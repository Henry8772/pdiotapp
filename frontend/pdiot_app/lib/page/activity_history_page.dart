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
  String _selectedTimeframe = 'Day';
  DateTime _selectedDateTime = DateTime.now();

  final List<String> _timeframeOptions = ['Day', 'Week', 'Month'];

  final List<Color> pieColors = [
    Colors.red, Colors.green, Colors.blue, Colors.orange,
    Colors.purple, Colors.pink, Colors.yellow, Colors.cyan,
    Colors.brown, Colors.grey, Colors.lime, Colors.indigo,
    // Add more colors if you have more than 12 activities
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    var todayActivities =
        await DatabaseHelper.getTimeSpentOnActivitiesByDay(_selectedDateTime);
    // var result = await DatabaseHelper.getSessionActivities();
    // var result1 = await DatabaseHelper.getActivities();
    setState(() {
      activities = todayActivities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EasyDateTimeLine(
              initialDate: _selectedDateTime,
              onDateChange: (selectedDate) {
                changeDateTime(selectedDate);
              },
              dayProps: const EasyDayProps(
                height: 56.0,
                width: 56.0,
                dayStructure: DayStructure.dayNumDayStr,
                inactiveDayStyle: DayStyle(
                  borderRadius: 48.0,
                  dayNumStyle: TextStyle(fontSize: 18.0),
                ),
                activeDayStyle: DayStyle(
                  dayNumStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              headerProps: const EasyHeaderProps(
                monthPickerType: MonthPickerType.switcher,
                selectedDateFormat: SelectedDateFormat.fullDateDMY,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Show data as:',
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

                        if (_selectedTimeframe == 'Week') {
                          startTime = endTime.subtract(Duration(days: 7));
                        } else if (_selectedTimeframe == 'Month') {
                          startTime = DateTime(
                              endTime.year, endTime.month - 1, endTime.day);
                        } else {
                          startTime = DateTime(
                              endTime.year, endTime.month, endTime.day);
                        }

                        var activitiesRange = await DatabaseHelper
                            .getTimeSpentOnActivitiesInRange(
                                startTime, endTime);
                        setState(() {
                          activities = activitiesRange;
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
            if (!activities.isEmpty)
              SizedBox(
                height: 300, // Fixed height for the pie chart
                child: SfCircularChart(
                  series: _createPieSeries(),
                ),
              ),
            if (activities.isEmpty)
              Center(
                child: Text(
                  'No available data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ListView.builder(
              itemCount: activities.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                String activityName = activities.keys.elementAt(index);
                int durationInSeconds = activities.values.elementAt(index);
                Color activityColor = pieColors[
                    index % pieColors.length]; // Assign a color from the list
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.access_time,
                        color: activityColor), // Use the assigned color
                    title: Text(activityName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(formatDuration(durationInSeconds)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    if (hours == 0 && minutes == 0) {
      return '${remainingSeconds}s'; // Return only seconds if less than a minute
    }
    return '${hours}h ${minutes}m';
  }

  void changeDateTime(DateTime selectedDate) async {
    _selectedDateTime = selectedDate;
    _loadActivities();
  }

  List<PieSeries<MapEntry<String, int>, String>> _createPieSeries() {
    final data = activities.entries.toList();
    return <PieSeries<MapEntry<String, int>, String>>[
      PieSeries<MapEntry<String, int>, String>(
        dataSource: data,
        xValueMapper: (MapEntry<String, int> data, _) => data.key,
        yValueMapper: (MapEntry<String, int> data, _) => data.value,
        pointColorMapper: (MapEntry<String, int> data, _) => pieColors[
            activities.keys.toList().indexOf(data.key) % pieColors.length],
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ),
    ];
  }
}
