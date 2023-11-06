import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_controller.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final ChartController _controller = ChartController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateUI); // Correctly added listener in initState
  }

  void _updateUI() {
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        // This empty setState will trigger the build method to run again
        // with the updated controller data.
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateUI); // Remove listener before disposing
    _controller.dispose(); // Dispose the controller if it has a dispose method
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
              // Wrap LineChart in Expanded to take available space
              child: LineChart(
                LineChartData(
                  minY: _controller.minY, // Set the minimum value of Y-axis
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
                        // Here you can provide your custom labels for the X axis
                        return value.toInt().toString();
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff75729e),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      getTitles: (value) {
                        // Here you can provide your custom labels for the Y axis
                        return '${value.toInt()}';
                      },
                      margin: 8,
                      reservedSize: 30,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _controller.accXData,
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _controller.accYData,
                      isCurved: true,
                      colors: [Colors.green],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _controller.accZData,
                      isCurved: true,
                      colors: [Colors.green],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // It's not typical to call setState when starting a long-running task like connecting to Bluetooth.
                // If connectBluetooth() changes the state, it should call setState internally if needed.
                _controller.connectBluetooth();
              },
              child: const Text('Connect to Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }
}
