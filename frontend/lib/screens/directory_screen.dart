import 'package:flutter/material.dart';
import '../theme.dart';
import '../language_service.dart';
import '../models.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = "";

  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter and search list
    final filteredMembers = MockData.members.where((member) {
      if (_searchQuery.trim().isEmpty) return true;
      final queryWords = _searchQuery.toLowerCase().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
      return queryWords.every((word) {
        return member.name.toLowerCase().contains(word) ||
            member.businessName.toLowerCase().contains(word) ||
            member.phone.contains(word) ||
            member.location.toLowerCase().contains(word) ||
            member.nativeAddress.toLowerCase().contains(word) ||
            member.bloodGroup.toLowerCase().contains(word) ||
            member.kootam.toLowerCase().contains(word);
      });
    }).toList();

    return Column(
      children: [
        // Search Header (Modern, clean, search-first)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: t("Search by Name, Business, Phone..."),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),

            ],
          ),
        ),

        // List
        Expanded(
          child: filteredMembers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  physics: const ClampingScrollPhysics(),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    
                    // Simple staggered fade/slide list transition
                    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _listController,
                        curve: Interval(
                          (index / filteredMembers.length).clamp(0.0, 1.0),
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    );

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: animation.value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - animation.value) * 30),
                            child: child,
                          ),
                        );
                      },
                      child: _buildMemberCard(context, member),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            t("No members found"),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            t("Try adjusting your search filters"),
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Member member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      child: InkWell(
        onTap: () => _showMemberDetailDialog(context, member),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              MemberAvatar(
                name: member.name,
                radius: 30,
                profileImage: member.profileImage,
              ),
              const SizedBox(width: 16),
              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            t(member.name),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (member.isPro) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "PRO",
                              style: TextStyle(
                                color: AppTheme.secondary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t(member.businessName),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildContactBtn(
                    icon: Icons.phone,
                    color: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _buildContactBtn(
                    iconWidget: const WhatsAppIconWidget(size: 18, color: Color(0xFF15803D)),
                    color: const Color(0xFFDCFCE7),
                    iconColor: const Color(0xFF15803D),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactBtn({
    IconData? icon,
    Widget? iconWidget,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: iconWidget ?? Icon(icon, color: iconColor, size: 18),
        ),
      ),
    );
  }

  void _showMemberDetailDialog(BuildContext context, Member member) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss Profile",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Scale and fade transition
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        final opacity = animation;

        return FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: scale,
            child: MemberDetailDialog(member: member),
          ),
        );
      },
    );
  }
}

// Dialog Popup implementation corresponding to Screen 6
class MemberDetailDialog extends StatefulWidget {
  final Member member;
  const MemberDetailDialog({super.key, required this.member});

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  bool _isPersonal = true;

