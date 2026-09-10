enum RequestStatus { pending, approved, rejected, partiallyApproved }

extension RequestStatusX on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'PENDING';
      case RequestStatus.approved:
        return 'APPROVED';
      case RequestStatus.rejected:
        return 'REJECTED';
      case RequestStatus.partiallyApproved:
        return 'PARTIALLY APPROVED';
    }
  }
}

class RequestModel {
  final int srNo;
  final String reqId;
  final RequestStatus status;
  final String corporation;
  final DateTime date;
  final int deskOneCount;
  final int deskTwoCount;

  const RequestModel({
    required this.srNo,
    required this.reqId,
    required this.status,
    required this.corporation,
    required this.date,
    required this.deskOneCount,
    required this.deskTwoCount,
  });
}
