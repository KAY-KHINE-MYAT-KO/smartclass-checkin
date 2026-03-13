import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInData {
  final String studentId;
  final String classId;
  final DateTime checkinTimestamp;
  final double? checkinLatitude;
  final double? checkinLongitude;
  final String previousTopic;
  final String expectedTopic;
  final int mood;

  CheckInData({
    required this.studentId,
    required this.classId,
    required this.checkinTimestamp,
    this.checkinLatitude,
    this.checkinLongitude,
    required this.previousTopic,
    required this.expectedTopic,
    required this.mood,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'checkinTimestamp': checkinTimestamp,
      'checkinGps': checkinLatitude != null && checkinLongitude != null
          ? GeoPoint(checkinLatitude!, checkinLongitude!)
          : null,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'mood': mood,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class ClassCompletionData {
  final String studentId;
  final String classId;
  final DateTime completionTimestamp;
  final double? completionLatitude;
  final double? completionLongitude;
  final String learnedToday;
  final String feedback;

  ClassCompletionData({
    required this.studentId,
    required this.classId,
    required this.completionTimestamp,
    this.completionLatitude,
    this.completionLongitude,
    required this.learnedToday,
    required this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'completionTimestamp': completionTimestamp,
      'completionGps': completionLatitude != null && completionLongitude != null
          ? GeoPoint(completionLatitude!, completionLongitude!)
          : null,
      'learnedToday': learnedToday,
      'feedback': feedback,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
