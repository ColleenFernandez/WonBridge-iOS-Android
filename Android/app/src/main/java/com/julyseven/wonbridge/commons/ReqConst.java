package com.julyseven.wonbridge.commons;

/**
 * Created by HGS on 12/11/2015.
 */
public class ReqConst {

    public static final String SERVER_ADDR = "http://52.78.120.201";
    public static final String CHATTING_SERVER = "52.78.120.201";
    public static final String WEBRTC_SERVER = "http://52.78.101.116:8080";

    public static final String ROOM_SERVICE = "@conference.";

    public static final String SERVER_URL = SERVER_ADDR + "/index.php/api/";
    public static final String UPLOADPATH = SERVER_ADDR + "/uploadfiles";

    public static final String REQ_LOGIN = "login";
    public static final String REQ_LOGINWECHAT = "loginWithWechat";
    public static final String REQ_LOGINQQ = "loginWithQQ";
    public static final String REQ_GETUSERINFOBYID = "getUserInfoById";
    public static final String REQ_GETFRIENDLIST = "getFriendList";
    public static final String REQ_UPLOADFILE = "uploadFile";
    public static final String REQ_GETROOMINFO = "getRoomInfo";
    public static final String REQ_GETROOMANDGROUPINFO = "getRoomAndGroupInfo";
    public static final String REQ_GETAUTHCODE = "getAuthCode";
    public static final String REQ_GETRECOVERYCODE = "getRecoveryCode";
    public static final String REQ_CONFIRMAUTHCODE = "confirmAuthCode";
    public static final String REQ_TEMPPASSWORD = "getTempPassword";
    public static final String REQ_CHECKNICKNAME = "checkNickName";
    public static final String REQ_CHANGEPASSWORD = "changePassword";
    public static final String REQ_CHANGENICKNAME = "changeNickName";
    public static final String REQ_REGISTER = "register";
    public static final String REQ_REGISTERWITHPHONE = "registerWithPhone";
    public static final String REQ_REGISTERWITHWECHAT = "registerWithWechat";
    public static final String REQ_REGISTERWITHQQ = "registerWithQQ";
    public static final String REQ_UPLOADPROFILE = "uploadProfile";
    public static final String REQ_GETNEARBYTIMELINE = "getNearbyTimeline";
    public static final String REQ_GETNEARBYGROUP = "getNearbyGroup";
    public static final String REQ_GETMYTIMELINE = "getMyTimeLine";
    public static final String REQ_SAVETIMELINE = "saveTimeLine";
    public static final String REQ_SAVETEXTTIMELINE = "saveTextTimeline";
    public static final String REQ_MAKEFRIEND = "makeFriend";
    public static final String REQ_DELETEFRIEND = "deleteFriend";
    public static final String REQ_SETPUBLICTIMELINE = "setPublicTimeline";
    public static final String REQ_SETPUBLICLOCATION = "setPublicLocation";
    public static final String REQ_SETLOCATION = "setLocation";
    public static final String REQ_GETNEARBYUSER = "getNearbyUser";
    public static final String REQ_GETTIMELINEDETAIL = "getTimelineDetail";
    public static final String REQ_LIKETIMELINE = "likeTimeline";
    public static final String REQ_UNLIKETIMELINE = "unlikeTimeline";
    public static final String REQ_SAVERESPOND = "saveRespond";
    public static final String REQ_GETBLOCKUSERS = "getBlockUser";
    public static final String REQ_SETBLOCKUSER = "setBlockUser";
    public static final String REQ_SETUNBLOCKUSER = "setUnblockUser";
    public static final String REQ_BLOCKFRIENDLIST = "blockFriendList";
    public static final String REQ_MAKEGROUP = "makeGroup";
    public static final String REQ_SETGROUPPROFILE = "setGroupProfile";
    public static final String REQ_SETGROUPNICKNAME = "setGroupNickname";
    public static final String REQ_SETGROUPPARTICIPANT = "setGroupParticipant";
    public static final String REQ_GETALLGROUP = "getAllGroup";
    public static final String REQ_SEARCHUSER = "searchUser";
    public static final String REQ_SEARCHGROUP = "searchGroup";
    public static final String REQ_SETGROUPOWNER = "setGroupOwner";
    public static final String REQ_GETONLINEMESSAGE = "getOnlineMessage";
    public static final String REQ_SENDONLINEMESSAGE = "sendOnlineMessage";
    public static final String REQ_SETCOUNTRY = "setCountry";
    public static final String REQ_GETNEARBYTIMELINEDETAIL = "getNearbyTimelineWithDetail";
    public static final String REQ_GETMYTIMELINEWITHDETAIL = "getMyTimeLineWithDetail";
    public static final String REQ_DELETETIMELINE = "deleteMyTimeline";
    public static final String REQ_GETNOTE = "getNote";
    public static final String REQ_REGISTERTOKEN = "registerToken";
    public static final String REQ_CHECKDEVICEID = "checkDeviceId";
    public static final String REQ_LOGOUT = "logout";
    public static final String REQ_SETPAYMENT = "setPayment";
    public static final String REQ_SETSCHOOL = "setSchool";
    public static final String REQ_SETVILLAGE = "setVillage";
    public static final String REQ_SETCOUNTRY2 = "setCountry2";
    public static final String REQ_SETWORKING = "setWorking";
    public static final String REQ_SETINTEREST = "setInterest";
    public static final String REQ_GROUPREQUEST = "groupRequest";
    public static final String REQ_GETGROUPREQUEST = "getGroupRequest";
    public static final String REQ_ACCEPTGROUPREQUEST = "acceptGroupRequest";
    public static final String REQ_DECLINEGROUPREQUEST = "declineGroupRequest";
    public static final String REQ_GETGROUPREQUESTBYID = "getGroupRequestById";
    public static final String REQ_GETGROUPPROFILE = "getGroupProfile";
    public static final String REQ_SENDCALL = "sendCall";
    public static final String REQ_CANCELCALL = "cancelCall";
    public static final String REQ_GETCALLREQUEST = "getCallRequest";
    public static final String REQ_GETSERVICECATEGORIES = "getServiceCategories";
    public static final String REQ_GETSUBCATEGORIES = "getSubCategories";


