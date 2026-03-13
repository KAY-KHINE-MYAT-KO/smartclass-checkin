import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_scanner_screen.dart';
import 'models.dart';
import 'theme.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();
  Position? _completionLocation;
  bool _isLocationLoading = false;
  DateTime? _completionTimestamp;
  String? _classId;
  bool _isClassSaved = false;

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
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
          _completionLocation = position;
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
      _completionTimestamp = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Timestamp captured: ${_completionTimestamp!.toIso8601String()}',
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

  Future<void> _saveFinishClass() async {
    final prefs = await SharedPreferences.getInstance();

    // Save to local storage
    await prefs.setString('finish_learnedToday', _learnedTodayController.text);
    await prefs.setString('finish_feedback', _feedbackController.text);

    if (_completionLocation != null) {
      await prefs.setDouble('completion_latitude', _completionLocation!.latitude);
      await prefs.setDouble('completion_longitude', _completionLocation!.longitude);
    }

    if (_completionTimestamp != null) {
      await prefs.setInt(
        'completion_timestamp',
        _completionTimestamp!.millisecondsSinceEpoch,
      );
    }

    if (_classId != null) {
      await prefs.setString('completion_classId', _classId!);
    }

    // Save to Firestore
    try {
      final studentId = prefs.getString('studentId') ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      
      // Generate a completionId for this session
      final completionId = 'completion_${DateTime.now().millisecondsSinceEpoch}';
      
      final completionData = ClassCompletionData(
        studentId: studentId,
        classId: _classId ?? 'unknown',
        completionTimestamp: _completionTimestamp ?? DateTime.now(),
        completionLatitude: _completionLocation?.latitude,
        completionLongitude: _completionLocation?.longitude,
        learnedToday: _learnedTodayController.text,
        feedback: _feedbackController.text,
      );

      await FirebaseFirestore.instance
          .collection('completions')
          .doc(completionId)
          .set(completionData.toMap());

      if (!mounted) return;
      
      setState(() {
        _isClassSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Reflection saved successfully!'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reset form after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _learnedTodayController.clear();
        _feedbackController.clear();
        setState(() {
          _completionLocation = null;
          _completionTimestamp = null;
          _classId = null;
          _isClassSaved = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to database: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish Class'),
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
                'Class Reflection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share what you learned and your feedback',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // What You Learned Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Key Takeaways',
                      icon: Icons.school,
                    ),
                    TextField(
                      controller: _learnedTodayController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write the main concepts and skills you learned...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Feedback Section
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Your Feedback',
                      icon: Icons.feedback,
                    ),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'What went well? What could be improved?',
                      ),
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
                      label: _completionLocation != null
                          ? '${_completionLocation!.latitude.toStringAsFixed(5)}, ${_completionLocation!.longitude.toStringAsFixed(5)}'
                          : 'Not captured',
                      isActive: _completionLocation != null,
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
                      title: 'Completion Time',
                      icon: Icons.schedule,
                    ),
                    StatusBadge(
                      label: _completionTimestamp != null
                          ? _completionTimestamp!.toLocal().toString().split('.')[0]
                          : 'Not captured',
                      isActive: _completionTimestamp != null,
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
                  label: const Text('Save Reflection'),
                  onPressed: _saveFinishClass,
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
