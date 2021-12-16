import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:http/http.dart' as http;
import 'package:nhtsapp/Networking/request_api_client.dart';
import 'package:nhtsapp/Networking/request_repository.dart';
import 'package:nhtsapp/Networking/sqlite_database_client.dart';
import 'package:nhtsapp/Blocs/manufacturers_list_bloc.dart';

class MockManufacturersListBloc
    extends MockBloc<ManufacturersListEvent, ManufacturersListState>
    implements ManufacturersListBloc {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  io.Directory _documentsDirectory = await getApplicationDocumentsDirectory();
  String _path = path.join(_documentsDirectory.path, "nhtsapp_local.db");
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

  group('ManufacturersListBloc', () {
    blocTest<ManufacturersListBloc, ManufacturersListState>(
      'supports matchers (contains)',
      build: () => ManufacturersListBloc(requestRepository: _reqRepository),
      act: (bloc) => bloc.add(FetchManufacturersListPressed(page: 1)),
      expect: () =>
          contains(ManufacturersListSuccess(responseList: [], nextPage: 2)),
    );

    blocTest<ManufacturersListBloc, ManufacturersListState>(
      'supports matchers',
      build: () => ManufacturersListBloc(requestRepository: _reqRepository),
      act: (bloc) => bloc
        ..add(FetchManufacturersListPressed(page: 1))
        ..add(FetchManufacturersListPressed(page: 2)),
      expect: () => containsAllInOrder(<int>[1, 2]),
    );

    test('TESTING BLOCK WITH MOCK', () async {
      // Create a mock instance
      final mockListBloc = MockManufacturersListBloc();

      // Assert that the initial state is correct.
      expect(mockListBloc.state, equals(ManufacturersListInitial()));

      // Stub the state stream
      whenListen(
        mockListBloc,
        Stream.fromIterable([
          ManufacturersListInitial(),
          ManufacturersListSuccess(responseList: [], nextPage: 1)
        ]),
        initialState: ManufacturersListInitial(),
      );

      // Assert that the stubbed stream is emitted.
      await expectLater(
          mockListBloc.stream,
          emitsInOrder(<ManufacturersListState>[
            ManufacturersListInitial(),
            ManufacturersListSuccess(responseList: [], nextPage: 1),
          ]));

      // Assert that the current state is in sync with the stubbed stream.
      expect(mockListBloc.state,
          equals(ManufacturersListSuccess(responseList: [], nextPage: 1)));
    });
  });
}
