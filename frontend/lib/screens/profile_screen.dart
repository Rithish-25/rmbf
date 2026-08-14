import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUrl = 'data:image/png;base64,$base64String';

        setState(() {
          MockData.currentUser = MockData.currentUser.copyWith(profileImage: dataUrl);
        });

        _showSnack("Profile photo updated successfully!", AppTheme.success);
      }
    } catch (e) {
      _showSnack("Failed to pick image: $e", AppTheme.error);
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        width: 280,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editTextField({
    required String label,
    required String currentValue,
    required ValueChanged<String> onSave,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Edit $label",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
            maxLength: label == "Mobile Number" ? 10 : null,
            autofocus: true,
            minLines: maxLines,
            maxLines: maxLines,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: "Enter $label",
              counterText: "",
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              errorMaxLines: 2,
            ),
            validator: validator,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentValue) {
      setState(() => onSave(result));
      _showSnack("$label updated successfully!", AppTheme.success);
    }
  }

  Future<void> _editDateField({
    required String label,
    required String currentValue,
    required ValueChanged<String> onSave,
  }) async {
    final initialDate = DateTime.tryParse(currentValue) ?? DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      if (formatted != currentValue) {
        setState(() => onSave(formatted));
        _showSnack("$label updated successfully!", AppTheme.success);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Profile Avatar with edit upload functionality
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                MemberAvatar(
                  name: user.name,
                  radius: 55,
                  profileImage: user.profileImage,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Power Meeting Name
          if (user.powerMeetingName.isNotEmpty) ...[
            Text(
              user.powerMeetingName.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Name and Tagline
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.businessName,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Position
          if (user.position.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.position,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primary.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Profile Details Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.phone_iphone_outlined,
                      "Mobile Number",
                      user.phone,
                      onEdit: () => _editTextField(
                        label: "Mobile Number",
                        currentValue: user.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Mobile number cannot be empty";
                          }
                          if (!RegExp(r'^[1-9]\d{9}$').hasMatch(value.trim())) {
                            return "10 digits only, cannot start with 0";
                          }
                          return null;
                        },
                        onSave: (v) => MockData.currentUser = MockData.currentUser.copyWith(phone: v),
                      ),
                    ),
                    _buildInfoRow(
                      Icons.cake_outlined,
                      "Date of Birth",
                      user.dob,
                      onEdit: () => _editDateField(
                        label: "Date of Birth",
                        currentValue: user.dob,
                        onSave: (v) => MockData.currentUser = MockData.currentUser.copyWith(dob: v),
                      ),
                    ),
                    _buildInfoRow(
                      Icons.favorite_border,
                      "Wedding Day",
                      user.weddingDay,
                      iconColor: Colors.redAccent,
                      onEdit: () => _editDateField(
                        label: "Wedding Day",
                        currentValue: user.weddingDay,
                        onSave: (v) => MockData.currentUser = MockData.currentUser.copyWith(weddingDay: v),
                      ),
                    ),
                    _buildInfoRow(
                      Icons.storefront_outlined,
                      "Company Open Day",
                      user.companyOpenDay,
                      onEdit: () => _editDateField(
                        label: "Company Open Day",
                        currentValue: user.companyOpenDay,
                        onSave: (v) => MockData.currentUser = MockData.currentUser.copyWith(companyOpenDay: v),
                      ),
                    ),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      "Office Address",
                      user.officeAddress,
                      onEdit: () => _editTextField(
                        label: "Office Address",
                        currentValue: user.officeAddress,
                        maxLines: 4,
                        onSave: (v) => MockData.currentUser = MockData.currentUser.copyWith(officeAddress: v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color iconColor = AppTheme.textSecondary,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "Not set" : value,
                  style: TextStyle(
                    color: value.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
              onPressed: onEdit,
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
