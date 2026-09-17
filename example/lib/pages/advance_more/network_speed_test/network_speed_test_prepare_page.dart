import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'network_speed_test_page.dart';

class NetworkSpeedTestPreparePage extends StatefulWidget {
  const NetworkSpeedTestPreparePage({Key? key}) : super(key: key);

  @override
  State<NetworkSpeedTestPreparePage> createState() => _NetworkSpeedTestPreparePageState();
}

class _NetworkSpeedTestPreparePageState extends State<NetworkSpeedTestPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF0277BD);

  void _onStartTest() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NetworkSpeedTestPage(
            roomIdSpec: _formKey.currentState!.roomIdSpec,
            userId: _formKey.currentState!.userId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SceneEntryScaffold(
      icon: Icons.network_check_rounded,
      accentColor: _accentColor,
      title: l10n.sceneNetworkSpeedTest,
      subtitle: l10n.descNetworkSpeedTest,
      form: UserRoomIdForm(key: _formKey),
      actionLabel: l10n.startSpeedTest,
      onAction: _onStartTest,
    );
  }
}
