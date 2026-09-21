import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/common/app_snack_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController;
  late TextEditingController _companyPhoneController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _selectedImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    _selectedImagePath = user?.avatarPath;
    _companyNameController = TextEditingController(
      text: (user?.companyName.isNotEmpty ?? false)
          ? user!.companyName
          : (kDebugMode ? 'testeing' : ''),
    );
    _companyPhoneController = TextEditingController();
    _fullNameController = TextEditingController(
      text: (user?.fullName.isNotEmpty ?? false)
          ? user!.fullName
          : (kDebugMode ? 'mohamed hany' : ''),
    );
    _phoneController = TextEditingController(
      text: (user?.phone.isNotEmpty ?? false)
          ? user!.phone
          : (kDebugMode ? '+201145330378' : ''),
    );
    _emailController = TextEditingController(
      text: (user?.email.isNotEmpty ?? false)
          ? user!.email
          : (kDebugMode ? 'mohamedfcis2000@gmail.com' : ''),
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyPhoneController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authCubit = context.read<AuthCubit>();
      final isAr = context.read<LocaleCubit>().state == 'ar';

      setState(() => _isSaving = true);
      await Future.delayed(const Duration(milliseconds: 600));

      await authCubit.updateUserProfile(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        companyName: _companyNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.showSuccess(
          context,
          message: isAr ? 'تم حفظ التغييرات بنجاح!' : 'Profile updated successfully!',
        );
      }
    }
  }

  void _resetChanges() {
    final authState = context.read<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    setState(() {
      _companyNameController.text = (user?.companyName.isNotEmpty ?? false)
          ? user!.companyName
          : (kDebugMode ? 'testeing' : '');
      _companyPhoneController.text = '';
      _fullNameController.text = (user?.fullName.isNotEmpty ?? false)
          ? user!.fullName
          : (kDebugMode ? 'mohamed hany' : '');
      _phoneController.text = (user?.phone.isNotEmpty ?? false)
          ? user!.phone
          : (kDebugMode ? '+201145330378' : '');
      _emailController.text = (user?.email.isNotEmpty ?? false)
          ? user!.email
          : (kDebugMode ? 'mohamedfcis2000@gmail.com' : '');
      _selectedImagePath = user?.avatarPath;
    });

    final isAr = context.read<LocaleCubit>().state == 'ar';
    AppSnackBar.showInfo(
      context,
      message: isAr ? 'تم تجاهل التغييرات' : 'Changes discarded',
    );
  }

  Future<void> _pickImage([ImageSource source = ImageSource.gallery]) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');

        setState(() {
          _selectedImagePath = savedImage.path;
        });

        if (mounted) {
          context.read<AuthCubit>().updateUserAvatar(savedImage.path);
          final isAr = context.read<LocaleCubit>().state == 'ar';
          AppSnackBar.showSuccess(
            context,
            message: isAr ? 'تم اختيار وتحديث الصورة بنجاح' : 'Image selected and updated successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final isAr = context.read<LocaleCubit>().state == 'ar';
        AppSnackBar.showError(
          context,
          message: isAr ? 'تعذر اختيار الصورة من المعرض' : 'Failed to pick image from gallery',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final isAr = locale == 'ar';

    final surfaceBg = isDark ? const Color(0xFF131A31) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2A4A) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF0F1426) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAr ? 'الملف الشخصي' : 'Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Main Content Area: Responsive 2-Column / Stack
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                final imageCard = _buildImageUploadCard(surfaceBg, borderColor, isDark, isAr);
                final detailsCard = _buildDetailsCard(surfaceBg, borderColor, inputBg, isDark, isAr);

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Right Side in RTL: Details Form Card
                      Expanded(
                        flex: 6,
                        child: detailsCard,
                      ),
                      const SizedBox(width: 20),
                      // Left Side in RTL: Image Upload Card
                      Expanded(
                        flex: 4,
                        child: imageCard,
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      imageCard,
                      const SizedBox(height: 20),
                      detailsCard,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(Color surfaceBg, Color borderColor, bool isDark, bool isAr) {
    final hasImage = _selectedImagePath != null &&
        _selectedImagePath!.isNotEmpty &&
        File(_selectedImagePath!).existsSync();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          // Circular Avatar with Image or Placeholder
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF0F1426) : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: hasImage ? const Color(0xFF2563EB) : borderColor,
                      width: 2,
                    ),
                    boxShadow: hasImage
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? Image.file(
                            File(_selectedImagePath!),
                            width: 104,
                            height: 104,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 38,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 38,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: surfaceBg,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      hasImage ? Icons.edit_rounded : Icons.photo_camera_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dashed Dropzone Box (Tappable for Gallery)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _pickImage(ImageSource.gallery),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1426) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasImage
                        ? const Color(0xFF2563EB)
                        : (isDark ? const Color(0xFF2A3A60) : const Color(0xFFCBD5E1)),
                    style: BorderStyle.solid,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      hasImage ? Icons.check_circle_rounded : Icons.photo_library_outlined,
                      size: 32,
                      color: hasImage ? AppColors.success : const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasImage
                          ? (isAr ? 'تم اختيار صورة من المعرض' : 'Photo selected from gallery')
                          : (isAr ? 'اسحب وأفلت صورتك هنا' : 'Drag and drop your image here'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasImage
                            ? (isDark ? AppColors.darkText : AppColors.lightText)
                            : (isDark ? Colors.white70 : AppColors.brandNavy),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasImage
                          ? (isAr ? 'اضغط لتغيير الصورة من المعرض' : 'Tap to choose another from gallery')
                          : (isAr ? 'أو اضغط للاستعراض من المعرض' : 'or click to browse gallery'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: hasImage
                            ? const Color(0xFF2563EB)
                            : (isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint),
                        fontWeight: hasImage ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Upload Submit Button (إرسال)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isUploadingImage
                ? null
                : () async {
                    if (!hasImage) {
                      await _pickImage(ImageSource.gallery);
                      return;
                    }
                    setState(() => _isUploadingImage = true);
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (mounted) {
                      final authCubit = context.read<AuthCubit>();
                      await authCubit.updateUserAvatar(_selectedImagePath!);
                      if (mounted) {
                        setState(() => _isUploadingImage = false);
                        AppSnackBar.showSuccess(
                          context,
                          message: isAr ? 'تم تحديث وحفظ الصورة الشخصية بنجاح' : 'Profile photo updated successfully',
                        );
                      }
                    }
                  },
            child: _isUploadingImage
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isAr ? 'إرسال' : 'Upload',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(
    Color surfaceBg,
    Color borderColor,
    Color inputBg,
    bool isDark,
    bool isAr,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 Header: تفاصيل الشركه
            Row(
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 18,
                  color: isDark ? Colors.white70 : AppColors.brandNavy,
                ),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'تفاصيل الشركه' : 'Company Details',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.brandNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Company Name & Company Phone
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Name
                Expanded(
                  child: _buildTextField(
                    label: isAr ? 'اسم الشركة' : 'Company Name',
                    isRequired: true,
                    controller: _companyNameController,
                    hintText: isAr ? 'اسم الشركة' : 'Company Name',
                    prefixIcon: Icons.business_center_outlined,
                    isDark: isDark,
                    inputBg: inputBg,
                    borderColor: borderColor,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? (isAr ? 'اسم الشركة مطلوب' : 'Company name is required')
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Company Phone
                Expanded(
                  child: _buildTextField(
                    label: isAr ? 'هاتف الشركة' : 'Company Phone',
                    isRequired: false,
                    controller: _companyPhoneController,
                    hintText: isAr ? 'هاتف الشركة' : 'Company Phone',
                    prefixIcon: Icons.phone_outlined,
                    isDark: isDark,
                    inputBg: inputBg,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 2 Header: تفاصيل شخصيه
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: isDark ? Colors.white70 : AppColors.brandNavy,
                ),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'تفاصيل شخصيه' : 'Personal Details',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.brandNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Full Name & Phone Number
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                Expanded(
                  child: _buildTextField(
                    label: isAr ? 'الاسم الكامل' : 'Full Name',
                    isRequired: true,
                    controller: _fullNameController,
                    hintText: isAr ? 'الاسم الكامل' : 'Full Name',
                    prefixIcon: Icons.person_outline_rounded,
                    isDark: isDark,
                    inputBg: inputBg,
                    borderColor: borderColor,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? (isAr ? 'الاسم الكامل مطلوب' : 'Full name is required')
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Phone Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: isAr ? 'رقم الهاتف' : 'Phone Number',
                        isRequired: false,
                        controller: _phoneController,
                        hintText: isAr ? 'رقم الهاتف' : 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                        isDark: isDark,
                        inputBg: inputBg,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAr
                            ? 'يُستخدم للتحقق من تسجيل الدخول واستعادة الحساب'
                            : 'Used for login verification and account recovery',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email Address
            _buildTextField(
              label: isAr ? 'البريد الالكتروني' : 'Email Address',
              isRequired: true,
              controller: _emailController,
              hintText: isAr ? 'البريد الالكتروني' : 'Email Address',
              prefixIcon: Icons.email_outlined,
              isDark: isDark,
              inputBg: inputBg,
              borderColor: borderColor,
              validator: (v) => (v == null || !v.contains('@'))
                  ? (isAr ? 'البريد الإلكتروني غير صحيح' : 'Invalid email address')
                  : null,
            ),
            const SizedBox(height: 24),

            // Bottom Actions (حفظ التغيرات, تجاهل التغيرات)
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    isAr ? 'حفظ التغيرات' : 'Save Changes',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  onPressed: _isSaving ? null : _saveChanges,
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _resetChanges,
                  child: Text(
                    isAr ? 'تجاهل التغيرات' : 'Discard Changes',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    required Color inputBg,
    required Color borderColor,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(

            text: label,
            style: TextStyle(

            fontFamily: 'Cairo',

              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            children: isRequired
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontSize: 13.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 18,
              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
