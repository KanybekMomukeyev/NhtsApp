// Get Manufacturer Details
// https://vpic.nhtsa.dot.gov/api/vehicles/getmanufacturerdetails/955?format=json
// https://vpic.nhtsa.dot.gov/api/vehicles/getmanufacturerdetails/955?format=json

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nhtsapp/Networking/request_repository.dart';
import 'package:nhtsapp/Models/manufacturer_make_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ------------------------------------------------ EVENT ------------------------------------------------
abstract class ManufacturerDetailEvent extends Equatable {
  const ManufacturerDetailEvent();
  @override
  List<Object> get props => [];
}

class ManufacturerDetailInitialStarted extends ManufacturerDetailEvent {
  @override
  String toString() {
    return "ManufacturerDetailInitialStarted";
  }
}

class FetchManufacturerDetailPressed extends ManufacturerDetailEvent {
  final int manufacturerId;
  const FetchManufacturerDetailPressed({required this.manufacturerId});
  @override
  List<Object> get props => [manufacturerId];
  @override
  String toString() {
    return "FetchManufacturerDetailPressed $manufacturerId";
  }
}

// ------------------------------------------------ STATE ------------------------------------------------ //
abstract class ManufacturerDetailState extends Equatable {
  const ManufacturerDetailState();
  @override
  List<Object> get props => [];
}

class ManufacturerDetailInitial extends ManufacturerDetailState {
  @override
  String toString() {
    return "ManufacturerDetailInitial";
  }
}

class ManufacturerDetailInProgress extends ManufacturerDetailState {
  @override
  String toString() {
    return "ManufacturerDetailInProgress";
  }
}

class ManufacturerDetailSuccess extends ManufacturerDetailState {
  final List<ModelForMake> responseList;
  const ManufacturerDetailSuccess({required this.responseList});

  @override
  List<Object> get props => [responseList];

  @override
  String toString() {
    return "ManufacturerDetailSuccess responseList.lenght = ${responseList.length}";
  }
}

class ManufacturerDetailFailure extends ManufacturerDetailState {
  final String message;
  const ManufacturerDetailFailure({required this.message});
  @override
  List<Object> get props => [message];
}

class ManufacturerDetailBloc
    extends Bloc<ManufacturerDetailEvent, ManufacturerDetailState> {
  final RequestRepository requestRepository;

  ManufacturerDetailBloc({required this.requestRepository})
      : super(ManufacturerDetailInitial()) {
    on<ManufacturerDetailInitialStarted>(_onStarted);
    on<FetchManufacturerDetailPressed>(_onFetch);
  }
  Future<void> _onStarted(
    ManufacturerDetailInitialStarted event,
    Emitter<ManufacturerDetailState> emit,
  ) async {
    emit(ManufacturerDetailInitial());
  }

  Future<void> _onFetch(
    FetchManufacturerDetailPressed event,
    Emitter<ManufacturerDetailState> emit,
  ) async {
    try {
      emit(ManufacturerDetailInProgress());

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        // Get from storage
        final _savedModels =
            await requestRepository.sqliteDatabaseClient.modelsForManufacturer(
          manufacturrerId: event.manufacturerId,
        );
        if (_savedModels.isEmpty) {
          return emit(const ManufacturerDetailFailure(
              message: "No internet connection!"));
        }
        return emit(ManufacturerDetailSuccess(responseList: _savedModels));
      }

      final makes =
          await requestRepository.requestApiClient.makesForManufacturer(
        manufacturerId: event.manufacturerId,
      );

      final List<ModelForMake> allModels = [];
      for (var make in makes) {
        final List<ModelForMake> _models =
            await requestRepository.requestApiClient.modelsForMake(
          makeName: make.makeName,
        );
        allModels.addAll(_models);
      }

      // Save to storage
      await requestRepository.sqliteDatabaseClient.insertModels(
        mfrid: event.manufacturerId,
        models: allModels,
      );

      // Get from storage
      final _savedModels =
          await requestRepository.sqliteDatabaseClient.modelsForManufacturer(
        manufacturrerId: event.manufacturerId,
      );

      return emit(ManufacturerDetailSuccess(responseList: _savedModels));
    } catch (error, _) {
      emit(ManufacturerDetailFailure(message: "$error"));
    }
  }

  @override
  Future<void> close() async {
    super.close();
  }
}
