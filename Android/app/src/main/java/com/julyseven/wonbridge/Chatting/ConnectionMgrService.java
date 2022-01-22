package com.julyseven.wonbridge.Chatting;

import android.app.Service;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Binder;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.webkit.URLUtil;

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
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.mypage.MyPageActivity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.register.LoginActivity;
import com.julyseven.wonbridge.utils.Database;

import org.appspot.apprtc.CallActivity;
import org.jivesoftware.smack.AbstractConnectionListener;
import org.jivesoftware.smack.ConnectionConfiguration;
import org.jivesoftware.smack.ReconnectionManager;
import org.jivesoftware.smack.SASLAuthentication;
import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.chat.Chat;
import org.jivesoftware.smack.chat.ChatManager;
import org.jivesoftware.smack.chat.ChatManagerListener;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.tcp.XMPPTCPConnection;
import org.jivesoftware.smack.tcp.XMPPTCPConnectionConfiguration;
import org.jivesoftware.smackx.iqregister.AccountManager;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.TimeZone;

import de.greenrobot.event.EventBus;
import me.leolin.shortcutbadger.ShortcutBadger;

/*
* The ConnectionMgrService class handles all of the XMPP connection (mainly log in and disconnection)
* We implement a Service to preserve the connection long-term.
* Ideally, you should also be implementing routine server pings to keep the connection alive (otherwise
*   you may create a 'zombie connection' - a connection that's somewhat connected but unable to receive input)
* */
public class ConnectionMgrService extends Service {

    protected static final String TAG = "XMPP";

    /*
    * SERVICE_NAME and HOST_NAME are your server details.
    * Make sure you edit this with your own
    * */

    public static XMPPTCPConnection mConnection = null;
    private XMPPTCPConnectionConfiguration mConnectionConfiguration;

    private boolean startConnected = false;
    private int _startFrom = Constants.XMPP_FROMBROADCAST;

    private final IBinder mBinder = new ServiceBinder();

    public boolean isConnected = false;

    //
    // video chatting
    private SharedPreferences sharedPref;
    private String keyprefVideoCallEnabled;
    private String keyprefCamera2;
    private String keyprefResolution;
    private String keyprefFps;
    private String keyprefCaptureQualitySlider;
    private String keyprefVideoBitrateType;
    private String keyprefVideoBitrateValue;
    private String keyprefVideoCodec;
    private String keyprefAudioBitrateType;
    private String keyprefAudioBitrateValue;
    private String keyprefAudioCodec;
    private String keyprefHwCodecAcceleration;
    private String keyprefCaptureToTexture;
    private String keyprefNoAudioProcessingPipeline;
    private String keyprefAecDump;
    private String keyprefOpenSLES;
    private String keyprefDisableBuiltInAec;
    private String keyprefDisableBuiltInAgc;
    private String keyprefDisableBuiltInNs;
    private String keyprefEnableLevelControl;
    private String keyprefDisplayHud;
    private String keyprefTracing;
    private String keyprefRoomServerUrl;

    private static final int CONNECTION_REQUEST = 1;
    private static boolean commandLineRun = false;
    private int _myId = 0;

    public class ServiceBinder extends Binder {
        ConnectionMgrService mService() {
            return ConnectionMgrService.this;
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        Commons.g_xmppService = this;
        _startFrom = Constants.XMPP_FROMBROADCAST;
        Database.init(getApplicationContext());

        initVideoChatting();

        onHandleIntent(intent);
        return START_STICKY;
    }

