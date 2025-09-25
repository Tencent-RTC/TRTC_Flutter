import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'render_params_state.dart';
import '../../../../common/user_list_widget.dart';
import '../../../../common/user_list_state.dart';

class RenderParamsPage extends StatefulWidget {
  const RenderParamsPage({Key? key}) : super(key: key);

  @override
  State<RenderParamsPage> createState() => _RenderParamsPageState();
}

class _RenderParamsPageState extends State<RenderParamsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RenderParamsState _renderParamsState;
  UserListState? _userListState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Adjusted to 3 Tabs
    _renderParamsState = RenderParamsState();
  }

  Future<void> _initialize() async {
    TRTCCloud trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(trtcCloud);
    _renderParamsState.initialize(trtcCloud, _userListState!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _renderParamsState.dispose();
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
            ChangeNotifierProvider.value(value: _renderParamsState),
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
        title: const Text('Render Parameters Settings'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _renderParamsState.isEnterRoom,
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
                    Tab(text: 'Local Render Params'),
                    Tab(text: 'Remote Render Params'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoomSettings(),
                      _buildLocalRenderParamsSettings(),
                      _buildRemoteRenderParamsSettings(),
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
                _renderParamsState.roomId = int.tryParse(value) ?? 0;
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
                _renderParamsState.localUserId = value;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _renderParamsState.isEnterRoom,
              builder: (context, isEnterRoom, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEnterRoom) {
                        _renderParamsState.exitRoom();
                      } else {
                        if (_renderParamsState.localUserId != null && _renderParamsState.roomId != null) {
                          _renderParamsState.enterRoom();
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

  Widget _buildLocalRenderParamsSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRotationControl(true, 'Rotation Angle'),
          _buildFillModeControl(true, 'Fill Mode'),
          _buildMirrorTypeControl(true, 'Mirror Mode'),
        ],
      ),
    );
  }

  Widget _buildRemoteRenderParamsSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRemoteUserControl('Remote User'),
          _buildRotationControl(false, 'Rotation Angle'),
          _buildFillModeControl(false, 'Fill Mode'),
          _buildMirrorTypeControl(false, 'Mirror Mode'),
        ],
      ),
    );
  }

  Widget _buildRotationControl(bool isLocal, String label) {
    return ValueListenableBuilder<TRTCVideoRotation>(
      valueListenable: isLocal ? _renderParamsState.localRotation : _renderParamsState.remoteRotation,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ${value}°'),
            DropdownButton<TRTCVideoRotation>(
              value: value,
              items: TRTCVideoRotation.values.map((angle) {
                String description;
                switch (angle) {
                  case TRTCVideoRotation.rotation0:
                    description = "0°";
                    break;
                  case TRTCVideoRotation.rotation90:
                    description = "90°";
                    break;
                  case TRTCVideoRotation.rotation180:
                    description = "180°";
                    break;
                  case TRTCVideoRotation.rotation270:
                    description = "270°";
                    break;
                }
                return DropdownMenuItem(
                  value: angle,
                  child: Text(description),
                );
              }).toList(),
              onChanged: (value) {
                if (isLocal) {
                  _renderParamsState.localRotation.value = value ?? TRTCVideoRotation.rotation0;
                } else {
                  _renderParamsState.remoteRotation.value = value ?? TRTCVideoRotation.rotation0;
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFillModeControl(bool isLocal, String label) {
    return ValueListenableBuilder<TRTCVideoFillMode>(
      valueListenable: isLocal ? _renderParamsState.localFillMode : _renderParamsState.remoteFillMode,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ${value}'),
            DropdownButton<TRTCVideoFillMode>(
              value: value,
              items: TRTCVideoFillMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (isLocal) {
                  _renderParamsState.localFillMode.value = value ?? TRTCVideoFillMode.fill;
                } else {
                  _renderParamsState.remoteFillMode.value = value ?? TRTCVideoFillMode.fill;
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMirrorTypeControl(bool isLocal, String label) {
    return ValueListenableBuilder<TRTCVideoMirrorType>(
      valueListenable: isLocal ? _renderParamsState.localMirrorType : _renderParamsState.remoteMirrorType,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ${value}'),
            DropdownButton<TRTCVideoMirrorType>(
              value: value,
              items: TRTCVideoMirrorType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (isLocal) {
                  _renderParamsState.localMirrorType.value = value ?? TRTCVideoMirrorType.auto;
                } else {
                  _renderParamsState.remoteMirrorType.value = value ?? TRTCVideoMirrorType.auto;
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRemoteUserControl(String label) {
    return ValueListenableBuilder<String>(
      valueListenable: _renderParamsState.selectRemoteUserId,
      builder: (context, value, child) {
        // Filter out local user ID
        final remoteUsers = _userListState!.users.entries.where((entry) => entry.key != _renderParamsState.localUserId).toList();
        // Allow empty string as initial value
        String dropdownValue = remoteUsers.any((entry) => entry.key == value) ? value : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ${dropdownValue.isEmpty ? "Not Selected" : dropdownValue}'),
            DropdownButton<String>(
              value: dropdownValue.isEmpty ? null : dropdownValue,
              hint: const Text('Select Remote User'),
              items: remoteUsers.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.key),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  _renderParamsState.selectRemoteUserId.value = newValue;
                  _renderParamsState.updateUserRenderParams(newValue, TRTCVideoStreamType.big);
                }
              },
            ),
          ],
        );
      },
    );
  }
}