//Order matters
import 'dart:ui';

import 'package:flutter/material.dart';

class Activity {
  final String name;
  final Color color;
  final IconData icon;

  Activity({required this.name, required this.color, required this.icon});
}

List<String> physicalClasses = [
  'Ascending stairs',
  'Descending stairs',
  'Lying down on back',
  'Lying down on left',
  'Lying down on right',
  'Lying down on stomach',
  'Miscellaneous movements',
  'Normal walking',
  'Running',
  'Shuffle walking',
  'Sitting/standing',
];

List<Activity> activities = [
  Activity(
      name: 'Ascending stairs',
      color: Colors.deepOrange,
      icon: Icons.arrow_upward),
  Activity(
      name: 'Descending stairs',
      color: Colors.brown,
      icon: Icons.arrow_downward),
  Activity(
      name: 'Lying down on back', color: Colors.lightBlue, icon: Icons.bed),
  Activity(name: 'Lying down on left', color: Colors.purple, icon: Icons.bed),
  Activity(name: 'Lying down on right', color: Colors.pink, icon: Icons.bed),
  Activity(name: 'Lying down on stomach', color: Colors.teal, icon: Icons.bed),
  Activity(
      name: 'Miscellaneous movements', color: Colors.grey, icon: Icons.shuffle),
  Activity(
      name: 'Normal walking', color: Colors.green, icon: Icons.directions_walk),
  Activity(name: 'Running', color: Colors.red, icon: Icons.directions_run),
  Activity(
      name: 'Shuffle walking',
      color: Colors.amber,
      icon: Icons.transfer_within_a_station),
  Activity(
      name: 'Sitting/standing', color: Colors.indigo, icon: Icons.event_seat)
];

Color getActivityColor(String activityName) {
  return activities
      .firstWhere((activity) => activity.name == activityName,
          orElse: () => Activity(
              name: '', color: Colors.blue, icon: Icons.hourglass_empty))
      .color;
}

Widget getActivityIcon(String activityName) {
  var activity = activities.firstWhere(
      (activity) => activity.name == activityName,
      orElse: () =>
          Activity(name: '', color: Colors.blue, icon: Icons.hourglass_empty));
  return Icon(activity.icon, size: 30, color: activity.color);
}

// Function to get dynamic border color based on activity
// Function to get dynamic border color based on activity
// Color getActivityColor(String activity) {
//   switch (activity) {
//     case "Ascending stairs":
//       return Colors.deepOrange;
//     case "Descending stairs":
//       return Colors.brown;
//     case "Lying down on back":
//       return Colors.lightBlue;
//     case "Lying down on left":
//       return Colors.purple;
//     case "Lying down on right":
//       return Colors.pink;
//     case "Lying down on stomach":
//       return Colors.teal;
//     case "Miscellaneous movements":
//       return Colors.grey;
//     case "Normal walking":
//       return Colors.green;
//     case "Running":
//       return Colors.red;
//     case "Shuffle walking":
//       return Colors.amber;
//     case "Sitting/standing":
//       return Colors.indigo;
//     default:
//       return Colors.blue; // Default color when no specific activity is detected
//   }
// }

// Widget getActivityIcon(String activity) {
//   IconData icon;
//   switch (activity) {
//     case "Ascending stairs":
//       icon = Icons.arrow_upward;
//       break;
//     case "Descending stairs":
//       icon = Icons.arrow_downward;
//       break;
//     case "Lying down back":
//     case "Lying down on left":
//     case "Lying down right":
//     case "Lying down on stomach":
//       icon = Icons.bed;
//       break;
//     case "Miscellaneous movements":
//       icon = Icons.shuffle;
//       break;
//     case "Normal walking":
//       icon = Icons.directions_walk;
//       break;
//     case "Running":
//       icon = Icons.directions_run;
//       break;
//     case "Shuffle walking":
//       icon = Icons.transfer_within_a_station;
//       break;
//     case "Sitting/standing":
//       icon = Icons.event_seat;
//       break;
//     default:
//       icon = Icons.help_outline;
//   }
//   return Icon(icon, size: 30, color: getActivityColor(activity));
// }

List<String> combinedClasses = [
  'Lying down on right_Coughing',
  'Lying down on stomach_Hyperventilating',
  'Lying down on back_Breathing Normal',
  'Lying down on back_Hyperventilating',
  'Lying down on stomach_Breathing Normal',
  'Lying down on left_Breathing Normal',
  'Lying down on right_Hyperventilating',
  'Lying down on left_Other',
  'Lying down on back_Coughing',
  'Sitting/standing_Breathing Normal',
  'Sitting/standing_Other',
  'Lying down on left_Coughing',
  'Lying down on right_Breathing Normal',
  'Lying down on stomach_Other',
  'Lying down on right_Other',
  'Sitting/standing_Coughing',
  'Lying down on back_Other',
  'Lying down on left_Hyperventilating',
  'Sitting/standing_Hyperventilating',
  'Lying down on stomach_Coughing'
];

List<String> respiratoryClasses = [
  'Coughing',
  'Hyperventilating',
  'Other',
  'Breathing Normal'
];
