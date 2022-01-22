//
//  Contstants.swift
//  WonBridge
//
//  Created by Saville Briard on 16/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

class Constants: NSObject {
    
    static let SAVE_ROOT_PATH               =       "WonBridge"
    
    static let UPLOAD_FILE_PATH             =       "WonBridge/upload_files"
    static let DOWNLOAD_FILE_PATH           =       "WonBridge/download_files"
    
    static let BAIDU_MAP_KEY                =       "vwfwqy2GGtD7Gr2L9sYiC9iG3WumheA0"
    
    static let GOOGLE_MAP_KEY               =       "AIzaSyBBu5J46bhuzTPg8odxVESWzUMSl4hk-kc"
    
    static let WECHAT_APP_ID                =       "wx37b6e49959b8ea38"
    static let WECHAT_SECRET                =       "77492c4eacef8b830e3925098ec1023b"
    static let WECHAT_MCH_ID                =       "1396879002"
    
    static let WECHAT_ACCESSTOKEN_PREFIX    =       "https://api.weixin.qq.com/sns/oauth2/access_token?"
    static let WECHAT_USERINFO_PREFIX       =       "https://api.weixin.qq.com/sns/userinfo?"
    
    static let QQ_APPID                     =       "101353369"
    static let QQ_SECRET                    =       "8cca3c1194a20f85f21dc1c7ed66e3e7"
    
    static let TIMELINE_IMAGE_PREFIX        =       "timeline_"
    
    static let LOCALE_CN                    =       "CN"
        
    /**********************************************/
    // UserDefault Key
    /**********************************************/
    static let PREFKEY_AUTOLOGOUT           =       "auto_logout"
    static let pref_user_loggedin           =       "isLoggedIn"
    static let pref_user_id                 =       "pref_user_id"
    static let pref_user_passsowrd          =       "pref_user_password"
    static let pref_user_phonenumber        =       "pref_user_phonenumber"
    static let pref_user_name               =       "pref_username"
    static let pref_user_email              =       "pref_useremail"
    static let pref_user_photoURL           =       "pref_photourl"
    static let pref_user_wechatId           =       "pref_user_wechatId"
    static let pref_user_qqId               =       "pref_user_qqId"
    static let pref_device_token            =       "pref_device_token"
    
    static let PREF_USER_LAT                =       "user_latitude"
    static let PREF_USER_LONG               =       "user_longitude"
    
    static let PREF_WECHAT_OPENID           =       "wechat_openid"
    static let PREFKEY_WECHAT_PHOTOURL      =       "wechat_photoUrl"
    static let PREFKEY_WECHAT_NICKNAME      =       "wechat_nickname"
    
    static let PREFKEY_QQID                 =       "qqid"
    static let PREFKEY_QQ_OPENID            =       "qq_openid"
    static let PREFKEY_QQ_PHOTOURL          =       "qq_photo_url"
    static let PREFKEY_QQ_NICKNAME          =       "qq_nickname"
    
    // time-line filter
    static let PREFKEY_DISTANCE             =       "pref_distance";
    static let PREFKEY_AGE_START            =       "pref_age_start";
    static let PREFKEY_AGE_END              =       "pref_age_end";
    static let PREFKEY_SEX                  =       "pref_sex";
    static let PREFKEY_LASTLOGIN            =       "pref_last_login";
    static let PREFKEY_RELATION             =       "pref_relation";
    
    // chatting alarm 
    static let pref_alarm_on_off            =       "alarm_on_off"
    
    static let PREFKEY_NOTISOUND            =       "sound_"
    static let PREFKEY_TOP                  =       "top_"
    
    /**********************************************/
    // message protocol string
    /**********************************************/
    static let KEY_SEPERATOR                =       "#"
    static let KEY_ROOM_MARKER              =       "ROOM#"
    static let KEY_VIDEO_MARKER             =       "VIDEO#"
    static let KEY_IMAGE_MARKER             =       "IMAGE#"
    static let KEY_FILE_MARKER              =       "FILE#"
    static let KEY_SYSTEM_MARKER            =       "SYSTEM#"
    
    static let KEY_GROUPNOTI_MARKER         =       "[GROUP NOTI]\n"
    static let KEY_LEAVEROOM_MARKER         =       "LEAVE**ROOM"
    static let KEY_DELEGATE_MARKER          =       "DELEGATE**ROOM"
    static let KEY_INVITE_MARKER            =       "INVITE**ROOM"
    static let KEY_BANISH_MARKER            =       "BANISH**ROOM"
    static let KEY_REQUEST_MARKER           =       "REQUEST**ROOM"
    static let KEY_ADD_MARKER               =       "ADD**ROOM"
    
