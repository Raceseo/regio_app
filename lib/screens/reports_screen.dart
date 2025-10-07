import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/activity_report.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';
import '../widgets/main_drawer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsStream = FirebaseFirestore.instance
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .withConverter<ActivityReport>(
          fromFirestore: ActivityReport.fromFirestore,
          toFirestore: (ActivityReport report, _) => report.toFirestore(),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('활동 보고서'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: StreamBuilder<QuerySnapshot<ActivityReport>>(
        stream: reportsStream.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('등록된 보고서가 없습니다.'));
          }

          final reports = snapshot.data!.docs.map((doc) => doc.data()).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  title: Text(
                    report.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '작성자: ${report.userName}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.content.length > 50
                            ? '${report.content.substring(0, 50)}...'
                            : report.content,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '활동일: ${DateFormat('yyyy.MM.dd').format(report.timestamp.toDate())}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ReportDetailScreen(report: report),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReportFormScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
