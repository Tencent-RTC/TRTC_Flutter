import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';

/// Set video resolution
class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  late TRTCCloud _trtcCloud;

  bool _isShowSetDialog = false;
  bool _isAPPPausedToClosed = false;
  double _currentCaptureValue = 100; //Default acquisition volume
  double _currentPlayValue = 100; //Default playback volume
  bool _enabledMirror = true;
  String _currentResolution = "360 * 640"; // Default resolution
  int _currentResValue = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
  List _resolutionList = [
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_160,
      "text": "160 * 160",
      "minBitrate": 40,
      "maxBitrate": 300,
      "curBitrate": 300
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180,
      "text": "180 * 320",
      "minBitrate": 80,
      "maxBitrate": 350,
      "curBitrate": 350
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_240,
      "text": "240 * 320",
      "minBitrate": 100,
      "maxBitrate": 400,
      "curBitrate": 400
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_480,
      "text": "480 * 480",
      "minBitrate": 200,
      "maxBitrate": 1000,
      "curBitrate": 750
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360,
      "text": "360 * 640",
      "minBitrate": 200,
      "maxBitrate": 1000,
      "curBitrate": 900
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480,
      "text": "480 * 640",
      "minBitrate": 250,
      "maxBitrate": 1000,
      "curBitrate": 1000
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540,
      "text": "540 * 960",
      "minBitrate": 400,
      "maxBitrate": 1600,
      "curBitrate": 1350
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720,
      "text": "720 * 1280",
      "minBitrate": 500,
      "maxBitrate": 2000,
      "curBitrate": 1850
    },
    {
      "value": TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1920_1080,
      "text": "1080 * 1920",
      "minBitrate": 800,
      "maxBitrate": 3000,
      "curBitrate": 1900
    },
  ];
  int _currentVideoFps = 15; //Default video capture frame rate
  List _videoFpsList = [15, 20];
  double _minBitrate = 200;
  double _maxBitrate = 1000;
  double _currentBitrate = 900; //Default bit rate

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _initRoom();
  }

  _initRoom() async {
    _trtcCloud = (await TRTCCloud.sharedInstance())!;
  }

  _dealMirror(state, value) {
    state(() {
      _enabledMirror = value;
    });
    if (value) {
      _trtcCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
    } else {
      _trtcCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE));
    }
  }

  // Resolution selection control
  _showResolution(morePageState) {
    showModalBottomSheet(
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, state) {
            return Container(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 30,
                onSelectedItemChanged: (position) {
                  _trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
                      videoFps: _currentVideoFps,
                      videoResolution: _resolutionList[position]['value'],
                      videoBitrate: _resolutionList[position]['curBitrate'],
                      videoResolutionMode:
                          TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE));

                  morePageState(() {
                    _currentResValue = _resolutionList[position]['value'];
                    _currentResolution = _resolutionList[position]['text'];
                    _minBitrate = double.parse(
                        _resolutionList[position]['minBitrate'].toString());
                    _maxBitrate = double.parse(
                        _resolutionList[position]['maxBitrate'].toString());
                    _currentBitrate = double.parse(
                        _resolutionList[position]['curBitrate'].toString());
                  });
                },
                children:
                    _resolutionList.map((item) => Text(item['text'])).toList(),
              ),
            );
          });
        },
        context: context);
  }

  // Frame rate selection control
  _showVideoFps(fpsState) {
    showModalBottomSheet(
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, state) {
            return Container(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 20,
                onSelectedItemChanged: (position) {
                  _trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
                    videoResolution: _currentResValue,
                    videoFps: _videoFpsList[position],
                    videoBitrate: _currentBitrate.round(),
                  ));
                  fpsState(() {
                    _currentVideoFps = _videoFpsList[position];
                  });
                },
                children:
                    _videoFpsList.map((item) => Text(item.toString())).toList(),
              ),
            );
          });
        },
        context: context);
  }
  
  Widget _videoSettings(state) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Row(
            children: <Widget>[
              Container(
                  width: 110,
                  alignment: Alignment.centerLeft,
                  child: Text('Resolution',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))),
              GestureDetector(
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 100.0,
                  height: 50.0,
                  child: Text(
                    _currentResolution,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () => _showResolution(state),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                  width: 110,
                  alignment: Alignment.centerLeft,
                  child: Text('FPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))),
              GestureDetector(
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 100.0,
                  height: 50.0,
                  child: Text(
                    _currentVideoFps.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () => _showVideoFps(state), //点击
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                  width: 85,
                  alignment: Alignment.centerLeft,
                  child: Text('Bit Rate',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))),
              Expanded(
                flex: 2,
                child: Slider(
                  value: _currentBitrate,
                  min: _minBitrate,
                  max: _maxBitrate,
                  divisions: (_maxBitrate - _minBitrate).round(),
                  label: _currentBitrate.round().toString(),
                  onChanged: (double value) {
                    _trtcCloud.setVideoEncoderParam(
                        TRTCVideoEncParam(
                            videoBitrate: value.round(),
                            videoFps: _currentVideoFps,
                            videoResolution: _currentResValue));
                    state(() {
                      _currentBitrate = value;
                    });
                  },
                ),
              ),
              Text(_currentBitrate.round().toString() + 'kbps',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                  width: 95,
                  alignment: Alignment.centerLeft,
                  child: Text('Local Mirror',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))),
              Container(
                  alignment: Alignment.centerLeft,
                  width: 100.0,
                  height: 50.0,
                  child: Switch(
                      value: _enabledMirror,
                      onChanged: (value) =>
                          _dealMirror(state, value)))
            ],
          ),
        ]),
      ),
    );
  }
  
  Widget _audioSettings(state) {
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            Row(
              children: <Widget>[
                Text('Capture Volume',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                Slider(
                  value: _currentCaptureValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _currentCaptureValue.round().toString(),
                  onChanged: (double value) {
                    _trtcCloud
                        .setAudioCaptureVolume(value.round());
                    state(() {
                      _currentCaptureValue = value;
                    });
                  },
                ),
                Text(_currentCaptureValue.round().toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Play Volume',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                Slider(
                  value: _currentPlayValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _currentPlayValue.round().toString(),
                  onChanged: (double value) {
                    _trtcCloud
                        .setAudioPlayoutVolume(value.round());
                    state(() {
                      _currentPlayValue = value;
                    });
                  },
                ),
                Text(_currentPlayValue.round().toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ])),
    );
  }

  _showSetDialog() {
    _isShowSetDialog = true;
    Future<void> future = showModalBottomSheet(
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return Container(
            color: Color.fromRGBO(19, 41, 75, 1),
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: Color.fromRGBO(19, 41, 75, 1),
                appBar: AppBar(
                    backgroundColor: Color.fromRGBO(19, 41, 75, 1),
                    bottom: TabBar(
                      tabs: [
                        Tab(text: 'Video'),
                        Tab(text: 'Audio'),
                      ],
                      unselectedLabelColor: Colors.white70,
                    ),
                    title: Text('Settings',
                      style: TextStyle(color: Colors.white),
                    ),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                ),
                body: TabBarView(
                  children: [
                    _videoSettings(state),
                    _audioSettings(state)
                  ],
                ),
              ),
            ),
          );
        });
      },
      context: context,
    );
    future.then((void value) {
      _isShowSetDialog = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        break;

      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        {
          if (_isAPPPausedToClosed) {
            _isAPPPausedToClosed = false;
            _showSetDialog();
          }
        }
        break;
      case AppLifecycleState.paused:
        {
          if (_isShowSetDialog) {
            Navigator.pop(context);
            _isAPPPausedToClosed = true;
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.more_horiz,
          color: Colors.white,
          size: 36.0,
        ),
        onPressed: () {
          _showSetDialog();
        });
  }
}
