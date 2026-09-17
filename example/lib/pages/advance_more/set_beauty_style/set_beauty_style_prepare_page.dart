import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'set_beauty_style_page.dart';

class SetBeautyStylePreparePage extends StatefulWidget {
  const SetBeautyStylePreparePage({Key? key}) : super(key: key);

  @override
  State<SetBeautyStylePreparePage> createState() =>
      _SetBeautyStylePreparePageState();
}

class _SetBeautyStylePreparePageState extends State<SetBeautyStylePreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFFAD1457);

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SetBeautyStylePage(
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
      icon: Icons.face_retouching_natural,
      accentColor: _accentColor,
      title: l10n.setBeautyStyleTitle,
      subtitle: l10n.descBeautyStyle,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.enterRoom,
      onAction: _onEnter,
    );
  }
}
