part of 'schedule_bloc.dart';

@immutable
abstract class ScheduleEvent {}

class LoadSchedules extends ScheduleEvent {}

class SaveSchedules extends ScheduleEvent {
  final List<Schedule> schedules;

  SaveSchedules(this.schedules);
}

class DeleteSchedule extends ScheduleEvent {
  final String scheduleId;

  DeleteSchedule(this.scheduleId);
}

class UpdateSchedule extends ScheduleEvent {
  final String scheduleId;
  final Schedule updatedSchedule;

  UpdateSchedule(this.scheduleId, this.updatedSchedule);
}
