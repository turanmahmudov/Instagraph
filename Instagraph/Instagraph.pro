TEMPLATE = app
TARGET = Instagraph

load(ubuntu-click)

QT += qml quick

UBUNTU_TRANSLATION_DOMAIN="instagraph-devs.turan-mahmudov-l"

SOURCES += main.cpp \
    src/instagram.cpp \
    src/instagramrequest.cpp \
    src/cripto/hmacsha.cpp \
    src/imageprocessor.cpp \
    src/offscreenrenderer.cpp \
    src/cropimageprovider.cpp \
    src/instagramcheckpoint.cpp \
    src/cacheimage.cpp

HEADERS += src/instagram.h \
    src/instagramrequest.h \
    src/cripto/hmacsha.h \
    src/imageprocessor.h \
    src/offscreenrenderer.h \
    src/cropimageprovider.h \
    src/instagramcheckpoint.h \
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

#target.path = $${UBUNTU_CLICK_BINARY_PATH}
#INSTALLS+=target

DISTFILES += \
    qml/js/Storage.js \
    qml/ui/LoginPage.qml \
    qml/components/BouncingProgressBar.qml \
    qml/ui/HomePage.qml \
    qml/js/Helper.js \
    qml/ui/NotifsPage.qml \
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
    qml/ui/Libraries.qml \
    qml/ui/DirectThreadPage.qml \
    qml/ui/ChangePasswordPage.qml \
    qml/ui/DiscoverPeoplePage.qml \
    qml/ui/RegisterPage.qml \
    qml/js/Worker.js \
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
    qml/components/FeedImage.qml

