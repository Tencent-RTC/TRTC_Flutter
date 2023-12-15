import 'package:flutter/material.dart';
import 'package:trtc_api_example/Advanced/PublishMediaStream/PublishMediaStreamAudiencePage.dart';
import 'package:trtc_api_example/Common/ExampleData.dart';
import 'package:trtc_api_example/Common/ExamplePageLayout.dart';
import './PublishMediaStreamAnchorPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PublishMediaStreamSelectRolePage extends StatefulWidget {
  const PublishMediaStreamSelectRolePage({Key? key}) : super(key: key);

  @override
  _PublishMediaStreamSelectRolePageState createState() => _PublishMediaStreamSelectRolePageState();
}

class _PublishMediaStreamSelectRolePageState extends State<PublishMediaStreamSelectRolePage> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    ExamplePageItem anchorPage = ExamplePageItem(
      title: 'Room ID: ',
      detailPage: PublishMediaStreamAnchorPage(),
    );
    ExamplePageItem audiencePage = ExamplePageItem(
      title: 'Audience page',
      detailPage: PublishMediaStreamAudiencePage(),
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
