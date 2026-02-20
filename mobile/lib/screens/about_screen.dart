import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About BeamX'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              'BeamX',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 0.1.0 Alpha',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Text(
                    'Fast. Secure. Local.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'BeamX lets you transfer files between devices on the same network instantly — no internet required, no cloud, no limits.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(indent: 30, endIndent: 30),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.code, color: Colors.blueAccent),
              title: Text('Built with Flutter + Rust'),
              subtitle: Text('flutter_rust_bridge v1.82.6'),
            ),
            const ListTile(
              leading: Icon(Icons.person, color: Colors.blueAccent),
              title: Text('Developer'),
              subtitle: Text('baedboibidex-cmyk'),
            ),
            const ListTile(
              leading: Icon(Icons.shield, color: Colors.blueAccent),
              title: Text('License'),
              subtitle: Text('MIT License'),
            ),
            const SizedBox(height: 20),
            const Text(
              '© 2026 BeamX. All rights reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
