import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shizuku_api_plugin/shizuku_api.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

/// Language choices offered by the demo's drop-down.
enum AppLocale { system, english, chinese }

/// Demonstrates the recommended `shizuku_api_plugin` flow:
/// check service → check permission → request permission → run command.
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.api});

  /// Injectable so widget tests can substitute a fake.
  final ShizukuApi? api;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLocale _localeOption = AppLocale.system;

  /// `null` leaves the locale to the system, which is the default.
  Locale? get _locale => switch (_localeOption) {
    AppLocale.system => null,
    AppLocale.english => const Locale('en'),
    AppLocale.chinese => const Locale('zh'),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DemoHome(
        api: widget.api,
        localeOption: _localeOption,
        onLocaleChanged: (option) => setState(() => _localeOption = option),
      ),
    );
  }
}

/// The demo page. Lives below [MaterialApp] so it can read [AppLocalizations]
/// and [ScaffoldMessenger] from its [BuildContext].
class DemoHome extends StatefulWidget {
  const DemoHome({
    super.key,
    this.api,
    required this.localeOption,
    required this.onLocaleChanged,
  });

  final ShizukuApi? api;
  final AppLocale localeOption;
  final ValueChanged<AppLocale> onLocaleChanged;

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  late final ShizukuApi _api = widget.api ?? ShizukuApi();

  final _commandController = TextEditingController(text: 'wm size');

  /// `null` means "not checked yet".
  bool? _binderRunning;
  bool? _permissionGranted;

  bool _checking = false;
  bool _requesting = false;
  bool _running = false;
  ({String text, bool isError})? _output;

  static const _quickCommands = <String>[
    'wm size',
    'pm list packages -3',
    'getprop ro.build.version.release',
    'settings get global airplane_mode_on',
    'dumpsys battery | grep level',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-refresh once the first frame is built so the demo shows live status.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshStatus());
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final binder = await _api.pingBinder() ?? false;
      final granted = binder ? await _api.checkPermission() ?? false : false;
      if (!mounted) return;
      setState(() {
        _binderRunning = binder;
        _permissionGranted = granted;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _binderRunning = false;
        _permissionGranted = false;
      });
      final l10n = AppLocalizations.of(context);
      _showSnack(l10n.checkStatusFailed(error.message ?? error.code));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _requestPermission() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      final granted = await _api.requestPermission() ?? false;
      if (!mounted) return;
      setState(() {
        _permissionGranted = granted;
        if (granted) _binderRunning = true;
      });
      final l10n = AppLocalizations.of(context);
      _showSnack(
        granted ? l10n.snackPermissionGranted : l10n.snackPermissionDenied,
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showSnack(l10n.requestPermissionFailed(error.message ?? error.code));
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _runCommand([String? preset]) async {
    if (_running) return;
    final command = (preset ?? _commandController.text).trim();
    if (command.isEmpty) {
      _showSnack(AppLocalizations.of(context).enterCommand);
      return;
    }
    if (preset != null) {
      _commandController.text = command;
    }
    setState(() {
      _running = true;
      _output = null;
    });
    try {
      final output = await _api.runCommand(command) ?? '';
      if (!mounted) return;
      setState(() => _output = (text: output, isError: false));
    } on PlatformException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(
        () => _output = (
          text: l10n.commandFailed(error.message ?? error.code),
          isError: true,
        ),
      );
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).appTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [_buildLanguageSelector()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(),
            const SizedBox(height: 12),
            _buildPermissionCard(),
            const SizedBox(height: 12),
            _buildCommandCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final l10n = AppLocalizations.of(context);

    Widget menuItem(String text) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(text)],
    );

    Widget barItem(String text) => Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Text(text)],
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DropdownButton<AppLocale>(
        key: const ValueKey('language-dropdown'),
        value: widget.localeOption,
        underline: const SizedBox.shrink(),
        selectedItemBuilder: (context) => <Widget>[
          barItem(l10n.followSystem),
          barItem('English'),
          barItem('简体中文'),
        ],
        onChanged: (option) {
          if (option != null) widget.onLocaleChanged(option);
        },
        items: <DropdownMenuItem<AppLocale>>[
          DropdownMenuItem(
            value: AppLocale.system,
            child: menuItem(l10n.followSystem),
          ),
          DropdownMenuItem(
            value: AppLocale.english,
            child: menuItem('English'),
          ),
          DropdownMenuItem(value: AppLocale.chinese, child: menuItem('简体中文')),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_outlined),
                const SizedBox(width: 8),
                Text(
                  l10n.status,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.checkStatus,
                  onPressed: _checking ? null : _refreshStatus,
                  icon: _checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _statusRow(
              l10n.shizukuService,
              _binderRunning,
              positive: l10n.serviceRunning,
              negative: l10n.serviceNotRunning,
            ),
            const SizedBox(height: 8),
            _statusRow(
              l10n.permission,
              _permissionGranted,
              positive: l10n.permissionGranted,
              negative: l10n.permissionDenied,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(
    String label,
    bool? value, {
    required String positive,
    required String negative,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        _statusBadge(value, positive: positive, negative: negative),
      ],
    );
  }

  Widget _statusBadge(
    bool? value, {
    required String positive,
    required String negative,
  }) {
    final l10n = AppLocalizations.of(context);
    final (icon, label, color) = switch (value) {
      true => (Icons.check_circle, positive, Colors.green),
      false => (Icons.cancel, negative, Colors.red),
      null => (Icons.help_outline, l10n.unknown, Colors.grey),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Widget _buildPermissionCard() {
    final l10n = AppLocalizations.of(context);
    final binderRunning = _binderRunning == true;
    final granted = _permissionGranted == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.permission,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (!binderRunning)
              Text(l10n.startShizukuFirst)
            else if (granted)
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  Expanded(child: Text(l10n.canRunCommandsNow)),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: Text(l10n.permissionNotGrantedYet)),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _requesting ? null : _requestPermission,
                    child: _requesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.requestPermission),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandCard() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.runCommand,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final command in _quickCommands)
                  ActionChip(
                    label: Text(command),
                    onPressed: _running ? null : () => _runCommand(command),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commandController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.commandLabel,
                hintText: l10n.commandHint,
              ),
              onSubmitted: (_) => _runCommand(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _running ? null : () => _runCommand(),
                icon: _running
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(l10n.run),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.output, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildOutput(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutput() {
    final l10n = AppLocalizations.of(context);
    final output = _output;
    final Widget content;
    if (_running) {
      content = const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (output == null) {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(l10n.noOutputYet)),
      );
    } else {
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          output.text.isEmpty ? l10n.emptyOutput : output.text,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: output.isError
                ? Colors.red
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}

final _lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  useMaterial3: true,
);

final _darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
