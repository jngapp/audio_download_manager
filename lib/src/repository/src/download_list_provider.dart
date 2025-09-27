import 'package:audio_download_manager/audio_download_manager.dart';

abstract interface class AdmDownloadListProvider {
  Future<List<AdmDownloadModel>> getDownloads();
  Future<void> clearDownloads();
  Future<void> delete(String id);
  Future<void> insert(AdmDownloadModel model);
  Future<void> onTaskFinishedCallback(AdmDownloadModel task);
  Future<void> onTaskFailedCallback(AdmDownloadModel task);
}