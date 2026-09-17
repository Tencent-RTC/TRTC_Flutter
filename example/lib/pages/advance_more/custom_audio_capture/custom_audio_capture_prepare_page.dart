import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'custom_audio_capture_page.dart';

class CustomAudioCapturePreparePage extends StatefulWidget {
  const CustomAudioCapturePreparePage({Key? key}) : super(key: key);

  @override
  State<CustomAudioCapturePreparePage> createState() =>
      _CustomAudioCapturePreparePageState();
}

class _CustomAudioCapturePreparePageState
    extends State<CustomAudioCapturePreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF6A1B9A);

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomAudioCapturePage(
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
      icon: Icons.mic_external_on,
      accentColor: _accentColor,
      title: l10n.customAudioCaptureTitle,
      subtitle: l10n.descCustomAudioCapture,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnter,
    );
  }
}
