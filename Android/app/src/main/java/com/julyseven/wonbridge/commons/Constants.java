package com.julyseven.wonbridge.commons;

/**
 * Created by sss on 8/24/2016.
 */
public class Constants {

    public static final String WECHAT_APP_ID = "wx37b6e49959b8ea38";
    public static final String WECHAT_SECRET = "77492c4eacef8b830e3925098ec1023b";
    public static final String MCH_ID = "1396879002";

    public static final String QQ_APP_ID = "101353369";
    public static final String QQ_SECRET = "8cca3c1194a20f85f21dc1c7ed66e3e7";

    public static final String BAIDU_PUSH_APIKEY = "4HicppDiCRl7Esso7lGFQOVIDKBTKFcX";
    public static final String BAIDU_PUSH_SECKEY = "AvEUdIFTuTh6EAD1Ss8vw0u9SSP7Pkao";

    public static final String WONBRIDGE = "WonBridge";

    public static final int VOLLEY_TIME_OUT = 60000;
    public static final int LOCATION_DELAY = 2000;

    public static final int LIMIT_FILE = 25 * 1024 * 1024;

    public static final int PROFILE_IMAGE_SIZE = 256;

    public static final int RECENT_MESSAGE_COUNT = 20;

    public static final int MAX_IMAGE_COUNT = 9;

    public static final int SPLASH_TIME = 2000;
    public static final int PICK_FROM_CAMERA = 100;
    public static final int PICK_FROM_ALBUM = 101;
    public static final int CROP_FROM_CAMERA = 102;
    public static final int EMAIL_VERIFICATION = 103;
    public static final int PICK_FROM_VIDEO = 104;
    public static final int PICK_FROM_FILE = 105;
    public static final int PICK_FROM_INVITE  = 106;
    public static final int PICK_FROM_SETTING  = 107;
    public static final int PICK_FROM_NICKNAME  = 108;
    public static final int PICK_FROM_GPSSETTINGS = 109;
    public static final int PICK_FROM_COUNTRY = 110;
    public static final int PICK_FROM_GROUPINFO = 111;
    public static final int PICK_FROM_BANISH = 112;
    public static final int PICK_FROM_DELEGATE = 113;
    public static final int PICK_FROM_GROUPNOTI = 114;
    public static final int PICK_FROM_ALLTEXT = 115;
    public static final int PICK_FROM_IMAGES = 116;
    public static final int PICK_FROM_SCHOOL = 117;
    public static final int PICK_FROM_VILLAGE = 118;
    public static final int PICK_FROM_EDITWORKING = 119;
    public static final int PICK_FROM_EDITINTEREST = 120;
    public static final int PICK_FROM_EDITSCHOOL = 121;
    public static final int PICK_FROM_EDITVILLAGE = 122;
    public static final int PICK_FROM_EDITCOUNTRY2 = 123;

    public static final int REQUST_PERMISSION = 150;

    public static final int INPUT_STATE_MESSAGE = 200;
    public static final int INPUT_NAME = 201;

