import 'package:flutter/material.dart';

class SensorGauge extends StatelessWidget {
  final double value;
  final String title;
  final String unit;
  final double min;
  final double max;
  final List<double> optimalRange;

  const SensorGauge({
    super.key,
    required this.value,
    required this.title,
    required this.unit,
    required this.min,
    required this.max,
    required this.optimalRange,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = ((value - min) / (max - min)).clamp(0.0, 1.0);
    bool isOptimal = value >= optimalRange[0] && value <= optimalRange[1];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[400],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOptimal ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isOptimal ? 'Optimal' : 'Check',
              style: TextStyle(
                color: isOptimal ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}