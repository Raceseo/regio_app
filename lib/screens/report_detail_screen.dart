import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/activity_report.dart';
import '../global_variables.dart'; // 전역 변수 임포트
import 'report_form_screen.dart'; // ⭐️ 수정: 누락된 import 추가

class ReportDetailScreen extends StatefulWidget {
  final ActivityReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late ActivityReport _currentReport;

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
  }

  // ⭐️ 수정: 새로운 모델의 userId를 사용하도록 변경
  bool get _canUserModify {
    final isAuthor = globalUserId == _currentReport.userId;
    final isAdmin = globalUserRole == 'admin';
    return isAuthor || isAdmin;
  }

  // 보고서 삭제 함수 (변경 없음)
  void _deleteReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('보고서 삭제'),
        content: const Text('정말로 이 보고서를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(_currentReport.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('보고서가 삭제되었습니다.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  // 보고서 수정 화면으로 이동 (변경 없음)
  void _editReport() async {
    final updatedReport = await Navigator.of(context).push<ActivityReport>(
      MaterialPageRoute(
        builder: (ctx) => ReportFormScreen(report: _currentReport),
      ),
    );

    if (updatedReport != null) {
      setState(() {
        _currentReport = updatedReport;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentReport.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_canUserModify)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editReport,
              tooltip: '수정',
            ),
          if (_canUserModify)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReport,
              tooltip: '삭제',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐️ UI 개선: '작성자'와 '소속' 정보 표시
            Text(
              '작성자: ${_currentReport.userName} (${_currentReport.unitName})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // ⭐️ 수정: 새로운 모델의 timestamp를 사용하도록 변경
            Text(
              '활동일: ${DateFormat('yyyy년 MM월 dd일').format(_currentReport.timestamp.toDate())}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            // ⭐️ 수정: createdAt은 timestamp와 통합되었으므로 삭제
            // const SizedBox(height: 8),
            // Text(
            //   '작성 시간: ${DateFormat('yyyy.MM.dd HH:mm').format(_currentReport.createdAt)}',
            //   style: const TextStyle(fontSize: 14, color: Colors.grey),
            // ),

            const Divider(height: 32),

            // ⭐️ UI 개선: 첨부 이미지가 있을 경우 표시
            if (_currentReport.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  _currentReport.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // 이미지 로딩 중 표시
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  // 이미지 로딩 실패 시 표시
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('이미지를 불러올 수 없습니다.'));
                  },
                ),
              ),
            if (_currentReport.imageUrl.isNotEmpty) const SizedBox(height: 24),

            // 내용 표시 (변경 없음)
            Text(
              _currentReport.content,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
