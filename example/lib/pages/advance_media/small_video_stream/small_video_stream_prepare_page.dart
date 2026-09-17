import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'small_video_stream_page.dart';

class SmallVideoStreamPreparePage extends StatefulWidget {
  const SmallVideoStreamPreparePage({Key? key}) : super(key: key);

  @override
  State<SmallVideoStreamPreparePage> createState() =>
      _SmallVideoStreamPreparePageState();
}

class _SmallVideoStreamPreparePageState
    extends State<SmallVideoStreamPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();
  bool _sdkReady = false;

  static const _accentColor = Color(0xFF00838F);

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
          builder: (_) => SmallVideoStreamPage(
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
      icon: Icons.picture_in_picture_alt_rounded,
      accentColor: _accentColor,
      title: l10n.sceneSmallVideoStream,
      subtitle: l10n.descSmallVideoStream,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _sdkReady ? _onEnter : null,
    );
  }
}
