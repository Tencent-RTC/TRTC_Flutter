import 'package:api_example/pages/advance_media/small_video_stream/small_video_stream_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import '../../../../common/user_list_widget.dart';
import '../../../../common/user_list_state.dart';

class SmallVideoStreamPage extends StatefulWidget {
  const SmallVideoStreamPage({Key? key}) : super(key: key);

  @override
  State<SmallVideoStreamPage> createState() => _SmallVideoStreamPageState();
}

class _SmallVideoStreamPageState extends State<SmallVideoStreamPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SmallVideoStreamState _smallVideoState;
  UserListState? _userListState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _smallVideoState = SmallVideoStreamState();
  }

  Future<void> _initialize() async {
    TRTCCloud trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(trtcCloud);
    _smallVideoState.initialize(trtcCloud, _userListState!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _smallVideoState.dispose();
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
            ChangeNotifierProvider.value(value: _smallVideoState),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Small Stream Settings'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _smallVideoState.isEnterRoom,
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
                    Tab(text: 'Small Stream Settings'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoomSettings(),
                      _buildSmallStreamSettings(),
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

  Widget _buildRoomSettings() {
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
                _smallVideoState.roomId = int.tryParse(value) ?? 0;
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
                _smallVideoState.localUserId = value;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _smallVideoState.displaySmall,
              builder: (context, displaySmall, _) {
                return Row(
                  children: [
                    const Text('Display Remote Small Stream'),
                    const Spacer(),
                    Switch(
                      value: displaySmall,
                      onChanged: (value) {
                        _smallVideoState.enableAllRemoteUserDisplaySmallVideoStream();
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _smallVideoState.isEnterRoom,
              builder: (context, isEnterRoom, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEnterRoom) {
                        _smallVideoState.exitRoom();
                      } else {
                        if (_smallVideoState.localUserId != null && _smallVideoState.roomId != null) {
                          _smallVideoState.enterRoom();
                        }
                      }
                    },
                    child: Text(isEnterRoom ? 'Exit Room' : 'Enter'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStreamSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Small Stream Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: _smallVideoState.enableSmallVideo,
            builder: (context, enableSmallVideo, _) {
              return Row(
                children: [
                  const Text('Enable Small Stream'),
                  const Spacer(),
                  Switch(
                    value: enableSmallVideo,
                    onChanged: (value) {
                      _smallVideoState.enableSmallVideo.value = value;
                      _smallVideoState.enableSmallVideoStream();
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: _smallVideoState.enableAdjustRes,
            builder: (context, enableAdjustRes, _) {
              return Row(
                children: [
                  const Text('Enable Adjust Res'),
                  const Spacer(),
                  Switch(
                    value: enableAdjustRes,
                    onChanged: (value) {
                      _smallVideoState.enableAdjustRes.value = value;
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _smallVideoState.minVideoBitrate,
            builder: (context, minVideoBitrate, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Min Bitrate (kbps)'),
                  Slider(
                    value: minVideoBitrate.toDouble(),
                    min: 0,
                    max: 2000,
                    divisions: 20,
                    onChanged: (newValue) {
                      _smallVideoState.minVideoBitrate.value = newValue.toInt();
                    },
                  ),
                  Text('Current: $minVideoBitrate'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _smallVideoState.videoBitrate,
            builder: (context, videoBitrate, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bitrate (kbps)'),
                  Slider(
                    value: videoBitrate.toDouble(),
                    min: 0,
                    max: 2000,
                    divisions: 20,
                    onChanged: (newValue) {
                      _smallVideoState.videoBitrate.value = newValue.toInt();
                    },
                  ),
                  Text('Current: $videoBitrate'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _smallVideoState.videoFps,
            builder: (context, videoFps, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frame Rate (FPS)'),
                  Slider(
                    value: videoFps.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (newValue) {
                      _smallVideoState.videoFps.value = newValue.toInt();
                    },
                  ),
                  Text('Current: $videoFps'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}