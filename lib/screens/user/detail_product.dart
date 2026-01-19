import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';

class DetailProduct extends StatefulWidget {
  const DetailProduct({super.key});

  @override
  State<DetailProduct> createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct> {
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== GAMBAR PRODUK (FIX) ======
            SizedBox(
              height: 220,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(product),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Kategori: ${product.category} • Size: ${product.size}'),
            const SizedBox(height: 8),
            Text(
              'Harga: ${formatIdr(product.price)}',
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              'Stok: ${product.stock}',
              style: TextStyle(
                color: product.stock > 0 ? Colors.black : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(product.description),
            const Spacer(),
            // ====== TOMBOL TAMBAH KE KERANJANG ======
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: product.stock > 0 && !_isAddingToCart
                    ? () => _addToCart(product)
                    : null,
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_shopping_cart),
                label: Text(
                  _isAddingToCart
                      ? 'Menambahkan...'
                      : 'Tambah ke Keranjang',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: product.stock > 0 ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ====== HANDLE SEMUA JENIS GAMBAR ======
  Widget _buildProductImage(Product product) {
    // 1️⃣ Asset lokal (assets/images/...)
    if (product.imagePath != null &&
        product.imagePath!.isNotEmpty &&
        product.imagePath!.startsWith('assets/')) {
      return Image.asset(
        product.imagePath!,
        fit: BoxFit.cover,
      );
    }

    // 2️⃣ File dari galeri (admin upload)
    if (product.imagePath != null &&
        product.imagePath!.isNotEmpty &&
        !product.imagePath!.startsWith('assets/') &&
        !kIsWeb) {
      return Image.file(
        File(product.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorImage(),
      );
    }

    // 3️⃣ Gambar dari internet
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorImage(),
      );
    }

    // 4️⃣ Default
    return _errorImage();
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image,
        size: 72,
        color: Colors.grey,
      ),
    );
  }

  /// ====== TAMBAH KE KERANJANG ======
  Future<void> _addToCart(Product product) async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      await context.read<CartProvider>().addToCart(product, 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} berhasil ditambahkan ke keranjang'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan ke keranjang'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }
}
