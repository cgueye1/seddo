enum TripTypeEnum { SUBSCRIPTION, OCCASIONAL }

TripTypeEnum? TripTypeEnumFromString(String? type) {
  if (type == null) return null;
  try {
    return TripTypeEnum.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == type.toUpperCase(),
    );
  } catch (e) {
    return null;
  }
}
