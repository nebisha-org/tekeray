import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TekerayApp());
}

class TekerayApp extends StatelessWidget {
  const TekerayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tekeray',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PropertyListScreen(),
    );
  }
}

class Property {
  final String title;
  final String location;
  final String imageUrl;
  final dynamic price;
  final String description;

  Property({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.description,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      title: json['title'] ?? 'No Title',
      location: json['location'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      price: json['price'] ?? 'N/A',
      description: json['description'] ?? '',
    );
  }
}

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final String apiUrl = 'https://bcad3ddmbc.execute-api.us-east-2.amazonaws.com/Prod/api/properties';
  List<Property> properties = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          properties = jsonList.map((json) => Property.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load properties (status ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void navigateToAddProperty() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
    ).then((_) => fetchProperties());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Properties')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final prop = properties[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: prop.imageUrl.isNotEmpty
                  ? Image.network(prop.imageUrl, width: 60, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(prop.title),
              subtitle: Text('${prop.price} - ${prop.location}'),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(prop.title),
                  content: Text(prop.description),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddProperty,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> submitProperty() async {
    final response = await http.post(
      Uri.parse('https://bcad3ddmbc.execute-api.us-east-2.amazonaws.com/Prod/api/properties'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': titleController.text,
        'location': locationController.text,
        'imageUrl': imageUrlController.text,
        'price': priceController.text,
        'description': descriptionController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      print('Failed to add property');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${response.statusCode}: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: submitProperty, child: const Text('Submit'))
          ],
        ),
      ),
    );
  }
}
