package com.julyseven.wonbridge.Chatting;

import android.content.Context;

import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.RoomEntity;

import org.jivesoftware.smack.MessageListener;
import org.jivesoftware.smack.PresenceListener;
import org.jivesoftware.smack.SmackConfiguration;
import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.packet.Presence;
import org.jivesoftware.smack.tcp.XMPPTCPConnection;
import org.jivesoftware.smackx.muc.DiscussionHistory;
import org.jivesoftware.smackx.muc.MultiUserChat;
import org.jivesoftware.smackx.muc.MultiUserChatManager;
import org.jivesoftware.smackx.xdata.Form;
import org.jivesoftware.smackx.xdata.FormField;

import java.util.List;

/**
 * Created by JIS on 12/21/2015.
 */
public class GroupChatManager {

    private Context _context;
    private XMPPTCPConnection _connection;
    private MultiUserChat _multiChat;
    private String _roomName;

    private MyPresenceListener _presenceListener;
    private MyMessageListener _messageListener;


    public static boolean isJoined = false;

    public GroupChatManager(Context context, XMPPTCPConnection connection, String roomName) {

        _context = context;
        _connection = connection;
        _roomName = roomName;
    }


    private void setConfig(MultiUserChat multiUserChat) {

        try {
            Form form = multiUserChat.getConfigurationForm();
            Form submitForm = form.createAnswerForm();
            List<FormField> fields = submitForm.getFields();
            for (FormField field : fields) {

                if (!FormField.Type.hidden.equals(field.getType()) && field.getVariable() != null) {
                    submitForm.setDefaultAnswer(field.getVariable());
                }
            }
            submitForm.setAnswer("muc#roomconfig_publicroom", true);

            multiUserChat.sendConfigurationForm(submitForm);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public void enterRoom(String nickName) {

        try {

            MultiUserChatManager mgr = MultiUserChatManager.getInstanceFor(_connection);
            _multiChat = mgr.getMultiUserChat(_roomName + ReqConst.ROOM_SERVICE + ReqConst.CHATTING_SERVER);

            _presenceListener = new MyPresenceListener();
            _messageListener = new MyMessageListener();

            _multiChat.addParticipantListener(_presenceListener);
            _multiChat.addMessageListener(_messageListener);

            DiscussionHistory history = new DiscussionHistory();
            history.setMaxStanzas(0);

            _multiChat.createOrJoin(nickName, null, history, SmackConfiguration.getDefaultPacketReplyTimeout());

            isJoined = true;

        } catch (Exception ex) {

            isJoined = false;
            ex.printStackTrace();
        }

        if (isJoined)
            setConfig(_multiChat);
    }

    public void reenterRoom(String nickName) {

        leaveRoom();
        enterRoom(String.valueOf(nickName));
    }

    public void leaveRoom() {

        try {
            _multiChat.leave();
            _multiChat.removeParticipantListener(_presenceListener);
            _multiChat.removeMessageListener(_messageListener);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        _presenceListener = null;
        _messageListener = null;
        _multiChat = null;

        isJoined = false;
    }

    public void sendMessage(String message)throws SmackException.NotConnectedException {

        try {
            _multiChat.sendMessage(message);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public String getRoomName(String message) {

        if (!message.startsWith(Constants.KEY_ROOM_MARKER))
            return null;

        return message.split(Constants.KEY_SEPERATOR)[1].split(":")[0];

    }


    public class MyPresenceListener implements PresenceListener {

        @Override
        public void processPresence(Presence presence) {

            String jID = presence.getFrom();
            String status = presence.getStatus();
            Presence.Type type = presence.getType();
        }
    }

    public class MyMessageListener implements MessageListener {

        @Override
        public void processMessage(Message message) {

            String jID = message.getFrom();

            final int sender = Integer.valueOf(jID.substring(jID.lastIndexOf("/") + 1));

            RoomEntity room = Commons.g_user.getRoom(getRoomName(message.getBody()));

            // not receive from block friend and not group
            if (Commons.g_user.isBlockUser(sender) && !room.isGroup())
                return;

            // if me
            if (sender == Commons.g_user.get_idx())
                return;

            final String msg = message.getBody();

            ((GroupChattingActivity)_context).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ((GroupChattingActivity)_context).addChat(sender, msg);
                    ((GroupChattingActivity)_context).playSendSound();
                }
            });
        }
    }

}
