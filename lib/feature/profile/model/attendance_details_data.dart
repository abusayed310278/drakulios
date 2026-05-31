class AttendanceDetailsData {
  const AttendanceDetailsData({
    required this.profile,
    required this.name,
    required this.memberId,
    required this.avatarUrl,
    required this.totalVisits,
    required this.avgStayMinutes,
    required this.lastVisitText,
    required this.activeDays,
    required this.missedDays,
    required this.dayDetails,
  });

  final Map<String, dynamic> profile;
  final String name;
  final String memberId;
  final String avatarUrl;
  final int totalVisits;
  final int avgStayMinutes;
  final String lastVisitText;
  final Set<int> activeDays;
  final Set<int> missedDays;
  final Map<String, Map<String, dynamic>> dayDetails;
}
