
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BoholExplorerApp());
}

const navy = Color(0xFF153448);
const teal = Color(0xFF087F8C);
const background = Color(0xFFF4F7F9);

class Destination {
  final String name;
  final String municipality;
  final String category;
  final String description;
  final String image;
  final String wikiTitle;

  const Destination({
    required this.name,
    required this.municipality,
    required this.category,
    required this.description,
    required this.image,
    required this.wikiTitle,
  });
}

const destinations = [
  Destination(
    name: 'Chocolate Hills',
    municipality: 'Carmen, Bohol',
    category: 'Nature',
    description:
        'Explore the famous geological landscape of cone-shaped hills that turn brown during the dry season.',
    image: 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e',
    wikiTitle: 'Chocolate_Hills',
  ),
  Destination(
    name: 'Loboc River',
    municipality: 'Loboc, Bohol',
    category: 'Nature',
    description:
        'Discover the scenic river, lush tropical surroundings, and popular river cruise experiences.',
    image: 'https://images.unsplash.com/photo-1437482078695-73f5ca6c96e2',
    wikiTitle: 'Loboc_River',
  ),
  Destination(
    name: 'Alona Beach',
    municipality: 'Panglao, Bohol',
    category: 'Beach',
    description:
        'Visit a popular white-sand beach known for clear water, snorkeling, and island activities.',
    image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
    wikiTitle: 'Alona_Beach',
  ),
  Destination(
    name: 'Philippine Tarsier Sanctuary',
    municipality: 'Corella, Bohol',
    category: 'Wildlife',
    description:
        'Learn about the Philippine tarsier and the importance of protecting its natural habitat.',
    image: 'https://images.unsplash.com/photo-1474511320723-9a56873867b5',
    wikiTitle: 'Philippine_tarsier',
  ),
  Destination(
    name: 'Baclayon Church',
    municipality: 'Baclayon, Bohol',
    category: 'Culture',
    description:
        'Discover one of Bohol’s historic churches and learn about local heritage and architecture.',
    image: 'https://images.unsplash.com/photo-1548013146-72479768bada',
    wikiTitle: 'Baclayon_Church',
  ),
  Destination(
    name: 'Dumaluan Beach',
    municipality: 'Panglao, Bohol',
    category: 'Beach',
    description:
        'Enjoy a relaxing coastal destination with sandy shores and beautiful sea views.',
    image: 'https://images.unsplash.com/photo-1519046904884-53103b34b206',
    wikiTitle: 'Panglao',
  ),
  Destination(
    name: 'Anda Beach',
    municipality: 'Anda, Bohol',
    category: 'Beach',
    description:
        'Explore the quieter eastern side of Bohol, with white sand and inviting coastal scenery.',
    image: 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2',
    wikiTitle: 'Anda_Bohol',
  ),
];

