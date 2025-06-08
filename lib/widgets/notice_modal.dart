// notice_model.dart
import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../pages/summary_page.dart';

class NoticeBottomSheet extends StatelessWidget {
  final DateTime date;
  final List<Notice> notices;

  const NoticeBottomSheet({
    super.key,
    required this.date,
    required this.notices,
  });

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일'
        ' (${['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7]})';

    // ✅ 숨기기 처리된 공지 제외
    final visibleNotices = notices.where((n) => !n.isHidden).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: visibleNotices.length,
                    itemBuilder: (_, index) {
                      final n = visibleNotices[index];
                      return GestureDetector(
                        onTap: () {
                          if (n.url != null && n.url!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SummaryPage(notice: n),
                              ),
                            );
                          }
                        },

                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: n.color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
