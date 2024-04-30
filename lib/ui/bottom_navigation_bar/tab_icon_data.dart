import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    required this.imagePath,
    required this.index,
    required this.selectedImagePath,
    required this.isSelected,
    required this.label,
    required TickerProvider vsync,
  }) : animationController = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 500),
  );

  String imagePath;
  String selectedImagePath;
  bool isSelected;
  int index;
  String label;
  AnimationController animationController;

  static List<TabIconData> tabIconsList(TickerProvider vsync) => [
    TabIconData(
      imagePath: 'assets/images/farm_management_tab.png',
      selectedImagePath: 'assets/images/farm_management_tab_selected.png',
      index: 0,
      isSelected: true,
      label: 'Manage',
      vsync: vsync,
    ),
    TabIconData(
      imagePath: 'assets/images/IoT_monitoring_tab.png',
      selectedImagePath: 'assets/images/IoT_monitoring_tab_selected.png',
      index: 1,
      isSelected: false,
      label: 'Monitor',
      vsync: vsync,
    ),
    TabIconData(
      imagePath: 'assets/images/disease_detection_tab.png',
      selectedImagePath: 'assets/images/disease_detection_tab_selected.png',
      index: 2,
      isSelected: false,
      label: 'Detect',
      vsync: vsync,
    ),
    TabIconData(
      imagePath: 'assets/images/user_profile_tab.png',
      selectedImagePath: 'assets/images/user_profile_tab_selected.png',
      index: 3,
      isSelected: false,
      label: 'Me',
      vsync: vsync,
    ),
  ];
}
