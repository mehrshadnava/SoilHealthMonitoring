// Simple entity class to avoid import issues
class SoilEntity {
  final String id;
  final double pH;
  final double moisture;
  final double temperature;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double electricalConductivity;
  final DateTime timestamp;

  SoilEntity({
    required this.id,
    required this.pH,
    required this.moisture,
    required this.temperature,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.electricalConductivity,
    required this.timestamp,
  });
}