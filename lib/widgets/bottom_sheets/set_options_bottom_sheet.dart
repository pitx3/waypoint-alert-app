import 'package:flutter/material.dart';

class SetOptionsBottomSheet {
  static void show(BuildContext context, {VoidCallback? onManageSetsTap}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Manage Waypoint Sets'),
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              onManageSetsTap?.call();
            },
          ),
        ],
      ),
    );
  }
}