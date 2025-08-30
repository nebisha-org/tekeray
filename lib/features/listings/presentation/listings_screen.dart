import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/listings_providers.dart';
import '../data/property.dart';

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(listingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tekeray')),
      body: async.when(
        data: (items) => _List(items: items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final List<Property> items;
  const _List({required this.items});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _Tile(p: items[i]),
    );
  }
}

class _Tile extends StatelessWidget {
  final Property p;
  const _Tile({required this.p});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: p.coverUrl.isNotEmpty
          ? Image.network(p.coverUrl, width: 56, height: 56, fit: BoxFit.cover)
          : const Icon(Icons.home),
      title: Text(p.title),
      subtitle: Text(p.address),
      trailing: Text('\$${p.price}/mo'),
    );
  }
}
