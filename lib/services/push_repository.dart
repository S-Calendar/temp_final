// lib/services/push_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice.dart';

class PushItem {
  final Notice notice;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final bool enabled;
  final int notificationId;

  PushItem({
    required this.notice,
    required this.scheduledAt,
    required this.createdAt,
    required this.enabled,
    required this.notificationId,
  });
}

class PushRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('calendarEvents');

  // isPush == true 만 조회
  static Future<List<PushItem>> loadPushItems() async {
    final snapshot = await _ref.where('isPush', isEqualTo: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      final notice = Notice.fromJson(data);

      final scheduledAt = (data['pushScheduledAt'] as Timestamp?)?.toDate();
      final createdAt = (data['pushCreatedAt'] as Timestamp?)?.toDate();
      final enabled = (data['isPush'] ?? false) == true;
      final nid = (data['notificationId'] ?? notice.hashCode) as int;

      return PushItem(
        notice: notice,
        scheduledAt: scheduledAt ?? DateTime.now(),
        createdAt: createdAt ?? DateTime.now(),
        enabled: enabled,
        notificationId: nid,
      );
    }).toList();
  }

  static Future<void> upsertPush({
    required Notice notice,
    required DateTime scheduledAt,
    required int notificationId,
    bool enabled = true,
  }) async {
    final docId = _docId(notice);
    await _ref.doc(docId).set({
      ...notice.toJson(),
      'isPush': enabled,
      'pushScheduledAt': Timestamp.fromDate(scheduledAt),
      'pushCreatedAt': FieldValue.serverTimestamp(),
      'notificationId': notificationId,
    }, SetOptions(merge: true));
  }

  static Future<void> setEnabled(Notice notice, bool enabled) async {
    final docId = _docId(notice);
    await _ref.doc(docId).set({'isPush': enabled}, SetOptions(merge: true));
  }

  static Future<void> removePush(Notice notice) async {
    // 기록은 남기고 isPush만 내리는 방식(필요시 필드 삭제로 바꿔도 됨)
    await setEnabled(notice, false);
  }

  static Future<bool> isPushed(Notice notice) async {
    final doc = await _ref.doc(_docId(notice)).get();
    return (doc.data()?['isPush'] ?? false) == true;
  }

  static String _docId(Notice notice) {
    final safeTitle =
        notice.title.replaceAll(RegExp(r'[^\w]+'), '-').toLowerCase();
    final safeDate = notice.startDate.toIso8601String().replaceAll(':', '');
    return '${safeTitle}_$safeDate';
  }
}
