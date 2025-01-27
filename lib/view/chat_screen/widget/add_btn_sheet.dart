import 'dart:developer';
import 'dart:io';

import 'package:bubbly/api/api_service.dart';
import 'package:bubbly/custom_view/common_ui.dart';
import 'package:bubbly/languages/languages_keys.dart';
import 'package:bubbly/utils/colors.dart';
import 'package:bubbly/utils/const_res.dart';
import 'package:bubbly/utils/firebase_res.dart';
import 'package:bubbly/utils/font_res.dart';
import 'package:bubbly/utils/my_loading/my_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


import 'image_video_msg_screen.dart';

class AddBtnSheet extends StatelessWidget {
  final Function(
      {String? msgType,
      String? imagePath,
      String? videoPath,
      String? msg}) fireBaseMsg;

  AddBtnSheet({Key? key, required this.fireBaseMsg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) {
        return Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  color: myLoading.isDark
                      ? ColorRes.colorPrimary
                      : ColorRes.greyShade100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 8),
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 10),
                    child: Text(
                      LKey.whichItemWouldYouLikeToSelectNSelectAItem.tr,
                      style: TextStyle(
                          color: ColorRes.colorTextLight,
                          fontSize: 17,
                          fontFamily: FontRes.fNSfUiSemiBold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTilesCustom(
                    onTap: (p0) {
                      if (p0 == 0) {
                        onImageClick(context);
                      } else if (p0 == 1) {
                        onVideoClick(context);
                      } else if (p0 == 2) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  void onImageClick(BuildContext context) async {
    File? images;
    // Pick an image
    CommonUI.showLoader(context);
    final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxHeight: maxHeight,
        maxWidth: maxWidth);
    Navigator.pop(context);
    if (image == null || image.path.isEmpty) return;
    images = File(image.path);
    log(images.path);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ImageVideoMsgScreen(
          image: images?.path,
          onIVSubmitClick: ({text}) {
            CommonUI.showLoader(context);
            ApiService().filePath(filePath: images).then((value) {
              log('==================== ${value.path}');
              fireBaseMsg(
                  msgType: FirebaseRes.image,
                  imagePath: value.path,
                  videoPath: null,
                  msg: text);
            }).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
        );
      },
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onVideoClick(BuildContext context) async {
    File? videos;
    String? imageUrl;
    String? videoUrl;
    CommonUI.showLoader(context);
    final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery, maxDuration: Duration(seconds: 30));
    Navigator.pop(context);
    if (video == null || video.path.isEmpty) return;

    /// calculating file size
    videos = File(video.path);
    int sizeInBytes = videos.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    if (sizeInMb <= 15) {
      await VideoThumbnail.thumbnailFile(video: videos.path).then(
        (value) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return ImageVideoMsgScreen(
                image: value,
                onIVSubmitClick: ({text}) {
                  CommonUI.showLoader(context);
                  ApiService()
                      .filePath(filePath: File(value ?? ''))
                      .then((value) {
                    imageUrl = value.path;
                  }).then(
                    (value) {
                      ApiService().filePath(filePath: videos).then((value) {
                        videoUrl = value.path;
                      }).then(
                        (value) {
                          fireBaseMsg(
                              videoPath: videoUrl,
                              msgType: FirebaseRes.video,
                              imagePath: imageUrl,
                              msg: text);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    }
  }
}

class ListTilesCustom extends StatelessWidget {
  final Function(int) onTap;

  const ListTilesCustom({Key? key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => onTap(index),
          child: Column(
            children: [
              Divider(color: Colors.grey, indent: 15, endIndent: 15),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  index == 0
                      ? LKey.images.tr
                      : index == 1
                          ? LKey.videos.tr
                          : LKey.close.tr,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: FontRes.fNSfUiRegular,
                      color: index == 2 ? Colors.red : null),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
