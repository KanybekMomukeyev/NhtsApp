# nhtsapp

A Flutter project for listing all manufacturers and their models.
Flutter (Channel Master, 2.9.0-1.0.pre.68, on macOS 11.1 20C69 darwin-x64, nullsafety)


To run application:
```
flutter run 
```

## Getting Started

1. For State Managment used Bloc
2. For Local Data storage used Sqlite, with platform channels
3. Timeout set for 30 seconds, if TimeOut exception is throwed, app throws error, 
   it will not take data from local storage.

Every part of logic like
  1. Working with Network
  2. Working with Database  
 
 divided for testing, best practises of Solid principles. 

To run unit tests (business logic: database, request_api_client, bloc logic), run
```
flutter run test/ -d emulator-5554
```
Or, for only database
```
flutter run test/database_test -d emulator-5554
```
Or, for only list bloc
```
flutter run test/man_list_bloc_test -d emulator-5554
```

# UPDATE
According to latest documentaion Flutter, all tests related to Database, File IO, Network, Bloc 
or specific logic of App Flow, should be written to Integration tests.

so to run integrstion test, just run

```
flutter test integration_test/database_integration_test.dart -d <DEVICE_ID>
```

here DEVICE_ID is, the retturn of command ``` flutter devices ```



- Web version of this project you can view here:
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
