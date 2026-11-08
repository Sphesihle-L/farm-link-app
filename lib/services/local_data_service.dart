import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/job.dart';
import '../models/job_application.dart';
import 'data_service.dart';

class LocalDataService implements DataService {
  static const _usersKey = 'farmlink_users';
  static const _jobsKey = 'farmlink_jobs';
  static const _appsKey = 'farmlink_applications';
  static const _currentUserKey = 'farmlink_current_user_id';

  // Helper to get all users
  Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_usersKey);
    if (str == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(str));
  }

  // Helper to save all users
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    if (userId == null) return null;

    final users = await _getUsers();
    final userMap = users.firstWhere(
      (u) => u['user']['id'] == userId,
      orElse: () => {},
    );
    if (userMap.isEmpty) return null;

    return AppUser.fromMap(userId, userMap['user']);
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    final users = await _getUsers();

    // Make email lowercase and trim spaces
    final cleanEmail = email.toLowerCase().trim();
    final cleanPassword = password.trim();

    final existing = users.firstWhere(
      (u) => u['email'] == cleanEmail && u['password'] == cleanPassword,
      orElse: () => {},
    );

    if (existing.isEmpty) throw Exception('Invalid email or password');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, existing['user']['id']);
    return AppUser.fromMap(existing['user']['id'], existing['user']);
  }

  @override
  Future<AppUser> register(
    String name,
    String email,
    String password,
    String phone,
    UserRole role,
  ) async {
    final users = await _getUsers();

    // Make email lowercase and trim spaces
    final cleanEmail = email.toLowerCase().trim();
    final cleanPassword = password.trim();

    if (users.any((u) => u['email'] == cleanEmail)) {
      throw Exception('Email already in use');
    }

    final newUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: name.trim(),
      role: role,
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );

    users.add({
      'email': cleanEmail,
      'password': cleanPassword,
      'user': newUser.toMap()..['id'] = newUser.id,
    });
    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, newUser.id);
    return newUser;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  @override
  Future<void> updateUserProfile(AppUser user) async {
    final users = await _getUsers();
    final index = users.indexWhere((u) => u['user']['id'] == user.id);
    if (index != -1) {
      users[index]['user'] = user.toMap()..['id'] = user.id;
      await _saveUsers(users);
    }
  }

  @override
  Future<Job> createJob(Job job) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_jobsKey);
    final jobs = str == null
        ? []
        : List<Map<String, dynamic>>.from(jsonDecode(str));

    jobs.add(job.toMap()..['id'] = job.id);
    await prefs.setString(_jobsKey, jsonEncode(jobs));
    return job;
  }

  @override
  Future<List<Job>> getOpenJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_jobsKey);
    if (str == null) return [];

    final jobs = List<Map<String, dynamic>>.from(jsonDecode(str));
    return jobs
        .where((j) => j['status'] == 'open')
        .map((j) => Job.fromMap(j['id'], j))
        .toList();
  }

  @override
  Future<List<Job>> getFarmerJobs(String farmerId) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_jobsKey);
    if (str == null) return [];

    final jobs = List<Map<String, dynamic>>.from(jsonDecode(str));
    return jobs
        .where((j) => j['farmerId'] == farmerId)
        .map((j) => Job.fromMap(j['id'], j))
        .toList();
  }

  @override
  Future<Job?> getJobById(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_jobsKey);
    if (str == null) return null;

    final jobs = List<Map<String, dynamic>>.from(jsonDecode(str));
    final jobMap = jobs.firstWhere((j) => j['id'] == jobId, orElse: () => {});
    if (jobMap.isEmpty) return null;
    return Job.fromMap(jobMap['id'], jobMap);
  }

  @override
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_jobsKey);
    if (str == null) return;

    final jobs = List<Map<String, dynamic>>.from(jsonDecode(str));
    final index = jobs.indexWhere((j) => j['id'] == jobId);
    if (index != -1) {
      jobs[index]['status'] = jobStatusToDb(status);
      await prefs.setString(_jobsKey, jsonEncode(jobs));
    }
  }

  @override
  Future<JobApplication> applyForJob(JobApplication app) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_appsKey);
    final apps = str == null
        ? []
        : List<Map<String, dynamic>>.from(jsonDecode(str));

    // Prevent duplicate applications
    if (apps.any(
      (a) => a['jobId'] == app.jobId && a['workerId'] == app.workerId,
    )) {
      throw Exception('You have already applied for this job.');
    }

    apps.add(app.toMap()..['id'] = app.id);
    await prefs.setString(_appsKey, jsonEncode(apps));
    return app;
  }

  @override
  Future<List<JobApplication>> getWorkerApplications(String workerId) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_appsKey);
    if (str == null) return [];

    final apps = List<Map<String, dynamic>>.from(jsonDecode(str));
    return apps
        .where((a) => a['workerId'] == workerId)
        .map((a) => JobApplication.fromMap(a['id'], a))
        .toList();
  }

  @override
  Future<List<JobApplication>> getJobApplications(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_appsKey);
    if (str == null) return [];

    final apps = List<Map<String, dynamic>>.from(jsonDecode(str));
    return apps
        .where((a) => a['jobId'] == jobId)
        .map((a) => JobApplication.fromMap(a['id'], a))
        .toList();
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_appsKey);
    if (str == null) return;

    final apps = List<Map<String, dynamic>>.from(jsonDecode(str));
    final index = apps.indexWhere((a) => a['id'] == applicationId);
    if (index != -1) {
      apps[index]['status'] = applicationStatusToDb(status);
      await prefs.setString(_appsKey, jsonEncode(apps));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    // Local storage doesn't send emails, so we do nothing here.
    // This is just to satisfy the DataService interface.
  }
}
