import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/managers/ads/banner_ad.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/functions.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/screens/chats_screen/chats_screen.dart';
import 'package:untitled/screens/feed_screen/feed_screen.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/screens/random_screen/random_screen.dart';
import 'package:untitled/screens/rooms_screen/rooms_screen.dart';
import 'package:untitled/screens/tabbar/tabbar_controller.dart';
import 'package:untitled/utilities/const.dart';

class TabBarScreen extends StatelessWidget {
  TabBarScreen({Key? key}) : super(key: key);
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final TabBarController controller = Get.put(TabBarController());
    Functions.changStatusBar(StatusBarStyle.black);
    return Scaffold(
      backgroundColor: cWhite,
      body: GetBuilder<TabBarController>(
        builder: (controller) {
          return Column(
            children: [
              // TabBarView(
              //   children: screens,
              // ),
              Expanded(
                child: ProsteIndexedStack(
                  children: [
                    IndexedStackChild(child: FeedScreen(scrollController: scrollController)),
                    IndexedStackChild(child: RoomsScreen()),
                    IndexedStackChild(child: RandomScreen()),
                    IndexedStackChild(child: ChatsScreen()),
                    IndexedStackChild(child: ProfileScreen(isFromTabBar: true, userId: SessionManager.shared.getUserID())),
                  ],
                  index: controller.selectedTab,
                ),
              ),
              // Expanded(child: selectedWidget()),
              BannerAdView(),
              Container(
                color: cBlack,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      button(LKeys.feed, MyImages.quill, 0, controller),
                      button(LKeys.rooms, MyImages.meeting, 1, controller),
                      button(LKeys.randoms, MyImages.random, 2, controller),
                      button(LKeys.chats, MyImages.chat, 3, controller),
                      button(LKeys.profile, MyImages.profile, 4, controller),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        init: controller,
      ),
    );
  }

  Widget button(String title, String image, int index, TabBarController controller) {
    return GestureDetector(
      onTap: () {
        if (index == 0 && controller.selectedTab == 0) {
          HapticFeedback.mediumImpact();
          if (scrollController.offset == 0) {
            refreshIndicatorKey.currentState?.show();
          } else {
            scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.linear);
          }
        }
        controller.selectIndex(index);
      },
      child: Container(
        color: cBlack,
        width: Get.width / 5,
        child: TabBarButton(image: image, title: title, isSelected: controller.selectedTab == index),
      ),
    );
  }

  Widget selectedWidget(TabBarController controller) {
    switch (controller.selectedTab) {
      case 0:
        return FeedScreen(scrollController: scrollController);
      case 1:
        return RoomsScreen();
      case 2:
        return RandomScreen();
      case 3:
        return ChatsScreen();
      case 4:
        return ProfileScreen(
          isFromTabBar: true,
          userId: SessionManager.shared.getUserID(),
        );
    }
    return Container();
  }
}

class TabBarButton extends StatelessWidget {
  final String title;
  final String image;
  final bool isSelected;

  const TabBarButton({Key? key, required this.title, required this.image, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          image,
          width: 20,
          height: 20,
          color: isSelected ? cPrimary : cLightText,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          title.tr,
          style: MyTextStyle.gilroyRegular(
            size: 12,
            color: isSelected ? cPrimary : cLightText,
          ),
        ),
      ],
    );
  }
}
