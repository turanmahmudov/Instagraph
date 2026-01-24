TEMPLATE = app
TARGET = Instagraph

load(ubuntu-click)

QT += qml quick widgets

# OpenSSL for password encryption
LIBS += -lssl -lcrypto

UBUNTU_TRANSLATION_DOMAIN="instagraph-devs.turan-mahmudov-l"

# New refactored Instagram API architecture
SOURCES += \
    src/instagram/utils/Constants.cpp \
    src/instagram/errors/ClientError.cpp \
    src/instagram/errors/ErrorHandler.cpp \
    src/instagram/session/SessionManager.cpp \
    src/instagram/network/CookieManager.cpp \
    src/instagram/network/SignatureGenerator.cpp \
    src/instagram/core/Request.cpp \
    src/instagram/core/Response.cpp \
    src/instagram/core/ApiClient.cpp \
    src/instagram/endpoints/AccountEndpoint.cpp \
    src/instagram/endpoints/MediaEndpoint.cpp \
    src/instagram/endpoints/DirectEndpoint.cpp \
    src/instagram/endpoints/FeedEndpoint.cpp \
    src/instagram/endpoints/PeopleEndpoint.cpp \
    src/instagram/endpoints/StoryEndpoint.cpp \
    src/instagram/endpoints/HashtagEndpoint.cpp \
    src/instagram/endpoints/LocationEndpoint.cpp \
    src/instagram/endpoints/SearchEndpoint.cpp \
    src/instagram/endpoints/UsertagEndpoint.cpp \
    src/instagram/endpoints/UploadEndpoint.cpp \
    src/instagram/services/ImageService.cpp \
    src/instagram/crypto/PasswordEncryptor.cpp \
    src/instagram/api/Instagram.cpp

HEADERS += \
    src/instagram/utils/Constants.h \
    src/instagram/errors/ClientError.h \
    src/instagram/errors/ErrorHandler.h \
    src/instagram/session/SessionManager.h \
    src/instagram/network/CookieManager.h \
    src/instagram/network/SignatureGenerator.h \
    src/instagram/core/Request.h \
    src/instagram/core/Response.h \
    src/instagram/core/ApiClient.h \
    src/instagram/endpoints/AccountEndpoint.h \
    src/instagram/endpoints/MediaEndpoint.h \
    src/instagram/endpoints/DirectEndpoint.h \
    src/instagram/endpoints/FeedEndpoint.h \
    src/instagram/endpoints/PeopleEndpoint.h \
    src/instagram/endpoints/StoryEndpoint.h \
    src/instagram/endpoints/HashtagEndpoint.h \
    src/instagram/endpoints/LocationEndpoint.h \
    src/instagram/endpoints/SearchEndpoint.h \
    src/instagram/endpoints/UsertagEndpoint.h \
    src/instagram/endpoints/UploadEndpoint.h \
    src/instagram/services/ImageService.h \
    src/instagram/crypto/PasswordEncryptor.h \
    src/instagram/api/Instagram.h

SOURCES += main.cpp \
    src/imageprocessor.cpp \
    src/offscreenrenderer.cpp \
    src/cropimageprovider.cpp \
    src/cacheimage.cpp

HEADERS += \
    src/imageprocessor.h \
    src/offscreenrenderer.h \
    src/cropimageprovider.h \
    src/cacheimage.h

RESOURCES += Instagraph.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  Instagraph.apparmor \
               Instagraph.dispatcher \
               Instagraph.png

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)

#show all the files in QtCreator
OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               Instagraph.desktop \
               Instagraph.dispatcher

#specify where the config files are installed to
config_files.path = /Instagraph
config_files.files += $${CONF_FILES}
INSTALLS+=config_files

#install the desktop file, a translated version is
#automatically created in the build directory
desktop_file.path = /Instagraph
desktop_file.files = $$OUT_PWD/Instagraph.desktop
desktop_file.CONFIG += no_check_exist
INSTALLS+=desktop_file

# Default rules for deployment.
#target.path = /opt/$${TARGET}/bin
target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS+=target