    static let VIDEO_CHATTING_SENT          =       "video chat request sent."
    static let VIDEO_CHATTING_ACCEPT        =       "video chat accepted."
    static let VIDEO_CHATTING_DECLINE       =       "video chat declined."
    static let VIDEO_CHATTING_CANCEL        =       "video chat canceled."
    
    static let KEY_ONLINE_SERVICEROOM       =       "online"
    
    static let TIME_AM                      =       "上午"
    static let TIME_PM                      =       "下午"
    
    static let GALLERY_IS_PICTURE           =       "PICTURE"      // image collection view
    static let GALLERY_IS_VIDEO             =       "VIDEO"        // video collection view
    
    static let KEY_QQID                     =       "qq_id"
    static let DEFAULT_QQ_PWD               =       "qqpwd"
    
    /**********************************************/
    // app string here
    /**********************************************/
    
    /**** call log message *****/
    static let CALL_DECLINED_BYOTHER        =       "Call declined"
    static let CALL_DECLINED_BYME           =       "Declined"
    static let CALL_CANCELLED_BYOTHER       =       "Call cancelled by caller"
    static let CALL_CANCELLED_BYME          =       "Cancelled"
    static let CALL_DURATION                =       "Duration: "
    static let CALL_NO_ANSWER               =       "Call was not answered"
    
    static let APP_NAME                     =   "WonBridge"
    static let ALERT_OK                     =   "确认"
    static let ALERT_CANCEL                 =   "撤消"
    
    static let TAB_MESSAGE_TITLE            =   "消息记录"
    
    
    static let TITLE_LOGOUT                 =   "确定要退出乔乔吗？"
    static let WRONG_DEVICE                 =   "다른 폰에서 로그인되어 있습니다. 다른 폰을 로그아웃시키겠습니까?"
    static let TITLE_BANISH_ALERT           =   "선택한 멤버를 추방하시겠습니까."
    static let TITLE_DELEGATE_ALERT         =   "님에게 그룹장권한을 위임하시겠습니까."
    static let TITLE_LEAVE_ROOM_OWNER       =   "그룹정보설정에서 그룹장권한을 위임해야만 방을 나가실수 있습니다."
    
    static let GROUP_REQUEST                =   "그룹장에게 보낼 참여 신청 메시지를 적어주세요."
    static let NOTE_GROUP_REQUEST           =   "신청이 완료되었습니다.\n그룹장이 수락하면, 그룹대화방에 자동으로 입장합니다"
    static let NOTE_GROUP_ACCEPT            =  "수락을 누르시면, 채팅방에 자동으로 참여됩니다."
    static let GROUP_REQUEST_MSG            =   " has sent request to join group."
    static let DEFAULT_REQUEST_MSG          =   "I 'd like to join the group."
    static let ADDED_TO_ROOM                =   " has been added to the group."
    
    
    
    static let TITLE_CONFIRM_DELETE         =   "確定要删除该聊天吗?"
    
    static let TITLE_ONLINE_SERVICE         =   "在线咨询"
    
    
    
    static let INPUT_NAME                   =   "请输入姓名."
    static let INPUT_PASSWORD               =   "密码必须是4~15位。"
    
    // Timeline, User, Group ViewController
    static let SLIDE_TIMELINE               =   "动态"
    static let SLIDE_USER                   =   "用户"
    static let SLIDE_GROUP                  =   "群組"
    
    static let DEFAULT_GROUPNAME            =   "Group"
    
    static let SLIDE_CHATTING               =   "会话"
    static let SLIDE_GROUPCHATTING          =   "聊天群"
    static let SLIDE_PARTNER                =   "公众号"
    
    // service
    static let TITLE_SERVICE                =   "商务服务"
    static let TITLE_DEPARTURE              =   "出国咨询"
    
    static let TITLE_PROFILE                =   "的信息"
    
    static let FRIEND_SELECT                =   "选择朋友"
    static let TITLE_CONFIRM                =   "确认"
    
    static let TITLE_SEND                   =   "发送"
    
    
    static let UNIT_AGE                     =   "岁"
    
    static let CONNECTED_CHAT_SERVER        =   "It was connected to the chat server."
    static let DISCONNECTED_CHAT_SERVER     =   "The connection to the chat server has been shut down."
    static let CONNECTING_CHAT_SERVER       =   "It is being connected \nto the chat server."
    
