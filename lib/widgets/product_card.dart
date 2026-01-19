import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/formatters.dart';

/// Highlight search query
TextSpan buildHighlightedTextSpan(
  String text,
  String query,
  TextStyle normalStyle,
  TextStyle highlightStyle,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return TextSpan(text: text, style: normalStyle);

  final lc = text.toLowerCase();
  final children = <TextSpan>[];
  int start = 0;

  while (true) {
    final index = lc.indexOf(q, start);
    if (index < 0) break;

    if (index > start) {
      children.add(
        TextSpan(text: text.substring(start, index), style: normalStyle),
      );
    }
    children.add(
      TextSpan(
        text: text.substring(index, index + q.length),
        style: highlightStyle,
      ),
    );
    start = index + q.length;
  }

  if (start < text.length) {
    children.add(
      TextSpan(text: text.substring(start), style: normalStyle),
    );
  }

  return TextSpan(children: children);
}

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final String? query;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.query,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  Widget _buildImage() {
    final path = widget.product.imagePath;
    final url = widget.product.imageUrl;

    // ✅ IMAGE FROM ASSET
    if (path != null && path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
      );
    }

    // ✅ IMAGE FROM FILE (GALLERY)
    if (path != null && path.isNotEmpty && !kIsWeb) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
      );
    }

    // ✅ IMAGE FROM NETWORK
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    // ❌ FALLBACK
    return const Icon(Icons.image, size: 48, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.query ?? '';
    const nameStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Color(0xFF1E293B),
    );
    final highlightStyle = nameStyle.copyWith(
      backgroundColor: const Color.fromRGBO(255, 193, 7, 0.3),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildImage()),

                  // Harga
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatIdr(widget.product.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Favorite
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _isFavorite = !_isFavorite),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Stok sedikit
                  if (widget.product.stock < 5)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Terbatas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: buildHighlightedTextSpan(
                      widget.product.name,
                      q,
                      nameStyle,
                      highlightStyle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.product.category} • ${widget.product.size}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stok: ${widget.product.stock}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
