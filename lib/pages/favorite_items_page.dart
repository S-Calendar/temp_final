import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../services/favorite_notice.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoriteItemsPage extends StatefulWidget {
  const FavoriteItemsPage({super.key});

  @override
  State<FavoriteItemsPage> createState() => _FavoriteItemsPageState();
}

class _FavoriteItemsPageState extends State<FavoriteItemsPage> {
  List<Notice> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
  }

  Future<void> _loadFavoriteItems() async {
    final favorites = await FavoriteNotices.loadFavorites();
    debugPrint('불러온 관심 공지: ${favorites.length}개');
    if (!mounted) return;
    setState(() {
      favoriteItems = favorites;
    });
  }

  Future<void> _removeFromFavorites(Notice notice) async {
    await FavoriteNotices.removeFavorite(notice);
    if (!mounted) return;
    setState(() {
      favoriteItems.remove(notice);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('관심 공지에서 제거되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관심 공지'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body:
          favoriteItems.isEmpty
              ? const Center(child: Text('관심 공지가 없습니다.'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notice = favoriteItems[index];
                  debugPrint(
                    '✅ UI에 표시할 공지: ${notice.title}, ${notice.startDate}',
                  );
                  return GestureDetector(
                    onTap: () async {
                      if (notice.url != null && notice.url!.isNotEmpty) {
                        final url = Uri.parse(notice.url!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('URL을 열 수 없습니다.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('해당 공지에 연결된 URL이 없습니다.'),
                          ),
                        );
                      }
                    },

                    child: Container(
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
                            icon: Icon(
                              notice.isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                              color:
                                  notice.isFavorite
                                      ? Colors.yellow
                                      : Colors.grey,
                            ),
                            onPressed: () async {
                              try {
                                if (!notice.isFavorite) {
                                  await FavoriteNotices.addFavorite(notice);
                                } else {
                                  await FavoriteNotices.removeFavorite(notice);
                                }
                                setState(() {
                                  notice.isFavorite = !notice.isFavorite;
                                  if (!notice.isFavorite)
                                    favoriteItems.remove(notice);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      notice.isFavorite
                                          ? '관심 공지에 추가되었습니다.'
                                          : '관심 공지에서 제거되었습니다.',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('오류가 발생했습니다. 다시 시도해주세요.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
