import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/http_client.dart';
import '../data/listings_remote.dart';
import '../data/listings_repo.dart';
import '../data/property.dart';

final dioProvider = Provider((ref) => makeDio());
final remoteProvider = Provider(
  (ref) => ListingsRemote(ref.watch(dioProvider)),
);
final repoProvider = Provider((ref) => ListingsRepo(ref.watch(remoteProvider)));

final listingsProvider = FutureProvider.autoDispose<List<Property>>((
  ref,
) async {
  return ref.watch(repoProvider).list();
});
