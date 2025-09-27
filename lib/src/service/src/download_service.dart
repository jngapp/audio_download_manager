import 'package:audio_download_manager/src/bloc/bloc.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class AdmDownloadService {
  AdmDownloadService._();

  static AdmDownloadService? _instance;
  FileDownloader? _downloader;
  String? _downloadPath;

  static AdmDownloadService get instance {
    _instance ??= AdmDownloadService._();
    return _instance!;
  }

  void _ensureInitialized() {
    _downloader ??= FileDownloader();
  }

  Future<void> configure({
    dynamic globalConfig,
    dynamic androidConfig,
    dynamic iOSConfig,
    dynamic desktopConfig,
  }) async {
    _ensureInitialized();
    await _downloader!.configure(globalConfig: globalConfig);
  }

  void registerCallback( {
    TaskStatusCallback? taskStatusCallback,
    TaskProgressCallback? taskProgressCallback,
    TaskNotificationTapCallback? taskNotificationTapCallback})  {
    _ensureInitialized();
    _downloader!.registerCallbacks(
      taskStatusCallback: taskStatusCallback,
      taskProgressCallback: taskProgressCallback,
      taskNotificationTapCallback: taskNotificationTapCallback,
    );
  }

  Future<String> getDownloadPath() async {
    _ensureInitialized();
    _downloadPath ??= (await getApplicationDocumentsDirectory()).path;
    return _downloadPath!;
  }

  Future<void> enqueue(DownloadTask task) async {
    _ensureInitialized();
    await _downloader!.enqueue(task);
  }

  Stream<TaskUpdate> get updates {
    _ensureInitialized();
    return _downloader!.updates;
  }

  Future<void> cancel(DownloadTask task) async {
    _ensureInitialized();
    await _downloader!.cancel(task);
  }

  Future<void> pause(DownloadTask task) async {
    _ensureInitialized();
    await _downloader!.pause(task);
  }

  Future<void> resume(DownloadTask task) async {
    _ensureInitialized();
    await _downloader!.resume(task);
  }
}
