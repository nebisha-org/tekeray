import 'listings_remote.dart';
import 'property.dart';

class ListingsRepo {
  final ListingsRemote remote;
  ListingsRepo(this.remote);

  Future<List<Property>> list() => remote.fetchProperties();
}
