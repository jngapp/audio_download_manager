import 'dart:convert';
import 'dart:ui';

import 'package:background_downloader/background_downloader.dart';

class AdmDownloadModel {
  String? id;
  String? url;
  String? fileName;
  String? directory;
  VoidCallback? onDone;
  // final Future<void> Function(TaskStatusUpdate taskStatusUpdate)? onDone;

  AdmDownloadModel({
    this.id,
    this.url,
    this.fileName,
    this.directory,
    this.onDone,
  });

  factory AdmDownloadModel.fromDownloadTask(Task task, {VoidCallback? onDone}) {
    return AdmDownloadModel(
      id: task.taskId,
      url: task.url,
      fileName: task.filename,
      directory: task.directory,
      onDone: onDone,
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
    VoidCallback? onDone,
    // Future<void> Function(TaskStatusUpdate taskStatusUpdate)? onDone,
  }) {
    return AdmDownloadModel(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      directory: directory ?? this.directory,
      onDone: onDone ?? this.onDone,
    );
  }
}