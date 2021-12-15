// To parse this JSON data, do
//
//     final manufacturersList = manufacturersListFromJson(jsonString);

import 'dart:convert';

ManufacturersInfo manufacturersListFromJson(String str) =>
    ManufacturersInfo.fromJson(json.decode(str));

String manufacturersListToJson(ManufacturersInfo data) =>
    json.encode(data.toJson());

class ManufacturersInfo {
  ManufacturersInfo({
    required this.count,
    required this.message,
    required this.results,
    this.nextPage = 1,
  });

  final int count;
  final String message;
  final List<ManufacturerListModel> results;
  int nextPage;

  factory ManufacturersInfo.fromJson(Map<String, dynamic> json) {
    if (json["Results"] != null) {
      return ManufacturersInfo(
        count: json["Count"],
        message: json["Message"],
        results: List<ManufacturerListModel>.from(
            json["Results"].map((x) => ManufacturerListModel.fromJson(x))),
        nextPage: 1,
      );
    } else {
      return ManufacturersInfo(
        count: json["Count"],
        message: json["Message"],
        results: [],
        nextPage: 1,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "NextPage": nextPage,
        "Count": count,
        "Message": message,
        "Results":
            List<ManufacturerListModel>.from(results.map((x) => x.toJson())),
      };
}

class ManufacturerListModel {
  ManufacturerListModel({
    required this.country,
    required this.mfrId,
    required this.mfrName,
  });

  final String country;
  final int mfrId;
  final String mfrName;

  factory ManufacturerListModel.fromJson(Map<String, dynamic> json) =>
      ManufacturerListModel(
        country: json["Country"],
        mfrId: json["Mfr_ID"],
        mfrName: json["Mfr_Name"],
      );

  Map<String, dynamic> toJson() => {
        "Country": country,
        "Mfr_ID": mfrId,
        "Mfr_Name": mfrName,
      };

  // 'INSERT OR REPLACE INTO manufacturers(mfrid, page, mfrname, country) VALUES(?, ?, ?, ?)',[12345678, 'company', 3.1416]);
  List<dynamic> databaseInsertValues({required int page}) {
    return [mfrId, page, mfrName, country];
  }
}