    public static final String KEY_ADDRESS = "address";
    public static final String KEY_ROOM = "room";
    public static final String KEY_ROOM_TITLE = "room_title";
    public static final String KEY_FROMLOGIN = "fromlogin";
    public static final String KEY_EMAIL = "email";
    public static final String KEY_LOGOUT = "logout";
    public static final String KEY_FRIEND = "friend";
    public static final String KEY_FILE = "file";
    public static final String KEY_NEWPARTICIPANTS = "participants";
    public static final String KEY_BANISHPARTICIPANTS = "banish_participants";
    public static final String KEY_USER_ID = "userid";
    public static final String KEY_ROOMUSER = "roomuser";
    public static final String KEY_ROOMID = "roomid";
    public static final String KEY_LIKEUSER = "like_users";
    public static final String KEY_USERNAME = "username";
    public static final String KEY_FRIENDREQUEST = "friend_request";
    public static final String KEY_LATITUDE = "latitude";
    public static final String KEY_LONGITUDE = "longitude";
    public static final String KEY_RADIUS = "radius";
    public static final String KEY_NEARBYUSERS = "nearby_users";
    public static final String KEY_VIDEOPATH = "video_path";
    public static final String KEY_IMAGEPATH = "image_path";
    public static final String KEY_EMOJI_PAGE = "emoji_page";
    public static final String KEY_MEMBERS = "members";
    public static final String KEY_GROUP = "group";
    public static final String KEY_INVITE = "invite";
    public static final String KEY_GROUPOUT = "group_out";
    public static final String KEY_DELEGATE = "group_delegate";
    public static final String KEY_DELEGATEIDX = "group_delegate_idx";
    public static final String KEY_GROUPNAME = "group_name";
    public static final String KEY_GROUPNOTI = "group_noti";
    public static final String KEY_ONLINE_SERVICE = "online_service";
    public static final String KEY_ONLINE_SERVICEROOM = "online";
    public static final String KEY_ALLTEXT = "all_text";
    public static final String KEY_TIMELINE = "timeline";
    public static final String KEY_PHONENUMBER = "phonenumber";
    public static final String KEY_WECHATID = "wechat_id";
    public static final String KEY_QQID = "qq_id";
    public static final String KEY_IMAGES = "images";
    public static final String KEY_COUNT = "count";
    public static final String KEY_PHOTOPATH = "photo_path";
    public static final String KEY_FROM_1_1 = "from_1_1";

    public static final String KEY_SEPERATOR = "#";
    public static final String KEY_FILE_MARKER = "FILE#";
    public static final String KEY_IMAGE_MARKER = "IMAGE#";
    public static final String KEY_VIDEO_MARKER = "VIDEO#";
    public static final String KEY_ROOM_MARKER = "ROOM#";
    public static final String KEY_SYSTEM_MARKER = "SYSTEM#";

    public static final String KEY_LEAVEROOM_MARKER = "LEAVE**ROOM";
    public static final String KEY_GROUPNOTI_MARKER = "[GROUP NOTI]\n";
    public static final String KEY_DELEGATE_MARKER = "DELEGATE**ROOM";
    public static final String KEY_INVITE_MARKER = "INVITE**ROOM";
    public static final String KEY_BANISH_MARKER = "BANISH**ROOM";
    public static final String KEY_ADD_MARKER = "ADD**ROOM";
    public static final String KEY_REQUEST_MARKER = "REQUEST**ROOM";


    public static final String KEY_ONLY_COUNTRY = "only_country";
    public static final String KEY_COUNTRY = "country";
    public static final String KEY_SCHOOL = "school";
    public static final String KEY_VILLAGE = "village";
    public static final String KEY_CHANGE_COUNTRY2 = "change_country2";


    public static final String XMPP_START = "xmpp";
    public static final int XMPP_FROMBROADCAST = 0;
    public static final int XMPP_FROMLOGIN = 1;

    public static final int NORMAL_NOTI_ID = 1;

    public static final int ANDROID = 0;

    public static final String VIDEO_CHATTING_SENT = "video chat request sent.";
    public static final String VIDEO_CHATTING_ACCEPT = "video chat accepted.";
    public static final String VIDEO_CHATTING_DECLINE = "video chat declined.";
    public static final String VIDEO_CHATTING_CANCEL = "video chat canceled.";

    public static final String FRIEND_REQUEST_SENT = " sent friend request.";
    public static final String FRIEND_REQUEST_ACCEPT = " accepted friend request.";

    public static final String VIDEO_CALLER_NAME = "caller_name";
    public static final String VIDEO_CALLER_ID = "caller_id";
    public static final String VIDEO_ROOM_ID = "room_id";
    public static final String VIDEO_ENABLED = "video_enabled";

    public static final int PAGE_SIZE = 30;

    public static final String DEFAULT_GROUPNAME = "Group";

    public static final String DEFAULT_WECHAT_PWD = "wechat";
    public static final String DEFAULT_QQ_PWD = "qqpwd";

    public static final String SLASH = "ssllaasshh";

}
