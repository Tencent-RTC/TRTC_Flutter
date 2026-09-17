import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'connect_other_room_page.dart';

class ConnectOtherRoomPreparePage extends StatefulWidget {
  const ConnectOtherRoomPreparePage({Key? key}) : super(key: key);

  @override
  State<ConnectOtherRoomPreparePage> createState() => _ConnectOtherRoomPreparePageState();
}

class _ConnectOtherRoomPreparePageState extends State<ConnectOtherRoomPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF00897B);

  void _onEnterRoom() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectOtherRoomPage(
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
      icon: Icons.accessibility_new_rounded,
      accentColor: _accentColor,
      title: l10n.scenePk,
      subtitle: l10n.descPk,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnterRoom,
    );
  }
}
