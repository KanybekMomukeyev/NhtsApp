import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:integration_test/integration_test.dart';
import 'package:nhtsapp/Models/manufacturer_list_model.dart';
import 'package:nhtsapp/Models/manufacturer_make_model.dart';
import 'package:nhtsapp/Networking/sqlite_database_client.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String pathToDb = path.join(documentsDirectory.path, "nhtsapp_test_local.db");
  final localSqliteDb = await sqflite.openDatabase(
    pathToDb,
    version: 1,
    onCreate: SqliteDatabaseClient.onCreateRunMigrations,
  );

  final sqlClient = SqliteDatabaseClient(database: localSqliteDb);
  final forSaveManufes = [
    ManufacturerListModel(
        country: "Test_Country_1", mfrId: 10098451, mfrName: "Test_Name_1"),
  ];
  await sqlClient.insertManufacturers(
      manufacturers: forSaveManufes, page: 450923);

  final forSaveModels = [
    ModelForMake(
      makeId: 1234321,
      makeName: "Make_Name_1",
      modelId: 54321,
      modelName: "Model_Name_1",
    ),
  ];

  await sqlClient.insertModels(models: forSaveModels, mfrid: 10098451);

  group('Database', () {
    testWidgets("failing test example", (WidgetTester tester) async {
      expect(2 + 2, equals(4));
    });

    test('saved values should be 1', () async {
      final _savedManufes = await sqlClient.manufacturersForPage(page: 450923);
      expect(_savedManufes.length, 1);
    });

    test('manufacturer should be equal', () async {
      final _savedManufes = await sqlClient.manufacturersForPage(page: 450923);

      expect(_savedManufes.first.mfrId, 10098451);
      expect(_savedManufes.first.country, "Test_Country_1");
      expect(_savedManufes.first.mfrName, "Test_Name_1");
    });

    test('model should be equal', () async {
      final _savedModels =
          await sqlClient.modelsForManufacturer(manufacturrerId: 10098451);

      expect(_savedModels.length, 1);
      expect(_savedModels.first.makeId, 1234321);
      expect(_savedModels.first.makeName, "Make_Name_1");
      expect(_savedModels.first.modelId, 54321);
      expect(_savedModels.first.modelName, "Model_Name_1");
    });
  });
}
