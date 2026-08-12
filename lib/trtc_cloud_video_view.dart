import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:tencent_rtc_sdk/impl/trtc/trtc_cloud_impl.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

/// Video view widget for displaying local video, remote video, or sub-stream
///
/// **Parameters:**
///
/// `onViewCreated`: Callback after the view is created, returns the generated `viewId`
class TRTCCloudVideoView extends StatefulWidget {
  static final Set<int> _viewIdSets = {};
  static addViewId(int viewId) {
    if (_viewIdSets.contains(viewId)) {
      return;
    }
    _viewIdSets.add(viewId);
  }

  static removeViewId(int viewId) {
    _viewIdSets.remove(viewId);
  }

  static bool containsViewId(int viewId) {
    return _viewIdSets.contains(viewId);
  }

  /// Callback after the view is created, returns a `viewId` that uniquely identifies a platform view in Flutter
  final ValueChanged<int>? onViewCreated;

  const TRTCCloudVideoView({Key? key, this.onViewCreated}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TRTCCloudVideoViewState();
}

/// @nodoc
class _TRTCCloudVideoViewState extends State<TRTCCloudVideoView> {
  static const MethodChannel _videoViewChannel = MethodChannel(
    'TXCloudVideoViewChannel',
  );

  MethodChannel? _channel;

  int? _textureId;
  int? _viewId;
  bool _renderSizeInitialized = false;

  int textureWidth = 0;
  int textureHeight = 0;

  bool _useTexture = false;

  @override
  void initState() {
    super.initState();
    _useTexture = TRTCCloudImpl.useTextureRender || TRTCPlatform.isOhos;
    _initTexture();
  }

  void _initTexture() {
    if (!_useTexture) {
      return;
    }

    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        TRTCPlatform.isMacOS) {
      _videoViewChannel.invokeMethod("createTextureView").then((value) {
        if (!mounted) return;
        setState(() {
          _textureId = value;
          TRTCCloudVideoView.addViewId(_textureId!);
          _setTextureAspectRatioListener(value);
        });
        widget.onViewCreated?.call(_textureId!);
      });
    } else if (TRTCPlatform.isOhos) {
      _videoViewChannel.invokeMethod('getTextureId').then((textureId) async {
        final surfaceId = await _videoViewChannel.invokeMethod('getSurfaceId', {
          'textureId': textureId,
        });
        if (!mounted) return;
        setState(() {
          _textureId = textureId as int;
          _viewId = surfaceId as int;
          TRTCCloudVideoView.addViewId(_viewId!);
        });
        widget.onViewCreated?.call(_viewId!);
      });
    }
  }

  void _setRenderSize(int textureId, int width, int height) {
    if (Platform.isIOS) return;
    _videoViewChannel.invokeMethod('setRenderSize', {
      'textureId': textureId,
      'width': width,
      'height': height,
    });
  }

  _setTextureAspectRatioListener(int textureId) {
    MethodChannel("tencent_rtc_texture_$textureId").setMethodCallHandler((
      call,
    ) async {
      switch (call.method) {
        case "updateVideoAspectRatio":
          final int w = call.arguments["width"];
          final int h = call.arguments["height"];
          if (w == textureWidth && h == textureHeight) return;
          textureWidth = w;
          textureHeight = h;
          break;
        default:
          throw MissingPluginException();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildRenderWidget();
  }

  Widget _buildRenderWidget() {
    if (_useTexture) {
      if (_textureId != null) {
        return _getTRTCTextureView();
      }
      return Container();
    }

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'TXCloudVideoViewPlatformView',
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: 'TXCloudVideoViewPlatformView',
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Container();
  }

  Widget _getTRTCTextureView() {
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!_renderSizeInitialized &&
              !Platform.isAndroid &&
              constraints.maxWidth > 0 &&
              constraints.maxHeight > 0) {
            _renderSizeInitialized = true;
            final pixelRatio = MediaQuery.of(context).devicePixelRatio;
            final renderWidth = (constraints.maxWidth * pixelRatio).toInt();
            final renderHeight = (constraints.maxHeight * pixelRatio).toInt();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _textureId != null) {
                _setRenderSize(_textureId!, renderWidth, renderHeight);
              }
            });
          }

          if (textureWidth <= 0 || textureHeight <= 0) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.black,
              child: Texture(
                textureId: _textureId!,
                filterQuality: FilterQuality.medium,
              ),
            );
          }

          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.black,
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: textureWidth.toDouble(),
                height: textureHeight.toDouble(),
                child: Texture(
                  textureId: _textureId!,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onPlatformViewCreated(int id) async {
    _channel = MethodChannel("TRTCPlatformView_$id");
    int? txView = await _channel!.invokeMethod<int>("getTXView");
    _viewId = txView;
    TRTCCloudVideoView.addViewId(_viewId!);
    widget.onViewCreated!(txView!);
  }

  @override
  void dispose() {
    if (_textureId != null) {
      if (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isWindows ||
          Platform.isMacOS) {
        TRTCCloudVideoView.removeViewId(_textureId!);
        _videoViewChannel.invokeMethod("disposeTextureView", {
          "textureId": _textureId!,
        });
      } else if (TRTCPlatform.isOhos) {
        _videoViewChannel.invokeMethod('unregisterTexture', {
          'textureId': _textureId!,
        });
      }
    }
    if (_viewId != null) {
      TRTCCloudVideoView.removeViewId(_viewId!);
    }
    super.dispose();
  }
}
