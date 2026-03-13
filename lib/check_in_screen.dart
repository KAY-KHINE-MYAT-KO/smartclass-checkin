import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_scanner_screen.dart';
import 'models.dart';
import 'theme.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  int _selectedMood = 3;
  Position? _checkinLocation;
  bool _isLocationLoading = false;
  DateTime? _checkinTimestamp;
  String? _classId;
  bool _isCheckInSaved = false;

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      await _requestLocationPermission();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _checkinLocation = position;
          _isLocationLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location captured: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing location: $e')),
        );
      }
    }
  }

  void _captureTimestamp() {
    setState(() {
      _checkinTimestamp = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Timestamp captured: ${_checkinTimestamp!.toIso8601String()}',
        ),
      ),
    );
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(title: 'Scan Class QR Code'),
      ),
    );
    if (result != null) {
      setState(() {
        _classId = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class ID: $_classId')),
        );
      }
    }
  }

  Future<void> _saveCheckIn() async {
    final prefs = await SharedPreferences.getInstance();

    // Save to local storage
    await prefs.setString('checkin_previousTopic', _previousTopicController.text);
    await prefs.setString('checkin_expectedTopic', _expectedTopicController.text);
    await prefs.setInt('checkin_mood', _selectedMood);

    if (_checkinLocation != null) {
      await prefs.setDouble('checkin_latitude', _checkinLocation!.latitude);
      await prefs.setDouble('checkin_longitude', _checkinLocation!.longitude);
    }

    if (_checkinTimestamp != null) {
      await prefs.setInt(
        'checkin_timestamp',
        _checkinTimestamp!.millisecondsSinceEpoch,
      );
    }

    if (_classId != null) {
      await prefs.setString('checkin_classId', _classId!);
    }

    // Save to Firestore
    try {
      final studentId = prefs.getString('studentId') ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      
      // Generate a checkInId for this session
      final checkInId = 'checkin_${DateTime.now().millisecondsSinceEpoch}';
      
      final checkInData = CheckInData(
        studentId: studentId,
        classId: _classId ?? 'unknown',
        checkinTimestamp: _checkinTimestamp ?? DateTime.now(),
        checkinLatitude: _checkinLocation?.latitude,
        checkinLongitude: _checkinLocation?.longitude,
        previousTopic: _previousTopicController.text,
        expectedTopic: _expectedTopicController.text,
        mood: _selectedMood,
      );

      await FirebaseFirestore.instance
          .collection('checkins')
          .doc(checkInId)
          .set(checkInData.toMap());

      if (!mounted) return;
      
      // Update UI state to show success
      setState(() {
        _isCheckInSaved = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Check-in saved successfully!'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reset form after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _previousTopicController.clear();
        _expectedTopicController.clear();
        setState(() {
          _selectedMood = 3;
          _checkinLocation = null;
          _checkinTimestamp = null;
          _classId = null;
          _isCheckInSaved = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Error saving to database: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodLabels = <int, String>{
      1: '😡 Very negative',
      2: '🙁 Negative',
      3: '😐 Neutral',
      4: '🙂 Positive',
      5: '😄 Very positive',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Before Class',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us what you remember and how you feel today',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Previous Topic Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Previous Class',
                      icon: Icons.history,
                    ),
                    TextField(
                      controller: _previousTopicController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'What topic was covered last time?',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Expected Topic Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Today\'s Expectations',
                      icon: Icons.lightbulb,
                    ),
                    TextField(
                      controller: _expectedTopicController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'What do you expect to learn today?',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Mood Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'How do you feel?',
                      icon: Icons.mood,
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: moodLabels.entries.map((entry) {
                        final value = entry.key;
                        final label = entry.value;
                        final selected = _selectedMood == value;
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                          labelStyle: TextStyle(
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? AppTheme.primaryColor : AppTheme.textPrimary,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedMood = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // QR Code Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Class Session',
                      icon: Icons.qr_code_2,
                    ),
                    StatusBadge(
                      label: _classId ?? 'Scan QR Code',
                      isActive: _classId != null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan QR Code'),
                        onPressed: _scanQrCode,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Location Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Location',
                      icon: Icons.location_on,
                    ),
                    StatusBadge(
                      label: _checkinLocation != null
                          ? '${_checkinLocation!.latitude.toStringAsFixed(5)}, ${_checkinLocation!.longitude.toStringAsFixed(5)}'
                          : 'Not captured',
                      isActive: _checkinLocation != null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isLocationLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text('Capture Location'),
                        onPressed: _isLocationLoading ? null : _captureLocation,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Timestamp Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Check-in Time',
                      icon: Icons.schedule,
                    ),
                    StatusBadge(
                      label: _checkinTimestamp != null
                          ? _checkinTimestamp!.toLocal().toString().split('.')[0]
                          : 'Not captured',
                      isActive: _checkinTimestamp != null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: const Text('Capture Time'),
                        onPressed: _captureTimestamp,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Save Check-in'),
                  onPressed: _saveCheckIn,
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
