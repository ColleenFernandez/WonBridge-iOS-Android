package com.julyseven.wonbridge.Chatting;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.net.Uri;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.RestartActivity;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.message.MsgActivity;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.utils.Database;

import org.jivesoftware.smack.chat.Chat;
import org.jivesoftware.smack.chat.ChatMessageListener;
import org.jivesoftware.smack.packet.Message;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.TimeZone;

/*
* MyChatMessageListener directs the incoming messages to the appropriate container.
* In this case, messages are contained in the ChatList
* */
public class MyChatMessageListener implements ChatMessageListener {

    private int _senderIdx = 0;

    public static final String OFFLINE_MSG_TAG = "<delay xmlns='urn:xmpp:delay'";

    @Override
    public void processMessage(Chat chat, Message message) {

        String mChatSender = message.getFrom();
        _senderIdx = getIdx(mChatSender);

        // if sender is block user
        if (Database.isBlocked(_senderIdx))
            return;

        final String mChatMessage = message.getBody();

        // only receive friend's call
        if (Database.isFriend(_senderIdx)) {

            // receive video call request
            if (mChatMessage.split(Constants.KEY_SEPERATOR)[0].equals(Constants.VIDEO_CHATTING_SENT)) {

                // offline receive call
                if (message.toString().contains(OFFLINE_MSG_TAG))
                    return;

                if (Commons.g_callRequestActivity != null || Commons.g_callRequestActivity != null)
                    return;

                String fromUser = mChatMessage.split(Constants.KEY_SEPERATOR)[1];
                String room = mChatMessage.split(Constants.KEY_SEPERATOR)[2];
                String videoEnabled = mChatMessage.split(Constants.KEY_SEPERATOR)[3];

                if (Boolean.parseBoolean(videoEnabled))
                    Commons.g_xmppService.showCallRequestActivity(_senderIdx, fromUser, room, true);
                else
                    Commons.g_xmppService.showCallRequestActivity(_senderIdx, fromUser, room, false);

                return;

            }// receive video call accept
            else if (mChatMessage.split(Constants.KEY_SEPERATOR)[0].equals(Constants.VIDEO_CHATTING_ACCEPT)) {

                return;
            }
            // receive video call decline
            else if (mChatMessage.split(Constants.KEY_SEPERATOR)[0].equals(Constants.VIDEO_CHATTING_DECLINE)) {

                if (Commons.g_callActivity != null) {

                    Commons.g_callActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Commons.g_callActivity.onDecline();
                        }
                    });

                }

                Commons.g_xmppService.processVideoCallMessage(_senderIdx, Commons.g_user.get_idx(), Commons.g_xmppService.getString(R.string.call_declined_byother));

