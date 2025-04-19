import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drivenotes/controller/provider/auth_provider.dart';
import 'package:drivenotes/models/notes_model.dart';
import 'package:drivenotes/controller/services/drive_service.dart';

class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String? errorMessage;

  NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotesNotifier extends StateNotifier<NotesState> {
  final DriveService _driveService;
  NotesNotifier(this._driveService) : super(NotesState()) {
    refreshNotes();
  }
  Future<void> refreshNotes() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final notes = await _driveService.getNotes();
      if (!mounted) return;
      state = state.copyWith(
        notes: notes,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notes: ${e.toString()}',
      );
    }
  }

  Future<void> createNote(String title, String content) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final note = await _driveService.createNote(title, content);
      state = state.copyWith(
        notes: [...state.notes, note],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create note: ${e.toString()}',
      );
    }
  }

  Future<void> updateNote(String id, String title, String content) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedNote = await _driveService.updateNote(id, title, content);
      state = state.copyWith(
        notes: state.notes.map((note) => 
          note.id == id ? updatedNote : note
        ).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update note: ${e.toString()}',
      );
    }
  }

  Future<void> deleteNote(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _driveService.deleteNote(id);
      state = state.copyWith(
        notes: state.notes.where((note) => note.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete note: ${e.toString()}',
      );
    }
  }
  void clearNotes() {
  state = NotesState();
}
}

final driveServiceProvider = Provider<DriveService>((ref) {
  final authState = ref.watch(authProvider);
   if (!authState.isAuthenticated) {
    return DriveService(null);
  }
  return DriveService(authState.credentials);
});

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) {
    return NotesNotifier(ref.read(driveServiceProvider))..clearNotes();
  }
  
  return NotesNotifier(ref.read(driveServiceProvider));
});