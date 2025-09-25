import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'video_quality_state.dart';
import '../../../../common/user_list_widget.dart';
import '../../../../common/user_list_state.dart';

class VideoQualityPage extends StatefulWidget {
  const VideoQualityPage({Key? key}) : super(key: key);

  @override
  State<VideoQualityPage> createState() => _VideoQualityPageState();
}

class _VideoQualityPageState extends State<VideoQualityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoQualityState _videoQualityState;
  UserListState? _userListState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _videoQualityState = VideoQualityState();
  }

  Future<void> _initialize() async {
    TRTCCloud trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(trtcCloud);
    _videoQualityState.initialize(trtcCloud, _userListState!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoQualityState.dispose();
    _userListState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _videoQualityState),
            ChangeNotifierProvider.value(value: _userListState!),
          ],
          child: Builder(
            builder: (context) => _buildPageContent(context),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(BuildContext context) {
    final state = Provider.of<VideoQualityState>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Video Quality Settings'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: state.isEnterRoom,
            builder: (context, isEnterRoom, _) {
              return Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isEnterRoom ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(
            child: UserListWidget(isVideoMode: true),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Room Settings'),
                    Tab(text: 'Encoder Settings'),
                    Tab(text: 'Network Settings'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      getRoomSettings(state),
                      getVideoEncSettings(state),
                      getNetworkQosSettings(state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getRoomSettings(VideoQualityState state) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Room ID',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                state.roomId = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) {
                state.localUserId = value;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<bool>(
                valueListenable: state.isEnterRoom,
                builder: (context, isEnterRoom, _) {
                  return ElevatedButton(
                    onPressed: () {
                      if (isEnterRoom) {
                        state.exitRoom();
                      } else {
                        if (state.localUserId != null && state.roomId != null) {
                          state.enterRoom(state.localUserId!, state.roomId!);
                        }
                      }
                    },
                    child: Text(isEnterRoom ? 'Exit Room' : 'Enter'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getVideoEncSettings(VideoQualityState state) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            ValueListenableBuilder(
                valueListenable: state.minVideoBitrate,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Text('Min Video Bitrate: ${state.minVideoBitrate.value}'),
                      Slider(
                        value: state.minVideoBitrate.value.toDouble(),
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        onChanged: (value) {
                          state.minVideoBitrate.value = value.toInt();
                          print('Min video bitrate updated to: ${state.minVideoBitrate.value}');
                        },
                      ),
                    ],
                  );
                }),
            const SizedBox(height: 16),
            ValueListenableBuilder(
                valueListenable: state.videoBitrate,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Text('Video Bitrate: ${state.videoBitrate.value}'),
                      Slider(
                        value: state.videoBitrate.value.toDouble(),
                        min: 0,
                        max: 2000,
                        divisions: 100,
                        onChanged: (value) {
                          state.videoBitrate.value = value.toInt();
                          print('Video bitrate updated to: ${state.videoBitrate.value}');
                        },
                      ),
                    ],
                  );
                }),
            const SizedBox(height: 16),
            ValueListenableBuilder(
                valueListenable: state.videoFps,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Text('Video FPS: ${state.videoFps.value}'),
                      Slider(
                        value: state.videoFps.value.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        onChanged: (value) {
                          state.videoFps.value = value.toInt();
                          print('Video FPS updated to: ${state.videoFps.value}');
                        },
                      ),
                    ],
                  );
                }),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Enable Resolution Adjustment'),
                const Spacer(),
                ValueListenableBuilder(
                    valueListenable: state.enableAdjustRes,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          Switch(
                            value: state.enableAdjustRes.value,
                            onChanged: (value) {
                              state.enableAdjustRes.value = value;
                            },
                          ),
                        ],
                      );
                    }),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: state.videoResolution,
              builder: (context, value, child) {
                return DropdownButton<TRTCVideoResolution>(
                  value: state.videoResolution.value,
                  items: TRTCVideoResolution.values.map((resolution) {
                    String description;
                    switch (resolution) {
                      case TRTCVideoResolution.res_120_120:
                        description = "120x120";
                        break;
                      case TRTCVideoResolution.res_160_160:
                        description = "160x160";
                        break;
                      case TRTCVideoResolution.res_270_270:
                        description = "270x270";
                        break;
                      case TRTCVideoResolution.res_480_480:
                        description = "480x480";
                        break;
                      case TRTCVideoResolution.res_160_120:
                        description = "160x120 (4:3)";
                        break;
                      case TRTCVideoResolution.res_240_180:
                        description = "240x180 (4:3)";
                        break;
                      case TRTCVideoResolution.res_280_210:
                        description = "280x210 (4:3)";
                        break;
                      case TRTCVideoResolution.res_320_240:
                        description = "320x240 (4:3)";
                        break;
                      case TRTCVideoResolution.res_400_300:
                        description = "400x300 (4:3)";
                        break;
                      case TRTCVideoResolution.res_480_360:
                        description = "480x360 (4:3)";
                        break;
                      case TRTCVideoResolution.res_640_480:
                        description = "640x480 (4:3)";
                        break;
                      case TRTCVideoResolution.res_960_720:
                        description = "960x720 (4:3)";
                        break;
                      case TRTCVideoResolution.res_160_90:
                        description = "160x90 (16:9)";
                        break;
                      case TRTCVideoResolution.res_256_144:
                        description = "256x144 (16:9)";
                        break;
                      case TRTCVideoResolution.res_320_180:
                        description = "320x180 (16:9)";
                        break;
                      case TRTCVideoResolution.res_480_270:
                        description = "480x270 (16:9)";
                        break;
                      case TRTCVideoResolution.res_640_360:
                        description = "640x360 (16:9)";
                        break;
                      case TRTCVideoResolution.res_960_540:
                        description = "960x540 (16:9)";
                        break;
                      case TRTCVideoResolution.res_1280_720:
                        description = "1280x720 (16:9)";
                        break;
                      case TRTCVideoResolution.res_1920_1080:
                        description = "1920x1080 (16:9)";
                        break;
                      default:
                        description = "1280x720 (16:9)";
                    }
                    return DropdownMenuItem(
                      value: resolution,
                      child: Text(description),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      state.videoResolution.value = value;
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: state.videoResolutionMode,
              builder: (context, value, child) {
                return DropdownButton<TRTCVideoResolutionMode>(
                  value: state.videoResolutionMode.value,
                  items: TRTCVideoResolutionMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode == TRTCVideoResolutionMode.portrait ? 'Portrait' : 'Landscape'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      state.videoResolutionMode.value = value;
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getNetworkQosSettings(VideoQualityState state) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            const Text('Network QoS Preference'),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: state.preference,
              builder: (context, value, child) {
                return DropdownButton<TRTCVideoQosPreference>(
                  value: state.preference.value,
                  items: TRTCVideoQosPreference.values.map((preference) {
                    String description;
                    switch (preference) {
                      case TRTCVideoQosPreference.smooth:
                        description = "Smooth First";
                        break;
                      case TRTCVideoQosPreference.clear:
                        description = "Clear First";
                        break;
                      default:
                        description = "Clear First";
                    }
                    return DropdownMenuItem(
                      value: preference,
                      child: Text(description),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      state.preference.value = value;
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}