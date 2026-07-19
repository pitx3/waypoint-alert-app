class AppConstants {

  // Set to "true" to start in "first run" mode
  static const bool debugResetFirstRun = false;

  // SharedPreferences keys
  static const String keyGpsPingInterval = 'gps_ping_interval';
  static const String keyGpsTimeoutSeconds = 'gps_timeout_seconds';
  static const String keyWalkingSpeedMpm = 'walking_speed_mpm';
  static const String keyDefaultAlertDistanceM = 'default_alert_distance_m';
  static const String keyHasCompletedFirstRun = 'has_completed_first_run';
  static const String keyActiveSetId = 'active_set_id';
  static const String keyMaxSearchDistanceM = 'max_search_distance_m';

  // Default values
  static const int defaultGpsPingInterval = 300;
  static const int defaultGpsTimeoutSeconds = 10;
  static const int defaultWalkingSpeedMpm = 100;
  static const int defaultAlertDistanceM = 250;
  static const bool defaultHasCompletedFirstRun = false;
  static const int defaultMaxSearchDistanceM = 5000;

  // Validation ranges
  static const int minGpsPingInterval = 30;
  static const int maxGpsPingInterval = 600;   // ten minutes
  static const int minGpsTimeoutSeconds = 5;
  static const int maxGpsTimeoutSeconds = 30;
  static const int minWalkingSpeedMpm = 30;
  static const int maxWalkingSpeedMpm = 300;   // 5m/sec
  static const int minAlertDistanceM = 50;
  static const int maxAlertDistanceM = 1000;

}