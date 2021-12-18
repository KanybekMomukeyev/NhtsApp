import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nhtsapp/Models/manufacturer_list_model.dart';
import 'package:nhtsapp/Models/manufacturer_make_model.dart';

class RequestApiClient {
  final http.Client httpClient;
  RequestApiClient({required this.httpClient});

  // https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json&page=2

  Future<ManufacturersInfo> allManufacturers({
    required int page,
  }) async {
    debugPrint("|| ---- allManufacturers started for page $page ----- ||");
    // await Future.delayed(const Duration(seconds: 8));
    try {
      var fullUrl = Uri.parse(
          "https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json&page=$page");

      final response =
          await httpClient.get(fullUrl).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
            "allManufacturers response.statusCode != ${response.statusCode} ${response.body}");
      }

      debugPrint("---- allManufacturers response success for page $page -----");

      final manufacturersInfo = manufacturersListFromJson(response.body);
      manufacturersInfo.nextPage = page + 1;

      return manufacturersInfo;
    } catch (error, stacktrace) {
      throw Exception('error getting allManufacturers $error, $stacktrace');
    }
  }

  // 1. Get all makes by Manufacturer ID
  // https://vpic.nhtsa.dot.gov/api/vehicles/GetMakeForManufacturer/988?format=json
  //
  // 2. Get all models by make name (Should we remove from make's name extra characters like ',' '.' ?)
  // https://vpic.nhtsa.dot.gov/api/vehicles/getmodelsformake/HONDA?format=json

  Future<List<MakeForManufacturer>> makesForManufacturer({
    required int manufacturerId,
  }) async {
    debugPrint("|| ---- makesForManufacturer started ----- ||");
    try {
      var fullUrl = Uri.parse(
          "https://vpic.nhtsa.dot.gov/api/vehicles/GetMakeForManufacturer/$manufacturerId?format=json");
      final response =
          await httpClient.get(fullUrl).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
            "allMakesForManufacturer response.statusCode != ${response.statusCode} ${response.body}");
      }
      debugPrint("---- makesForManufacturer response success -----");
      final makeForManufacturerList =
          makeForManufacturerListFromJson(response.body);
      return makeForManufacturerList.results;
    } catch (error, stacktrace) {
      throw Exception('error getting makesForManufacturer $error, $stacktrace');
    }
  }

  Future<List<ModelForMake>> modelsForMake({
    required String makeName,
  }) async {
    debugPrint("|| ---- modelsForMake started ----- ||");
    try {
      // nhtsa api gives error, if makeName contains "." or "," characters
      final modifiedMakeName = makeName.replaceAll(".", "").replaceAll(",", "");
      var fullUrl = Uri.parse(Uri.encodeFull(
          "https://vpic.nhtsa.dot.gov/api/vehicles/getmodelsformake/$modifiedMakeName?format=json"));

      final response =
          await httpClient.get(fullUrl).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
            "modelsForMake response.statusCode != ${response.statusCode} ${response.body}");
      }
      debugPrint("---- modelsForMake response success -----");
      final modelForMakeList = modelForMakeListFromJson(response.body);
      return modelForMakeList.results;
    } catch (error, stacktrace) {
      throw Exception('error getting modelsForMake $error, $stacktrace');
    }
  }
}
