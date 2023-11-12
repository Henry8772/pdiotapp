import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:pdiot_app/utils/database_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ActivitiHistoryPage extends StatefulWidget {
  const ActivitiHistoryPage({super.key});

  @override
  State<ActivitiHistoryPage> createState() => _ActivitiHistoryPageState();
}

class _ActivitiHistoryPageState extends State<ActivitiHistoryPage> {
  Map<String, int> activities = {};
  //There will be 12 acitivities, remember to leave space in ui
  late DateTime _startDate, _endDate;
  String _selectedTimeframe = 'Day';

  final List<String> _timeframeOptions = ['Day', 'Week', 'Month'];

  @override
  void initState() {
    super.initState();
    _loadTodayActivities();
  }

  void _loadTodayActivities() async {
    // var todayActivities = await DatabaseHelper.getTimeSpentOnActivitiesToday();
    // var result = await DatabaseHelper.getSessionActivities();
    // var result1 = await DatabaseHelper.getActivities();
    setState(() {
      activities = {
        'Running': 3600,
        'Reading': 1800,
        // Add more activities here
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          EasyDateTimeLine(
            initialDate: DateTime.now(),
            onDateChange: (selectedDate) {
              changeDateTime(selectedDate);
              //`selectedDate` the new date selected.
            },
            dayProps: const EasyDayProps(
              height: 56.0,
              width: 56.0,
              dayStructure: DayStructure.dayNumDayStr,
              inactiveDayStyle: DayStyle(
                borderRadius: 48.0,
                dayNumStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              activeDayStyle: DayStyle(
                dayNumStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            headerProps: const EasyHeaderProps(
              // showHeader: false,
              monthPickerType: MonthPickerType.switcher,
              selectedDateFormat: SelectedDateFormat.fullDateDMY,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // This will align the children to opposite ends
              children: [
                const Text(
                  'Show data as:', // Text aligned to the left
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedTimeframe,
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      setState(() {
                        _selectedTimeframe = newValue;
                      });

                      DateTime endTime = DateTime.now();
                      DateTime startTime;

                      // Determine the start time based on the selected timeframe
                      if (_selectedTimeframe == 'Week') {
                        startTime = endTime.subtract(Duration(days: 7));
                      } else if (_selectedTimeframe == 'Month') {
                        startTime = DateTime(
                            endTime.year, endTime.month - 1, endTime.day);
                      } else {
                        // Default to day (or implement other logic as needed)
                        startTime =
                            DateTime(endTime.year, endTime.month, endTime.day);
                      }

                      setState(() {
                        activities = {
                          'Running': 8600,
                          'Reading': 4800,
                          // Add more activities here
                        };
                        ;
                      });
                    }
                  },
                  items: _timeframeOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCircularChart(
              series: _createPieSeries(),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              String activityName = activities.keys.elementAt(index);
              int durationInSeconds = activities.values.elementAt(index);
              return Card(
                child: ListTile(
                  leading: Icon(Icons.access_time,
                      color: Colors.blue), // Icon for the activity
                  title: Text(activityName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(formatDuration(durationInSeconds)),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  void changeDateTime(DateTime selectedDate) async {
    // _controller.changeSelectedDay(selectedDate);
    // await _controller.loadData(0);
    // setState(() {});
  }

  List<PieSeries<MapEntry<String, int>, String>> _createPieSeries() {
    final data = activities.entries.toList();
    return <PieSeries<MapEntry<String, int>, String>>[
      PieSeries<MapEntry<String, int>, String>(
        dataSource: data,
        xValueMapper: (MapEntry<String, int> data, _) => data.key,
        yValueMapper: (MapEntry<String, int> data, _) => data.value,
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ),
    ];
  }
}
