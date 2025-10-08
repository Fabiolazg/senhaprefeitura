// lib/view/analysis_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  List<Map<String, dynamic>> _calledTickets = []; // armazenará ticket data com calledAt DateTime

  // cores
  static const Color _rose = Color(0xFFF595D4); // NM
  static const Color _blue = Color(0xFF1791d5); // Normal
  static const Color _gray = Color(0xFFB0B0B0); // Prioridade

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCalledTickets();
    // re-fetch quando trocar aba para disparar animação (contador)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // força rebuild para reanimar contadores
        setState(() {});
      }
    });
  }

  Future<void> _loadCalledTickets() async {
    setState(() => _loading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('tickets')
          .where('called', isEqualTo: true)
          .get();

      _calledTickets = snapshot.docs.map((doc) {
        final data = doc.data();
        final calledAtRaw = data['calledAt'];
        DateTime? calledAt;
        if (calledAtRaw is Timestamp) {
          calledAt = calledAtRaw.toDate();
        } else if (calledAtRaw is DateTime) {
          calledAt = calledAtRaw;
        } else {
          calledAt = null;
        }
        return {
          'type': data['type'] ?? '',
          'number': data['number'] ?? 0,
          'calledAt': calledAt,
        };
      }).toList();
    } catch (e) {
      debugPrint('Erro ao carregar tickets: $e');
      _calledTickets = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  // helpers para filtrar por período
  List<Map<String, dynamic>> _ticketsToday() {
    final now = DateTime.now();
    return _calledTickets.where((t) {
      final dt = t['calledAt'] as DateTime?;
      if (dt == null) return false;
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).toList();
  }

  int _weekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final diff = date.difference(firstDay);
    return ((diff.inDays + firstDay.weekday) / 7).ceil();
  }

  List<Map<String, dynamic>> _ticketsThisWeek() {
    final now = DateTime.now();
    final currentWeek = _weekNumber(now);
    return _calledTickets.where((t) {
      final dt = t['calledAt'] as DateTime?;
      if (dt == null) return false;
      return dt.year == now.year &&
          dt.month == now.month &&
          _weekNumber(dt) == currentWeek;
    }).toList();
  }

  List<Map<String, dynamic>> _ticketsThisMonth() {
    final now = DateTime.now();
    return _calledTickets.where((t) {
      final dt = t['calledAt'] as DateTime?;
      if (dt == null) return false;
      return dt.year == now.year && dt.month == now.month;
    }).toList();
  }

  // calcula totais e por tipo
  Map<String, int> _countsFromList(List<Map<String, dynamic>> list) {
    final total = list.length;
    final nm = list.where((t) => (t['type'] ?? '') == 'NM').length;
    final normal = list.where((t) => (t['type'] ?? '') == 'Normal').length;
    final pri = list.where((t) => (t['type'] ?? '') == 'Prioridade').length;
    return {'total': total, 'nm': nm, 'normal': normal, 'priority': pri};
  }

  // widget para contador animado (de 0 até value)
  Widget _animatedCounterCard(String label, int value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        child: SizedBox(
          height: 80,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              builder: (context, t, _) {
                final display = (value * t).round();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$display',
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // total card (cinza)
  Widget _totalCard(int total) {
    return Card(
      color: _gray,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 80,
        width: double.infinity,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            builder: (context, t, _) {
              final display = (total * t).round();
              return Text(
                'Total de atendimentos: $display',
                style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(int nm, int normal, int priority) {
    final sections = <PieChartSectionData>[];
    if (nm + normal + priority == 0) {
      // fatia dummie para evitar erro do fl_chart quando todos zeros
      sections.add(PieChartSectionData(
        value: 1,
        color: Colors.grey.shade300,
        title: '0',
        radius: 50,
        titleStyle: GoogleFonts.lexend(color: Colors.black),
      ));
    } else {
      if (nm > 0) {
        sections.add(PieChartSectionData(
          value: nm.toDouble(),
          color: _rose,
          title: '$nm',
          radius: 50,
          titleStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ));
      }
      if (normal > 0) {
        sections.add(PieChartSectionData(
          value: normal.toDouble(),
          color: _blue,
          title: '$normal',
          radius: 50,
          titleStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ));
      }
      if (priority > 0) {
        sections.add(PieChartSectionData(
          value: priority.toDouble(),
          color: _gray,
          title: '$priority',
          radius: 50,
          titleStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ));
      }
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildTabBody(List<Map<String, dynamic>> tickets, String title) {
    final counts = _countsFromList(tickets);
    final total = counts['total']!;
    final nm = counts['nm']!;
    final normal = counts['normal']!;
    final priority = counts['priority']!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(animation);
        return SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: animation, child: child));
      },
      child: SingleChildScrollView(
        key: ValueKey<String>(title + total.toString() + nm.toString() + normal.toString() + priority.toString()),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _totalCard(total),
            const SizedBox(height: 12),
            Row(
              children: [
                _animatedCounterCard('NM', nm, _rose),
                _animatedCounterCard('Normal', normal, _blue),
                _animatedCounterCard('Prioridade', priority, _gray),
              ],
            ),
            const SizedBox(height: 20),
            _buildPieChart(nm, normal, priority),
            const SizedBox(height: 16),
            // resumo textual (opcional, compacto)
            Card(
              margin: const EdgeInsets.only(top: 12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Resumo — $title',
                      style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('NM: $nm', style: GoogleFonts.lexend(),),
                        Text('Normal: $normal', style: GoogleFonts.lexend()),
                        Text('Prioridade: $priority', style: GoogleFonts.lexend()),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // botão de recarregar manualmente
  Widget _buildReloadButton() {
    return IconButton(
      tooltip: 'Recarregar',
      onPressed: () async {
        await _loadCalledTickets();
      },
      icon: const Icon(Icons.refresh),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análises de Atendimentos',
          style: GoogleFonts.lexend( color: Colors.white, fontSize: 20)),
        backgroundColor: _blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        actions: [_buildReloadButton()],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Semana'),
            Tab(text: 'Mês'),
          ],
          indicatorColor: _rose,
          labelColor: _rose,
          unselectedLabelColor: Colors.white,
          labelStyle: GoogleFonts.lexend(fontSize: 15),
          unselectedLabelStyle: GoogleFonts.lexend(fontSize: 13),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imagens_flutter/fundo2.jpg"),
            fit: BoxFit.cover,
          ),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Hoje
          _buildTabBody(_ticketsToday(), 'Hoje'),
          // Semana
          _buildTabBody(_ticketsThisWeek(), 'Semana'),
          // Mês
          _buildTabBody(_ticketsThisMonth(), 'Mês'),
        ],
      ),
      ),
    );
  }
}