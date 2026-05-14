library;

import 'package:flutter/material.dart';
import '../../../../core/constants/farmer_strings.dart';
import '../../../../core/theme/app_theme.dart';

String? validateImageFile(int fileSize) {
  const maxFileSizeBytes = 5 * 1024 * 1024;

  if (fileSize == 0) {
    return FarmerStrings.errorImageEmpty;
  }

  if (fileSize > maxFileSizeBytes) {
    return FarmerStrings.errorImageLarge;
  }

  return null;
}

String getFriendlyErrorMessage(dynamic exception) {
  final errorString = '$exception'.toLowerCase();

  if (errorString.contains('permission') || errorString.contains('denied')) {
    return FarmerStrings.permissionCameraMessage;
  }

  if (errorString.contains('could not decode') ||
      errorString.contains('unsupported')) {
    return FarmerStrings.errorImageInvalid;
  }

  if (errorString.contains('empty')) {
    return FarmerStrings.errorImageEmpty;
  }

  if (errorString.contains('out of memory')) {
    return FarmerStrings.errorOutOfMemory;
  }

  if (errorString.contains('tensor') ||
      errorString.contains('shape') ||
      errorString.contains('mismatch')) {
    return FarmerStrings.errorModelMissing;
  }

  return FarmerStrings.errorGeneral;
}

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.onDismiss,
    this.icon = Icons.error_outline_rounded,
  });

  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onDismiss;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentLight.withAlpha(150),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentLight.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.accentLight,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (onDismiss != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                ),
              if (onDismiss != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showErrorSnackBar(
  BuildContext context, {
  required String message,
  VoidCallback? onRetry,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              onPressed: onRetry,
            )
          : null,
    ),
  );
}

class PermissionRequestCard extends StatelessWidget {
  const PermissionRequestCard({
    super.key,
    required this.title,
    required this.message,
    required this.onAllow,
    required this.onDeny,
  });

  final String title;
  final String message;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDeny,
                  child: const Text('Not Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAllow,
                  child: const Text('Allow'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
