import '../../data.dart';

class AnimationService {
  final ProjectRepo _projectRepo;

  AnimationService(this._projectRepo);

  Future<AnimationStateModel> createAnimationState({
    required int projectId,
    required String name,
    required int frameRate,
  }) async {
    final newState = AnimationStateModel(
      id: 0,
      name: name,
      frameRate: frameRate,
    );

    return await _projectRepo.createState(projectId, newState);
  }

  Future<void> deleteAnimationState(int stateId) async {
    await _projectRepo.deleteState(stateId);
  }

  Future<void> updateAnimationState({
    required int projectId,
    required AnimationStateModel state,
  }) async {
    await _projectRepo.updateState(projectId, state);
  }

  AnimationStateModel updateFrameRate(AnimationStateModel state, int frameRate) {
    return state.copyWith(frameRate: frameRate);
  }

  AnimationStateModel renameState(AnimationStateModel state, String newName) {
    return state.copyWith();
  }

  int calculateSafeStateIndex(
    List<AnimationStateModel> states,
    int currentIndex,
    int deletedIndex,
  ) {
    if (states.length <= 1) return 0;

    if (deletedIndex == currentIndex) {
      // Deleting current state, select previous or first
      return (deletedIndex > 0) ? deletedIndex - 1 : 0;
    } else if (deletedIndex < currentIndex) {
      // Deleting state before current, adjust index
      return currentIndex - 1;
    } else {
      // Deleting state after current, keep same index
      return currentIndex;
    }
  }

  int findStateIndex(List<AnimationStateModel> states, int stateId) {
    return states.indexWhere((state) => state.id == stateId);
  }

  int findFrameIndex(List<AnimationFrame> frames, int frameId) {
    return frames.indexWhere((frame) => frame.id == frameId);
  }

  AnimationStateModel? findStateById(List<AnimationStateModel> states, int stateId) {
    try {
      return states.firstWhere((state) => state.id == stateId);
    } catch (e) {
      return null;
    }
  }

  AnimationFrame? findFrameById(List<AnimationFrame> frames, int frameId) {
    try {
      return frames.firstWhere((frame) => frame.id == frameId);
    } catch (e) {
      return null;
    }
  }

  List<AnimationFrame> removeFramesForState(
    List<AnimationFrame> allFrames,
    int stateId,
  ) {
    return allFrames.where((frame) => frame.stateId != stateId).toList();
  }

  bool canDeleteState(List<AnimationStateModel> states) {
    return states.length > 1;
  }

  bool canDeleteFrame(List<AnimationFrame> frames) {
    return frames.length > 1;
  }
}
