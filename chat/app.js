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

var utilities = {};
utilities.resizeUI = function() {
        var totalHeight = $(window).height();
        var totalWidth = $(window).width();

        var titleBar = $('.titleBar');
        var participantsArea = $('.participantsArea');
        var waitingMessage = $('#waitingMessage');
        var messagesArea = $('.messagesArea');
        var inputArea = $('.inputArea');
        var footerBar = $('.footerBar');
        var coverFrame = $('.coverFrame');

        participantsArea.height(totalHeight - titleBar.height() - footerBar.height() - 2);
        var participantsSeparatorBottom = $('.participantsSeparator').offset().top +
                                                    $('.participantsSeparator').height();
        waitingMessage.offset({top: participantsSeparatorBottom +
                                           (participantsArea.height() - waitingMessage.height() -
                                                    participantsSeparatorBottom + titleBar.height()) / 2,
                               left: (participantsArea.width()-waitingMessage.width())/2});
        messagesArea.width(totalWidth - participantsArea.width() - 60);
        messagesArea.height(inputArea.offset().top - messagesArea.offset().top - 30);

        var boxWidth = $('.messagesArea').width()
        if (boxWidth > 600) {
            boxWidth = 600;
        }
        $('.messagelocalUserBox').width(boxWidth-33);
        $('.messageRemoteUserBox').width(boxWidth-37);
        $('.messageParticipantLine').width(boxWidth);

        inputArea.width(totalWidth - participantsArea.width() - 20);
        var inputAreaFieldWidth = inputArea.width() - 10;
        if (inputAreaFieldWidth > 600) {
            inputAreaFieldWidth = 600;
        }
        $('.inputAreaField').width(inputAreaFieldWidth);

        coverFrame.height(totalHeight - titleBar.height() - footerBar.height());
        coverFrame.offset({top: titleBar.height(), left: 0});
        $('.displayNameArea').offset({top: totalHeight * .40, left: totalWidth * .40});
    };


(function() {

    $(document).ready(function(){
        $(window).resize(utilities.resizeUI);
    });
})();
