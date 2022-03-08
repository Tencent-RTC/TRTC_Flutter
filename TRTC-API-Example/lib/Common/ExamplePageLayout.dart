import 'dart:async';

import 'package:flutter/material.dart';
import 'TXUpdateEvent.dart';
import 'ExampleData.dart';

class ExamplePageLayout extends StatefulWidget {
  final ExamplePageItem examplePageData;
  const ExamplePageLayout({Key? key, required this.examplePageData})
      : super(key: key);

  @override
  _ExamplePageLayoutState createState() => _ExamplePageLayoutState();
}

class _ExamplePageLayoutState extends State<ExamplePageLayout> {
  late StreamSubscription eventBusFn;
  String pageTitle = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      pageTitle = this.widget.examplePageData.title;
    });
    eventBusFn = eventBus.on<TitleUpdateEvent>().listen((event) {
      setState(() {
        pageTitle = event.pageTitle;
      });
    });
  }

  @override
  dispose() {
    eventBusFn.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: this.widget.examplePageData.detailPage != null
          ? this.widget.examplePageData.detailPage!
          : Center(
              child: Text('not found'),
            ),
    );
  }
}
