import 'dart:async';

class Mutex {
  final List<Completer<void>> _waiting = [];
  bool _isLocked = false;

  bool _tryNextJob(Completer<void> job) {
    if (_isLocked) return false;
    _isLocked = true;
    job.complete();
    return true;
  }

  Future<void> _acquire() {
    final job = Completer<void>();

    if (_waiting.isNotEmpty || !_tryNextJob(job)) {
      _waiting.add(job);
    }

    return job.future;
  }

  void _release() {
    if (!_isLocked) {
      throw StateError("_acquire was not called!");
    }
    _isLocked = false;

    if (_waiting.isNotEmpty) {
      final job = _waiting.first;
      _tryNextJob(job);
      _waiting.removeAt(0);
    }
  }

  Future protect(Future Function() fnc) async {
    await _acquire();
    try {
      await fnc();
    } finally {
      _release();
    }
  }
}
