import '../constants/app_constants.dart';

class AppSettings {
  final int gpsPingInterval;
  final int gpsTimeoutSeconds;
  final int walkingSpeedMpm;
  final int defaultAlertDistanceM;
  final bool hasCompletedFirstRun;
  final int maxSearchDistanceM;

  AppSettings({
    this.gpsPingInterval = AppConstants.defaultGpsPingInterval,
    this.gpsTimeoutSeconds = AppConstants.defaultGpsTimeoutSeconds,
    this.walkingSpeedMpm = AppConstants.defaultWalkingSpeedMpm,
    this.defaultAlertDistanceM = AppConstants.defaultAlertDistanceM,
    this.hasCompletedFirstRun = AppConstants.defaultHasCompletedFirstRun,
    this.maxSearchDistanceM = AppConstants.defaultMaxSearchDistanceM,
  });

  AppSettings copyWith({
    int? gpsPingInterval,
    int? gpsTimeoutSeconds,
    int? walkingSpeedMpm,
    int? defaultAlertDistanceM,
    bool? hasCompletedFirstRun,
    int? maxSearchDistanceM,
  }) {
    return AppSettings(
      gpsPingInterval: gpsPingInterval ?? this.gpsPingInterval,
      gpsTimeoutSeconds: gpsTimeoutSeconds ?? this.gpsTimeoutSeconds,
      walkingSpeedMpm: walkingSpeedMpm ?? this.walkingSpeedMpm,
      defaultAlertDistanceM: defaultAlertDistanceM ?? this.defaultAlertDistanceM,
      hasCompletedFirstRun: hasCompletedFirstRun ?? this.hasCompletedFirstRun,
      maxSearchDistanceM: maxSearchDistanceM ?? this.maxSearchDistanceM,
    );
  }
}