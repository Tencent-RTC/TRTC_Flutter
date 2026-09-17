import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'set_beauty_style_state.dart';

class SetBeautyStylePage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const SetBeautyStylePage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<SetBeautyStylePage> createState() => _SetBeautyStylePageState();
}

class _SetBeautyStylePageState extends State<SetBeautyStylePage> {
  late SetBeautyStyleState _state;
  static const _accentColor = Color(0xFFE91E63);

  @override
  void initState() {
    super.initState();
    _state = SetBeautyStyleState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
    _state.addListener(_onChanged);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
    _state.removeListener(_onChanged);
    _state.dispose();
    super.dispose();
  }

  BoxDecoration _cardDec() => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.setBeautyStyleTitle),
          actions: [
            Container(
              width: 10, height: 10, margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _state.isEnterRoom ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        body: Column(children: [
          _buildPreview(l10n),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildStyleCard(l10n),
              const SizedBox(height: 10),
              _buildSliderCard(l10n),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity, height: 48,
              child: FilledButton(
                onPressed: () { _state.exitRoom(); Navigator.pop(context); },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.exitRoomButton),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Local preview (large, for beauty effect visibility) ─────

  Widget _buildPreview(AppLocalizations l10n) => Container(
        margin: const EdgeInsets.all(12),
        height: 240,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            TRTCCloudVideoView(onViewCreated: (v) => _state.setLocalViewId(v)),
            Positioned(
              top: 8, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                child: Text(l10n.localPreview,
                    style: TextStyle(color: _accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      );

  // ─── Beauty style selector ───────────────────────────────────

  Widget _buildStyleCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.face_retouching_natural, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.beautyStyleLabel.trim(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _styleChip(l10n, TRTCBeautyStyle.smooth, Icons.blur_on),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _styleChip(l10n, TRTCBeautyStyle.nature, Icons.spa_outlined),
          ),
        ]),
      ]),
    );
  }

  Widget _styleChip(AppLocalizations l10n, TRTCBeautyStyle value, IconData icon) {
    final selected = _state.style == value;
    final label = value == TRTCBeautyStyle.smooth
        ? l10n.beautyStyleSmooth
        : l10n.beautyStyleNature;
    return GestureDetector(
      onTap: () => _state.setStyle(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accentColor.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _accentColor : Colors.transparent, width: 1.5),
        ),
        child: Column(children: [
          Icon(icon, size: 28, color: selected ? _accentColor : Colors.grey),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: selected ? _accentColor : Colors.grey.shade700,
          )),
        ]),
      ),
    );
  }

  // ─── Slider card ─────────────────────────────────────────────

  Widget _buildSliderCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(children: [
        _sliderItem(
          l10n.beautyLevelLabel(_state.beautyLevel),
          _state.beautyLevel,
          Icons.face,
          (v) => _state.setBeautyLevel(v.round()),
        ),
        const Divider(height: 24),
        _sliderItem(
          l10n.whitenessLevelLabel(_state.whitenessLevel),
          _state.whitenessLevel,
          Icons.brightness_5_outlined,
          (v) => _state.setWhitenessLevel(v.round()),
        ),
        const Divider(height: 24),
        _sliderItem(
          l10n.ruddinessLevelLabel(_state.ruddinessLevel),
          _state.ruddinessLevel,
          Icons.favorite_outline,
          (v) => _state.setRuddinessLevel(v.round()),
        ),
      ]),
    );
  }

  Widget _sliderItem(String label, int value, IconData icon, ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: _accentColor),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Container(
          width: 28, height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$value', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: _accentColor)),
        ),
      ]),
      Slider(
        value: value.toDouble(),
        min: 0, max: 9, divisions: 9,
        activeColor: _accentColor,
        label: value.toString(),
        onChanged: onChanged,
      ),
    ]);
  }
}
