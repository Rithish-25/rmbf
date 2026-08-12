import 'package:flutter/material.dart';
import 'dart:math';
import '../theme.dart';
import '../models.dart';
import 'thanks_note_history_screen.dart';

class ThanksNoteScreen extends StatefulWidget {
  const ThanksNoteScreen({super.key});

  @override
  State<ThanksNoteScreen> createState() => _ThanksNoteScreenState();
}

class _ThanksNoteScreenState extends State<ThanksNoteScreen> {
  final _partnerController = TextEditingController();
  final _amountController = TextEditingController();
  
  // Referral specific controllers and states
  String _referralType = "Self";
  final _referralNameController = TextEditingController();
  final _referralPhoneController = TextEditingController();
  final _referralBusinessController = TextEditingController();

  bool _isGiven = true;

  @override
  void dispose() {
    _partnerController.dispose();
    _amountController.dispose();
    _referralNameController.dispose();
    _referralPhoneController.dispose();
    _referralBusinessController.dispose();
    super.dispose();
  }

  void _submitThanksNote() {
    double amount = 0.0;
    if (!_isGiven) {
      final amountStr = _amountController.text.trim();
      if (amountStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill in the business amount!"),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      final parsedAmount = double.tryParse(amountStr.replaceAll(",", ""));
      if (parsedAmount == null || parsedAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid numeric business amount!"),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
      amount = parsedAmount;
    }

    String memberName = "";
    String businessName = "";

    if (_isGiven) {
      if (_referralType == "Other") {
        memberName = _referralNameController.text.trim();
        final phone = _referralPhoneController.text.trim();
        businessName = _referralBusinessController.text.trim();

        if (memberName.isEmpty || phone.isEmpty || businessName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in Referral Name, Phone No, and Business Name!"),
              backgroundColor: AppTheme.error,
            ),
          );
          return;
        }
      } else {
        // Self Referral
        memberName = MockData.currentUser.name;
        businessName = MockData.currentUser.businessName;
      }
    } else {
      memberName = _partnerController.text.trim();
      if (memberName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please search and select a partner!"),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
      businessName = memberName.contains(" ") ? memberName : "$memberName Business Solutions";
    }

    // Add mock note
    final newNote = ThanksNote(
      id: "TXN${Random().nextInt(900) + 100}",
      memberName: memberName,
      businessName: businessName,
      amount: amount,
      isGiven: _isGiven,
      date: DateTime.now().toString().split(" ")[0],
      attachmentName: null,
      referralType: _isGiven ? _referralType : null,
      referralPhone: _isGiven ? (_referralType == "Other" ? _referralPhoneController.text.trim() : MockData.currentUser.phone) : null,
    );

    setState(() {
      MockData.thanksNotes.insert(0, newNote);
      _partnerController.clear();
      _amountController.clear();
      _referralNameController.clear();
      _referralPhoneController.clear();
      _referralBusinessController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(_isGiven
                ? "Referal successfully submitted!"
                : "Thanks Note successfully submitted!"),
          ],
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-calculate sum dynamically
    double totalGiven = 0;
    double totalTaken = 0;
    for (var note in MockData.thanksNotes) {
      if (note.isGiven) {
        totalGiven += note.amount;
      } else {
        totalTaken += note.amount;
      }
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Financial Totals Header Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.border, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card, color: AppTheme.success, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Total Given",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹ ${_formatCurrency(totalGiven)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(height: 40, width: 1, color: AppTheme.border),
                  Expanded(
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, color: AppTheme.primary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Total Taken",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹ ${_formatCurrency(totalTaken)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Add Thanks Note Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Add Thanksnote",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Segmented Slide Toggle Switch
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Stack(
                      children: [
                        // Sliding indicator background
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: _isGiven ? Alignment.centerLeft : Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                        // Buttons text
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isGiven = true),
                                child: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 16,
                                        color: _isGiven ? Colors.white : AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Referal",
                                        style: TextStyle(
                                          color: _isGiven ? Colors.white : AppTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isGiven = false),
                                child: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 16,
                                        color: !_isGiven ? Colors.white : AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Thank You note",
                                        style: TextStyle(
                                          color: !_isGiven ? Colors.white : AppTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isGiven) ...[
                    DropdownButtonFormField<String>(
                      value: _referralType,
                      items: const [
                        DropdownMenuItem(
                          value: "Self",
                          child: Text("Self", style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                        ),
                        DropdownMenuItem(
                          value: "Other",
                          child: Text("Other", style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _referralType = val ?? "Self";
                        });
                      },
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                      decoration: InputDecoration(
                        labelText: "Referral Type",
                        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Search Input / Referral Details Inputs
                  if (!_isGiven) ...[
                    TextField(
                      controller: _partnerController,
                      decoration: InputDecoration(
                        hintText: "Search Name / Phone / Business",
                        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.person_search_outlined, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (_referralType == "Other") ...[
                    // Referal Name
                    TextField(
                      controller: _referralNameController,
                      decoration: InputDecoration(
                        hintText: "Referal Name",
                        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone No
                    TextField(
                      controller: _referralPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Phone No",
                        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Business Name
                    TextField(
                      controller: _referralBusinessController,
                      decoration: InputDecoration(
                        hintText: "Business Name",
                        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.business_outlined, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Business Amount Input
                  if (!_isGiven) ...[
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Business Amount (₹)",
                        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.currency_rupee, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitThanksNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 1,
                    ),
                    child: Text(
                      _isGiven ? "Submit Referal" : "Submit Thanksnote",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // View History button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThanksNoteHistoryScreen()),
              ).then((_) {
                // Re-render when coming back in case notes were edited/deleted
                setState(() {});
              });
            },
            icon: const Icon(
              Icons.visibility_outlined,
              size: 18,
            ),
            label: const Text("View Thanksnote History"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
}
