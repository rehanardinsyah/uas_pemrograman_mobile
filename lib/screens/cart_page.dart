import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.cartItems.isEmpty
              ? const Center(child: Text('Keranjang masih kosong'))
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
    );
  }
}
