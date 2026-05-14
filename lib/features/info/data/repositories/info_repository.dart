library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/info_item.dart';

final class InfoRepository {
  const InfoRepository();

  Future<List<InfoItem>> load(InfoType type) async {
    final raw = await rootBundle.loadString(type.assetPath);
    final list = json.decode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>().map(InfoItem.fromJson).toList();
  }
}
