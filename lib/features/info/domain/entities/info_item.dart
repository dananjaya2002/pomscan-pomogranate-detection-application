/// Shared domain entity for knowledge-base content items.
library;

enum InfoType { diseases, plantation, harvesting }

extension InfoTypeExt on InfoType {
  String get assetPath {
    switch (this) {
      case InfoType.diseases:
        return 'assets/content/diseases.json';
      case InfoType.plantation:
        return 'assets/content/plantation.json';
      case InfoType.harvesting:
        return 'assets/content/harvesting.json';
    }
  }

  String get title {
    switch (this) {
      case InfoType.diseases:
        return 'Diseases';
      case InfoType.plantation:
        return 'Plantation Guide';
      case InfoType.harvesting:
        return 'Harvesting Guide';
    }
  }
}

final class InfoItem {
  const InfoItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.details,
    this.tips = const [],
  });

  final String id;
  final String title;
  final String icon;
  final String description;

  /// For diseases: 'severity + cause + symptoms + treatment + prevention'.
  /// For others: 'indicator' field.
  final Map<String, dynamic> details;
  final List<String> tips;

  factory InfoItem.fromJson(Map<String, dynamic> json) {
    final tips = <String>[];
    final rawTips = json['tips'];
    if (rawTips is List) {
      tips.addAll(rawTips.cast<String>());
    }

    // Build a generic details map from whatever keys are present
    final details = <String, dynamic>{};
    for (final key in [
      'severity',
      'cause',
      'symptoms',
      'treatment',
      'prevention',
      'indicator',
    ]) {
      if (json.containsKey(key)) details[key] = json[key];
    }

    return InfoItem(
      id: json['id'] as String,
      title: json['name'] as String? ?? json['title'] as String,
      icon: json['icon'] as String? ?? '📄',
      // 'description' key is optional — fall back to 'symptoms', 'cause', or
      // empty string so disease/plantation/harvesting JSON missing the field
      // does not throw a type-cast error at runtime.
      description:
          json['description'] as String? ??
          json['symptoms'] as String? ??
          json['cause'] as String? ??
          '',
      details: details,
      tips: tips,
    );
  }
}
