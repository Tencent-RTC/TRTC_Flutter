import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'audio_call_page.dart';

class AudioCallPreparePage extends StatefulWidget {
  const AudioCallPreparePage({Key? key}) : super(key: key);

  @override
  State<AudioCallPreparePage> createState() => _AudioCallPreparePageState();
}

class _AudioCallPreparePageState extends State<AudioCallPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFFE65100);

  void _startCall() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioCallPage(
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
      icon: Icons.call_rounded,
      accentColor: _accentColor,
      title: l10n.audioCallSetup,
      subtitle: l10n.descAudioCall,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.startCall,
      onAction: _startCall,
    );
  }
}
