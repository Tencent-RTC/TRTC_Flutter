import 'dart:async';
import 'dart:math' as math;
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

class CustomAudioCaptureState extends ChangeNotifier {
  bool _isCustomAudioEnabled = false;
  String? _localUserId;
  int? _roomId;
  TRTCCloud? _trtcCloud;
  bool _isInitialized = false;
  final Map<String, RemoteUserState> _remoteUsers = {};
  String _statusMessage = 'Preparing...';
  bool _isEnterRoomSuccess = false;
  Timer? _audioSendTimer;
  int _frameCount = 0;
  
  // Audio parameters
  final int _sampleRate = 48000;
  final int _channel = 2; // Stereo
  final int _frameDuration = 20; // ms
  
  // Melody parameters
  int _currentNoteIndex = 0;
  int _noteStartFrame = 0;
  
  // Musical scale: C D E F G A B (Major scale)
  final List<double> _melodyFrequencies = [
    261.63, // C4
    293.66, // D4
    329.63, // E4
    349.23, // F4
    392.00, // G4
    440.00, // A4
    493.88, // B4
  ];
  
  // Note durations in frames (at 20ms per frame, 25 frames = 0.5 second)
  final List<int> _noteDurations = [
    25, // C - 0.5s
    25, // D - 0.5s
    25, // E - 0.5s
    25, // F - 0.5s
    25, // G - 0.5s
    25, // A - 0.5s
    50, // B - 1.0s (longer for musical phrase ending)
  ];

  // Getters
  bool get isCustomAudioEnabled => _isCustomAudioEnabled;
  String? get localUserId => _localUserId;
  int? get roomId => _roomId;
  List<RemoteUserState> get remoteUsers => _remoteUsers.values.toList();
  bool get isInitialized => _isInitialized;
  String get statusMessage => _statusMessage;
  bool get isEnterRoomSuccess => _isEnterRoomSuccess;
  int get frameCount => _frameCount;

  TRTCCloudListener? _listener;

  Future<void> initialize({
    required String userId,
    required int roomId,
  }) async {
    _localUserId = userId;
    _roomId = roomId;
    _statusMessage = 'Initializing...';

    await _initializeTRTC();
    notifyListeners();
  }

