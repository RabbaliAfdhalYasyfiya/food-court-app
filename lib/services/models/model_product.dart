import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_court_app/services/models/model.dart';

class MenuProduct {
  String productId;
  String imageProduct;
  String nameProduct;
  String priceProduct;
  String categoryProduct;
  int stockProduct;
  String descProduct;
  //Timestamp timesDate;

  MenuProduct({
    required this.productId,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.categoryProduct,
    required this.stockProduct,
    required this.descProduct,
    //required this.timesDate,
  });

  factory MenuProduct.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuProduct(
      productId: doc.id,
      imageProduct: data['image_product'],
      nameProduct: data['name_product'],
      priceProduct: data['price_product'],
      categoryProduct: data['category_product'],
      stockProduct: data['stock_product'],
      descProduct: data['description_product'],
      //timesDate: data['times'],
    );
  }
}

class OrderProduct {
  String vendorId;
  String orderId;
  Timestamp orderTime;
  String payMethod;
  double subTotal;
  double priceTotal;
  List<Product> product;

  OrderProduct({
    required this.vendorId,
    required this.orderId,
    required this.orderTime,
    required this.payMethod,
    required this.subTotal,
    required this.priceTotal,
    required this.product,
  });

  factory OrderProduct.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderProduct(
      vendorId: data['vendor_id'],
      orderId: data['order_id'],
      orderTime: data['order_time'],
      payMethod: data['pay_method'],
      subTotal: data['sub_total'],
      priceTotal: data['price_total'],
      product: (data['product'] as List<dynamic>)
          .map(
            (e) => Product.fromDocument(
              e as Map<String, dynamic>,
              data['order_time'],
              data['pay_method'],
            ),
          )
          .toList(),
    );
  }
}

class Product {
  String productId;
  String imageProduct;
  String nameProduct;
  double priceProduct;
  int quantityProduct;
  double valueTotal;
  Timestamp orderTime;
  String payMethod;

  Product({
    required this.productId,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.quantityProduct,
    required this.valueTotal,
    required this.orderTime,
    required this.payMethod,
  });

  factory Product.fromDocument(
    Map<String, dynamic> doc,
    Timestamp orderTime,
    String payMethod,
  ) {
    return Product(
      productId: doc['product_id'],
      imageProduct: doc['image_product'],
      nameProduct: doc['name_product'],
      priceProduct: doc['price_product'],
      quantityProduct: doc['quantity_product'],
      valueTotal: doc['value_total'],
      orderTime: orderTime,
      payMethod: payMethod,
    );
  }
}

class FavProduct {
  String productId;
  String imageProduct;
  String nameProduct;
  String priceProduct;
  String categoryProduct;
  String descProduct;

  FavProduct({
    required this.productId,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.categoryProduct,
    required this.descProduct,
  });

  factory FavProduct.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavProduct(
      productId: data['product_id'],
      imageProduct: data['image_product'],
      nameProduct: data['name_product'],
      priceProduct: data['price_product'],
      categoryProduct: data['category_product'],
      descProduct: data['description_product'],
    );
  }
}

Future<List<MarkerAdmin>> fetchMarkerAdminDataFromFirestore() async {
  List<MarkerAdmin> markerAdminList = [];

  QuerySnapshot<Map<String, dynamic>> adminsSnapshot =
      await FirebaseFirestore.instance.collection('admins').get();

  for (var doc in adminsSnapshot.docs) {
    MarkerAdmin markerAdmin = await MarkerAdmin.fromDocument(doc);
    markerAdminList.add(markerAdmin);
  }

  return markerAdminList;
}
