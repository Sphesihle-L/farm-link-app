import '../models/app_user.dart';
import '../models/job.dart';
import '../models/job_application.dart';

abstract class DataService {
  // --- Auth & User ---
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> register(
    String name,
    String email,
    String password,
    String phone,
    UserRole role,
  );
  Future<void> signOut();
  Future<void> updateUserProfile(AppUser user);
  Future<void> sendEmailVerification();
  // --- Jobs ---
  Future<Job> createJob(Job job);
  Future<List<Job>> getOpenJobs();
  Future<List<Job>> getFarmerJobs(String farmerId);
  Future<Job?> getJobById(String jobId);
  Future<void> updateJobStatus(String jobId, JobStatus status);

  // --- Applications ---
  Future<JobApplication> applyForJob(JobApplication application);
  Future<List<JobApplication>> getWorkerApplications(String workerId);
  Future<List<JobApplication>> getJobApplications(String jobId);
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  );
}
