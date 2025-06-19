import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekeray/welcome_screen.dart'; // Make sure this path is correct
import 'package:tekeray/property_detail_screen.dart'; // Make sure this path is correct
import 'package:tekeray/add_property_screen.dart'; // Add this line
// ... keep existing imports

// --- Main entry point of the app ---
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Required for SharedPreferences
  runApp(const MyApp());
}

// --- MyApp handles initial loading and conditional screen display ---
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _hasSeenWelcome = false;
  // If you wanted to load the initial role directly on subsequent launches,
  // you could uncomment the line below and use it in your conditional logic.
  // String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenWelcome = prefs.getBool(HAS_SEEN_WELCOME_KEY) ?? false;
      // _userRole = prefs.getString(USER_ROLE_KEY); // Load role if needed on subsequent launches
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Show a loader while checking
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Tekeray',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          elevation: 4,
        ),
      ),
      // --- Conditional Home Screen ---
      home: _hasSeenWelcome
          ? const PropertyBrowseScreen()
          : const WelcomeScreen(),
    );
  }
}

// --- Property Browse Screen ---
class PropertyBrowseScreen extends StatefulWidget {
  const PropertyBrowseScreen({super.key});

  @override
  State<PropertyBrowseScreen> createState() => _PropertyBrowseScreenState();
}

class _PropertyBrowseScreenState extends State<PropertyBrowseScreen> {
  // We'll use dummy data for now
  final List<Map<String, String>> dummyProperties = [
    {
      'imageUrl':
          'https://via.placeholder.com/400x250/F8F8F8/000000?text=Property+1',
      'title': 'Spacious 2-Bedroom Apartment',
      'location': 'Downtown City, CA',
      'price': '\$2,500/month',
      'description':
          'Bright and airy apartment with modern amenities. Perfect for urban living.',
    },
    {
      'imageUrl':
          'https://via.placeholder.com/400x250/F8F8F8/000000?text=Property+2',
      'title': 'Cozy Studio near Park',
      'location': 'Greenwood Park, NY',
      'price': '\$1,800/month',
      'description':
          'Compact and efficient studio, ideal for singles or students. Close to public transport.',
    },
    {
      'imageUrl':
          'https://via.placeholder.com/400x250/F8F8F8/000000?text=Property+3',
      'title': 'Family Home with Garden',
      'location': 'Suburbia Hills, TX',
      'price': '\$3,200/month',
      'description':
          'Large 4-bedroom house with a spacious backyard, great for kids and pets. Quiet neighborhood.',
    },
    {
      'imageUrl':
          'https://via.placeholder.com/400x250/F8F8F8/000000?text=Property+4',
      'title': 'Loft with City Views',
      'location': 'Art District, IL',
      'price': '\$2,900/month',
      'description':
          'Trendy loft apartment with high ceilings and panoramic city views. Artistic vibe.',
    },
    {
      'imageUrl':
          'https://via.placeholder.com/400x250/F8F8F8/000000?text=Property+5',
      'title': 'Beachfront Condo',
      'location': 'Coastal Breeze, FL',
      'price': '\$4,500/month',
      'description':
          'Luxurious beachfront condo with direct access to the sand. Stunning ocean views.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tekeray: Browse Properties'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality coming soon!'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0), // Padding around the entire list
        itemCount: dummyProperties.length,
        itemBuilder: (context, index) {
          final property = dummyProperties[index];
          return PropertyCard(
            imageUrl: property['imageUrl']!,
            title: property['title']!,
            location: property['location']!,
            price: property['price']!,
            description: property['description']!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PropertyDetailScreen(property: property),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
          );
        },
        child: const Icon(Icons.add_home_work),
      ),
    );
  }
}

// --- Reusable Property Card Widget ---
class PropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final String description;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0), // Space between cards
      child: InkWell(
        // Makes the card tappable
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Match card border radius
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity, // Take full width
                fit: BoxFit.cover, // Cover the area without distortion
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
