class SettingModel {
  SettingModel({
    this.status,
    this.message,
    this.data,
  });

  SettingModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Settings.fromJson(json['data']) : null;
  }

  bool? status;
  String? message;
  Settings? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Settings {
  Settings({
    this.id,
    this.appName,
    this.setRoomUsersLimit,
    this.minuteLimitInCreatingStory,
    this.minuteLimitInAudioPost,
    this.minuteLimitInChoosingVideoForStory,
    this.minuteLimitInChoosingVideoForPost,
    this.maxImagesCanBeUploadedInOnePost,
    this.adBannerAndroid,
    this.adInterstitialAndroid,
    this.adBannerIOS,
    this.adInterstitialIOS,
    this.isAdmobOn,
    this.audioSpaceHostsLimit,
    this.audioSpaceListenersLimit,
    this.audioSpaceDurationInMinutes,
    this.isSightEngineEnabled,
    this.sightEngineApiUser,
    this.sightEngineApiSecret,
    this.sightEngineImageWorkflowId,
    this.sightEngineVideoWorkflowId,
    this.storageType,
    this.fetchPostType,
    this.supportEmail,
    this.createdAt,
    this.updatedAt,
    this.interests,
    this.documentType,
    this.reportReasons,
    this.restrictedUsernames,
  });

  Settings.fromJson(dynamic json) {
    id = json['id'];
    appName = json['app_name'];
    setRoomUsersLimit = json['setRoomUsersLimit'];
    minuteLimitInCreatingStory = json['minute_limit_in_creating_story'];
    minuteLimitInAudioPost = json['minute_limit_in_audio_post'];
    minuteLimitInChoosingVideoForStory = json['minute_limit_in_choosing_video_for_story'];
    minuteLimitInChoosingVideoForPost = json['minute_limit_in_choosing_video_for_post'];
    maxImagesCanBeUploadedInOnePost = json['max_images_can_be_uploaded_in_one_post'];
    adBannerAndroid = json['ad_banner_android'];
    adInterstitialAndroid = json['ad_interstitial_android'];
    adBannerIOS = json['ad_banner_iOS'];
    adInterstitialIOS = json['ad_interstitial_iOS'];
    isAdmobOn = json['is_admob_on'];
    audioSpaceHostsLimit = json['audio_space_hosts_limit'];
    audioSpaceListenersLimit = json['audio_space_listeners_limit'];
    audioSpaceDurationInMinutes = json['audio_space_duration_in_minutes'];
    isSightEngineEnabled = json['is_sight_engine_enabled'];
    sightEngineApiUser = json['sight_engine_api_user'];
    sightEngineApiSecret = json['sight_engine_api_secret'];
    sightEngineImageWorkflowId = json['sight_engine_image_workflow_id'];
    sightEngineVideoWorkflowId = json['sight_engine_video_workflow_id'];
    storageType = json['storage_type'];
    fetchPostType = json['fetch_post_type'];
    supportEmail = json['support_email'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['interests'] != null) {
      interests = [];
      json['interests'].forEach((v) {
        interests?.add(Interest.fromJson(v));
      });
    }
    if (json['documentType'] != null) {
      documentType = [];
      json['documentType'].forEach((v) {
        documentType?.add(DocumentType.fromJson(v));
      });
    }
    if (json['reportReasons'] != null) {
      reportReasons = [];
      json['reportReasons'].forEach((v) {
        reportReasons?.add(ReportReasons.fromJson(v));
      });
    }
    if (json['restrictedUsernames'] != null) {
      restrictedUsernames = [];
      json['restrictedUsernames'].forEach((v) {
        restrictedUsernames?.add(RestrictedUsernames.fromJson(v));
      });
    }
  }

  num? id;
  String? appName;
  num? setRoomUsersLimit;
  num? minuteLimitInCreatingStory;
  num? minuteLimitInAudioPost;
  num? minuteLimitInChoosingVideoForStory;
  num? minuteLimitInChoosingVideoForPost;
  num? maxImagesCanBeUploadedInOnePost;
  String? adBannerAndroid;
  String? adInterstitialAndroid;
  String? adBannerIOS;
  String? adInterstitialIOS;
  num? isAdmobOn;
  num? audioSpaceHostsLimit;
  num? audioSpaceListenersLimit;
  num? audioSpaceDurationInMinutes;
  num? isSightEngineEnabled;
  String? sightEngineApiUser;
  String? sightEngineApiSecret;
  String? sightEngineImageWorkflowId;
  String? sightEngineVideoWorkflowId;
  num? storageType;
  num? fetchPostType;
  String? supportEmail;
  String? createdAt;
  String? updatedAt;
  List<Interest>? interests;
  List<DocumentType>? documentType;
  List<ReportReasons>? reportReasons;
  List<RestrictedUsernames>? restrictedUsernames;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['app_name'] = appName;
    map['setRoomUsersLimit'] = setRoomUsersLimit;
    map['minute_limit_in_creating_story'] = minuteLimitInCreatingStory;
    map['minute_limit_in_audio_post'] = minuteLimitInAudioPost;
    map['minute_limit_in_choosing_video_for_story'] = minuteLimitInChoosingVideoForStory;
    map['minute_limit_in_choosing_video_for_post'] = minuteLimitInChoosingVideoForPost;
    map['max_images_can_be_uploaded_in_one_post'] = maxImagesCanBeUploadedInOnePost;
    map['ad_banner_android'] = adBannerAndroid;
    map['ad_interstitial_android'] = adInterstitialAndroid;
    map['ad_banner_iOS'] = adBannerIOS;
    map['ad_interstitial_iOS'] = adInterstitialIOS;
    map['is_admob_on'] = isAdmobOn;
    map['audio_space_hosts_limit'] = audioSpaceHostsLimit;
    map['audio_space_listeners_limit'] = audioSpaceListenersLimit;
    map['audio_space_duration_in_minutes'] = audioSpaceDurationInMinutes;
    map['is_sight_engine_enabled'] = isSightEngineEnabled;
    map['sight_engine_api_user'] = sightEngineApiUser;
    map['sight_engine_api_secret'] = sightEngineApiSecret;
    map['sight_engine_image_workflow_id'] = sightEngineImageWorkflowId;
    map['sight_engine_video_workflow_id'] = sightEngineVideoWorkflowId;
    map['storage_type'] = storageType;
    map['fetch_post_type'] = fetchPostType;
    map['support_email'] = supportEmail;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (interests != null) {
      map['interests'] = interests?.map((v) => v.toJson()).toList();
    }
    if (documentType != null) {
      map['documentType'] = documentType?.map((v) => v.toJson()).toList();
    }
    if (reportReasons != null) {
      map['reportReasons'] = reportReasons?.map((v) => v.toJson()).toList();
    }
    if (restrictedUsernames != null) {
      map['restrictedUsernames'] = restrictedUsernames?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class RestrictedUsernames {
  RestrictedUsernames({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  RestrictedUsernames.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? title;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class ReportReasons {
  ReportReasons({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  ReportReasons.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? title;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class DocumentType {
  DocumentType({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  DocumentType.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? title;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Interest {
  Interest({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.totalRoomOfInterest,
  });

  Interest.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalRoomOfInterest = json['totalRoomOfInterest'];
  }

  num? id;
  String? title;
  String? createdAt;
  String? updatedAt;
  num? totalRoomOfInterest;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['totalRoomOfInterest'] = totalRoomOfInterest;
    return map;
  }
}
