import 'package:flutter/material.dart';

class TenantCategories extends SliverPersistentHeaderDelegate {
  TenantCategories({
    required this.onChanged,
    required this.selectedIndex,
    required this.categories,
  });

  final ValueChanged<int> onChanged;
  final int selectedIndex;
  final List<String> categories;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 52,
      color: Colors.white,
      child: ProductCategories(
        onChanged: onChanged,
        selectedIndex: selectedIndex,
        categories: categories,
      ),
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class ProductCategories extends StatefulWidget {
  const ProductCategories({
    super.key,
    required this.onChanged,
    required this.selectedIndex,
    required this.categories,
  });

  final ValueChanged<int> onChanged;
  final int selectedIndex;
  final List<String> categories;

  @override
  State<ProductCategories> createState() => _ProductCategoriesState();
}

class _ProductCategoriesState extends State<ProductCategories> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          widget.categories.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextButton(
                onPressed: () {
                  widget.onChanged(index);
                },
                style: const ButtonStyle(
                  shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 5)),
                ),
                child: Text(
                  widget.categories[index],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: widget.selectedIndex == index ? FontWeight.w600 : FontWeight.w400,
                    color: widget.selectedIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.black38,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
