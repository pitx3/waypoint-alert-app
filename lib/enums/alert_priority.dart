enum AlertPriority {
  low,
  normal,
  high,
  critical;

  String get displayname {
    switch (this) {
      case AlertPriority.low: return 'Low';
      case AlertPriority.normal: return 'Normal';
      case AlertPriority.high: return 'High';
      case AlertPriority.critical: return 'CRITICAL';
    }
  }

  /// Parse from CSF string (case-insensitive)
  static AlertPriority? fromString(String value) {
    final normalized = value.trim().toLowerCase();

    try {
      return AlertPriority.values.byName(normalized);
    } catch (_) {
      return null;
    }
  }

  bool get isUrgent => this == high || this == critical;

}