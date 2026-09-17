import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'publish_media_stream_anchor_page.dart';
import 'publish_media_stream_audience_page.dart';

class PublishMediaStreamPreparePage extends StatefulWidget {
  const PublishMediaStreamPreparePage({Key? key}) : super(key: key);

  @override
  State<PublishMediaStreamPreparePage> createState() =>
      _PublishMediaStreamPreparePageState();
}

class _PublishMediaStreamPreparePageState
    extends State<PublishMediaStreamPreparePage> {
  static const _accentColor = Color(0xFF6A1B9A);
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  /// Selected role. Defaults to anchor (the primary demo flow).
  String _selectedRole = 'anchor';

  void _onEnterRoom() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    final userId = _formKey.currentState!.userId;
    final roomIdSpec = _formKey.currentState!.roomIdSpec;
    if (_selectedRole == 'anchor') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublishMediaStreamAnchorPage(
            userId: userId,
            roomIdSpec: roomIdSpec,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublishMediaStreamAudiencePage(
            userId: userId,
            roomIdSpec: roomIdSpec,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SceneEntryScaffold(
      icon: Icons.stream,
      accentColor: _accentColor,
      title: l10n.publishMediaStreamTitle,
      subtitle: l10n.publishGuide1,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserRoomIdForm(key: _formKey),
          const SizedBox(height: 18),
          _buildRoleSelector(l10n),
        ],
      ),
      actionLabel: l10n.enterRoom,
      onAction: _onEnterRoom,
    );
  }

  Widget _buildRoleSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.publishGuide2,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                l10n,
                icon: Icons.cast,
                label: l10n.anchor,
                selected: _selectedRole == 'anchor',
                onTap: () => setState(() => _selectedRole = 'anchor'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                l10n,
                icon: Icons.visibility,
                label: l10n.audience,
                selected: _selectedRole == 'audience',
                onTap: () => setState(() => _selectedRole = 'audience'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    AppLocalizations l10n, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? _accentColor.withOpacity(0.12)
              : _accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _accentColor : _accentColor.withOpacity(0.3),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: _accentColor),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _accentColor)),
          ],
        ),
      ),
    );
  }
}
