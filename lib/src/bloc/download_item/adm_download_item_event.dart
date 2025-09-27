part of 'adm_download_item_bloc.dart';

sealed class AdmDownloadItemEvent extends Equatable {
  const AdmDownloadItemEvent();
}

class AdmEmitDownloadingProgress extends AdmDownloadItemEvent {
  const AdmEmitDownloadingProgress({required this.update, required this.taskId});
  final TaskProgressUpdate update;
  final String taskId;

  @override
  List<Object> get props => [];
}
