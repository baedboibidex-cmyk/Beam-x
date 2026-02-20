import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController(text: 'My BeamX Device');
  final _folderController = TextEditingController(text: '/home/gamp/Downloads');
  bool _autoReceive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Device', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Device Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.devices),
            ),
          ),
          const SizedBox(height: 30),
          const Text('Transfers', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: _folderController,
            decoration: const InputDecoration(
              labelText: 'Save Files To',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.folder),
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Auto Accept Files'),
            subtitle: const Text('Automatically receive incoming files'),
            value: _autoReceive,
            onChanged: (val) => setState(() => _autoReceive = val),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved!')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
