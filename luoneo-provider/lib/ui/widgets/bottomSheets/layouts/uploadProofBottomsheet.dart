import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../../../../app/generalImports.dart';
import '../../customVideoPlayer/playVideoScreen.dart';

class UploadProofBottomSheet extends StatefulWidget {
  const UploadProofBottomSheet({super.key, this.preSelectedFiles});

  final List<Map<String, dynamic>>? preSelectedFiles;

  @override
  State<UploadProofBottomSheet> createState() => _UploadProofBottomSheetState();
}

class _UploadProofBottomSheetState extends State<UploadProofBottomSheet> {
  late ValueNotifier<List<Map<String, dynamic>>> uploadedMedia = ValueNotifier(
    widget.preSelectedFiles ?? [],
  );

  Future<void> selectMedia() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          '3g2',
          '3gp',
          'aaf',
          'asf',
          'avchd',
          'avi',
          'drc',
          'flv',
          'm2v',
          'm3u8',
          'm4p',
          'm4v',
          'mkv',
          'mng',
          'mov',
          'mp2',
          'mp4',
          'mpe',
          'mpeg',
          'mpg',
          'mpv',
          'mxf',
          'nsv',
          'ogg',
          'ogv',
          'qt',
          'rm',
          'rmvb',
          'roq',
          'svi',
          'vob',
          'webm',
          'wmv',
          'yuv',
          'jpg',
          'jpeg',
          'jfif',
          'pjpeg',
          'pjp',
          'png',
          'svg',
          'gif',
          'apng',
          'webp',
          'avif',
        ],
      );

      if (result != null) {
        final List<Map<String, dynamic>> files = result.paths.map((
          String? path,
        ) {
          final String? mimeType = lookupMimeType(path!);

          final List<String> extension = mimeType!.split('/');

          return {'file': File(path), 'fileType': extension.first};
        }).toList();

        // if files are already added previously, then remove that file from new file list
        for (int i = 0; i < uploadedMedia.value.length; i++) {
          for (int j = 0; j < files.length; j++) {
            if (uploadedMedia.value[i]['file'].path == files[j]['file'].path) {
              files.removeAt(j);
            }
          }
        }
        uploadedMedia.value = uploadedMedia.value + files;
      } else {
        // User canceled the picker
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    uploadedMedia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      title: 'chooseMedia',
      child: ValueListenableBuilder(
        valueListenable: uploadedMedia,
        builder:
            (
              BuildContext context,
              List<Map<String, dynamic>> value,
              Widget? child,
            ) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          //if images are there then we will enable scroll
                          physics: value.isEmpty
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              CustomInkWellContainer(
                                onTap: selectMedia,
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                        vertical: 15,
                                        horizontal: 5,
                                      ),
                                  child: SetDottedBorderWithHint(
                                    width: value.isEmpty
                                        ? MediaQuery.sizeOf(context).width - 30
                                        : 100,
                                    height: 100,
                                    radius: 5,
                                    borderColor: Theme.of(
                                      context,
                                    ).colorScheme.blackColor,
                                    strPrefix: 'chooseMedia'.translate(
                                      context: context,
                                    ),
                                    str: '',
                                  ),
                                ),
                              ),
                              if (value.isNotEmpty)
                                Row(
                                  children: List.generate(
                                    value.length,
                                    (int index) => CustomContainer(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 100,
                                      width: 100,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor
                                            .withValues(alpha: 0.5),
                                      ),
                                      child: Stack(
                                        children: [
                                          if (value[index]['fileType'] ==
                                              'image')
                                            Center(
                                              child: Image.file(
                                                File(
                                                  value[index]['file']!.path,
                                                ),
                                              ),
                                            )
                                          else
                                            CustomInkWellContainer(
                                              child: Center(
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.accentColor,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext context) {
                                                      return PlayVideoScreen(
                                                        videoFile:
                                                            value[index]['file'],
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            child: CustomInkWellContainer(
                                              onTap: () async {
                                                //assigning new list, because listener will not notify if we remove the values only to the list
                                                uploadedMedia.value = List.from(
                                                  uploadedMedia.value,
                                                )..removeAt(index);
                                              },
                                              child: CustomContainer(
                                                height: 20,
                                                width: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .blackColor
                                                    .withValues(alpha: 0.4),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.clear_rounded,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  CloseAndConfirmButton(
                    closeButtonPressed: () {
                      Navigator.pop(context, uploadedMedia.value);
                    },
                    confirmButtonPressed: () {
                      Navigator.pop(context, uploadedMedia.value);
                    },
                    confirmButtonName: uploadedMedia.value.isNotEmpty
                        ? 'done'.translate(context: context)
                        : 'skip'.translate(context: context),
                  ),
                ],
              );
            },
      ),
    );
  }
}