    static let FILE_SENT                    =   "File sent."
    
    static let TITLE_GROUP                  =   "群組"
    static let TITLE_GROUPPROFILE           =   "群組信息"
    
    static let NO_INPUT                     =   "未输入"
    
    // chat setting menu
    static let TEXT_ADD                     =   "加"
    static let TEXT_BLOCK                   =   "屛蔽"
    
    static let SEX_SELECTION                =   "请选择性别"
    static let SEX_MALE                     =   "男子"
    static let SEX_FEMALE                   =   "女子"
    
    static let SEND_CODE                    =   "发送"
    static let RESEND_CODE                  =   "再次发送"
    
    static let TITLE_SHOWLIST               =   "详细信息"
    
    static let TITLE_TIMELINELIST_SUFFIX    =   "的动态"
    
    static let ADD_FRIEND                   =   "添加好友"
    static let DEL_FRIEND                   =   "删除好友"
    
    static let TITLE_CONTENT_ALL            =   "全文"
    static let TITLE_CONTENT_CLOSE          =   "收起"
    
    static let TITLE_DEL                    =   "删除"
    
    // Contact
    static let SLIDE_FRIEND                 =   "好友"
    
    static let PREFIEX_NICKNAME             =   "名称"
    
    static let TITLE_ADD                    =   "添加"
    static let TITLE_ALREADY_ADDED          =   "已添加"
    static let TITLE_INVITE                 =   "邀请"
    static let TITLE_REQUEST                =   "申请"
    static let TITLE_WAITING                =   "等待中"
    
    static let PREFIX_MEMBERCOUNT           =   "成员数"
    static let RREFIX_CREATEDDATE           =   "建群日期"
    
    static let TITLE_EVENT                  =   "活动"
    static let TITLE_CHATBOX                =   "聊天窗"
    static let TITLE_SEARCH                 =   "搜索"
    static let TITLE_COUPON                 =   "代金券"
    
    static let DEPARTURE_SEARCH1            =   "常识"
    static let DEPARTURE_SEARCH2            =   "护照"
    static let DEPARTURE_SEARCH3            =   "国籍"
    static let DEPARTURE_SEARCH4            =   "签证"
    static let DEPARTURE_SEARCH5            =   "机票"
    static let DEPARTURE_SEARCH6            =   "外汇"
    static let DEPARTURE_SEARCH7            =   "交通"
    static let DEPARTURE_SEARCH8            =   "住宿"
    
    static let SERVICE_SEARCH1              =   "家政服务"
    static let SERVICE_SEARCH2              =   "移民中介"
    static let SERVICE_SEARCH3              =   "出国考察"
    static let SERVICE_SEARCH4              =   "文化娱乐"
    static let SERVICE_SEARCH5              =   "出国留学"
    static let SERVICE_SEARCH6              =   "旅游攻略"
    static let SERVICE_SEARCH7              =   "投资置产"
    static let SERVICE_SEARCH8              =   "商品购物"
    
    static let MY_COUPON                    =   "我的代金券"
    static let GOT_COUPON                   =   "获取代金券"
    
    
    static let TAKE_PHOTO                   =   "照片拍摄"
    static let FROM_GALLERY                 =   "从相册选择"
    
    static let ALEADY_EXIST_NICKNAME        =   "已注册的昵称"
    
    static let CONFIRM_PASSWORDERROR        =   "您输入的密码不一致!"
    
    static let TITLE_LIKE_USERS             =   "喜欢的用户"
    
    static let INFO_RADIUS                  =   "半径"
    static let INFO_IN_FRIEND               =   "内 好友"
    
    static let UNIT_PEOPLE                  =   "名"
    static let INFO_PUBLIC                  =   "公开"
    static let INFO_NON_PUBLIC              =   "未公开"
    
    static let STATE_FRIEND                 =   "好友"
    
    static let TITLE_ACCEPT                 =   "接受"
    
    static let HOLDER_BLOCKING              =   "屛蔽中(不能对话)"
    
    static let MENU_BLOCK                   =   "屛蔽"
    static let MENU_UNBLOCK                 =   "解除"
    
    static let INPUT_EMAIL                  =   "输入电子邮箱"
    static let INPUT_PHONE                  =   "输入手机号码"
    
    
    
    static let GROUP_INFO                   =   "群组信息"
    static let GROUP_MEMBER_COUNT           =   "全部群成员"
    
