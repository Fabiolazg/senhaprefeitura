import 'package:flutter/material.dart';
import 'package:senhaprefeitura/models/ticket_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with SingleTickerProviderStateMixin {
  List<Ticket> allTickets = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('tickets').get();

    allTickets = snapshot.docs.map((doc) {
      final data = doc.data();
      return Ticket(
        id: doc.id,
        type: data['type'] ?? '',
        number: data['number'] ?? 0,
        called: data['called'] ?? false,
        calledAt: (data['calledAt'] as Timestamp?)?.toDate(),
      );
    }).toList();

    setState(() {
      isLoading = false;
    });
  }

  int getTodayCount(List<Ticket> tickets) {
    final now = DateTime.now();
    return tickets.where((t) => t.calledAt != null && t.calledAt!.year == now.year && t.calledAt!.month == now.month && t.calledAt!.day == now.day).length;
  }

  int getWeekCount(List<Ticket> tickets) {
    final now = DateTime.now();
    int currentWeek = weekNumber(now);
    return tickets.where((t) => t.calledAt != null && t.calledAt!.year == now.year && t.calledAt!.month == now.month && weekNumber(t.calledAt!) == currentWeek).length;
  }

  int getMonthCount(List<Ticket> tickets) {
    final now = DateTime.now();
    return tickets.where((t) => t.calledAt != null && t.calledAt!.year == now.year && t.calledAt!.month == now.month).length;
  }

  int weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final diff = date.difference(firstDayOfYear);
    return ((diff.inDays + firstDayOfYear.weekday) / 7).ceil();
  }

  Widget _buildTabContent(List<Ticket> tickets) {
    final total = tickets.length;
    final nm = tickets.where((t) => t.type == 'NM').length;
    final normal = tickets.where((t) => t.type == 'Normal').length;
    final prioridade = tickets.where((t) => t.type == 'Prioridade').length;

    const cardMargin = EdgeInsets.symmetric(vertical: 8.0);
    const cardWidth = double.infinity;
    const cardHeight = 80.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total card
          Card(
            color: const Color(0xFFB0B0B0), // cinza
            margin: cardMargin,
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Center(
                child: Text(
                  'Total de atendimentos: $total',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Row de cards por tipo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Card(
                  color: const Color(0xFFF595D4),
                  margin: cardMargin,
                  child: SizedBox(
                    height: cardHeight,
                    child: Center(
                      child: Text(
                        'NM: $nm',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  color: const Color(0xFF1791d5),
                  margin: cardMargin,
                  child: SizedBox(
                    height: cardHeight,
                    child: Center(
                      child: Text(
                        'Normal: $normal',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  color: const Color(0xFFB0B0B0),
                  margin: cardMargin,
                  child: SizedBox(
                    height: cardHeight,
                    child: Center(
                      child: Text(
                        'Prioridade: $prioridade',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gráfico de pizza
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: nm.toDouble(),
                    color: const Color(0xFFF595D4),
                    title: 'NM: $nm',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: normal.toDouble(),
                    color: const Color(0xFF1791d5),
                    title: 'Normal: $normal',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: prioridade.toDouble(),
                    color: const Color(0xFFB0B0B0),
                    title: 'Prioridade: $prioridade',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análises de Atendimentos'),
        backgroundColor: const Color(0xFF1791d5),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Semana'),
            Tab(text: 'Mês'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(allTickets.where((t) => t.calledAt != null && t.calledAt!.day == DateTime.now().day && t.calledAt!.month == DateTime.now().month && t.calledAt!.year == DateTime.now().year).toList()),
          _buildTabContent(allTickets.where((t) => t.calledAt != null && weekNumber(t.calledAt!) == weekNumber(DateTime.now()) && t.calledAt!.month == DateTime.now().month && t.calledAt!.year == DateTime.now().year).toList()),
          _buildTabContent(allTickets.where((t) => t.calledAt != null && t.calledAt!.month == DateTime.now().month && t.calledAt!.year == DateTime.now().year).toList()),
        ],
      ),
    );
  }
}