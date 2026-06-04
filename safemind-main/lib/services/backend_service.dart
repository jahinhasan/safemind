import 'dart:math';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/app_user.dart';
import '../models/admin_activity_item.dart';
import '../models/comment_item.dart';
import '../models/message_item.dart';
import '../models/post_item.dart';
import '../models/report_item.dart';

class SafeMindBackend {
  SafeMindBackend._() {
    _seedDemoData();
  }

  static final SafeMindBackend instance = SafeMindBackend._();

  final StreamController<SafeMindUser?> _authUpdates = StreamController<SafeMindUser?>.broadcast();
  final StreamController<List<SafeMindPost>> _postUpdates = StreamController<List<SafeMindPost>>.broadcast();
  final StreamController<List<SafeMindReport>> _reportUpdates = StreamController<List<SafeMindReport>>.broadcast();
  final StreamController<List<SafeMindUser>> _userUpdates = StreamController<List<SafeMindUser>>.broadcast();
  final StreamController<List<SafeMindAdminActivity>> _activityUpdates = StreamController<List<SafeMindAdminActivity>>.broadcast();
  final Map<String, StreamController<List<SafeMindComment>>> _commentUpdates = {};
  final Map<String, StreamController<List<SafeMindMessage>>> _messageUpdates = {};
  final StreamController<List<SafeMindConversation>> _conversationUpdates = StreamController<List<SafeMindConversation>>.broadcast();

  SafeMindUser? _demoUser;
  final List<SafeMindUser> _demoUsers = [];
  final List<SafeMindPost> _demoPosts = [];
  final Map<String, List<SafeMindComment>> _demoComments = {};
  final List<SafeMindReport> _demoReports = [];
  final List<SafeMindAdminActivity> _demoActivities = [];
  final List<SafeMindMessage> _demoMessages = [];
  final List<SafeMindConversation> _demoConversations = [];

  bool get _usesFirebase => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _auth => _usesFirebase ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore => _usesFirebase ? FirebaseFirestore.instance : null;

  Stream<SafeMindUser?> authStateChanges() async* {
    if (_usesFirebase) {
      // Listen to auth state changes and, when signed in, stream the user's
      // Firestore document so updates (like role changes) are reflected live.
      yield* _auth!.authStateChanges().asyncExpand((user) {
        // ignore: avoid_print
        print('Auth state changed: user=${user?.uid}');
        if (user == null) {
          return Stream<SafeMindUser?>.value(null);
        }

        try {
          // Create a default user first to show immediately
          final defaultUser = SafeMindUser(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email,
            role: 'user',
            isAnonymous: user.isAnonymous,
          );
          
          // Use StreamController to manage multiple stream sources
          final controller = StreamController<SafeMindUser?>();
          
          // Emit default user immediately
          controller.add(defaultUser);
          
          // Subscribe to Firestore document updates
          final subscription = _firestore!.collection('users').doc(user.uid).snapshots().listen(
            (doc) {
              final data = doc.data();
              if (data == null) {
                // ignore: avoid_print
                print('User doc is null for ${user.uid}, using default user');
                controller.add(defaultUser);
              } else {
                // ignore: avoid_print
                print('User doc loaded for ${user.uid}: role=${data['role']}');
                final updatedUser = _userFromMap(user.uid, data).copyWith(
                  name: (data['name'] as String?) ?? user.displayName ?? (user.isAnonymous ? 'Anonymous User' : user.email?.split('@').first ?? 'User'),
                  email: user.email,
                  isAnonymous: (data['isAnonymous'] as bool?) ?? user.isAnonymous,
                );
                controller.add(updatedUser);
              }
            },
            onError: (error) {
              // ignore: avoid_print
              print('Error listening to user doc: $error');
              controller.add(defaultUser);
            },
          );
          
          // Clean up subscription when controller is closed
          controller.onCancel = () => subscription.cancel();
          
          return controller.stream;
        } catch (e) {
          // ignore: avoid_print
          print('Error in authStateChanges: $e');
          // Return a stream with a default user if Firestore listener fails
          return Stream<SafeMindUser?>.value(
            SafeMindUser(
              id: user.uid,
              name: user.displayName ?? 'User',
              email: user.email,
              role: 'user',
              isAnonymous: user.isAnonymous,
            ),
          );
        }
      });
      return;
    }

    yield _demoUser;
    yield* _authUpdates.stream;
  }

