// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Shizuku API 演示';

  @override
  String get language => '语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get status => '状态';

  @override
  String get checkStatus => '检查状态';

  @override
  String get shizukuService => 'Shizuku 服务';

  @override
  String get permission => '权限';

  @override
  String get serviceRunning => '运行中';

  @override
  String get serviceNotRunning => '未运行';

  @override
  String get permissionGranted => '已授权';

  @override
  String get permissionDenied => '未授权';

  @override
  String get unknown => '未知';

  @override
  String get startShizukuFirst => '请先启动 Shizuku，然后再申请权限。';

  @override
  String get canRunCommandsNow => '已获得权限，现在可以执行命令了。';

  @override
  String get permissionNotGrantedYet => '尚未获得权限。';

  @override
  String get requestPermission => '申请权限';

  @override
  String get snackPermissionGranted => '权限已授予。';

  @override
  String get snackPermissionDenied => '权限被拒绝。';

  @override
  String checkStatusFailed(String error) {
    return '检查状态失败：$error';
  }

  @override
  String requestPermissionFailed(String error) {
    return '申请权限失败：$error';
  }

  @override
  String get runCommand => '执行命令';

  @override
  String get commandLabel => '命令';

  @override
  String get commandHint => '例如 wm size、pm list packages';

  @override
  String get run => '运行';

  @override
  String get output => '输出';

  @override
  String get noOutputYet => '暂无输出。';

  @override
  String get emptyOutput => '（输出为空）';

  @override
  String get enterCommand => '请输入命令。';

  @override
  String commandFailed(String error) {
    return '错误：$error';
  }
}
