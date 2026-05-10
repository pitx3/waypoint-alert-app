import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';


  
class IconForType extends StatelessWidget {
  final String type;

  const IconForType({super.key, required this.type});

  @override 
  Widget build(BuildContext context) {
    final iconData = _getIconForType(type);
    final color = _getColorForType(type);

    return Icon(iconData, color: color);
  }
}


IconData _getIconForType(String type) {
  switch (type.toLowerCase()) {
    case 'water':
      return Icons.water_drop;
    case 'trailhead':
      return Icons.hiking;
    case 'camp':
      return MdiIcons.tent;
    case 'junction':
      return Icons.signpost;  // alternatives: assistant_direction, assistant_navigation, call_split, foloow_the_signs, fork_left, fork_right,
    default:
      return Icons.place;  
  }
}

Color _getColorForType(String type) {
  switch (type.toLowerCase()) {
    case 'water':
      return Colors.lightBlue;
    case 'trailhead':
      return Colors.green;
    case 'camp':
      return Colors.orange;
    case 'junction': 
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
