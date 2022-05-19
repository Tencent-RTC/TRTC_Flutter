import 'package:flutter/material.dart';
import 'package:trtc_api_example/Advanced/PushCDN/PushCDNAudiencePage.dart';
import 'package:trtc_api_example/Common/ExampleData.dart';
import 'package:trtc_api_example/Common/ExamplePageLayout.dart';
import './PushCDNAnchorPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

///  PushCDNSelectRolePage.dart
///  TRTC-API-Example-Dart
class PushCDNSelectRolePage extends StatefulWidget {
  const PushCDNSelectRolePage({Key? key}) : super(key: key);

  @override
  _PushCDNSelectRolePageState createState() => _PushCDNSelectRolePageState();
}

class _PushCDNSelectRolePageState extends State<PushCDNSelectRolePage> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    ExamplePageItem anchorPage = ExamplePageItem(
      title: 'Room ID: ',
      detailPage: PushCDNAnchorPage(),
    );
    ExamplePageItem audiencePage = ExamplePageItem(
      title: 'Audience page',
      detailPage: PushCDNAudiencePage(),
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(AppLocalizations.of(context)!.pushcdn_select_role_guide),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {
               Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => ExamplePageLayout(
                    examplePageData: anchorPage,
                  ),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.pushcdn_select_role_anchor_choice),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: style,
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => ExamplePageLayout(
                    examplePageData: audiencePage,
                  ),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.pushcdn_select_role_audience_choice),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.pushcdn_select_role_result),
        ],
      ),
    );
  }
}
