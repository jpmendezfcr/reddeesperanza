import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/utilities/const.dart';

class MyCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;

  const MyCachedImage({super.key, this.imageUrl, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    // Check if the imageUrl is null, empty, or not a valid URL
    if (imageUrl == null || imageUrl!.isEmpty || !Uri.parse(imageUrl!.addBaseURL()).isAbsolute) {
      return placeHolder();
    }

    return CachedNetworkImage(
      cacheKey: imageUrl?.addBaseURL() ?? '',
      imageUrl: imageUrl?.addBaseURL() ?? '',
      width: width,
      height: height,
      fit: BoxFit.cover,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      errorWidget: (context, url, error) {
        return placeHolder();
      },
      placeholder: (context, url) {
        return placeHolder();
      },
    );
  }

  Widget placeHolder() {
    return Image.asset(MyImages.placeHolderImage, width: width, height: height, fit: BoxFit.cover);
  }
}

class MyCachedProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final String? fullName;

  const MyCachedProfileImage({super.key, this.imageUrl, this.width, this.height, this.fullName});

  @override
  Widget build(BuildContext context) {
    // Check if the imageUrl is null, empty, or not a valid URL
    if (imageUrl == null || imageUrl!.isEmpty || !Uri.parse(imageUrl!.addBaseURL()).isAbsolute) {
      return placeHolder();
    }

    return CachedNetworkImage(
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageUrl: imageUrl?.addBaseURL() ?? '',
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => placeHolder(),
      errorWidget: (context, url, error) {
        return placeHolder();
      },
    );
  }

  Widget placeHolder() {
    return Container(
      color: cDarkBG,
      height: height,
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        fullName == null || fullName!.isEmpty ? "No"[0].toUpperCase() : fullName![0].toUpperCase(),
        style: MyTextStyle.gilroyBold(color: cPrimary, size: 30),
      ),
    );
  }
}
