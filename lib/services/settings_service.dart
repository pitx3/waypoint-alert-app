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
      walkingSpeedMpm: prefs.getInt(AppConstants.keyWalkingSpeedMpm) ?? AppConstants.defaultWalkingSpeedMpm,
      defaultAlertDistanceM: prefs.getInt(AppConstants.keyDefaultAlertDistanceM) ?? AppConstants.defaultAlertDistanceM,
      hasCompletedFirstRun: prefs.getBool(AppConstants.keyHasCompletedFirstRun) ?? AppConstants.defaultHasCompletedFirstRun
    );
  }

  Future<void> setGpsPingInterval(int seconds) async {
    await prefs.setInt(AppConstants.keyGpsPingInterval, seconds);
  }

  Future<void> setWalkingSpeedMpm(int seconds) async {
    await prefs.setInt(AppConstants.keyWalkingSpeedMpm, seconds);
  }

  Future<void> setDefaultAlertDistanceM(int meters) async {
    await prefs.setInt(AppConstants.keyDefaultAlertDistanceM, meters);
  }

  bool get isFirstRun => !prefs.containsKey(AppConstants.keyHasCompletedFirstRun);
  Future<void> setFirstRunComplete() async {
    await prefs.setBool(AppConstants.keyHasCompletedFirstRun, true);
  }

  Future<int?> getActiveSetId() async => prefs.getInt(AppConstants.keyActiveSetId);
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