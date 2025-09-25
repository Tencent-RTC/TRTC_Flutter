import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'local_record_state.dart';
import '../../../../common/user_list_widget.dart';
import '../../../../common/user_list_state.dart';

class LocalRecordPage extends StatefulWidget {
  const LocalRecordPage({Key? key}) : super(key: key);

  @override
  State<LocalRecordPage> createState() => _LocalRecordPageState();
}

class _LocalRecordPageState extends State<LocalRecordPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LocalRecordState _localRecordState;
  UserListState? _userListState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _localRecordState = LocalRecordState();
  }

  Future<void> _initialize() async {
    TRTCCloud trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(trtcCloud);
    _localRecordState.initialize(trtcCloud, _userListState!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _localRecordState.dispose();
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
            ChangeNotifierProvider.value(value: _localRecordState),
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
        title: const Text('Local Recording Settings'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _localRecordState.isEnterRoom,
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
                    Tab(text: 'Recording Settings'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoomSettings(),
                      _buildRecordSettings(),
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
                _localRecordState.roomId = int.tryParse(value) ?? 0;
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
                _localRecordState.localUserId = value;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _localRecordState.isEnterRoom,
              builder: (context, isEnterRoom, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEnterRoom) {
                        _localRecordState.exitRoom();
                      } else {
                        if (_localRecordState.localUserId != null && _localRecordState.roomId != null) {
                          _localRecordState.enterRoom();
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

  Widget _buildRecordSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _localRecordState.isRecording,
            builder: (context, isRecording, _) {
              return SwitchListTile(
                title: const Text('Start Recording'),
                value: isRecording,
                onChanged: (value) {
                  _localRecordState.isRecording.value = value;
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'File Path',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (value) {
              _localRecordState.filePath.value = value;
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TRTCLocalRecordType>(
            valueListenable: _localRecordState.recordType,
            builder: (context, recordType, _) {
              return DropdownButton<TRTCLocalRecordType>(
                value: recordType,
                items: TRTCLocalRecordType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _localRecordState.recordType.value = value;
                  }
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Recording Interval (ms)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _localRecordState.interval.value = int.tryParse(value) ?? -1;
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Max File Duration (ms)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _localRecordState.maxDurationPerFile.value = int.tryParse(value) ?? 0;
            },
          ),
        ],
      ),
    );
  }
}