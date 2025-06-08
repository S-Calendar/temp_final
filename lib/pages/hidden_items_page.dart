// hidden_items_page.dart
import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../services/hidden_notice.dart';

class HiddenItemsPage extends StatefulWidget {
  const HiddenItemsPage({super.key});

  @override
  State<HiddenItemsPage> createState() => _HiddenItemsPageState();
}

class _HiddenItemsPageState extends State<HiddenItemsPage> {
  List<Notice> hiddenItems = [];

  @override
  void initState() {
    super.initState();
    _loadHiddenItemsAsync();
  }

  Future<void> _loadHiddenItemsAsync() async {
    await HiddenNotices.loadHidden();
    setState(() {
      hiddenItems = HiddenNotices.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('숨기기 편집'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body:
          hiddenItems.isEmpty
              ? const Center(child: Text('숨긴 공지가 없습니다.'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: hiddenItems.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notice = hiddenItems[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(notice.title)),
                        IconButton(
                          icon: const Icon(Icons.undo, color: Colors.green),
                          onPressed: () async {
                            await HiddenNotices.unhide(notice);
                            _loadHiddenItemsAsync();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('공지를 복원했습니다.')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
