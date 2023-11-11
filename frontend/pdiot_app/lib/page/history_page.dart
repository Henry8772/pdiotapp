import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdiot_app/page/history_controller.dart';
import 'package:pdiot_app/page/homepage.dart';
import 'package:pdiot_app/utils/ui_utils.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class PastDataPage extends StatefulWidget {
  @override
  _PastDataPageState createState() => _PastDataPageState();
}

class _PastDataPageState extends State<PastDataPage> {
  DateTime selectedDate = DateTime.now();
  final HistoryController _controller = Get.put(HistoryController()); //
  List<SensorData> selectedChartData = [];
  RangeValues selectedRange = RangeValues(0, 100);

  @override
  void initState() {
    super.initState();
    // Initialize selectedChartData based on current date
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Update selectedChartData based on picked date
      });
    }
  }

  Widget _buildRangeSelector() {
    return RangeSlider(
      values: selectedRange,
      min: 0,
      max: 100, // Adjust max based on your data
      onChanged: (RangeValues newRange) {
        setState(() {
          selectedRange = newRange;
          // Update chart data based on new range
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: _pickDate,
            child: Text('Select Date'),
          ),
          EasyDateTimeLine(
            initialDate: DateTime.now(),
            onDateChange: (selectedDate) {
              //`selectedDate` the new date selected.
            },
            headerProps: const EasyHeaderProps(
              monthPickerType: MonthPickerType.switcher,
              selectedDateFormat: SelectedDateFormat.fullDateDMY,
            ),
            dayProps: const EasyDayProps(
              dayStructure: DayStructure.dayStrDayNum,
              activeDayStyle: DayStyle(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff3371FF),
                      Color(0xff8426D6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildRangeSelector(),
          buildChartBox('Accelerometer Data', selectedChartData),
          // Repeat for Gyroscope Data
        ],
      ),
    );
  }

  // Include _buildChartBox and other necessary methods
}
