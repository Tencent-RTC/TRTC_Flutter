import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'audio_quality_page.dart';

class AudioQualityPreparePage extends StatefulWidget {
  const AudioQualityPreparePage({Key? key}) : super(key: key);

  @override
  State<AudioQualityPreparePage> createState() =>
      _AudioQualityPreparePageState();
}

class _AudioQualityPreparePageState extends State<AudioQualityPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF00897B);

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AudioQualityPage(
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
      icon: Icons.graphic_eq_rounded,
      accentColor: _accentColor,
      title: l10n.audioQualityTitle,
      subtitle: l10n.descAudioQuality,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnter,
    );
  }
}
