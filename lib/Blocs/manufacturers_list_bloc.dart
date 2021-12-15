// Get All Manufacturers
// https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json&page=1
// https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json&page=2

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nhtsapp/Networking/request_repository.dart';
import 'package:nhtsapp/Models/manufacturer_list_model.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

const _throttleDuration = Duration(seconds: 4);

// ------------------------------------------------ EVENT ------------------------------------------------
abstract class ManufacturersListEvent extends Equatable {
  const ManufacturersListEvent();
  @override
  List<Object> get props => [];
}

class ManufacturersListInitialStarted extends ManufacturersListEvent {
  @override
  String toString() {
    return "ManufacturersListInitialStarted";
  }
}

class FetchManufacturersListPressed extends ManufacturersListEvent {
  final int page;
  const FetchManufacturersListPressed({required this.page});
  @override
  List<Object> get props => [page];

  @override
  String toString() {
    return "FetchManufacturersListPressed $page";
  }
}

// ------------------------------------------------ STATE ------------------------------------------------ //
abstract class ManufacturersListState extends Equatable {
  const ManufacturersListState();
  @override
  List<Object> get props => [];
}

class ManufacturersListInitial extends ManufacturersListState {
  @override
  String toString() {
    return "ManufacturersListInitial";
  }
}

class ManufacturersListSuccess extends ManufacturersListState {
  final List<ManufacturerListModel> responseList;
  final int nextPage;
  const ManufacturersListSuccess({
    required this.responseList,
    required this.nextPage,
  });
  @override
  List<Object> get props => [responseList, nextPage];

  @override
  String toString() {
    return "ManufacturersListSuccess ${responseList.length}";
  }
}

class ManufacturersListFailure extends ManufacturersListState {
  final String message;
  const ManufacturersListFailure({required this.message});
  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return "ManufacturersListFailure";
  }
}

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ManufacturersListBloc
    extends Bloc<ManufacturersListEvent, ManufacturersListState> {
  final RequestRepository requestRepository;

  ManufacturersListBloc({required this.requestRepository})
      : super(ManufacturersListInitial()) {
    on<ManufacturersListInitialStarted>(
      _onStarted,
    );
    on<FetchManufacturersListPressed>(
      _onFetch,
      transformer: throttleDroppable(_throttleDuration),
    );
  }

  Future<void> _onStarted(
    ManufacturersListInitialStarted event,
    Emitter<ManufacturersListState> emit,
  ) async {
    emit(ManufacturersListInitial());
  }

  Future<void> _onFetch(
    FetchManufacturersListPressed event,
    Emitter<ManufacturersListState> emit,
  ) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        // Get from storage
        final _savedManufacturers =
            await requestRepository.sqliteDatabaseClient.manufacturersForPage(
          page: event.page,
        );
        if (_savedManufacturers.isEmpty) {
          return emit(const ManufacturersListFailure(
              message: "No internet connection!"));
        }
        return emit(ManufacturersListSuccess(
          responseList: _savedManufacturers,
          nextPage: (event.page + 1),
        ));
      }

      final ManufacturersInfo _manufacturersInfo =
          await requestRepository.requestApiClient.allManufacturers(
        page: event.page,
      );
      if (_manufacturersInfo.results.isEmpty) {
        return emit(
            const ManufacturersListFailure(message: "Response is empty!"));
      }

      // Save to storage
      await requestRepository.sqliteDatabaseClient.insertManufacturers(
        page: event.page,
        manufacturers: _manufacturersInfo.results,
      );

      // Get from storage
      final _savedManufacturers =
          await requestRepository.sqliteDatabaseClient.manufacturersForPage(
        page: event.page,
      );

      return emit(ManufacturersListSuccess(
        responseList: _savedManufacturers,
        nextPage: _manufacturersInfo.nextPage,
      ));
    } catch (error, _) {
      emit(ManufacturersListFailure(message: "$error"));
    }
  }

  @override
  Future<void> close() async {
    super.close();
  }
}
