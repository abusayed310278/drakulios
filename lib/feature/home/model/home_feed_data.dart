class HomeFeedData {
  const HomeFeedData({
    required this.items,
    this.serverDate,
  });

  final List<Map<String, dynamic>> items;
  final DateTime? serverDate;
}
