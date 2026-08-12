import 'package:api_example/pages/advance_media/screenshot/screenshot_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import '../../../../common/user_list_widget.dart';
import '../../../../common/user_list_state.dart';

class ScreenshotPage extends StatefulWidget {
  const ScreenshotPage({Key? key}) : super(key: key);

  @override
  State<ScreenshotPage> createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScreenshotState _screenshotState;
  UserListState? _userListState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _screenshotState = ScreenshotState();
  }

  Future<void> _initialize() async {
    TRTCCloud trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(trtcCloud);
    _screenshotState.initialize(trtcCloud, _userListState!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _screenshotState.dispose();
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
            ChangeNotifierProvider.value(value: _screenshotState),
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
        title: const Text('Video Capture Settings'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _screenshotState.isEnterRoom,
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
                    Tab(text: 'Capture Settings'),
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
                _screenshotState.roomId = int.tryParse(value) ?? 0;
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
                _screenshotState.localUserId = value;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _screenshotState.isEnterRoom,
              builder: (context, isEnterRoom, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEnterRoom) {
                        _screenshotState.exitRoom();
                      } else {
                        if (_screenshotState.localUserId != null && _screenshotState.roomId != null) {
                          _screenshotState.enterRoom();
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
          const Text('Capture Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: _screenshotState.snapUserId,
            builder: (context, value, child) {
              final remoteUsers = _userListState!.users.entries.toList();
              String dropdownValue = remoteUsers.any((entry) => entry.key == value) ? value : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Capture Target'),
                  DropdownButton<String>(
                    value: dropdownValue.isEmpty ? null : dropdownValue,
                    hint: const Text('Select Target'),
                    items: remoteUsers.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        _screenshotState.snapUserId.value = newValue;
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TRTCSnapshotSourceType>(
            valueListenable: _screenshotState.sourceType,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Source Type'),
                  DropdownButton<TRTCSnapshotSourceType>(
                    value: value,
                    items: TRTCSnapshotSourceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        _screenshotState.sourceType.value = newValue;
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _screenshotState.snapShotVideo();
              },
              child: const Text('Capture'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}