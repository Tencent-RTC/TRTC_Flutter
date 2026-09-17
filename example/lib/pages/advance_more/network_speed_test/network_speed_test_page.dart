import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'network_speed_test_state.dart';

class NetworkSpeedTestPage extends StatefulWidget {
  final RoomIdSpec roomIdSpec;
  final String userId;

  const NetworkSpeedTestPage({
    Key? key,
    required this.roomIdSpec,
    required this.userId,
  }) : super(key: key);

  @override
  State<NetworkSpeedTestPage> createState() => _NetworkSpeedTestPageState();
}

class _NetworkSpeedTestPageState extends State<NetworkSpeedTestPage> {
  late NetworkSpeedTestState _state;
  final TextEditingController _upBwController = TextEditingController(text: '1000');
  final TextEditingController _downBwController = TextEditingController(text: '1000');
  static const _accentColor = Color(0xFF0277BD);

  @override
  void initState() {
    super.initState();
    _state = NetworkSpeedTestState(userId: widget.userId);
    _state.addListener(_onChanged);
    _state.isTesting.addListener(_onChanged);
    _state.initialize();
  }

  void _onChanged() => mounted ? setState(() {}) : null;

  @override
  void dispose() {
    _state.isTesting.removeListener(_onChanged);
    _state.removeListener(_onChanged);
    _upBwController.dispose();
    _downBwController.dispose();
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
        appBar: AppBar(title: Text(l10n.networkSpeedTestTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _buildConfigCard(l10n),
            const SizedBox(height: 10),
            _buildControlButtons(l10n),
            const SizedBox(height: 10),
            _buildResultCard(l10n),
          ]),
        ),
      ),
    );
  }

  // ─── Config card ─────────────────────────────────────────────

  Widget _buildConfigCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.tune, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.speedTestConfig,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        // Scene selector
        Text(l10n.speedTestScene, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          _sceneChip(l10n.speedTestSceneDelay, TRTCSpeedTestScene.delayTesting, l10n),
          _sceneChip(l10n.speedTestSceneDelayBandwidth, TRTCSpeedTestScene.delayAndBandwidthTesting, l10n),
          _sceneChip(l10n.speedTestSceneChorus, TRTCSpeedTestScene.onlineChorusTesting, l10n),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _upBwController,
              decoration: InputDecoration(
                labelText: l10n.speedTestUpBandwidth,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _state.setUpBandwidth(int.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _downBwController,
              decoration: InputDecoration(
                labelText: l10n.speedTestDownBandwidth,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _state.setDownBandwidth(int.tryParse(v) ?? 0),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _sceneChip(String label, TRTCSpeedTestScene value, AppLocalizations l10n) {
    final selected = _state.scene == value;
    return GestureDetector(
      onTap: () => _state.setScene(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _accentColor : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _accentColor : Colors.transparent),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey.shade700,
            )),
      ),
    );
  }

  // ─── Control buttons ─────────────────────────────────────────

  Widget _buildControlButtons(AppLocalizations l10n) {
    final testing = _state.isTesting.value;
    return Row(children: [
      Expanded(
        child: SizedBox(
          height: 46,
          child: FilledButton.icon(
            onPressed: testing ? null : _doStart,
            icon: Icon(testing ? Icons.hourglass_top : Icons.play_arrow, size: 20),
            label: Text(l10n.startSpeedTest),
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: testing ? _doStop : null,
            icon: const Icon(Icons.stop, size: 20),
            label: Text(l10n.stopSpeedTest),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ),
    ]);
  }

  void _doStart() {
    final success = _state.startSpeedTest();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.speedTestStarted : l10n.speedTestFailed),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _doStop() {
    _state.stopSpeedTest();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.speedTestStopped),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Result card ─────────────────────────────────────────────

  Widget _buildResultCard(AppLocalizations l10n) {
    final results = _state.results;
    final hasResult = results.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDec(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.speed, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Text(l10n.speedTestResultsRealtime,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (hasResult)
            TextButton.icon(
              onPressed: _state.clearResults,
              icon: const Icon(Icons.clear_all, size: 16),
              label: Text(l10n.speedTestClear, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.zero),
            ),
        ]),
        const SizedBox(height: 8),
        if (!hasResult)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(l10n.speedTestNoResult,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            reverse: true,
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final result = results[results.length - 1 - index];
              return _buildResultItem(result, l10n);
            },
          ),
      ]),
    );
  }

  Widget _buildResultItem(TRTCSpeedTestResult result, AppLocalizations l10n) {
    final success = result.success;
    final quality = result.quality;
    final qualityColor = _qualityColor(quality);
    final qualityText = _qualityText(quality, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: success status + quality badge
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: qualityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(qualityText,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: qualityColor)),
          ),
          const SizedBox(width: 8),
          if (!success)
            Text(result.errMsg, style: TextStyle(fontSize: 11, color: Colors.red))
          else
            Text('${l10n.speedTestServerIp}: ${result.ip}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ]),
        if (success) ...[
          const SizedBox(height: 8),
          // Metrics grid
          Wrap(spacing: 12, runSpacing: 6, children: [
            _metric(l10n.speedTestRtt, '${result.rtt} ms', Icons.timer_outlined),
            _metric(l10n.speedTestUpLost, '${(result.upLostRate * 100).toStringAsFixed(1)}%',
                Icons.arrow_upward),
            _metric(l10n.speedTestDownLost, '${(result.downLostRate * 100).toStringAsFixed(1)}%',
                Icons.arrow_downward),
            _metric(l10n.speedTestUpJitter, '${result.upJitter} ms', Icons.show_chart),
            _metric(l10n.speedTestDownJitter, '${result.downJitter} ms', Icons.show_chart),
            _metric(l10n.speedTestUpBw, '${result.availableUpBandwidth} kbps', Icons.upload),
            _metric(l10n.speedTestDownBw, '${result.availableDownBandwidth} kbps', Icons.download),
          ]),
        ],
      ]),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.grey.shade400),
      const SizedBox(width: 4),
      Text('$label: ', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }

  Color _qualityColor(TRTCQuality quality) {
    switch (quality) {
      case TRTCQuality.excellent:
        return Colors.green;
      case TRTCQuality.good:
        return Colors.lightBlue;
      case TRTCQuality.poor:
        return Colors.orange;
      case TRTCQuality.bad:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _qualityText(TRTCQuality quality, AppLocalizations l10n) {
    switch (quality) {
      case TRTCQuality.excellent:
        return l10n.speedTestQualityExcellent;
      case TRTCQuality.good:
        return l10n.speedTestQualityGood;
      case TRTCQuality.poor:
        return l10n.speedTestQualityPoor;
      case TRTCQuality.bad:
        return l10n.speedTestQualityBad;
      default:
        return l10n.speedTestQualityUnknown;
    }
  }
}
