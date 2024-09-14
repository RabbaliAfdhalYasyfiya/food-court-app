import 'package:flutter/cupertino.dart';

class ProductItems extends StatefulWidget {
  const ProductItems({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<ProductItems> createState() => _ProductItemsState();
}

class _ProductItemsState extends State<ProductItems> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
