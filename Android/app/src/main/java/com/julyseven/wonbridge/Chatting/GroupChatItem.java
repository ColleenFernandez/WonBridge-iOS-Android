package com.julyseven.wonbridge.Chatting;


import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

/*
* This class is used for storing messages received and sent via XMPP
* */
public class GroupChatItem {

    public enum ChatType {TEXT, IMAGE, VIDEO, FILE, SYSTEM};

    public enum StatusType {NORMAL, START_UPLOADING, UPLOADING, START_DOWNLOADING, DOWNLOADING, FAIL};

    private int _sender = 0;
    private String _roomName = "";
    private String _message = "";
    private String _time = "";
    private ChatType _type = ChatType.TEXT;
    private StatusType _status = StatusType.NORMAL;
    private int _progress = 0;
    private String _fileUrl = "";
    private String _participants = "";


    /**  Group Chatting Message */
    public GroupChatItem(int sender, String room, String body) {

        this._sender = sender;
        this._roomName = room;
        this._message = getMessage(body);
        this._time = getTime(body);
        this._type = getType(body);
        this._status = StatusType.NORMAL;


    }

    public GroupChatItem(int sender , String body){

        this._sender = sender;
        this._message = getMessage(body);
        this._time = getTime(body);
        this._type = getType(body);
        this._status = StatusType.NORMAL;
        this._participants = getRoomParticipants(body);
    }

    /** Get from DB */
    public GroupChatItem(int sender, String room, String message, int type, String time) {

        this._sender = sender;
        this._roomName = room;
        this._message = message;
        this._time = time;
        this._type = ChatType.values()[type];
        this._status = StatusType.NORMAL;
    }

    /** Open chatting room Message Item*/
    public GroupChatItem(int sender, String message, int type, String participants, String time ){

        this._sender = sender;
        this._message = message;
        this._type = ChatType.values()[type];
        this._participants = participants;
        this._time = time;

    }

    public GroupChatItem(int sender, String room, String body, StatusType status) {

        this._sender = sender;
        this._roomName = room;
        this._message = getMessage(body);
        this._time = getTime(body);
        this._type = getType(body);
        this._status = status;
    }

    public String get_participants() {
        return _participants;
    }


    public int getSender() {
        return _sender;
    }

    public String getRoomName() {
        return _roomName;
    }

    public String getMessage() {
        return _message;
    }

    public void setMessage(String message) {
        _message = message;
    }

    public ChatType getType() {
        return _type;
    }

    public String getTime() { return _time; }

    // 20160103,6:07:06
    public String getDisplayTime() {

        String time = "";

        try {
            String date = _time.split(",")[0];
            String fulltime = _time.split(",")[1];

            fulltime.substring(0, fulltime.lastIndexOf(":"));

            int hour = Integer.valueOf(fulltime.split(":")[0]);
            String min = fulltime.split(":")[1];

            if (hour < 12) {

                if (Commons.g_xmppService != null){
                    time = Commons.g_xmppService.getString(R.string.am) + " " + hour + ":" + min;
                }

            } else {
                hour -= 12;
                if (hour == 0)
                    hour = 12;

                if (Commons.g_xmppService != null){

                    time = Commons.g_xmppService.getString(R.string.pm) + " " + hour + ":" + min;
                }


            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return time;

    }

    // ROOM#[roomname]:[roomparticipants]:[sendername]#message#time
    // ROOM#1_2:1_2_3:에스오#message#time, ROOM#1_2:1_2_3:에스오#FILE#url#filename#time
    public String getMessage(String body) {

        String body1 = body.substring(body.indexOf(Constants.KEY_SEPERATOR) + 1, body.lastIndexOf(Constants.KEY_SEPERATOR));
        String message = body1.substring(body1.indexOf(Constants.KEY_SEPERATOR) + 1);

        if (getType(body) != ChatType.TEXT) {
            message = message.substring(message.indexOf(Constants.KEY_SEPERATOR) + 1);
        }

        return message;
    }


    // 20150101,13:30:26 or 20160103,6:07:06
    public String getTime(String body) {

        String time = body.substring(body.lastIndexOf(Constants.KEY_SEPERATOR) + 1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd,HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

        try {

            Date date = sdf.parse(time);
            sdf.setTimeZone(TimeZone.getDefault());
            time = sdf.format(date);

        }catch (Exception ex) {
            ex.printStackTrace();
        }

        return time;
    }

    public ChatType getType(String body) {

        String body1 = body.substring(body.indexOf(Constants.KEY_SEPERATOR) + 1);
        body1 = body1.substring(body1.indexOf(Constants.KEY_SEPERATOR) + 1);
        ChatType type = ChatType.TEXT;

        if (body1.startsWith(Constants.KEY_FILE_MARKER))
            type = ChatType.FILE;
        else if (body1.startsWith(Constants.KEY_IMAGE_MARKER))
            type = ChatType.IMAGE;
        else if (body1.startsWith(Constants.KEY_VIDEO_MARKER))
            type = ChatType.VIDEO;
        else if (body1.startsWith(Constants.KEY_SYSTEM_MARKER))
            type = ChatType.SYSTEM;

        return type;
    }


    // url#filename
    public String getFileUrl() {

        return _message.split(Constants.KEY_SEPERATOR)[0];
    }

    public String getFilename() {

        return _message.split(Constants.KEY_SEPERATOR)[3];
    }

    public int getImageWidth() {

        return Integer.parseInt(_message.split(Constants.KEY_SEPERATOR)[1]);
    }

    public int getImageHeight() {

        return Integer.parseInt(_message.split(Constants.KEY_SEPERATOR)[2]);
    }

    public String getUploadFileName() {

        String filename = Commons.g_chattingActivity.getString(R.string.file) +  getFilename();
        return filename;
    }

    public StatusType get_status() {
        return _status;
    }

    public void set_status(StatusType _status) {
        this._status = _status;
    }

    public int get_progress() {
        return _progress;
    }

    public void set_progress(int _progress) {
        this._progress = _progress;
    }

    public String getRoomParticipants(String message) {

        if (!message.startsWith(Constants.KEY_ROOM_MARKER))
            return null;

        return message.split(Constants.KEY_SEPERATOR)[1].split(":")[1];

    }



}
