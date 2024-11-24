class PartnerModel {
  List<Records>? records;

  PartnerModel({this.records});

  PartnerModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic> && json["records"] is List) {
      records = (json["records"] as List).map((v) => Records.fromJson(v as Map<String, dynamic>)).toList();
    } else if (json is List) {
      // إذا كان الجيسون عبارة عن قائمة مباشرة
      records = json.map((v) => Records.fromJson(v as Map<String, dynamic>)).toList();
    } else {
      records = [];
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (records != null) {
      map["records"] = records?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Records {
  int? id;
  String? name;
  String? email;
  String? image512;

  Records({this.id, this.name, this.email, this.image512});

  Records.fromJson(Map<String, dynamic> json) {
    id = json["id"]; // تعيين قيمة افتراضية عند عدم وجود المفتاح
    name = json["name"] ?? ""; // تعيين قيمة افتراضية عند عدم وجود المفتاح
    email = (json["email"] is! bool) ? json["email"] ?? "" : ""; // معالجة القيم غير المتوقعة
    image512 = (json["image_128"] is! bool) ? json["image_128"] ?? "" : ""; // معالجة القيم غير المتوقعة
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["email"] = email;
    map["image_128"] = image512;
    return map;
  }
}
