// favorite_notice.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice.dart';

class FavoriteNotices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _noticesRef =>
      _firestore.collection('calendarEvents'); // 로그인 없이 단일 notices 컬렉션만 사용

  // 즐겨찾기된 공지들만 불러오기
  static Future<List<Notice>> loadAllNotices() async {
    final snapshot = await _noticesRef.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Notice.fromJson(data);
    }).toList();
  }

  // isFavorite == true인 공지만 필터링해서 불러오기
  static Future<List<Notice>> loadFavorites() async {
    final snapshot =
        await _noticesRef.where('isFavorite', isEqualTo: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Notice.fromJson(data);
    }).toList();
  }

  // 즐겨찾기 추가 (isFavorite true로 설정)
  static Future<void> addFavorite(Notice notice) async {
    final docId = _generateDocId(notice);
    await _noticesRef.doc(docId).set(
      {
        ...notice.toJson(), // 기존 공지 정보
        'isFavorite': true, // 즐겨찾기 설정
      },
      SetOptions(merge: true), // 병합해서 기존 데이터 유지
    );
  }

  // 즐겨찾기 제거 (isFavorite false로 설정)
  static Future<void> removeFavorite(Notice notice) async {
    final docId = _generateDocId(notice);
    await _noticesRef.doc(docId).set({
      'isFavorite': false,
    }, SetOptions(merge: true));
  }

  static Future<void> toggleFavorite(Notice notice) async {
    final docId = _generateDocId(notice);
    final docRef = _noticesRef.doc(docId);
    final doc = await docRef.get();

    final current = (doc.data()?['isFavorite'] ?? false) == true;

    if (doc.exists) {
      await docRef.update({'isFavorite': !current});
    } else {
      await docRef.set({
        ...notice.toJson(),
        'isFavorite': !current,
      }, SetOptions(merge: true));
    }
  }

  // 현재 공지가 즐겨찾기 상태인지 확인
  static Future<bool> isFavorite(Notice notice) async {
    final docId = _generateDocId(notice);
    final doc = await _noticesRef.doc(docId).get();
    return (doc.data()?['isFavorite'] ?? false) == true;
  }

  // 공지를 구별할 고유 문서 ID 생성 (제목+날짜)
  static String _generateDocId(Notice notice) {
    final safeTitle =
        notice.title.replaceAll(RegExp(r'[^\w]+'), '-').toLowerCase();
    final safeDate = notice.startDate.toIso8601String().replaceAll(':', '');
    return '${safeTitle}_$safeDate';
  }
}
