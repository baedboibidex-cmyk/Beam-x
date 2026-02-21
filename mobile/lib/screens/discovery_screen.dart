import 'package:flutter/material.dart';
import '../main.dart' show native;
import '../bridge_generated.dart';
import 'transfer_screen.dart';
import 'chat_screen.dart';
import 'clipboard_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<Device> _devices = [];
  bool _scanning = false;
  String _status = "Press scan to find devices";
  final _ipController = TextEditingController();

  void _scan() async {
    setState(() {
      _scanning = true;
      _status = "Scanning...";
      _devices = [];
    });
    try {
      final devices = await native.discoverDevices();
      setState(() {
        _devices = devices;
        _status = devices.isEmpty
            ? "No devices found"
            : "Found ${devices.length} device(s)";
      });
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _scanning = false);
    }
  }

  void _connectManual() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => TransferScreen(deviceIp: ip)));
  }

  void _chatManual() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ChatScreen(deviceIp: ip)));
  }

  void _clipboardManual() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ClipboardScreen(deviceIp: ip)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(_status, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _scanning ? null : _scan,
            icon: _scanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.radar),
            label: Text(_scanning ? "Scanning..." : "Scan Network"),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          const Text("Or connect manually:",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "Enter IP address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lan),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _connectManual,
                icon: const Icon(Icons.swap_horiz),
                label: const Text("Transfer"),
              ),
              ElevatedButton.icon(
                onPressed: _chatManual,
                icon: const Icon(Icons.chat),
                label: const Text("Chat"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withOpacity(0.2),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _clipboardManual,
                icon: const Icon(Icons.content_paste),
                label: const Text("Clipboard"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF6D00).withOpacity(0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _devices.isEmpty
                ? const Center(child: Text("No devices yet"))
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final d = _devices[index];
                      return ListTile(
                        leading: const Icon(Icons.devices,
                            color: Colors.blueAccent),
                        title: Text(d.name),
                        subtitle: Text("${d.ip}:${d.port}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat,
                                  color: Colors.greenAccent),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChatScreen(deviceIp: d.ip),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransferScreen(deviceIp: d.ip),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
