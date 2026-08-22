class ActivityModel {
  final int id;
  final int user;
  final String userName;
  final String activityName;
  final String datetime;
  final String? imageIcon;
  final String? status;
  final String createdAt;
  final String updatedAt;

  ActivityModel({
    required this.id,
    required this.user,
    required this.userName,
    required this.activityName,
    required this.datetime,
    this.imageIcon,
    this.status,  // ✅
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      userName: json['user_name'] ?? '',
      activityName: json['activity_name'] ?? '',
      datetime: json['datetime'] ?? '',
      imageIcon: json['image_icon'],
      status: json['status'] ?? 'in_progress',  // ✅
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'user_name': userName,
      'activity_name': activityName,
      'datetime': datetime,
      'image_icon': imageIcon,
      'status': status,  // ✅
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get formattedTime {
    try {
      final dt = DateTime.parse(datetime).toLocal();
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return datetime;
    }
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(datetime).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}