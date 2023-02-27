import 'dart:async';
import '/utils/mutex.dart';

typedef OperationStatusIsCancelledFunc = bool Function();

class OperationStatus {
  OperationStatus(OperationStatusIsCancelledFunc isCancelledFunc)
      : _isCancelledFunc = isCancelledFunc;

  final OperationStatusIsCancelledFunc _isCancelledFunc;

  bool get isCancelled => _isCancelledFunc();
}

typedef CancelableOperationFunc = Future Function(OperationStatus);

class Operation {
  factory Operation.debounce(Duration debounceDuration,
      {bool? mustCancelCurrent}) {
    return Operation(
        debounceDuration: debounceDuration,
        mustCancelCurrent: mustCancelCurrent);
  }

  factory Operation.singleton({bool? mustCancelCurrent}) {
    return Operation(mustCancelCurrent: mustCancelCurrent);
  }

  Operation({Duration? debounceDuration, bool? mustCancelCurrent})
      : _debounceDuration = debounceDuration,
        _mustCancelCurrent = mustCancelCurrent;

  final Duration? _debounceDuration;
  bool _cancelAll = false;
  final bool? _mustCancelCurrent;
  Timer? _timer;
  final _mutex = Mutex();
  int _currentTaskId = 0;

  Future schedule(CancelableOperationFunc callback) async {
    final debounceDuration = _debounceDuration;
    if (debounceDuration != null) {
      if (_timer?.isActive ?? false) {
        _timer?.cancel();
      }

      _timer = Timer(debounceDuration, () {
        final thisTaskId = ++_currentTaskId;
        final status = OperationStatus(() =>
            _cancelAll ||
            ((_mustCancelCurrent ?? false) && (thisTaskId != _currentTaskId)));
        _mutex.protect(() async {
          await callback(status);
        });
      });
    } else {
      final thisTaskId = ++_currentTaskId;
      final status = OperationStatus(() =>
          _cancelAll ||
          ((_mustCancelCurrent ?? false) && (thisTaskId != _currentTaskId)));
      _mutex.protect(() async {
        await callback(status);
      });
    }
  }

  Future cancelAll() async {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _cancelAll = true;
    _mutex.protect(() async {
      // Just check that no other operation is in the queue
    });
    _cancelAll = false;
  }
}
