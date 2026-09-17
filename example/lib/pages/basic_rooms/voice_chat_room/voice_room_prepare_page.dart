import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'voice_room_page.dart';

class VoiceRoomPreparePage extends StatefulWidget {
  const VoiceRoomPreparePage({Key? key}) : super(key: key);

  @override
  State<VoiceRoomPreparePage> createState() => _VoiceRoomPreparePageState();
}

class _VoiceRoomPreparePageState extends State<VoiceRoomPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF6A1B9A);

  void _startVoiceChat() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoiceRoomPage(
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
      icon: Icons.voice_chat_rounded,
      accentColor: _accentColor,
      title: l10n.voiceChatRoomSetup,
      subtitle: l10n.descVoiceChatRoom,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.joinVoiceRoom,
      onAction: _startVoiceChat,
    );
  }
}
