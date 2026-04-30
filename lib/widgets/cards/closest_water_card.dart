import 'package:flutter/material.dart';

class ClosestWaterCard extends StatelessWidget {
  final String? waterName;
  final double? distanceKm;
  final double? bearing;

  const ClosestWaterCard({
    super.key,
    this.waterName,
    this.distanceKm,
    this.bearing,
  });

  @override
  Widget build(BuildContext context) {
    if (waterName == null || distanceKm == null) {
      return _EmptyState();
    }

    return Card(
      color: Colors.blue[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.water_drop,
              size: 32,
              color: Colors.lightBlue[300],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CLOSEST WATER',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    waterName!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${distanceKm!.toStringAsFixed(1)} km away',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.lightBlue[300],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.explore,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (bearing == null) ? '--' : '${bearing!.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );

  }

}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              'No water waypoints in current set',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

}