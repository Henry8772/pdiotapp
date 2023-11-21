import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:pdiot_app/utils/classification_utils.dart';
import 'package:pdiot_app/utils/database_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivitiHistoryPage extends StatefulWidget {
  const ActivitiHistoryPage({super.key});

  @override
  State<ActivitiHistoryPage> createState() => _ActivitiHistoryPageState();
}

class _ActivitiHistoryPageState extends State<ActivitiHistoryPage> {
  Map<String, ActivityData> activities = {};
  //There will be 12 acitivities, remember to leave space in ui
  String _selectedTimeframe = 'Day';
  DateTime _selectedDateTime = DateTime.now();

  final List<String> _timeframeOptions = ['Day', 'This Week', 'This Month'];

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
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: Image.asset('assets/images/组 117@2x.png')),
          historyTitle(),
          Positioned(
            top: 108,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _selectedTimeframe == 'Day'
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xff1B1956).withOpacity(0.06),
                                    offset: Offset(0, 13),
                                    spreadRadius: 0,
                                    blurRadius: 50)
                              ]),
                          child: EasyDateTimeLine(
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
                              selectedDateFormat:
                                  SelectedDateFormat.fullDateDMY,
                            ),
                          ),
                        )
                      : SizedBox(),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Show data as:',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff333333)),
                        ),
                        Container(
                          height: 36,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0xffD7D8DB),
                              color: Colors.white,
                              border: Border.all(
                                  color: Color(0xffD7D8DB), width: 1)),
                          child: DropdownButton<String>(
                            value: _selectedTimeframe,
                            underline: Container(),
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTimeframe = newValue;
                                });

                                DateTime endTime = DateTime.now();
                                DateTime startTime;

                                if (_selectedTimeframe == 'Week') {
                                  startTime =
                                      endTime.subtract(Duration(days: 7));
                                } else if (_selectedTimeframe == 'Month') {
                                  startTime = DateTime(endTime.year,
                                      endTime.month - 1, endTime.day);
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
                        ),
                      ],
                    ),
                  ),
                  if (!activities.isEmpty)
                    SizedBox(
                      height: 260, // Fixed height for the pie chart
                      child: SfCircularChart(
                        series: _createPieSeries(),
                      ),
                    ),
                  if (activities.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'No available data',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ListView.separated(
                    itemCount: activities.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      String activityName = activities.keys.elementAt(index);
                      ActivityData activityData =
                          activities.values.elementAt(index);
                      int durationInSeconds = activityData.overallDuration;
                      Color activityColor = pieColors[index %
                          pieColors.length]; // Assign a color from the list

                      activities.values.elementAt(index);

                      List<String> activityDetails = [];

                      // Check and add details for non-zero durations
                      if (activityData.breathinDuration > 0) {
                        activityDetails.add(
                            "- Breathing normal: ${formatDuration(activityData.breathinDuration)}");
                      }
                      if (activityData.coughingDuration > 0) {
                        activityDetails.add(
                            "- Coughing: ${formatDuration(activityData.coughingDuration)}");
                      }

                      if (activityData.hyperventilatingDuration > 0) {
                        activityDetails.add(
                            "- Hyperventilating: ${formatDuration(activityData.hyperventilatingDuration)}");
                      }
                      if (activityData.otherDuration > 0) {
                        activityDetails.add(
                            "- Other: ${formatDuration(activityData.otherDuration)}");
                      }
                      if (activityDetails.isNotEmpty &&
                          activityData.physicalDuration > 0) {
                        activityDetails.add(
                            "- Physical (non-respiratory): ${formatDuration(activityData.physicalDuration)}");
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xff1B1956).withOpacity(0.06),
                                  offset: Offset(0, 13),
                                  spreadRadius: 0,
                                  blurRadius: 50)
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                        color: activityColor,
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    child: const Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Text(activityName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333),
                                            fontSize: 16)),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    formatDuration(durationInSeconds),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff333333),
                                        fontSize: 14),
                                  )
                                ],
                              ),
                              SizedBox(
                                  height:
                                      activityDetails.isNotEmpty ? 10.0 : 0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: activityDetails.map((detail) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 40.0),
                                        Expanded(
                                          child: Text(
                                            detail, // Assuming 'description' holds the text
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            ]),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onWeekSelected(DateTime startOfWeek, DateTime endOfWeek) async {
    setState(() {
      _selectedDateTime = startOfWeek;
    });

    var activitiesRange = await DatabaseHelper.getTimeSpentOnActivitiesInRange(
        startOfWeek, endOfWeek);
    setState(() {
      activities = activitiesRange;
    });
  }

  void _onMonthSelected(DateTime startOfMonth, DateTime endOfMonth) async {
    setState(() {
      _selectedDateTime = startOfMonth;
    });

    var activitiesRange = await DatabaseHelper.getTimeSpentOnActivitiesInRange(
        startOfMonth, endOfMonth);
    setState(() {
      activities = activitiesRange;
    });
  }

  Widget dateTimeLinePicker() {
    if (_selectedTimeframe == "Day") {
      return EasyDateTimeLine(
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
          selectedDateFormat: SelectedDateFormat.fullDateDMY,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    if (hours == 0 && minutes == 0) {
      return '${remainingSeconds}s'; // Return only seconds if less than a minute
    } else if (hours == 0) {
      return '${minutes}m';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  void changeDateTime(DateTime selectedDate) async {
    _selectedDateTime = selectedDate;
    _loadActivities();
  }

  List<PieSeries<MapEntry<String, ActivityData>, String>> _createPieSeries() {
    final data = activities.entries.toList();
    return <PieSeries<MapEntry<String, ActivityData>, String>>[
      PieSeries<MapEntry<String, ActivityData>, String>(
        dataSource: data,
        xValueMapper: (MapEntry<String, ActivityData> data, _) => data.key,
        yValueMapper: (MapEntry<String, ActivityData> data, _) =>
            data.value.overallDuration,
        pointColorMapper: (MapEntry<String, ActivityData> data, _) => pieColors[
            activities.keys.toList().indexOf(data.key) % pieColors.length],
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ),
    ];
  }
}

class historyTitle extends StatelessWidget {
  const historyTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 54,
      left: 16,
      child: Text("History",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
