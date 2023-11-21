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

List<String> physicalClassesWithRespiratory = [
  'Lying down on back',
  'Lying down on left',
  'Lying down on right',
  'Lying down on stomach',
  'Sitting/standing',
];

List<String> allClasses = [
  'Ascending stairs',
  'Descending stairs',
  'Lying down on back - Breathing Normal',
  'Lying down on back - Coughing',
  'Lying down on back - Hyperventilating',
  'Lying down on back - Other',
  'Lying down on left - Breathing Normal',
  'Lying down on left - Coughing',
  'Lying down on left - Hyperventilating',
  'Lying down on left - Other',
  'Lying down on right - Breathing Normal',
  'Lying down on right - Coughing',
  'Lying down on right - Hyperventilating',
  'Lying down on right - Other',
  'Lying down on stomach - Breathing Normal',
  'Lying down on stomach - Coughing',
  'Lying down on stomach - Hyperventilating',
  'Lying down on stomach - Other',
  'Miscellaneous movements',
  'Normal walking',
  'Running',
  'Shuffle walking',
  'Sitting/standing : Breathing Normal',
  'Sitting/standing : Coughing',
  'Sitting/standing : Hyperventilating',
  'Sitting/standing : Other'
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
  String processedActivityName = activityName.contains(' - ')
      ? activityName.split(' - ')[0]
      : activityName;

  return activities
      .firstWhere((activity) => activity.name == processedActivityName,
          orElse: () => Activity(
              name: '', color: Colors.blue, icon: Icons.hourglass_empty))
      .color;
}

Widget getActivityIcon(String activityName) {
  String processedActivityName = activityName.contains(' - ')
      ? activityName.split(' - ')[0]
      : activityName;

  var activity = activities.firstWhere(
      (activity) => activity.name == processedActivityName,
      orElse: () =>
          Activity(name: '', color: Colors.blue, icon: Icons.hourglass_empty));

  return Icon(activity.icon, size: 30, color: activity.color);
}

List<String> combinedClasses = [
  'Lying down on back_Breathing Normal', //0
  'Lying down on back_Coughing', //1
  'Lying down on back_Hyperventilating', //2
  'Lying down on back_Other', //3
  'Lying down on left_Breathing Normal', //4
  'Lying down on left_Coughing', //5
  'Lying down on left_Hyperventilating', //6
  'Lying down on left_Other', //7
  'Lying down on right_Breathing Normal', //8
  'Lying down on right_Coughing',
  'Lying down on right_Hyperventilating',
  'Lying down on right_Other',
  'Lying down on stomach_Breathing Normal',
  'Lying down on stomach_Coughing',
  'Lying down on stomach_Hyperventilating',
  'Lying down on stomach_Other',
  'Sitting/standing_Breathing Normal',
  'Sitting/standing_Coughing',
  'Sitting/standing_Hyperventilating',
  'Sitting/standing_Other'
];

List<String> respiratoryClasses = [
  'Breathing Normal',
  'Coughing',
  'Hyperventilating',
  'Other',
];
