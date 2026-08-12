import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onLoginSuccess;
  final Map<String, String>? signupDetails;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.onLoginSuccess,
    this.signupDetails,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    setState(() {
      _errorMessage = null;
    });

    final otpCode = _controllers.map((c) => c.text.trim()).join();

    if (otpCode.length != 4) {
      setState(() {
        _errorMessage = "Please enter the complete 4-digit OTP";
      });
      return;
    }

    // Accepts any 4-digit OTP for development as requested
    final otpRegex = RegExp(r'^\d{4}$');
    if (!otpRegex.hasMatch(otpCode)) {
      setState(() {
        _errorMessage = "Please enter a valid numeric OTP code";
      });
      return;
    }

    // OTP is valid! Log user in
    // If signupDetails are present, dynamically construct and overwrite currentUser!
    if (widget.signupDetails != null) {
      final name = widget.signupDetails!['name']!;
      final phone = widget.signupDetails!['phone']!;
      final businessName = widget.signupDetails!['businessName']!;

      MockData.currentUser = Member(
        name: name,
        phone: phone,
        businessName: businessName,
        chapter: "UNITY Team", 
        location: "Settaikara Chettangal", 
        bloodGroup: "O+", 
        nativeAddress: "0 Points", 
        email: "${name.toLowerCase().replaceAll(' ', '')}@gmail.com",
        fatherName: "N/A",
        spouseName: "N/A",
        education: "N/A",
        profileImage: null,
        isPro: true,
        kootam: "Unity",
      );
    } else {
      // Find the existing member details by phone number
      final matchingMember = MockData.members.firstWhere(
        (m) => m.phone == widget.phoneNumber,
        orElse: () => MockData.currentUser,
      );
      MockData.currentUser = matchingMember;
    }

    // Pop the navigation stack to remove LoginScreen and OtpScreen from history
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("OTP Verification"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Subtitle information
              Text(
                "Verify Mobile Number",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontFamily: AppTheme.lightTheme.textTheme.headlineLarge?.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Enter the 4-digit code sent to +91 ${widget.phoneNumber}",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // OTP Input Boxes Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 50,
                            height: 60,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.border),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    _focusNodes[index].unfocus();
                                  }
                                } else {
                                  if (index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Verify and Login",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Resend text option
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Verification code resent successfully!"),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
                child: const Text(
                  "Didn't receive code? Resend OTP",
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
