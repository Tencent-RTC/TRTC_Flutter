import 'package:flutter/material.dart';
import 'package:trtc_api_example/Advanced/PushCDN/PushCDNAudiencePage.dart';
import 'package:trtc_api_example/Common/ExampleData.dart';
import 'package:trtc_api_example/Common/ExamplePageLayout.dart';
import './PushCDNAnchorPage.dart';

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
      title: '房间号: ',
      detailPage: PushCDNAnchorPage(),
    );
    ExamplePageItem audiencePage = ExamplePageItem(
      title: '观众端',
      detailPage: PushCDNAudiencePage(),
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("您好，请选择进入房间角色："),
          Text("主播进入房间,在进房参数中填写streamid,可自动发布CDN;"),
          Text("当主播数大于等于2时,可开启云端混流,主播选择旁路到CDN后,观众可以输入播放地址进行观看;"),
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
            child: const Text('我是主播'),
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
            child: const Text('我是观众'),
          ),
          const SizedBox(height: 20),
          Text("在进行TRTC推CDN流发布前，需要完成以下事项：\n1、在控制台启用旁路推流，推流地址在启动该功能后会自动生成。\n2、播放CDN需要您自行申请注册并备案播放域名。\n参考文档：\n实现CDN直播观看：\nhttps://cloud.tencent.com/document/product/647/16826\n云端混流转码：\nhttps://cloud.tencent.com/document/product/647/16827"),
        ],
      ),
    );
  }
}
