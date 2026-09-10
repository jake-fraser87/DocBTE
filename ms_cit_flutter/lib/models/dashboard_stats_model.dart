class DeskSplit {
  final int deskOne;
  final int deskTwo;

  const DeskSplit({required this.deskOne, required this.deskTwo});

  int get total => deskOne + deskTwo;
}

class DashboardStatsModel {
  final int totalRequests;
  final DeskSplit pending;
  final DeskSplit approved;
  final DeskSplit rejected;
  final DeskSplit partiallyApproved;

  const DashboardStatsModel({
    required this.totalRequests,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.partiallyApproved,
  });
}
