import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/models/water_info.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';

class ClosestWaterCard extends StatefulWidget {
  final WaterInfo waterInfo;

  const ClosestWaterCard({
    super.key,
    required this.waterInfo,
  });

  @override
  State<ClosestWaterCard> createState() => _ClosestWaterCardState();
}

class _ClosestWaterCardState extends State<ClosestWaterCard> {
  String _formatDistance(double? meters) {
    if (meters == null) return '--';
    if (meters < 1000) return '${meters.toStringAsFixed(0)}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _formatBearing(double? degrees) {
    if (degrees == null) return '';
    return '${degrees.toStringAsFixed(0)}°';
  }

  @override
  Widget build(BuildContext context) {
    final water = widget.waterInfo;

    if (water.closestWater == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Closest Water',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('No water waypoints available'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Closest Water',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildWaterRow(
              water.closestWater!,
              water.closestDistanceMeters!,
              water.isClosestBehind,
              water.closestBearing,
            ),
            if (water.isClosestBehind && water.nextWaterAhead != null) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildWaterRow(
                water.nextWaterAhead!,
                water.nextWaterDistanceMeters!,
                false,
                water.nextWaterBearing,
                label: 'Next Ahead',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWaterRow(
    Waypoint waypoint,
    double distance,
    bool isBehind,
    double? bearing, {
    String? label,
  }) {
    final directionIcon = isBehind
        ? const Icon(Icons.arrow_back, size: 16, color: Colors.orange)
        : const Icon(Icons.arrow_forward, size: 16, color: Colors.green);

    final distanceText = isBehind
        ? '${_formatDistance(distance)} behind'
        : _formatDistance(distance);

    return Row(
      children: [
        directionIcon,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              Text(
                waypoint.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Row(
                children: [
                  Text(
                    distanceText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (bearing != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _formatBearing(bearing),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}