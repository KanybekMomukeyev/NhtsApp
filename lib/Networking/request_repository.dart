import 'package:nhtsapp/Networking/request_api_client.dart';
import 'package:nhtsapp/Networking/sqlite_database_client.dart';

class RequestRepository {
  final RequestApiClient requestApiClient;
  final SqliteDatabaseClient sqliteDatabaseClient;

  RequestRepository({
    required this.requestApiClient,
    required this.sqliteDatabaseClient,
  });
}
