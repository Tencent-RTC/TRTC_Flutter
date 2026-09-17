import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'music_effect_page.dart';

class MusicEffectPreparePage extends StatefulWidget {
  const MusicEffectPreparePage({Key? key}) : super(key: key);

  @override
  State<MusicEffectPreparePage> createState() => _MusicEffectPreparePageState();
}

class _MusicEffectPreparePageState extends State<MusicEffectPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFFAD1457);

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MusicEffectPage(
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
      icon: Icons.music_note_rounded,
      accentColor: _accentColor,
      title: l10n.sceneMusicEffect,
      subtitle: l10n.descMusicEffect,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnter,
    );
  }
}
