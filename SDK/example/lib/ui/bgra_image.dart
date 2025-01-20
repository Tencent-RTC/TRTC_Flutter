import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BgraImage extends StatefulWidget {
  final Uint8List? bgraData;
  final int width;
  final int height;

  BgraImage({
    Key? key,
    required this.bgraData,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _BgraImageState createState() => _BgraImageState();
}

class _BgraImageState extends State<BgraImage> {
  late Future<ui.Image?> _imageFuture;

  @override
  void initState() {
    super.initState();
    if (widget.bgraData != null) {
      _imageFuture = _bgraToImage(widget.bgraData!, widget.width, widget.height);
    } else {
      _imageFuture = Future.value(null);
    }
  }

  Future<ui.Image?> _bgraToImage(Uint8List bgraData, int width, int height) async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      bgraData,
      width,
      height,
      ui.PixelFormat.bgra8888,
      (ui.Image image) {
        completer.complete(image);
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image?>(
      future: _imageFuture,
      builder: (BuildContext context, AsyncSnapshot<ui.Image?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            return RawImage(
              image: snapshot.data!,
            );
          } else {
            return Container(color: Colors.black);
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}