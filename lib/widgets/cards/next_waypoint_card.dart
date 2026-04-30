import 'package:flutter/material.dart';

class NextWaypointCard extends StatelessWidget {
  final String name;
  final double distanceKm;
  final double bearing;

  const NextWaypointCard({
    super.key,
    required this.name,
    required this.distanceKm,
    required this.bearing,
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
                const Icon(Icons.flag, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'NEXT WAYPOINT',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
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
                Icon(
                  Icons.directions_walk,
                  size: 16,
                  color: Colors.teal[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${distanceKm.toStringAsFixed(1)} km away',
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
          ],
        ),
      ),
    );
    
  }



}