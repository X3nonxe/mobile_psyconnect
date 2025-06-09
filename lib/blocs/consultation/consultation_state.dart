part of 'consultation_bloc.dart';

@immutable
abstract class ConsultationState {}

class ConsultationInitial extends ConsultationState {}

class ConsultationLoading extends ConsultationState {}

class ConsultationSaving extends ConsultationState {}

class ConsultationUpdateSuccess extends ConsultationState {}

class ConsultationUpdating extends ConsultationState {
  final String consultationId;

  ConsultationUpdating(this.consultationId);
}

class ConsultationLoaded extends ConsultationState {
  final List<Consultation> consultations;

  ConsultationLoaded(this.consultations);
}

class ClientConsultationsLoaded extends ConsultationState {
  final List<Consultation> consultations;

  ClientConsultationsLoaded(this.consultations);
}

class ConsultationSaved extends ConsultationState {
  final List<Consultation> consultations;

  ConsultationSaved(this.consultations);
}

class ConsultationError extends ConsultationState {
  final String message;

  ConsultationError(this.message);
}