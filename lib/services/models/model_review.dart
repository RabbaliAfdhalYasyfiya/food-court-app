import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewAdmin {
  String reviewId;
  String adminId;
  String clientId;
  String imageUser;
  String username;
  double rating;
  String comment;
  String imageReview;

  ReviewAdmin({
    required this.reviewId,
    required this.adminId,
    required this.clientId,
    required this.imageUser,
    required this.username,
    required this.rating,
    required this.comment,
    required this.imageReview,
  });

  factory ReviewAdmin.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return ReviewAdmin(
      reviewId: snapshot.id,
      clientId: data['client_id'],
      adminId: data['admin_id'],
      imageUser: data['image'],
      username: data['username'],
      rating: data['rating'],
      comment: data['comment'],
      imageReview: data['image_review'],
    );
  }
}