class BoholExplorerApp extends StatelessWidget {
  const BoholExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bohol Tourist Explorer',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          primary: navy,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: navy,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  String selectedCategory = 'All';
  String searchText = '';
  final searchController = TextEditingController();
  List<String> favoriteNames = [];
  List<Map<String, dynamic>> apiResults = [];
  bool loading = false;
  String? apiError;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      favoriteNames = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favoriteNames);
  }

  Future<void> toggleFavorite(Destination destination) async {
    setState(() {
      if (favoriteNames.contains(destination.name)) {
        favoriteNames.remove(destination.name);
      } else {
        favoriteNames.add(destination.name);
      }
    });
    await saveFavorites();
  }

  Future<void> deleteFavorite(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove favorite?'),
        content: Text('Remove $name from your saved destinations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => favoriteNames.remove(name));
      await saveFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorite removed successfully')),
        );
      }
    }
  }

  Future<void> searchWikipedia(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      loading = true;
      apiError = null;
      apiResults = [];
    });

    try {
      final uri = Uri.https(
        'en.wikipedia.org',
        '/w/api.php',
        {
          'action': 'query',
          'list': 'search',
          'srsearch': '$query Bohol Philippines tourist destination',
          'format': 'json',
          'origin': '*',
        },
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('The tourism search service is unavailable.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final queryData = data['query'] as Map<String, dynamic>;
      final results = queryData['search'] as List<dynamic>;

      if (!mounted) return;
      setState(() {
        apiResults = results.take(8).map((item) {
          final result = item as Map<String, dynamic>;
          return <String, dynamic>{
            'title': result['title'] ?? '',
            'snippet': (result['snippet'] ?? '')
                .toString()
                .replaceAll(RegExp(r'<[^>]*>'), ''),
          };
        }).toList();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        apiError = 'Could not load search results. Check your connection.';
      });
    }
  }

  List<Destination> get filteredDestinations {
    Iterable<Destination> items = destinations;

    if (selectedTab == 1) {
      items = items.where((d) => favoriteNames.contains(d.name));
    }

    if (selectedCategory != 'All') {
      items = items.where((d) => d.category == selectedCategory);
    }

    if (searchText.trim().isNotEmpty) {
      final query = searchText.toLowerCase();
      items = items.where((d) =>
          d.name.toLowerCase().contains(query) ||
          d.municipality.toLowerCase().contains(query) ||
          d.category.toLowerCase().contains(query));
    }

    return items.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isFavorites = selectedTab == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.travel_explore, color: teal, size: 30),
            SizedBox(width: 10),
            Text(
              'Bohol Explorer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh favorites',
            onPressed: loadFavorites,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [navy, teal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR NEXT ADVENTURE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Discover the beauty of Bohol.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Find beaches, natural wonders, wildlife, '
                              'and cultural destinations across Bohol.',
                              style: TextStyle(
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() => searchText = value);
                          if (value.trim().length >= 3) {
                            searchWikipedia(value);
                          } else {
                            setState(() => apiResults = []);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search places or municipalities...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchText = '';
                                apiResults = [];
                                apiError = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isFavorites
                                  ? 'Saved destinations'
                                  : 'Explore destinations',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                          ),
                          Text(
                            '${filteredDestinations.length} places',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            'All',
                            'Nature',
                            'Beach',
                            'Wildlife',
                            'Culture',
                          ].map((category) {
                            final selected = selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: selected,
                                onSelected: (_) => setState(
                                  () => selectedCategory = category,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (filteredDestinations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 44,
                                color: Colors.black38,
                              ),
                              SizedBox(height: 10),
                              Text('No destinations found.'),
                              Text('Try another search or category.'),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredDestinations.length,
                          itemBuilder: (context, index) {
                            final destination = filteredDestinations[index];
                            return DestinationCard(
                              destination: destination,
                              isFavorite:
                                  favoriteNames.contains(destination.name),
                              onFavorite: () => toggleFavorite(destination),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(
                                    destination: destination,
                                    isFavorite: favoriteNames
                                        .contains(destination.name),
                                    onFavorite: () =>
                                        toggleFavorite(destination),
                                  ),
                                ),
                              ),
                              onDelete: isFavorites
                                  ? () => deleteFavorite(destination.name)
                                  : null,
                            );
                          },
                        ),
                      if (searchText.trim().length >= 3) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Wikipedia API results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (apiError != null)
                          Text(apiError!)
                        else if (apiResults.isEmpty)
                          const Text('No additional results available.')
                        else
                          ...apiResults.map(
                            (result) => Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.public,
                                  color: teal,
                                ),
                                title: Text(result['title'].toString()),
                                subtitle: Text(
                                  result['snippet'].toString(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.open_in_new),
                                onTap: () {
                                  final title = Uri.encodeComponent(
                                    result['title'].toString()
                                        .replaceAll(' ', '_'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Wikipedia article: $title',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 20),
                      const Text(
                        'Travel responsibly. Respect local communities '
                        'and protect the natural beauty of Bohol.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                NavigationBar(
                  selectedIndex: selectedTab,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedTab = index;
                      selectedCategory = 'All';
                      searchText = '';
                      searchController.clear();
                      apiResults = [];
                      apiError = null;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Explore',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.favorite_outline),
                      selectedIcon: Icon(Icons.favorite),
                      label: 'Favorites',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  destination.image,
                  width: 100,
                  height: 112,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 112,
                    color: const Color(0xFFDCEFEB),
                    child: const Icon(
                      Icons.landscape,
                      size: 38,
                      color: teal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.category.toUpperCase(),
                      style: const TextStyle(
                        color: teal,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      destination.municipality,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'View destination  →',
                      style: TextStyle(
                        color: teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : navy,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Delete favorite',
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Destination destination;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const DetailScreen({
    super.key,
    required this.destination,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destination details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              destination.image,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                color: const Color(0xFFDCEFEB),
                child: const Icon(Icons.landscape, size: 80, color: teal),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            destination.category.toUpperCase(),
            style: const TextStyle(
              color: teal,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            destination.name,
            style: const TextStyle(
              color: navy,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: teal),
              const SizedBox(width: 6),
              Expanded(child: Text(destination.municipality)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            destination.description,
            style: const TextStyle(fontSize: 16, height: 1.7),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            label: Text(
              isFavorite ? 'Saved to favorites' : 'Save to favorites',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              final query = Uri.encodeComponent(
                '${destination.name}, ${destination.municipality}',
              );
              final url = 'https://www.openstreetmap.org/search?query=$query';
              showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Find this destination'),
                  content: SelectableText(url),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Show map link'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Please confirm current opening hours, entrance fees, '
            'and local travel conditions before visiting.',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
