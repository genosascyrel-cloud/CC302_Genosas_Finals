import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api.dart';
import '../services/saved_store.dart';
import '../widgets/common.dart';
import 'detail.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _api = BoholApi();
  late Future<List<Place>> _future;
  String _query = '';
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _future = _api.fetchPlaces();
  }

  void _retry() => setState(() => _future = _api.fetchPlaces());

  Future<void> _refresh() async {
    setState(() => _future = _api.fetchPlaces());
    try {
      await _future;
    } catch (_) {}
  }

  void _toggle(Place p) {
    final nowSaved = savedStore.toggle(p);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(nowSaved ? '${p.name} added to My Trip' : '${p.name} removed from My Trip'),
        action: nowSaved ? null : SnackBarAction(label: 'UNDO', onPressed: () => savedStore.add(p)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bohol Explorer')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(children: [
            const WeatherCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search attractions...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _query = '')),
                ),
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: _query, selection: TextSelection.collapsed(offset: _query.length))),
                onChanged: (v) => _query = v,
                onSubmitted: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final c in BoholApi.categories)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: _buildList()),
          ]),
        ),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Place>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(message: 'Loading Bohol attractions...');
        }
        if (snap.hasError) {
          return StateMessage(
            icon: Icons.wifi_off,
            title: 'Something went wrong',
            message: snap.error.toString(),
            actionLabel: 'Retry',
            onAction: _retry,
          );
        }
        final q = _query.trim().toLowerCase();
        final places = snap.data!.where((p) {
          final okCat = _category == 'All' || p.category == _category;
          final okQ = q.isEmpty ||
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q);
          return okCat && okQ;
        }).toList();

        if (places.isEmpty) {
          return const StateMessage(
            icon: Icons.search_off,
            title: 'No places found',
            message: 'Try a different search or choose another category.',
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListenableBuilder(
            listenable: savedStore,
            builder: (context, _) => ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, i) {
                final p = places[i];
                return PlaceCard(
                  place: p,
                  saved: savedStore.isSaved(p.id),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => DetailScreen(place: p))),
                  onToggleSave: () => _toggle(p),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
