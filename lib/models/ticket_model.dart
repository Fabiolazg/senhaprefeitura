import 'package:cloud_firestore/cloud_firestore.dart';


class Ticket {
  final String id; // ID do doc no Firestore
  final int number;
  final String type; // prioridade, nm, normal
  bool called;
  DateTime? calledAt;

  Ticket({
    required this.id,
    required this.number,
    required this.type,
    this.called = false,
    this.calledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'type': type,
      'called': called,
      'calledAt': calledAt,
    };
  }

  factory Ticket.fromFirestore(String id, Map<String, dynamic> data) {
    return Ticket(
      id: id,
      number: data['number'],
      type: data['type'],
      called: data['called'] ?? false,
      calledAt: (data['calledAt'] as Timestamp?)?.toDate(),
    );
  }
}