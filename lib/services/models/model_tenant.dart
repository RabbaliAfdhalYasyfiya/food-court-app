import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_court_app/services/models/model_product.dart';

class Tenant {
  String vendorId;
  String adminId;
  String imagePlace;
  String vendorName;
  String emailVendor;
  String phoneNumberVendor;
  bool isOpen;
  List<MenuProduct> product;
  List<OrderProduct> order;

  Tenant({
    required this.vendorId,
    required this.adminId,
    required this.imagePlace,
    required this.vendorName,
    required this.emailVendor,
    required this.phoneNumberVendor,
    required this.isOpen,
    required this.product,
    required this.order,
  });

  factory Tenant.fromDocument(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Tenant(
      vendorId: snapshot.id,
      adminId: data['admin_id'],
      imagePlace: data['image_place'],
      vendorName: data['vendor_name'],
      emailVendor: data['email_address'],
      phoneNumberVendor: data['phone_number'],
      isOpen: data['is_close'],
      product: [],
      order: [],
    );
  }

  Future<List<MenuProduct>> fetchProduct() async {
    List<MenuProduct> menuProduct = [];
    final productSnapshot = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .collection('products')
        .get();

    product = productSnapshot.docs.map((doc) => MenuProduct.fromDocument(doc)).toList();

    return menuProduct;
  }

  Future<List<OrderProduct>> fetchOrder() async {
    List<OrderProduct> orderProduct = [];

    final orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('vendor_id', isEqualTo: vendorId)
        .get();

    order = orderSnapshot.docs.map((doc) => OrderProduct.fromDocument(doc)).toList();

    return orderProduct;
  }
}