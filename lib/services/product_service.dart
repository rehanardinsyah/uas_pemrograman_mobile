import '../models/product_model.dart';

/// In-memory product service with simple CRUD for demo/UAS.
class ProductService {
  final List<Product> _items = [
    Product(
      id: 'p1',
      name: 'Kaos Vintage',
      category: 'Kaos',
      size: 'M',
      stock: 5,
      price: 70000,
      description: 'Kaos vintage berkualitas, cocok untuk outfit skena',
      imagePath: 'assets/images/kaos_vintage.jpg',
    ),
    Product(
      id: 'p2',
      name: 'Jaket Denim',
      category: 'Jaket',
      size: 'L',
      stock: 2,
      price: 150000,
      description: 'Jaket denim second but in great condition',
      imagePath: 'assets/images/jaket_denim.jpg',
    ),
    Product(
      id: 'p3',
      name: 'Celana beagy',
      category: 'Celana',
      size: 'M',
      stock: 8,
      price: 90000,
      description: 'Celana beagy, nyaman dipakai sehari-hari dan juga biar kalcer',
      imagePath: 'assets/images/celana_beagy.jpg',

    ),
    Product(
      id: 'p4',
      name: 'Sweater Rajut',
      category: 'Sweater',
      size: 'L',
      stock: 4,
      price: 120000,
      description: 'Sweater rajut hangat, cocok untuk cuaca dingin',
     imagePath: 'assets/images/sweater_rajut.jpg',
    ),
    Product(
      id: 'p5',
      name: 'Kemeja Flanel',
      category: 'Kemeja',
      size: 'M',
      stock: 3,
      price: 85000,
      description: 'Kemeja flanel dengan motif kotak-kotak',
      imagePath: 'assets/images/kemeja_flanel.jpg',
    ),
    Product(
      id: 'p6',
      name: 'Celana Y2K',
      category: 'Celana',
      size: 'L',
      stock: 5,
      price: 130000,
      description: 'Celana model Y2K thrift premium',
      imagePath: 'assets/images/celana_y2k.jpg',
    ),
  ];

  List<Product> getAll() => List.unmodifiable(_items);

  Product? getById(String id) {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Product product) {
    _items.add(product);
  }

  void update(Product product) {
    final idx = _items.indexWhere((p) => p.id == product.id);
    if (idx >= 0) _items[idx] = product;
  }

  void delete(String id) {
    _items.removeWhere((p) => p.id == id);
  }

  void updateStock(String id, int delta) {
    final p = getById(id);
    if (p != null) p.stock = (p.stock + delta).clamp(0, 999999);
  }
}