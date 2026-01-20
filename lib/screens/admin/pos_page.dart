import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/formatters.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.read<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Point Of Sale')),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: cart.cartItems.isEmpty
                      ? const Center(child: Text('Keranjang kosong'))
                      : ListView.builder(
                          itemCount: cart.cartItems.length,
                          itemBuilder: (c, i) {
                            final item = cart.cartItems[i];
                            return ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                '${item['quantity']} x ${formatIdr(item['price'])}',
                              ),
                              trailing: Text(
                                formatIdr(
                                  item['price'] * item['quantity'],
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ===== TOTAL & BAYAR =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: ${formatIdr(cart.totalPrice)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: cart.cartItems.isEmpty || _isProcessing
                            ? null
                            : () async {
                                setState(() => _isProcessing = true);

                                // kurangi stok produk
                                for (var item in cart.cartItems) {
                                  productProvider.updateStock(
                                    item['product_id'],
                                    -item['quantity'],
                                  );
                                }

                                await cart.clearCart();

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Transaksi berhasil'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                setState(() => _isProcessing = false);
                              },
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('BAYAR'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
