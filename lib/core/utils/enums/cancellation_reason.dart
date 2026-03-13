enum CancellationReason {
  FEEL_ENDANGERED,
  LOCATION_CHANGED,
  NO_REASON,
  OTHER;

  String get value {
    switch (this) {
      case CancellationReason.FEEL_ENDANGERED:
        return 'I_FELT_ENDANGERED_BY_THE_DRIVER';
      case CancellationReason.LOCATION_CHANGED:
        return 'CHANGED_MY_LOCATION';
      case CancellationReason.NO_REASON:
        return 'NO_REASON';
      case CancellationReason.OTHER:
        return 'OTHER';
    }
  }

  static CancellationReason fromString(String reason) {
    switch (reason) {
      case 'I felt endangered by the driver':
        return CancellationReason.FEEL_ENDANGERED;
      case 'Changed my location':
        return CancellationReason.LOCATION_CHANGED;
      case 'No reason':
        return CancellationReason.NO_REASON;
      default:
        return CancellationReason.OTHER;
    }
  }
}
