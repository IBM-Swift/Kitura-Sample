/*
 Copyright IBM Corporation 2016

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/
(function() {

var formattedTime = function() {
    var date = new Date();
    var minutes = date.getMinutes();
    return date.getHours() + ':' + (minutes < 10 ? '0' : '') + minutes;
}

var displayMessage = function($scope, displayName, messageText) {
    messageText = messageText.replace(/\n/g, '<br>');


    var localUser = displayName == $scope.displayName;
    var borderSpace = localUser ? 0 : 4;

    var boxWidth = $('.messagesArea').width()
    if (boxWidth > 600) {
        boxWidth = 600;
    }

    var messageBox =
        '<div class="' + (localUser ? 'messagelocalUserBox' : 'messageRemoteUserBox') + '"' +
              ' style="width:' + (boxWidth-33-borderSpace) + 'px;"' + '>' +
          '<div>' +
            '<div class="messageDisplayName">' + displayName + '</div>' +
            '<div class="messageTime">' + formattedTime() + '</div>' +
          '</div>' +
          '<div class="messageText">' + messageText + '</div>' +
        '</div>';

    var initialsCircle =
        '<div class="messageCircle ' + (localUser ? 'localUserText' : 'remoteUserText') + '"' +
                   'style="' + (localUser ? 'margin-right: 3px;' : 'margin-left: 3px;' ) + '"' +
                   '>' + $scope.participantInitials[displayName] + '</div>'

    var initialsTriangle = '<div class="' + (localUser ? 'leftTriangle' : 'rightTriangle') + '"></div>';
    var rightOverlayTriangle = '<div class="rightOverlayTriangle"></div>';

    var snippet =
        '<div class="messageLine">' +
          (localUser ? (initialsCircle + initialsTriangle + messageBox) :
                            (messageBox + initialsTriangle + rightOverlayTriangle + initialsCircle)) +
        '</div>';

    var messagesArea = $('.messagesArea');
    messagesArea.html(messagesArea.html() + snippet);
    var children = messagesArea.children();
    children[children.length-1].scrollIntoView();
};

var addMessageParticipantLine = function($scope, displayName, joined) {
    var boxWidth = $('.messagesArea').width()
    if (boxWidth > 600) {
        boxWidth = 600;
    }

    var snippet =
            '<div class="messageParticipantLine"' +
                            ' style="width:' + boxWidth + 'px;">' +
              '<span style="font-weight: 500;">' + displayName + '</span>' +
              '<span style="margin-left: 5px;">has ' + (joined ? 'joined' : 'left') + ' the chat</span>' +
              '<div class="messageTime" style="margin-top: 0;">' + formattedTime() + '</div>' +
            '</div>';

    var messagesArea = $('.messagesArea');
    messagesArea.html(messagesArea.html() + snippet);
    var children = messagesArea.children();
    children[children.length-1].scrollIntoView();
}

var initials = function(name) {
    var parts = name.split(' ');
    var result;
    if (parts.length > 1) {
        result = parts[0].substring(0, 1) + parts[1].substring(0, 1);
    }
    else {
        result = parts[0].substring(0, 2);
    }
    return result.toUpperCase()
};

var participantConnected = function($scope, displayName, initialConnect) {
    if (displayName != $scope.displayName) {
        var displayNameInitials = initials(displayName);
        $scope.participantInitials[displayName] = displayNameInitials;
        $scope.participants.push({displayName: displayName, initials: displayNameInitials, typing: false});
        $scope.participants.sort(function(a, b) {
            if (a.displayName > b.displayName) {
                return 1
            }
            else if (a.displayName < b.displayName) {
                return -1
            }
            else {
                return 0
            }
        });
        $scope.$apply();
        if (!initialConnect) {
            addMessageParticipantLine($scope, displayName, true);
        }
    }
};

var participantDisconnected = function($scope, displayName) {
    for (var i=0  ;  i < $scope.participants.length  ;  i++) {
        if (displayName == $scope.participants[i].displayName) {
            $scope.participants.splice(i, 1);
            $scope.$apply();
            addMessageParticipantLine($scope, displayName, false);
            break;
        }
    }
};

var updateTypingState = function($scope, displayName, state) {
    if (displayName != $scope.displayName) {
        for (var i=0  ;  i < $scope.participants.length  ;  i++) {
            if (displayName == $scope.participants[i].displayName) {
                $scope.participants[i].typing = state;
                $scope.$apply();
                break;
            }
        }
    }
};

var setupWebSocketClient = function($scope) {
    var wsProtocol = location.protocol == 'http:' ? 'ws' : 'wss'
    var client = new WebSocket(wsProtocol + '://' + location.host + '/kitura-chat', 'chat');

    client.onerror =  function(error) {
        alert('Connect Error: ' + error.toString());
    };

    client.onopen = function() {
        client.send('C:'+ $scope.displayName)
    };

    client.onclose = function() {
        alert('Chat closed')
    };

    client.onmessage = function(event) {
        var parts = event.data.split(':');
        if (parts.length > 1) {
            switch(parts[0]) {
                case 'c':
                    participantConnected($scope, parts[1], true);
                    break;

                case 'C':
                    participantConnected($scope, parts[1], false);
                    break;

                case 'D':
                    participantDisconnected($scope, parts[1]);
                    break;

                case 'M':
                    var temp = ""
                    for (var i=2 ;  i < parts.length  ;  i++) {
                        temp += ":" + parts[i];
                    }
                    displayMessage($scope, parts[1], temp.substring(1));
                    break;

                case 'S':
                    updateTypingState($scope, parts[1], false);
                    break;

                case 'T':
                    updateTypingState($scope, parts[1], true);
                    break;
            }
        }
    };

    return client;
};


var app = angular.module('chat-client', []);

app.controller("chat-controller", function($scope) {
    $scope.participants = [];
    $scope.participantInitials = {};
    $scope.displayName = "";
    $scope.initials = "";
    $scope.isTyping = 0;

    $scope.displayNameEntered = function() {
        $('.coverFrame').hide();
        $('.displayNameArea').hide();
        $scope.initials = initials($scope.displayName);
        $scope.participantInitials[$scope.displayName] = $scope.initials;

        try {
            $scope.client = setupWebSocketClient($scope);
        }
        catch(error) {}
    };

    var typingStopped = function() {
        $scope.client.send('S:' + $scope.displayName);
        clearTimeout($scope.isTyping);
        $scope.isTyping = 0;
    };

    $scope.inputAreaInput = function(event) {
        if ((event.key == 'Enter' || event.keyCode == 13) && !event.cntrlKey && !event.shiftKey) {
            typingStopped();
            var inputAreaField = $('#inputAreaField');
            var text = inputAreaField.val();
            $scope.client.send('M:' + $scope.displayName + ':' + text);
            event.preventDefault();
            inputAreaField.val('');
        }
        else {
            if ($scope.isTyping) {
                clearTimeout($scope.isTyping);
            }
            else {
                $scope.client.send('T:' + $scope.displayName)
            }
            $scope.isTyping = setTimeout(typingStopped, 5000);
        }
    }
})

app.directive("chatUi", function() {
    return {
        restrict: "E",
        templateUrl: "templates/chatUi.html",
        link: function(scope, element, attrs, controller) {
            utilities.resizeUI();
            $('.inputAreaField').get()[0].focus();
        }
    }
});

})()
