import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_court_app/services/map_service.dart';
import 'package:food_court_app/services/models/model_product.dart';
import 'package:geolocator/geolocator.dart';

import 'model_review.dart';
import 'model_tenant.dart';

class MarkerAdmin {
  bool isClose;
  String adminId;
  String codeUnique;
  String imagePlace;
  String placeName;
  String phoneNumber;
  String emailAddress;
  String addressPlace;
  double latitude;
  double longitude;
  double distance;
  String imageIcon;
  List<Tenant> vendors;
  List<ReviewAdmin> reviews;

  MarkerAdmin({
    required this.isClose,
    required this.adminId,
    required this.codeUnique,
    required this.imagePlace,
    required this.placeName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.addressPlace,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.imageIcon,
    required this.reviews,
    required this.vendors,
  });
  double averageRating() {
    if (reviews.isEmpty) {
      return 0.0; // Return 0 if there are no reviews
    }

    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review.rating;
    }

    return totalRating / reviews.length;
  }

  static Future<double> calculateDistance(
    double adminLatitude,
    double adminLongitude,
  ) async {
    Position position = await MapService().determinePosition();

    double userLatitude = position.latitude;
    double userLongitude = position.longitude;

    double calculateDistance = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      adminLatitude,
      adminLongitude,
    );

    return calculateDistance / 1000;
  }

  static Future<List<ReviewAdmin>> fetchReviews(DocumentReference docRef) async {
    List<ReviewAdmin> reviews = [];
    QuerySnapshot<Map<String, dynamic>> reviewSnapshot = await docRef.collection('reviews').get();

    for (var reviewDoc in reviewSnapshot.docs) {
      reviews.add(
        ReviewAdmin(
          reviewId: reviewDoc['review_id'],
          adminId: reviewDoc['review_id'],
          clientId: reviewDoc['client_id'],
          imageUser: reviewDoc['image'],
          username: reviewDoc['username'],
          rating: reviewDoc['rating'],
          comment: reviewDoc['comment'],
          imageReview: reviewDoc['image_review'],
        ),
      );
    }
    return reviews;
  }

  static Future<List<Tenant>> fetchVendors(DocumentReference docRef) async {
    List<Tenant> vendors = [];
    QuerySnapshot<Map<String, dynamic>> vendorSnapshot = await docRef.collection('vendors').get();

    for (var vendorDoc in vendorSnapshot.docs) {
      List<MenuProduct> menuProduct = [];
      List<OrderProduct> orderProduct = [];

      QuerySnapshot<Map<String, dynamic>> menuProductSnapshot =
          await vendorDoc.reference.collection('products').get();

      for (var menuProductDoc in menuProductSnapshot.docs) {
        menuProduct.add(
          MenuProduct(
            productId: menuProductDoc['product_id'],
            imageProduct: menuProductDoc['image_product'],
            nameProduct: menuProductDoc['name_product'],
            priceProduct: menuProductDoc['price_product'],
            categoryProduct: menuProductDoc['category_product'],
            stockProduct: menuProductDoc['stock_product'],
            descProduct: menuProductDoc['description_product'],
            //timesDate: menuProductDoc['times_date'],
          ),
        );
      }

      QuerySnapshot<Map<String, dynamic>> orderProductSnapshot =
          await vendorDoc.reference.collection('orders').get();

      for (var orderProductDoc in orderProductSnapshot.docs) {
        orderProduct.add(
          OrderProduct(
            vendorId: orderProductDoc['vendor_id'],
            orderId: orderProductDoc['order_id'],
            orderTime: orderProductDoc['order_time'],
            payMethod: orderProductDoc['pay_method'],
            subTotal: orderProductDoc['sub_total'],
            priceTotal: orderProductDoc['price_total'],
            product: orderProductDoc['product'],
          ),
        );
      }

      vendors.add(
        Tenant(
          vendorId: vendorDoc['vendor_id'],
          adminId: vendorDoc['admin_id'],
          imagePlace: vendorDoc['image_place'],
          vendorName: vendorDoc['vendor_name'],
          emailVendor: vendorDoc['email_address'],
          phoneNumberVendor: vendorDoc['phone_number'],
          isOpen: vendorDoc['is_close'],
          product: menuProduct,
          order: orderProduct,
        ),
      );
    }
    return vendors;
  }

  static Future<MarkerAdmin> fromDocument(DocumentSnapshot snapshot) async {
    final data = snapshot.data() as Map<String, dynamic>;
    List<ReviewAdmin> reviews = await fetchReviews(snapshot.reference);
    List<Tenant> vendors = await fetchVendors(snapshot.reference);
    double distance = await calculateDistance(data['latitude'], data['longitude']);
    return MarkerAdmin(
      adminId: snapshot.id,
      isClose: data['is_close'],
      codeUnique: data['code_unique'],
      imagePlace: data['image_place'],
      placeName: data['place_name'],
      phoneNumber: data['phone_number'],
      emailAddress: data['email_address'],
      addressPlace: data['address_place'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      distance: distance,
      imageIcon: data['image_icon'],
      reviews: reviews,
      vendors: vendors,
    );
  }
}




class IndividualBar {
  final int x;
  final double y;

  IndividualBar({
    required this.x,
    required this.y,
  });
}

class BarData {
  final double sunTotal;
  final double monTotal;
  final double tueTotal;
  final double wedTotal;
  final double thuTotal;
  final double friTotal;
  final double satTotal;

  BarData({
    required this.sunTotal,
    required this.monTotal,
    required this.tueTotal,
    required this.wedTotal,
    required this.thuTotal,
    required this.friTotal,
    required this.satTotal,
  });

  List<IndividualBar> barData = [];

  void initalizeBarData() {
    barData = [
      IndividualBar(x: 0, y: sunTotal),
      IndividualBar(x: 1, y: monTotal),
      IndividualBar(x: 2, y: tueTotal),
      IndividualBar(x: 3, y: wedTotal),
      IndividualBar(x: 4, y: thuTotal),
      IndividualBar(x: 5, y: friTotal),
      IndividualBar(x: 6, y: satTotal),
    ];
  }
}

