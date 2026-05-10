import 'package:flutter/material.dart';

import 'package:waypoint_alert_app/utils/ui.dart' as ui;

class NextWaypointCard extends StatelessWidget {
  final String name;
  final String type;
  final double distanceKm;
  final double bearing;
  final String? notes;

  const NextWaypointCard({
    super.key,
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.bearing,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ui.IconForType(type: type),
                const SizedBox(width: 8),
                const Text(
                  'NEXT WAYPOINT',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${distanceKm.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.explore,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${bearing.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(notes ?? ''),             
              ],
            ),
          ],
        ),
      ),
    );
    
  }



}