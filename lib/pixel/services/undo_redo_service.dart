import '../pixel_draw_state.dart';

class UndoRedoService {
  static const int _maxUndoStates = 50;

  final List<PixelDrawState> _undoStack = [];
  final List<PixelDrawState> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void saveState(PixelDrawState state) {
    // Create a deep copy of the state
    final stateCopy = state.copyWith();

    _undoStack.add(stateCopy);

    // Limit the undo stack size
    if (_undoStack.length > _maxUndoStates) {
      _undoStack.removeAt(0);
    }

    // Clear redo stack when new state is saved
    _redoStack.clear();
  }

  PixelDrawState? undo(PixelDrawState currentState) {
    if (!canUndo) return null;

    // Save current state to redo stack
    _redoStack.add(currentState.copyWith());

    // Get previous state from undo stack
    final previousState = _undoStack.removeLast();

    return previousState.copyWith(
      canUndo: canUndo,
      canRedo: canRedo,
    );
  }

  PixelDrawState? redo(PixelDrawState currentState) {
    if (!canRedo) return null;

    // Save current state to undo stack
    _undoStack.add(currentState.copyWith());

    // Get next state from redo stack
    final nextState = _redoStack.removeLast();

    return nextState.copyWith(
      canUndo: canUndo,
      canRedo: canRedo,
    );
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  int get undoStackSize => _undoStack.length;
  int get redoStackSize => _redoStack.length;

  // For debugging purposes
  List<String> getUndoStackSummary() {
    return _undoStack.map((state) => 'Frame: ${state.currentFrameIndex}, Layer: ${state.currentLayerIndex}').toList();
  }

  List<String> getRedoStackSummary() {
    return _redoStack.map((state) => 'Frame: ${state.currentFrameIndex}, Layer: ${state.currentLayerIndex}').toList();
  }
}
