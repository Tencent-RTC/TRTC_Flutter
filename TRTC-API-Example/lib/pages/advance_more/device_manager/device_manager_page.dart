import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

import '../../../common/user_list_widget.dart';
import '../../../common/user_list_state.dart';
import 'device_manager_state.dart';

class DeviceManagerPage extends StatefulWidget {
  const DeviceManagerPage({Key? key}) : super(key: key);

  @override
  State<DeviceManagerPage> createState() => _DeviceManagerPageState();
}

class _DeviceManagerPageState extends State<DeviceManagerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DeviceManagerState _deviceManagerState;
  UserListState? _userListState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _deviceManagerState = DeviceManagerState();
  }

  Future<void> _initialize() async {
    TRTCCloud trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(trtcCloud);
    _deviceManagerState.initialize(trtcCloud, _userListState!);
    _deviceManagerState.enableCameraAutoFocus(false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _deviceManagerState.dispose();
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
            ChangeNotifierProvider.value(value: _deviceManagerState),
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
        title: const Text('Device Manager'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _deviceManagerState.isEnterRoom,
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
                    Tab(text: 'Device Settings'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoomSettings(),
                      _buildDeviceSettings(),
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
                _deviceManagerState.roomId = int.tryParse(value) ?? 0;
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
                _deviceManagerState.localUserId = value;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _deviceManagerState.isEnterRoom,
              builder: (context, isEnterRoom, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEnterRoom) {
                        _deviceManagerState.exitRoom();
                      } else {
                        if (_deviceManagerState.localUserId != null && _deviceManagerState.roomId != null) {
                          _deviceManagerState.enterRoom();
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

  Widget _buildDeviceSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Text('Device Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Front Camera Status'),
                  ElevatedButton(
                    onPressed: () => _deviceManagerState.isFrontCamera(),
                    child: const Text('Get'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Max Zoom Ratio'),
                  ElevatedButton(
                    onPressed: () => _deviceManagerState.getCameraZoomMaxRatio(),
                    child: const Text('Get'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Auto Focus Status'),
                  ElevatedButton(
                    onPressed: () => _deviceManagerState.isAutoFocusEnabled(),
                    child: const Text('Get'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Camera Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: _deviceManagerState.frontCamera,
            builder: (context, isFront, _) {
              return Row(
                children: [
                  const Text('Front Camera'),
                  const Spacer(),
                  Switch(
                    value: isFront,
                    onChanged: (value) {
                      _deviceManagerState.frontCamera.value = value;
                    },
                  ),
                ],
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _deviceManagerState.cameraAutofocus,
            builder: (context, autoFocus, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _deviceManagerState.frontCamera,
                builder: (context, isFront, __) {
                  return Row(
                    children: [
                      const Text('Enable Camera Torch'),
                      const Spacer(),
                      Switch(
                        value: autoFocus,
                        onChanged: isFront
                            ? null
                            : (value) {
                                _deviceManagerState.cameraAutofocus.value = value;
                              },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<double>(
            valueListenable: _deviceManagerState.cameraZoomRatio,
            builder: (context, ratio, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Zoom Ratio'),
                  Slider(
                    value: ratio,
                    min: 1.0,
                    max: 24.0,
                    onChanged: (value) {
                      _deviceManagerState.cameraZoomRatio.value = value;
                    },
                  ),
                  Text('Current: ${ratio.toStringAsFixed(2)}'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Audio Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ValueListenableBuilder<TXAudioRoute>(
            valueListenable: _deviceManagerState.audioRoute,
            builder: (context, route, _) {
              return Row(
                children: [
                  const Text('Audio Route'),
                  const Spacer(),
                  DropdownButton<TXAudioRoute>(
                    value: route,
                    items: [TXAudioRoute.speakerPhone, TXAudioRoute.earpiece].map((route) {
                      return DropdownMenuItem<TXAudioRoute>(
                        value: route,
                        child: Text(route.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _deviceManagerState.audioRoute.value = value;
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Focus Position', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              const Text("X: "),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    double? x = double.tryParse(value);
                    if (x != null) {
                      _deviceManagerState.focusPositionX = x;
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              const Text("Y: "),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    double? y = double.tryParse(value);
                    if (y != null) {
                      _deviceManagerState.focusPositionY = y;
                    }
                  },
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _deviceManagerState.setCameraFocusPosition(),
            child: const Text('Set Focus Position'),
          ),
          const SizedBox(height: 16),
          const Text('Resolution Settings', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Width',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _deviceManagerState.width = int.tryParse(value) ?? 640;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _deviceManagerState.height = int.tryParse(value) ?? 360;
                  },
                ),
              ),
              const SizedBox(width: 16),
              ValueListenableBuilder<TXCameraCaptureMode>(
                valueListenable: _deviceManagerState.captureMode,
                builder: (context, mode, _) {
                  return DropdownButton<TXCameraCaptureMode>(
                    value: mode,
                    items: TXCameraCaptureMode.values.map((mode) {
                      return DropdownMenuItem<TXCameraCaptureMode>(
                        value: mode,
                        child: Text(mode.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _deviceManagerState.captureMode.value = value;
                      }
                    },
                  );
                },
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _deviceManagerState.setCameraCaptureParam(),
            child: const Text('Camera Capture'),
          ),
        ],
      ),
    );
  }
}