  Future<void> _initializeTRTC() async {
    if (_trtcCloud == null) {
      _trtcCloud = await TRTCCloud.sharedInstance();
      _isInitialized = true;
    }
    _listener ??= _getTRTCCloudListener();
    if (_listener != null) {
      _trtcCloud?.registerListener(_listener!);
    }

    _statusMessage = 'Entering room...';
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: _localUserId ?? "",
        roomId: roomId ?? 123456,
        role: TRTCRoleType.anchor,
        userSig: GenerateTestUserSig.genTestSig(_localUserId!),
      ),
      TRTCAppScene.audioCall,
    );
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return _listener ??= TRTCCloudListener(
      onError: (errorCode, errorMsg) {
        _statusMessage = 'Error: $errorMsg';
        notifyListeners();
      },
      onEnterRoom: (result) {
        if (result > 0) {
          _statusMessage = 'Room entered successfully';
          _isEnterRoomSuccess = true;
        } else {
          _statusMessage = 'Failed to enter room: $result';
          _isEnterRoomSuccess = false;
        }
        notifyListeners();
      },
      onRemoteUserEnterRoom: (userId) {
        addRemoteUser(userId);
        _statusMessage = 'User $userId joined the room';
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        removeRemoteUser(userId);
        _statusMessage = 'User $userId left the room';
        notifyListeners();
      },
      onUserAudioAvailable: (userId, available) {
        updateRemoteUserAudioState(userId, available);
      },
    );
  }

  Future<void> enableCustomAudioCapture(bool enable) async {
    if (_trtcCloud == null) return;
    
    _isCustomAudioEnabled = enable;
    _trtcCloud?.enableCustomAudioCapture(enable);
    
    if (enable) {
      _startSendingAudioData();
      _statusMessage = 'Custom audio capture enabled - Playing C D E F G A B melody';
    } else {
      _stopSendingAudioData();
      _statusMessage = 'Custom audio capture disabled';
    }
    
    notifyListeners();
  }

  void _startSendingAudioData() {
    _frameCount = 0;
    _currentNoteIndex = 0;
    _noteStartFrame = 0;
    
    // Send audio frames at 20ms intervals
    _audioSendTimer = Timer.periodic(Duration(milliseconds: _frameDuration), (timer) {
      _sendAudioFrame();
    });
  }

  void _stopSendingAudioData() {
    _audioSendTimer?.cancel();
    _audioSendTimer = null;
  }

  Future<void> _sendAudioFrame() async {
    if (_trtcCloud == null) return;

    final int samplesPerFrame = (_sampleRate * _frameDuration ~/ 1000);
    final int frameSize = samplesPerFrame * _channel * 2; // 2 bytes per sample (int16)

    // Generate high-quality audio with rich harmonics
    final Uint8List audioData = _generateHighQualityAudio(samplesPerFrame);

    // Update timestamp
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // Create audio frame
    final audioFrame = TRTCAudioFrame(
      audioFormat: TRTCAudioFrameFormat.pcm,
      data: audioData,
      length: frameSize,
      sampleRate: _sampleRate,
      channel: _channel,
      timestamp: currentTime,
    );

    // Send audio frame
    _trtcCloud?.sendCustomAudioData(audioFrame);
    
    _frameCount++;
    
    // Check if we need to move to the next note
    if (_frameCount - _noteStartFrame >= _noteDurations[_currentNoteIndex]) {
      _currentNoteIndex = (_currentNoteIndex + 1) % _melodyFrequencies.length;
      _noteStartFrame = _frameCount;
    }
    
    if (_frameCount % 50 == 0) {
      // Update status every 1 second (50 frames * 20ms)
      final double seconds = _frameCount * _frameDuration / 1000.0;
      const notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
      _statusMessage = 'Playing melody (${notes[_currentNoteIndex]}) - ${seconds.toStringAsFixed(1)}s';
      notifyListeners();
    }
  }

  Uint8List _generateHighQualityAudio(int samplesPerFrame) {
    final ByteData byteData = ByteData(samplesPerFrame * _channel * 2);
    
    // Get current note frequency
    final double baseFreq = _melodyFrequencies[_currentNoteIndex];
    
    // Calculate fade in/out for smooth transitions
    const int fadeFrames = 5; // Number of frames for fade in/out
    final int framesIntoNote = _frameCount - _noteStartFrame;
    final int framesUntilEnd = _noteDurations[_currentNoteIndex] - framesIntoNote;
    
    for (int i = 0; i < samplesPerFrame; i++) {
      final int globalSampleIndex = (_frameCount - _noteStartFrame) * samplesPerFrame + i;
      final double t = globalSampleIndex / _sampleRate;
      
      // Calculate envelope (fade in/out) for smooth transitions
      double envelope = 1.0;
      if (framesIntoNote == 0 && i < samplesPerFrame * fadeFrames) {
        // Fade in at the start of a note
        envelope = (i / (samplesPerFrame * fadeFrames));
        envelope = envelope * envelope; // Squared for smoother curve
      } else if (framesUntilEnd <= fadeFrames) {
        // Fade out at the end of a note
        final double fadeOutProgress = (framesUntilEnd * samplesPerFrame - i) / (samplesPerFrame * fadeFrames);
        envelope = fadeOutProgress * fadeOutProgress;
      }
      
      // Generate rich harmonic content with carefully balanced amplitudes
      double leftValue = 0.0;
      double rightValue = 0.0;
      
      // Fundamental frequency (primary tone)
      const double fundamentalAmp = 12000.0;
      leftValue += fundamentalAmp * math.sin(2 * math.pi * baseFreq * t);
      rightValue += fundamentalAmp * math.sin(2 * math.pi * baseFreq * t);
      
      // 2nd harmonic (octave) - adds richness and fullness
      const double harmonic2Amp = 6000.0;
      leftValue += harmonic2Amp * math.sin(2 * math.pi * baseFreq * 2 * t);
      rightValue += harmonic2Amp * math.sin(2 * math.pi * baseFreq * 2 * t + 0.1); // Slight phase shift
      
      // 3rd harmonic (perfect fifth) - adds warmth
      const double harmonic3Amp = 4000.0;
      leftValue += harmonic3Amp * math.sin(2 * math.pi * baseFreq * 3 * t);
      rightValue += harmonic3Amp * math.sin(2 * math.pi * baseFreq * 3 * t + 0.2);
      
      // 4th harmonic (two octaves) - adds brightness
      const double harmonic4Amp = 2000.0;
      leftValue += harmonic4Amp * math.sin(2 * math.pi * baseFreq * 4 * t);
      rightValue += harmonic4Amp * math.sin(2 * math.pi * baseFreq * 4 * t + 0.15);
      
      // 5th harmonic (major third) - adds complexity
      const double harmonic5Amp = 1000.0;
      leftValue += harmonic5Amp * math.sin(2 * math.pi * baseFreq * 5 * t);
      rightValue += harmonic5Amp * math.sin(2 * math.pi * baseFreq * 5 * t + 0.25);
      
      // Add subtle vibrato for more natural sound (3Hz vibrato, 2% depth)
      final double vibrato = 1.0 + 0.02 * math.sin(2 * math.pi * 3.0 * t);
      leftValue *= vibrato;
      rightValue *= vibrato;
      
      // Apply envelope
      leftValue *= envelope;
      rightValue *= envelope;
      
      // Clamp and convert to int16
      final int leftSample = leftValue.round().clamp(-32768, 32767);
      final int rightSample = rightValue.round().clamp(-32768, 32767);
      
      // Write stereo samples (little-endian int16)
      final int sampleIndex = i * 2;
      byteData.setInt16(sampleIndex * 2, leftSample, Endian.little);
      byteData.setInt16(sampleIndex * 2 + 2, rightSample, Endian.little);
    }
    
    return byteData.buffer.asUint8List();
  }

  void addRemoteUser(String userId) {
    if (!_remoteUsers.containsKey(userId) && userId != _localUserId) {
      _remoteUsers[userId] = RemoteUserState(userId: userId);
      notifyListeners();
    }
  }

  void removeRemoteUser(String userId) {
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers.remove(userId);
      notifyListeners();
    }
  }

  void updateRemoteUserAudioState(String userId, bool hasAudio) {
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers[userId]!.updateAudioState(hasAudio);
      notifyListeners();
    }
  }

  Future<void> exitRoom() async {
    if (_trtcCloud != null) {
      _stopSendingAudioData();
      _trtcCloud?.enableCustomAudioCapture(false);
      _trtcCloud?.exitRoom();
    }
  }

  @override
  void dispose() {
    _stopSendingAudioData();
    _trtcCloud?.enableCustomAudioCapture(false);
    _trtcCloud?.exitRoom();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}

class RemoteUserState {
  final String userId;
  bool hasAudio;

  RemoteUserState({
    required this.userId,
    this.hasAudio = false,
  });

  void updateAudioState(bool hasAudio) {
    this.hasAudio = hasAudio;
  }
}
