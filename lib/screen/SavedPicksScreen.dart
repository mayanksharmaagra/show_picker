import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/Suggestion.dart';

class SavedPicksScreen extends StatefulWidget {
  const SavedPicksScreen({super.key});

  @override
  State<SavedPicksScreen> createState() => _SavedPicksScreenState();
}

class _SavedPicksScreenState extends State<SavedPicksScreen> {
  final List<Suggestion> _allSaved = [
    Suggestion(
      title: "Drishyam 2",
      year: 2022,
      reason: "Masterpiece",
      type: "movie",
      vote_average: 8.4,
    ),
    Suggestion(
      title: "Star Quest",
      year: 2023,
      reason: "Sci-fi journey",
      type: "movie",
      vote_average: 7.2,
    ),
    Suggestion(
      title: "Super Nova",
      year: 2021,
      reason: "Action packed",
      type: "movie",
    ),
    Suggestion(
      title: "Forest Tales",
      year: 2020,
      reason: "Nature documentary",
      type: "movie",
    ),
    Suggestion(
      title: "Kingdom's Fall",
      year: 2019,
      reason: "Epic drama",
      type: "movie",
    ),
    Suggestion(
      title: "Love in Paris",
      year: 2024,
      reason: "Romantic",
      type: "movie",
    ),
  ];

  List<Suggestion> _filteredSaved = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSaved = _allSaved;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredSaved = _allSaved
          .where((s) => s.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),
      appBar: _isSearching ? _buildSearchAppBar() : _buildDefaultAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_filteredSaved.length} titles saved",
                  style: const TextStyle(
                    color: Color(0xff94A3B8),
                    fontSize: 14,
                  ),
                ),
                _buildSortDropdown(),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.65,
              ),
              itemCount: _filteredSaved.length,
              itemBuilder: (context, index) => _buildMovieCard(_filteredSaved[index]),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff0F172A),
      elevation: 0,
      title: const Text(
        "My Saved Picks",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => setState(() => _isSearching = true),
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: _showFilterSheet,
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff1E293B),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            _filteredSaved = _allSaved;
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Search your picks...",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildSortDropdown() {
    return InkWell(
      onTap: () {}, // TODO: Implement sort
      child: const Row(
        children: [
          Text(
            "Sort: Recent",
            style: TextStyle(color: Color(0xff3B82F6), fontSize: 13),
          ),
          Icon(Icons.arrow_drop_down, color: Color(0xff3B82F6)),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Suggestion suggestion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xff1E293B),
                  child: suggestion.poster_path != null
                      ? CachedNetworkImage(
                          imageUrl: suggestion.poster_path!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.movie, color: Colors.white24, size: 40),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Image.asset(
                  "assets/images/flicker_star.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          suggestion.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (suggestion.vote_average != null)
          _buildStars(suggestion.vote_average!)
        else
          const Text(
            "Rate it",
            style: TextStyle(color: Color(0xff64748B), fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildStars(double rating) {
    // TMDB is 0-10, we show 5 stars
    int stars = (rating / 2).round();
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: const Color(0xffFBBF24),
          size: 14,
        );
      }),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter Picks",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Simulating filter options
              _buildFilterOption("Movies"),
              _buildFilterOption("TV Shows"),
              _buildFilterOption("Recently Added"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Icon(Icons.circle_outlined, color: Color(0xff64748B)),
        ],
      ),
    );
  }
}
