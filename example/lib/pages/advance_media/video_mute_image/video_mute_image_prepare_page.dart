import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'video_mute_image_page.dart';

class VideoMuteImagePreparePage extends StatefulWidget {
  const VideoMuteImagePreparePage({Key? key}) : super(key: key);

  @override
  State<VideoMuteImagePreparePage> createState() =>
      _VideoMuteImagePreparePageState();
}

class _VideoMuteImagePreparePageState
    extends State<VideoMuteImagePreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();
  bool _sdkReady = false;

  static const _accentColor = Color(0xFF455A64);

  @override
  void initState() {
    super.initState();
    _initSdk();
  }

  Future<void> _initSdk() async {
    await TRTCCloud.sharedInstance();
    if (mounted) setState(() => _sdkReady = true);
  }

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoMuteImagePage(
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
      icon: Icons.image_rounded,
      accentColor: _accentColor,
      title: l10n.sceneVideoMuteImage,
      subtitle: l10n.descVideoMuteImage,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _sdkReady ? _onEnter : null,
    );
  }
}
