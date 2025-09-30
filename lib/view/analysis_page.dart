import 'package:flutter/material.dart';
import 'home_page.dart';

class AnalysisPage extends StatefulWidget {
  final List<Ticket> priorityQueue;
  final List<Ticket> nmQueue;
  final List<Ticket> normalQueue;

  const AnalysisPage({
    super.key,
    required this.priorityQueue,
    required this.nmQueue,
    required this.normalQueue,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with SingleTickerProviderStateMixin {
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

  int getCalledCount(String period) {
    DateTime now = DateTime.now();
    List<Ticket> allTickets = [
      ...widget.priorityQueue,
      ...widget.nmQueue,
      ...widget.normalQueue,
    ];
    if (period == 'Diário') {
      return allTickets.where((t) => t.called && t.calledAt != null && t.calledAt!.day == now.day && t.calledAt!.month == now.month && t.calledAt!.year == now.year).length;
    } else if (period == 'Semanal') {
      int weekNumber(DateTime date) => ((date.day - 1) / 7).floor() + 1;
      int currentWeek = weekNumber(now);
      return allTickets.where((t) => t.called && t.calledAt != null && weekNumber(t.calledAt!) == currentWeek && t.calledAt!.month == now.month && t.calledAt!.year == now.year).length;
    } else if (period == 'Mensal') {
      return allTickets.where((t) => t.called && t.calledAt != null && t.calledAt!.month == now.month && t.calledAt!.year == now.year).length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
      body: TabBarView(
        controller: _tabController,
        children: [
          buildAnalysisCard('Diário'),
          buildAnalysisCard('Semanal'),
          buildAnalysisCard('Mensal'),
        ],
      ),
    );
  }

  Widget buildAnalysisCard(String period) {
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Total de fichas chamadas: ${getCalledCount(period)}', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
