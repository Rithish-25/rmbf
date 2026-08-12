import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models.dart';

class ThanksNoteHistoryScreen extends StatefulWidget {
  final String initialFilter;
  const ThanksNoteHistoryScreen({super.key, this.initialFilter = "All"});

  @override
  State<ThanksNoteHistoryScreen> createState() => _ThanksNoteHistoryScreenState();
}

class _ThanksNoteHistoryScreenState extends State<ThanksNoteHistoryScreen> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignmentForFilter(String filter) {
    if (filter == "All") return Alignment.centerLeft;
    if (filter == "Given") return Alignment.center;
    return Alignment.centerRight;
  }

  String _formatCurrency(double value) {
    String valStr = value.toInt().toString();
    if (valStr.length <= 3) return valStr;
    String lastThree = valStr.substring(valStr.length - 3);
    String remaining = valStr.substring(0, valStr.length - 3);
    
    String formattedRemaining = "";
    int count = 0;
    for (int i = remaining.length - 1; i >= 0; i--) {
      formattedRemaining = remaining[i] + formattedRemaining;
      count++;
      if (count == 2 && i > 0) {
        formattedRemaining = ",$formattedRemaining";
        count = 0;
      }
    }
    return "$formattedRemaining,$lastThree";
  }

  String _formatDate(String rawDate) {
    try {
      final parts = rawDate.split("-");
      if (parts.length == 3) {
        return "${int.parse(parts[2])}/${int.parse(parts[1])}/${parts[0]}";
      }
    } catch (_) {}
    return rawDate;
  }

  void _editNoteDialog(ThanksNote note) {
    final nameController = TextEditingController(text: note.memberName);
    final amountController = TextEditingController(text: note.amount.toInt().toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Edit Thanksnote",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Member Name",
                  labelStyle: GoogleFonts.outfit(),
                ),
                style: GoogleFonts.outfit(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (₹)",
                  labelStyle: GoogleFonts.outfit(),
                ),
                style: GoogleFonts.outfit(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text.trim());
                if (name.isNotEmpty && amount != null && amount > 0) {
                  final index = MockData.thanksNotes.indexWhere((n) => n.id == note.id);
                  if (index != -1) {
                    setState(() {
                      MockData.thanksNotes[index] = ThanksNote(
                        id: note.id,
                        memberName: name,
                        businessName: note.businessName,
                        amount: amount,
                        isGiven: note.isGiven,
                        date: note.date,
                        attachmentName: note.attachmentName,
                      );
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: Text("Save", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _deleteNoteDialog(ThanksNote note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete Thanksnote",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete this thanksnote transaction?",
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  MockData.thanksNotes.removeWhere((n) => n.id == note.id);
                });
                Navigator.pop(context);
              },
              child: Text("Delete", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryList() {
    final filteredNotes = MockData.thanksNotes.where((note) {
      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "Given") return note.isGiven;
      if (_selectedFilter == "Taken") return !note.isGiven;
      return true;
    }).toList();

    if (filteredNotes.isEmpty) {
      return Center(
        child: Text(
          "No history found",
          style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.memberName,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    note.isGiven ? "Given" : "Taken",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: note.isGiven ? AppTheme.error : AppTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                note.businessName,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "₹ ${_formatCurrency(note.amount)}",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _formatDate(note.date),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (note.isGiven)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _editNoteDialog(note),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.secondary),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: AppTheme.secondary,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _deleteNoteDialog(note),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.error),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.error,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Thanksnote History",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF), // Soft light blue background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppTheme.primary, // Dark Blue close button
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Stack(
                  children: [
                    // Sliding indicator background
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: _getAlignmentForFilter(_selectedFilter),
                      child: FractionallySizedBox(
                        widthFactor: 0.33,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // Buttons text
                    Row(
                      children: [
                        _buildFilterTab("All"),
                        _buildFilterTab("Given"),
                        _buildFilterTab("Taken"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedFilter),
                    child: _buildHistoryList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
