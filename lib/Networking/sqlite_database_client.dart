import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:nhtsapp/Models/manufacturer_list_model.dart';
import 'package:nhtsapp/Models/manufacturer_make_model.dart';

class SqliteDatabaseClient {
  SqliteDatabaseClient({required this.database});
  final sqflite.Database database;

  static void onCreateRunMigrations(
      sqflite.Database database, int version) async {
    await database.execute(
        "CREATE TABLE IF NOT EXISTS manufacturers(mfrid INTEGER PRIMARY KEY, page INTEGER, mfrname TEXT, country TEXT )");
    await database.execute(
        "CREATE INDEX IF NOT EXISTS page_manufacturers_idx ON manufacturers (page);");
    await database.execute(
        "CREATE TABLE IF NOT EXISTS modelformakes(modelid INTEGER PRIMARY KEY, mfrid INTEGER, makeid INTEGER, makename TEXT, modelname TEXT )");
    await database.execute(
        "CREATE INDEX IF NOT EXISTS mfrid_modelformakes_idx ON modelformakes (mfrid);");
  }

  Future<List<ManufacturerListModel>> manufacturersForPage(
      {required int page}) async {
    List<Map> list =
        await database.rawQuery('SELECT * FROM manufacturers WHERE page=$page');
    List<ManufacturerListModel> manufacturers = [];
    for (int i = 0; i < list.length; i++) {
      manufacturers.add(ManufacturerListModel(
        mfrId: list[i]["mfrid"],
        mfrName: list[i]["mfrname"],
        country: list[i]["country"],
      ));
    }
    debugPrint("manufacturers.length = ${manufacturers.length}");
    return manufacturers;
  }

  Future<void> insertManufacturers(
      {required int page,
      required List<ManufacturerListModel> manufacturers}) async {
    try {
      final saveValue = await database.transaction((txn) async {
        for (var manufacturer in manufacturers) {
          int id1 = await txn.rawInsert(
              'INSERT OR REPLACE INTO manufacturers(mfrid, page, mfrname, country) VALUES(?, ?, ?, ?)',
              manufacturer.databaseInsertValues(page: page));
        }
      });
      debugPrint('saveValue: $saveValue');
    } catch (error, stacktrace) {
      throw Exception('error saving insertManufacturers $error, $stacktrace');
    }
  }

  Future<void> insertModels(
      {required int mfrid, required List<ModelForMake> models}) async {
    try {
      final saveValue = await database.transaction((txn) async {
        for (var model in models) {
          int id1 = await txn.rawInsert(
              'INSERT OR REPLACE INTO modelformakes(modelid, mfrid, makeid, makename, modelname) VALUES(?, ?, ?, ?, ?)',
              model.databaseInsertValues(manufacturrerId: mfrid));
        }
      });
      debugPrint('saveValue: $saveValue');
    } catch (error, stacktrace) {
      throw Exception('error saving insertModels $error, $stacktrace');
    }
  }

  Future<List<ModelForMake>> modelsForManufacturer(
      {required int manufacturrerId}) async {
    List<Map> list = await database
        .rawQuery('SELECT * FROM modelformakes WHERE mfrid=$manufacturrerId');
    List<ModelForMake> models = [];
    for (int i = 0; i < list.length; i++) {
      models.add(ModelForMake(
        modelId: list[i]["modelid"],
        makeId: list[i]["makeid"],
        makeName: list[i]["makename"],
        modelName: list[i]["modelname"],
      ));
    }
    debugPrint("models.length = ${models.length}");
    return models;
  }
}
