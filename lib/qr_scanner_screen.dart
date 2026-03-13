import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'theme.dart';

class QrScannerScreen extends StatefulWidget {
  final String title;

  const QrScannerScreen({
    super.key,
    this.title = 'Scan QR Code',
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController controller;
  final TextEditingController _manualInputController = TextEditingController();
  bool _showManualInput = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      autoStart: true,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _toggleManualInput() {
    setState(() {
      _showManualInput = !_showManualInput;
    });
  }

  void _submitManualCode() {
    if (_manualInputController.text.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pop(_manualInputController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _toggleManualInput,
            tooltip: 'Manual Input',
          ),
        ],
      ),
      body: _showManualInput
          ? _buildManualInputUI()
          : _buildScannerUI(),
    );
  }

  Widget _buildScannerUI() {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                if (mounted) {
                  Navigator.of(context).pop(barcode.rawValue!);
                }
                return;
              }
            }
          },
          errorBuilder: (context, error, child) {
            return Center(
              child: Text('Camera Error: ${error.errorCode}'),
            );
          },
        ),
        // Guide overlay
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor, width: 8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Instructions at bottom
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Align QR code within the box',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInputUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter Class ID',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'If QR code scanning is not available, enter the class ID directly:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _manualInputController,
                decoration: const InputDecoration(
                  labelText: 'Class ID',
                  hintText: 'e.g., CS101-2026-03-13',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  onPressed: _submitManualCode,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Back to Scanner'),
                onPressed: _toggleManualInput,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

