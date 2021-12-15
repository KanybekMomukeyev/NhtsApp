// To parse this JSON data, do
//
//     final makeForManufacturerList = makeForManufacturerListFromJson(jsonString);

import 'dart:convert';

MakeForManufacturerList makeForManufacturerListFromJson(String str) =>
    MakeForManufacturerList.fromJson(json.decode(str));

String makeForManufacturerListToJson(MakeForManufacturerList data) =>
    json.encode(data.toJson());

class MakeForManufacturerList {
  MakeForManufacturerList({
    required this.count,
    required this.message,
    required this.results,
  });

  final int count;
  final String message;
  final List<MakeForManufacturer> results;

  factory MakeForManufacturerList.fromJson(Map<String, dynamic> json) =>
      MakeForManufacturerList(
        count: json["Count"],
        message: json["Message"],
        results: List<MakeForManufacturer>.from(
            json["Results"].map((x) => MakeForManufacturer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Count": count,
        "Message": message,
        "Results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class MakeForManufacturer {
  MakeForManufacturer({
    required this.makeId,
    required this.makeName,
    required this.mfrName,
  });

  final int makeId;
  final String makeName;
  final String mfrName;

  factory MakeForManufacturer.fromJson(Map<String, dynamic> json) =>
      MakeForManufacturer(
        makeId: json["Make_ID"],
        makeName: json["Make_Name"],
        mfrName: json["Mfr_Name"],
      );

  Map<String, dynamic> toJson() => {
        "Make_ID": makeId,
        "Make_Name": makeName,
        "Mfr_Name": mfrName,
      };
}

// To parse this JSON data, do
//
//     final modelForMakeList = modelForMakeListFromJson(jsonString);

ModelForMakeList modelForMakeListFromJson(String str) =>
    ModelForMakeList.fromJson(json.decode(str));

String modelForMakeListToJson(ModelForMakeList data) =>
    json.encode(data.toJson());

class ModelForMakeList {
  ModelForMakeList({
    required this.count,
    required this.message,
    required this.results,
  });

  final int count;
  final String message;
  final List<ModelForMake> results;

  factory ModelForMakeList.fromJson(Map<String, dynamic> json) =>
      ModelForMakeList(
        count: json["Count"],
        message: json["Message"],
        results: List<ModelForMake>.from(
            json["Results"].map((x) => ModelForMake.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Count": count,
        "Message": message,
        "Results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class ModelForMake {
  ModelForMake({
    required this.makeId,
    required this.makeName,
    required this.modelId,
    required this.modelName,
  });

  final int makeId;
  final String makeName;
  final int modelId;
  final String modelName;

  factory ModelForMake.fromJson(Map<String, dynamic> json) => ModelForMake(
        makeId: json["Make_ID"],
        makeName: json["Make_Name"],
        modelId: json["Model_ID"],
        modelName: json["Model_Name"],
      );

  Map<String, dynamic> toJson() => {
        "Make_ID": makeId,
        "Make_Name": makeName,
        "Model_ID": modelId,
        "Model_Name": modelName,
      };

  // 'INSERT OR REPLACE INTO modelformakes(modelid, mfrid, makeid, makename, modelname) VALUES(?, ?, ?, ?, ?)',
  List<dynamic> databaseInsertValues({required int manufacturrerId}) {
    return [modelId, manufacturrerId, makeId, makeName, modelName];
  }
}
