import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/request_model.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;

  const RequestCard({super.key, required this.request});

  Color get _accent {
    switch (request.status) {
      case RequestStatus.pending:
        return AppColors.amber;
      case RequestStatus.approved:
        return AppColors.green;
      case RequestStatus.rejected:
        return AppColors.red;
      case RequestStatus.partiallyApproved:
        return AppColors.teal;
    }
  }

  Color get _accentSoft {
    switch (request.status) {
      case RequestStatus.pending:
        return AppColors.amberSoft;
      case RequestStatus.approved:
        return AppColors.greenSoft;
      case RequestStatus.rejected:
        return AppColors.redSoft;
      case RequestStatus.partiallyApproved:
        return AppColors.tealSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm:ss a');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          top: const BorderSide(color: AppColors.line),
          right: const BorderSide(color: AppColors.line),
          bottom: const BorderSide(color: AppColors.line),
          left: BorderSide(color: _accent, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sr. #${request.srNo}  •  Req ID: ${request.reqId}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _accentSoft, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  request.status.label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(request.corporation, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 2),
          Text(dateFmt.format(request.date), style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('DESK-I: ${request.deskOneCount}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
              const SizedBox(width: 14),
              Text('DESK-II: ${request.deskTwoCount}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
            ],
          ),
        ],
      ),
    );
  }
}