  @override
  Widget build(BuildContext context) {
    final m = widget.member;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Card Content Container
            Material(
              color: Colors.white,
              elevation: 8,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Member Name
                    Text(
                      t(m.name),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${t("Kootam")}: ${t(m.kootam)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Custom Segmented Switch (Personal vs Business)
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPersonal = true;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: _isPersonal ? AppTheme.primaryGradient : null,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: _isPersonal ? Colors.white : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        t("Personal"),
                                        style: TextStyle(
                                          color: _isPersonal ? Colors.white : AppTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPersonal = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: !_isPersonal ? AppTheme.primaryGradient : null,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.business,
                                      size: 16,
                                      color: !_isPersonal ? Colors.white : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        t("Business"),
                                        style: TextStyle(
                                          color: !_isPersonal ? Colors.white : AppTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Switch Details (Slide transition placeholder via animated switcher)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: _isPersonal
                          ? _buildPersonalDetails(m)
                          : _buildBusinessDetails(m),
                    ),
                  ],
                ),
              ),
            ),

            // Top Overlapping Avatar
            Positioned(
              top: -45,
              child: MemberAvatar(
                name: m.name,
                radius: 45,
                profileImage: m.profileImage,
              ),
            ),

            // Redesigned Close Button (overlapping top right)
            Positioned(
              top: 15,
              right: 15,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetails(Member m) {
    return Column(
      key: const ValueKey("personal_tab"),
      children: [
        _buildDetailRow(Icons.email_outlined, "Email", m.email),
        _buildDetailRow(Icons.phone_outlined, "Phone", m.phone),
        _buildDetailRow(Icons.bloodtype_outlined, "Blood Group", m.bloodGroup, iconColor: Colors.redAccent),
        _buildDetailRow(Icons.person_outline, "Father Name", m.fatherName),
        _buildDetailRow(Icons.favorite_border, "Spouse Name", m.spouseName),
        _buildDetailRow(Icons.school_outlined, "Education", m.education),
        _buildDetailRow(Icons.stars_outlined, "Points Balance", m.nativeAddress, iconColor: AppTheme.secondary),
      ],
    );
  }

  Widget _buildBusinessDetails(Member m) {
    return Column(
      key: const ValueKey("business_tab"),
      children: [
        _buildDetailRow(Icons.business_outlined, "Business Name", m.businessName),
        _buildDetailRow(Icons.work_outline, "Industry", "Construction & Design"),
        _buildDetailRow(Icons.location_on_outlined, "Location", m.location),
        _buildDetailRow(Icons.description_outlined, "Designation", "Partner / MD"),
        _buildDetailRow(Icons.language_outlined, "Website", "www.${m.name.toLowerCase().replaceAll(' ', '')}.com"),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color iconColor = AppTheme.textSecondary}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(
            t(label),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              t(value.isEmpty ? "N/A" : value),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsAppIconWidget extends StatelessWidget {
  final double size;
  final Color color;

  const WhatsAppIconWidget({
    Key? key,
    this.size = 24.0,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WhatsAppPainter(color),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final Color color;

  _WhatsAppPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;
    canvas.scale(scaleX, scaleY);

    final path = Path()
      ..moveTo(12.012, 2.0)
      ..cubicTo(6.506, 2.0, 2.024, 6.482, 2.024, 11.988)
      ..cubicTo(2.024, 13.749, 2.483, 15.467, 3.356, 16.994)
      ..lineTo(2.0, 22.0)
      ..lineTo(7.166, 20.646)
      ..cubicTo(8.638, 21.448, 10.291, 21.872, 12.012, 21.872)
      ..cubicTo(17.518, 21.872, 22.0, 17.39, 22.0, 11.988)
      ..cubicTo(22.0, 6.482, 17.518, 2.0, 12.012, 2.0)
      ..close()
      ..moveTo(18.071, 15.904)
      ..cubicTo(17.811, 16.636, 16.789, 17.232, 16.289, 17.312)
      ..cubicTo(15.814, 17.388, 15.306, 17.442, 13.239, 16.588)
      ..cubicTo(10.594, 15.496, 8.911, 12.806, 8.779, 12.631)
      ..cubicTo(8.647, 12.456, 7.702, 11.198, 7.702, 9.901)
      ..cubicTo(7.702, 8.603, 8.382, 7.964, 8.624, 7.704)
      ..cubicTo(8.866, 7.444, 9.152, 7.378, 9.328, 7.378)
      ..cubicTo(9.504, 7.378, 9.68, 7.38, 9.834, 7.388)
      ..cubicTo(9.998, 7.396, 10.218, 7.326, 10.436, 7.852)
      ..cubicTo(10.656, 8.38, 11.188, 9.684, 11.254, 9.816)
      ..cubicTo(11.32, 9.948, 11.364, 10.102, 11.276, 10.278)
      ..cubicTo(11.188, 10.454, 11.144, 10.564, 11.012, 10.718)
      ..cubicTo(10.88, 10.872, 10.735, 11.061, 10.616, 11.18)
      ..cubicTo(10.484, 11.312, 10.348, 11.455, 10.502, 11.719)
      ..cubicTo(10.656, 11.983, 11.185, 12.846, 11.966, 13.54)
      ..cubicTo(12.956, 14.422, 13.79, 14.697, 14.054, 14.829)
      ..cubicTo(14.318, 14.961, 14.472, 14.939, 14.626, 14.763)
      ..cubicTo(14.78, 14.587, 15.286, 13.993, 15.462, 13.729)
      ..cubicTo(15.638, 13.465, 15.814, 13.509, 16.056, 13.597)
      ..cubicTo(16.298, 13.685, 17.596, 14.323, 17.86, 14.455)
      ..cubicTo(18.124, 14.587, 18.3, 14.653, 18.366, 14.763)
      ..cubicTo(18.432, 14.873, 18.432, 15.401, 18.172, 16.136)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
