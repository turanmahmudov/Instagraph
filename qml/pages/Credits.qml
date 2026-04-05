import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Page"

PageItem {
    id: creditsPage

    header: PageHeaderItem {
        title: i18n.tr("Credits")
    }

    Flickable {
        id: flickable
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: creditsPage.header.bottom
        }
        contentHeight: columnSuperior.height

        Column {
            id: columnSuperior
            width: parent.width

            ListItem {
                height: prs1Layout.height
                ListItemLayout {
                    id: prs1Layout

                    title.text: "Turan Mahmudov (turanmahmudov)"
                    subtitle.text: i18n.tr("Creator")
                }
                onClicked: {
                    Qt.openUrlExternally("https://github.com/turanmahmudov/");
                }
            }

            ListItem {
                height: prs2Layout.height
                ListItemLayout {
                    id: prs2Layout

                    title.text: "Kevin Feyder (halfsail)"
                    subtitle.text: i18n.tr("Icon")
                }
                onClicked: {
                    Qt.openUrlExternally("https://github.com/halfsail");
                }
            }

            ListItem {
                height: prs3Layout.height
                ListItemLayout {
                    id: prs3Layout

                    title.text: "Rúben Carneiro (rubencarneiro)"
                    subtitle.text: i18n.tr("Focal Update")
                }
                onClicked: {
                    Qt.openUrlExternally("https://gitlab.com/rubencarneiro");
                }
            }

            ListItem {
                height: prs4Layout.height
                ListItemLayout {
                    id: prs4Layout

                    title.text: "Stefano Verzegnassi (sverzegnassi)"
                    subtitle.text: i18n.tr("Original InstantFX App - used for Instagram Filters")
                }
                onClicked: {
                    Qt.openUrlExternally("https://github.com/sverzegnassi");
                }
            }

            ListItem {
                height: prs5Layout.height
                ListItemLayout {
                    id: prs5Layout

                    title.text: "Chupligin Sergey (neochapay)"
                    subtitle.text: i18n.tr("Original QtInstagram Library - used for the Backend")
                }
                onClicked: {
                    Qt.openUrlExternally("https://github.com/neochapay");
                }
            }

            ListItem {
                height: allContributorsLayout.height
                divider.visible: false
                ListItemLayout {
                    id: allContributorsLayout

                    title.text: i18n.tr("All Contributors")
                    subtitle.text: i18n.tr("Thank you to all contributors!")
                }
                onClicked: {
                    Qt.openUrlExternally("https://github.com/turanmahmudov/Instagraph/graphs/contributors");
                }
            }
        }
    }
}
