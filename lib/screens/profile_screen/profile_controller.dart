import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/common/api_service/moderator_service.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/functions.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/screens/feed_screen/feed_screen_controller.dart';
import 'package:untitled/utilities/const.dart';
import 'package:untitled/utilities/params.dart';

import '../sheets/confirmation_sheet.dart';

class ProfileController extends FeedScreenController {
  User? user;
  final int userID;
  String followBtnID = "follow_btn";

  double maxExtent = 250.0;
  double currentExtent = 250.0;
  bool isFollowLoading = false;
  final bool isFromTabBar;
  final idForImage = '${DateTime.now().microsecondsSinceEpoch}';

  // ScrollController newScrollController = ScrollController();

  ProfileController(this.userID, this.isFromTabBar);

  void updateEverything() {
    update([scrollID]);
    update();
  }

  void updateMyProfile() {
    if (user?.id == SessionManager.shared.getUserID()) {
      user = SessionManager.shared.getUser();
      update();
      update([scrollID]);
    }
  }

  void getStories() {
    UserService.shared.fetchProfile(userID, (user) {
      this.user = user;

      if (user.id == SessionManager.shared.getUserID()) {
        SessionManager.shared.setUser(user);
      }
      update();
      update([scrollID]);
    });
  }

  Future<void> getProfile({bool isForRefresh = false}) async {
    if (!isForRefresh) {
      startLoading();
    }
    await UserService.shared.fetchProfile(userID, (user) {
      this.user = user;

      if (user.id == SessionManager.shared.getUserID()) {
        SessionManager.shared.setUser(user);
      }
      update();
      update([scrollID]);
      stopLoading();
    });
  }

  @override
  void onReady() {
    super.onReady();
    user = User(id: userID);
    getProfile();
    if (!(user?.isBlockedByMe() ?? false)) {
      fetchUserPosts(userID);
    }
    scrollController?.addListener(() {
      currentExtent = maxExtent - scrollController!.offset;
      if (currentExtent < 0) currentExtent = 0.0;
      if (currentExtent > maxExtent) currentExtent = maxExtent;
      update([scrollID]);
    });
  }

  void refreshData() {
    getProfile(isForRefresh: true);
    if (!(user?.isBlockedByMe() ?? false)) {
      refreshPosts();
    }
  }

  void blockByModerator() {
    Future.delayed(const Duration(milliseconds: 1), () {
      Get.bottomSheet(ConfirmationSheet(
        desc: LKeys.blockUserGloballyByModeratorDesc,
        buttonTitle: LKeys.block,
        onTap: () {
          ModeratorService.shared.blockUser(
              userId: userId,
              completion: () {
                isFollowLoading = false;
                user?.followingStatus = 0;
                user?.followers = (user?.followers ?? 0) - 1;
                posts.clear();
                updateEverything();
                Get.back();
              });
        },
      ));
    });
  }

  void blockUnblock() {
    if (user?.isBlockedByMe() ?? false) {
      unblockUser(user, () {
        fetchUserPosts((user?.id ?? 0).toInt());
        updateEverything();
      });
    } else {
      blockUser(user, () {
        isFollowLoading = false;
        user?.followingStatus = 0;
        user?.followers = (user?.followers ?? 0) - 1;
        posts.clear();
        updateEverything();
      });
    }
  }

  @override
  void onClose() {
    Functions.changStatusBar(StatusBarStyle.white);
  }

  void followToggle() {
    if ((user?.followingStatus ?? 0) > 1) {
      unfollow();
    } else {
      follow();
    }
  }

  void follow() {
    isFollowLoading = true;
    update();
    UserService.shared.followUser(userId, () {
      isFollowLoading = false;
      user?.followingStatus = 2;
      user?.followers = (user?.followers ?? 0) + 1;
      update();
    });
  }

  void unfollow() {
    isFollowLoading = true;
    update();
    UserService.shared.unfollowUser(userId, () {
      isFollowLoading = false;
      user?.followingStatus = 0;
      user?.followers = (user?.followers ?? 0) - 1;
      update();
    });
  }

  void shareProfile() {
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      title: user?.fullName ?? '',
      imageUrl: user?.profile?.addBaseURL() ?? '',
      contentDescription: user?.username ?? '',
      publiclyIndex: true,
      locallyIndex: true,
    );
    BranchLinkProperties lp = BranchLinkProperties();
    lp.addControlParam(Param.userId, '$userID');
    if (GetPlatform.isIOS) {
      if (buo.imageUrl != '') {
        FlutterBranchSdk.showShareSheet(buo: buo, linkProperties: lp, messageText: '');
      } else {
        rootBundle.load(MyImages.appIcon).then((data) {
          FlutterBranchSdk.shareWithLPLinkMetadata(buo: buo, linkProperties: lp, icon: data.buffer.asUint8List(), title: user?.fullName ?? '');
        });
      }
    } else {
      FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp).then((value) {
        Share.share(value.result ?? '', subject: user?.fullName ?? '');
      });
    }
  }
}
