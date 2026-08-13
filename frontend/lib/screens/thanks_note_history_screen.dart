import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models.dart';

class ThanksNoteHistoryScreen extends StatefulWidget {
  final String initialFilter;
  const ThanksNoteHistoryScreen({super.key, this.initialFilter = "Referal"});

  @override
  State<ThanksNoteHistoryScreen> createState() => _ThanksNoteHistoryScreenState();
}

class _ThanksNoteHistoryScreenState extends State<ThanksNoteHistoryScreen> {
  late String _selectedFilter;
  DateTimeRange? _selectedDateRange;
  bool _isTuesdayFilter = true;

  @override
  void initState() {
    super.initState();
    // Map initial filter
    if (widget.initialFilter == "Given" || widget.initialFilter == "Taken") {
      _selectedFilter = "Thanks Note";
    } else {
      _selectedFilter = widget.initialFilter;
    }
    _setTuesdayRange();
  }

  void _setTuesdayRange() {
    final now = DateTime.now();
    // Tuesday is 2
    int daysToSubtract = (now.weekday - DateTime.tuesday) % 7;
    if (daysToSubtract < 0) daysToSubtract += 7;
    final lastTuesday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
    final start = lastTuesday.subtract(const Duration(days: 7));
    _selectedDateRange = DateTimeRange(start: start, end: lastTuesday);
    _isTuesdayFilter = true;
  }

  bool _isWithinRange(String dateStr) {
    try {
      final parts = dateStr.split("-");
      if (parts.length == 3) {
        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        if (_selectedDateRange != null) {
          final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
          final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
          return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
                 (date.isAtSameMomentAs(end) || date.isBefore(end));
        }
      }
    } catch (_) {}
    return true;
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _isTuesdayFilter = false;
      });
    }
  }

  String _formatDateToShow(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
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
    if (filter == "Referal") return Alignment.centerLeft;
    return Alignment.centerRight;
  }



  String _formatDate(String rawDate) {
    try {
      final parts = rawDate.split("-");
      if (parts.length == 3) {
        return "${parts[2].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[0]}";
      }
    } catch (_) {}
    return rawDate;
  }

  String _formatCurrency(double value) {
    String valStr = value.toInt().toString();
    if (valStr.length <= 3) return "₹$valStr";
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
    return "₹$formattedRemaining,$lastThree";
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
                        isReferral: note.isReferral,
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
      bool matchesTab = false;
      if (_selectedFilter == "Referal") {
        matchesTab = note.isReferral;
      } else if (_selectedFilter == "Thanks Note") {
        matchesTab = !note.isReferral && !note.isGiven;
      }
      
      if (!matchesTab) return false;
      return _isWithinRange(note.date);
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
        
        String cardLabel;
        Color labelColor;
        if (note.isReferral) {
          cardLabel = "Referal";
          labelColor = AppTheme.primary;
        } else if (note.isGiven) {
          cardLabel = "Given";
          labelColor = AppTheme.error;
        } else {
          cardLabel = "Thanks Note";
          labelColor = AppTheme.success;
        }

        String titleText;
        String subtitleText;

        if (note.isReferral) {
          if (note.referralType == "Self") {
            titleText = MockData.currentUser.name;
            subtitleText = note.businessName;
          } else {
            titleText = note.businessName;
            subtitleText = "Referred to ${note.memberName}";
          }
        } else {
          if (note.referralType == "Connect") {
            titleText = note.businessName;
            subtitleText = "Received via ${note.memberName}";
          } else if (note.referralType == "Direct") {
            titleText = MockData.currentUser.name;
            subtitleText = "Received from ${note.memberName}";
          } else {
            titleText = note.memberName;
            subtitleText = note.businessName;
          }
        }

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
                    titleText,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    cardLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitleText,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatDate(note.date),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      if (note.amount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          "•",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCurrency(note.amount),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!note.isGiven && !note.isReferral)
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
      appBar: AppBar(
        title: const Text("Thanksnote History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white24, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        widthFactor: 0.5,
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
                        _buildFilterTab("Referal"),
                        _buildFilterTab("Thanks Note"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Tuesday to Tuesday date filter status card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isTuesdayFilter 
                            ? AppTheme.success.withOpacity(0.1) 
                            : AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isTuesdayFilter ? Icons.event_repeat : Icons.date_range,
                        size: 14,
                        color: _isTuesdayFilter ? AppTheme.success : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isTuesdayFilter 
                                ? "Tuesday to Tuesday Term" 
                                : "Custom Date Range",
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _selectedDateRange != null
                                ? "${_formatDateToShow(_selectedDateRange!.start)} - ${_formatDateToShow(_selectedDateRange!.end)}"
                                : "All History",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isTuesdayFilter)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _setTuesdayRange();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Reset",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _pickDateRange,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Sort/Filter",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedFilter + (_selectedDateRange?.toString() ?? '')),
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
