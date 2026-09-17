import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'switch_room_page.dart';

class SwitchRoomPreparePage extends StatefulWidget {
  const SwitchRoomPreparePage({Key? key}) : super(key: key);

  @override
  State<SwitchRoomPreparePage> createState() => _SwitchRoomPreparePageState();
}

class _SwitchRoomPreparePageState extends State<SwitchRoomPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF3F51B5);

  void _onEnterRoom() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SwitchRoomPage(
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
      icon: Icons.account_balance_rounded,
      accentColor: _accentColor,
      title: l10n.sceneSwitchRoom,
      subtitle: l10n.descSwitchRoom,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnterRoom,
    );
  }
}
