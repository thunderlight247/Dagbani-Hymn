import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/church.dart';
import '../services/church_service.dart';

class ChurchFormScreen extends StatefulWidget {
  final String? userCongregation;
  final Church? existing; // non-null when editing

  const ChurchFormScreen({
    super.key,
    this.userCongregation,
    this.existing,
  });

  @override
  State<ChurchFormScreen> createState() => _ChurchFormScreenState();
}

class _ChurchFormScreenState extends State<ChurchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ChurchService();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _townCtrl;
  late final TextEditingController _presbyCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _mapsCtrl;
  late final TextEditingController _ministerCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _activitiesCtrl;

  bool _saving = false;

  // GPS state
  bool _detectingLocation = false;
  String _gpsStatus = '';

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _townCtrl = TextEditingController(text: e?.townCity ?? '');
    _presbyCtrl = TextEditingController(text: e?.presbytery ?? '');
    _locationCtrl = TextEditingController(text: e?.locationDescription ?? '');
    _mapsCtrl = TextEditingController(text: e?.googleMapsUrl ?? '');
    _ministerCtrl = TextEditingController(text: e?.minister ?? '');
    _phoneCtrl = TextEditingController(text: e?.contactPhone ?? '');
    _activitiesCtrl = TextEditingController(text: e?.activities ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _townCtrl, _presbyCtrl, _locationCtrl,
      _mapsCtrl, _ministerCtrl, _phoneCtrl, _activitiesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── GPS capture ────────────────────────────────────────────────────────────

  Future<void> _captureCurrentLocation() async {
    setState(() {
      _detectingLocation = true;
      _gpsStatus = 'Requesting location permission…';
    });

    // Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _detectingLocation = false;
          _gpsStatus = 'Location permission denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _detectingLocation = false;
        _gpsStatus = 'Permission permanently denied. Enable it in Settings.';
      });
      return;
    }

    // Check GPS service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _detectingLocation = false;
        _gpsStatus = 'GPS is turned off. Please enable Location Services.';
      });
      return;
    }

    setState(() => _gpsStatus = '📡 Acquiring GPS coordinates…');

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      final mapsUrl =
          'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      // Auto-fill the Google Maps field
      _mapsCtrl.text = mapsUrl;

      setState(() {
        _detectingLocation = false;
        _gpsStatus =
            '✅ Location captured (${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})';
      });

      // Show confirmation dialog
      if (!mounted) return;
      _showLocationConfirmDialog(position, mapsUrl);
    } on TimeoutException {
      setState(() {
        _detectingLocation = false;
        _gpsStatus = '⏱ GPS timed out. Try again or enter location manually.';
      });
    } catch (e) {
      setState(() {
        _detectingLocation = false;
        _gpsStatus = '❌ Could not get location. Try again.';
      });
    }
  }

  void _showLocationConfirmDialog(Position position, String mapsUrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.green),
            SizedBox(width: 8),
            Text('Location Captured'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your current GPS coordinates have been set as the church location.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lat: ${position.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  Text(
                    'Lng: ${position.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please confirm the church name and location description are correct before submitting.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear if they don't want it
              _mapsCtrl.clear();
              setState(() => _gpsStatus = '');
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Location'),
          ),
        ],
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final id = _isEditing
        ? widget.existing!.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final church = Church(
      id: id,
      name: _nameCtrl.text.trim(),
      townCity: _townCtrl.text.trim(),
      presbytery: _presbyCtrl.text.trim(),
      locationDescription: _locationCtrl.text.trim(),
      googleMapsUrl: _mapsCtrl.text.trim(),
      minister: _ministerCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      activities: _activitiesCtrl.text.trim(),
      uploadedBy: widget.userCongregation ?? '',
      createdAt: _isEditing ? widget.existing!.createdAt : DateTime.now(),
    );

    bool ok;
    if (_isEditing) {
      ok = await _service.updateChurch(church);
    } else {
      ok = await _service.uploadChurch(church);
    }

    setState(() => _saving = false);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save. Check your connection and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Church' : 'Add Church'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── GPS Location Card ──────────────────────────────────────────
            Card(
              color: primary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                      color: primary.withValues(alpha: 0.2))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gps_fixed_rounded, color: primary),
                        const SizedBox(width: 8),
                        Text(
                          'Auto-Detect Church Location',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primary,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'If you are physically at the church right now, tap the button below — your GPS coordinates will be used as the exact location pin.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            _detectingLocation ? null : _captureCurrentLocation,
                        icon: _detectingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.my_location_rounded),
                        label: Text(_detectingLocation
                            ? 'Detecting…'
                            : '📍 Use My Current Location'),
                      ),
                    ),
                    if (_gpsStatus.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _gpsStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: _gpsStatus.startsWith('✅')
                              ? Colors.green
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Church Name ───────────────────────────────────────────────
            _buildField(
              controller: _nameCtrl,
              label: 'Church Name',
              hint: 'e.g. PCG: Van Den Broek Memorial Congregation',
              required: true,
              icon: Icons.church_rounded,
            ),

            // ── Town / City ───────────────────────────────────────────────
            _buildField(
              controller: _townCtrl,
              label: 'Town / City',
              hint: 'e.g. Tamale',
              required: true,
              icon: Icons.location_city_rounded,
            ),

            // ── Presbytery / District ─────────────────────────────────────
            _buildField(
              controller: _presbyCtrl,
              label: 'Presbytery / District',
              hint: 'e.g. Northern Presbytery',
              required: true,
              icon: Icons.account_tree_rounded,
            ),

            // ── Physical Location Description ─────────────────────────────
            _buildField(
              controller: _locationCtrl,
              label: 'Location Description & Landmark',
              hint: 'e.g. Near Central Market, opposite ABC Hotel',
              required: false,
              icon: Icons.signpost_rounded,
              maxLines: 2,
            ),

            // ── Google Maps URL ───────────────────────────────────────────
            _buildField(
              controller: _mapsCtrl,
              label: 'Google Maps Link (auto-filled by GPS or paste manually)',
              hint: 'https://www.google.com/maps?q=...',
              required: false,
              icon: Icons.map_rounded,
            ),

            // ── Minister / Contact Person ─────────────────────────────────
            _buildField(
              controller: _ministerCtrl,
              label: 'Minister / Catechist / Contact Person',
              hint: 'e.g. Rev. John Doe',
              required: false,
              icon: Icons.person_rounded,
            ),

            // ── Contact Phone ─────────────────────────────────────────────
            _buildField(
              controller: _phoneCtrl,
              label: 'Contact Phone Number',
              hint: 'e.g. 024 123 4567',
              required: false,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),

            // ── Weekly Activities ─────────────────────────────────────────
            const SizedBox(height: 4),
            const Text(
              'Weekly Activities & Schedule',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter one activity per line. Format: Day: Time & Description\n'
              'e.g.\nSunday: 7:00AM & 10:00AM Worship Service\n'
              'Wednesday: 6:00PM Midweek Prayer',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _activitiesCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_month_rounded),
                hintText: 'Sunday: 7:00AM & 10:00AM Worship\nWednesday: 6:00PM Prayer',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_rounded),
              label: Text(_isEditing ? 'Update Church' : 'Submit Church Details'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool required,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                ? 'This field is required'
                : null
            : null,
      ),
    );
  }
}
