import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:file_picker/file_picker.dart';
import '../bridge_generated.dart';

final _native = NativeImpl(ExternalLibrary.open(
  '/home/gamp/beamx/mobile/native/target/debug/libnative.so'));

class TransferScreen extends StatefulWidget {
  final String deviceIp;
  const TransferScreen({super.key, required this.deviceIp});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String _status = "Ready";
  bool _busy = false;
  String? _selectedFile;
  double _progress = 0;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.path;
        _status = "Selected: ${result.files.single.name}";
      });
    }
  }

  void _sendFile() async {
    if (_selectedFile == null) {
      setState(() => _status = "Please select a file first");
      return;
    }
    setState(() {
      _busy = true;
      _status = "Sending file...";
      _progress = 0;
    });
    try {
      // Simulate progress
      for (int i = 1; i <= 5; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() => _progress = i / 5);
      }
      final result = await _native.sendFile(
        filePath: _selectedFile!,
        targetIp: widget.deviceIp,
      );
      setState(() {
        _status = result;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _busy = false);
    }
  }

  void _receiveFile() async {
    setState(() {
      _busy = true;
      _status = "Waiting for incoming file...";
      _progress = 0;
    });
    try {
      final result = await _native.receiveFile(
        savePath: '/home/gamp/received_file.txt',
      );
      setState(() {
        _status = result;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Transfer'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swap_horiz, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              'Device: ${widget.deviceIp}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            if (_busy || _progress > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 8),
                    Text("${(_progress * 100).toInt()}%"),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _busy ? null : _pickFile,
              icon: const Icon(Icons.folder_open),
              label: const Text("Pick File"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _busy ? null : _sendFile,
              icon: const Icon(Icons.upload),
              label: const Text("Send File"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _busy ? null : _receiveFile,
              icon: const Icon(Icons.download),
              label: const Text("Receive File"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