    static let FAILURE_TO_LOGIN             =   "Fail to login"
    static let UNREGISTERED_USER            =   "Unreigstered User."
    static let WRONG_PASSWORD               =   "Password is wrong."
    static let FAIL_TO_CONNECT              =   "Fail to connect to a server. \nPlease try again."
    static let INPUT_RIGHT_EMAIL            =   "Please input correct email address."
    static let EXIST_EMAIL                  =   "已注册的电子邮箱"
    static let EXIST_PHONE                  =   "已注册的手机号码"
    static let CODE_SENT                    =   "6 digits code is sent to your email."
    static let VERIFY_CODE                  =   "Please input verification code."
    static let VERIFY_EMAIL                 =   "Please verify email."
    static let VERIFY_SUCESS                =   "Successfully verified."
    static let INPUT_NICKNAME               =   "名称必须是2~15位。"
    static let NICK_CONFLICT                =   "Already exist nickname."
    static let NICK_AVAILABLE               =   "It is available nickname."
    static let INPUT_SEX                    =   "Please input sex."
    static let INPUT_CONFIRM                =   "Please confirm your password."
    static let WRONG_CODE                   =   "Please input right verification code."
    static let REGISTER_FAIL                =   "Failed to register"
    static let PHOTO_UPLOAD_FAIL            =   "Failed to upload photo."
    static let PHOTO_UPLOAD_SUCCESS         =   "Succesfully uploaded."
    
    static let EXIST_WECHAT                 =   "已注册的微信号码"
    static let SOCIAL_PASSWORD_WARNING      =   "※ Wechat, QQ로 가입한 경우는비밀번호\n 찾기가 불가능합니다."
    static let UNREGISTER_IN_SOCIAL         =   "가입되지 않은 계정입니다. 확인을 누르면 회원가입으로 이동합니다."
    
    
    static let FAIL_TO_POST_TIMELINE        =   "Failed to post timeline."
    static let SUCCESS_TO_POST_TIMELINE     =   "Sucessfully posted."
    
    static let SUCCESS_ADD_FRIEND           =   "Succesfully added to friends."
    static let SUCCESS_DELETE               =   "Succesfully deleted."
    
    static let TITLE_READ                   =   "Read"
    static let TITLE_DELETE                 =   "Delete"
    
    static let TITLE_LEAVE_ROOM             =   "Are you sure you want to leave this room?"
    
    static let INPUT_TIMLLINE_MSG           =   "Please input timeline message."
    static let INPUT_TIMELINE_IMG           =   "Please attach one more timeline image."
    
    static let NO_TIMELINE                  =   "no timeline"
    
    static let NEED_ACCESS_MICROHPHONE      =   "You need to access microphone."
    static let NEED_ACCESS_CAMERA           =   "You need to access to phone camera."
    
    static let PWD_RESET_ERROR              =    "Please input right ID and password."
    
    static let FRIEND_REQUEST_SENT          =   " sent friend request."
    static let FRIEND_REQUEST_ACCEPT        =   " accepted friend request.";
    
    static let NOT_USE_PHONE                =   "Cannot use outside of China"
    static let INPUT_RIGHT_EMAIL_PHONE      =   "Please input right phonenumber/email"
    static let NOT_REGISTERED_USER          =   "Not registered user"
    
    static let TEMP_PWD_PREFIX              =   "\nYour password is"
    static let TEMP_PWD_SUFFIX              =   "\nPlease login and change your password"
    
    static let LEAVE_ROOM                   =   " left the room."
    static let BECOME_GROUPOWNER            =   " has become group owner."
    static let INVITEED_ROOM                =   " has been invited to the room."
    static let BANISH_ROOM                  =   " has been out of the room."
    
    static let INSTALL_WECHAT               =   "Please install Wechat and try again."
    static let FAILED_WECHAT                =   "Failed to login to Wechat."
    
    static let FAILED_QQ                    =   "Failed to login to QQ."
    
    static let INSTALL_QQ                   =    "Please install QQ and try again."
    
    static let DEFAULT_WECHAT_PWD           =   "wechat"
    
    static let SELECTABLE_MAX_COUNT         =   "Select maximum 9 images."
    
    static let PAY_RESULT_TI                =   "这个界面用于显示第三方app通过微信支付的结果"
    static let APP_TIP                      =   "提示"
    static let GET_PREPAYID                 =   "正在获取预支付订单..."
    
    static let SLASH                        =   "ssllaasshh"
}







