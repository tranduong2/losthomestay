class DiscountModel {
  final String code;
  final double percent; // 0-100
  final DateTime expiry;
  final bool active;

  DiscountModel({
    required this.code,
    required this.percent,
    required this.expiry,
    this.active = true,
  });

  bool get isValid => active && DateTime.now().isBefore(expiry);
}

