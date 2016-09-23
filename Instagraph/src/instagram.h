#ifndef INSTAGRAM_H
#define INSTAGRAM_H

#include <QObject>
#include <QDir>
#include <QVariant>

class Instagram : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(QString photos_path READ photos_path NOTIFY photos_pathChanged)
public:
    explicit Instagram(QObject *parent = 0);

    bool busy() const;
    QString error() const;
    QString photos_path() const;

public slots:
    void login(bool forse = false);
    void logout();

    void setUsername(QString username){this->m_username = username;}
    void setPassword(QString password){this->m_password = password;}

    QString getUsernameId(){return this->m_username_id;}

    void postImage(QString path, QString caption, QVariantMap location, QString upload_id = "");
    void postVideo(QFile *video);

    void infoMedia(QString mediaId);
    void editMedia(QString mediaId, QString captionText = "");
    void deleteMedia(QString mediaId);
    void removeSelftag(QString mediaId);

    void postComment(QString mediaId, QString commentText);
    void deleteComment(QString mediaId, QString commentId);

    void setPrivateAccount();
    void setPublicAccount();
    void changeProfilePicture(QFile *photo);
    void removeProfilePicture();
    void getProfileData();
    void editProfile(QString url, QString phone, QString first_name, QString biography, QString email, bool gender);
    void getUsernameInfo(QString usernameId);

    void getRecentActivity();
    void getFollowingRecentActivity();

    void getUserTags(QString usernameId);
    void tagFeed(QString tag, QString max_id = "");
    void getTimeLine(QString max_id = "");
    void getUsernameFeed(QString usernameID, QString maxid = "", QString minTimestamp = "");
    void getPopularFeed(QString max_id = "");

    void getMediaLikers(QString mediaId);
    void getMediaComments(QString mediaId);

    void like(QString mediaId);
    void unLike(QString mediaId);

    void follow(QString userId);
    void unFollow(QString userId);
    void block(QString userId);
    void unBlock(QString userId);
    void userFriendship(QString userId);
    void getLikedMedia();

    void checkUsername(QString username);
    void createAccount(QString username, QString password, QString email);

    void searchUsername(QString username);

    void searchUsers(QString query);
    void searchTags(QString query);
    void searchFBLocation(QString query);
    void getLocationFeed(QString locationId, QString max_id = "");
    void searchLocation(QString latitude, QString longitude, QString query = "");

    void getv2Inbox();
    void directThread(QString threadId);
    void directMessage(QString recipients, QString text, QString thread_id = "0");

    void changePassword(QString oldPassword, QString newPassword);

    void explore(QString max_id = "");

    void getUserFollowings(QString usernameId, QString max_id = "");
    void getUserFollowers(QString usernameId, QString max_id = "");

    void rotateImg(QString filename, qreal deg);
    void squareImg(QString filename);
    void cropImg(QString filename, qreal propos);
    void scaleImg(QString filename);

