import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  PushCDNAudiencePage.dart
///  TRTC-API-Example-Dart
class PushCDNAudiencePage extends StatefulWidget {
  const PushCDNAudiencePage({Key? key}) : super(key: key);

  @override
  _PushCDNAudiencePageState createState() => _PushCDNAudiencePageState();
}

class _PushCDNAudiencePageState extends State<PushCDNAudiencePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.pushcdn_play),
    );
  }
}
