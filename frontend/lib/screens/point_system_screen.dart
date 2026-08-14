import 'package:flutter/material.dart';
import '../theme.dart';
import '../language_service.dart';

class PointSystemScreen extends StatelessWidget {
  const PointSystemScreen({super.key});

  static const List<Map<String, String>> _rules = [
    {"desc": "R to R", "value": "250"},
    {"desc": "Power Team Attendance", "value": "1000"},
    {"desc": "Absent", "value": "-500"},
    {"desc": "Attendance - Present", "value": "500"},
    {"desc": "Leave", "value": "-300"},
    {"desc": "Absent", "value": "-400"},
    {"desc": "Early Going / Late", "value": "-200"},
    {"desc": "Referral Value for each 1000 Rupees", "value": "5"},
    {"desc": "Referral Count", "value": "200"},
    {"desc": "Visitors Count", "value": "1500"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        title: Text(t("Point System")),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white24, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t("Points & Attendance Rules"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: AppTheme.border, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(2.2),
                  1: FlexColumnWidth(1.2),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Color(0xFFF3F4F6)),
                    children: [
                      _HeaderCell("Description"),
                      _HeaderCell("Per count", alignEnd: true),
                    ],
                  ),
                  for (final rule in _rules)
                    TableRow(
                      children: [
                        _DataCell(rule["desc"]!),
                        _DataCell(
                          rule["value"]!,
                          alignEnd: true,
                          color: rule["value"]!.startsWith("-")
                              ? AppTheme.error
                              : AppTheme.textPrimary,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool alignEnd;
  const _HeaderCell(this.text, {this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        t(text),
        textAlign: alignEnd ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool alignEnd;
  final Color color;
  const _DataCell(this.text, {this.alignEnd = false, this.color = AppTheme.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        t(text),
        textAlign: alignEnd ? TextAlign.center : TextAlign.left,
        style: TextStyle(fontSize: 13, color: color),
      ),
    );
  }
}
