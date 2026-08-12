import 'package:api_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/common/user_list_state.dart';
import 'package:api_example/common/user_list_widget.dart';

class SetWatermarkPage extends StatefulWidget {
  final String userId;
  final String roomId;

  const SetWatermarkPage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<SetWatermarkPage> createState() => _SetWatermarkPageState();
}

class _SetWatermarkPageState extends State<SetWatermarkPage> {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  UserListState? _userListState;
  bool _isEntered = false;
  bool _isInit = false;

  TRTCVideoStreamType _streamType = TRTCVideoStreamType.big;
  double _x = 0.5;
  double _y = 0.5;
  double _width = 0.2;

  @override
  void initState() {
    super.initState();
    _initTRTC();
  }

  Future<void> _initTRTC() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _userListState = UserListState(_trtcCloud!);
    _listener = TRTCCloudListener(
      onEnterRoom: (result) {
        if (result > 0) {
          setState(() {
            _isEntered = true;
          });
          _userListState?.setLocalUser(widget.userId);
          Fluttertoast.showToast(msg: 'Enter room success');
        } else {
          Fluttertoast.showToast(msg: 'Enter room failed: $result');
        }
      },
      onError: (code, msg) {
        Fluttertoast.showToast(msg: 'Error: $msg($code)');
      },
      onExitRoom: (reason) {
        setState(() {
          _isEntered = false;
        });
        Fluttertoast.showToast(msg: 'Exited room');
      },
    );
    _trtcCloud?.registerListener(_listener!);
    _enterRoom();
    setState(() {
      _isInit = true;
    });
  }

  void _enterRoom() {
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: widget.userId,
        roomId: int.tryParse(widget.roomId) ?? 0,
        userSig: GenerateTestUserSig.genTestSig(widget.userId),
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.live,
    );
  }

  void _setWatermark() async {
    var imagePath = await Utils.getAssetsFilePath('assets/images/watermark_img.png');
    _trtcCloud?.setWatermark(imagePath, _streamType, _x, _y, _width);
    Fluttertoast.showToast(msg: 'setWatermark applied');
  }

  @override
  void dispose() {
    _trtcCloud?.unRegisterListener(_listener!);
    _trtcCloud?.exitRoom();
    _userListState?.dispose();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userListState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return ChangeNotifierProvider.value(
      value: _userListState!,
      child: Scaffold(
        appBar: AppBar(title: const Text('Set Watermark')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Room User List'),
              const SizedBox(height: 8),
              const SizedBox(height: 220, child: UserListWidget(isVideoMode: true)),
              const Divider(height: 20),
              const Text('Watermark Image Path'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Stream Type: '),
                  const SizedBox(width: 8),
                  DropdownButton<TRTCVideoStreamType>(
                    value: _streamType,
                    items: TRTCVideoStreamType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (type) {
                      if (type != null) setState(() => _streamType = type);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('X: ${_x.toStringAsFixed(2)}'),
              Slider(
                value: _x,
                min: 0,
                max: 1,
                divisions: 100,
                label: _x.toStringAsFixed(2),
                onChanged: (v) => setState(() => _x = v),
              ),
              Text('Y: ${_y.toStringAsFixed(2)}'),
              Slider(
                value: _y,
                min: 0,
                max: 1,
                divisions: 100,
                label: _y.toStringAsFixed(2),
                onChanged: (v) => setState(() => _y = v),
              ),
              Text('Width: ${_width.toStringAsFixed(2)}'),
              Slider(
                value: _width,
                min: 0.01,
                max: 1,
                divisions: 100,
                label: _width.toStringAsFixed(2),
                onChanged: (v) => setState(() => _width = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isEntered ? _setWatermark : null,
                  child: const Text('Apply Watermark'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 