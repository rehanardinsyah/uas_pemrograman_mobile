import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../utils/formatters.dart';
import '../../widgets/product_card.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _lowStockOnly = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v, void Function(String) apply) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => apply(v));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    var products = provider.filteredItems;

    if (_lowStockOnly) {
      products = products.where((p) => p.stock <= 3).toList();
    }

    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Admin'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (user?.name.isNotEmpty == true) ? user!.name[0] : 'A',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Produk'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/add');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthProvider>().signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/admin/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildStats(provider),
          _buildSearch(provider),
          _buildFilter(provider),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (c, i) =>
                  _buildCard(context, products[i], provider.query),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _statCard('Total Produk', provider.items.length.toString()),
          const SizedBox(width: 8),
          _statCard(
            'Low Stock',
            provider.items.where((p) => p.stock <= 3).length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Cari produk (Admin)...',
          suffixIcon: provider.query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    provider.clearQuery();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (v) => _onSearchChanged(v, (q) => provider.setQuery(q)),
      ),
    );
  }

  Widget _buildFilter(ProductProvider provider) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final c in provider.categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c),
                selected: provider.category == c,
                onSelected: (_) => provider.setCategory(c),
              ),
            ),
          FilterChip(
            label: const Text('Low stock'),
            selected: _lowStockOnly,
            onSelected: (v) => setState(() => _lowStockOnly = v),
          ),
        ],
      ),
    );
  }

  /// =============================
  /// CARD PRODUK (FIX IMAGE)
  /// =============================
  Widget _buildCard(BuildContext context, Product p, String q) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(p),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(formatIdr(p.price),
                style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () =>
                      context.read<ProductProvider>().updateStock(p.id, -1),
                ),
                Text('Stok: ${p.stock}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      context.read<ProductProvider>().updateStock(p.id, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// =============================
  /// IMAGE AMAN WEB
  /// =============================
  Widget _buildProductImage(Product p) {
    if (p.imagePath != null && p.imagePath!.isNotEmpty) {
      return Image.asset(
        p.imagePath!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }

    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) {
      return Image.network(
        p.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }

    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, size: 48),
    );
  }
}
