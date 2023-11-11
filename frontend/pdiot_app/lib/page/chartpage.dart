import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_controller.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final ChartController _controller = ChartController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateUI); // Listen for updates
  }

  void _updateUI() {
    if (mounted) {
      setState(() {}); // Trigger UI update when controller updates
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateUI); // Proper cleanup
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: _controller.minY,
                  maxY: _controller.maxY,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff72719b),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      margin: 10,
                      getTitles: (value) {
                        // Check if the value is divisible by 3
                        if (value.toInt() % 3 == 0) {
                          return value.toInt().toString();
                        }
                        return ''; // Return empty string for other values
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff75729e),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      getTitles: (value) => '${value.toInt()}',
                      margin: 8,
                      reservedSize: 30,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _controller.accXData.length <= 15
                          ? _controller.accXData
                          : _controller.accXData
                              .sublist(_controller.accXData.length - 15),
                      isCurved: true,
                      colors: [
                        Colors.red
                      ], // Assuming you want red for the X data
                      barWidth: 1,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _controller.accYData.length <= 15
                          ? _controller.accYData
                          : _controller.accYData
                              .sublist(_controller.accYData.length - 15),
                      isCurved: true,
                      colors: [
                        Colors.green
                      ], // Assuming you want green for the Y data
                      barWidth: 1,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _controller.accZData.length <= 15
                          ? _controller.accZData
                          : _controller.accZData
                              .sublist(_controller.accZData.length - 15),
                      isCurved: true,
                      colors: [Colors.blue], // Z data is now blue as requested
                      barWidth: 1,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _controller.connectBluetooth,
              child: const Text('Connect to Bluetooth'),
            ),
            ElevatedButton(
              onPressed: _controller.addDummyDataTest,
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: _controller.stopDummyDataTest,
              child: const Text('Stop'),
            ),
            ElevatedButton(
              onPressed: _controller.load,
              child: const Text('Load Model'),
            ),
            Text("Result: ${_controller.output}")
          ],
        ),
      ),
    );
  }
}
