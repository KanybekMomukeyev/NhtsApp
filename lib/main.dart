import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:http/http.dart' as http;
import 'package:nhtsapp/Networking/sqlite_database_client.dart';
import 'package:nhtsapp/Networking/request_api_client.dart';
import 'package:nhtsapp/Networking/request_repository.dart';
import 'package:nhtsapp/Blocs/manufacturers_list_bloc.dart';
import 'package:nhtsapp/Blocs/manufacturer_detail_bloc.dart';
import 'package:nhtsapp/UI/manufacturers_list_page.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint("$transition");
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint("$error");
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  io.Directory _documentsDirectory = await getApplicationDocumentsDirectory();
  String _path = join(_documentsDirectory.path, "nhtsapp_local.db");
  final _localSqliteDb = await sqflite.openDatabase(
    _path,
    version: 1,
    onCreate: SqliteDatabaseClient.onCreateRunMigrations,
  );

  final _httpClient = http.Client();
  final _apiClient = RequestApiClient(httpClient: _httpClient);
  final _sqlClient = SqliteDatabaseClient(database: _localSqliteDb);

  final RequestRepository _reqRepository = RequestRepository(
    requestApiClient: _apiClient,
    sqliteDatabaseClient: _sqlClient,
  );

  BlocOverrides.runZoned(
    () => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<ManufacturersListBloc>(
            create: (context) {
              return ManufacturersListBloc(
                requestRepository: _reqRepository,
              )..add(ManufacturersListInitialStarted());
            },
          ),
          BlocProvider<ManufacturerDetailBloc>(
            create: (context) {
              return ManufacturerDetailBloc(
                requestRepository: _reqRepository,
              )..add(ManufacturerDetailInitialStarted());
            },
          ),
        ],
        child: MyApp(),
      ),
    ),
    blocObserver: SimpleBlocObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHTSAPP DEMO APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ManufacturersListPage(),
    );
  }
}
