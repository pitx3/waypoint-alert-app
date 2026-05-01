import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/constants/app_constants.dart';

import '../../helpers/expect_helpers.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late SettingsService settingsService;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    settingsService = SettingsService(mockPrefs);
  });


  group('getSettings', () {
    test('returns defaults when no values stored', () {
      when(() => mockPrefs.getInt(AppConstants.keyGpsPingInterval)).thenReturn(null);
      when(() => mockPrefs.getInt(AppConstants.keyWalkingSpeedMpm)).thenReturn(null);
      when(() => mockPrefs.getInt(AppConstants.keyDefaultAlertDistanceM)).thenReturn(null);
      when(() => mockPrefs.getBool(AppConstants.keyHasCompletedFirstRun)).thenReturn(null);

      final settings = settingsService.getSettings();

      expect(settings.gpsPingInterval, AppConstants.defaultGpsPingInterval, reason: 'Did not get default GPS ping interval');
      expect(settings.walkingSpeedMpm, AppConstants.defaultWalkingSpeedMpm, reason: 'Did not get default Walking Speed mpm');
      expect(settings.defaultAlertDistanceM, AppConstants.defaultAlertDistanceM, reason: 'Did not get default Alert Distance');
      expect(settings.hasCompletedFirstRun, AppConstants.defaultHasCompletedFirstRun, reason: 'Did not get default Has Completed First Run');
    });

    test('returns stored values when present', () {
      when(() => mockPrefs.getInt(AppConstants.keyGpsPingInterval)).thenReturn(120);
      when(() => mockPrefs.getInt(AppConstants.keyWalkingSpeedMpm)).thenReturn(100);
      when(() => mockPrefs.getInt(AppConstants.keyDefaultAlertDistanceM)).thenReturn(500);
      when(() => mockPrefs.getBool(AppConstants.keyHasCompletedFirstRun)).thenReturn(true);

      final settings = settingsService.getSettings();

      expect(settings.gpsPingInterval, 120, reason: 'Did not get assigned GPS ping interval');
      expect(settings.walkingSpeedMpm, 100, reason: 'Did not get assigned Walking Speed mpm');
      expect(settings.defaultAlertDistanceM, 500, reason: 'Did not get assigned Alert Distance');
      expect(settings.hasCompletedFirstRun, true, reason: 'Did not get assigned Has Completed First Run');
    });  
  });

  group('setters', (){
    test('setGpsPingInterval stores value', () async {
      when (() => mockPrefs.setInt(AppConstants.keyGpsPingInterval, 180))
        .thenAnswer((_) async => true);
      await settingsService.setGpsPingInterval(180);
      verify(() => mockPrefs.setInt(AppConstants.keyGpsPingInterval, 180)).called(1);
    });

    test('setWalkingSpeedMpm stores value', () async {
      when (() => mockPrefs.setInt(AppConstants.keyWalkingSpeedMpm, 200))
        .thenAnswer((_) async => true);
      await settingsService.setWalkingSpeedMpm(200);
      verify(() => mockPrefs.setInt(AppConstants.keyWalkingSpeedMpm, 200)).called(1);
    });
    
    test('setDefaultAlertDistanceM stores value', () async {
      when (() => mockPrefs.setInt(AppConstants.keyDefaultAlertDistanceM, 400))
        .thenAnswer((_) async => true);
      await settingsService.setDefaultAlertDistanceM(400);
      verify(() => mockPrefs.setInt(AppConstants.keyDefaultAlertDistanceM, 400)).called(1);
    });
    
    test('setFirtRunComplete stores true', () async {
      when (() => mockPrefs.setBool(AppConstants.keyHasCompletedFirstRun, true))
        .thenAnswer((_) async => true);
      await settingsService.setFirstRunComplete();
      verify(() => mockPrefs.setBool(AppConstants.keyHasCompletedFirstRun, true)).called(1);
    });
    
  });

  group('isFirstRun', () {
    test('returns true when key not present', () {
      when(() => mockPrefs.containsKey(AppConstants.keyHasCompletedFirstRun)).thenReturn(false);
      expect(settingsService.isFirstRun, true);
    });
    test('returns false when key is present', () {
      when(() => mockPrefs.containsKey(AppConstants.keyHasCompletedFirstRun)).thenReturn(true);
      expect(settingsService.isFirstRun, false);
    });
  });

  group('activeSetId', () {
    test('getActiveSetId returns null when not set', () async {
      when(() => mockPrefs.getInt(AppConstants.keyActiveSetId)).thenReturn(null);

      final result = await settingsService.getActiveSetId();

      expectNull(result, reason: 'ActiveSetId should be null when not set.');
    });

    test('getActiveSetId returns stored value', () async {
      when(() => mockPrefs.getInt(AppConstants.keyActiveSetId)).thenReturn(42);

      final result = await settingsService.getActiveSetId();

      expect(result, 42, reason: 'Should return stored active set ID');
    });

    test('setActveSetId stored value', () async {
      when(() => mockPrefs.setInt(AppConstants.keyActiveSetId, 15))
        .thenAnswer((_) async => true);

      await settingsService.setActiveSetId(15);

      verify(() => mockPrefs.setInt(AppConstants.keyActiveSetId, 15)).called(1);
    });
  
    test('setActiveSetId removes key when null', () async {
      when(() => mockPrefs.remove(AppConstants.keyActiveSetId))
        .thenAnswer((_) async => true);

      await settingsService.setActiveSetId(null);

      verify(() => mockPrefs.remove(AppConstants.keyActiveSetId)).called(1);
    });

  });

}