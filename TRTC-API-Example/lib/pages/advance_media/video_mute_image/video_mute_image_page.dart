import 'package:api_example/pages/advance_media/video_mute_image/video_mute_image_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import '../../../../common/user_list_widget.dart';
import '../../../../common/user_list_state.dart';

class VideoMuteImagePage extends StatefulWidget {
  const VideoMuteImagePage({Key? key}) : super(key: key);

  @override
  State<VideoMuteImagePage> createState() => _VideoMuteImagePageState();
}

class _VideoMuteImagePageState extends State<VideoMuteImagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoMuteImageState _videoMuteState;
  UserListState? _userListState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _videoMuteState = VideoMuteImageState();
  }

  Future<void> _initialize() async {
    TRTCCloud trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(trtcCloud);
    _videoMuteState.initialize(trtcCloud, _userListState!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoMuteState.dispose();
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
            ChangeNotifierProvider.value(value: _videoMuteState),
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
        title: const Text('Video Settings'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _videoMuteState.isEnterRoom,
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
                    Tab(text: 'Snapshot & Image'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoomSettings(),
                      _buildSnapAndImageSettings(),
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
                _videoMuteState.roomId = int.tryParse(value) ?? 0;
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
                _videoMuteState.localUserId = value;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _videoMuteState.isLocalVideoEnabled,
              builder: (context, isEnabled, _) {
                return Row(
                  children: [
                    const Text('Enable Local Video'),
                    const Spacer(),
                    Switch(
                      value: isEnabled,
                      onChanged: (value) {
                        _videoMuteState.muteLocalVideo();
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _videoMuteState.isEnterRoom,
              builder: (context, isEnterRoom, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEnterRoom) {
                        _videoMuteState.exitRoom();
                      } else {
                        if (_videoMuteState.localUserId != null && _videoMuteState.roomId != null) {
                          _videoMuteState.enterRoom();
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

  Widget _buildSnapAndImageSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Image Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: _videoMuteState.imagePath,
            builder: (context, value, child) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Image Path'),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: value.isEmpty ? null : value,
                      hint: const Text('Select Image Path'),
                      items: _videoMuteState.pathList.map((path) {
                        return DropdownMenuItem(
                          value: path,
                          child: Text(
                            path,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (newPath) {
                        if (newPath != null) {
                          _videoMuteState.imagePath.value = newPath;
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _videoMuteState.fps,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FPS'),
                  Slider(
                    value: value.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (newValue) {
                      _videoMuteState.fps.value = newValue.toInt();
                    },
                  ),
                  Text('Current: $value'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _videoMuteState.setVideoMuteImage();
              },
              child: const Text('Apply Settings'),
            ),
          ),
        ],
      ),
    );
  }
}