import 'dart:async';
import 'dart:math';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:untitled/common/api_service/moderator_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/library/add_to_cart/add_to_cart_animation.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/story.dart';
import 'package:untitled/screens/sheets/confirmation_sheet.dart';
import 'package:untitled/utilities/const.dart';

import '../../../screens/chats_screen/chatting_screen/chatting_controller.dart';
import '../controller/story_controller.dart';
import '../utils.dart';
import 'story_image.dart';
import 'story_video.dart';

/// Indicates where the progress indicators should be placed.
enum ProgressPosition { top, bottom, none }

/// This is used to specify the height of the progress indicator. Inline stories
/// should use [small]
enum IndicatorHeight { small, large }

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  final num id;
  final List<String> viewedByUsersIds;

  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  /// The page content
  final Widget view;
  final Story? story;

  StoryItem(
    this.view, {
    required this.id,
    required this.viewedByUsersIds,
    required this.duration,
    required this.story,
    this.shown = false,
  });

  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem text({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    Duration? duration,
    Story? story,
    num id = 0,
    List<String> viewedByUsersIds = const [],
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.r,
      backgroundColor.g,
      backgroundColor.b,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
        Container(
          key: key,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(roundedTop ? 8 : 0),
              bottom: Radius.circular(roundedBottom ? 8 : 0),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Center(
            child: Text(
              title,
              style: textStyle?.copyWith(
                    color: contrast > 1.8 ? Colors.white : Colors.black,
                  ) ??
                  TextStyle(
                    color: contrast > 1.8 ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          //color: backgroundColor,
        ),
        shown: shown,
        duration: duration ?? const Duration(seconds: 3),
        viewedByUsersIds: viewedByUsersIds,
        id: id,
        story: story);
  }

  /// Factory constructor for page images. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageImage({
    required String url,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    Duration? duration,
    num id = 0,
    Story? story,
    List<String> viewedByUsersIds = const [],
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              StoryImage.url(
                url,
                controller: controller,
                fit: imageFit,
                requestHeaders: requestHeaders,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 24,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    color: caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        viewedByUsersIds: viewedByUsersIds,
        duration: duration ?? const Duration(seconds: 3),
        id: id,
        story: story);
  }

  /// Shorthand for creating inline image. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.inlineImage({required String url, Text? caption, required StoryController controller, Key? key, BoxFit imageFit = BoxFit.cover, Map<String, dynamic>? requestHeaders, bool shown = false, bool roundedTop = true, bool roundedBottom = false, Duration? duration, num id = 0, List<String> viewedByUsersIds = const [], Story? story}) {
    return StoryItem(
        ClipSmoothRect(
          radius: SmoothBorderRadius.vertical(top: SmoothRadius(cornerRadius: roundedTop ? 8 : 0, cornerSmoothing: cornerSmoothing), bottom: SmoothRadius(cornerRadius: roundedBottom ? 8 : 0, cornerSmoothing: cornerSmoothing)),
          key: key,
          child: Container(
            color: Colors.grey[100],
            child: Container(
              color: Colors.black,
              child: Stack(
                children: <Widget>[
                  StoryImage.url(
                    url,
                    controller: controller,
                    fit: imageFit,
                    requestHeaders: requestHeaders,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        width: double.infinity,
                        child: caption ?? const SizedBox(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        shown: shown,
        viewedByUsersIds: viewedByUsersIds,
        duration: duration ?? const Duration(seconds: 3),
        id: id,
        story: story);
  }

  /// Shorthand for creating page video. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageVideo(
    String url, {
    required StoryController controller,
    Key? key,
    Duration? duration,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    num id = 0,
    Story? story,
    List<String> viewedByUsersIds = const [],
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              StoryVideo.url(
                url,
                controller: controller,
                requestHeaders: requestHeaders,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color: caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        viewedByUsersIds: viewedByUsersIds,
        duration: duration ?? const Duration(seconds: 10),
        id: id,
        story: story);
  }

  /// Shorthand for creating a story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.pageProviderImage(
    ImageProvider image, {
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Duration? duration,
    num id = 0,
    Story? story,
    List<String> viewedByUsersIds = const [],
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: Image(
                  image: image,
                  height: double.infinity,
                  width: double.infinity,
                  fit: imageFit,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 24,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    color: caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        viewedByUsersIds: viewedByUsersIds,
        duration: duration ?? const Duration(seconds: 3),
        id: id,
        story: story);
  }

  /// Shorthand for creating an inline story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.inlineProviderImage(
    ImageProvider image, {
    Key? key,
    Text? caption,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
    Story? story,
    num id = 0,
    List<String> viewedByUsersIds = const [],
  }) {
    return StoryItem(
        Container(
          key: key,
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(roundedTop ? 8 : 0),
                bottom: Radius.circular(roundedBottom ? 8 : 0),
              ),
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
              )),
          child: Container(
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: double.infinity,
                child: caption ?? const SizedBox(),
              ),
            ),
          ),
        ),
        shown: shown,
        duration: duration ?? const Duration(seconds: 3),
        viewedByUsersIds: viewedByUsersIds,
        id: id,
        story: story);
  }
}

/// Widget to display stories just like Whatsapp and Instagram. Can also be used
/// inline/inside [ListView] or [Column] just like Google News app. Comes with
/// gestures to pause, forward and go to previous page.
class StoryView extends StatefulWidget {
  /// The pages to displayed.
  final List<StoryItem?> storyItems;

  /// Callback for when a full cycle of story is shown. This will be called
  /// each time the full story completes when [repeat] is set to `true`.
  final VoidCallback? onComplete;

  final VoidCallback? onBack;

  /// Callback for when a vertical swipe gesture is detected. If you do not
  /// want to listen to such event, do not provide it. For instance,
  /// for inline stories inside ListViews, it is preferable to not to
  /// provide this callback so as to enable scroll events on the list view.
  final Function(Direction?)? onVerticalSwipeComplete;

  /// Callback for when a story is currently being shown.
  final ValueChanged<StoryItem>? onStoryShow;

  /// Where the progress indicator should be placed.
  final ProgressPosition progressPosition;

  /// Should the story be repeated forever?
  final bool repeat;

  /// If you would like to display the story as full-page, then set this to
  /// `false`. But in case you would display this as part of a page (eg. in
  /// a [ListView] or [Column]) then set this to `true`.
  final bool inline;

  // Controls the playback of the stories
  final StoryController controller;

  // Indicator Color
  final Color indicatorColor;

  final Widget Function(StoryItem item)? overlayWidget;

  const StoryView({super.key, required this.storyItems, required this.controller, this.onComplete, this.onStoryShow, this.progressPosition = ProgressPosition.top, this.repeat = false, this.inline = false, this.onVerticalSwipeComplete, this.indicatorColor = Colors.white, this.onBack, this.overlayWidget});

  @override
  State<StatefulWidget> createState() {
    return StoryViewState();
  }
}

class StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  Timer? _nextDebouncer;

  StreamSubscription<PlaybackState>? _playbackSubscription;

  TextEditingController textEditingController = TextEditingController();
  FocusNode inputNode = FocusNode();

  VerticalDragInfo? verticalDragInfo;

  StoryItem? get _currentStory {
    return widget.storyItems.firstWhereOrNull((it) => !it!.shown);
  }

  Widget get _currentView {
    var item = widget.storyItems.firstWhereOrNull((it) => !it!.shown);
    item ??= widget.storyItems.last;
    return SafeArea(
      bottom: false,
      child: ClipSmoothRect(
        radius: const SmoothBorderRadius.all(SmoothRadius(cornerRadius: 8, cornerSmoothing: cornerSmoothing)),
        child: item?.view ?? Container(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // All pages after the first unshown page should have their shown value as
    // false
    final firstPage = widget.storyItems.firstWhereOrNull((it) => !it!.shown);
    if (firstPage == null) {
      for (var it2 in widget.storyItems) {
        it2!.shown = false;
      }
    } else {
      final lastShownPos = widget.storyItems.indexOf(firstPage);
      widget.storyItems.sublist(lastShownPos).forEach((it) {
        it!.shown = false;
      });
    }

    _playbackSubscription = widget.controller.playbackNotifier.listen((playbackStatus) {
      switch (playbackStatus) {
        case PlaybackState.play:
          _removeNextHold();
          _animationController?.forward();
          break;

        case PlaybackState.pause:
          _holdNext(); // then pause animation
          _animationController?.stop(canceled: false);
          break;

        case PlaybackState.next:
          _removeNextHold();
          _goForward();
          break;

        case PlaybackState.previous:
          _removeNextHold();
          _goBack();
          break;
        case PlaybackState.playFromStart:
          // _goBack();
          break;
      }
    });

    _holdNext(); // then pause animation
    _animationController?.stop(canceled: false);

    _play();
  }

  @override
  void dispose() {
    _clearDebouncer();

    _animationController?.dispose();
    _playbackSubscription?.cancel();

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _play() {
    _animationController?.dispose();
    // get the next playing page
    final storyItem = widget.storyItems.firstWhere((it) {
      return !it!.shown;
    })!;

    if (widget.onStoryShow != null) {
      widget.onStoryShow!(storyItem);
    }

    _animationController = AnimationController(duration: storyItem.duration, vsync: this);
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        storyItem.shown = true;
        if (widget.storyItems.last != storyItem) {
          _beginPlay();
        } else {
          // done playing
          _onComplete();
        }
      }
    });

    _currentAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    widget.controller.play();
  }

  void _beginPlay() {
    setState(() {});
    widget.controller.playFromStart();
    _play();
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.controller.pause();
      widget.onComplete!();
    }

    if (widget.repeat) {
      for (var it in widget.storyItems) {
        it!.shown = false;
      }

      _beginPlay();
    }
  }

  void _goBack() {
    _animationController!.stop();

    if (_currentStory == null) {
      widget.storyItems.last!.shown = false;
    }

    if (_currentStory == widget.storyItems.first) {
      _beginPlay();
      if (widget.onBack != null) {
        widget.onBack!();
      }
    } else {
      _currentStory!.shown = false;
      int lastPos = widget.storyItems.indexOf(_currentStory);
      final previous = widget.storyItems[lastPos - 1]!;

      previous.shown = false;

      _beginPlay();
    }
  }

  void _goForward() {
    if (_currentStory != widget.storyItems.last) {
      _animationController!.stop();

      // get last showing
      final last = _currentStory;

      if (last != null) {
        last.shown = true;
        if (last != widget.storyItems.last) {
          _beginPlay();
        }
      }
    } else {
      // this is the last page, progress animation should skip to end
      _animationController!.animateTo(1.0, duration: const Duration(milliseconds: 10));
    }
  }

  void _clearDebouncer() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _removeNextHold() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _holdNext() {
    _nextDebouncer?.cancel();
    _nextDebouncer = Timer(const Duration(milliseconds: 500), () {});
  }

  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  double currentOpacity = 1;

  @override
  Widget build(BuildContext context) {
    var item = widget.storyItems.firstWhereOrNull((it) => !it!.shown);
    item ??= widget.storyItems.last;
    var isMyStory = item?.story?.user?.id == SessionManager.shared.getUserID();

    return AddToCartAnimation(
      opacity: 1,
      width: 3,
      height: 3,
      cartKey: cartKey,
      jumpAnimation: JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        // You can run the animation by addToCartAnimationMethod, just pass trough the the global key of  the image as parameter
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            KeyboardVisibilityBuilder(builder: (context, isKeyboardOn) {
              isKeyboardOn ? widget.controller.pause() : widget.controller.play();
              return Expanded(
                child: Stack(
                  children: <Widget>[
                    _currentView,
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [cBlack.withValues(alpha: 0.7), Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                    Visibility(
                      visible: widget.progressPosition != ProgressPosition.none,
                      child: Align(
                        alignment: widget.progressPosition == ProgressPosition.top ? Alignment.topCenter : Alignment.bottomCenter,
                        child: SafeArea(
                          bottom: widget.inline ? false : true,
                          // we use SafeArea here for notched and bezels phones
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: PageBar(
                                  widget.storyItems.map((it) => PageData(it!.duration, it.shown)).toList(),
                                  _currentAnimation,
                                  key: UniqueKey(),
                                  indicatorHeight: widget.inline ? IndicatorHeight.small : IndicatorHeight.large,
                                  indicatorColor: widget.indicatorColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        heightFactor: 1,
                        child: GestureDetector(
                          onTapDown: (details) {
                            widget.controller.pause();
                          },
                          onTapCancel: () {
                            widget.controller.play();
                          },
                          onTapUp: (details) {
                            // if debounce timed out (not active) then continue anim
                            if (_nextDebouncer?.isActive == false) {
                              widget.controller.play();
                            } else {
                              widget.controller.next();
                            }
                          },
                          onVerticalDragStart: widget.onVerticalSwipeComplete == null
                              ? null
                              : (details) {
                                  widget.controller.pause();
                                },
                          onVerticalDragCancel: widget.onVerticalSwipeComplete == null
                              ? null
                              : () {
                                  widget.controller.play();
                                },
                          onVerticalDragUpdate: widget.onVerticalSwipeComplete == null
                              ? null
                              : (details) {
                                  verticalDragInfo ??= VerticalDragInfo();

                                  verticalDragInfo!.update(details.primaryDelta!);

                                  // TODO: provide callback interface for animation purposes
                                },
                          onVerticalDragEnd: widget.onVerticalSwipeComplete == null
                              ? null
                              // ? (details) {
                              //     if (!verticalDragInfo!.cancel && widget.onVerticalSwipeComplete != null) {
                              //       widget.onVerticalSwipeComplete!(verticalDragInfo!.direction);
                              //     } else {
                              //       if (verticalDragInfo!.direction == Direction.up) {
                              //         print("Dragged Up");
                              //
                              //         FocusScope.of(context).requestFocus(inputNode);
                              //       }
                              //     }
                              //     // verticalDragInfo!.res();
                              //   }
                              : (details) {
                                  widget.controller.play();
                                  // finish up drag cycle
                                  if (!verticalDragInfo!.cancel && widget.onVerticalSwipeComplete != null) {
                                    widget.onVerticalSwipeComplete!(verticalDragInfo!.direction);
                                  }

                                  verticalDragInfo = null;
                                },
                        )),
                    Align(
                      alignment: Alignment.centerLeft,
                      heightFactor: 1,
                      child: SizedBox(
                          width: 70,
                          child: GestureDetector(onTap: () {
                            widget.controller.previous();
                          })),
                    ),
                    SafeArea(
                      child: widget.overlayWidget != null && item != null ? widget.overlayWidget!(item) : Container(),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8),
                        child: AddToCartIcon(
                          key: cartKey,
                          icon: Container(
                            width: 20,
                            height: 20,
                            color: Colors.transparent,
                          ),
                          badgeOptions: const BadgeOptions(
                            active: true,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isKeyboardOn,
                      child: GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Container(
                            color: Colors.black.withValues(alpha: isKeyboardOn ? 0.6 : 0),
                            alignment: Alignment.center,
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              primary: false,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                              ),
                              itemCount: storyQuickReplyEmojis.length,
                              itemBuilder: (BuildContext context, int index) {
                                final GlobalKey widgetKey = GlobalKey();
                                return GestureDetector(
                                  onTap: () async {
                                    // FocusManager.instance.primaryFocus?.unfocus();
                                    currentOpacity = 0;
                                    setState(() {});
                                    // await Future.delayed(Duration(milliseconds: 10));
                                    HapticFeedback.mediumImpact();
                                    await runAddToCartAnimation(widgetKey);
                                    currentOpacity = 1;
                                    // await cartKey.currentState!.runClearCartAnimation();
                                    sendReply(reply: storyQuickReplyEmojis[index], item: item, isEmoji: true);
                                  },
                                  child: AnimatedOpacity(
                                    opacity: currentOpacity,
                                    duration: Duration(milliseconds: 1500),
                                    child: Container(
                                        key: widgetKey,
                                        margin: EdgeInsets.all(10),
                                        alignment: Alignment.center,
                                        child: Text(
                                          storyQuickReplyEmojis[index],
                                          style: TextStyle(fontSize: 50),
                                        )),
                                  ),
                                );
                              },
                            )),
                      ),
                    ),
                  ],
                ),
              );
            }),
            SafeArea(
              top: false,
              child: !isMyStory
                  ? Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(15),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            decoration: ShapeDecoration(
                              shape: StadiumBorder(side: BorderSide(color: cWhite.withValues(alpha: 0.6), width: 1)),
                            ),
                            height: 40,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: TextField(
                              focusNode: inputNode,
                              controller: textEditingController,
                              style: MyTextStyle.gilroyMedium(color: cWhite),
                              cursorColor: cPrimary,
                              decoration: InputDecoration(
                                hintText: LKeys.writeHere.tr,
                                hintStyle: MyTextStyle.gilroyRegular(color: cLightText.withValues(alpha: 0.8)),
                                border: InputBorder.none,
                                counterText: '',
                                isDense: true,
                                contentPadding: const EdgeInsets.all(0),
                              ),
                              textInputAction: TextInputAction.send,
                              onChanged: (value) {
                                setState(() {});
                              },
                              onSubmitted: (value) {
                                sendReply(reply: value, item: item, isEmoji: false);
                              },
                            ),
                          ),
                        ),
                        if (textEditingController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              sendReply(reply: textEditingController.text, item: item, isEmoji: false);
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Image.asset(
                                MyImages.sendStory,
                                color: cWhite.withValues(alpha: 0.8),
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        if (SessionManager.shared.getUserID() != item?.story?.userId && SessionManager.shared.getUser()?.isModerator == 1)
                          GestureDetector(
                            onTap: () {
                              deleteStory(item: item);
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Icon(
                                CupertinoIcons.trash,
                                color: cRed,
                                size: 25,
                                // height: 30,
                                // width: 30,
                              ),
                            ),
                          )
                      ],
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }

  void sendReply({StoryItem? item, required String reply, required bool isEmoji}) {
    if (reply.isEmpty) return;
    var chattingController = ChattingController(user: item?.story?.user, shouldCallAPI: false);
    if (item?.story != null) {
      HapticFeedback.mediumImpact();
      chattingController.sendStoryReply(story: item!.story!, reply: reply);
      textEditingController.text = '';
      FocusManager.instance.primaryFocus?.unfocus();
      BaseController.share.materialSnackBar(LKeys.messageSent.tr);
      setState(() {});
    }
  }

  void deleteStory({StoryItem? item}) {
    widget.controller.pause();
    Get.bottomSheet(ConfirmationSheet(
        desc: LKeys.deleteStoryByModeratorDesc,
        buttonTitle: LKeys.delete,
        onTap: () {
          BaseController.share.startLoading();
          ModeratorService.shared.deleteStory(
              storyId: item?.story?.id?.toInt() ?? 0,
              completion: () {
                BaseController.share.stopLoading();
                Get.back();
              });
        })).then((value) {
      widget.controller.play();
    });
  }
}

/// Capsule holding the duration and shown property of each story. Passed down
/// to the pages bar to render the page indicators.
class PageData {
  Duration duration;
  bool shown;

  PageData(this.duration, this.shown);
}

/// Horizontal bar displaying a row of [StoryProgressIndicator] based on the
/// [pages] provided.
class PageBar extends StatefulWidget {
  final List<PageData> pages;
  final Animation<double>? animation;
  final IndicatorHeight indicatorHeight;
  final Color indicatorColor;

  const PageBar(
    this.pages,
    this.animation, {
    this.indicatorHeight = IndicatorHeight.large,
    this.indicatorColor = Colors.white,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageBarState();
  }
}

class PageBarState extends State<PageBar> {
  double spacing = 4;

  @override
  void initState() {
    super.initState();

    int count = widget.pages.length;
    spacing = (count > 15) ? 1 : ((count > 10) ? 2 : 4);

    widget.animation!.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isPlaying(PageData page) {
    return widget.pages.firstWhereOrNull((it) => !it.shown) == page;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.pages.map((it) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.only(right: widget.pages.last == it ? 0 : spacing),
            child: StoryProgressIndicator(
              isPlaying(it) ? widget.animation!.value : (it.shown ? 1 : 0),
              indicatorHeight: widget.indicatorHeight == IndicatorHeight.large ? 5 : 3,
              indicatorColor: widget.indicatorColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Custom progress bar. Supposed to be lighter than the
/// original [ProgressIndicator], and rounded at the sides.
class StoryProgressIndicator extends StatelessWidget {
  /// From `0.0` to `1.0`, determines the progress of the indicator
  final double value;
  final double indicatorHeight;
  final Color indicatorColor;

  const StoryProgressIndicator(
    this.value, {
    super.key,
    this.indicatorHeight = 5,
    this.indicatorColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(
        indicatorHeight,
      ),
      foregroundPainter: IndicatorOval(
        indicatorColor.withValues(alpha: 0.8),
        value,
      ),
      painter: IndicatorOval(
        indicatorColor.withValues(alpha: 0.4),
        1.0,
      ),
    );
  }
}

class IndicatorOval extends CustomPainter {
  final Color color;
  final double widthFactor;

  IndicatorOval(this.color, this.widthFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * widthFactor, size.height), const Radius.circular(3)), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Concept source: https://stackoverflow.com/a/9733420
class ContrastHelper {
  static double luminance(int? r, int? g, int? b) {
    final a = [r, g, b].map((it) {
      double value = it!.toDouble() / 255.0;
      return value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4);
    }).toList();

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  static double contrast(rgb1, rgb2) {
    return luminance(rgb2[0], rgb2[1], rgb2[2]) / luminance(rgb1[0], rgb1[1], rgb1[2]);
  }
}