    //request params
    public static final String PARAM_ID = "id";
    public static final String PARAM_TYPE = "type";
    public static final String PARAM_FILENAME = "filename";
    public static final String PARAM_NAME = "name";
    public static final String PARAM_FILE = "file";
    public static final String PARAM_FRIENDLIST = "friend_list";
    public static final String PARAM_CONTENT = "content";
    public static final String PARAM_LATITUDE = "latitude";
    public static final String PARAM_LONGITUDE = "longitude";
    public static final String PARAM_TIMELINEID = "timeline_id";
    public static final String PARAM_USERID = "user_id";
    public static final String PARAM_MESSAGE = "message";
    public static final String PARAM_ISIMAGE = "is_image";
    public static final String PARAM_WIDTH = "width";
    public static final String PARAM_HEIGHT = "height";
    public static final String PARAM_GROUPNAME = "group_name";


    //response value
    public static final String RES_CODE = "result_code";
    public static final String RES_IDX = "idx";
    public static final String RES_USERINFO = "user_info";
    public static final String RES_USERINFOS = "user_infos";
    public static final String RES_FRIENDINFOS = "friend_infos";
    public static final String RES_GROUPINFOS = "group_infos";
    public static final String RES_GROUPINFO = "group_info";
    public static final String RES_TIMELINE = "time_line";
    public static final String RES_NAME = "name";
    public static final String RES_NICKNAME = "nickname";
    public static final String RES_EMAIL = "email";
    public static final String RES_LABEL = "label";
    public static final String RES_BG_URL = "bg_url";
    public static final String RES_PHOTO_URL = "photo_url";
    public static final String RES_PHONE_NUMBER = "phone_number";
    public static final String RES_FILE_URL = "file_url";
    public static final String RES_FILENAME = "filename";
    public static final String RES_ISFRIEND = "is_friend";
    public static final String RES_CONTENT = "content";
    public static final String RES_USERNAME = "user_name";
    public static final String RES_USERID = "user_id";
    public static final String RES_ID = "id";
    public static final String RES_ISPUBLICLOCATION = "is_location_public";
    public static final String RES_ISPUBLICTIMELINE = "is_timeline_public";
    public static final String RES_SEX = "sex";
    public static final String RES_LATITUDE = "latitude";
    public static final String RES_LONGITUDE = "longitude";
    public static final String RES_LASTLOGIN = "last_login";
    public static final String RES_REGTIME = "reg_time";
    public static final String RES_REGDATE = "reg_date";
    public static final String RES_LINK = "link";
    public static final String RES_TYPE = "type";
    public static final String RES_LIKECOUNT = "like_count";
    public static final String RES_RESPONDCOUNT = "respond_count";
    public static final String RES_LIKEUSERLIST = "like_user_list";
    public static final String RES_RESPONDUSERLIST = "respond_user_list";
    public static final String RES_ISLIKE = "is_like";
    public static final String RES_RESPONDTIME = "respond_time";
    public static final String RES_RESTEMPPWD = "temp_password";
    public static final String RES_PARTICIPANT = "participant";
    public static final String RES_PROFILE = "profile";
    public static final String RES_MESSAGEINFOS = "message_infos";
    public static final String RES_MESSAGE = "message";
    public static final String RES_COUNTRY = "country";
    public static final String RES_RESPONDINFO = "respond_info";
    public static final String RES_LIKEUSERNAME = "like_username";
    public static final String RES_WECHATID = "wechat_id";
    public static final String RES_QQID = "qq_id";
    public static final String RES_NOTEINFO = "note_info";
    public static final String RES_HEIGHT = "height";
    public static final String RES_WIDTH = "width";
    public static final String RES_SCHOOL = "school";
    public static final String RES_VILLAGE = "village";
    public static final String RES_COUNTRY2 = "country2";
    public static final String RES_WORKING = "working";
    public static final String RES_INTEREST = "interest";
    public static final String RES_ISREQUEST = "is_request";
    public static final String RES_GROUPREQUESTS = "group_requests";
    public static final String RES_USERPHOTO = "user_photo";
    public static final String RES_GROUPURLS = "group_urls";
    public static final String RES_CATEGORYINFOS = "category_infos";
    public static final String RES_SUBCATEGORY = "sub_category";

    public static final int CODE_SUCCESS = 0;
    public static final int CODE_UNREGUSER = 104;
    public static final int CODE_INVALIDPWD = 105;


}
