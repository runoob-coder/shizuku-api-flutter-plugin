// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shizuku API Demo';

  @override
  String get language => 'Language';

  @override
  String get followSystem => 'Follow system';

  @override
  String get status => 'Status';

  @override
  String get checkStatus => 'Check status';

  @override
  String get shizukuService => 'Shizuku service';

  @override
  String get permission => 'Permission';

  @override
  String get serviceRunning => 'Running';

  @override
  String get serviceNotRunning => 'Not running';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionDenied => 'Denied';

  @override
  String get unknown => 'Unknown';

  @override
  String get startShizukuFirst =>
      'Start Shizuku first, then request permission.';

  @override
  String get canRunCommandsNow =>
      'Permission granted. You can run commands now.';

  @override
  String get permissionNotGrantedYet => 'Permission not granted yet.';

  @override
  String get requestPermission => 'Request permission';

  @override
  String get snackPermissionGranted => 'Permission granted.';

  @override
  String get snackPermissionDenied => 'Permission denied.';

  @override
  String checkStatusFailed(String error) {
    return 'Failed to check status: $error';
  }

  @override
  String requestPermissionFailed(String error) {
    return 'Failed to request permission: $error';
  }

  @override
  String get runCommand => 'Run command';

  @override
  String get commandLabel => 'Command';

  @override
  String get commandHint => 'e.g. wm size, pm list packages';

  @override
  String get run => 'Run';

  @override
  String get output => 'Output';

  @override
  String get noOutputYet => 'No output yet.';

  @override
  String get emptyOutput => '(empty output)';

  @override
  String get enterCommand => 'Please enter a command.';

  @override
  String commandFailed(String error) {
    return 'Error: $error';
  }
}
