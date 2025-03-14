import 'dart:ui';

import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/extensions/int_extension.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/functions.dart';
import 'package:untitled/common/widgets/menu.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/chatting_view.dart';
import 'package:untitled/screens/extra_views/back_button.dart';
import 'package:untitled/screens/feed_screen/feed_screen.dart';
import 'package:untitled/screens/profile_screen/follower_following/follower_following_screen.dart';
import 'package:untitled/screens/profile_screen/full_image_screen.dart';
import 'package:untitled/screens/profile_screen/profile_controller.dart';
import 'package:untitled/screens/report_screen/report_sheet.dart';
import 'package:untitled/screens/rooms_screen/room_card.dart';
import 'package:untitled/screens/setting_screen/setting_screen.dart';
import 'package:untitled/screens/story_screen/story_screen.dart';
import 'package:untitled/utilities/const.dart';

class ProfileScreen extends StatelessWidget {
  final num userId;

  const ProfileScreen({Key? key, this.isFromTabBar = false, required this.userId}) : super(key: key);
  final bool isFromTabBar;

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = ProfileController(userId.toInt(), isFromTabBar);
    final bool isMyProfile = controller.userID == SessionManager.shared.getUserID();
    Functions.changStatusBar(StatusBarStyle.white);
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GetBuilder(
              id: controller.scrollID,
              tag: controller.scrollID,
              init: controller,
              builder: (controller) {
                return RefreshIndicator(
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  color: refreshIndicatorColor,
                  backgroundColor: refreshIndicatorBgColor,
                  onRefresh: () async {
                    await controller.getProfile(isForRefresh: true);
                    await controller.refreshPosts();
                  },
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      GetBuilder(
                          id: controller.scrollID,
                          tag: controller.scrollID,
                          init: controller,
                          builder: (_) {
                            var temp = (controller.currentExtent * 0.28);
                            var size = temp < 35.0 ? 35.0 : temp;
                            var o = (-1 * (size - 70)) * 0.02857143;
                            var opacity = 1 - (o > 1.0 ? 1.0 : o);
                            return SliverAppBar(
                              pinned: true,
                              backgroundColor: Colors.transparent,
                              expandedHeight: controller.maxExtent,
                              collapsedHeight: 60,
                              stretch: true,
                              shadowColor: Colors.transparent,
                              leadingWidth: 0,
                              automaticallyImplyLeading: false,
                              flexibleSpace: FlexibleSpaceBar(
                                expandedTitleScale: 1,
                                titlePadding: const EdgeInsets.all(0),
                                collapseMode: CollapseMode.pin,
                                title: Stack(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            var backgroundImage = controller.user?.backgroundImage ?? '';
                                            if (backgroundImage.isNotEmpty) {
                                              Get.context!.pushTransparentRoute(
                                                FullImageScreen(
                                                  image: backgroundImage,
                                                  tag: 'BackgroundImage_${controller.userID}_${controller.idForImage}',
                                                  width: Get.width,
                                                  height: null,
                                                  cornerRadius: 0,
                                                ),
                                              );
                                            }
                                          },
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Container(color: cBlack),
                                              Hero(
                                                tag: 'BackgroundImage_${controller.userID}_${controller.idForImage}',
                                                child: MyCachedImage(
                                                  imageUrl: controller.user?.backgroundImage ?? '',
                                                  width: Get.width,
                                                  height: 170 + Get.mediaQuery.viewInsets.top,
                                                ),
                                              ),
                                              ClipRRect(
                                                // Clip it cleanly.
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: (1 - opacity) * 10, sigmaY: (1 - opacity) * 10),
                                                  child: Container(
                                                    color: Colors.black.withValues(alpha: (1 - opacity) / 2),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: isFromTabBar ? 15 : 45, bottom: 12),
                                          child: temp < 5 ? namePlate(controller) : Container(),
                                        ),
                                        top(controller, opacity)
                                      ],
                                    ),
                                    SafeArea(
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 18, right: 15, left: 7),
                                        child: Row(
                                          children: [
                                            !isFromTabBar
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: const Icon(
                                                      Icons.chevron_left_rounded,
                                                      color: cWhite,
                                                      size: 30,
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                            const Spacer(),
                                            isMyProfile
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Navigate.to(const SettingScreen())?.then((value) {
                                                        controller.updateMyProfile();
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.settings,
                                                      color: cWhite,
                                                    ),
                                                  )
                                                : profileMenu(controller)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                stretchModes: const [StretchMode.zoomBackground],
                                // background: GestureDetector(
                                //   child: MyCachedImage(
                                //     imageUrl: controller.user?.backgroundImage ?? '',
                                //     // width: Get.width,
                                //     height: 190 + Get.mediaQuery.viewInsets.top,
                                //   ),
                                // ),
                              ),
                            );
                          }),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            details(controller),
                            postsView(controller),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
          isMyProfile
              ? GetBuilder(
                  init: controller,
                  builder: (controller) {
                    return PostButton(
                      onPostBack: (post) {
                        controller.refreshPosts();
                      },
                      onStoryBack: () {
                        controller.getStories();
                      },
                    );
                  })
              : Container(),
        ],
      ),
    );
  }

  Widget top(ProfileController controller, double opacity) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 58,
          color: cBlack.withValues(alpha: opacity),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(width: isFromTabBar ? 0 : (1 - opacity) * 25),
                  GestureDetector(
                    onLongPress: () {
                      Get.context!.pushTransparentRoute(
                        FullImageScreen(
                          image: (controller.user?.profile ?? ''),
                          tag: 'ProfileImage${controller.userID}_${controller.idForImage}',
                          width: Get.width - 100,
                          height: Get.width - 100,
                        ),
                      );
                    },
                    onTap: () {
                      if ((controller.user?.story ?? []).isNotEmpty) {
                        Get.bottomSheet(StoryScreen(users: [controller.user ?? User()], index: 0), isScrollControlled: true, ignoreSafeArea: false).then((value) {
                          controller.getStories();
                        });
                      } else {
                        Get.context!.pushTransparentRoute(
                          FullImageScreen(
                            image: (controller.user?.profile ?? ''),
                            tag: 'ProfileImage${controller.userID}_${controller.idForImage}',
                            width: Get.width - 100,
                            height: Get.width - 100,
                          ),
                        );
                      }
                    },
                    child: Opacity(
                      opacity: opacity,
                      child: Hero(
                        tag: 'ProfileImage${controller.userID}_${controller.idForImage}',
                        transitionOnUserGestures: true,
                        child: ClipSmoothRect(
                          radius: const SmoothBorderRadius.all(SmoothRadius(cornerRadius: 15, cornerSmoothing: cornerSmoothing)),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            color: (controller.user?.story ?? []).isEmpty ? Colors.transparent : (controller.user?.isAllStoryShown() == false ? cPrimary : cLightText),
                            child: ClipSmoothRect(
                              radius: const SmoothBorderRadius.all(SmoothRadius(cornerRadius: 13, cornerSmoothing: cornerSmoothing)),
                              child: MyCachedImage(
                                imageUrl: (controller.user?.profile ?? ''),
                                width: opacity == 0 ? 0 : 85,
                                height: opacity == 0 ? 0 : 85,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  (!(controller.user?.isBlockedByMe() ?? false)) ? Opacity(opacity: opacity, child: followBtn(controller)) : Container(),
                ],
              ),
            ),
            Container(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget namePlate(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                controller.user?.fullName ?? '',
                style: MyTextStyle.gilroyBlack(color: cWhite, size: 24),
                maxLines: 1,
              ),
            ),
            VerifyIcon(
              user: controller.user,
            )
          ],
        ),
        Text(
          '@${controller.user?.username ?? ''}',
          style: MyTextStyle.gilroyLight(color: cPrimary),
        ),
      ],
    );
  }

  Widget details(ProfileController controller) {
    return GetBuilder(
        init: controller,
        tag: "${controller.userID}",
        builder: (controller) {
          return controller.user == null
              ? Container()
              : Container(
                  padding: const EdgeInsets.all(15),
                  color: cBlack,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      namePlate(controller),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigate.to(FollowerFollowingScreen(isForFollowing: false, user: controller.user));
                            },
                            child: Row(
                              children: [
                                Text(
                                  controller.user?.followers?.makeToString() ?? '0',
                                  style: MyTextStyle.gilroyBold(color: cWhite),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  LKeys.followers.tr,
                                  style: MyTextStyle.gilroyLight(color: cWhite),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigate.to(FollowerFollowingScreen(isForFollowing: true, user: controller.user));
                            },
                            child: Row(
                              children: [
                                Text(
                                  controller.user?.following?.makeToString() ?? '0',
                                  style: MyTextStyle.gilroyBold(color: cWhite),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  LKeys.following.tr,
                                  style: MyTextStyle.gilroyLight(color: cWhite),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      controller.user?.bio == null
                          ? Container()
                          : Column(
                              children: [
                                DetectableText(
                                  maxLines: null,
                                  detectionRegExp: detectionRegExp(atSign: false, url: true)!,
                                  onTap: (p0) async {
                                    controller.handleURL(url: p0);
                                  },
                                  lessStyle: MyTextStyle.gilroyMedium(color: cPrimary),
                                  moreStyle: MyTextStyle.gilroyMedium(color: cPrimary),
                                  trimCollapsedText: LKeys.showMore.tr,
                                  trimExpandedText: '  ${LKeys.showLess.tr}',
                                  text: controller.user?.bio ?? '',
                                  basicStyle: MyTextStyle.gilroyLight(size: 16, color: cLightIcon),
                                  detectedStyle: MyTextStyle.gilroyRegular(size: 16, color: cPrimary),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                      Wrap(
                        children: (controller.user?.getInterestsStringList() ?? []).map((e) {
                          return RoomCardInterestTagToShow(
                            tag: e,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
        });
  }

  Widget postsView(ProfileController controller) {
    return FeedsView(
      controller: controller,
      id: '${controller.userID}_${controller.profileFeedID}',
    );
  }

  Widget followBtn(ProfileController controller) {
    return GetBuilder<ProfileController>(
      init: controller,
      tag: "${controller.userID}",
      builder: (controller) {
        var isFollowed = (controller.user?.followingStatus ?? 0) == 2 || (controller.user?.followingStatus ?? 0) == 3;
        return controller.user?.id == SessionManager.shared.getUserID()
            ? Container()
            : GestureDetector(
                onTap: () {
                  Navigate.to(ChattingView(user: controller.user));
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: cPrimary.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Image.asset(
                        MyImages.chatProfile,
                        width: 22,
                        height: 22,
                        color: cWhite,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: controller.followToggle,
                      child: Container(
                        padding: const EdgeInsets.only(right: 25, left: 25, top: 10, bottom: 8),
                        decoration: BoxDecoration(color: isFollowed ? cDarkText.withValues(alpha: 0.7) : cWhite, borderRadius: BorderRadius.circular(100)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            controller.isFollowLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: isFollowed ? cWhite : cBlack,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isFollowed ? LKeys.unFollow.tr : LKeys.follow.tr,
                                    style: MyTextStyle.gilroyBold(color: isFollowed ? cLightText : cBlack),
                                  ),
                            Opacity(
                              opacity: 0,
                              child: Text(
                                LKeys.unFollow.tr,
                                style: MyTextStyle.gilroyBold(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget profileMenu(ProfileController controller) {
    return Menu(items: [
      PopupMenuItem(
        onTap: controller.shareProfile,
        textStyle: MyTextStyle.gilroyMedium(),
        child: Text(LKeys.share.tr),
      ),
      PopupMenuItem(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 1), () {
            Get.bottomSheet(ReportSheet(user: controller.user), isScrollControlled: true);
          });
        },
        textStyle: MyTextStyle.gilroyMedium(),
        child: Text(LKeys.report.tr),
      ),
      PopupMenuItem(
        textStyle: MyTextStyle.gilroyMedium(),
        child: Text(controller.user?.isBlockedByMe() ?? false ? LKeys.unBlock.tr : LKeys.block.tr),
        onTap: controller.blockUnblock,
      ),
      if (SessionManager.shared.getUserID() != controller.user?.id && SessionManager.shared.getUser()?.isModerator == 1 && controller.user?.isBlock == 0)
        PopupMenuItem(
          textStyle: MyTextStyle.gilroyMedium(),
          child: Text(LKeys.blockGlobally.tr),
          onTap: controller.blockByModerator,
        )
    ]);
  }
}
