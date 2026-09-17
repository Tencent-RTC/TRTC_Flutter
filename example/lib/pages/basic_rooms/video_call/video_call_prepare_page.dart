import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'video_call_page.dart';

class VideoCallPreparePage extends StatefulWidget {
  const VideoCallPreparePage({Key? key}) : super(key: key);

  @override
  State<VideoCallPreparePage> createState() => _VideoCallPreparePageState();
}

class _VideoCallPreparePageState extends State<VideoCallPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();
  bool _sdkReady = false;

  static const _accentColor = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _initSdk();
  }

  Future<void> _initSdk() async {
    await TRTCCloud.sharedInstance();
    if (mounted) setState(() => _sdkReady = true);
  }

  void _startCall() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallPage(
            userId: _formKey.currentState!.userId,
            roomIdSpec: _formKey.currentState!.roomIdSpec,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SceneEntryScaffold(
      icon: Icons.videocam_rounded,
      accentColor: _accentColor,
      title: l10n.videoCallSetup,
      subtitle: l10n.descVideoCall,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.startCall,
      onAction: _sdkReady ? _startCall : null,
    );
  }
}
