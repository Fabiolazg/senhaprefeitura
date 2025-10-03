import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int getCalledCount(List<Ticket> tickets, String period) {
    final now = DateTime.now();

    if (period == 'Diário') {
      return tickets
          .where((t) =>
      t.called &&
          t.calledAt != null &&
          t.calledAt!.day == now.day &&
          t.calledAt!.month == now.month &&
          t.calledAt!.year == now.year)
          .length;
    } else if (period == 'Semanal') {
      int weekNumber(DateTime date) => ((date.day - 1) / 7).floor() + 1;
      final currentWeek = weekNumber(now);
      return tickets
          .where((t) =>
      t.called &&
          t.calledAt != null &&
          weekNumber(t.calledAt!) == currentWeek &&
          t.calledAt!.month == now.month &&
          t.calledAt!.year == now.year)
          .length;
    } else if (period == 'Mensal') {
      return tickets
          .where((t) =>
      t.called &&
          t.calledAt != null &&
          t.calledAt!.month == now.month &&
          t.calledAt!.year == now.year)
          .length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análises'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Diário'),
            Tab(text: 'Semanal'),
            Tab(text: 'Mensal'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('tickets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mapeia os documentos para objetos Ticket
          List<Ticket> allTickets = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Ticket(
              id: doc.id,
              type: data['type'] ?? 'Normal',
              number: (data['number'] ?? 0).toInt(),
              called: data['called'] ?? false,
              calledAt: (data['calledAt'] as Timestamp?)?.toDate(),
            );
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              buildAnalysisCard(allTickets, 'Diário'),
              buildAnalysisCard(allTickets, 'Semanal'),
              buildAnalysisCard(allTickets, 'Mensal'),
            ],
          );
        },
      ),
    );
  }

  Widget buildAnalysisCard(List<Ticket> tickets, String period) {
    final count = getCalledCount(tickets, period);
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                period,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Total de fichas chamadas: $count',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}