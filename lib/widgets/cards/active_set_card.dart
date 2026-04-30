import 'package:flutter/material.dart';

class ActiveSetCard extends StatelessWidget {
  final String setName;
  final int waypointCount;
  final VoidCallback? onTap;

  const ActiveSetCard({
    super.key,
    required this.setName,
    required this.waypointCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Active Set',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text (
                setName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text (
                '$waypointCount waypoints loaded',
                style: const TextStyle(fontSize: 14)
              ),
            ],
          ),
        ),
      ),
    );
  }

}