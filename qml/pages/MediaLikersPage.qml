// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.1

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: medialikerspage

    property var photoId

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeaderItem {
        title: i18n.tr("Likes")
    }

    function mediaLikersDataFinished(data) {
        mediaLikersModel.clear()

        worker.sendMessage({'feed': 'MediaLikersPage', 'obj': data.users, 'model': mediaLikersModel, 'clear_model': clear_models})

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/SimpleWorker.js"
        onMessage: {
        }
    }

    Component.onCompleted: {
        getMediaLikes();
    }

    function getMediaLikes(next_id)
    {
        clear_models = false
        if (!next_id) {
            mediaLikersModel.clear()
            clear_models = true
        }
        instagram.getMediaLikers(photoId);
    }

    ListModel {
        id: mediaLikersModel
    }

    UsersListView {
        id: mediaLikersList
        model: mediaLikersModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(medialikerspage, PagesConstants.user, {usernameId: user_id})
        }
        PullToRefresh {
            refreshing: list_loading && mediaLikersModel.count == 0
            onRefresh: {
                list_loading = true
                getMediaLikes()
            }
        }
    }

    Connections{
        target: instagram
        onMediaLikersDataReady: {
            var data = JSON.parse(answer);
            mediaLikersDataFinished(data);
        }
    }
}
