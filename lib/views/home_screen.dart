import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drivenotes/controller/provider/auth_provider.dart';
import 'package:drivenotes/controller/provider/notes_provider.dart';
import 'package:drivenotes/controller/provider/theme_provider.dart';
import 'package:drivenotes/views/notes_editor_screen.dart';
import 'package:animations/animations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final themeMode = ref.watch(themeProvider);
  
    String themeButtonTooltip = switch (themeMode) {
      ThemeMode.dark => 'Currently in Dark mode',
      ThemeMode.system => 'Currently in system mode',
      ThemeMode.light => 'Currently in light mode',
    };

    IconData themeIcon = switch (themeMode) {
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
      ThemeMode.system => Icons.settings,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DriveNotes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(themeIcon),
            tooltip: themeButtonTooltip,
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh notes',
            onPressed: () => ref.read(notesProvider.notifier).refreshNotes(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: notesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesState.errorMessage != null
              ? _buildErrorView(context, notesState.errorMessage!, ref)
              : notesState.notes.isEmpty
                  ? _buildEmptyView()
                  : _buildNotesList(context, notesState.notes, ref),
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (context, closedContainer) => const NoteEditorScreen(),
        closedElevation: 6.0,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        closedColor: Theme.of(context).colorScheme.primary,
        closedBuilder: (context, openContainer) => Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(notesProvider.notifier).refreshNotes(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No notes yet. Create one by tapping the + button below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List notes, WidgetRef ref) {
    return AnimatedList(
      initialItemCount: notes.length,
      itemBuilder: (context, index, animation) {
        final note = notes[index];
        return _buildNoteItem(context, note, ref, animation);
      },
    );
  }

  Widget _buildNoteItem(BuildContext context, note, WidgetRef ref, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Card(
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(note: note),
                ),
              );
            },
            onLongPress: () => _showDeleteDialog(context, note, ref),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 20,
                        tooltip: 'Delete note',
                        onPressed: () => _showDeleteDialog(context, note, ref),
                      ),
                    ],
                  ),
                  if (note.content.isNotEmpty) const SizedBox(height: 8),
                  if (note.content.isNotEmpty)
                    Text(
                      note.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, note, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("Delete"),
              onPressed: () {
                ref.read(notesProvider.notifier).deleteNote(note.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}