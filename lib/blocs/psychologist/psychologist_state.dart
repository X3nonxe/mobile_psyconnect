part of 'psychologist_bloc.dart';

@immutable
abstract class PsychologistState {}

class PsychologistInitial extends PsychologistState {}

class PsychologistLoading extends PsychologistState {}

class PsychologistSaving extends PsychologistState {}

class PsychologistLoaded extends PsychologistState {
  final List<PsychologistModel> psychologists;

  PsychologistLoaded(this.psychologists);
}

class PsychologistError extends PsychologistState {
  final String message;

  PsychologistError(this.message);
}
