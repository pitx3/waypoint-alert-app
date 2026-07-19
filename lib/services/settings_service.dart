import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint_alert_app/constants/app_constants.dart';
import 'package:waypoint_alert_app/models/app_settings.dart';

class SettingsService {
  final SharedPreferences prefs;

  SettingsService(this.prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  AppSettings getSettings() {
    return AppSettings(
      gpsPingInterval: prefs.getInt(AppConstants.keyGpsPingInterval) ?? AppConstants.defaultGpsPingInterval,
      gpsTimeoutSeconds: prefs.getInt(AppConstants.keyGpsTimeoutSeconds) ?? AppConstants.defaultGpsTimeoutSeconds,
      walkingSpeedMpm: prefs.getInt(AppConstants.keyWalkingSpeedMpm) ?? AppConstants.defaultWalkingSpeedMpm,
      defaultAlertDistanceM: prefs.getInt(AppConstants.keyDefaultAlertDistanceM) ?? AppConstants.defaultAlertDistanceM,
      hasCompletedFirstRun: prefs.getBool(AppConstants.keyHasCompletedFirstRun) ?? AppConstants.defaultHasCompletedFirstRun,
      maxSearchDistanceM: prefs.getInt(AppConstants.keyMaxSearchDistanceM) ?? AppConstants.defaultMaxSearchDistanceM,
    );
  }

  Future<void> setGpsPingInterval(int seconds) async {
    await prefs.setInt(AppConstants.keyGpsPingInterval, seconds);
  }

  Future<void> setGpsTimeoutSeconds(int seconds) async {
    await prefs.setInt(AppConstants.keyGpsTimeoutSeconds, seconds);
  }

  Future<void> setWalkingSpeedMpm(int seconds) async {
    await prefs.setInt(AppConstants.keyWalkingSpeedMpm, seconds);
  }

  Future<void> setDefaultAlertDistanceM(int meters) async {
    await prefs.setInt(AppConstants.keyDefaultAlertDistanceM, meters);
  }

  Future<void> setMaxSearchDistanceM(int meters) async {
    await prefs.setInt(AppConstants.keyMaxSearchDistanceM, meters);
  }

  // First Run Flag
  bool get isFirstRun => !prefs.containsKey(AppConstants.keyHasCompletedFirstRun);
  Future<void> setFirstRunComplete() async {
    await prefs.setBool(AppConstants.keyHasCompletedFirstRun, true);
  }

  /*  Specific settings getters (that aren't really getters) for convenience   */
  int getGpsPingInterval() =>
    prefs.getInt(AppConstants.keyGpsPingInterval)
    ?? AppConstants.defaultGpsPingInterval;

  int getGpsTimeoutSeconds() => 
    prefs.getInt(AppConstants.keyGpsTimeoutSeconds)
    ?? AppConstants.defaultGpsTimeoutSeconds;

  int getMaxSearchDistanceM() => 
    prefs.getInt(AppConstants.keyMaxSearchDistanceM) 
    ?? AppConstants.defaultMaxSearchDistanceM;
  

  int? getActiveSetId() => prefs.getInt(AppConstants.keyActiveSetId);

  Future<void> setActiveSetId(int? id) async {
    if (id == null) {
      await prefs.remove(AppConstants.keyActiveSetId);
    } else {
      await prefs.setInt(AppConstants.keyActiveSetId, id);
    }
  }
  
  Future<void> resetFirstRunForDebug() async {
    if (AppConstants.debugResetFirstRun) {
      await prefs.remove(AppConstants.keyHasCompletedFirstRun);
    }
  }



}