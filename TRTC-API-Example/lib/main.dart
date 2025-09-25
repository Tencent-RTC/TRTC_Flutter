import 'package:api_example/router/router_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (TRTCPlatform.isOhos || TRTCPlatform.isAndroid) ? const PermissionGateScreen() : const RouterPage(),
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
      debugPrint('权限请求异常: $e');
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 20),
        const Text('需要开启摄像头和麦克风权限才能进行视频通话',
            style: TextStyle(fontSize: 16)),
        const SizedBox(height: 30),
        FilledButton(
          onPressed: onRetry,
          child: const Text('重试授权'),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => openAppSettings(),
          child: const Text('前往系统设置'),
        ),
      ],
    );
  }
}
