import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import Lomiri.Content 1.1
import QtMultimedia 5.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

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
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
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
            onClicked: pageLayout.pushToCurrent(medialikerspage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: user_id})
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
