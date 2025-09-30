import 'package:flutter/material.dart';
import 'package:senhaprefeitura/view/analysis_page.dart';

class HomePage extends StatefulWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Ticket {
  final String type;
  final int number;
  bool called;
  DateTime? calledAt;

  Ticket({required this.type, required this.number, this.called = false});
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

  void addTickets() {
    final normalCount = int.tryParse(normalController.text.trim()) ?? 0;
    final nmCount = int.tryParse(nmController.text.trim()) ?? 0;
    final priorityCount = int.tryParse(priorityController.text.trim()) ?? 0;

    for (int i = 0; i < priorityCount; i++) {
      priorityCounter++;
      priorityQueue.add(Ticket(type: "Prioridade", number: priorityCounter));
    }
    for (int i = 0; i < nmCount; i++) {
      nmCounter++;
      nmQueue.add(Ticket(type: "NM", number: nmCounter));
    }
    for (int i = 0; i < normalCount; i++) {
      normalCounter++;
      normalQueue.add(Ticket(type: "Normal", number: normalCounter));
    }

    normalController.clear();
    nmController.clear();
    priorityController.clear();

    setState(() {});
  }

  void callNextTicket() {
    Ticket? next;

    // Prioridade intercalada
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
      setState(() {
        _nextTicket = "${next?.type} #${next?.number}";
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
        title: Text('Fila Prefeitura'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle, size: 64, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(widget.userEmail, style: const TextStyle(color: Colors.white)),
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
                        builder: (context) => AnalysisPage(
                          priorityQueue : priorityQueue,
                          nmQueue : nmQueue,
                          normalQueue : normalQueue
                        )
                    )
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
          image: AssetImage("assets/fundo.jpg"),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: normalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Normal"),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: nmController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "NM"),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: priorityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Prioridade"),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: addTickets,
                          child: const Text("Adicionar"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Próxima ficha: $_nextTicket",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: callNextTicket,
                      child: const Text("Chamar próxima ficha"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Filas Atuais",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
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
            ),
          ],
        ),
      ),
      ),
    );
  }
}