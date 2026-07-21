import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onImportTap;
  final VoidCallback? onSettingsTap;

  const AppDrawer({
    super.key,
    this.onImportTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            top: 50,
            bottom: 24,
          ),
          children: [
            // Import Waypoints
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text('Import Waypoints'),
              onTap: () {
                Navigator.pop(context); // close Drawer
                onImportTap?.call();
              }
            ),
            // Settings
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // close Drawer
                onSettingsTap?.call();
              }
            ),
          ],
        ),
      ),
    );
  }
}