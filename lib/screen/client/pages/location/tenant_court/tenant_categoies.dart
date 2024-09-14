import 'package:flutter/material.dart';

class TenantCategories extends StatefulWidget {
  const TenantCategories({
    super.key,
    required this.onChange,
    required this.selectedIndex,
  });

  final ValueChanged<int> onChange;
  final int selectedIndex;

  @override
  State<TenantCategories> createState() => _TenantCategoriesState();
}

class _TenantCategoriesState extends State<TenantCategories> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [],
      ),
    );
  }
}
