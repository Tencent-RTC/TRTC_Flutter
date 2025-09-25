import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'voice_effect_state.dart';
import 'package:api_example/common/user_list_widget.dart';

class VoiceEffectPage extends StatefulWidget {
  final String userId;
  final String roomId;
  const VoiceEffectPage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<VoiceEffectPage> createState() => _VoiceEffectPageState();
}

class _VoiceEffectPageState extends State<VoiceEffectPage> {
  late VoiceEffectState _state;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _state = VoiceEffectState();
    _initRoom();
  }

  Future<void> _initRoom() async {
    await _state.enterRoom(widget.userId, int.tryParse(widget.roomId) ?? 0);
    setState(() {
      _isInit = true;
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );

  Widget _sectionDivider() => const Divider(height: 32, thickness: 1.2);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: Consumer<VoiceEffectState>(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Voice Effect Test')),
            body: _isInit
                ? Column(
                    children: [
                      Expanded(
                        flex: 0,
                        child: state.userListState == null
                            ? const Center(child: CircularProgressIndicator())
                            : ChangeNotifierProvider.value(
                                value: state.userListState!,
                                child: const SizedBox(
                                  height: 220,
                                  child: UserListWidget(isVideoMode: true),
                                ),
                              ),
                      ),
                      const Divider(height: 24),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Ear Monitor'),
                              SwitchListTile(
                                title: const Text('Enable'),
                                value: state.earMonitorEnabled,
                                onChanged: state.setEarMonitorEnabled,
                              ),
                              const SizedBox(height: 12),
                              const Text('Volume'),
                              Slider(
                                value: state.earMonitorVolume.toDouble(),
                                min: 0,
                                max: 150,
                                divisions: 150,
                                label: state.earMonitorVolume.toString(),
                                onChanged: (v) => state.setEarMonitorVolume(v.toInt()),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Voice Reverb'),
                              DropdownButton<int>(
                                value: state.reverbType,
                                isExpanded: true,
                                items: state.reverbTypes.map((e) => DropdownMenuItem(value: e, child: Text('Type $e'))).toList(),
                                onChanged: (v) => state.setReverbType(v!),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Voice Changer'),
                              DropdownButton<int>(
                                value: state.changerType,
                                isExpanded: true,
                                items: state.changerTypes.map((e) => DropdownMenuItem(value: e, child: Text('Type $e'))).toList(),
                                onChanged: (v) => state.setChangerType(v!),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Voice Capture Volume'),
                              Slider(
                                value: state.captureVolume.toDouble(),
                                min: 0,
                                max: 150,
                                divisions: 150,
                                label: state.captureVolume.toString(),
                                onChanged: (v) => state.setCaptureVolume(v.toInt()),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Voice Pitch'),
                              Slider(
                                value: state.voicePitch,
                                min: -1,
                                max: 1,
                                divisions: 20,
                                label: state.voicePitch.toStringAsFixed(2),
                                onChanged: (v) => state.setVoicePitch(v),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Callback / Log'),
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  itemCount: state.logs.length,
                                  itemBuilder: (context, idx) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text(state.logs[idx], style: const TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
} 