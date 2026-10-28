/// Vehicle classes supported by CMP roadside detection model.
/// Reference: AGENT.md Section 4 & 7.7.
enum VehicleClass {
  car('car', 'কার'),
  bus('bus', 'বাস'),
  truck('truck', 'ট্রাক'),
  cng('cng', 'সিএনজি'),
  motorcycle('motorcycle', 'মোটরসাইকেল'),
  leguna('leguna', 'লেগুনা');

  const VehicleClass(this.wireName, this.banglaLabel);

  final String wireName;
  final String banglaLabel;

  static VehicleClass fromString(String value) {
    return VehicleClass.values.firstWhere(
      (e) => e.wireName == value.toLowerCase().trim(),
      orElse: () => VehicleClass.car,
    );
  }
}
