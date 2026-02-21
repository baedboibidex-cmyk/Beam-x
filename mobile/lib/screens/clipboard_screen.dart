import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import '../bridge_generated.dart';

final _native = NativeImpl(ExternalLibrary.open(
  '/home/gamp/beamx/mobile/native/target/debug/libnative.so'));

class ClipboardScreen extends StatefulWidget {
  final String deviceIp;
  const ClipboardScreen({super.key, required this.deviceIp});

  @override
  State<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState extends State<ClipboardScreen> {
  final _controller = TextEditingController();
  String _status = "Ready";
  String _received = "";
  bool _busy = false;

  void _sendClipboard() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _status = "Please enter or paste text first");
      return;
    }
    setState(() {
      _busy = true;
      _status = "Sending clipboard...";
    });
    try {
      final result = await _native.sendClipboard(
        text: text,
        targetIp: widget.deviceIp,
      );
      setState(() => _status = result);
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _busy = false);
    }
  }

  void _receiveClipboard() async {
    setState(() {
      _busy = true;
      _status = "Waiting for clipboard...";
    });
    try {
      final result = await _native.receiveClipboard();
      setState(() {
        _received = result;
        _status = "Clipboard received!";
      });
      await Clipboard.setData(ClipboardData(text: result));
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _busy = false);
    }
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      _controller.text = data.text ?? '';
      setState(() => _status = "Pasted from clipboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard Sync'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.devices, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Text(
                    'Connected to: ${widget.deviceIp}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Send Text',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type or paste text to send...',
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste),
                  label: const Text("Paste"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _sendClipboard,
                  icon: const Icon(Icons.send),
                  label: const Text("Send"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),
            const Text(
              'Receive Text',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _busy ? null : _receiveClipboard,
              icon: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              label:
                  Text(_busy ? "Waiting..." : "Wait for Clipboard"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.withOpacity(0.2),
              ),
            ),
            if (_received.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Received:',
                        style: TextStyle(
                            color: Colors.greenAccent, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(_received,
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: _received));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Copied to clipboard!')),
                        );
                      },
                      child: const Text('Tap to copy',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              _status,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
