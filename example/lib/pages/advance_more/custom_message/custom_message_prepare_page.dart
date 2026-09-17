import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'custom_message.dart';

class CustomMessagePreparePage extends StatefulWidget {
  const CustomMessagePreparePage({Key? key}) : super(key: key);

  @override
  State<CustomMessagePreparePage> createState() => _CustomMessagePreparePageState();
}

class _CustomMessagePreparePageState extends State<CustomMessagePreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF5E35B1);

  void _onEnterRoom() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomMessagePage(
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
      icon: Icons.sms_rounded,
      accentColor: _accentColor,
      title: l10n.sceneCustomMessage,
      subtitle: l10n.descCustomMessage,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnterRoom,
    );
  }
}