    // Handles incoming events
    protected void onHandleIntent(Intent intent) {

        if (intent != null) {
            _startFrom = intent.getIntExtra(Constants.XMPP_START, Constants.XMPP_FROMBROADCAST);
        }

        String xmppID = Preference.getInstance().getValue(this,
                PrefConst.PREFKEY_XMPPID, "");
        String userpwd = Preference.getInstance().getValue(this,
                PrefConst.PREFKEY_USERPWD, "");

        _myId = Integer.parseInt(xmppID);

        Log.d("Id and pwd ===>", xmppID + "  " + userpwd);

        if(xmppID.length() > 0 && userpwd.length() > 0) {
            startLogin(xmppID, userpwd);

        }

    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    /*
    * startLogin creates the connection for the log in process.
    * First, a connection to the server must be established. After the connection
    *   is established, then only can you process the login details.
    * */
    private void startLogin(final String username, final String password) {

        new Thread(new Runnable() {
            @Override
            public void run() {

                mConnectionConfiguration = XMPPTCPConnectionConfiguration.builder()
                        .setUsernameAndPassword(username, password) // The username and password supplied by the user
                        .setServiceName(ReqConst.CHATTING_SERVER) // Service name
                        .setPort(5222) // Incoming port (might depend on your XMPP server software)
                        .setSecurityMode(ConnectionConfiguration.SecurityMode.disabled) // Security mode is disabled for example purposes
                        .setResource("WonBridge")
                        .build();

                mConnection = new XMPPTCPConnection(mConnectionConfiguration);
                mConnection.setPacketReplyTimeout(30000);

                mConnection.addConnectionListener(myConnectionListener);

                ReconnectionManager reconnectionMgr = ReconnectionManager.getInstanceFor(mConnection);
                reconnectionMgr.enableAutomaticReconnection();

                try {
                    mConnection.connect();
                    startConnected = true;
                } catch (Exception e) {
                    e.printStackTrace();
                }

                // If the connection is successful, we begin the login process
                if(startConnected) {
                    Log.d(TAG, "======================Connected======================");
                    connectionLogin();

                } else {
                    Log.d(TAG, "======================Unable to connect======================");
                    if (_startFrom == Constants.XMPP_FROMLOGIN)
                        EventBus.getDefault().post(new LoggedInEvent(false));
                }
            }
        }).start();
    }

    private boolean loggedIn = true;

    private void connectionLogin() {

        try {
            SASLAuthentication.unBlacklistSASLMechanism("PLAIN");
            SASLAuthentication.blacklistSASLMechanism("DIGEST-MD5");
            mConnection.login();

        } catch (Exception e) {
            e.printStackTrace();
            loggedIn = false;
        }

        // If the login fails, we disconnect from the server
        if(!loggedIn) {

            Log.d(TAG, "======================LoggedIn Fail======================");
            disconnect();
            loggedIn = true;

            if (_startFrom == Constants.XMPP_FROMLOGIN)
                EventBus.getDefault().post(new LoggedInEvent(false));


        } else {
            // If the login succeeds, we implement the chat listener.
            // It's important to implement the listener here so we can receive messages sent to us
            //      when we're offline.
            Log.d(TAG, "======================LoggedIn Success======================");

            createChatListener();

            // Callback to LoginScreen to change the UI to the ChatScreen listview
            if (_startFrom == Constants.XMPP_FROMLOGIN)
                EventBus.getDefault().post(new LoggedInEvent(true));

        }
    }

    private AbstractConnectionListener myConnectionListener = new AbstractConnectionListener() {

        @Override
        public void authenticated(XMPPConnection connection, boolean resumed) {
            super.authenticated(connection, resumed);
        }

        @Override
        public void connected(XMPPConnection connection) {
            super.connected(connection);
            isConnected = true;
            Log.d("XMPP", "xmppconnection connected.");
        }

        @Override
        public void connectionClosed() {
            super.connectionClosed();

            if (mConnection != null)
                mConnection.removeConnectionListener(myConnectionListener);
            myConnectionListener = null;
            mConnection = null;

            isConnected = false;
            GroupChatManager.isJoined = false;
            Log.d("XMPP", "xmppconnection closed.");
        }

        @Override
        public void connectionClosedOnError(Exception e) {
            super.connectionClosedOnError(e);

            isConnected = false;
            GroupChatManager.isJoined = false;
            if (Commons.g_isAppRunning && Commons.g_currentActivity != null) {
                Commons.g_currentActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Commons.g_currentActivity.showToast(getString(R.string.chatting_error));
                    }
                });
            }
            Log.d("XMPP", "xmppconnection closed with error.");
        }

        @Override
        public void reconnectingIn(int seconds) {
            super.reconnectingIn(seconds);

            Log.d("XMPP", "xmppconnection reconnecting");
        }

        @Override
        public void reconnectionFailed(Exception e) {
            super.reconnectionFailed(e);
            isConnected = false;
            GroupChatManager.isJoined = false;
            Log.d("XMPP", "xmppconnection reconnection failed");
        }

