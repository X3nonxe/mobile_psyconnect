part of 'consultation_bloc.dart';

@immutable
abstract class ConsultationEvent {}
class LoadConsultations extends ConsultationEvent {}

class LoadClientConsultations extends ConsultationEvent {}

class UpdateConsultation extends ConsultationEvent {
  final String consultationId;
  final String updatedConsultation;

  UpdateConsultation(this.consultationId, this.updatedConsultation);
}