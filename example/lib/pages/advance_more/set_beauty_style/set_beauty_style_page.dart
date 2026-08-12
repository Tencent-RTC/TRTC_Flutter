import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import '../../../common/user_list_state.dart';
import '../../../common/user_list_widget.dart';

class SetBeautyStylePage extends StatefulWidget {
  final String userId;
  final String roomId;

  const SetBeautyStylePage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<SetBeautyStylePage> createState() => _SetBeautyStylePageState();
}

class _SetBeautyStylePageState extends State<SetBeautyStylePage> {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  UserListState? _userListState;
  bool _isEntered = false;
  bool _isInit = false;
  TRTCBeautyStyle _style = TRTCBeautyStyle.smooth;
  double _beautyLevel = 5;
  double _whitenessLevel = 5;
  double _ruddinessLevel = 5;

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

  void _setBeautyStyle() {
    _trtcCloud?.setBeautyStyle(
      _style,
      _beautyLevel.toInt(),
      _whitenessLevel.toInt(),
      _ruddinessLevel.toInt(),
    );
    Fluttertoast.showToast(msg: 'setBeautyStyle applied');
  }

  @override
  void dispose() {
    _trtcCloud?.unRegisterListener(_listener!);
    _trtcCloud?.exitRoom();
    _userListState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userListState == null) {
      // 初始化未完成时显示 loading
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return ChangeNotifierProvider.value(
      value: _userListState!,
      child: Scaffold(
        appBar: AppBar(title: const Text('Set Beauty Style')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Room User List'),
              const SizedBox(height: 8),
              const SizedBox(height: 220, child: UserListWidget(isVideoMode: true)),
              const Divider(height: 32),
              Row(
                children: [
                  const Text('Beauty Style: '),
                  const SizedBox(width: 8),
                  DropdownButton<TRTCBeautyStyle>(
                    value: _style,
                    items: TRTCBeautyStyle.values.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (style) {
                      if (style != null) setState(() => _style = style);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Beauty Level: ${_beautyLevel.toInt()}'),
              Slider(
                value: _beautyLevel,
                min: 0,
                max: 9,
                divisions: 9,
                label: _beautyLevel.toInt().toString(),
                onChanged: (v) => setState(() => _beautyLevel = v),
              ),
              const SizedBox(height: 16),
              Text('Whiteness Level: ${_whitenessLevel.toInt()}'),
              Slider(
                value: _whitenessLevel,
                min: 0,
                max: 9,
                divisions: 9,
                label: _whitenessLevel.toInt().toString(),
                onChanged: (v) => setState(() => _whitenessLevel = v),
              ),
              const SizedBox(height: 16),
              Text('Ruddiness Level: ${_ruddinessLevel.toInt()}'),
              Slider(
                value: _ruddinessLevel,
                min: 0,
                max: 9,
                divisions: 9,
                label: _ruddinessLevel.toInt().toString(),
                onChanged: (v) => setState(() => _ruddinessLevel = v),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isEntered ? _setBeautyStyle : null,
                  child: const Text('Apply Beauty Style'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 