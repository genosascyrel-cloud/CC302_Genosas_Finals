import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api.dart';
import '../services/saved_store.dart';

/// Form with validation to add your own place to My Trip.
class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});
  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Nature';

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final name = _name.text.trim();
    savedStore.add(Place(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: _desc.text.trim().isEmpty ? 'My own saved place.' : _desc.text.trim(),
      category: _category,
      isCustom: true,
    ));
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('"$name" added to My Trip')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Place')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Place name *', prefixIcon: Icon(Icons.place)),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Please enter a place name';
                  if (s.length < 3) return 'Name must be at least 3 characters';
                  if (savedStore.items.any((p) => p.name.toLowerCase() == s.toLowerCase())) {
                    return 'This place is already in My Trip';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                items: BoholApi.categories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _desc,
                maxLines: 4,
                maxLength: 200,
                decoration: const InputDecoration(
                    labelText: 'Description (optional)', alignLabelWithHint: true),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                    onPressed: _submit, icon: const Icon(Icons.check), label: const Text('Save place')),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
