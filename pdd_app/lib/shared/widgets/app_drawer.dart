import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'nav_content.dart';

class AppDrawer extends StatelessWidget {
  final String userRole;

  const AppDrawer({super.key, this.userRole = 'Admin'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.primaryColor,
      child: NavContent(userRole: userRole, isSidebar: false),
    );
  }
}
