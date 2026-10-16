import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/saved_store.dart';
import '../widgets/common.dart';
import 'add_place.dart';
import 'detail.dart';

/// "My Trip": saved places. Supports ADD (custom), EDIT (note) and DELETE.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  Future<bool> _confirm(BuildContext context, Place p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this place?'),
        content: Text('"${p.name}" will be removed from My Trip.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _delete(BuildContext context, Place p) {
    final index = savedStore.remove(p.id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('"${p.name}" deleted'),
        action: SnackBarAction(label: 'UNDO', onPressed: () => savedStore.restore(p, index)),
      ));
  }

  Future<void> _editNote(BuildContext context, Place p) async {
    final result = await showDialog<String>(
        context: context, builder: (_) => _NoteDialog(initial: p.note, title: p.name));
    if (result != null) savedStore.updateNote(p.id, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Trip')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add place'),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlaceScreen())),
      ),
      body: ListenableBuilder(
        listenable: savedStore,
        builder: (context, _) {
          final items = savedStore.items;
          if (items.isEmpty) {
            return const StateMessage(
              icon: Icons.bookmark_border,
              title: 'Your trip is empty',
              message: 'Save attractions from Explore, or tap "Add place" to create your own.',
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 88, top: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final p = items[i];
                  return Dismissible(
                    key: ValueKey(p.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirm(context, p),
                    onDismissed: (_) => _delete(context, p),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PlaceImage(url: p.imageUrl, height: 60, width: 60),
                        ),
                        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          p.note.isEmpty ? p.category : '${p.category} · ${p.note}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => DetailScreen(place: p))),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              tooltip: 'Edit note',
                              icon: const Icon(Icons.edit_note),
                              onPressed: () => _editNote(context, p)),
                          IconButton(
                              tooltip: 'Delete',
                              icon: Icon(Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () async {
                                if (await _confirm(context, p) && context.mounted) {
                                  _delete(context, p);
                                }
                              }),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  final String initial;
  final String title;
  const _NoteDialog({required this.initial, required this.title});
  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Note for ${widget.title}'),
        content: TextField(
          controller: _c,
          maxLength: 80,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Visit on Day 2, bring sunscreen'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, _c.text.trim()), child: const Text('Save')),
        ],
      );
}
