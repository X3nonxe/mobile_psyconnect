import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psyconnect/models/consultation_model.dart';
import 'package:psyconnect/repositories/consultation_repository.dart';

part 'consultation_event.dart';
part 'consultation_state.dart';

class ConsultationBloc extends Bloc<ConsultationEvent, ConsultationState> {
  final ConsultationRepository repository;
  final String psychologistId;

  ConsultationBloc({
    required this.repository,
    required this.psychologistId,
  }) : super(ConsultationInitial()) {
    on<LoadConsultations>(_onLoadConsultations);
    on<LoadClientConsultations>(_onLoadClientConsultations);
    on<UpdateConsultation>(_onUpdateConsultation);
  }

  Future<void> _onLoadConsultations(
      LoadConsultations event, Emitter<ConsultationState> emit) async {
    emit(ConsultationLoading());
    try {
      final consultations = await repository.getConsultations(psychologistId);
      emit(ConsultationLoaded(consultations));
    } catch (e) {
      emit(ConsultationError(e.toString()));
    }
  }

  Future<void> _onLoadClientConsultations(
      LoadClientConsultations event, Emitter<ConsultationState> emit) async {
    emit(ConsultationLoading());
    try {
      final consultations = await repository.getClientConsultations();
      emit(ClientConsultationsLoaded(consultations));
    } catch (e) {
      emit(ConsultationError(e.toString()));
    }
  }

  Future<void> _onUpdateConsultation(
      UpdateConsultation event, Emitter<ConsultationState> emit) async {
    try {
      emit(ConsultationUpdating(event.consultationId));
      await repository.updateConsultationStatus(
          event.consultationId, event.updatedConsultation);
      emit(ConsultationUpdateSuccess());

      // Reload consultations based on the current user role
      if (psychologistId.isNotEmpty) {
        add(LoadConsultations());
      } else {
        add(LoadClientConsultations());
      }
    } catch (e) {
      emit(ConsultationError(e.toString()));
    }
  }
}
