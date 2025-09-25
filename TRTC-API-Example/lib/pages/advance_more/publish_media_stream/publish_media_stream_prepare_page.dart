import 'publish_media_stream_anchor_page.dart';
import 'publish_media_stream_audience_page.dart';
import 'package:flutter/material.dart';

class PublishMediaStreamPreparePage extends StatefulWidget {
  const PublishMediaStreamPreparePage({Key? key}) : super(key: key);

  @override
  _PublishMediaStreamPreparePageState createState() => _PublishMediaStreamPreparePageState();
}

class _PublishMediaStreamPreparePageState extends State<PublishMediaStreamPreparePage> {
  final String guide1 = 'Select a role:\n- Anchors can publish streams via CDNs upon room entry by specifying the room entry parameter `streamid`.\n- Anchors can publish streams via CDNs upon room entry by specifying the room entry B2parameter B2\n- If anchors choose to relay streams to CDNs, audience can enter the playback address to watch the streams.';
  final String guide2 = 'Before you publish streams to CDNs, do the following:\n1. Enable relayed push in the console. A push address will be generated automatically.\n2. Register a domain name for playback and complete ICP filing.\nDocumentation: CDN Relayed Live Streaming (https://cloud.tencent.com/document/product/647/16826); On-Cloud MixTranscoding (https://cloud.tencent.com/document/product/647/16827)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: const Text('Publish Media Stream'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(guide1,
                style: const TextStyle(fontSize: 15, inherit: false)
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                 Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => const PublishMediaStreamAnchorPage(),
                  ),
                 );
              },
              child: const Text('Anchor'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => const PublishMediaStreamAudiencePage(),
                  ),
                );
              },
              child: const Text('Audience'),
            ),
            const SizedBox(height: 20),
            Text(guide2,
                style: const TextStyle(fontSize: 15, inherit: false)
            ),
          ],
        ),
      ),
    );
  }
}
