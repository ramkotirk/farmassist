import 'package:farmassist/ui/farm/farm_menu.dart';
import 'package:farmassist/ui/widgets/tab_page.dart';
import 'package:flutter/material.dart';

class FarmManagementPage extends TabPage {
  const FarmManagementPage({required String pageTitle})
      : super(pageTitle: pageTitle);

  @override
  _FarmManagementState createState() => _FarmManagementState();
}

class _FarmManagementState extends TabPageState<FarmManagementPage> {
  @override
  void initState() {
    tabListView.add(FarmMenu());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Widget buildTabListView() {
    return super.buildTabListView();
  }
}
