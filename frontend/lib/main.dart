import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'screens/home_screen.dart';
import 'screens/directory_screen.dart';
import 'screens/thanks_note_screen.dart';
import 'screens/meeting_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/r_to_r_form_screen.dart';
import 'screens/referral_list_screen.dart';
import 'screens/splash_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final startTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (loggedIn) {
      final name = prefs.getString('userName');
      final phone = prefs.getString('userPhone');
      final businessName = prefs.getString('userBusinessName');
      final nativeAddress = prefs.getString('userPoints') ?? "150 Points";
      if (name != null && phone != null && businessName != null) {
        MockData.currentUser = Member(
          name: name,
          phone: phone,
          businessName: businessName,
          chapter: "UNITY Team",
          location: "Settaikara Chettangal",
          bloodGroup: "B+",
          nativeAddress: nativeAddress,
          email: "${name.toLowerCase().replaceAll(' ', '')}@gmail.com",
          fatherName: "N/A",
          spouseName: "N/A",
          education: "N/A",
          profileImage: null,
          isPro: true,
          kootam: "Unity",
        );
      }
    }
    
    // Ensure splash screen shows for at least 2.5 seconds (2500 ms)
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(milliseconds: 2500) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  Future<void> _setLoginStatus(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', loggedIn);
    if (!loggedIn) {
      await prefs.remove('userName');
      await prefs.remove('userPhone');
      await prefs.remove('userBusinessName');
      await prefs.remove('userPoints');
    } else {
      await prefs.setString('userName', MockData.currentUser.name);
      await prefs.setString('userPhone', MockData.currentUser.phone);
      await prefs.setString('userBusinessName', MockData.currentUser.businessName);
      await prefs.setString('userPoints', MockData.currentUser.nativeAddress);
    }
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'Rmbf',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      );
    }

    return MaterialApp(
      title: 'Rmbf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoggedIn
          ? MainShell(
              onLogout: () {
                _setLoginStatus(false);
              },
            )
          : LoginScreen(
              onLoginSuccess: () {
                _setLoginStatus(true);
              },
            ),
    );
  }
}

class MainShell extends StatefulWidget {
  final VoidCallback onLogout;
  const MainShell({super.key, required this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Navigation pages list
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onNavigateToThanks: () {
        setState(() {
          _currentIndex = 2; // Index of Thanks Note
        });
      }),
      const DirectoryScreen(),
      const ThanksNoteScreen(),
      const MeetingScreen(),
      ProfileScreen(onLogout: widget.onLogout),
    ];
  }

  Future<bool?> _showExitConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Tapping outside must not dismiss it
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Exit App",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          content: const Text("Are you sure you want to exit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "No",
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Yes", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "RMBF Dashboard";
      case 1:
        return "Member Directory";
      case 2:
        return "Thanks Note Activity";
      case 3:
        return "Meetings & Events";
      case 4:
        return "My Member Profile";
      default:
        return "Rmbf";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          final shouldExit = await _showExitConfirmationDialog();
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        onDrawerChanged: (isOpened) => FocusManager.instance.primaryFocus?.unfocus(),
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.border, height: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications"), backgroundColor: AppTheme.primary),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        child: Container(
          color: AppTheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drawer Header with Dark Blue Gradient matching guidelines
              Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MemberAvatar(
                          name: user.name,
                          radius: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.chapter,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Navigation Items with Icons
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.calendar_today_outlined,
                      title: "Apply Leave",
                      onTap: () {
                        Navigator.pop(context);
                        _showDrawerActionDialog("Apply Leave", const LeaveFormDialog());
                      },
                    ),

                    _buildDrawerItem(
                      icon: Icons.gavel_outlined,
                      title: "RMBF By-Laws",
                      onTap: () {
                        Navigator.pop(context);
                        _showDrawerActionDialog("RMBF By-Laws", const ByLawsDialog());
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.handshake_outlined,
                      title: "R to R Form",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RtoRFormScreen()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.description_outlined,
                      title: "Referral",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReferralListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Logout Area with distinct design (red button)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onLogout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FadeIndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home, "Home"),
                    _buildNavItem(1, Icons.people_outline, Icons.people, "Directory"),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 30), // Fixed height matching icon slot
                            const SizedBox(height: 6),
                            Text(
                              "Thanks Note",
                              style: TextStyle(
                                color: _currentIndex == 2 ? AppTheme.primary : AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: _currentIndex == 2 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildNavItem(3, Icons.business_center_outlined, Icons.business_center, "Meeting"),
                    _buildNavItem(4, Icons.person_outline, Icons.person, "Profile"),
                  ],
                ),
              ),
            ),
          ),
          
          // Uplifted floating action button logo
          Positioned(
            top: -16, // uplifted by 16 pixels to float above curves
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 2),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _currentIndex == 2 ? AppTheme.goldGradient : AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: (_currentIndex == 2 ? AppTheme.secondary : AppTheme.primary).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.note_add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 20),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primary : AppTheme.textSecondary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30, // Fixed height for icon slot to push text down
              child: Center(
                child: Icon(isSelected ? solidIcon : outlineIcon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showDrawerActionDialog(String title, Widget body) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          content: SingleChildScrollView(child: body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        );
      },
    );
  }
}

// Sub-widgets for Drawer actions dialog layouts

class LeaveFormDialog extends StatefulWidget {
  const LeaveFormDialog({super.key});

  @override
  State<LeaveFormDialog> createState() => _LeaveFormDialogState();
}

class _LeaveFormDialogState extends State<LeaveFormDialog> {
  static bool _isLeaveApplied = false;
  static String _selectedMeeting = "";

  late final TextEditingController _meetingController;

  @override
  void initState() {
    super.initState();
    _meetingController = TextEditingController(text: _selectedMeeting);
  }

  @override
  void dispose() {
    _meetingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLeaveApplied) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      "Leave Request Applied",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    children: [
                      const TextSpan(
                        text: "Meeting Name: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: _selectedMeeting),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLeaveApplied = false;
                _selectedMeeting = "";
                _meetingController.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Leave request cancelled successfully."),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text("Cancel Leave", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Meeting Name", style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: _meetingController,
          decoration: InputDecoration(
            hintText: "Enter meeting name",
            hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final meetingName = _meetingController.text.trim();
            if (meetingName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please enter a meeting name!"),
                  backgroundColor: AppTheme.error,
                ),
              );
              return;
            }
            setState(() {
              _isLeaveApplied = true;
              _selectedMeeting = meetingName;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Leave applied for $meetingName!"),
                backgroundColor: AppTheme.success,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text("Apply Leave", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}



class ByLawsDialog extends StatelessWidget {
  const ByLawsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1. Attendance Policies",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
        ),
        SizedBox(height: 4),
        Text(
          "Members must maintain at least 80% attendance. Leave must be filed 24 hours prior via the app.",
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        SizedBox(height: 12),
        Text(
          "2. Referral Integrity",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
        ),
        SizedBox(height: 4),
        Text(
          "All referrals passed must follow the G to G standard. Real-time updates required on thanks notes.",
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}



class FadeIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(children.length, (idx) {
        final isSelected = idx == index;
        return IgnorePointer(
          ignoring: !isSelected,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: duration,
            curve: Curves.easeInOut,
            child: children[idx],
          ),
        );
      }),
    );
  }
}
