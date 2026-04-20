/// TFLite detection model data source.
///
/// Uses the same interpreter lifecycle pattern as disease detection:
///   - lazy initialise()
///   - iOS CoreML delegate attempt, CPU fallback
///   - runInference() on preprocessed Float32 input
///
/// This datasource additionally normalises tensor layouts for detection models
/// because exported models may differ (NHWC/NCHW input and [1,rows,cols] vs
/// [1,cols,rows] output).
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

final class ModelDataSource {
	ModelDataSource({required this.modelAssetPath});

	final String modelAssetPath;

	Interpreter? _interpreter;
	bool _isInitialised = false;
	String _activeDelegate = 'CPU';

	// Input layout metadata
	int _inputSize = AppConstants.inputSize;
	int _inputHeight = AppConstants.inputSize;
	int _inputWidth = AppConstants.inputSize;
	int _inputChannels = 3;
	bool _inputIsNchw = false;

	// Output layout metadata
	int _outputRows = AppConstants.numClasses + 4;
	int _outputCols = 8400;
	bool _outputIsTransposed = false;

	List<int> _inputTensorShape = const [1, 640, 640, 3];
	List<int> _outputTensorShape = const [1, 7, 8400];

	bool get isInitialised => _isInitialised;
	String get activeDelegate => _activeDelegate;

	/// Spatial size expected by existing preprocessing path.
	int get inputSize => _inputSize;

	// ── Initialisation ────────────────────────────────────────────────────────

	Future<void> initialise() async {
		if (_isInitialised) return;

		final threads = (Platform.numberOfProcessors - 1).clamp(2, 4);

		final delegatesToTry = <_DelegateTier>[
			if (Platform.isIOS)
				_DelegateTier(name: 'CoreML', build: () => CoreMlDelegate()),
		];

		for (final tier in delegatesToTry) {
			try {
				final options = InterpreterOptions()..threads = threads;
				options.addDelegate(tier.build());
				_interpreter = await Interpreter.fromAsset(
					modelAssetPath,
					options: options,
				);
				_interpreter!.allocateTensors();
				_isInitialised = true;
				_activeDelegate = tier.name;
				_cacheTensorLayouts(threads);
				return;
			} catch (e) {
				_log.w('${tier.name} delegate failed, trying next: $e');
				_interpreter?.close();
				_interpreter = null;
			}
		}

		try {
			final options = InterpreterOptions()..threads = threads;
			_interpreter = await Interpreter.fromAsset(
				modelAssetPath,
				options: options,
			);
			_interpreter!.allocateTensors();
			_isInitialised = true;
			_activeDelegate = 'CPU';
			_cacheTensorLayouts(threads);
		} catch (e, st) {
			_log.e('Detection model load failed (CPU fallback)', error: e, stackTrace: st);
			throw ModelFailure('Failed to load detection TFLite model: $e');
		}
	}

	void _cacheTensorLayouts(int threads) {
		_inputTensorShape = _interpreter!.getInputTensor(0).shape;
		_outputTensorShape = _interpreter!.getOutputTensor(0).shape;
		_cacheInputLayout(_inputTensorShape);
		_cacheOutputLayout(_outputTensorShape);

		_log.i(
			'Detection model ready [$_activeDelegate] — '
			'input: $_inputTensorShape  output: $_outputTensorShape  '
			'threads: $threads  nchwInput: $_inputIsNchw  '
			'transposedOutput: $_outputIsTransposed',
		);
	}

	// ── Inference ─────────────────────────────────────────────────────────────

