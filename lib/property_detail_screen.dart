import 'package:flutter/material.dart';

class PropertyDetailScreen extends StatelessWidget {
  // We'll pass the full property data to this screen
  final Map<String, String> property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property['title']!), // Display property title in app bar
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView for scrollability
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero animation for smooth image transition (optional but nice!)
            Hero(
              tag:
                  'propertyImage-${property['imageUrl']!}', // Unique tag for hero animation
              child: Image.network(
                property['imageUrl']!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 250,
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
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['title']!,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        property['location']!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    property['price']!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property['description']!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // Contact Landlord Button
                  SizedBox(
                    width: double.infinity, // Make button take full width
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement contact landlord functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Contacting landlord for ${property['title']}!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.phone,
                      ), // or Icons.email, Icons.message
                      label: const Text('Contact Landlord'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
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
