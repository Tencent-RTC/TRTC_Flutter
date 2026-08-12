// Copyright (c) 2022 Tencent. All rights reserved.
// ignore_for_file: constant_identifier_names
// ignore_for_file: prefer_const_constructors_in_immutables
part of 'super_player.dart';

typedef FTXOnRenderViewCreatedListener = void Function(int viewId);

class TXPlayerVideo extends StatefulWidget {
  final FTXAndroidRenderViewType renderViewType;
  final FTXOnRenderViewCreatedListener? onRenderViewCreatedListener;

  ///
  /// Starting from version 12.4.1, the method of binding textures by passing in a controller has been removed.
  /// This method is removed due to too many unforeseen issues. It is recommended to use the `onRenderViewCreatedListener`
  /// callback of `TXPlayerVideo`. After obtaining the `viewId`, use `controller#setPlayerView` to bind the player
  /// and texture.
  ///
  /// e.g:
  /// TXPlayerVideo(
  ///    onRenderViewCreatedListener: (viewId) {
  ///      /// Only the most basic configuration methods for textures and the player are shown here.
  ///      /// The `viewId` can be recorded here to switch between multiple textures. For example, in the scenario
  ///      /// of switching between portrait and landscape orientations:
  ///      /// To switch from the portrait view to the landscape view, obtain the `viewId` of the landscape view
  ///      /// after switching to landscape orientation and set it.  When switching back to portrait orientation,
  ///      /// switch back using the recorded `viewId`.
  ///      _controller.setPlayerView(viewId);
  ///    },
  ///  )
  ///
  TXPlayerVideo(
      {this.onRenderViewCreatedListener,
      FTXAndroidRenderViewType? androidRenderType,
      Key? viewKey})
      : renderViewType =
            androidRenderType ?? FTXAndroidRenderViewType.TEXTURE_VIEW,
        super(key: viewKey);

  @override
  TXPlayerVideoState createState() => TXPlayerVideoState();
}

class TXPlayerVideoState extends State<TXPlayerVideo> {
  static const TAG = "TXPlayerVideo";

  int _viewId = -1;
  Completer<int> _viewIdCompleter = Completer();
  // for force rebuild
  Key _platformViewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TXPlayerVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.renderViewType != widget.renderViewType) {
      setState(() {
        _platformViewKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return IgnorePointer(
          ignoring: true,
          child: AndroidView(
            key: _platformViewKey,
            onPlatformViewCreated: _onCreateAndroidView,
            viewType: _kFTXPlayerRenderViewType,
            layoutDirection: TextDirection.ltr,
            creationParams: {
              _kFTXAndroidRenderTypeKey: widget.renderViewType.index
            },
            creationParamsCodec: const StandardMessageCodec(),
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IgnorePointer(
        ignoring: true,
        child: UiKitView(
            key: _platformViewKey,
            viewType: _kFTXPlayerRenderViewType,
            layoutDirection: TextDirection.ltr,
            creationParams: const {},
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreateIOSView),
      );
    } else {
      throw ArgumentError("platform not support: $defaultTargetPlatform");
    }
  }

  void _onCreateAndroidView(int id) {
    if (_viewIdCompleter.isCompleted) {
      _viewIdCompleter = Completer();
    }
    _viewId = id;
    _viewIdCompleter.complete(id);
    widget.onRenderViewCreatedListener?.call(id);
  }

  void _onCreateIOSView(int id) {
    if (_viewIdCompleter.isCompleted) {
      _viewIdCompleter = Completer();
    }
    _viewId = id;
    _viewIdCompleter.complete(id);
    widget.onRenderViewCreatedListener?.call(id);
  }

  Future<int> getViewId() async {
    await _viewIdCompleter.future;
    return _viewId;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
