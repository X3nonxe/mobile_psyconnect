import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psyconnect/models/psychologist.dart';
import 'package:psyconnect/repositories/psychologist_repository.dart';

part 'psychologist_event.dart';
part 'psychologist_state.dart';

class PsychologistBloc extends Bloc<PsychologistEvent, PsychologistState> {
  final PsychologistRepository repository;

  PsychologistBloc({
    required this.repository,
  }) : super(PsychologistInitial()) {
    on<LoadPsychologist>(_onLoadPsychologist);
  }

  Future<void> _onLoadPsychologist(
      LoadPsychologist event, Emitter<PsychologistState> emit) async {
    emit(PsychologistLoading());
    try {
      final psychologist = await repository.getAllPsychologist();
      emit(PsychologistLoaded(psychologist));
    } catch (e) {
      emit(PsychologistError(e.toString()));
    }
  }
}