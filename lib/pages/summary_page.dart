import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:scalendar_app/models/notice.dart';
import 'package:scalendar_app/services/gemini_service.dart';
import 'package:scalendar_app/services/web_scraper_service.dart';
import 'package:scalendar_app/services/hidden_notice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/favorite_notice.dart';

class SummaryPage extends StatefulWidget {
  final Notice notice;
  const SummaryPage({super.key, required this.notice});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final WebScraperService _webScraperService = WebScraperService();
  final GeminiService _geminiService = GeminiService();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isLoading = true;
  Map<String, String>? _summaryResults;
  String? _errorMessage;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeNotification();
    _loadMemo();
    _summarizeFromInitialUrl();
    _loadFavoriteStatus();
  }

  Future<void> _initializeNotification() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleNotification(Notice notice) async {
    final scheduledDate = DateTime(
      notice.startDate.year,
      notice.startDate.month,
      notice.startDate.day - 1,
      8,
      0,
      0,
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'notice_channel',
        '공지 알림',
        channelDescription: '신청 시작일 하루 전, 오전 8시에 알림이 예약되었습니다.',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      notice.hashCode,
      '다가오는 공지',
      notice.title,
      tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      ), // 기존 DateTime → TZDateTime 변환
      details, // 이미 만든 NotificationDetails 객체라면 그대로 사용
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> _toggleNotificationForNotice() async {
    if (widget.notice.isPush) {
      // 알림 취소
      await _notificationsPlugin.cancel(widget.notice.hashCode);
      setState(() {
        widget.notice.isPush = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('알림이 취소되었습니다.')));
    } else {
      // 알림 예약
      await _scheduleNotification(widget.notice);
      setState(() {
        widget.notice.isPush = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('알림이 예약되었습니다.')));
    }
  }

  Future<void> _loadMemo() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateMemoKey();
    final savedMemo = prefs.getString(key);
    if (!mounted) return;
    setState(() {
      widget.notice.memo = savedMemo;
    });
  }

  Future<void> _saveMemo(String memo) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateMemoKey();
    await prefs.setString(key, memo);
    if (!mounted) return;
    setState(() {
      widget.notice.memo = memo;
    });
  }

  String _generateMemoKey() {
    return 'memo_${widget.notice.title}_${widget.notice.startDate.toIso8601String()}';
  }

  Future<void> _summarizeFromInitialUrl() async {
    try {
      final content = await _webScraperService.fetchAndExtractText(
        widget.notice.url ?? '',
      );
      if (content == null || content.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage = "웹 페이지 내용을 가져오거나 파싱하는 데 실패했습니다.";
          _isLoading = false;
        });
        return;
      }

      final summary = await _geminiService.summarizeUrlContent(content);
      if (summary == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = "요약 내용을 생성하는 데 실패했습니다.";
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _summaryResults = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "오류 발생: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    final rawUrl = widget.notice.url;
    if (rawUrl == null) return;
    final url = Uri.parse(rawUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("링크를 열 수 없습니다.")));
    }
  }

  void _showMemoDialog() {
    final TextEditingController controller = TextEditingController(
      text: widget.notice.memo,
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('메모 수정'),
            content: TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(hintText: '메모를 입력하세요'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final memo = controller.text.trim();
                  await _saveMemo(memo);
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  void _hideNotice() async {
    await HiddenNotices.add(widget.notice);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 공지를 숨겼습니다.')));
    Navigator.pop(context);
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await FavoriteNotices.isFavorite(widget.notice);
    if (!mounted) return;
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    await FavoriteNotices.toggleFavorite(widget.notice);
    final newStatus = await FavoriteNotices.isFavorite(widget.notice);
    if (!mounted) return;
    setState(() {
      _isFavorite = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus ? '관심 공지에 추가되었습니다.' : '관심 공지에서 제거되었습니다.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지 요약'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(
              widget.notice.isPush
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: widget.notice.isPush ? Colors.blue : null,
            ),
            onPressed: _toggleNotificationForNotice,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNoticeHeader(),
                    const SizedBox(height: 24),
                    _buildSummaryItem('참가대상', _summaryResults!["참가대상"]),
                    _buildSummaryItem('신청기간', _summaryResults!["신청기간"]),
                    _buildSummaryItem('신청방법', _summaryResults!["신청방법"]),
                    _buildSummaryItem('내용', _summaryResults!["내용"]),
                    const SizedBox(height: 16),
                    if (widget.notice.url != null)
                      GestureDetector(
                        onTap: _launchUrl,
                        child: const Text(
                          '홈페이지 바로가기',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      '메모:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.notice.memo != null &&
                        widget.notice.memo!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(widget.notice.memo!),
                      ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _showMemoDialog,
                          child: const Text('수정'),
                        ),
                        const SizedBox(width: 40),
                        ElevatedButton(
                          onPressed: _hideNotice,
                          child: const Text('숨기기'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildNoticeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              color: widget.notice.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.notice.title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          const SizedBox(height: 4.0),
          Text(content ?? '정보 없음', style: const TextStyle(fontSize: 14.0)),
        ],
      ),
    );
  }
}
