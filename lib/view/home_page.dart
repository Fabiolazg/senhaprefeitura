import 'package:flutter/material.dart';
import 'package:senhaprefeitura/view/analysis_page.dart';
import 'package:senhaprefeitura/models/ticket_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController normalController = TextEditingController();
  final TextEditingController nmController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  List<Ticket> normalQueue = [];
  List<Ticket> nmQueue = [];
  List<Ticket> priorityQueue = [];

  bool lastWasNM = false;
  bool lastWasPriority = false;
  String _nextTicket = "Nenhuma ficha na fila";

  int normalCounter = 0;
  int nmCounter = 0;
  int priorityCounter = 0;

  /// Adiciona fichas e grava no Firestore
  void addTickets() async {
    final normalCount = int.tryParse(normalController.text.trim()) ?? 0;
    final nmCount = int.tryParse(nmController.text.trim()) ?? 0;
    final priorityCount = int.tryParse(priorityController.text.trim()) ?? 0;

    final firestore = FirebaseFirestore.instance;

    for (int i = 0; i < priorityCount; i++) {
      priorityCounter++;
      final docRef = firestore.collection('tickets').doc();
      await docRef.set({
        'type': 'Prioridade',
        'number': priorityCounter,
        'called': false,
        'calledAt': null,
      });
      final ticket = Ticket(
          id: docRef.id, type: 'Prioridade', number: priorityCounter);
      priorityQueue.add(ticket);
    }

    for (int i = 0; i < nmCount; i++) {
      nmCounter++;
      final docRef = firestore.collection('tickets').doc();
      await docRef.set({
        'type': 'NM',
        'number': nmCounter,
        'called': false,
        'calledAt': null,
      });
      final ticket = Ticket(id: docRef.id, type: 'NM', number: nmCounter);
      nmQueue.add(ticket);
    }

    for (int i = 0; i < normalCount; i++) {
      normalCounter++;
      final docRef = firestore.collection('tickets').doc();
      await docRef.set({
        'type': 'Normal',
        'number': normalCounter,
        'called': false,
        'calledAt': null,
      });
      final ticket = Ticket(id: docRef.id, type: 'Normal', number: normalCounter);
      normalQueue.add(ticket);
    }

    normalController.clear();
    nmController.clear();
    priorityController.clear();

    setState(() {});
  }

  /// Chama a próxima ficha e atualiza no Firestore
  void callNextTicket() async {
    Ticket? next;

    if (priorityQueue.isNotEmpty && !lastWasPriority) {
      next = priorityQueue.removeAt(0);
      lastWasPriority = true;
    } else if ((nmQueue.isNotEmpty || normalQueue.isNotEmpty)) {
      if (nmQueue.isNotEmpty && normalQueue.isNotEmpty) {
        if (lastWasNM) {
          next = normalQueue.removeAt(0);
          lastWasNM = false;
        } else {
          next = nmQueue.removeAt(0);
          lastWasNM = true;
        }
      } else if (nmQueue.isNotEmpty) {
        next = nmQueue.removeAt(0);
        lastWasNM = true;
      } else if (normalQueue.isNotEmpty) {
        next = normalQueue.removeAt(0);
        lastWasNM = false;
      }
      lastWasPriority = false;
    } else if (priorityQueue.isNotEmpty) {
      next = priorityQueue.removeAt(0);
      lastWasPriority = true;
    }

    if (next != null) {
      next.called = true;
      next.calledAt = DateTime.now();

      final firestore = FirebaseFirestore.instance;
      await firestore.collection('tickets').doc(next.id).update({
        'called': true,
        'calledAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _nextTicket = "${next!.type} #${next.number}";
      });
    } else {
      setState(() {
        _nextTicket = "Nenhuma ficha na fila";
      });
    }
  }

  @override
  void dispose() {
    normalController.dispose();
    nmController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fila Prefeitura',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1791d5),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFF595D4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle,
                      size: 64, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(widget.userEmail,
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Análises'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnalysisPage()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/imagens_flutter/fundo.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "Adicionar Fichas",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: normalController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: "Normal"),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: nmController,
                                keyboardType: TextInputType.number,
                                decoration:
                                const InputDecoration(labelText: "NM"),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: priorityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: "Prioridade"),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: addTickets,
                                child: const Text(
                                  "Adicionar",
                                  style: TextStyle(color: Color(0xFF1791d5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Próxima ficha: $_nextTicket",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: callNextTicket,
                          child: const Text(
                            "Chamar próxima ficha",
                            style: TextStyle(color: Color(0xFF1791d5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Filas Atuais",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            children: [
                              Text("Prioridade: ${priorityQueue.map((t) => t.number).join(', ')}"),
                              Text("NM: ${nmQueue.map((t) => t.number).join(', ')}"),
                              Text("Normal: ${normalQueue.map((t) => t.number).join(', ')}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}