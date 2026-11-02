enum ApplicationStatus { pending, selected, notSelected, withdrawn, jobClosed }

String applicationStatusToDb(ApplicationStatus s) => switch (s) {
      ApplicationStatus.pending => 'pending',
      ApplicationStatus.selected => 'selected',
      ApplicationStatus.notSelected => 'not_selected',
      ApplicationStatus.withdrawn => 'withdrawn',
      ApplicationStatus.jobClosed => 'job_closed',
    };

String applicationStatusLabel(ApplicationStatus s) => switch (s) {
      ApplicationStatus.pending => 'Pending',
      ApplicationStatus.selected => 'Selected',
      ApplicationStatus.notSelected => 'Not selected',
      ApplicationStatus.withdrawn => 'Withdrawn',
      ApplicationStatus.jobClosed => 'Job closed',
    };

ApplicationStatus applicationStatusFromDb(String? v) =>
    ApplicationStatus.values.firstWhere(
      (s) => applicationStatusToDb(s) == v,
      orElse: () => ApplicationStatus.pending,
    );

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String farmerId;
  final String workerName; // denormalised
  final String workerPhone;
  final String workerSkills;
  final String jobTitle; // denormalised, for My Applications list
  final String note;
  final ApplicationStatus status;
  final DateTime appliedAt;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.farmerId,
    this.workerName = '',
    this.workerPhone = '',
    this.workerSkills = '',
    this.jobTitle = '',
    this.note = '',
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
  });

  Map<String, dynamic> toMap() => {
        'jobId': jobId,
        'workerId': workerId,
        'farmerId': farmerId,
        'workerName': workerName,
        'workerPhone': workerPhone,
        'workerSkills': workerSkills,
        'jobTitle': jobTitle,
        'note': note,
        'status': applicationStatusToDb(status),
        'appliedAt': appliedAt.toUtc().toIso8601String(),
      };

  factory JobApplication.fromMap(String id, Map<String, dynamic> m) =>
      JobApplication(
        id: id,
        jobId: m['jobId'] as String? ?? '',
        workerId: m['workerId'] as String? ?? '',
        farmerId: m['farmerId'] as String? ?? '',
        workerName: m['workerName'] as String? ?? '',
        workerPhone: m['workerPhone'] as String? ?? '',
        workerSkills: m['workerSkills'] as String? ?? '',
        jobTitle: m['jobTitle'] as String? ?? '',
        note: m['note'] as String? ?? '',
        status: applicationStatusFromDb(m['status'] as String?),
        appliedAt:
            DateTime.tryParse(m['appliedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
