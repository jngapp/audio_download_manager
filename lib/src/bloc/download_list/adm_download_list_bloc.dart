import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:audio_download_manager/audio_download_manager.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import '../../service/service.dart';
import '../download_item/adm_download_item_bloc.dart';
part 'adm_download_list_event.dart';
part 'adm_download_list_state.dart';

class AdmDownloadListBloc
    extends Bloc<AdmDownloadListEvent, AdmDownloadListState> {
  final AdmDownloadListProvider downloadListProvider;
  StreamSubscription<TaskUpdate>? _updateSubscription;
  // ReceivePort? _receivePort;


  AdmDownloadListBloc({required this.downloadListProvider})
    : super(
        AdmDownloadListState(
          downloadingList: [],
          downloadedList: [],
          enqueuedList: [],
          failedList: [],
          status: AdmDownloadListStatus.loading,
        ),
      ) {
    on<AdmLoadDownloadedList>(_onLoadDownloadedList);
    on<AdmClearDownloadedList>(_onClearDownloadedList);
    on<_AdmMoveItemToEnqueue>(_onEnqueueItem);
    on<_AdmMoveItemToDownloading>(_onDownloadItem);
    on<_AdmMoveItemToComplete>(_onCompleteDownload);
    on<_AdmMoveItemToFailed>(_onFailedDownload);
    on<AdmEnqueueItem>(_onAddItemToQueue);
    on<AdmDeleteItem>(_onDeleteItem);

    // _receivePort ??= ReceivePort();
    // IsolateNameServer.registerPortWithName(_receivePort!.sendPort, 'downloadCallbackPort');
    // _receivePort!.listen((message) {
    //   print('listening');
    //   final status = message[0];
    //   final data = message[1];
    //   print(message);
    //   final downloadTask = AdmDownloadModel.fromJson(data);
    //   if(status == 0) {
    //     downloadListProvider.onTaskFailedCallback(downloadTask);
    //   }
    //   else {
    //     downloadListProvider.onTaskFinishedCallback(downloadTask);
    //     print(downloadTask.toJson());
    //   }
    //
    // }, onDone: () {
    //   print('ReceivePort done');
    // }, onError: (error) {
    //   print('ReceivePort error: $error');
    // });

    _updateSubscription = AdmDownloadService.instance.updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate():
          switch (update.status) {
            case TaskStatus.complete:
              final completeItem = AdmDownloadModel.fromDownloadTask(
                update.task,
              );
              downloadListProvider.onTaskFinishedCallback(completeItem);
              add(_AdmMoveItemToComplete(completeItem));
              break;
            case TaskStatus.enqueued:
              final enqueuedItem = AdmDownloadModel.fromDownloadTask(
                update.task,
              );
              add(_AdmMoveItemToEnqueue(enqueuedItem));
              break;
            case TaskStatus.running:
              final downloadingItem = AdmDownloadModel.fromDownloadTask(
                update.task,
              );
              add(_AdmMoveItemToDownloading(downloadingItem));
              break;
            case TaskStatus.notFound:
            case TaskStatus.failed:
              final failedItem = AdmDownloadModel.fromDownloadTask(update.task);
              downloadListProvider.onTaskFailedCallback(failedItem);
              add(_AdmMoveItemToFailed(failedItem));
              break;
            case TaskStatus.canceled:
            case TaskStatus.paused:
            default:
              // print('Default ${update.status}');
          }
        case TaskProgressUpdate():
          GetIt.I<AdmDownloadItemBloc>().add(
            AdmEmitDownloadingProgress(
              update: update,
              taskId: update.task.taskId,
            ),
          );
      }
    });

    add(AdmLoadDownloadedList());
  }

  void _onDeleteItem(
    AdmDeleteItem event,
    Emitter<AdmDownloadListState> emit,
  ) async {
    downloadListProvider.delete(event.id);
    final updatedDownloadedList =
        state.downloadedList.where((e) => e.id != event.id).toList();
    emit(state.copyWith(downloadedList: updatedDownloadedList));
  }

  void _stopListeningToUpdates() {
    _updateSubscription?.cancel();
    _updateSubscription = null;
  }

  void _checkAndHandleEmptyDownloads(Emitter<AdmDownloadListState> emit) {
    // No action needed since we always listen
  }

  void _onAddItemToQueue(
    AdmEnqueueItem event,
    Emitter<AdmDownloadListState> emit,
  ) async {
    final download = event.item;
    String url = download.url!;
    final task = DownloadTask(
      url: url,
      updates: Updates.statusAndProgress,
      taskId: download.id!,
      filename: download.fileName!,
      // options: TaskOptions(onTaskFinished: onTaskFinishedCallback),
      retries: 3,
    );
    await AdmDownloadService.instance.enqueue(task);
  }

  void _onDownloadItem(
    _AdmMoveItemToDownloading event,
    Emitter<AdmDownloadListState> emit,
  ) async {
    if (!state.downloadingList.map((e) => e.id).toList().contains(event.item.id)) {
      // print('before added ${state.downloadingList.length} to downloading');
      // print('added ${event.item.id} to downloading');
      final downloadingList = List<AdmDownloadModel>.from(
        state.downloadingList + [event.item],
      );
      final enqueuedList = List<AdmDownloadModel>.from(
        state.enqueuedList.where((e) => e.id != event.item.id).toList(),
      );
      emit(
        state.copyWith(
          downloadingList: downloadingList,
          enqueuedList: enqueuedList,
        ),
      );

      // print('after added ${state.downloadingList.length} to downloading');
    }
  }

  void _onEnqueueItem(
    _AdmMoveItemToEnqueue event,
    Emitter<AdmDownloadListState> emit,
  ) async {
    if (!state.enqueuedList.map((e) => e.id).contains(event.item.id) &&
        !state.downloadingList.map((e) => e.id).contains(event.item.id)) {
      final enqueuedList = List<AdmDownloadModel>.from(
        state.enqueuedList + [event.item],
      );
      // print('added ${event.item.id} to enqueued');
      emit(state.copyWith(enqueuedList: enqueuedList));
    }
  }

  void _onCompleteDownload(
    _AdmMoveItemToComplete event,
    Emitter<AdmDownloadListState> emit,
  ) async {

    // print('before removed ${state.downloadingList.length} from downloading');
    final downloadingList =
        state.downloadingList.where((e) => e.id != event.item.id).toList();
    final downloadedList = List<AdmDownloadModel>.from(
      state.downloadedList + [event.item],
    );
    // print('added ${event.item.id} to completed');
    emit(
      state.copyWith(
        downloadedList: downloadedList,
        downloadingList: downloadingList,
      ),
    );
    // print('after removed ${state.downloadingList.length} from downloading');
    downloadListProvider.insert(event.item);
    _checkAndHandleEmptyDownloads(emit);
  }

  void _onFailedDownload(
    _AdmMoveItemToFailed event,
    Emitter<AdmDownloadListState> emit,
  ) async {
    final downloadingList =
        state.downloadingList.where((e) => e.id != event.item.id).toList();
    final failedList = List<AdmDownloadModel>.from(
      state.failedList + [event.item],
    );
    emit(
      state.copyWith(failedList: failedList, downloadingList: downloadingList),
    );
    _checkAndHandleEmptyDownloads(emit);
  }

  void _onLoadDownloadedList(
    AdmLoadDownloadedList event,
    Emitter<AdmDownloadListState> emit,
  ) async {
    emit(state.copyWith(status: AdmDownloadListStatus.loading));
    final downloadedList = await downloadListProvider.getDownloads();
    emit(
      state.copyWith(
        downloadedList: downloadedList,
        status: AdmDownloadListStatus.loaded,
      ),
    );
  }

  void _onClearDownloadedList(
    AdmClearDownloadedList event,
    Emitter<AdmDownloadListState> emit,
  ) async {
    emit(state.copyWith(status: AdmDownloadListStatus.loading));
    await downloadListProvider.clearDownloads();
    emit(
      state.copyWith(downloadedList: [], status: AdmDownloadListStatus.loaded),
    );
  }

  @override
  Future<void> close() {
    _stopListeningToUpdates();
    return super.close();
  }
}
//
// @pragma("vm:entry-point")
// Future<void> onTaskFinishedCallback(TaskStatusUpdate statusUpdate) async {
//   final downloadTask = AdmDownloadModel.fromDownloadTask(statusUpdate.task);
//   final sendPort = IsolateNameServer.lookupPortByName('downloadCallbackPort');
//   if(sendPort == null) {
//     print('sendPort null');
//   }
//   else {
//     print('sendPort not null');
//   }
//
//   if (statusUpdate.status == TaskStatus.complete &&
//       statusUpdate.responseStatusCode == 200) {
//     sendPort!.send([1, downloadTask.toJson().toString()]);
//     print('sending successful task');
//     // AudioDownloadManager.admDownloadListProvider?.onTaskFinishedCallback.call(AdmDownloadModel.fromDownloadTask(statusUpdate.task));
//   } else {
//     sendPort!.send([0, downloadTask.toJson()]);
//     // AudioDownloadManager.admDownloadListProvider?.onTaskFailedCallback.call(AdmDownloadModel.fromDownloadTask(statusUpdate.task));
//     // callbackCounter += 100; // to indicate error
//   }
//   // print('In onTaskFinishedCallback. Callback counter is now $callbackCounter');
//   // _sendCounterToMainIsolate();
// }
