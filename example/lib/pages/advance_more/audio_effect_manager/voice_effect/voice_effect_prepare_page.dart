import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'voice_effect_page.dart';

class VoiceEffectPreparePage extends StatefulWidget {
  const VoiceEffectPreparePage({Key? key}) : super(key: key);

  @override
  State<VoiceEffectPreparePage> createState() => _VoiceEffectPreparePageState();
}

class _VoiceEffectPreparePageState extends State<VoiceEffectPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF283593);

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceEffectPage(
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
      icon: Icons.settings_voice_rounded,
      accentColor: _accentColor,
      title: l10n.sceneVoiceEffect,
      subtitle: l10n.descVoiceEffect,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnter,
    );
  }
}
