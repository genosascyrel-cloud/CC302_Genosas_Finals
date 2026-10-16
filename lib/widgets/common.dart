import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api.dart';

/// Reusable widget for empty / error states (HCI: feedback + error recovery).
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: t.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: t.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: t.textTheme.bodyMedium),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel ?? 'Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  final String message;
  const LoadingView({super.key, this.message = 'Loading...'});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ]),
      );
}

/// Network image with loading indicator and graceful fallback.
class PlaceImage extends StatelessWidget {
  final String? url;
  final String? fallbackUrl;
  final double height;
  final double? width;
  const PlaceImage({super.key, this.url, this.fallbackUrl, required this.height, this.width});

  Widget _placeholder(BuildContext context) => Container(
        height: height,
        width: width ?? double.infinity,
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(Icons.landscape, size: height / 2.5,
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      );

  @override
  Widget build(BuildContext context) {
    if (url == null) return _placeholder(context);
    return Image.network(
      url!,
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (c, child, p) => p == null
          ? child
          : SizedBox(height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
      errorBuilder: (c, e, s) => (fallbackUrl != null && fallbackUrl != url)
          ? PlaceImage(url: fallbackUrl, height: height, width: width)
          : _placeholder(c),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  const PlaceCard({
    super.key,
    required this.place,
    required this.saved,
    required this.onTap,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              PlaceImage(url: place.imageUrl, height: 170),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(230),
                  child: IconButton(
                    tooltip: saved ? 'Remove from saved' : 'Save place',
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                        color: t.colorScheme.primary),
                    onPressed: onToggleSave,
                  ),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(place.name, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Chip(
                  label: Text(place.category),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6),
                Text(place.description,
                    maxLines: 3, overflow: TextOverflow.ellipsis, style: t.textTheme.bodyMedium),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});
  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Future<Weather> _future = BoholApi().fetchWeather();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      color: t.colorScheme.primaryContainer,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: FutureBuilder<Weather>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Row(children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Checking Tagbilaran weather...'),
              ]);
            }
            if (snap.hasError) {
              return Row(children: [
                const Icon(Icons.cloud_off),
                const SizedBox(width: 12),
                const Expanded(child: Text('Weather unavailable')),
                IconButton(
                  tooltip: 'Retry weather',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() => _future = BoholApi().fetchWeather()),
                ),
              ]);
            }
            final w = snap.data!;
            return Row(children: [
              Icon(w.icon, size: 32, color: t.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${w.temp.round()}°C · ${w.label}',
                      style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text('Tagbilaran, Bohol · wind ${w.wind.round()} km/h', style: t.textTheme.bodySmall),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
