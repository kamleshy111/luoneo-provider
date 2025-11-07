class NotificationDataModel {
  String? id;
  String? title;
  String? message;
  String? type;
  String? typeId;
  String? image;
  String? orderId;
  String? isRead;
  String? dateSent;
  String? duration;

  NotificationDataModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.typeId,
    required this.image,
    required this.orderId,
    required this.isRead,
    required this.dateSent,
    required this.duration,
  });

  factory NotificationDataModel.fromMap(final Map<String, dynamic> map) =>
      NotificationDataModel(
        id: map["id"]?.toString() ?? '',
        title: map["title"]?.toString() ?? '',
        message: map["message"]?.toString() ?? '',
        type: map["type"]?.toString() ?? '',
        typeId: map["type_id"]?.toString() ?? '',
        image: map["image"]?.toString() ?? '',
        orderId: map["order_id"]?.toString() ?? '',
        isRead: map["is_readed"]?.toString() ?? '',
        dateSent: map["date_sent"]?.toString() ?? '',
        duration: map["duration"]?.toString() ?? '',
      );

  NotificationDataModel.fromJson(final Map<String, dynamic> map) {
    id = map['id'] ?? '0';
    title = map['title'].toString();
    message = map['message'].toString();
    type = map['type'].toString();
    typeId = map['type_id'].toString();
    image = map['image'].toString();
    orderId = map['order_id'].toString();
    isRead = map['is_readed'].toString();
    dateSent = map['date_sent'].toString();
    duration = map['duration'].toString();
  }
}