	Future<List<List<double>>> runInference(Float32List inputBuffer) async {
		if (!_isInitialised || _interpreter == null) {
			throw StateError('ModelDataSource not initialised. Call initialise() first.');
		}

		final expectedInputLength = _inputHeight * _inputWidth * _inputChannels;
		if (inputBuffer.length != expectedInputLength) {
			throw ArgumentError(
				'Input tensor shape mismatch: expected flat length $expectedInputLength '
				'for input $_inputTensorShape, got ${inputBuffer.length}.',
			);
		}

		final input = _inputIsNchw
				? _toNchw(inputBuffer).reshape([1, _inputChannels, _inputHeight, _inputWidth])
				: inputBuffer.reshape([1, _inputHeight, _inputWidth, _inputChannels]);

		final output = List.generate(
			1,
			(_) => List.generate(
				_outputRows,
				(_) => List<double>.filled(_outputCols, 0.0),
			),
		);

		try {
			_interpreter!.run(input, output);
		} on ArgumentError catch (e) {
			throw StateError(
				'Model inference shape mismatch. '
				'Input shape: $_inputTensorShape, output shape: $_outputTensorShape, '
				'rows/cols: $_outputRows/$_outputCols, transpose: $_outputIsTransposed. '
				'Error: $e',
			);
		}

		final raw = output[0];
		if (_outputIsTransposed) {
			return _transpose2D(raw);
		}
		return raw;
	}

	void _cacheInputLayout(List<int> inputShape) {
		if (inputShape.length < 4) {
			throw ModelFailure(
				'Unsupported input tensor shape: $inputShape. '
				'Expected [1, H, W, C] or [1, C, H, W].',
			);
		}

		if (inputShape[1] == 3 && inputShape[3] != 3) {
			_inputIsNchw = true;
			_inputChannels = inputShape[1];
			_inputHeight = inputShape[2];
			_inputWidth = inputShape[3];
		} else {
			_inputIsNchw = false;
			_inputHeight = inputShape[1];
			_inputWidth = inputShape[2];
			_inputChannels = inputShape[3] <= 0 ? 3 : inputShape[3];
		}
		_inputSize = _inputHeight > _inputWidth ? _inputHeight : _inputWidth;
	}

	void _cacheOutputLayout(List<int> outputShape) {
		if (outputShape.length < 3) {
			throw ModelFailure(
				'Unsupported output tensor shape: $outputShape. '
				'Expected [1, rows, cols] or [1, cols, rows].',
			);
		}

		final dimA = outputShape[1];
		final dimB = outputShape[2];

		final aLooksLikeRows = dimA <= 256 && dimB > dimA;
		final bLooksLikeRows = dimB <= 256 && dimA > dimB;

		if (aLooksLikeRows) {
			_outputRows = dimA;
			_outputCols = dimB;
			_outputIsTransposed = false;
			return;
		}
		if (bLooksLikeRows) {
			_outputRows = dimB;
			_outputCols = dimA;
			_outputIsTransposed = true;
			return;
		}

		_outputRows = dimA;
		_outputCols = dimB;
		_outputIsTransposed = false;
	}

	Float32List _toNchw(Float32List sourceHwc) {
		final converted = Float32List(sourceHwc.length);
		var dst = 0;
		for (var c = 0; c < _inputChannels; c++) {
			for (var y = 0; y < _inputHeight; y++) {
				for (var x = 0; x < _inputWidth; x++) {
					final src = ((y * _inputWidth + x) * _inputChannels) + c;
					converted[dst++] = sourceHwc[src];
				}
			}
		}
		return converted;
	}

	List<List<double>> _transpose2D(List<List<double>> source) {
		if (source.isEmpty) return source;
		final rows = source.length;
		final cols = source[0].length;
		final transposed = List.generate(
			cols,
			(_) => List<double>.filled(rows, 0.0),
		);
		for (var r = 0; r < rows; r++) {
			for (var c = 0; c < cols; c++) {
				transposed[c][r] = source[r][c];
			}
		}
		return transposed;
	}

	Future<void> dispose() async {
		_interpreter?.close();
		_interpreter = null;
		_isInitialised = false;
	}
}

final class _DelegateTier {
	const _DelegateTier({required this.name, required this.build});
	final String name;
	final Delegate Function() build;
}

