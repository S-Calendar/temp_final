// notice.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;
  final String? url;
  final String? writer;
  final String category; // 카테고리 필드 추가

  bool isFavorite;
  bool isHidden;
  String? memo;
  bool isPush;

  Notice({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.category, // 추가
    this.url,
    this.writer,
    this.isFavorite = false,
    this.isHidden = false,
    this.memo,
    this.isPush = false,
  });

  // 신청기간 길이 (띠 우선순위 판단용)
  int get duration => endDate.difference(startDate).inDays + 1;

  // 날짜 포함 여부
  bool includes(DateTime date) {
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      title: json['title'] ?? '',
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      color: Color(json['color']), // int로 저장된 color를 복원
      category: json['category'] ?? '', // 추가
      url: json['url'],
      writer: json['writer'],
      isFavorite: json['isFavorite'] ?? false,
      isHidden: json['isHidden'] ?? false,
      memo: json['memo'],
      isPush: json['isPush'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'color': color.value, // int로 변환
      'category': category, // 추가
      'url': url,
      'writer': writer,
      'isFavorite': isFavorite,
      'isHidden': isHidden,
      'memo': memo,
      'isPush': isPush,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is Notice && title == other.title && startDate == other.startDate;

  @override
  int get hashCode => Object.hash(title, startDate);
}
