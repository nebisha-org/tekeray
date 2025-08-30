// lib/main.dart
import 'package:flutter/material.dart';
import 'features/listings/data/property.dart';
import 'features/listings/data/listings_remote.dart';
import 'core/http_client.dart';

void main() {
  runApp(const TekerayApp());
}

class TekerayApp extends StatelessWidget {
  const TekerayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tekeray',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
      ),
      home: const PropertyListScreen(),
    );
  }
}

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late final ListingsRemote remote;
  List<Property> properties = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    remote = ListingsRemote(makeDio());
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final list = await remote.fetchProperties();
      setState(() {
        properties = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> navigateToAddProperty() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyScreen(remote: remote),
      ),
    );
    if (created == true) {
      await fetchProperties();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = isLoading
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
                  // ✅ Fallback icon if image fails (e.g., CORS on web)
                  leading: prop.imageUrl.isNotEmpty
                      ? Image.network(
                          prop.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        )
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
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Available Properties')),
      body: RefreshIndicator(onRefresh: fetchProperties, child: body),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddProperty,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key, required this.remote});
  final ListingsRemote remote;

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _form = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final imageUrlController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    imageUrlController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitProperty() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final priceStr = priceController.text.trim();
      final priceNum = num.tryParse(priceStr) ?? 0;

      final prop = Property(
        title: titleController.text.trim(),
        location: locationController.text.trim(),
        imageUrl: imageUrlController.text.trim(),
        price: priceNum,
        description: descriptionController.text.trim(),
      );

      await widget.remote.createProperty(prop);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Property added')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding property: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 12);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              spacing,
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              spacing,
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              spacing,
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              spacing,
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : submitProperty,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
