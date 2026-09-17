import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/common/room_input_prefs.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// A reusable form widget for entering a User ID and a Room ID before
/// entering a TRTC demo scene.
///
/// TRTC identifies a room by `strRoomId` (a string room id). A single room
/// number input is provided; the numeric `roomId` alternative is intentionally
/// omitted to keep the entry UI minimal. Automatically loads the last-entered
/// values on init and exposes the current values via [userId] / [roomIdSpec] /
/// [strRoomId]. The caller is responsible for calling [save] to persist values.
class UserRoomIdForm extends StatefulWidget {
  final String? initialUserId;
  final String? initialStrRoomId;

  const UserRoomIdForm({
    Key? key,
    this.initialUserId,
    this.initialStrRoomId,
  }) : super(key: key);

  @override
  State<UserRoomIdForm> createState() => UserRoomIdFormState();
}

class UserRoomIdFormState extends State<UserRoomIdForm> {
  late final TextEditingController _userIdController;
  late final TextEditingController _strRoomIdController;
  final _formKey = GlobalKey<FormState>();
  bool _showRoomIdRequiredError = false;

  @override
  void initState() {
    super.initState();
    final initialUserId = widget.initialUserId;
    final initialStrRoomId = widget.initialStrRoomId;
    _userIdController = TextEditingController(
      text: initialUserId != null && initialUserId.isNotEmpty
          ? initialUserId
          : RoomInputPrefs.lastUserId,
    );
    _strRoomIdController = TextEditingController(
      text: initialStrRoomId != null && initialStrRoomId.isNotEmpty
          ? initialStrRoomId
          : RoomInputPrefs.lastStrRoomId,
    );
  }

  String get userId => _userIdController.text.trim();
  String get strRoomId => _strRoomIdController.text.trim();
  RoomIdSpec get roomIdSpec => RoomIdSpec(strRoomId: strRoomId);

  bool validate() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final roomIdValid = strRoomId.isNotEmpty;
    if (mounted) {
      setState(() => _showRoomIdRequiredError = !roomIdValid);
    } else {
      _showRoomIdRequiredError = !roomIdValid;
    }
    return formValid && roomIdValid;
  }

  Future<void> save() async {
    await RoomInputPrefs.saveUserId(userId);
    await RoomInputPrefs.saveStrRoomId(strRoomId);
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _strRoomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    InputDecoration decoration({
      required String label,
      required String hint,
      required IconData icon,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        // ignore: deprecated_member_use
        fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        prefixIcon:
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _userIdController,
            decoration: decoration(
              label: l10n.userIdLabel,
              hint: l10n.userIdHint,
              icon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.enterUserId;
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _strRoomIdController,
            decoration: decoration(
              label: l10n.roomNumberLabel,
              hint: l10n.roomNumberHint,
              icon: Icons.meeting_room_outlined,
            ),
            onChanged: (_) {
              if (_showRoomIdRequiredError) {
                setState(() => _showRoomIdRequiredError = false);
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.roomNumberRequired;
              }
              return null;
            },
          ),
          if (_showRoomIdRequiredError) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                l10n.roomNumberRequired,
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
