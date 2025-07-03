import 'package:flutter/material.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
