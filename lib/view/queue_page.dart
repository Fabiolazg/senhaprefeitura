import 'package:flutter/material.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  String? _currentTicket;

  void _callNextTicket(String type) {
    // Aqui futuramente você conecta com Firebase ou SQLite
    setState(() {
      _currentTicket = "Chamando ${type.toUpperCase()} - Nº ${DateTime.now().millisecondsSinceEpoch % 1000}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentTicket != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _currentTicket!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        Wrap(
          spacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _callNextTicket("Normal"),
              child: const Text("Próxima Normal"),
            ),
            ElevatedButton(
              onPressed: () => _callNextTicket("Preferencial"),
              child: const Text("Próxima Preferencial"),
            ),
            ElevatedButton(
              onPressed: () => _callNextTicket("Outros Municípios"),
              child: const Text("Próxima Outros"),
            ),
          ],
        ),
      ],
    );
  }
}
