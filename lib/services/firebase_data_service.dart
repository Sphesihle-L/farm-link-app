import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../models/app_user.dart';
import '../models/job.dart';
import '../models/job_application.dart';
import 'data_service.dart';

class FirebaseDataService implements DataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  final String _usersCollection = 'users';
  final String _jobsCollection = 'jobs';
  final String _appsCollection = 'applications';

  @override
  Future<AppUser?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore
        .collection(_usersCollection)
        .doc(currentUser.uid)
        .get();
    if (!doc.exists) return null;

    return AppUser.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password.trim(),
      );

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .get();
      if (!doc.exists) throw Exception("User profile not found.");

      return AppUser.fromMap(doc.id, doc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Invalid email or password');
      }
      throw Exception(e.message ?? 'Authentication failed');
    }
  }

  @override
  Future<AppUser> register(
    String name,
    String email,
    String password,
    String phone,
    UserRole role,
  ) async {
    try {
      // 1. Create Auth Account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password.trim(),
      );

      // 2. Create User Document in Firestore
      final newUser = AppUser(
        id: credential.user!.uid,
        displayName: name.trim(),
        role: role,
        phone: phone.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_usersCollection)
          .doc(newUser.id)
          .set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Email already in use');
      }
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> updateUserProfile(AppUser user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .update(user.toMap());
  }

  @override
  Future<Job> createJob(Job job) async {
    await _firestore.collection(_jobsCollection).doc(job.id).set(job.toMap());
    return job;
  }

  @override
  Future<List<Job>> getOpenJobs() async {
    final snapshot = await _firestore
        .collection(_jobsCollection)
        .where('status', isEqualTo: 'open')
        .get();

    return snapshot.docs.map((doc) => Job.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Future<List<Job>> getFarmerJobs(String farmerId) async {
    final snapshot = await _firestore
        .collection(_jobsCollection)
        .where('farmerId', isEqualTo: farmerId)
        .get();

    return snapshot.docs.map((doc) => Job.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Future<Job?> getJobById(String jobId) async {
    final doc = await _firestore.collection(_jobsCollection).doc(jobId).get();
    if (!doc.exists) return null;
    return Job.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    await _firestore.collection(_jobsCollection).doc(jobId).update({
      'status': jobStatusToDb(status),
    });
  }

  @override
  Future<JobApplication> applyForJob(JobApplication app) async {
    // Using the deterministic ID prevents duplicate applications automatically!
    await _firestore.collection(_appsCollection).doc(app.id).set(app.toMap());
    return app;
  }

  @override
  Future<List<JobApplication>> getWorkerApplications(String workerId) async {
    final snapshot = await _firestore
        .collection(_appsCollection)
        .where('workerId', isEqualTo: workerId)
        .get();

    return snapshot.docs
        .map((doc) => JobApplication.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<JobApplication>> getJobApplications(String jobId) async {
    final snapshot = await _firestore
        .collection(_appsCollection)
        .where('jobId', isEqualTo: jobId)
        .get();

    return snapshot.docs
        .map((doc) => JobApplication.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    await _firestore.collection(_appsCollection).doc(applicationId).update({
      'status': applicationStatusToDb(status),
    });
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
