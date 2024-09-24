class QueueManager {
  static final QueueManager _instance = QueueManager._internal();
  factory QueueManager() => _instance;
  QueueManager._internal();

  final _queue = <Function>[];
  bool _isRunning = false;

  void add(Function task) {
    _queue.add(task);
    if (!_isRunning) {
      _isRunning = true;
      _run();
    }
  }

  void _run() {
    if (_queue.isEmpty) {
      _isRunning = false;
      return;
    }

    final task = _queue.removeAt(0);
    task();
    _run();
  }
}
