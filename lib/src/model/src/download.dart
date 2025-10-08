import 'package:background_downloader/background_downloader.dart';

class AdmDownloadModel {
  String? id;
  String? url;
  String? fileName;
  String? directory;

  AdmDownloadModel({
    this.id,
    this.url,
    this.fileName,
    this.directory,
  });

  factory AdmDownloadModel.fromDownloadTask(Task task) {
    return AdmDownloadModel(
      id: task.taskId,
      url: task.url,
      fileName: task.filename,
      directory: task.directory,
    );
  }

  // factory AdmDownloadModel.fromJson(Map<String, dynamic> json) {
  //   return AdmDownloadModel(
  //     id: json['id'],
  //     url: json['url'],
  //     fileName: json['fileName'],
  //     directory: json['directory']
  //   );
  // }
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'url': url,
  //     'fileName': fileName,
  //     'directory': directory,
  //   };
  // }

  AdmDownloadModel copyWith({
    String? id,
    String? url,
    String? fileName,
    String? directory,
    // Future<void> Function(TaskStatusUpdate taskStatusUpdate)? onDone,
  }) {
    return AdmDownloadModel(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      directory: directory ?? this.directory,
    );
  }
}