DISTFILES += \
    qml/components/ActionLineIconDelegate.qml \
    qml/components/ErrorPopup.qml \
    qml/components/LineIcon.qml \
    qml/components/LoadingSpinner.qml \
    qml/components/MultiUserSelector.qml \
    qml/components/MultipleAccountsSwitcher.qml \
    qml/components/PageHeaderItem.qml \
    qml/components/PageItem.qml \
    qml/components/UserDataColumn.qml \
    qml/components/UserHighlightsTray.qml \
    qml/components/UserRowSlot.qml \
    qml/fonts/Fonts.qml \
    qml/fonts/LineIcons.ttf \
    qml/fonts/qmldir \
    qml/js/DiscoverWorker.js \
    qml/js/Storage.js \
    qml/js/TimelineWorker.js \
    qml/ui/ActivityPage.qml \
    qml/ui/HighlightStoriesPage.qml \
    qml/ui/LoginPage.qml \
    qml/components/BouncingProgressBar.qml \
    qml/ui/HomePage.qml \
    qml/js/Helper.js \
    qml/ui/SearchPage.qml \
    qml/ui/UserPage.qml \
    qml/ui/CameraPage.qml \
    qml/components/ListFeedDelegate.qml \
    qml/components/UserListFeedDelegate.qml \
    qml/ui/TagFeedPage.qml \
    qml/js/Scripts.js \
    qml/ui/DirectInboxPage.qml \
    qml/ui/CameraEditPage.qml \
    qml/ui/CommentsPage.qml \
    qml/components/BottomMenu.qml \
    qml/ui/CameraCaptionPage.qml \
    qml/components/FollowComponent.qml \
    qml/ui/OtherUserPage.qml \
    qml/ui/SinglePhoto.qml \
    qml/ui/MediaLikersPage.qml \
    qml/ui/EditProfilePage.qml \
    qml/ui/OptionsPage.qml \
    qml/ui/About.qml \
    qml/ui/Credits.qml \
    qml/ui/DirectThreadPage.qml \
    qml/ui/ChangePasswordPage.qml \
    qml/ui/DiscoverPeoplePage.qml \
    qml/ui/RegisterPage.qml \
    qml/js/ActivityWorker.js \
    qml/js/SimpleWorker.js \
    Instagraph.dispatcher \
    qml/ui/UserFollowings.qml \
    qml/ui/UserFollowers.qml \
    qml/ui/CameraCropPage.qml \
    qml/ui/EditMediaPage.qml \
    qml/components/FiltersView.qml \
    qml/filters/FiltersList.qml \
    qml/filters/effects/WebkitCssFilter.qml \
    qml/filters/Clarendon.qml \
    qml/components/FilterBase.qml \
    qml/filters/Aden.qml \
    qml/filters/Brooklyn.qml \
    qml/filters/EarlyBird.qml \
    qml/filters/Filter1977.qml \
    qml/filters/Gingham.qml \
    qml/filters/Hudson.qml \
    qml/filters/Inkwell.qml \
    qml/filters/Lark.qml \
    qml/filters/Lofi.qml \
    qml/filters/Moon.qml \
    qml/filters/Nashville.qml \
    qml/filters/NoFilter.qml \
    qml/filters/Perpetua.qml \
    qml/filters/Reyes.qml \
    qml/filters/Rise.qml \
    qml/filters/Slumber.qml \
    qml/filters/Toaster.qml \
    qml/filters/Walden.qml \
    qml/filters/XPro2.qml \
    qml/components/ImageProcessorOutput.qml \
    qml/components/ImageContainer.qml \
    qml/components/BasicFilters.qml \
    qml/components/ClarityFilter.qml \
    qml/components/OtherActionsView.qml \
    qml/effects/EffectsList.qml \
    qml/components/OtherActionDelegate.qml \
    qml/components/SliderStyle.qml \
    qml/components/Slider.qml \
    qml/components/sliderUtils.js \
    qml/filters/VscoC1.qml \
    qml/components/FunctionSelector.qml \
    qml/components/CameraToolButton.qml \
    qml/components/CameraCaptureButton.qml \
    qml/ui/ImportPhotoPage.qml \
    qml/ui/SearchLocation.qml \
    qml/ui/LocationFeedPage.qml \
    qml/components/ClaritySettingsPanel.qml \
    qml/components/EmptyBox.qml \
    qml/ui/LikedMediaPage.qml \
    qml/ui/CheckpointInfo.qml \
    qml/components/FloatingActionButton.qml \
    qml/ui/SuggestionsPage.qml \
    qml/ui/ShareMediaPage.qml \
    qml/components/ContentDownloadDialog.qml \
    qml/components/FeedImage.qml \
    qml/components/Helpers/UriHandlerHelper.qml \
    qml/components/Style/Style.qml \
    qml/components/Style/StyleDark.qml \
    qml/components/Style/StyleLight.qml
