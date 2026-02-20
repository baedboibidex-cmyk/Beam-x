import 'package:flutter/material.dart';

class TransferRecord {
  final String fileName;
  final String deviceIp;
  final int bytes;
  final DateTime time;
  final bool sent;

  TransferRecord({
    required this.fileName,
    required this.deviceIp,
    required this.bytes,
    required this.sent,
  }) : time = DateTime.now();
}

final List<TransferRecord> transferHistory = [];

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() => transferHistory.clear());
            },
          )
        ],
      ),
      body: transferHistory.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("No transfers yet",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: transferHistory.length,
              itemBuilder: (context, index) {
                final record = transferHistory[index];
                return ListTile(
                  leading: Icon(
                    record.sent ? Icons.upload : Icons.download,
                    color: record.sent ? Colors.blueAccent : Colors.greenAccent,
                  ),
                  title: Text(record.fileName),
                  subtitle: Text(
                    "${record.sent ? 'Sent to' : 'Received from'} ${record.deviceIp}",
                  ),
                  trailing: Text(
                    "${(record.bytes / 1024).toStringAsFixed(1)} KB\n"
                    "${record.time.hour}:${record.time.minute.toString().padLeft(2, '0')}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}
