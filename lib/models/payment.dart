import 'package:MoonGoAdmin/models/product.dart';
import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int id;
  final int userId;
  final String payWith;
  final int status;
  final String transactionImage;
  final String updatedBy;
  final String createdAt;
  final String updatedAt;
  final Product item;

  Payment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        payWith = json['pay_with'],
        status = (json['status'] is String)
            ? int.tryParse(json['status'])
            : json['status'],
        transactionImage = json['transaction_image'],
        updatedBy = json['updated_by'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        item = Product.fromJson(json['item']);

  @override
  List<Object> get props => [id];
}
