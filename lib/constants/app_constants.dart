class AppConstants {

  // SharedPreferences keys
  static const String keyGpsPingInterval = 'gps_ping_interval';
  static const String keyWalkingSpeedMpm = 'walking_speed_mpm';
  static const String keyDefaultAlertDistanceM = 'default_alert_distance_m';
  static const String keyHasCompletedFirstRun = 'has_completed_first_run';

  // Default values
  static const int defaultGpsPingInterval = 300;
  static const int defaultWalkingSpeedMpm = 100;
  static const int defaultAlertDistanceM = 250;
  static const bool defaultHasCompletedFirstRun = false;

  // Validation ranges
  static const int minGpsPingInterval = 30;
  static const int maxGpsPingInterval = 600;   // ten minutes
  static const int minWalkingSpeedMpm = 30;
  static const int maxWalkingSppedMpm = 300;   // 5m/sec
  static const int minAlertDistanceM = 50;
  static const int maxAlertDistanceM = 1000;

}