  Stream<List<SafeMindPost>> watchPosts() async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.where((doc) => (doc.data()['removed'] as bool?) != true).map((doc) => _postFromMap(doc.id, doc.data())).toList());
      return;
    }

    yield List<SafeMindPost>.unmodifiable(_sortedPosts(_demoPosts));
    yield* _postUpdates.stream;
  }

  Stream<List<SafeMindPost>> watchPostsByAuthor(String authorId) async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('posts')
          .where('authorId', isEqualTo: authorId)
          .snapshots()
          .map((snapshot) {
            final posts = snapshot.docs
                .where((doc) => (doc.data()['removed'] as bool?) != true)
                .map((doc) => _postFromMap(doc.id, doc.data()))
                .toList();
            posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return posts;
          });
      return;
    }

    final posts = _demoPosts.where((post) => post.authorId == authorId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield List<SafeMindPost>.unmodifiable(posts);
    yield* _postUpdates.stream.map((posts) {
      final authoredPosts = posts.where((post) => post.authorId == authorId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return List<SafeMindPost>.unmodifiable(authoredPosts);
    });
  }

  Stream<SafeMindPost?> watchPost(String postId) async* {
    if (_usesFirebase) {
      yield* _firestore!.collection('posts').doc(postId).snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data == null || (data['removed'] as bool?) == true) {
          return null;
        }
        return _postFromMap(snapshot.id, data);
      });
      return;
    }

    yield _findPost(postId);
    yield* _postUpdates.stream.map((posts) => _findPost(postId));
  }

  Future<SafeMindPost?> getPost(String postId) async {
    if (_usesFirebase) {
      final snapshot = await _firestore!.collection('posts').doc(postId).get();
      final data = snapshot.data();
      if (data == null || (data['removed'] as bool?) == true) {
        return null;
      }
      return _postFromMap(snapshot.id, data);
    }

    return _findPost(postId);
  }

  Stream<List<SafeMindComment>> watchComments(String postId) async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt')
          .snapshots()
          .map((snapshot) => snapshot.docs.where((doc) => (doc.data()['removed'] as bool?) != true).map((doc) => _commentFromMap(doc.id, postId, doc.data())).toList());
      return;
    }

    yield List<SafeMindComment>.unmodifiable(_demoComments[postId] ?? const <SafeMindComment>[]);
    yield* _commentStreamFor(postId).stream;
  }

  Stream<List<SafeMindComment>> watchCommentsByAuthor(String authorId) async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collectionGroup('comments')
          .where('authorId', isEqualTo: authorId)
          .snapshots()
          .map((snapshot) {
            final comments = snapshot.docs
                .where((doc) => (doc.data()['removed'] as bool?) != true)
                .map((doc) {
                  final postId = doc.reference.parent.parent?.id ?? '';
                  return _commentFromMap(doc.id, postId, doc.data());
                })
                .toList();
            comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return comments;
          });
      return;
    }

    final comments = _demoComments.values.expand((items) => items).where((comment) => comment.authorId == authorId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield List<SafeMindComment>.unmodifiable(comments);
    yield* _commentUpdates.values.isEmpty
        ? Stream<List<SafeMindComment>>.empty()
        : Stream.multi((controller) {
            for (final entry in _commentUpdates.entries) {
              entry.value.stream.listen((_) {
                final updatedComments = _demoComments.values.expand((items) => items).where((comment) => comment.authorId == authorId).toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                controller.add(List<SafeMindComment>.unmodifiable(updatedComments));
              });
            }
          });
  }

  Stream<List<SafeMindReport>> watchReports() async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => _reportFromMap(doc.id, doc.data())).toList());
      return;
    }

    yield List<SafeMindReport>.unmodifiable(_demoReports);
    yield* _reportUpdates.stream;
  }

  Stream<List<SafeMindUser>> watchUsers() async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => _userFromMap(doc.id, doc.data())).toList());
      return;
    }

    yield List<SafeMindUser>.unmodifiable(_demoUsers);
    yield* _userUpdates.stream;
  }

  Stream<List<SafeMindAdminActivity>> watchActivity() async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('adminActivity')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => _activityFromMap(doc.id, doc.data())).toList());
      return;
    }

    yield List<SafeMindAdminActivity>.unmodifiable(_demoActivities);
    yield* _activityUpdates.stream;
  }

  Future<void> signInAnonymously() async {
    if (_usesFirebase) {
      final random = Random();
      final guestEmail = 'guest_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1 << 32)}@safemind.local';
      final guestPassword = 'guest_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1 << 32)}';
      final cred = await _auth!.createUserWithEmailAndPassword(email: guestEmail, password: guestPassword);
      await cred.user?.updateDisplayName('Anonymous User');
      await _ensureFirebaseUserDoc(cred.user, isAnonymous: true, displayName: 'Anonymous User');
      return;
    }

    _demoUser = const SafeMindUser(id: 'demo-anon', name: 'Anonymous User', email: null, role: 'user', isAnonymous: true);
    _syncDemoUser(_demoUser!);
    _authUpdates.add(_demoUser);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (_usesFirebase) {
      try {
        // ignore: avoid_print
        print('Attempting Firebase sign-in for: ${email.trim()}');
        final cred = await _auth!.signInWithEmailAndPassword(email: email.trim(), password: password);
        // ignore: avoid_print
        print('Firebase sign-in successful for: ${cred.user?.uid}');
        await _ensureFirebaseUserDoc(cred.user, isAnonymous: false);
        // ignore: avoid_print
        print('User document ensured, sign-in complete');
        return;
      } catch (e) {
        // ignore: avoid_print
        print('Firebase sign-in error: $e');
        rethrow;
      }
    }

    _demoUser = SafeMindUser(
      id: 'demo-${email.trim()}',
      name: email.trim().split('@').first,
      email: email.trim(),
      role: _roleForEmail(email.trim()),
      isAnonymous: false,
    );
    _syncDemoUser(_demoUser!);
    _authUpdates.add(_demoUser);
  }

  Future<void> signUpWithEmailAndPassword({required String name, required String email, required String password}) async {
    if (_usesFirebase) {
      final cred = await _auth!.createUserWithEmailAndPassword(email: email.trim(), password: password);
      if (cred.user != null) {
        await cred.user!.updateDisplayName(name.trim());
      }
      await _ensureFirebaseUserDoc(cred.user, isAnonymous: false, displayName: name.trim());
      return;
    }

    _demoUser = SafeMindUser(
      id: 'demo-${email.trim()}',
      name: name.trim().isEmpty ? email.trim().split('@').first : name.trim(),
      email: email.trim(),
      role: _roleForEmail(email.trim()),
      isAnonymous: false,
    );
    _syncDemoUser(_demoUser!);
    _authUpdates.add(_demoUser);
  }

  Future<void> signOut() async {
    if (_usesFirebase) {
      await _auth!.signOut();
      return;
    }

    _demoUser = null;
    _authUpdates.add(null);
  }

  Future<void> saveMood(int mood) async {
    final user = await currentUser();
    if (user == null) return;

    if (_usesFirebase) {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Save mood to user's mood tracking
      await _firestore!.collection('users').doc(user.id).collection('moods').doc(dateKey).set({
        'mood': mood,
        'moodLabel': ['Awful', 'Bad', 'Okay', 'Good', 'Great'][mood - 1],
        'date': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Also update user profile with today's mood
      await _firestore!.collection('users').doc(user.id).update({
        'todaysMood': mood,
        'todaysMoodLabel': ['Awful', 'Bad', 'Okay', 'Good', 'Great'][mood - 1],
        'lastMoodUpdate': FieldValue.serverTimestamp(),
      });
      return;
    }

    // Demo mode - store locally
    if (_demoUser != null) {
      _demoUser = _demoUser!.copyWith();
    }
  }

  Future<int?> getUserMood(String userId) async {
    if (_usesFirebase) {
      try {
        final userDoc = await _firestore!.collection('users').doc(userId).get();
        return userDoc.data()?['todaysMood'] as int?;
      } catch (e) {
        // ignore: avoid_print
        print('Error getting user mood: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> updateUserMoodInPost(String postId, int mood) async {
    if (_usesFirebase) {
      await _firestore!.collection('posts').doc(postId).update({'authorMood': mood});
      return;
    }

    _updateDemoPost(postId, (post) => post.copyWith(authorMood: mood));
  }

  Future<void> updateUserRole({required String userId, required String role}) async {
    if (_usesFirebase) {
      await _firestore!.collection('users').doc(userId).update({'role': role, 'updatedAt': FieldValue.serverTimestamp()});
      await _logActivity(action: 'Role updated', subject: userId, detail: 'Changed role to $role');
      return;
    }

    final index = _demoUsers.indexWhere((user) => user.id == userId);
    if (index == -1) return;
    _demoUsers[index] = _demoUsers[index].copyWith(role: role);
    _userUpdates.add(List<SafeMindUser>.unmodifiable(_demoUsers));
    await _logActivity(action: 'Role updated', subject: _demoUsers[index].name, detail: 'Changed role to $role');
  }

  Future<void> banUser(String userId, {bool banned = true}) async {
    if (_usesFirebase) {
      await _firestore!.collection('users').doc(userId).update({'isBanned': banned, 'moderationState': banned ? 'banned' : 'active', 'updatedAt': FieldValue.serverTimestamp()});
      await _logActivity(action: banned ? 'User banned' : 'User unbanned', subject: userId, detail: banned ? 'Account suspended by admin' : 'Account restored');
      return;
    }

    final index = _demoUsers.indexWhere((user) => user.id == userId);
    if (index == -1) return;
    _demoUsers[index] = _demoUsers[index].copyWith(isBanned: banned, moderationState: banned ? 'banned' : 'active');
    _userUpdates.add(List<SafeMindUser>.unmodifiable(_demoUsers));
    await _logActivity(action: banned ? 'User banned' : 'User unbanned', subject: _demoUsers[index].name, detail: banned ? 'Account suspended by admin' : 'Account restored');
  }

  Future<void> createPost({required String content, required String category, required bool anonymous}) async {
    final user = await currentUser();
    final authorName = anonymous || user?.isAnonymous == true ? 'Anonymous User' : (user?.name ?? 'Anonymous User');
    final authorId = user?.id ?? 'anonymous';
    final normalizedContent = content.trim();
    
    // Get user's current mood
    int? authorMood;
    if (user != null) {
      authorMood = await getUserMood(user.id);
    }

    if (_usesFirebase) {
      await _firestore!.collection('posts').add({
        'authorId': authorId,
        'authorName': authorName,
        'isAnonymous': anonymous || user?.isAnonymous == true,
        'content': normalizedContent,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'supportCount': 0,
        'commentCount': 0,
        'solved': false,
        'bestCommentId': null,
        'hasAdvisorResponse': false,
        'authorMood': authorMood,
      });
      if (user != null) {
        await _firestore!.collection('users').doc(user.id).set({'postCount': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      }
      await _logActivity(action: 'New post created', subject: authorName, detail: 'Category: $category');
      return;
    }

    final post = SafeMindPost(
      id: 'demo-post-${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      authorName: authorName,
      isAnonymous: anonymous || user?.isAnonymous == true,
      content: normalizedContent,
      category: category,
      createdAt: DateTime.now(),
      supportCount: 0,
      commentCount: 0,
      solved: false,
      bestCommentId: null,
      hasAdvisorResponse: false,
      authorMood: authorMood,
    );

    _demoPosts.insert(0, post);
    _incrementDemoPostCount(authorId);
    _postUpdates.add(List<SafeMindPost>.unmodifiable(_sortedPosts(_demoPosts)));
    await _logActivity(action: 'New post created', subject: authorName, detail: 'Category: $category');
  }

  Future<void> supportPost(String postId) async {
    if (_usesFirebase) {
      await _firestore!.collection('posts').doc(postId).update({'supportCount': FieldValue.increment(1)});
      return;
    }

    final index = _demoPosts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      return;
    }

    _demoPosts[index] = _demoPosts[index].copyWith(supportCount: _demoPosts[index].supportCount + 1);
    _postUpdates.add(List<SafeMindPost>.unmodifiable(_sortedPosts(_demoPosts)));
  }

  Future<void> addComment(String postId, String content) async {
    final user = await currentUser();
    final authorName = user?.isAnonymous == true ? 'Anonymous User' : (user?.name ?? 'Anonymous User');
    final role = user?.role ?? 'user';
    final isAdvisor = role == 'advisor';

    if (_usesFirebase) {
      await _firestore!
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'authorId': user?.id ?? 'anonymous',
        'authorName': authorName,
        'authorRole': role,
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'highlighted': false,
      });
      await _firestore!.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
        'hasAdvisorResponse': isAdvisor ? true : false,
      });
      await _logActivity(action: 'Comment added', subject: authorName, detail: 'Posted on $postId');
      return;
    }

    final comment = SafeMindComment(
      id: 'demo-comment-${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: user?.id ?? 'anonymous',
      authorName: authorName,
      authorRole: role,
      content: content.trim(),
      createdAt: DateTime.now(),
      likes: 0,
      highlighted: false,
    );

    final comments = _demoComments.putIfAbsent(postId, () => <SafeMindComment>[]);
    comments.insert(0, comment);
    _updateDemoPost(postId, (post) => post.copyWith(commentCount: post.commentCount + 1, hasAdvisorResponse: post.hasAdvisorResponse || isAdvisor));
    _commentStreamFor(postId).add(List<SafeMindComment>.unmodifiable(comments));
    await _logActivity(action: 'Comment added', subject: authorName, detail: 'Posted on $postId');
  }

  Future<void> markBestComment({required String postId, required String commentId}) async {
    if (_usesFirebase) {
      await _firestore!.collection('posts').doc(postId).update({'bestCommentId': commentId, 'solved': true});
      await _firestore!.collection('posts').doc(postId).collection('comments').doc(commentId).update({'highlighted': true});
      return;
    }

    _updateDemoPost(postId, (post) => post.copyWith(bestCommentId: commentId, solved: true));
    final comments = _demoComments[postId];
    if (comments == null) return;
    final updated = comments.map((comment) => comment.id == commentId ? comment.copyWith(highlighted: true) : comment).toList();
    _demoComments[postId] = updated;
    _commentStreamFor(postId).add(List<SafeMindComment>.unmodifiable(updated));
  }

  Future<void> reportContent({required String targetType, required String targetId, required String reason, String? targetAuthorId, String? targetAuthorName, String severity = 'medium'}) async {
    final user = await currentUser();
    final reporterName = user?.isAnonymous == true ? 'Anonymous User' : (user?.name ?? 'Anonymous User');

    if (_usesFirebase) {
      await _firestore!.collection('reports').add({
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'reporterName': reporterName,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'open',
        'severity': severity,
        'targetAuthorId': targetAuthorId,
        'targetAuthorName': targetAuthorName,
      });
      await _logActivity(action: 'Content reported', subject: targetType, detail: reason);
      return;
    }

    _demoReports.insert(0, SafeMindReport(id: 'demo-report-${DateTime.now().millisecondsSinceEpoch}', targetType: targetType, targetId: targetId, targetAuthorId: targetAuthorId, targetAuthorName: targetAuthorName, reason: reason, reporterName: reporterName, createdAt: DateTime.now(), status: 'open', severity: severity));
    _reportUpdates.add(List<SafeMindReport>.unmodifiable(_demoReports));
    await _logActivity(action: 'Content reported', subject: targetType, detail: reason);
  }

  Future<void> resolveReport(String reportId, {required String action, required String detail}) async {
    if (_usesFirebase) {
      await _firestore!.collection('reports').doc(reportId).update({'status': 'resolved', 'resolvedAction': action, 'resolvedDetail': detail, 'resolvedAt': FieldValue.serverTimestamp()});
      await _logActivity(action: action, subject: 'Report $reportId', detail: detail);
      return;
    }

    final index = _demoReports.indexWhere((report) => report.id == reportId);
    if (index == -1) return;
    final report = _demoReports[index];
    _demoReports[index] = SafeMindReport(
      id: report.id,
      targetType: report.targetType,
      targetId: report.targetId,
      targetAuthorId: report.targetAuthorId,
      targetAuthorName: report.targetAuthorName,
      reason: report.reason,
      reporterName: report.reporterName,
      createdAt: report.createdAt,
      status: 'resolved',
      severity: report.severity,
    );
    _reportUpdates.add(List<SafeMindReport>.unmodifiable(_demoReports));
    await _logActivity(action: action, subject: 'Report ${report.id}', detail: detail);
  }

  Future<void> removePost(String postId, {String reason = 'Removed by admin'}) async {
    if (_usesFirebase) {
      await _firestore!.collection('posts').doc(postId).update({'removed': true, 'removedReason': reason, 'removedAt': FieldValue.serverTimestamp()});
      await _logActivity(action: 'Post removed', subject: postId, detail: reason);
      return;
    }

    final index = _demoPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    _demoPosts.removeAt(index);
    _postUpdates.add(List<SafeMindPost>.unmodifiable(_sortedPosts(_demoPosts)));
    await _logActivity(action: 'Post removed', subject: postId, detail: reason);
  }

  Future<void> removeComment({required String postId, required String commentId, String reason = 'Removed by admin'}) async {
    if (_usesFirebase) {
      await _firestore!.collection('posts').doc(postId).collection('comments').doc(commentId).update({'removed': true, 'removedReason': reason, 'removedAt': FieldValue.serverTimestamp()});
      await _firestore!.collection('posts').doc(postId).update({'commentCount': FieldValue.increment(-1)});
      await _logActivity(action: 'Comment removed', subject: commentId, detail: reason);
      return;
    }

    final comments = _demoComments[postId];
    if (comments == null) return;
    comments.removeWhere((comment) => comment.id == commentId);
    _commentStreamFor(postId).add(List<SafeMindComment>.unmodifiable(comments));
    _updateDemoPost(postId, (post) => post.copyWith(commentCount: post.commentCount > 0 ? post.commentCount - 1 : 0));
    await _logActivity(action: 'Comment removed', subject: commentId, detail: reason);
  }

  Future<void> moderateReportedTarget(SafeMindReport report, {required String action}) async {
    final detail = '${report.targetType} ${report.targetId}';
    switch (report.targetType) {
      case 'post':
        if (action == 'remove') {
          await removePost(report.targetId, reason: report.reason);
        } else if (action == 'ban' && report.targetAuthorId != null) {
          await banUser(report.targetAuthorId!, banned: true);
        }
        break;
      case 'comment':
        if (action == 'remove' && report.targetId.contains(':')) {
          final segments = report.targetId.split(':');
          if (segments.length == 2) {
            await removeComment(postId: segments.first, commentId: segments.last, reason: report.reason);
          }
        } else if (action == 'ban' && report.targetAuthorId != null) {
          await banUser(report.targetAuthorId!, banned: true);
        }
        break;
      case 'user':
        if (action == 'ban' && report.targetId.isNotEmpty) {
          await banUser(report.targetId, banned: true);
        }
        break;
    }

    await resolveReport(report.id, action: action == 'remove' ? 'Content removed' : 'User banned', detail: detail);
  }

  Future<SafeMindUser?> currentUser() async {
    if (_usesFirebase) {
      final user = _auth!.currentUser;
      if (user == null) return null;
      final doc = await _firestore!.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data == null) {
        return SafeMindUser(id: user.uid, name: user.displayName ?? 'User', email: user.email, role: 'user', isAnonymous: user.isAnonymous);
      }

      return _userFromMap(user.uid, data).copyWith(
        name: (data['name'] as String?) ?? user.displayName ?? (user.isAnonymous ? 'Anonymous User' : user.email?.split('@').first ?? 'User'),
        email: user.email,
        isAnonymous: (data['isAnonymous'] as bool?) ?? user.isAnonymous,
      );
    }

    return _demoUser;
  }

  StreamController<List<SafeMindComment>> _commentStreamFor(String postId) {
    return _commentUpdates.putIfAbsent(postId, () => StreamController<List<SafeMindComment>>.broadcast());
  }

  void _seedDemoData() {
    _demoUsers.addAll([
      const SafeMindUser(id: 'demo-user-1', name: 'Anonymous User', email: 'anon1@safemind.local', role: 'user', isAnonymous: true, postCount: 1, joinedAt: null, moderationState: 'active'),
      const SafeMindUser(id: 'demo-user-2', name: 'Sarah M.', email: 'sarah@safemind.local', role: 'advisor', isAnonymous: false, postCount: 4, joinedAt: null, moderationState: 'active'),
      const SafeMindUser(id: 'demo-admin-1', name: 'Admin', email: 'admin@safemind.local', role: 'admin', isAnonymous: false, postCount: 0, joinedAt: null, moderationState: 'active'),
    ]);

    _demoPosts.addAll([
      SafeMindPost(
        id: 'demo-post-1',
        authorId: 'demo-user-1',
        authorName: 'Anonymous User',
        isAnonymous: true,
        content: 'I have been feeling very anxious before exams. Does anyone have a routine that actually helps?',
        category: 'Anxiety',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        supportCount: 24,
        commentCount: 3,
        solved: false,
        bestCommentId: 'demo-comment-1',
        hasAdvisorResponse: true,
      ),
      SafeMindPost(
        id: 'demo-post-2',
        authorId: 'demo-user-2',
        authorName: 'Anonymous User',
        isAnonymous: true,
        content: 'Just wanted to share that talking with one trusted person made a huge difference for me.',
        category: 'Support',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        supportCount: 89,
        commentCount: 12,
        solved: true,
        bestCommentId: 'demo-comment-2',
        hasAdvisorResponse: true,
      ),
    ]);

    _demoUsers[0] = _demoUsers[0].copyWith(postCount: 1);
    _demoUsers[1] = _demoUsers[1].copyWith(postCount: 1);
    _userUpdates.add(List<SafeMindUser>.unmodifiable(_demoUsers));

    _demoComments['demo-post-1'] = [
      SafeMindComment(
        id: 'demo-comment-1',
        postId: 'demo-post-1',
        authorId: 'advisor-1',
        authorName: 'Dr. Sarah Johnson',
        authorRole: 'advisor',
        content: 'Try the 4-7-8 breathing method and keep a short checklist so the work feels smaller.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 18,
        highlighted: true,
      ),
      SafeMindComment(
        id: 'demo-comment-3',
        postId: 'demo-post-1',
        authorId: 'demo-user-3',
        authorName: 'Anonymous User',
        authorRole: 'user',
        content: 'Breaking tasks into smaller chunks really helped me this semester.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        likes: 12,
        highlighted: false,
      ),
    ];

    _demoComments['demo-post-2'] = [
      SafeMindComment(
        id: 'demo-comment-2',
        postId: 'demo-post-2',
        authorId: 'advisor-2',
        authorName: 'Mark Thompson',
        authorRole: 'advisor',
        content: 'That is a strong first step. Keep repeating honest conversations and protect your sleep schedule too.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 9,
        highlighted: true,
      ),
    ];

    _demoReports.add(SafeMindReport(id: 'demo-report-1', targetType: 'post', targetId: 'demo-post-2', targetAuthorId: 'demo-user-2', targetAuthorName: 'Anonymous User', reason: 'Looks like spam', reporterName: 'Anonymous User', createdAt: DateTime.now().subtract(const Duration(minutes: 10)), status: 'open', severity: 'medium'));

    _demoActivities.addAll([
      SafeMindAdminActivity(id: 'activity-1', action: 'New user registration', subject: 'user_456', actorName: 'System', detail: 'Created in demo mode', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
      SafeMindAdminActivity(id: 'activity-2', action: 'Post reported', subject: 'demo-post-2', actorName: 'Anonymous User', detail: 'Looks like spam', createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
      SafeMindAdminActivity(id: 'activity-3', action: 'Comment removed', subject: 'demo-comment-2', actorName: 'Admin', detail: 'Policy violation', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
    ]);
  }

  List<SafeMindPost> _sortedPosts(List<SafeMindPost> posts) {
    final sorted = [...posts];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  SafeMindPost? _findPost(String postId) {
    for (final post in _demoPosts) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  void _updateDemoPost(String postId, SafeMindPost Function(SafeMindPost) updater) {
    final index = _demoPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    _demoPosts[index] = updater(_demoPosts[index]);
    _postUpdates.add(List<SafeMindPost>.unmodifiable(_sortedPosts(_demoPosts)));
  }

  SafeMindPost _postFromMap(String id, Map<String, dynamic> data) {
    return SafeMindPost(
      id: id,
      authorId: (data['authorId'] as String?) ?? 'anonymous',
      authorName: (data['authorName'] as String?) ?? 'Anonymous User',
      isAnonymous: (data['isAnonymous'] as bool?) ?? true,
      content: (data['content'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'General',
      createdAt: _toDateTime(data['createdAt']),
      supportCount: (data['supportCount'] as int?) ?? 0,
      commentCount: (data['commentCount'] as int?) ?? 0,
      solved: (data['solved'] as bool?) ?? false,
      bestCommentId: data['bestCommentId'] as String?,
      hasAdvisorResponse: (data['hasAdvisorResponse'] as bool?) ?? false,
      authorMood: data['authorMood'] as int?,
    );
  }

  SafeMindComment _commentFromMap(String id, String postId, Map<String, dynamic> data) {
    return SafeMindComment(
      id: id,
      postId: postId,
      authorId: (data['authorId'] as String?) ?? 'anonymous',
      authorName: (data['authorName'] as String?) ?? 'Anonymous User',
      authorRole: (data['authorRole'] as String?) ?? 'user',
      content: (data['content'] as String?) ?? '',
      createdAt: _toDateTime(data['createdAt']),
      likes: (data['likes'] as int?) ?? 0,
      highlighted: (data['highlighted'] as bool?) ?? false,
    );
  }

  SafeMindReport _reportFromMap(String id, Map<String, dynamic> data) {
    return SafeMindReport(
      id: id,
      targetType: (data['targetType'] as String?) ?? 'post',
      targetId: (data['targetId'] as String?) ?? '',
      targetAuthorId: data['targetAuthorId'] as String?,
      targetAuthorName: data['targetAuthorName'] as String?,
      reason: (data['reason'] as String?) ?? '',
      reporterName: (data['reporterName'] as String?) ?? 'Anonymous User',
      createdAt: _toDateTime(data['createdAt']),
      status: (data['status'] as String?) ?? 'open',
      severity: (data['severity'] as String?) ?? _severityForReason((data['reason'] as String?) ?? ''),
    );
  }

  DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Messaging functionality
  Stream<List<SafeMindConversation>> watchConversations(String userId) async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
            final conversations = snapshot.docs.map((doc) => SafeMindConversation.fromMap(doc.id, doc.data())).toList();
            conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
            return conversations;
          });
      return;
    }

    final conversations = _demoConversations.where((conv) => conv.user1Id == userId || conv.user2Id == userId).toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    yield conversations;
    yield* _conversationUpdates.stream;
  }

  Stream<List<SafeMindMessage>> watchMessages(String conversationId) async* {
    if (_usesFirebase) {
      yield* _firestore!
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => SafeMindMessage.fromMap(doc.id, doc.data())).toList());
      return;
    }

    final conversationMessages = _demoMessages.where((msg) => msg.conversationId == conversationId).toList();
    conversationMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    yield conversationMessages;
    yield* _messageStreamFor(conversationId).stream;
  }

  Future<void> sendMessage({
    required String recipientId,
    required String recipientName,
    required String content,
  }) async {
    final sender = await currentUser();
    if (sender == null) return;

    if (_usesFirebase) {
      // Create or get conversation ID
      final conversationId = _makeConversationId(sender.id, recipientId);
      final conversationRef = _firestore!.collection('conversations').doc(conversationId);
      
      // Check if conversation exists
      final existing = await conversationRef.get();
      
      if (!existing.exists) {
        // Create new conversation
        await conversationRef.set({
          'user1Id': sender.id,
          'user1Name': sender.name,
          'user2Id': recipientId,
          'user2Name': recipientName,
          'lastMessage': content,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'participants': [sender.id, recipientId],
        });
      } else {
        // Update conversation with last message
        await conversationRef.update({
          'lastMessage': content,
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }

      // Add message
      await conversationRef.collection('messages').add({
        'senderId': sender.id,
        'senderName': sender.name,
        'recipientId': recipientId,
        'recipientName': recipientName,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'conversationId': conversationId,
      });
      return;
    }

    // Demo mode
    final conversationId = _makeConversationId(sender.id, recipientId);
    final message = SafeMindMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: sender.id,
      senderName: sender.name,
      recipientId: recipientId,
      recipientName: recipientName,
      content: content,
      createdAt: DateTime.now(),
      isRead: false,
      conversationId: conversationId,
    );

    _demoMessages.add(message);
    _messageStreamFor(conversationId).add(_demoMessages.where((msg) => msg.conversationId == conversationId).toList());

    // Update or create conversation
    final convIndex = _demoConversations.indexWhere((c) => c.id == conversationId);
    if (convIndex == -1) {
      _demoConversations.add(SafeMindConversation(
        id: conversationId,
        user1Id: sender.id,
        user1Name: sender.name,
        user2Id: recipientId,
        user2Name: recipientName,
        lastMessage: content,
        lastMessageTime: DateTime.now(),
      ));
    } else {
      _demoConversations[convIndex] = _demoConversations[convIndex].copyWith(
        lastMessage: content,
        lastMessageTime: DateTime.now(),
      );
    }
    _conversationUpdates.add(List<SafeMindConversation>.unmodifiable(_demoConversations));
  }

  StreamController<List<SafeMindMessage>> _messageStreamFor(String conversationId) {
    return _messageUpdates.putIfAbsent(
      conversationId,
      () => StreamController<List<SafeMindMessage>>.broadcast(),
    );
  }

  String _makeConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'conv-${ids[0]}-${ids[1]}';
  }

  Future<void> _ensureFirebaseUserDoc(User? user, {required bool isAnonymous, String? displayName}) async {
    if (user == null) {
      // ignore: avoid_print
      print('_ensureFirebaseUserDoc: user is null');
      return;
    }
    try {
      final docRef = _firestore!.collection('users').doc(user.uid);
      final existing = await docRef.get();
      final existingData = existing.data();
      final currentRole = (existingData?['role'] as String?) ?? 'user';
      final currentBanned = (existingData?['isBanned'] as bool?) ?? false;
      final currentModerationState = (existingData?['moderationState'] as String?) ?? 'active';
      final currentPostCount = (existingData?['postCount'] as int?) ?? 0;

      await docRef.set({
        'name': displayName ?? user.displayName ?? (isAnonymous ? 'Anonymous User' : user.email?.split('@').first ?? 'User'),
        'email': user.email,
        'role': currentRole,
        'isAnonymous': isAnonymous,
        'isBanned': currentBanned,
        'postCount': currentPostCount,
        'moderationState': currentModerationState,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // ignore: avoid_print
      print('_ensureFirebaseUserDoc: Successfully created/updated user doc for ${user.uid}');
    } catch (e) {
      // ignore: avoid_print
      print('_ensureFirebaseUserDoc error: $e');
      rethrow;
    }
  }

  SafeMindUser _userFromMap(String id, Map<String, dynamic> data) {
    return SafeMindUser(
      id: id,
      name: (data['name'] as String?) ?? 'Anonymous User',
      email: data['email'] as String?,
      role: (data['role'] as String?) ?? 'user',
      isAnonymous: (data['isAnonymous'] as bool?) ?? false,
      isBanned: (data['isBanned'] as bool?) ?? false,
      postCount: (data['postCount'] as int?) ?? 0,
      joinedAt: _toDateTime(data['createdAt']),
      moderationState: (data['moderationState'] as String?) ?? 'active',
    );
  }

  SafeMindAdminActivity _activityFromMap(String id, Map<String, dynamic> data) {
    return SafeMindAdminActivity(
      id: id,
      action: (data['action'] as String?) ?? 'Activity',
      subject: (data['subject'] as String?) ?? '',
      actorName: (data['actorName'] as String?) ?? 'Admin',
      detail: (data['detail'] as String?) ?? '',
      createdAt: _toDateTime(data['createdAt']),
      kind: (data['kind'] as String?) ?? 'moderation',
    );
  }

  String _roleForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.startsWith('admin') || normalized.contains('+admin@')) {
      return 'admin';
    }
    if (normalized.startsWith('advisor') || normalized.contains('+advisor@')) {
      return 'advisor';
    }
    return 'user';
  }

  String _severityForReason(String reason) {
    final lower = reason.toLowerCase();
    if (lower.contains('abuse') || lower.contains('harm') || lower.contains('threat')) {
      return 'high';
    }
    if (lower.contains('spam') || lower.contains('misleading')) {
      return 'medium';
    }
    return 'low';
  }

  void _syncDemoUser(SafeMindUser user) {
    final index = _demoUsers.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      _demoUsers.add(user);
    } else {
      _demoUsers[index] = user;
    }
    _userUpdates.add(List<SafeMindUser>.unmodifiable(_demoUsers));
  }

  void _incrementDemoPostCount(String userId) {
    final index = _demoUsers.indexWhere((user) => user.id == userId);
    if (index == -1) return;
    _demoUsers[index] = _demoUsers[index].copyWith(postCount: _demoUsers[index].postCount + 1);
    _userUpdates.add(List<SafeMindUser>.unmodifiable(_demoUsers));
  }

  Future<void> _logActivity({required String action, required String subject, required String detail, String actorName = 'Admin', String kind = 'moderation'}) async {
    final entry = SafeMindAdminActivity(
      id: 'activity-${DateTime.now().millisecondsSinceEpoch}',
      action: action,
      subject: subject,
      actorName: actorName,
      detail: detail,
      createdAt: DateTime.now(),
      kind: kind,
    );

    if (_usesFirebase) {
      await _firestore!.collection('adminActivity').add({
        'action': entry.action,
        'subject': entry.subject,
        'actorName': entry.actorName,
        'detail': entry.detail,
        'createdAt': FieldValue.serverTimestamp(),
        'kind': entry.kind,
      });
      return;
    }

    _demoActivities.insert(0, entry);
    _activityUpdates.add(List<SafeMindAdminActivity>.unmodifiable(_demoActivities));
  }
}