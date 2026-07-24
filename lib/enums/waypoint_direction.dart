enum WaypointDirection {
  straight,
  left,
  right,
  slightLeft,
  slightRight,
  hardLeft,
  hardRight,
  uTurn;

  String get displayName {
    switch (this) {
      case WaypointDirection.straight: return 'Straight';
      case WaypointDirection.left: return 'Left';
      case WaypointDirection.right: return 'Right';
      case WaypointDirection.slightLeft: return 'Slight Left';
      case WaypointDirection.slightRight: return 'Slight Right';
      case WaypointDirection.hardLeft: return 'Hard Left';
      case WaypointDirection.hardRight: return 'Hard Right';
      case WaypointDirection.uTurn: return 'U-Turn';
    }
  }

  static WaypointDirection? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase().replaceAll('-', '');
    for (final direction in WaypointDirection.values) {
      if (direction.name.toLowerCase() == normalized) {
        return direction;
      }
    }
    return null;
  }

}