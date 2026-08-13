import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  List<Booking> _allBookings = [];
  bool _isLoading = true;

  // Fallback colors configured by admin
  final Map<String, String> _adminColorConfig = {
    "Meeting Schedule": "#1E3A8A",
    "Birthday": "#F59E0B",
    "Wedding Day": "#EC4899",
    "Company Open Day": "#10B981",
  };

  @override
  void initState() {
    super.initState();
    // Default to August 2026 to match dashboard state
    _focusedMonth = DateTime(2026, 8);
    _selectedDay = DateTime(2026, 8, 10); // August 10, 2026
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final bookings = await ApiService.fetchBookings();
    setState(() {
      _allBookings = bookings;
      _isLoading = false;
    });
  }

  Color _getEventColor(Booking booking) {
    return _parseColor(booking.colorCode);
  }

  Color _getTypeColor(String type) {
    // Check if we have an event of this type in our loaded bookings to use its color code
    final match = _allBookings.firstWhere(
      (b) => b.type == type,
      orElse: () => Booking(
        id: "",
        title: "",
        type: type,
        date: "",
        colorCode: _adminColorConfig[type] ?? "#1E3A8A",
        description: "",
        time: "",
      ),
    );
    return _parseColor(match.colorCode);
  }

  Color _parseColor(String hexColor) {
    try {
      String cleanHex = hexColor.replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return AppTheme.primary;
    }
  }

  int _daysInMonth(DateTime date) {
    var firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  int _firstWeekdayOffset(DateTime date) {
    var firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7; // Sunday = 0, Monday = 1, etc.
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  List<Booking> _getBookingsForDate(DateTime date) {
    final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _allBookings.where((b) => b.date == dateString).toList();
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        final color = _getEventColor(booking);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header with Type Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: color.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        booking.type,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  booking.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 16),
                // Date & Time
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: color),
                    const SizedBox(width: 10),
                    Text(
                      booking.date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: color),
                    const SizedBox(width: 10),
                    Text(
                      booking.time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                if (booking.description.isNotEmpty) ...[
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDayEventsDialog(DateTime date, List<Booking> bookings) {
    if (bookings.isEmpty) return;
    if (bookings.length == 1) {
      _showBookingDetails(bookings.first);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Events on ${_getMonthName(date.month)} ${date.day}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final color = _getEventColor(booking);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.border.withOpacity(0.5)),
                        ),
                        elevation: 0,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close list dialog
                            _showBookingDetails(booking); // Open details dialog
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.type,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 16),
                              ],
                            ),
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

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(_focusedMonth.month);
    final year = _focusedMonth.year;
    final totalDays = _daysInMonth(_focusedMonth);
    final offset = _firstWeekdayOffset(_focusedMonth);


    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Calendar Booking"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Month Selector Header Card
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      children: [
                        // Month Toggle Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                              onPressed: _previousMonth,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: Text(
                                "$monthName $year",
                                key: ValueKey(_focusedMonth),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Days of the week row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _DayNameLabel("S"),
                            _DayNameLabel("M"),
                            _DayNameLabel("T"),
                            _DayNameLabel("W"),
                            _DayNameLabel("T"),
                            _DayNameLabel("F"),
                            _DayNameLabel("S"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Calendar Grid
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: GridView.builder(
                            key: ValueKey(_focusedMonth),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.05,
                            ),
                            itemCount: offset + totalDays,
                            itemBuilder: (context, index) {
                              if (index < offset) {
                                return const SizedBox.shrink();
                              }
                              final day = index - offset + 1;
                              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                              final bookings = _getBookingsForDate(date);
                              final isSelected = _selectedDay.year == date.year &&
                                  _selectedDay.month == date.month &&
                                  _selectedDay.day == date.day;
                              final isToday = DateTime.now().year == date.year &&
                                  DateTime.now().month == date.month &&
                                  DateTime.now().day == date.day;

                              BoxDecoration cellDecoration;
                              Color textColor;

                              if (bookings.isNotEmpty) {
                                textColor = Colors.white;
                                final border = isSelected
                                    ? Border.all(color: AppTheme.primary, width: 2.5)
                                    : isToday
                                        ? Border.all(color: AppTheme.secondary, width: 2.0)
                                        : null;

                                if (bookings.length == 1) {
                                  cellDecoration = BoxDecoration(
                                    color: _getEventColor(bookings.first),
                                    borderRadius: BorderRadius.circular(10),
                                    border: border,
                                  );
                                } else {
                                  final colors = bookings.map((b) => _getEventColor(b)).toList();
                                  cellDecoration = BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: colors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: border,
                                  );
                                }
                              } else {
                                textColor = isSelected
                                    ? AppTheme.primary
                                    : isToday
                                        ? AppTheme.secondary
                                        : AppTheme.textPrimary;
                                cellDecoration = BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary.withOpacity(0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : isToday
                                            ? AppTheme.secondary
                                            : Colors.transparent,
                                    width: isSelected || isToday ? 1.5 : 0,
                                  ),
                                );
                              }

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDay = date;
                                  });
                                  if (bookings.isNotEmpty) {
                                    _showDayEventsDialog(date, bookings);
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: cellDecoration,
                                  child: Center(
                                    child: Text(
                                      day.toString(),
                                      style: TextStyle(
                                        fontWeight: isSelected || isToday || bookings.isNotEmpty
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Legend
                Padding(
                  padding: const EdgeInsets.only(left: 48, right: 20, top: 12, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(type: "Meeting Schedule", color: _getTypeColor("Meeting Schedule")),
                      const SizedBox(height: 14),
                      _LegendItem(type: "Birthday", color: _getTypeColor("Birthday")),
                      const SizedBox(height: 14),
                      _LegendItem(type: "Wedding Day", color: _getTypeColor("Wedding Day")),
                      const SizedBox(height: 14),
                      _LegendItem(type: "Company Open Day", color: _getTypeColor("Company Open Day")),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
}

class _DayNameLabel extends StatelessWidget {
  final String label;
  const _DayNameLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String type;
  final Color color;

  const _LegendItem({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          type,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
