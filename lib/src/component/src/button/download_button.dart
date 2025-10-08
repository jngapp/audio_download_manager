import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AdmDownloadStatus {
  notDownloaded,
  fetchingDownload,
  downloading,
  downloaded
}

class AdmDownloadConfig {
  const AdmDownloadConfig({
    required this.onDownload,
    this.onCancel,
    this.notDownloadedWidget,
    this.notDownloadedText,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.status,
  });

  final VoidCallback onDownload;
  final VoidCallback? onCancel;
  final AdmDownloadStatus? status;
  // final Function(AdmDownloadModel task)? onDone;
  final Duration transitionDuration;
  final Widget? notDownloadedWidget;
  final String? notDownloadedText;
}

@immutable
class AdmDownloadButton extends StatelessWidget {
  const AdmDownloadButton({
    super.key,
    required this.status,
    this.downloadProgress = 0,
    required this.config,

  });

  final AdmDownloadStatus status;
  final double downloadProgress;
  final AdmDownloadConfig config;

  bool get _isDownloading => status == AdmDownloadStatus.downloading;
  bool get _isFetching => status == AdmDownloadStatus.fetchingDownload;

  void _onPressed() {
    switch (status) {
      case AdmDownloadStatus.notDownloaded:
        config.onDownload();
      case AdmDownloadStatus.fetchingDownload:
        config.onCancel?.call();
      case AdmDownloadStatus.downloading:
        config.onCancel?.call();
      case AdmDownloadStatus.downloaded:
        // config.onDone?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: _onPressed,
        child: Stack(
          children: [
            ButtonShapeWidget(
              transitionDuration: config.transitionDuration,
              isDownloading: _isDownloading,
              isFetching: _isFetching,
              config: config,
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: config.transitionDuration,
                opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
                curve: Curves.ease,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProgressIndicatorWidget(
                      downloadProgress: downloadProgress,
                      isDownloading: _isDownloading,
                      isFetching: _isFetching,
                    ),
                    if(config.onCancel != null)
                      if (_isDownloading || _isFetching )
                        const Icon(
                          Icons.stop,
                          size: 14,
                          color: CupertinoColors.activeBlue,
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.isDownloading,
    required this.isFetching,
    required this.transitionDuration,
    required this.config,
  });
  final AdmDownloadConfig config;

  final bool isDownloading;
  final bool isFetching;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    ShapeDecoration? shape;
    if (isDownloading || isFetching) {
      shape = const ShapeDecoration(
        shape: CircleBorder(),
        color: Colors.transparent,
      );
    } else {
      shape = const ShapeDecoration(
        shape: StadiumBorder(),
        color: CupertinoColors.lightBackgroundGray,
      );
    }
    return SizedBox(
      width: isDownloading || isFetching ? 48 : 96,
      child: AnimatedContainer(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6),
        duration: transitionDuration,
        curve: Curves.ease,
        width: double.infinity,
        decoration: shape,
        child: AnimatedOpacity(
          duration: transitionDuration,
          opacity: isDownloading || isFetching ? 0.0 : 1.0,
          curve: Curves.ease,
          child: config.notDownloadedWidget ?? Text(
            config. notDownloadedText ?? 'GET',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: downloadProgress),
        duration: const Duration(milliseconds: 200),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            backgroundColor:
                isDownloading
                    ? CupertinoColors.lightBackgroundGray
                    : Colors.transparent,
            valueColor: AlwaysStoppedAnimation(
              isFetching
                  ? CupertinoColors.lightBackgroundGray
                  : CupertinoColors.activeBlue,
            ),
            strokeWidth: 2,
            value: isFetching ? null : progress,
          );
        },
      ),
    );
  }
}

class AdmDownloadedTextWidget extends StatelessWidget {
  const AdmDownloadedTextWidget({super.key, this.downloadedText,
    this.transitionDuration = const Duration(milliseconds: 500), this.onOpen,});
  final String? downloadedText;
  final Duration transitionDuration;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: GestureDetector(
        onTap: onOpen,
        child: AnimatedContainer(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6),
          duration: transitionDuration,
          curve: Curves.ease,
          width: double.infinity,
          decoration: const ShapeDecoration(
            shape: StadiumBorder(),
            color: CupertinoColors.lightBackgroundGray,
          ),
          child: SizedBox(
            width: 96,
            child: AnimatedOpacity(
              duration: transitionDuration,
              opacity: 1.0,
              curve: Curves.ease,
              child: Text( downloadedText ?? 'GET',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );;
  }
}

