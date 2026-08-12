import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'music_effect_state.dart';
import 'package:api_example/common/user_list_widget.dart';
import 'package:provider/provider.dart';

class MusicEffectPage extends StatefulWidget {
  final String userId;
  final String roomId;
  const MusicEffectPage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<MusicEffectPage> createState() => _MusicEffectPageState();
}

class _MusicEffectPageState extends State<MusicEffectPage> {
  late MusicEffectState _state;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _state = MusicEffectState(widget.userId, int.tryParse(widget.roomId) ?? 0);
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
      child: Consumer<MusicEffectState>(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Music Effect Test'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  state.exitRoom();
                  Navigator.pop(context);
                },
              ),
            ),
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
                              _sectionTitle('Music File'),
                              TextField(
                                controller: state.musicPathController,
                                decoration: const InputDecoration(hintText: 'e.g. assets/music/daoxiang.mp3'),
                              ),
                              const SizedBox(height: 20),
                              _sectionDivider(),
                              _sectionTitle('Start Music'),
                              TextField(
                                controller: state.musicIdController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Music ID'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: state.loopCountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Loop Count'),
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                title: const Text('Publish'),
                                value: state.publish,
                                onChanged: (v) => state.setPublish(v),
                              ),
                              SwitchListTile(
                                title: const Text('Short File'),
                                value: state.isShortFile,
                                onChanged: (v) => state.setShortFile(v),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.startPlayMusic : null,
                                  child: const Text('Start Music'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Pause/Resume/Stop'),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.pauseMusic : null,
                                  child: const Text('Pause'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.resumeMusic : null,
                                  child: const Text('Resume'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.stopMusic : null,
                                  child: const Text('Stop'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Music Volume & Pitch'),
                              const SizedBox(height: 8),
                              const Text('All Volume'),
                              Slider(
                                value: state.allMusicVolume.toDouble(),
                                min: 0,
                                max: 150,
                                divisions: 150,
                                label: state.allMusicVolume.toString(),
                                onChanged: (v) => state.setAllMusicVolume(v.toInt()),
                              ),
                              const SizedBox(height: 8),
                              const Text('Music Pitch'),
                              Slider(
                                value: state.musicPitch,
                                min: -1,
                                max: 1,
                                divisions: 20,
                                label: state.musicPitch.toStringAsFixed(2),
                                onChanged: (v) => state.setMusicPitch(v),
                              ),
                              const SizedBox(height: 8),
                              const Text('Speed Rate'),
                              Slider(
                                value: state.musicSpeedRate,
                                min: 0.5,
                                max: 2.0,
                                divisions: 15,
                                label: state.musicSpeedRate.toStringAsFixed(2),
                                onChanged: (v) => state.setMusicSpeedRate(v),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Music Progress'),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.getMusicCurrentPos : null,
                                  child: const Text('Get Current Pos'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.getMusicDuration : null,
                                  child: const Text('Get Duration'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: state.seekPosController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Seek to (ms)'),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.seekMusicToPos : null,
                                  child: const Text('Seek'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Track & Preload'),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.getMusicTrackCount : null,
                                  child: const Text('Get Track Count'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: state.trackIndexController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Track Index'),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.setMusicTrack : null,
                                  child: const Text('Set Track'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.preloadMusic : null,
                                  child: const Text('Preload Music'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.setPreloadObserver : null,
                                  child: const Text('Set Preload Observer'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.setMusicObserver : null,
                                  child: const Text('Set Music Observer'),
                                ),
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