import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'set_watermark_state.dart';

class SetWatermarkPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const SetWatermarkPage({Key? key, required this.userId, required this.roomIdSpec})
      : super(key: key);

  @override
  State<SetWatermarkPage> createState() => _SetWatermarkPageState();
}

class _SetWatermarkPageState extends State<SetWatermarkPage> {
  late SetWatermarkState _state;
  static const _accentColor = Color(0xFF6D4C41);

  @override
  void initState() {
    super.initState();
    _state = SetWatermarkState(userId: widget.userId, roomIdSpec: widget.roomIdSpec);
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
          title: Text(l10n.setWatermarkTitle),
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
              _buildStreamTypeCard(l10n),
              const SizedBox(height: 10),
              _buildPositionCard(l10n),
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

  // ─── Local preview ───────────────────────────────────────────

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
              child: _label(l10n.localPreview, _accentColor),
            ),
          ]),
        ),
      );

  Widget _label(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  // ─── Stream type card ────────────────────────────────────────

  Widget _buildStreamTypeCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.stream, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.streamTypeLabel.trim(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _streamChip(TRTCVideoStreamType.big, l10n.streamTypeBig, Icons.hd_outlined),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _streamChip(TRTCVideoStreamType.sub, l10n.streamTypeSub, Icons.screen_share_outlined),
          ),
        ]),
      ]),
    );
  }

  Widget _streamChip(TRTCVideoStreamType value, String label, IconData icon) {
    final selected = _state.streamType == value;
    return GestureDetector(
      onTap: () => _state.setStreamType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accentColor.withOpacity(0.12) : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _accentColor : Colors.transparent, width: 1.5),
        ),
        child: Column(children: [
          Icon(icon, size: 24, color: selected ? _accentColor : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? _accentColor : Colors.grey.shade700,
          )),
        ]),
      ),
    );
  }

  // ─── Position & size card ────────────────────────────────────

  Widget _buildPositionCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(children: [
        _sliderItem(
          l10n.xAxisLabel, _state.x, Icons.arrow_right_alt,
          (v) => _state.setX(v),
        ),
        const Divider(height: 24),
        _sliderItem(
          l10n.yAxisLabel, _state.y, Icons.arrow_downward,
          (v) => _state.setY(v),
        ),
        const Divider(height: 24),
        _sliderItem(
          l10n.widthLabel, _state.watermarkWidth, Icons.swap_horiz,
          (v) => _state.setWidth(v),
          min: 0.01,
        ),
      ]),
    );
  }

  Widget _sliderItem(String label, double value, IconData icon, ValueChanged<double> onChanged,
      {double min = 0}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: _accentColor),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Container(
          width: 48, height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value.toStringAsFixed(2), style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: _accentColor)),
        ),
      ]),
      Slider(
        value: value,
        min: min, max: 1, divisions: 100,
        activeColor: _accentColor,
        label: value.toStringAsFixed(2),
        onChanged: onChanged,
      ),
    ]);
  }
}