                return;
            }
            // receive call cancel
            else if (mChatMessage.split(Constants.KEY_SEPERATOR)[0].equals(Constants.VIDEO_CHATTING_CANCEL)) {

                if (Commons.g_callRequestActivity != null) {

                    Commons.g_callRequestActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Commons.g_callRequestActivity.onCancel();
                        }
                    });

                } else if (Commons.g_callActivity != null) {

                    Commons.g_callActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Commons.g_callActivity.onCancel();
                        }
                    });

                }

                // offline receive call
                if (message.toString().contains(OFFLINE_MSG_TAG)) {

                    String fullMessage = message.toString();
                    int stampPos = fullMessage.indexOf("stamp='");
                    int lastPos = fullMessage.lastIndexOf("from=");
                    String stamp = fullMessage.substring(stampPos + 7, lastPos - 2);
                    Commons.g_xmppService.processOfflineCallMessage(_senderIdx, _senderIdx, Commons.g_xmppService.getString(R.string.call_cancelled_byother), stamp);

                } else {
                    Commons.g_xmppService.processVideoCallMessage(_senderIdx, _senderIdx, Commons.g_xmppService.getString(R.string.call_cancelled_byother));
                }
                return;

            }
        }

        // write message into db
        // if request to group message, not write to db.
        if (getType(mChatMessage) != GroupChatItem.ChatType.SYSTEM || !getMessage(mChatMessage).contains(Constants.KEY_REQUEST_MARKER)) {

            GroupChatItem chatItem = new GroupChatItem(_senderIdx, getRoomName(mChatMessage), mChatMessage);
            Database.createMessage(chatItem);
        }
        // if app is running
        if (Commons.g_isAppRunning) {

            final RoomEntity room = Commons.g_user.getRoom(getRoomName(mChatMessage));

            // not receive from block friend and not group chatting
            if (Commons.g_user.isBlockUser(_senderIdx) && !room.isGroup())
                return;

            if (Commons.g_isAppPaused) {
                notifyNewMessage(mChatMessage);

            } else {

                if (Commons.g_chattingActivity != null)
                    Commons.g_chattingActivity.vibrate();
                else
                    notifyNewMessage(mChatMessage);
            }

            // if room is not exist, create room
            if (room == null || (!room.get_participants().equals(getRoomParticipants(mChatMessage)) && !getMessage(mChatMessage).contains(Constants.KEY_BANISH_MARKER))) {
                getRoomInfo(mChatMessage, _senderIdx);
            } else {

                if (!room.get_participants().equals(getRoomParticipants(mChatMessage))) {

                    GroupEntity groupEntity = new GroupEntity();
                    groupEntity.set_groupName(getRoomName(mChatMessage));
                    groupEntity.set_participants(getRoomParticipants(mChatMessage));

                    if (Commons.g_user.get_groupList().contains(groupEntity)) {
                        Commons.g_user.getGroup(getRoomName(mChatMessage)).set_participants(getRoomParticipants(mChatMessage));
                    }

                    room.set_participants(getRoomParticipants(mChatMessage));

                }

                room.set_recentContent(getMessage(mChatMessage));
                room.set_recentTime(getFullTime(mChatMessage));
                room.add_rcentCounter();
                Database.updateRoom(room);

                if (Commons.g_currentActivity != null) {

                    final String msg = message.getBody();

                    if (getType(mChatMessage) == GroupChatItem.ChatType.SYSTEM) {

                        // procees delegate message
                        if (msg.contains(Constants.KEY_DELEGATE_MARKER)) {
                            int dolPos = getMessage(mChatMessage).lastIndexOf("$");
                            String roomname = getMessage(mChatMessage).substring(0, dolPos);
                            dolPos = roomname.lastIndexOf("$");
                            String name = roomname.substring(0, dolPos);
                            roomname = roomname.substring(dolPos + 1);

                            // if me is new owner
                            if (name.equals(Commons.g_user.get_name())) {
                                Commons.g_user.getGroup(roomname).set_ownerIdx(Commons.g_user.get_idx());
                            } else {
                                if (_senderIdx == Commons.g_user.get_idx())
                                    Commons.g_user.getGroup(roomname).set_ownerIdx(0);
                            }
                        }

                        // process banishh message
                        if (msg.contains(Constants.KEY_BANISH_MARKER)) {

                            int dolPos = getMessage(mChatMessage).lastIndexOf("$");
                            String all = getMessage(mChatMessage).substring(0, dolPos);
                            dolPos = all.lastIndexOf("$");
                            String names = all.substring(0, dolPos);
                            String ids = all.substring(dolPos + 1);
                            String idArray[] = ids.split("_");
                            ArrayList<String> idList = new ArrayList<>(Arrays.asList(idArray));

                            // if me is bannished
                            if (idList.contains(String.valueOf(Commons.g_user.get_idx()))) {
                                // delete room from database
                                Database.deleteRoom(room);
                                Database.deleteRoomMessage(room);

                                // delete group and room
                                GroupEntity groupEntity = new GroupEntity();
                                groupEntity.set_groupName(getRoomName(mChatMessage));
                                Commons.g_user.get_groupList().remove(groupEntity);
                                Commons.g_user.get_roomList().remove(room);

                            } else {

                                for (int i = 0; i < idArray.length; i++) {
                                    Database.deleteUserMessage(room, Integer.parseInt(idArray[i]));

                                    FriendEntity friendEntity = new FriendEntity();
                                    friendEntity.set_idx(Integer.parseInt(idArray[i]));

                                    Commons.g_user.getRoom(room.get_name()).get_participantList().remove(friendEntity);
                                }
                            }

                            getGroupProfile(room.get_name());
                        }

                        if (msg.contains(Constants.KEY_LEAVEROOM_MARKER)) {

                            final int leaveId = _senderIdx;

                            // add to leavemembers.
                            if (room.get_leaveMembers().length() == 0) {
                                room.set_leaveMembers(String.valueOf(leaveId));
                            } else {

                                String leaveMembers[] = room.get_leaveMembers().split("_");
                                ArrayList<String> leaveIds = new ArrayList<>(Arrays.asList(leaveMembers));

                                if (!leaveIds.contains(String.valueOf(leaveId)))
                                    room.set_leaveMembers(room.get_leaveMembers() + "_" + leaveId);
                            }

                            // remove from participants.
                            room.removeParticipant(leaveId);
                            Commons.g_user.getGroup(room.get_name()).removeParticipant(leaveId);
                            Commons.g_user.getRoom(room.get_name()).removeParticipant(leaveId);

                            Database.updateRoom(room);

                            getGroupProfile(room.get_name());

                        }
                    }

                    // room recent info update
                    if (Commons.g_currentActivity.getClass().equals(MsgActivity.class)) {
                        Commons.g_currentActivity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                ((MsgActivity) Commons.g_currentActivity).refresh();
                            }
                        });
                    }

                    Commons.g_currentActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Commons.g_currentActivity.setUnRead();
                        }
                    });
                }

                // process status message because status message is msg outside of room.
                if (Commons.g_chattingActivity != null) {

                    String jID = message.getFrom();

                    final int sender = Integer.valueOf(jID.substring(0, jID.lastIndexOf("@")));

                    final String msg = message.getBody();

                    if (getType(msg) != GroupChatItem.ChatType.SYSTEM)
                        return;

                    if (sender == Commons.g_user.get_idx() && msg.contains(Constants.KEY_LEAVEROOM_MARKER))
                        return;

                    if (Commons.g_chattingActivity._roomEntity.get_name().equals(getRoomName(mChatMessage))) {


                        if (!msg.contains(Constants.KEY_REQUEST_MARKER)) {
                            (Commons.g_chattingActivity).runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    Commons.g_chattingActivity.addChat(sender, msg);
                                }
                            });
                        }

                        if (msg.contains(Constants.KEY_BANISH_MARKER)) {

                            Commons.g_chattingActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {

                                    int dolPos = getMessage(mChatMessage).lastIndexOf("$");
                                    String all = getMessage(mChatMessage).substring(0, dolPos);
                                    dolPos = all.lastIndexOf("$");
                                    String names = all.substring(0, dolPos);
                                    String ids = all.substring(dolPos + 1);
                                    String idArray[] = ids.split("_");
                                    ArrayList<String> idList = new ArrayList<>(Arrays.asList(idArray));

                                    // if me is banished, go out room
                                    if (idList.contains(String.valueOf(Commons.g_user.get_idx()))) {
                                        Commons.g_chattingActivity.finish();
                                    } else { // delete user's message
                                        Commons.g_chattingActivity._roomEntity.set_participants(getRoomParticipants(msg));
                                        Commons.g_chattingActivity.removeBanishUsers(idList);
                                        Commons.g_chattingActivity.updateRoomTitle();
                                    }
                                }
                            });

                        }

                        if (msg.contains(Constants.KEY_LEAVEROOM_MARKER)) {

                            final int leaveId = _senderIdx;

                            Commons.g_chattingActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    Commons.g_chattingActivity._roomEntity.removeParticipant(leaveId);
                                    Commons.g_chattingActivity.updateRoomTitle();
                                }
                            });
                        }

                        if (msg.contains(Constants.KEY_REQUEST_MARKER)) {
                            Commons.g_chattingActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    Commons.g_chattingActivity.getGroupRequestByUserId(sender, Commons.g_chattingActivity._roomEntity.get_name());
                                }
                            });
                        }
                    }

                }

            }

        } else {

            if (getType(mChatMessage) == GroupChatItem.ChatType.SYSTEM) {

                // process banishh message
                if (mChatMessage.contains(Constants.KEY_BANISH_MARKER)) {

                    int dolPos = getMessage(mChatMessage).lastIndexOf("$");
                    String all = getMessage(mChatMessage).substring(0, dolPos);
                    dolPos = all.lastIndexOf("$");
                    String names = all.substring(0, dolPos);
                    String ids = all.substring(dolPos + 1);
                    String idArray[] = ids.split("_");
                    ArrayList<String> idList = new ArrayList<>(Arrays.asList(idArray));

                    RoomEntity roomEntity = new RoomEntity(getRoomName(mChatMessage));

                    // if me is bannished
                    if (idList.contains(String.valueOf(Commons.g_user.get_idx()))) {
                        // delete room from database
                        Database.deleteRoom(roomEntity);
                        Database.deleteRoomMessage(roomEntity);

                    } else {

                        for (int i = 0; i < idArray.length; i++) {
                            Database.deleteUserMessage(roomEntity, Integer.parseInt(idArray[i]));
                        }
                    }
                }

                if (mChatMessage.contains(Constants.KEY_LEAVEROOM_MARKER)) {

                    final int leaveId = _senderIdx;

                    RoomEntity roomEntity = Database.getRoom(getRoomName(mChatMessage));

                    if (roomEntity.get_leaveMembers().length() == 0) {
                        roomEntity.set_leaveMembers(String.valueOf(leaveId));
                    } else {

                        String leaveMembers[] = roomEntity.get_leaveMembers().split("_");
                        ArrayList<String> leaveIds = new ArrayList<>(Arrays.asList(leaveMembers));

                        if (!leaveIds.contains(String.valueOf(leaveId)))
                            roomEntity.set_leaveMembers(roomEntity.get_leaveMembers() + "_" + leaveId);
                    }

                    roomEntity.removeParticipant(leaveId);
                    Database.updateRoom(roomEntity);

                }
            }

            notifyNewMessage(mChatMessage);
        }

    }


    // ROOM#10_12_13:10_12_13_14:에스오#this is room outside message body#time
    public String getRoomName(String message) {

        if (!message.startsWith(Constants.KEY_ROOM_MARKER))
            return null;

        return message.split(Constants.KEY_SEPERATOR)[1].split(":")[0];

    }

    // ROOM#10_12_13:10_12_13_14:에스오#this is room outside message body#time
    public String getRoomParticipants(String message) {

        if (!message.startsWith(Constants.KEY_ROOM_MARKER))
            return null;

        return message.split(Constants.KEY_SEPERATOR)[1].split(":")[1];

    }

    // ROOM#10_12_13:10_12_13_14:에스오#this is room outside message body#time
    public String getSenderName(String message) {

        if (!message.startsWith(Constants.KEY_ROOM_MARKER))
            return null;

        return message.split(Constants.KEY_SEPERATOR)[1].split(":")[2];

    }

    public String getFullTime(String body) {

        String fulldatetime = body.substring(body.lastIndexOf(Constants.KEY_SEPERATOR) + 1);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd,HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

        try {

            Date date = sdf.parse(fulldatetime);
            sdf.setTimeZone(TimeZone.getDefault());
            fulldatetime = sdf.format(date);

        }catch (Exception ex) {
            ex.printStackTrace();
        }

        return fulldatetime;
    }


    // ROOM#1_2#message#time, ROOM#1_2#FILE#message#time
    public String getMessage(String body) {

        String body1 = body.substring(body.indexOf(Constants.KEY_SEPERATOR) + 1, body.lastIndexOf(Constants.KEY_SEPERATOR));
        String message = body1.substring(body1.indexOf(Constants.KEY_SEPERATOR) + 1);

        if (getType(body) == GroupChatItem.ChatType.VIDEO ||
                getType(body) == GroupChatItem.ChatType.IMAGE ||
                getType(body) == GroupChatItem.ChatType.FILE ) {
            message = Commons.g_xmppService.getString(R.string.transfer_file);
        } else if (getType(body) == GroupChatItem.ChatType.SYSTEM) {
            message = message.substring(Constants.KEY_SYSTEM_MARKER.length());
        }

        return message;
    }

    public GroupChatItem.ChatType getType(String body) {

        String body1 = body.substring(body.indexOf(Constants.KEY_SEPERATOR) + 1);
        body1 = body1.substring(body1.indexOf(Constants.KEY_SEPERATOR) + 1);
        GroupChatItem.ChatType type = GroupChatItem.ChatType.TEXT;

        if (body1.startsWith(Constants.KEY_FILE_MARKER))
            type = GroupChatItem.ChatType.FILE;
        else if (body1.startsWith(Constants.KEY_IMAGE_MARKER))
            type = GroupChatItem.ChatType.IMAGE;
        else if (body1.startsWith(Constants.KEY_VIDEO_MARKER))
            type = GroupChatItem.ChatType.VIDEO;
        else if (body1.startsWith(Constants.KEY_SYSTEM_MARKER))
            type = GroupChatItem.ChatType.SYSTEM;

        return type;
    }

    public void getRoomInfo(final String message, final int sender){

        final String participants = getRoomParticipants(message);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETROOMANDGROUPINFO;

        String params = String.format("/%d/%s/%s", Commons.g_user.get_idx(), participants, getRoomName(message));
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseRoomInfoResponse(json, message, sender);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseRoomInfoResponse(String json, String message, final int sender){

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray friends = response.getJSONArray(ReqConst.RES_USERINFOS);

                ArrayList<FriendEntity> participants = new ArrayList<FriendEntity>();

                // get participants data
                for (int i = 0; i < friends.length(); i++) {

                    JSONObject friend = (JSONObject) friends.get(i);
                    FriendEntity entity = new FriendEntity();

                    if (friend.getInt(ReqConst.RES_ID) == Commons.g_user.get_idx())
                        continue;

                    entity.set_idx(friend.getInt(ReqConst.RES_ID));
                    entity.set_name(friend.getString(ReqConst.RES_NAME));
                    entity.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_isFriend(friend.getInt(ReqConst.RES_ISFRIEND) == 1);
                    entity.set_latitude((float) friend.getDouble(ReqConst.RES_LATITUDE));
                    entity.set_longitude((float) friend.getDouble(ReqConst.RES_LONGITUDE));
                    entity.set_lastLogin(friend.getString(ReqConst.RES_LASTLOGIN));
                    entity.set_country(friend.getString(ReqConst.RES_COUNTRY));
                    entity.set_country2(friend.getString(ReqConst.RES_COUNTRY2));

                    participants.add(entity);
                }

                // make room
                RoomEntity roomEntity = new RoomEntity(getRoomName(message));
                roomEntity.set_participantList(participants);
                roomEntity.set_participants(roomEntity.makeParticipantsWithoutLeaveMemeber(true));
                roomEntity.set_recentContent(getMessage(message));
                roomEntity.set_recentTime(getFullTime(message));
                roomEntity.add_rcentCounter();

                if (!Commons.g_user.get_roomList().contains(roomEntity)) {
                    Commons.g_user.get_roomList().add(roomEntity);
                    Database.createRoom(roomEntity);
                }else {
                    RoomEntity oldRoom = Commons.g_user.getRoom(roomEntity.get_name());
                    oldRoom.set_participants(roomEntity.get_participants());
                    oldRoom.set_participantList(roomEntity.get_participantList());
                    oldRoom.set_recentContent(roomEntity.get_recentContent());
                    oldRoom.set_recentTime(roomEntity.get_recentTime());
                    oldRoom.add_rcentCounter();

                    Database.updateRoom(oldRoom);
                }

                // if group
                if (isGroup(roomEntity.get_name())) {

                    JSONObject jsonGroup = response.getJSONObject(ReqConst.RES_GROUPINFO);
                    GroupEntity groupEntity = new GroupEntity();

                    groupEntity.set_ownerIdx(jsonGroup.getInt(ReqConst.RES_USERID));
                    groupEntity.set_groupName(jsonGroup.getString(ReqConst.RES_NAME));
                    groupEntity.set_participants(jsonGroup.getString(ReqConst.RES_PARTICIPANT));
                    groupEntity.set_groupNickname(jsonGroup.getString(ReqConst.RES_NICKNAME));
                    groupEntity.set_groupProfileUrl(jsonGroup.getString(ReqConst.RES_PROFILE));
                    groupEntity.set_regDate(jsonGroup.getString(ReqConst.RES_REGDATE));
                    groupEntity.set_country(jsonGroup.getString(ReqConst.RES_COUNTRY));
                    JSONArray jsonUrls = jsonGroup.getJSONArray(ReqConst.RES_GROUPURLS);
                    for (int j = 0 ; j < jsonUrls.length(); j++) {
                        groupEntity.get_profileUrls().add((jsonUrls.getString(j)));
                    }

                    if (Commons.g_user.get_groupList().contains(groupEntity)) {
                        Commons.g_user.get_groupList().remove(groupEntity);
                    }
                    Commons.g_user.get_groupList().add(groupEntity);
                }
                //

                if (Commons.g_currentActivity != null) {

                    // refresh chat room list
                    if (Commons.g_currentActivity.getClass().equals(MsgActivity.class)) {
                        Commons.g_currentActivity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                               ((MsgActivity) Commons.g_currentActivity).refresh();
                            }
                        });
                    }

                    Commons.g_currentActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Commons.g_currentActivity.setUnRead();
                        }
                    });
                }
            }

            if (Commons.g_chattingActivity != null) {

                Commons.g_chattingActivity.updateRoomTitle();

                final String msg = message;

                if (!msg.contains(Constants.KEY_INVITE_MARKER) && !msg.contains(Constants.KEY_BANISH_MARKER) && !msg.contains(Constants.KEY_ADD_MARKER))
                    return;

                if (Commons.g_chattingActivity._roomEntity.get_name().equals(getRoomName(msg))) {

                    (Commons.g_chattingActivity).runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Commons.g_chattingActivity.addChat(sender, msg);
                        }
                    });
                }
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

    }


    public void getGroupProfile(final String roomname) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETGROUPPROFILE;

        String params = String.format("/%s", roomname);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseProfileResponse(json, roomname);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseProfileResponse(String json, String roomname) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {

                Commons.g_user.getGroup(roomname).get_profileUrls().clear();

                JSONArray jsonUrls = response.getJSONArray(ReqConst.RES_GROUPURLS);
                for (int j = 0 ; j < jsonUrls.length(); j++) {
                    Commons.g_user.getGroup(roomname).get_profileUrls().add((jsonUrls.getString(j)));
                }

                if (Commons.g_currentActivity.getClass().equals(MsgActivity.class)) {
                    Commons.g_currentActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            ((MsgActivity) Commons.g_currentActivity).refresh();
                        }
                    });
                }
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }


    private void notifyNewMessage(String message) {

        boolean pushSetting = Preference.getInstance().getValue(Commons.g_xmppService, PrefConst.PREFKEY_PUSH, true);

        if (!pushSetting)
            return;

        if (Commons.g_xmppService != null)
            Commons.g_xmppService.updateBadgeCount(Commons.g_badgCount + 1);

        RoomEntity room = new RoomEntity(getRoomName(message), getRoomParticipants(message), getMessage(message), getFullTime(message), Commons.g_badgCount, "");
        // no banish message
        if (getType(message) != GroupChatItem.ChatType.SYSTEM && !message.contains(Constants.KEY_BANISH_MARKER)) {
            // create room
            Database.createRoom(room);
        }

        Intent notiIntent = new Intent(Commons.g_xmppService, RestartActivity.class);
        notiIntent.putExtra(Constants.KEY_ROOM, getRoomName(message));
        notiIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);

        PendingIntent pendingIntent = PendingIntent.getActivity(Commons.g_xmppService, 1, notiIntent,
                PendingIntent.FLAG_UPDATE_CURRENT);

        Notification.Builder builder = new Notification.Builder(Commons.g_xmppService);

        // noti small icon
        builder.setSmallIcon(R.mipmap.ic_launcher);
        // noti preview
        builder.setTicker(getNotiText(message));
        // noti time
        builder.setWhen(System.currentTimeMillis());
        // noti title
        builder.setContentTitle(getTitleString());
        // content
        builder.setContentText(getNotiText(message));
        // action on touch
        builder.setContentIntent(pendingIntent);
        // auto cancel
        builder.setAutoCancel(true);

        builder.setOngoing(false);

        // large icon
        builder.setLargeIcon(BitmapFactory.decodeResource(Commons.g_xmppService.getResources(),
                R.mipmap.ic_launcher));


        // sound
        if (Preference.getInstance().getValue(Commons.g_xmppService, PrefConst.PREFKEY_NOTISOUND + room.get_name(), true)) {
            builder.setDefaults(Notification.DEFAULT_SOUND);
            Uri uri = Uri.parse("android.resource://"
                    + Commons.g_xmppService.getPackageName() + "/" + R.raw.noti);

            builder.setSound(uri);
        }

        // vibration
        builder.setDefaults(Notification.DEFAULT_VIBRATE);

        // create noti
        NotificationManager nm = (NotificationManager) Commons.g_xmppService.getSystemService(Context.NOTIFICATION_SERVICE);
        nm.notify(Constants.NORMAL_NOTI_ID, builder.build());

    }

    public String getTitleString() {

        String ret = "[" + Commons.g_xmppService.getString(R.string.app_name) + "]";
        return ret;
    }

    public int getIdx(String name) {
        return Integer.valueOf(name.split("@")[0]);
    }


    public String getNotiText(String message) {

        String sender = getSenderName(message);
        String body = getMessage(message);
        String returned = sender + " : ";

        if (getType(message) == GroupChatItem.ChatType.SYSTEM) {

            if (body.contains(Constants.KEY_LEAVEROOM_MARKER)) {

                int dolPos = body.lastIndexOf("$");
                String name = body.substring(0, dolPos);
                returned += name + Commons.g_xmppService.getString(R.string.leave_room);

            } else if (body.contains(Constants.KEY_DELEGATE_MARKER)) {

                int dolPos = body.lastIndexOf("$");
                String roomname = body.substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String name = roomname.substring(0, dolPos);
                returned += name + Commons.g_xmppService.getString(R.string.become_groupowner);

            } else if (body.contains(Constants.KEY_INVITE_MARKER)) {

                int dolPos = body.lastIndexOf("$");
                String names = body.substring(0, dolPos);
                returned += names + Commons.g_xmppService.getString(R.string.invited_toroom);

            } else if (body.contains(Constants.KEY_BANISH_MARKER)) {

                int dolPos = body.lastIndexOf("$");
                String roomname = body.substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String names = roomname.substring(0, dolPos);
                returned += names + Commons.g_xmppService.getString(R.string.banish_fromroom);

            } else if (body.contains(Constants.KEY_REQUEST_MARKER)) {
                int dolPos = body.lastIndexOf("$");
                String roomname = body.substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String name = roomname.substring(0, dolPos);
                returned = name + Commons.g_xmppService.getString(R.string.group_request_message);
            } else if (body.contains(Constants.KEY_ADD_MARKER)) {

                int dolPos = body.lastIndexOf("$");
                String roomname = body.substring(0, dolPos);
                dolPos = roomname.lastIndexOf("$");
                String name = roomname.substring(0, dolPos);
                returned += name + Commons.g_xmppService.getString(R.string.add_toroom);
            }
        }
        else {
            returned += body;
        }

        return returned;

    }

    public boolean isGroup(String roomname) {

        int size = roomname.split("_").length;

        if (size > 2)
            return true;

        return false;
    }

}
