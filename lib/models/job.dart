import 'package:intl/intl.dart';

enum JobStatus { open, filled, closed, cancelled }

String jobStatusToDb(JobStatus s) => switch (s) {
      JobStatus.open => 'open',
      JobStatus.filled => 'filled',
      JobStatus.closed => 'closed',
      JobStatus.cancelled => 'cancelled',
    };

String jobStatusLabel(JobStatus s) => switch (s) {
      JobStatus.open => 'Open',
      JobStatus.filled => 'Filled',
      JobStatus.closed => 'Closed',
      JobStatus.cancelled => 'Cancelled',
    };

JobStatus jobStatusFromDb(String? v) => JobStatus.values.firstWhere(
      (s) => jobStatusToDb(s) == v,
      orElse: () => JobStatus.open,
    );

enum PayBasis { perHour, perDay, perJob, toBeDiscussed }

String payBasisToDb(PayBasis p) => switch (p) {
      PayBasis.perHour => 'per_hour',
      PayBasis.perDay => 'per_day',
      PayBasis.perJob => 'per_job',
      PayBasis.toBeDiscussed => 'to_be_discussed',
    };

String payBasisLabel(PayBasis p) => switch (p) {
      PayBasis.perHour => 'per hour',
      PayBasis.perDay => 'per day',
      PayBasis.perJob => 'per job',
      PayBasis.toBeDiscussed => 'to be discussed',
    };

PayBasis payBasisFromDb(String? v) => PayBasis.values.firstWhere(
      (p) => payBasisToDb(p) == v,
      orElse: () => PayBasis.toBeDiscussed,
    );

class Job {
  final String id;
  final String farmerId;
  final String farmerName; // denormalised for display
  final String title;
  final String description;
  final String area;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime; // "07:00"
  final String endTime;
  final int workersNeeded;
  final double? payAmount;
  final PayBasis payBasis;
  final List<String> requirements;
  final String contactInstructions;
  final JobStatus status;
  final DateTime createdAt;

  const Job({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.title,
    this.description = '',
    required this.area,
    required this.startDate,
    required this.endDate,
    this.startTime = '',
    this.endTime = '',
    required this.workersNeeded,
    this.payAmount,
    this.payBasis = PayBasis.toBeDiscussed,
    this.requirements = const [],
    this.contactInstructions = '',
    this.status = JobStatus.open,
    required this.createdAt,
  });

  String get payDisplay {
    if (payBasis == PayBasis.toBeDiscussed || payAmount == null) {
      return 'Pay: to be discussed';
    }
    final amount = payAmount! % 1 == 0
        ? payAmount!.toStringAsFixed(0)
        : payAmount!.toStringAsFixed(2);
    return 'R$amount ${payBasisLabel(payBasis)}';
  }

  String get dateRangeDisplay {
    final f = DateFormat('d MMM');
    return startDate == endDate
        ? f.format(startDate)
        : '${f.format(startDate)} – ${f.format(endDate)}';
  }

  Map<String, dynamic> toMap() => {
        'farmerId': farmerId,
        'farmerName': farmerName,
        'title': title,
        'description': description,
        'area': area,
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'workersNeeded': workersNeeded,
        'payAmount': payAmount,
        'payBasis': payBasisToDb(payBasis),
        'requirements': requirements,
        'contactInstructions': contactInstructions,
        'status': jobStatusToDb(status),
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory Job.fromMap(String id, Map<String, dynamic> m) => Job(
        id: id,
        farmerId: m['farmerId'] as String? ?? '',
        farmerName: m['farmerName'] as String? ?? '',
        title: m['title'] as String? ?? '',
        description: m['description'] as String? ?? '',
        area: m['area'] as String? ?? '',
        startDate:
            DateTime.tryParse(m['startDate'] as String? ?? '') ?? DateTime.now(),
        endDate:
            DateTime.tryParse(m['endDate'] as String? ?? '') ?? DateTime.now(),
        startTime: m['startTime'] as String? ?? '',
        endTime: m['endTime'] as String? ?? '',
        workersNeeded: (m['workersNeeded'] as num?)?.toInt() ?? 1,
        payAmount: (m['payAmount'] as num?)?.toDouble(),
        payBasis: payBasisFromDb(m['payBasis'] as String?),
        requirements:
            (m['requirements'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        contactInstructions: m['contactInstructions'] as String? ?? '',
        status: jobStatusFromDb(m['status'] as String?),
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}