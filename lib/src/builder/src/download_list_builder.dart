import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../audio_download_manager.dart';
import '../../bloc/bloc.dart';

class AdmDownloadListBuilder extends StatelessWidget {
  const AdmDownloadListBuilder({
    super.key,
    required this.loadingBuilder,
    required this.loadedBuilder,
    required this.errorBuilder,
  });

  final Widget Function(BuildContext context) loadingBuilder;
  final Widget Function(
    BuildContext context,
    List<AdmDownloadModel> enqueuedList,
    List<AdmDownloadModel> downloadingList,
    List<AdmDownloadModel> downloadedList,
    List<AdmDownloadModel> failedList,
  )
  loadedBuilder;
  final Widget Function(BuildContext context) errorBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdmDownloadListBloc, AdmDownloadListState>(
      builder: (context, state) {
        switch (state.status) {
          case AdmDownloadListStatus.loading:
            return loadingBuilder(context);
          case AdmDownloadListStatus.loaded:
            return loadedBuilder(
              context,
              state.enqueuedList,
              state.downloadingList,
              state.downloadedList,
              state.failedList,
            );
          case AdmDownloadListStatus.error:
            return errorBuilder(context);
        }
      },
    );
  }
}

class AdmItemBuilder extends StatelessWidget {
  const AdmItemBuilder({
    super.key,
    required this.defaultBuilder,
    required this.enqueuedBuilder,
    required this.downloadingBuilder,
    required this.downloadedBuilder,
    this.failedBuilder,
    required this.itemId,
  });

  final Widget Function(BuildContext context) defaultBuilder;
  final Widget Function(BuildContext context) enqueuedBuilder;
  final Widget Function(BuildContext context, double? progress)
  downloadingBuilder;
  final Widget Function(BuildContext context) downloadedBuilder;
  final Widget Function(BuildContext context)? failedBuilder;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdmDownloadListBloc, AdmDownloadListState>(
      builder: (context, listState) {
        if (!listState.downloadedList
            .map((e) => e.id)
            .toList()
            .contains(itemId)) {
          if (listState.enqueuedList
              .map((e) => e.id)
              .toList()
              .contains(itemId)) {
            return enqueuedBuilder(context);
          } else if (listState.downloadingList
              .map((e) => e.id)
              .toList()
              .contains(itemId)) {
            return BlocBuilder<AdmDownloadItemBloc, AdmDownloadItemState>(
              builder: (context, itemState) {
                return downloadingBuilder(context, itemState.update?.progress);
              },
            );
          }
          return defaultBuilder(context);
        } else {
          return downloadedBuilder(context);
        }
      },
    );
  }
}

class AdmItemAnimatedWidget extends StatefulWidget {
  const AdmItemAnimatedWidget({
    super.key,
    required this.config,
    required this.itemId,
    this.downloadedWidget,
  });

  final AdmDownloadConfig config;
  final String itemId;
  final Widget? downloadedWidget;

  @override
  State<AdmItemAnimatedWidget> createState() => _AdmItemAnimatedWidgetState();
}

class _AdmItemAnimatedWidgetState extends State<AdmItemAnimatedWidget> {
  late AdmDownloadController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdmDownloadController();
    _controller.downloadStatus =
        widget.config.status ?? AdmDownloadStatus.notDownloaded;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdmDownloadListBloc, AdmDownloadListState>(
          listener: (context, listState) {
            if (!listState.downloadedList
                .map((e) => e.id)
                .toList()
                .contains(widget.itemId)) {
              if (listState.enqueuedList
                  .map((e) => e.id)
                  .toList()
                  .contains(widget.itemId)) {
                _controller.downloadStatus = AdmDownloadStatus.fetchingDownload;
              } else if (listState.downloadingList
                  .map((e) => e.id)
                  .toList()
                  .contains(widget.itemId)) {
                _controller.downloadStatus = AdmDownloadStatus.downloading;
              }
            } else {
              _controller.downloadStatus = AdmDownloadStatus.downloaded;
              // widget.config.onDone?.call(
              //   listState.downloadedList.firstWhere(
              //     (e) => e.id == widget.itemId,
              //   ),
              // );
            }
          },
        ),
        BlocListener<AdmDownloadItemBloc, AdmDownloadItemState>(
          listener: (context, itemState) {
            _controller.progress = itemState.update?.progress ?? 0.0;
          },
        ),
      ],
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _controller.downloadStatus == AdmDownloadStatus.downloaded
              ? widget.downloadedWidget ?? SizedBox.shrink()
              : AdmDownloadButton(
                downloadProgress: _controller.progress,
                status: _controller.downloadStatus,
                config: widget.config,
              );
        },
      ),
    );
  }
}

class AdmDownloadController with ChangeNotifier {
  double _progress = 0.0;
  AdmDownloadStatus _downloadStatus = AdmDownloadStatus.notDownloaded;

  double get progress => _progress;

  AdmDownloadStatus get downloadStatus => _downloadStatus;

  set downloadStatus(AdmDownloadStatus status) {
    _downloadStatus = status;
    notifyListeners();
  }

  set progress(double progress) {
    _progress = progress;
    notifyListeners();
  }
}
