import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../listings/data/property.dart';
import '../providers/listings_provider.dart';

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Properties')),
      body: listings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load properties:\n$err',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No properties yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = items[i];
              return ListTile(
                leading: (p.imageUrl.isNotEmpty)
                    ? Image.network(
                        p.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.home),
                title: Text(p.title),
                subtitle: Text(p.location),
                trailing: Text('\$${p.price}/mo'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _PropertyDetails(property: p),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed('/addProperty'); // keep your existing route or adjust
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _PropertyDetails extends StatelessWidget {
  const _PropertyDetails({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (property.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                property.imageUrl,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            property.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place, size: 18),
              const SizedBox(width: 6),
              Text(property.location),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${property.price}/mo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(property.description),
        ],
      ),
    );
  }
}
