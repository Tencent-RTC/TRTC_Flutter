import 'package:flutter/material.dart';

/// 渲染类型
enum RenderType {
  texture,
  platformView,
  unknown,
}

extension RenderTypeLabel on RenderType {
  String get label {
    switch (this) {
      case RenderType.texture:
        return 'Texture';
      case RenderType.platformView:
        return 'PlatformView';
      case RenderType.unknown:
        return 'Unknown';
    }
  }
}

class RenderTypeProbe extends StatefulWidget {
  final Widget child;

  final ValueChanged<RenderType> onDetected;

  const RenderTypeProbe({
    Key? key,
    required this.child,
    required this.onDetected,
  }) : super(key: key);

  @override
  State<RenderTypeProbe> createState() => _RenderTypeProbeState();
}

class _RenderTypeProbeState extends State<RenderTypeProbe> {
  final GlobalKey _probeKey = GlobalKey();
  RenderType _detected = RenderType.unknown;

  @override
  void initState() {
    super.initState();
    _scheduleDetect();
  }

  void _scheduleDetect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final type = _detectRenderType();
      if (type == RenderType.unknown) {
        _scheduleDetect();
        return;
      }
      if (type != _detected) {
        _detected = type;
        widget.onDetected(type);
      }
    });
  }

  RenderType _detectRenderType() {
    final context = _probeKey.currentContext;
    if (context == null) return RenderType.unknown;

    RenderType result = RenderType.unknown;
    void visitor(Element el) {
      if (result != RenderType.unknown) return;
      final w = el.widget;
      if (w is Texture) {
        result = RenderType.texture;
        return;
      }
      if (w is AndroidView || w is UiKitView) {
        result = RenderType.platformView;
        return;
      }
      el.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _probeKey,
      child: widget.child,
    );
  }
}
