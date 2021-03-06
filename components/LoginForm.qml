import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import UQQ 1.0 as QQ
import "md5.js" as MD5

Item {
    id: loginForm

    Component.onCompleted: {
        QQ.Client.captchaChanged.connect(onCaptchaChanged);
        QQ.Client.errorChanged.connect(onErrorChanged);
    }

    Component.onDestruction: {
    }

    Column {
        anchors.centerIn: parent
        spacing: units.gu(1)

        Image {
            source: "../logo2.png"
        }

        Label {
            id: errMsg
            width: parent.width
            clip: true
            text: QQ.Client.getLoginInfo("errMsg");
            color: "red"
        }

        FormInput {
            id: username

            label: i18n.tr("用户名:")
            placeholderText: i18n.tr("QQ号码")
            KeyNavigation.tab: password
            focus: true
            onFocusChanged: {
                if (!focus && text.length > 0) {
                    QQ.Client.checkCode(text);
                }
            }
        }
        FormInput {
            id: password

            label: i18n.tr("密    码:")
            echoMode: TextInput.Password
            KeyNavigation.tab: captcha.visible ? captcha : username
            KeyNavigation.backtab: username
        }
        FormInput {
            id: captcha

            label: i18n.tr("验证码:")
            visible: false
            KeyNavigation.tab: username
            KeyNavigation.backtab: password
        }

        Rectangle {
            width: parent.width
            height: childrenRect.height
            color: "transparent"

            AnimatedImage {
                id: captchaImg
                anchors.left: parent.left
                height: loginButton.height
                visible: false
                cache: false
            }

            StatusPopover {
                id: statusPopover

                onTriggered: {
                    statusImg.source = source;
                    statusTxt.text = text;
                    statusPopover.status = status;
                }
            }

            UbuntuShape {
                id: statusButton
                anchors.right: loginButton.left
                anchors.rightMargin: units.gu(1.5)
                anchors.verticalCenter: loginButton.verticalCenter
                width: childrenRect.width
                height: loginButton.height - units.gu(1)
                color: "snow"
                enabled: !indicator.running

                Row {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: units.gu(0.5)
                    Image {
                        id: statusImg
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../res/status/imonline.png"
                    }
                    Label {
                        id: statusTxt
                        anchors.verticalCenter: parent.verticalCenter
                        text: "在线"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        statusPopover.caller = statusButton;
                        statusPopover.show();
                    }
                }
            }

            Button {
                id: loginButton
                anchors.right: parent.right
                text: i18n.tr("登录")
                enabled: !indicator.running

                onClicked: {
                    login(username.text, password.text, captcha.text, statusPopover.status);
                }
            }
            ActivityIndicator {
                id: indicator
                anchors.centerIn: loginButton
            }
        }
    }

    function onCaptchaChanged(needed) {
        captchaImg.source = "";
        captcha.text = "";
        if (needed) {
            captcha.visible = true;
            captchaImg.visible = true;
            captchaImg.source = "../" + QQ.Client.getLoginInfo("captcha");
        } else {
            captcha.visible = false;
            captchaImg.visible = false;
        }
    }

    function onErrorChanged(errCode) {

        if (errCode === 0) {
            errMsg.text = " ";
        } else {
            errMsg.text = QQ.Client.getLoginInfo("errMsg");
            indicator.running = false;
        }
    }

    function login(uin, password, vc, status) {
        var pwdMd5;

        if (uin.length === 0 || password.length === 0) {
            errMsg.text = i18n.tr("请正确输入QQ帐号和密码!");
            return;
        }
        if (captcha.visible && vc.length < 4) {
            errMsg.text = i18n.tr("请正确输入验证码!");
            return;
        }

        if (!captcha.visible) {
            vc = QQ.Client.getLoginInfo("vc");
        }
        eval("var uinHex = '" + QQ.Client.getLoginInfo("uinHex") + "'");
        //console.log("qmllogin: " + QQ.Client.getLoginInfo("uinHex") + ", " + password + ", " + vc);
        pwdMd5 = MD5.pwdMd5(uinHex, password, vc);

        indicator.running = true;
        QQ.Client.login(uin, pwdMd5, vc, status);
    }
}
