part of 'schedule_bloc.dart';

@immutable
abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleSaving extends ScheduleState {}

class ScheduleOperationSuccess extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<Schedule> schedules;

  ScheduleLoaded(this.schedules);
}

class ScheduleSaved extends ScheduleState {
  final List<Schedule> schedules;

  ScheduleSaved(this.schedules);
}

class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError(this.message);
}
