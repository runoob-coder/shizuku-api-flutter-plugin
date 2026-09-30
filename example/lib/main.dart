import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shizuku_api_plugin/shizuku_api.dart';

void main() {
  runApp(const MyApp());
}

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
  late final ShizukuApi _api = widget.api ?? ShizukuApi();

  final _commandController = TextEditingController(text: 'wm size');

  /// `null` means "not checked yet".
  bool? _binderRunning;
  bool? _permissionGranted;

  bool _checking = false;
  bool _requesting = false;
  bool _running = false;
  String? _output;

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
      _showSnack('Failed to check status: ${error.message ?? error.code}');
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
      _showSnack(granted ? 'Permission granted.' : 'Permission denied.');
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showSnack('Failed to request permission: ${error.message ?? error.code}');
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _runCommand([String? preset]) async {
    if (_running) return;
    final command = (preset ?? _commandController.text).trim();
    if (command.isEmpty) {
      _showSnack('Please enter a command.');
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
      setState(() => _output = output);
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _output = 'Error: ${error.message ?? error.code}');
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
    return MaterialApp(
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Shizuku API Demo')),
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
      ),
    );
  }

  Widget _buildStatusCard() {
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
                Text('Status', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  tooltip: 'Check status',
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
              'Shizuku service',
              _binderRunning,
              positive: 'Running',
              negative: 'Not running',
            ),
            const SizedBox(height: 8),
            _statusRow(
              'Permission',
              _permissionGranted,
              positive: 'Granted',
              negative: 'Denied',
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
    final (icon, label, color) = switch (value) {
      true => (Icons.check_circle, positive, Colors.green),
      false => (Icons.cancel, negative, Colors.red),
      null => (Icons.help_outline, 'Unknown', Colors.grey),
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
    final binderRunning = _binderRunning == true;
    final granted = _permissionGranted == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permission', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (!binderRunning)
              const Text('Start Shizuku first, then request permission.')
            else if (granted)
              const Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text('Permission granted. You can run commands now.'),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Expanded(child: Text('Permission not granted yet.')),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _requesting ? null : _requestPermission,
                    child: _requesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Request permission'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Run command', style: Theme.of(context).textTheme.titleMedium),
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Command',
                hintText: 'e.g. wm size, pm list packages',
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
                label: const Text('Run'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Output', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildOutput(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutput() {
    final output = _output;
    final Widget content;
    if (_running) {
      content = const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (output == null) {
      content = const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No output yet.')),
      );
    } else {
      final isError =
          output.startsWith('Error') || output.startsWith('Unexpected error');
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          output.isEmpty ? '(empty output)' : output,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: isError
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
