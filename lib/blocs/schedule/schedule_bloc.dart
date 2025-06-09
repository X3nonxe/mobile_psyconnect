import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psyconnect/models/schedule_model.dart';
import 'package:psyconnect/repositories/schedule_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository repository;
  final String psychologistId;

  ScheduleBloc({required this.repository, required this.psychologistId})
      : super(ScheduleInitial()) {
    on<LoadSchedules>(_onLoadSchedules);
    on<SaveSchedules>(_onSaveSchedules);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<DeleteSchedule>(_onDeleteSchedule);
  }

  Future<void> _onLoadSchedules(
      LoadSchedules event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final schedules = await repository.getSchedules(psychologistId);
      emit(ScheduleLoaded(schedules));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onSaveSchedules(
      SaveSchedules event, Emitter<ScheduleState> emit) async {
    emit(ScheduleSaving());
    try {
      await repository.saveSchedules(event.schedules);
      final schedules = await repository.getSchedules(psychologistId);
      emit(ScheduleSaved(schedules));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(ScheduleLoading());
      await repository.updateSchedule(event.scheduleId, event.updatedSchedule);
      emit(ScheduleOperationSuccess());
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> _onDeleteSchedule(
      DeleteSchedule event, Emitter<ScheduleState> emit) async {
    try {
      emit(ScheduleLoading());
      await repository.deleteSchedule(event.scheduleId);
      emit(ScheduleOperationSuccess()); // Emit state success
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
