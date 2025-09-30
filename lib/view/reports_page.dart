import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // no futuro, esses dados virão do banco
    final totalTickets = 120;
    final normalTickets = 80;
    final preferentialTickets = 30;
    final otherTickets = 10;
    final avgTime = "5 min 32 seg";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text("Relatórios do Dia",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.confirmation_num),
            title: const Text("Total de Fichas"),
            trailing: Text("$totalTickets"),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Normais"),
            trailing: Text("$normalTickets"),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility),
            title: const Text("Preferenciais"),
            trailing: Text("$preferentialTickets"),
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text("Outros Municípios"),
            trailing: Text("$otherTickets"),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text("Tempo Médio de Atendimento"),
            trailing: Text(avgTime),
          ),
        ],
      ),
    );
  }
}
