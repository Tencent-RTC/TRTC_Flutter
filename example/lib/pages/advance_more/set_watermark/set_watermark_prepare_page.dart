import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'set_watermark_page.dart';

class SetWatermarkPreparePage extends StatefulWidget {
  const SetWatermarkPreparePage({Key? key}) : super(key: key);

  @override
  State<SetWatermarkPreparePage> createState() => _SetWatermarkPreparePageState();
}

class _SetWatermarkPreparePageState extends State<SetWatermarkPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF6D4C41);

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetWatermarkPage(
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
      icon: Icons.branding_watermark_rounded,
      accentColor: _accentColor,
      title: l10n.sceneWatermark,
      subtitle: l10n.descWatermark,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnter,
    );
  }
}
