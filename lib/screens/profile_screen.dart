import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upload_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool redirectToUpload;

  const ProfileScreen({super.key, this.redirectToUpload = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _congregationController = TextEditingController();
  final _districtController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedRole = 'Organist / Keyboardist';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _roles = [
    'Organist / Keyboardist',
    'Chorister / Choir Director',
    'Pastor / Catechist',
    'Presbyter / Elder',
    'Church Member',
  ];

  static const Color pcgBlue = Color(0xFF1565C0);
  static const Color pcgDarkBlue = Color(0xFF0D47A1);
  static const Color pcgTeal = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _congregationController.dispose();
    _districtController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _congregationController.text = prefs.getString('user_congregation') ?? '';
      _districtController.text = prefs.getString('user_district') ?? '';
      _contactController.text = prefs.getString('user_contact') ?? '';
      final savedRole = prefs.getString('user_role');
      if (savedRole != null && _roles.contains(savedRole)) {
        _selectedRole = savedRole;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_congregation', _congregationController.text.trim());
    await prefs.setString('user_district', _districtController.text.trim());
    await prefs.setString('user_role', _selectedRole);
    await prefs.setString('user_contact', _contactController.text.trim());

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Profile saved successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (widget.redirectToUpload) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UploadScreen()),
      );
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributor Profile'),
        elevation: 0,
        backgroundColor: pcgBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [pcgBlue, pcgDarkBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: pcgBlue.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/cover.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedBuilder(
                            animation: Listenable.merge([_nameController, _congregationController]),
                            builder: (context, _) {
                              final displayName = _nameController.text.trim().isNotEmpty
                                  ? _nameController.text.trim()
                                  : 'Aminu Amos';
                              final displayCong = _congregationController.text.trim().isNotEmpty
                                  ? _congregationController.text.trim()
                                  : 'PCG: Van Den Broek Memorial Congregation';

                              return Column(
                                children: [
                                  Text(
                                    displayName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayCong,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Text(
                              _selectedRole,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (widget.redirectToUpload) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: pcgTeal.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: pcgTeal.withValues(alpha: 0.35)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: pcgTeal),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Complete your name and congregation below to proceed to the Hymn Audio Uploads screen.',
                                style: TextStyle(fontSize: 13, color: pcgTeal, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Text(
                      'Personal & Congregation Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Full Name Input
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name / Contributor Name',
                        hintText: 'Aminu Amos',
                        prefixIcon: const Icon(Icons.person_rounded, color: pcgBlue),
                        helperText: 'Your name as it will appear on your uploaded hymns',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name (e.g., Aminu Amos)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Congregation Input
                    TextFormField(
                      controller: _congregationController,
                      decoration: InputDecoration(
                        labelText: 'Congregation / Local Church',
                        hintText: 'PCG: Van Den Broek Memorial Congregation',
                        prefixIcon: const Icon(Icons.church_rounded, color: pcgBlue),
                        helperText: 'e.g. PCG: Van Den Broek Memorial Congregation',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your congregation name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Presbytery / District Input
                    TextFormField(
                      controller: _districtController,
                      decoration: InputDecoration(
                        labelText: 'Presbytery / District',
                        hintText: 'Northern Presbytery',
                        prefixIcon: const Icon(Icons.location_city_rounded, color: pcgBlue),
                        helperText: 'Your church district or presbytery',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // Role / Ministry Selector
                    const Text(
                      'Church Role / Ministry',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _roles.map((role) {
                        final isSelected = _selectedRole == role;
                        return ChoiceChip(
                          label: Text(role),
                          selected: isSelected,
                          selectedColor: pcgBlue.withValues(alpha: 0.18),
                          labelStyle: TextStyle(
                            color: isSelected ? pcgBlue : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedRole = role);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Phone / Contact (Optional)
                    TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone / Contact (Optional)',
                        hintText: 'e.g. 0244123456',
                        prefixIcon: const Icon(Icons.phone_rounded, color: pcgBlue),
                        helperText: 'Optional contact for church choir/media inquiries',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    FilledButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: pcgBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  widget.redirectToUpload
                                      ? 'Save Profile & Continue to Upload'
                                      : 'Save Profile',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
