import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/src/generated/platform_bindings.g.dart';
import 'package:alarm/utils/alarm_exception.dart';
import 'package:alarm/utils/alarm_handler.dart';
import 'package:flutter/foundation.dart';

/// Uses method channel to interact with the native platform.
class IOSAlarm {
  static final AlarmApi _api = AlarmApi();

  /// Calls the native function `setAlarm` and listens to alarm ring state.
  ///
  /// Also set periodic timer and listens for app state changes to trigger
  /// the alarm ring callback at the right time.
  static Future<bool> setAlarm(AlarmSettings settings) async {
    final id = settings.id;
    try {
      await _api
          .setAlarm(alarmSettings: settings.toWire())
          .catchError(AlarmExceptionHandlers.catchError<void>);
      alarmPrint(
        'Alarm with id $id scheduled successfully at ${settings.dateTime}',
      );
    } on AlarmException catch (_) {
      await Alarm.stop(id);
      rethrow;
    }

    return true;
  }

  /// Disposes timer and FGBG subscription
  /// and calls the native `stopAlarm` function.
  static Future<bool> stopAlarm(int id) async {
    try {
      await _api
          .stopAlarm(alarmId: id)
          .catchError(AlarmExceptionHandlers.catchError<void>);
      alarmPrint('Alarm with id $id stopped');
      return true;
    } on AlarmException catch (e) {
      alarmPrint('Failed to stop alarm $id. $e');
      return false;
    }
  }

  /// Checks whether an alarm or any alarm (if id is null) is ringing.
  static Future<bool> isRinging([int? id]) async {
    try {
      final res = await _api
          .isRinging(alarmId: id)
          .catchError(AlarmExceptionHandlers.catchError<bool>);
      return res;
    } on AlarmException catch (e) {
      debugPrint('Error checking if alarm is ringing: $e');
      return false;
    }
  }

  /// Sets the native notification on app kill title and body.
  static Future<void> setWarningNotificationOnKill(String title, String body) =>
      _api
          .setWarningNotificationOnKill(title: title, body: body)
          .catchError(AlarmExceptionHandlers.catchError<void>);
}