private:
    QString EXPERIMENTS     = "ig_android_progressive_jpeg,ig_creation_growth_holdout,ig_android_report_and_hide,ig_android_new_browser,ig_android_enable_share_to_whatsapp,ig_android_direct_drawing_in_quick_cam_universe,ig_android_huawei_app_badging,ig_android_universe_video_production,ig_android_asus_app_badging,ig_android_direct_plus_button,ig_android_ads_heatmap_overlay_universe,ig_android_http_stack_experiment_2016,ig_android_infinite_scrolling,ig_fbns_blocked,ig_android_white_out_universe,ig_android_full_people_card_in_user_list,ig_android_post_auto_retry_v7_21,ig_fbns_push,ig_android_feed_pill,ig_android_profile_link_iab,ig_explore_v3_us_holdout,ig_android_histogram_reporter,ig_android_anrwatchdog,ig_android_search_client_matching,ig_android_high_res_upload_2,ig_android_new_browser_pre_kitkat,ig_android_2fac,ig_android_grid_video_icon,ig_android_white_camera_universe,ig_android_disable_chroma_subsampling,ig_android_share_spinner,ig_android_explore_people_feed_icon,ig_explore_v3_android_universe,ig_android_media_favorites,ig_android_nux_holdout,ig_android_search_null_state,ig_android_react_native_notification_setting,ig_android_ads_indicator_change_universe,ig_android_video_loading_behavior,ig_android_black_camera_tab,liger_instagram_android_univ,ig_explore_v3_internal,ig_android_direct_emoji_picker,ig_android_prefetch_explore_delay_time,ig_android_business_insights_qe,ig_android_direct_media_size,ig_android_enable_client_share,ig_android_promoted_posts,ig_android_app_badging_holdout,ig_android_ads_cta_universe,ig_android_mini_inbox_2,ig_android_feed_reshare_button_nux,ig_android_boomerang_feed_attribution,ig_android_fbinvite_qe,ig_fbns_shared,ig_android_direct_full_width_media,ig_android_hscroll_profile_chaining,ig_android_feed_unit_footer,ig_android_media_tighten_space,ig_android_private_follow_request,ig_android_inline_gallery_backoff_hours_universe,ig_android_direct_thread_ui_rewrite,ig_android_rendering_controls,ig_android_ads_full_width_cta_universe,ig_video_max_duration_qe_preuniverse,ig_android_prefetch_explore_expire_time,ig_timestamp_public_test,ig_android_profile,ig_android_dv2_consistent_http_realtime_response,ig_android_enable_share_to_messenger,ig_explore_v3,ig_ranking_following,ig_android_pending_request_search_bar,ig_android_feed_ufi_redesign,ig_android_video_pause_logging_fix,ig_android_default_folder_to_camera,ig_android_video_stitching_7_23,ig_android_profanity_filter,ig_android_business_profile_qe,ig_android_search,ig_android_boomerang_entry,ig_android_inline_gallery_universe,ig_android_ads_overlay_design_universe,ig_android_options_app_invite,ig_android_view_count_decouple_likes_universe,ig_android_periodic_analytics_upload_v2,ig_android_feed_unit_hscroll_auto_advance,ig_peek_profile_photo_universe,ig_android_ads_holdout_universe,ig_android_prefetch_explore,ig_android_direct_bubble_icon,ig_video_use_sve_universe,ig_android_inline_gallery_no_backoff_on_launch_universe,ig_android_image_cache_multi_queue,ig_android_camera_nux,ig_android_immersive_viewer,ig_android_dense_feed_unit_cards,ig_android_sqlite_dev,ig_android_exoplayer,ig_android_add_to_last_post,ig_android_direct_public_threads,ig_android_prefetch_venue_in_composer,ig_android_bigger_share_button,ig_android_dv2_realtime_private_share,ig_android_non_square_first,ig_android_video_interleaved_v2,ig_android_follow_search_bar,ig_android_last_edits,ig_android_video_download_logging,ig_android_ads_loop_count_universe,ig_android_swipeable_filters_blacklist,ig_android_boomerang_layout_white_out_universe,ig_android_ads_carousel_multi_row_universe,ig_android_mentions_invite_v2,ig_android_direct_mention_qe,ig_android_following_follower_social_context";

    QString m_username;
    QString m_password;
    QString m_debug;
    QString m_username_id;
    QString m_uuid;
    QString m_device_id;
    QString m_token;
    QString m_rank_token;
    QString m_IGDataPath;

    QString m_caption;
    QString m_image_path;

    QDir m_data_path;

    QDir m_photos_path;

    bool m_isLoggedIn = false;

    QString generateDeviceId();

    bool m_busy;
    QString m_error;

    QVariantMap lastUploadLocation;

signals:
    void profileConnected(QVariant answer);
    void profileConnectedFail();

    void mediaInfoReady(QVariant answer);
    void mediaEdited(QVariant answer);
    void mediaDeleted(QVariant answer);

    void imageConfigureDataReady(QVariant answer);

    void removeSelftagDone(QVariant answer);
    void commentPosted(QVariant answer);
    void commentDeleted(QVariant answer);

    void profilePictureDeleted(QVariant answer);
    void setProfilePrivate(QVariant answer);
    void setProfilePublic(QVariant answer);
    void profileDataReady(QVariant answer);
    void editDataReady(QVariant answer);
    void usernameDataReady(QVariant answer);

    void recentActivityDataReady(QVariant answer);
    void followingRecentDataReady(QVariant answer);

    void userTagsDataReady(QVariant answer);
    void tagFeedDataReady(QVariant answer);
    void timeLineDataReady(QVariant answer);
    void userTimeLineDataReady(QVariant answer);
    void popularFeedDataReady(QVariant answer);

    void mediaLikersDataReady(QVariant answer);
    void mediaCommentsDataReady(QVariant answer);
    void likeDataReady(QVariant answer);
    void unLikeDataReady(QVariant answer);

    void followDataReady(QVariant answer);
    void unFollowDataReady(QVariant answer);
    void blockDataReady(QVariant answer);
    void unBlockDataReady(QVariant answer);
    void userFriendshipDataReady(QVariant answer);
    void likedMediaDataReady(QVariant answer);

    void doLogout(QVariant answer);

    void usernameCheckDataReady(QVariant answer);
    void createAccountDataReady(QVariant answer);

    void error(QString message);

    void searchUsernameDataReady(QVariant answer);

    void searchUsersDataReady(QVariant answer);
    void searchTagsDataReady(QVariant answer);
    void searchFBLocationDataReady(QVariant answer);
    void getLocationFeedDataReady(QVariant answer);
    void searchLocationDataReady(QVariant answer);

    void v2InboxDataReady(QVariant answer);
    void directThreadReady(QVariant answer);
    void directMessageReady(QVariant answer);

    void changePasswordReady(QVariant answer);

    void exploreDataReady(QVariant answer);

    void userFollowingsDataReady(QVariant answer);
    void userFollowersDataReady(QVariant answer);

    void busyChanged();
    void errorChanged();
    void photos_pathChanged();

    void imgSquared();
    void imgRotated();
    void imgCropped();
    void imgScaled();

private slots:
    void setUser();
    void doLogin();
    void syncFeatures();
    void profileConnect(QVariant profile);
    void configurePhoto(QVariant answer);
};

#endif // INSTAGRAM_H
