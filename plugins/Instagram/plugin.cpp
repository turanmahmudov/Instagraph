#include <QtQml/QQmlContext>
#include <QtQml>

#include "plugin.h"
#include "src/api/Instagram.h"
#include "src/media/MediaCache.h"
#include "src/models/ActivityListModel.h"
#include "src/models/CommentListModel.h"
#include "src/models/DirectInboxModel.h"
#include "src/models/DirectThreadModel.h"
#include "src/models/ExploreGridModel.h"
#include "src/models/MediaFeedModel.h"
#include "src/models/RecipientListModel.h"
#include "src/models/ReelTrayModel.h"
#include "src/models/SearchResultModel.h"
#include "src/models/TimelineFeedModel.h"
#include "src/models/UserListModel.h"

void InstagramPlugin::registerTypes(const char * uri) {
    // @uri Instagram

    // Register Instagram as a creatable type
    // Usage in QML: Instagram { id: instagram }
    qmlRegisterType<Instagram>(uri, 1, 0, "Instagram");
    qmlRegisterType<MediaCache>(uri, 1, 0, "MediaCache");
    qmlRegisterUncreatableType<JsonListModel>(uri, 1, 0, "JsonListModel",
                                              "JsonListModel is a base class");
    qmlRegisterType<ActivityListModel>(uri, 1, 0, "ActivityListModel");
    qmlRegisterType<CommentListModel>(uri, 1, 0, "CommentListModel");
    qmlRegisterType<DirectInboxModel>(uri, 1, 0, "DirectInboxModel");
    qmlRegisterType<DirectThreadModel>(uri, 1, 0, "DirectThreadModel");
    qmlRegisterType<ExploreGridModel>(uri, 1, 0, "ExploreGridModel");
    qmlRegisterType<MediaFeedModel>(uri, 1, 0, "MediaFeedModel");
    qmlRegisterType<RecipientListModel>(uri, 1, 0, "RecipientListModel");
    qmlRegisterType<ReelTrayModel>(uri, 1, 0, "ReelTrayModel");
    qmlRegisterType<SearchResultModel>(uri, 1, 0, "SearchResultModel");
    qmlRegisterType<TimelineFeedModel>(uri, 1, 0, "TimelineFeedModel");
    qmlRegisterType<UserListModel>(uri, 1, 0, "UserListModel");

    // Alternatively, register as singleton (only one instance):
    // qmlRegisterSingletonType<Instagram>(uri, 1, 0, "Instagram",
    //     [](QQmlEngine*, QJSEngine*) -> QObject* { return new Instagram; });
}
