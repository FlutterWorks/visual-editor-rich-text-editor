import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controller/controllers/editor-controller.dart';
import '../../../shared/models/editor-icon-theme.model.dart';
import '../../../shared/state/editor-state-receiver.dart';
import '../../../shared/state/editor.state.dart';
import '../../models/media-picker.type.dart';
import '../toolbar.dart';

// Insert in the document images capture via the camera.
// ignore: must_be_immutable
class CameraButton extends StatelessWidget with EditorStateReceiver {
  late final MediaLoaderService _imageVideoUtils;

  final IconData icon;
  final double iconSize;
  final Color? fillColor;
  final EditorController controller;
  final OnImagePickCallback? onImagePickCallback;
  final OnVideoPickCallback? onVideoPickCallback;
  final WebImagePickImpl? webImagePickImpl;
  final WebVideoPickImpl? webVideoPickImpl;
  final FilePickImpl? filePickImpl;
  final EditorIconThemeM? iconTheme;
  final double buttonsSpacing;
  late EditorState _state;

  CameraButton({
    required this.icon,
    required this.controller,
    required this.buttonsSpacing,
    this.iconSize = defaultIconSize,
    this.fillColor,
    this.onImagePickCallback,
    this.onVideoPickCallback,
    this.filePickImpl,
    this.webImagePickImpl,
    this.webVideoPickImpl,
    this.iconTheme,
    Key? key,
  }) : super(key: key) {
    controller.setStateInEditorStateReceiver(this);
    _imageVideoUtils = MediaLoaderService(_state);
  }

  @override
  void cacheStateStore(EditorState state) {
    _state = state;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return IconBtn(
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
      buttonsSpacing: buttonsSpacing,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _handleCameraButtonTap(
        context,
        controller,
        onImagePickCallback: onImagePickCallback,
        onVideoPickCallback: onVideoPickCallback,
        filePickImpl: filePickImpl,
        webImagePickImpl: webImagePickImpl,
      ),
    );
  }

  // === PRIVATE ===

  Future<void> _handleCameraButtonTap(
    BuildContext context,
    EditorController controller, {
    OnImagePickCallback? onImagePickCallback,
    OnVideoPickCallback? onVideoPickCallback,
    FilePickImpl? filePickImpl,
    WebImagePickImpl? webImagePickImpl,
  }) async {
    if (onImagePickCallback != null && onVideoPickCallback != null) {
      // Show dialog to choose Photo or Video
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    icon: const Icon(
                      Icons.photo,
                      color: Colors.cyanAccent,
                    ),
                    label: const Text('Photo'),
                    onPressed: () {
                      _imageVideoUtils.pickImage(
                        context,
                        ImageSource.camera,
                        onImagePickCallback,
                        filePickImpl: filePickImpl,
                        webImagePickImpl: webImagePickImpl,
                      );
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.movie_creation,
                      color: Colors.orangeAccent,
                    ),
                    label: const Text('Video'),
                    onPressed: () {
                      _imageVideoUtils.insertVideo(
                        context,
                        ImageSource.camera,
                        onVideoPickCallback,
                        filePickImpl: filePickImpl,
                        webVideoPickImpl: webVideoPickImpl,
                      );
                    },
                  )
                ],
              ),
            );
          });
    }

    if (onImagePickCallback != null) {
      return _imageVideoUtils.pickImage(
        context,
        ImageSource.camera,
        onImagePickCallback,
        filePickImpl: filePickImpl,
        webImagePickImpl: webImagePickImpl,
      );
    }

    assert(onVideoPickCallback != null, 'onVideoPickCallback must not be null');
    return _imageVideoUtils.insertVideo(
      context,
      ImageSource.camera,
      onVideoPickCallback!,
      filePickImpl: filePickImpl,
      webVideoPickImpl: webVideoPickImpl,
    );
  }
}
