import '../../app/generalImports.dart';

abstract class CreateServiceCubitState {}

class CreateServiceInitial extends CreateServiceCubitState {}

class CreateServiceInProgress extends CreateServiceCubitState {}

class CreateServiceSuccess extends CreateServiceCubitState {
  final ServiceModel service;

  CreateServiceSuccess({required this.service});
}

class CreateServiceFailure extends CreateServiceCubitState {
  final String errorMessage;

  CreateServiceFailure(this.errorMessage);
}

class CreateServiceCubit extends Cubit<CreateServiceCubitState> {
  final ServiceRepository _serviceRepository = ServiceRepository();

  CreateServiceCubit() : super(CreateServiceInitial());

  Future<void> createService(CreateServiceModel dataModel) async {
    try {
      emit(CreateServiceInProgress());

      final ServiceModel serviceModel = await _serviceRepository.createService(
        dataModel,
      );

      emit(CreateServiceSuccess(service: serviceModel));
    } catch (e) {
      emit(CreateServiceFailure(e.toString()));
    }
  }
}
