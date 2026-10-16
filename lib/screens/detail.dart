import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/saved_store.dart';
import '../widgets/common.dart';

class DetailScreen extends StatelessWidget {
  final Place place;
  const DetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: savedStore,
      builder: (context, _) {
        final saved = savedStore.isSaved(place.id);
        final t = Theme.of(context);

        final image = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PlaceImage(url: place.largeImageUrl, fallbackUrl: place.imageUrl, height: 260),
        );
        final info = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.name, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Chip(avatar: const Icon(Icons.label_outline, size: 18), label: Text(place.category)),
            const SizedBox(height: 12),
            Text(place.description, style: t.textTheme.bodyLarge?.copyWith(height: 1.5)),
            if (place.wikiUrl != null) ...[
              const SizedBox(height: 16),
              Text('Source (Wikipedia):', style: t.textTheme.labelMedium),
              SelectableText(place.wikiUrl!, style: TextStyle(color: t.colorScheme.primary)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: Icon(saved ? Icons.bookmark_remove : Icons.bookmark_add),
                label: Text(saved ? 'Remove from My Trip' : 'Add to My Trip'),
                onPressed: () {
                  final now = savedStore.toggle(place);
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(SnackBar(
                        content: Text(now ? 'Added to My Trip' : 'Removed from My Trip')));
                },
              ),
            ),
          ]),
        );

        return Scaffold(
          appBar: AppBar(title: Text(place.name)),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: LayoutBuilder(builder: (context, box) {
                  // Responsive: side-by-side on wide screens / landscape.
                  if (box.maxWidth > 600) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Padding(padding: const EdgeInsets.all(16), child: image)),
                      Expanded(child: info),
                    ]);
                  }
                  return Column(children: [
                    Padding(padding: const EdgeInsets.all(16), child: image),
                    info,
                  ]);
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
