import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'live_room_page.dart';

class LiveRoomPreparePage extends StatefulWidget {
  const LiveRoomPreparePage({Key? key}) : super(key: key);

  @override
  State<LiveRoomPreparePage> createState() => _LiveRoomPreparePageState();
}

class _LiveRoomPreparePageState extends State<LiveRoomPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFFC62828);

  void _startLive() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveRoomPage(
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
      icon: Icons.live_tv_rounded,
      accentColor: _accentColor,
      title: l10n.liveRoomSetup,
      subtitle: l10n.descLiveRoom,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.joinRoom,
      onAction: _startLive,
    );
  }
}
