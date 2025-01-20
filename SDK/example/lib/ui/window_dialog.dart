
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:flutter/material.dart';

import 'package:trtc_demo/ui/bgra_image.dart';

class WindowSelectorDialog extends StatelessWidget {
  final TRTCScreenCaptureSourceList windows;

  WindowSelectorDialog({required this.windows});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select a window to share'),
      content: Container(
        width: double.maxFinite,
                child: GridView.builder(
          itemCount: windows.count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, 
            crossAxisSpacing: 8, 
            mainAxisSpacing: 8, 
            childAspectRatio: 1, 
          ),
          itemBuilder: (context, index) {
            final window = windows.sourceInfo[index];
            final imageBuffer = (window.type == TRTCScreenCaptureSourceType.window)
                ? window.iconBGRA
                : window.thumbBGRA;
            return InkWell(
              onTap: () {
                Navigator.of(context).pop(index);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    window.sourceName!,
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  imageBuffer != null
                      ? BgraImage(
                          bgraData: imageBuffer.buffer!,
                          width: imageBuffer.width!,
                          height: imageBuffer.height!,
                        )
                      : Placeholder(fallbackWidth: 50, fallbackHeight: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}