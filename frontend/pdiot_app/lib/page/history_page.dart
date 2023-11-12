// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:pdiot_app/page/history_controller.dart';
// import 'package:pdiot_app/page/homepage.dart';
// import 'package:pdiot_app/utils/ui_utils.dart';
// import 'package:easy_date_timeline/easy_date_timeline.dart';

// class PastDataPage extends StatefulWidget {
//   @override
//   _PastDataPageState createState() => _PastDataPageState();
// }

// class _PastDataPageState extends State<PastDataPage> {
//   DateTime selectedDate = DateTime.now();
//   final HistoryController _controller = Get.put(HistoryController()); //
//   RangeValues selectedRange = RangeValues(0, 100);
//   int selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller.refreshDateTime();
//     _controller.loadData(0);
//     setState(() {});

//     // Initialize selectedChartData based on current date
//   }

//   void _pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         changeDateTime(selectedDate);

//         // Update selectedChartData based on picked date
//       });
//     }
//   }

//   void changeDateTime(DateTime selectedDate) async {
//     _controller.changeSelectedDay(selectedDate);
//     await _controller.loadData(0);
//     setState(() {});
//   }

//   Widget _buildRangeSelector() {
//     return RangeSlider(
//       values: selectedRange,
//       min: 0,
//       max: 100, // Adjust max based on your data
//       onChanged: (RangeValues newRange) {
//         setState(() {
//           selectedRange = newRange;
//           // Update chart data based on new range
//         });
//       },
//     );
//   }

//   void _handleBoxTap(int index) async {
//     // _controller.refreshDateTime();
//     bool flag = await _controller.loadData(index);

//     setState(() {
//       selectedIndex = index;
//       // This will rebuild the widget with updated data
//     });
//   }

//   Widget _buildSlidableBoxGroup() {
//     // Check if the list is empty
//     if (_controller.date_time.value.isEmpty) {
//       return const Center(
//         child: Text(
//           'No available data',
//           style:
//               TextStyle(fontSize: 16, color: Colors.grey), // Optional styling
//         ),
//       );
//     }

//     // If the list is not empty, build the list
//     return Column(
//       children: [
//         const Padding(
//           padding: EdgeInsets.fromLTRB(10.0, 0, 0, 10),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//                 "Available Time Stamps:"), // Updated text as per your request
//           ),
//         ),
//         Container(
//           height: 40, // Adjust height as needed
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _controller.date_time.value.length,
//             itemBuilder: (BuildContext context, int index) {
//               return _buildBox(_controller.date_time.value[index], index);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBox(String content, int index) {
//     bool isSelected = index == selectedIndex; // Check if this box is selected

//     return InkWell(
//       onTap: () => _handleBoxTap(index),
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 8.0),
//         padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Colors.blue
//               : Colors.white, // Selected box is blue, others are white
//           borderRadius: BorderRadius.circular(10),
//           border: isSelected
//               ? null
//               : Border.all(
//                   color: Colors.blue), // Unselected boxes have a blue border
//         ),
//         child: Center(
//           child: Text(
//             content,
//             style: TextStyle(
//                 color: isSelected
//                     ? Colors.white
//                     : Colors.blue), // Change text color based on selection
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         // Use SafeArea to avoid overlaps with system UI
//         child: SingleChildScrollView(
//           // Wrap with SingleChildScrollView for scrollable content
//           padding: const EdgeInsets.all(16.0), // Consistent padding
//           child: Obx(
//             () => Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start, // Align items to start
//               children: <Widget>[
//                 // Row(
//                 //   mainAxisAlignment: MainAxisAlignment
//                 //       .spaceBetween, // Aligns children to start and end
//                 //   children: [
//                 //     Text(
//                 //       '${DateFormat('yyyy-MM-dd').format(selectedDate)}', // Displays formatted current day
//                 //       style: TextStyle(fontSize: 16), // Optional styling
//                 //     ),
//                 //     ElevatedButton(
//                 //       onPressed: _pickDate,
//                 //       child: const Text('Select Date'),
//                 //       style: ElevatedButton.styleFrom(
//                 //         primary: Theme.of(context).primaryColor,
//                 //         onPrimary: Colors.white,
//                 //         shape: RoundedRectangleBorder(
//                 //           borderRadius: BorderRadius.circular(30),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//                 SizedBox(height: 10), // Spacing between elements
//                 EasyDateTimeLine(
//                   initialDate: DateTime.now(),
//                   onDateChange: (selectedDate) {
//                     changeDateTime(selectedDate);
//                     //`selectedDate` the new date selected.
//                   },
//                   dayProps: const EasyDayProps(
//                     height: 56.0,
//                     width: 56.0,
//                     dayStructure: DayStructure.dayNumDayStr,
//                     inactiveDayStyle: DayStyle(
//                       borderRadius: 48.0,
//                       dayNumStyle: TextStyle(
//                         fontSize: 18.0,
//                       ),
//                     ),
//                     activeDayStyle: DayStyle(
//                       dayNumStyle: TextStyle(
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                   ),
//                   headerProps: const EasyHeaderProps(
//                     // showHeader: false,
//                     monthPickerType: MonthPickerType.switcher,
//                     selectedDateFormat: SelectedDateFormat.fullDateDMY,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 _buildSlidableBoxGroup(),
//                 SizedBox(height: 10),
//                 // For Accelerometer Data
//                 _controller.accData.isNotEmpty
//                     ? buildChartBox('Accelerometer Data', _controller.accData)
//                     : SizedBox.shrink(), // or Container()

//                 SizedBox(height: 10),

//                 // For Gyroscope Data
//                 // Assuming you have a separate list for gyroscope data
//                 _controller.accData.isNotEmpty
//                     ? buildChartBox('Gyroscope Data', _controller.accData)
//                     : SizedBox.shrink(), // or Container()

//                 // ... [Additional content as needed] ...
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //       body: Obx(
//   //     () => Column(
//   //       children: <Widget>[
//   //         ElevatedButton(
//   //           onPressed: _pickDate,
//   //           child: Text('Select Date'),
//   //         ),
//   //         EasyDateTimeLine(
//   //           initialDate: DateTime.now(),
//   //           onDateChange: (selectedDate) {
//   //             //`selectedDate` the new date selected.
//   //           },
//   //           headerProps: const EasyHeaderProps(
//   //             monthPickerType: MonthPickerType.switcher,
//   //             selectedDateFormat: SelectedDateFormat.fullDateDMY,
//   //           ),
//   //           dayProps: const EasyDayProps(
//   //             dayStructure: DayStructure.dayStrDayNum,
//   //             activeDayStyle: DayStyle(
//   //               decoration: BoxDecoration(
//   //                 borderRadius: BorderRadius.all(Radius.circular(8)),
//   //                 gradient: LinearGradient(
//   //                   begin: Alignment.topCenter,
//   //                   end: Alignment.bottomCenter,
//   //                   colors: [
//   //                     Color(0xff3371FF),
//   //                     Color(0xff8426D6),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //         _buildSlidableBoxGroup(),
//   //         // _buildRangeSelector(),
//   //         buildChartBox('Accelerometer Data', _controller.accData),
//   //         ElevatedButton(
//   //           onPressed: _controller.refreshDateTime,
//   //           child: const Text('test'),
//   //         ),

//   //         // Repeat for Gyroscope Data
//   //       ],
//   //     ),
//   //   ));
//   // }

//   // Include _buildChartBox and other necessary methods
// }
