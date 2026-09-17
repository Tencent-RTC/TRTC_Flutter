import 'package:api_example/common/locale_controller.dart';
import 'package:api_example/common/room_input_prefs.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:api_example/router/router_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RoomInputPrefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleController()..init(),
      child: Consumer<LocaleController>(
        builder: (context, localeController, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: localeController.locale,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (localeController.locale != null) {
                return localeController.locale;
              }
              for (final loc in supportedLocales) {
                if (loc.languageCode == deviceLocale?.languageCode) {
                  return loc;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C6EF5)),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF6F7FB),
            ),
            home: (TRTCPlatform.isOhos || TRTCPlatform.isAndroid)
                ? const PermissionGateScreen()
                : const RouterPage(),
          );
        },
      ),
    );
  }
}

class PermissionGateScreen extends StatefulWidget {
  const PermissionGateScreen({super.key});

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen> {
  bool _isCheckingPermissions = true;
  bool _isPermissionRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (_isPermissionRequesting) return;
    _isPermissionRequesting = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final allGranted = statuses.values.every((s) => s.isGranted);

      if (allGranted) {
        _navigateToMainScreen();
      } else {
        setState(() => _isCheckingPermissions = false);
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    } finally {
      _isPermissionRequesting = false;
    }
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RouterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isCheckingPermissions
            ? const CircularProgressIndicator()
            : _PermissionDeniedUI(onRetry: _checkPermissions),
      ),
    );
  }
}

class _PermissionDeniedUI extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionDeniedUI({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 20),
        Text(l10n.permissionRequired, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 30),
        FilledButton(
          onPressed: onRetry,
          child: Text(l10n.retryPermission),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text(l10n.goToSettings),
        ),
      ],
    );
  }
}