        @Override
        public void reconnectionSuccessful() {
            super.reconnectionSuccessful();
            Log.d("XMPP", "xmppconnection reconnection successed.");
            isConnected = true;
            if (Commons.g_isAppRunning) {
                Commons.g_currentActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Commons.g_currentActivity.showToast(getString(R.string.chatting_success));
                    }
                });
            }

            if (Commons.g_chattingActivity != null) {
                Commons.g_chattingActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Commons.g_chattingActivity.reenterRoom();
                    }
                });
            }
        }
    };

    /*
    * CreateChatListener implements the listener class for incoming chats.
    * The class is MyChatMessageListener
    * DISCLAIMER: You should be renewing the listener if the user logs in as another user, otherwise you may
    *   have duplicate messages
    * */
    private MyChatMessageListener mChatMessageListener;

    private void createChatListener() {

        if(mConnection != null) {

            ChatManager chatManager = ChatManager.getInstanceFor(mConnection);
            chatManager.setNormalIncluded(false); // Eliminates a few debug messages

            chatManager.addChatListener(new ChatManagerListener() {
                @Override
                public void chatCreated(Chat chat, boolean createdLocally) {

//                    if (!createdLocally) {
                        Log.d("XMPP", "chat listener created");
//                        mChatMessageListener = new MyChatMessageListener();
                        chat.addMessageListener(new MyChatMessageListener());
//                    }
                }
            });
        }
    }

    public void updateBadgeCount(int count) {

        Commons.g_badgCount = count;

        Commons.addNumShortCut(this, RestartActivity.class, true, String.valueOf(count), false);
    }

    private String getLauncherClassName() {

        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_LAUNCHER);
        intent.setPackage(getPackageName());

        List<ResolveInfo> resolveInfoList = getPackageManager().queryIntentActivities(intent, 0);
        if(resolveInfoList != null && resolveInfoList.size() > 0) {
            return resolveInfoList.get(0).activityInfo.name;
        }

        return null;
    }

    /*
    * This disconnection method is created here to validate if the connection is not null otherwise
    *   it may crash the application.
    * */
    public void disconnect() {

        if (mConnection != null && mConnection.isConnected()) {

            new AsyncTask<Void, Void, Void>() {
                @Override
                protected Void doInBackground(Void... params) {

                    mConnection.removeConnectionListener(myConnectionListener);
                    myConnectionListener = null;
                    mConnection.disconnect();
                    mConnection = null;
                    return null;
                }
            }.execute();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        disconnect();
    }


    // video call
    public void sendTextMessage(String address, String chat_message) {
        // Listview is updated with our new message
        ChatManager chatManager = ChatManager.getInstanceFor(mConnection);

        final Chat newChat = chatManager.createChat(address);

        final Message message = new Message();
        message.setBody(chat_message);

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params) {
                // We send the message here.
                // You should also check if the username is valid here.
                try {
                    newChat.sendMessage(message);
                } catch (SmackException.NotConnectedException e) {
                }
                return null;
            }

            @Override
            protected void onPostExecute(Void aVoid) {
                super.onPostExecute(aVoid);
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    public void sendVideoRequest(int toUserId, String toUserName, boolean videoEnabled) {

        String roomNumber = String.valueOf(getRandomRoomNumber());
        String message = Constants.VIDEO_CHATTING_SENT + Constants.KEY_SEPERATOR + Commons.g_user.get_name() + Constants.KEY_SEPERATOR + roomNumber + Constants.KEY_SEPERATOR + videoEnabled;
        sendTextMessage(Commons.idxToAddr(toUserId), message);

        sendCallRequestToServer(toUserId, roomNumber, videoEnabled);

        gotoCallActivity(roomNumber, toUserName, videoEnabled, true, toUserId);

    }

    public void sendCallRequestToServer(int toUserId, String roomNumber, boolean videoEnabled) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SENDCALL;

        String params = String.format("/%d/%d/%s/%d", Commons.g_user.get_idx(), toUserId, roomNumber, videoEnabled ? 1 : 0);

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

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


    public void sendVideoAccept(int fromUserId) {

        String message = Constants.VIDEO_CHATTING_ACCEPT + Constants.KEY_SEPERATOR + fromUserId;
        sendTextMessage(Commons.idxToAddr(fromUserId), message);

    }

    public void sendVideoDecline(int fromUserId) {

        String message = Constants.VIDEO_CHATTING_DECLINE + Constants.KEY_SEPERATOR + fromUserId;
        sendTextMessage(Commons.idxToAddr(fromUserId), message);

        processVideoCallMessage(fromUserId, fromUserId, Commons.g_xmppService.getString(R.string.call_declined_byme));
    }


    public void sendVideoCancel(int toUserId) {

        String message = Constants.VIDEO_CHATTING_CANCEL + Constants.KEY_SEPERATOR + toUserId;
        sendTextMessage(Commons.idxToAddr(toUserId), message);

        sendCallCancellToServer(toUserId);

        processVideoCallMessage(toUserId, Commons.g_user.get_idx(), Commons.g_xmppService.getString(R.string.call_cancelled_byme));
    }

    public void sendCallCancellToServer(int toUserId) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_CANCELCALL;

        String params = String.format("/%d/%d", Commons.g_user.get_idx(), toUserId);

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

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

    public void sendVideoNoAnswer(int toUserId) {

        String message = Constants.VIDEO_CHATTING_CANCEL + Constants.KEY_SEPERATOR + toUserId;
        sendTextMessage(Commons.idxToAddr(toUserId), message);

        sendCallCancellToServer(toUserId);

        processVideoCallMessage(toUserId, Commons.g_user.get_idx(), Commons.g_xmppService.getString(R.string.call_cancelled_noanswer));
    }

    public void gotoCallActivity(String roomNumber, String toUserName, boolean videoEnabled, boolean isSender, int otherIdx) {

        connectToRoom("videocall_" + roomNumber, toUserName, false, 0, videoEnabled, isSender, otherIdx);
    }

    public void processVideoCallMessage(int senderIdx, int chatIdx, String message) {


        // add message to database
        String roomname = senderIdx + "_" + _myId;
        if (senderIdx > _myId)
            roomname = _myId + "_" + senderIdx;

        String time = Commons.getCurrentTimeString();

        final GroupChatItem chatItem = new GroupChatItem(chatIdx, roomname, message, GroupChatItem.ChatType.TEXT.ordinal(), time);
        Database.createMessage(chatItem);


        // update room recent info
        RoomEntity room;
        if (Commons.g_currentActivity != null) {

            room = Commons.g_user.getRoom(roomname);
            // room recent info update
            if (Commons.g_currentActivity.getClass().equals(MsgActivity.class)) {
                Commons.g_currentActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ((MsgActivity) Commons.g_currentActivity).refresh();
                    }
                });
            }

        } else {
            room = Database.getRoom(roomname);
        }

        if (room != null) {

            room.set_recentContent(chatItem.getMessage());
            room.set_recentTime(time);
            Database.updateRoom(room);
        }

        if (Commons.g_chattingActivity != null) {
            Commons.g_chattingActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Commons.g_chattingActivity.addChat(chatItem);
                }
            });
        }

    }

    public void processOfflineCallMessage(int senderIdx, int chatIdx, String message, String timeStamp) {


        // add message to database
        String roomname = senderIdx + "_" + _myId;
        if (senderIdx > _myId)
            roomname = _myId + "_" + senderIdx;

        String time = "";

        timeStamp = timeStamp.replace("T", " ");

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

        Date when = new Date();
        try {

            when = sdf.parse(timeStamp);

            sdf = new SimpleDateFormat("yyyyMMdd,HH:mm:ss");
            time = sdf.format(when);

        }catch (Exception ex) {
        }

        final GroupChatItem chatItem = new GroupChatItem(chatIdx, roomname, message, GroupChatItem.ChatType.TEXT.ordinal(), time);
        Database.createMessage(chatItem);


        // update room recent info
        RoomEntity room;
        if (Commons.g_currentActivity != null) {

            room = Commons.g_user.getRoom(roomname);
            // room recent info update
            if (Commons.g_currentActivity.getClass().equals(MsgActivity.class)) {
                Commons.g_currentActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ((MsgActivity) Commons.g_currentActivity).refresh();
                    }
                });
            }

        } else {
            room = Database.getRoom(roomname);
        }

        if (room != null) {

            room.set_recentContent(chatItem.getMessage());
            room.set_recentTime(time);
            Database.updateRoom(room);
        }

        if (Commons.g_chattingActivity != null) {
            Commons.g_chattingActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Commons.g_chattingActivity.addChat(chatItem);
                }
            });
        }

    }

    public void initVideoChatting() {

        PreferenceManager.setDefaultValues(this, R.xml.preferences, false);
        sharedPref = PreferenceManager.getDefaultSharedPreferences(this);
        keyprefVideoCallEnabled = getString(R.string.pref_videocall_key);
        keyprefCamera2 = getString(R.string.pref_camera2_key);
        keyprefResolution = getString(R.string.pref_resolution_key);
        keyprefFps = getString(R.string.pref_fps_key);
        keyprefCaptureQualitySlider = getString(R.string.pref_capturequalityslider_key);
        keyprefVideoBitrateType = getString(R.string.pref_startvideobitrate_key);
        keyprefVideoBitrateValue = getString(R.string.pref_startvideobitratevalue_key);
        keyprefVideoCodec = getString(R.string.pref_videocodec_key);
        keyprefHwCodecAcceleration = getString(R.string.pref_hwcodec_key);
        keyprefCaptureToTexture = getString(R.string.pref_capturetotexture_key);
        keyprefAudioBitrateType = getString(R.string.pref_startaudiobitrate_key);
        keyprefAudioBitrateValue = getString(R.string.pref_startaudiobitratevalue_key);
        keyprefAudioCodec = getString(R.string.pref_audiocodec_key);
        keyprefNoAudioProcessingPipeline = getString(R.string.pref_noaudioprocessing_key);
        keyprefAecDump = getString(R.string.pref_aecdump_key);
        keyprefOpenSLES = getString(R.string.pref_opensles_key);
        keyprefDisableBuiltInAec = getString(R.string.pref_disable_built_in_aec_key);
        keyprefDisableBuiltInAgc = getString(R.string.pref_disable_built_in_agc_key);
        keyprefDisableBuiltInNs = getString(R.string.pref_disable_built_in_ns_key);
        keyprefEnableLevelControl = getString(R.string.pref_enable_level_control_key);
        keyprefDisplayHud = getString(R.string.pref_displayhud_key);
        keyprefTracing = getString(R.string.pref_tracing_key);
        keyprefRoomServerUrl = getString(R.string.pref_room_server_url_key);
    }

    private void connectToRoom(String roomId, String username, boolean loopback, int runTimeMs, boolean videoEnabled, boolean isSender, int otherIdx) {
        // Get room name (random for loopback).

        String roomUrl = ReqConst.WEBRTC_SERVER;

        // Video call enabled flag.
//        boolean videoCallEnabled = sharedPref.getBoolean(keyprefVideoCallEnabled,
//                Boolean.valueOf(getString(R.string.pref_videocall_default)));

        // Use Camera2 option.
        boolean useCamera2 = sharedPref.getBoolean(keyprefCamera2,
        Boolean.valueOf(getString(R.string.pref_camera2_default)));
        // Get default codecs.
        String videoCodec = sharedPref.getString(keyprefVideoCodec,
                getString(R.string.pref_videocodec_default));
        String audioCodec = sharedPref.getString(keyprefAudioCodec,
                getString(R.string.pref_audiocodec_default));

        // Check HW codec flag.
        boolean hwCodec = sharedPref.getBoolean(keyprefHwCodecAcceleration,
                Boolean.valueOf(getString(R.string.pref_hwcodec_default)));

        // Check Capture to texture.
        boolean captureToTexture = sharedPref.getBoolean(keyprefCaptureToTexture,
                Boolean.valueOf(getString(R.string.pref_capturetotexture_default)));

        // Check Disable Audio Processing flag.
        boolean noAudioProcessing = sharedPref.getBoolean(
                keyprefNoAudioProcessingPipeline,
                Boolean.valueOf(getString(R.string.pref_noaudioprocessing_default)));

        // Check Disable Audio Processing flag.
        boolean aecDump = sharedPref.getBoolean(
                keyprefAecDump,
                Boolean.valueOf(getString(R.string.pref_aecdump_default)));

        // Check OpenSL ES enabled flag.
        boolean useOpenSLES = sharedPref.getBoolean(
                keyprefOpenSLES,
                Boolean.valueOf(getString(R.string.pref_opensles_default)));

        // Check Disable built-in AEC flag.
        boolean disableBuiltInAEC = sharedPref.getBoolean(
            keyprefDisableBuiltInAec,
            Boolean.valueOf(getString(R.string.pref_disable_built_in_aec_default)));

        // Check Disable built-in AGC flag.
        boolean disableBuiltInAGC = sharedPref.getBoolean(
            keyprefDisableBuiltInAgc,
            Boolean.valueOf(getString(R.string.pref_disable_built_in_agc_default)));

        // Check Disable built-in NS flag.
        boolean disableBuiltInNS = sharedPref.getBoolean(
            keyprefDisableBuiltInNs,
            Boolean.valueOf(getString(R.string.pref_disable_built_in_ns_default)));

        // Check Enable level control.
        boolean enableLevelControl = sharedPref.getBoolean(
            keyprefEnableLevelControl,
            Boolean.valueOf(getString(R.string.pref_enable_level_control_key)));
            // Get video resolution from settings.
            int videoWidth = 0;
            int videoHeight = 0;
            String resolution = sharedPref.getString(keyprefResolution,
                    getString(R.string.pref_resolution_default));

        String[] dimensions = resolution.split("[ x]+");
        if (dimensions.length == 2) {
            try {
                videoWidth = Integer.parseInt(dimensions[0]);
                videoHeight = Integer.parseInt(dimensions[1]);
            } catch (NumberFormatException e) {
                videoWidth = 0;
                videoHeight = 0;
            }
        }

        // Get camera fps from settings.
        int cameraFps = 0;
        String fps = sharedPref.getString(keyprefFps,
                getString(R.string.pref_fps_default));
        String[] fpsValues = fps.split("[ x]+");
        if (fpsValues.length == 2) {
            try {
                cameraFps = Integer.parseInt(fpsValues[0]);
            } catch (NumberFormatException e) {
            }
        }

        // Check capture quality slider flag.
        boolean captureQualitySlider = sharedPref.getBoolean(keyprefCaptureQualitySlider,
                Boolean.valueOf(getString(R.string.pref_capturequalityslider_default)));

        // Get video and audio start bitrate.
        int videoStartBitrate = 0;
        String bitrateTypeDefault = getString(
                R.string.pref_startvideobitrate_default);
        String bitrateType = sharedPref.getString(
                keyprefVideoBitrateType, bitrateTypeDefault);
        if (!bitrateType.equals(bitrateTypeDefault)) {
            String bitrateValue = sharedPref.getString(keyprefVideoBitrateValue,
                    getString(R.string.pref_startvideobitratevalue_default));
            videoStartBitrate = Integer.parseInt(bitrateValue);
        }
        int audioStartBitrate = 0;
        bitrateTypeDefault = getString(R.string.pref_startaudiobitrate_default);
        bitrateType = sharedPref.getString(
                keyprefAudioBitrateType, bitrateTypeDefault);
        if (!bitrateType.equals(bitrateTypeDefault)) {
            String bitrateValue = sharedPref.getString(keyprefAudioBitrateValue,
                    getString(R.string.pref_startaudiobitratevalue_default));
            audioStartBitrate = Integer.parseInt(bitrateValue);
        }

        // Check statistics display option.
        boolean displayHud = sharedPref.getBoolean(keyprefDisplayHud,
                Boolean.valueOf(getString(R.string.pref_displayhud_default)));

        boolean tracing = sharedPref.getBoolean(
                keyprefTracing, Boolean.valueOf(getString(R.string.pref_tracing_default)));

        // Start AppRTCDemo activity.
        if (validateUrl(roomUrl)) {
            Uri uri = Uri.parse(roomUrl);
            Intent intent = new Intent(this, CallActivity.class);
            intent.setData(uri);
            intent.putExtra(CallActivity.EXTRA_USERNAME, username);
            intent.putExtra(CallActivity.EXTRA_ROOMID, roomId);
            intent.putExtra(CallActivity.EXTRA_LOOPBACK, loopback);
            intent.putExtra(CallActivity.EXTRA_VIDEO_CALL, videoEnabled);
            intent.putExtra(CallActivity.EXTRA_CAMERA2, useCamera2);
            intent.putExtra(CallActivity.EXTRA_VIDEO_WIDTH, videoWidth);
            intent.putExtra(CallActivity.EXTRA_VIDEO_HEIGHT, videoHeight);
            intent.putExtra(CallActivity.EXTRA_VIDEO_FPS, cameraFps);
            intent.putExtra(CallActivity.EXTRA_VIDEO_CAPTUREQUALITYSLIDER_ENABLED,
              captureQualitySlider);
            intent.putExtra(CallActivity.EXTRA_VIDEO_BITRATE, videoStartBitrate);
            intent.putExtra(CallActivity.EXTRA_VIDEOCODEC, videoCodec);
            intent.putExtra(CallActivity.EXTRA_HWCODEC_ENABLED, hwCodec);
            intent.putExtra(CallActivity.EXTRA_CAPTURETOTEXTURE_ENABLED, captureToTexture);
            intent.putExtra(CallActivity.EXTRA_NOAUDIOPROCESSING_ENABLED,
              noAudioProcessing);
            intent.putExtra(CallActivity.EXTRA_AECDUMP_ENABLED, aecDump);
            intent.putExtra(CallActivity.EXTRA_OPENSLES_ENABLED, useOpenSLES);
            intent.putExtra(CallActivity.EXTRA_DISABLE_BUILT_IN_AEC, disableBuiltInAEC);
            intent.putExtra(CallActivity.EXTRA_DISABLE_BUILT_IN_AGC, disableBuiltInAGC);
            intent.putExtra(CallActivity.EXTRA_DISABLE_BUILT_IN_NS, disableBuiltInNS);
            intent.putExtra(CallActivity.EXTRA_ENABLE_LEVEL_CONTROL, enableLevelControl);
            intent.putExtra(CallActivity.EXTRA_AUDIO_BITRATE, audioStartBitrate);
            intent.putExtra(CallActivity.EXTRA_AUDIOCODEC, audioCodec);
            intent.putExtra(CallActivity.EXTRA_DISPLAY_HUD, displayHud);
            intent.putExtra(CallActivity.EXTRA_TRACING, tracing);
            intent.putExtra(CallActivity.EXTRA_CMDLINE, commandLineRun);
            intent.putExtra(CallActivity.EXTRA_RUNTIME, runTimeMs);
            intent.putExtra(CallActivity.EXTRA_ISSENDER, isSender);
            intent.putExtra(CallActivity.EXTRA_OTHERIDX, otherIdx);

            if (Commons.g_commonActivity != null)
                Commons.g_commonActivity.startActivityForResult(intent, CONNECTION_REQUEST);
            else if (Commons.g_chattingActivity != null)
                Commons.g_chattingActivity.startActivityForResult(intent, CONNECTION_REQUEST);
            else if (Commons.g_currentActivity != null)
                Commons.g_currentActivity.startActivityForResult(intent, CONNECTION_REQUEST);
        }
    }

    private boolean validateUrl(String url) {
        if (URLUtil.isHttpsUrl(url) || URLUtil.isHttpUrl(url)) {
            return true;
        }

        new AlertDialog.Builder(this)
                .setTitle(getText(R.string.invalid_url_title))
                .setMessage(getString(R.string.invalid_url_text, url))
                .setCancelable(false)
                .setNeutralButton(R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                }).create().show();
        return false;
    }

    public void showCallRequestActivity(final int fromUserId, final String fromUserName, final String room, boolean videoEnabled) {

        Intent intent = new Intent(Commons.g_xmppService, CallRequestActivity.class);
        intent.putExtra(Constants.VIDEO_CALLER_NAME, fromUserName);
        intent.putExtra(Constants.VIDEO_CALLER_ID, fromUserId);
        intent.putExtra(Constants.VIDEO_ROOM_ID, room);
        intent.putExtra(Constants.VIDEO_ENABLED, videoEnabled);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);

    }

    public int getRandomRoomNumber() {

        Random r = new Random();
        return 100000 + r.nextInt(900000);

    }

    public void processLogout() {

        Commons.g_isAppRunning = false;

        Preference.getInstance().put(this, PrefConst.PREFKEY_USEREMAIL, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_USERPWD, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_XMPPID, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_WECHATID, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_QQID, "");
        Commons.g_xmppService.disconnect();

        gotoLogin();
    }


    public void gotoLogin() {

        if (Commons.g_chattingActivity != null)
            Commons.g_chattingActivity.finish();

        if (Commons.g_onlineActivity != null)
            Commons.g_onlineActivity.finish();

        if (Commons.g_commonActivity != null)
            Commons.g_commonActivity.finish();

        if (Commons.g_currentActivity != null)
            Commons.g_currentActivity.finish();

        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
    }

}
