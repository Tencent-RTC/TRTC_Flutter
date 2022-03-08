import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Common/ExampleData.dart';
import 'Common/ExamplePageLayout.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  List<ExamplePageItem> _exampleList = [];
  Widget getSeparatorBuilder(BuildContext context, index) {
    Divider divider = Divider(
      thickness: 0, // 分隔线宽度
      height: 15,
    );
    return divider;
  }

  Widget getItemBuilder(context, index) {
    ExamplePageItem currentObj = this._exampleList[index];
    if (currentObj.detailPage == null) {
      return Text(
        currentObj.title,
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
    ListTile apiItem = new ListTile(
      tileColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: Text(currentObj.title),
      subtitle: currentObj.subTitle != null ? Text(currentObj.subTitle!) : null,
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => ExamplePageLayout(
              examplePageData: currentObj,
            ),
          ),
        );
      },
    );
    return apiItem;
  }

  @override
  void initState() {
    super.initState();
    ExampleData.exampleDataList.forEach((key, value) {
      List<ExamplePageItem> ls = value;
      _exampleList.add(ExamplePageItem(title: key, detailPage: null));
      _exampleList.addAll(ls);
    });
    initPermission();
  }

  initPermission() async {
    if (!(await Permission.camera.request().isGranted) ||
        !(await Permission.microphone.request().isGranted)) {
      showToast('需要获取音视频权限才能进入');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRTC API Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
              child: ListView.separated(
                separatorBuilder: this.getSeparatorBuilder,
                itemBuilder: this.getItemBuilder,
                itemCount: _exampleList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
