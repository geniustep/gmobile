// ════════════════════════════════════════════════════════════
// WebSocketEvent - Real-time event model
// ════════════════════════════════════════════════════════════

class WebSocketEvent {
  final String operation; // 'update', 'create', 'delete'
  final String model;
  final int id;
  final Map<String, dynamic> data;

  WebSocketEvent({
    required this.operation,
    required this.model,
    required this.id,
    required this.data,
  });

  @override
  String toString() {
    return 'WebSocketEvent(operation: $operation, model: $model, id: $id)';
  }
}
