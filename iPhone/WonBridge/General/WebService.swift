//
//  WebService.swift
//  WonBridge
//
//  Created by Tiia on 28/08/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// -----------------
// Web Service - 
// -----------------

// server url
private let SERVER_ADDR                     =       "http://52.78.120.201"
private let BASE_URL                        =       "http://52.78.120.201/index.php/api/"
private let UPLOADPATH                      =       SERVER_ADDR + "/uploadfiles"
private let REQ_LOGIN                       =       "login"
private let REQ_LOGINWECHAT                 =       "loginWithWechat"
private let REQ_LOGINQQ                     =       "loginWithQQ"
private let REQ_REGISTERWITHQQ              =       "registerWithQQ"
private let REQ_GETFRIENDS                  =       "getFriendList"
private let REQ_GETALLUSERS                 =       "getUserInfo"
private let REQ_GETROOMINFO                 =       "getRoomInfo"
private let REQ_GETROOMANDGROUPINFO         =       "getRoomAndGroupInfo"
private let REQ_GETAUTHCODE                 =       "getAuthCode"
private let REQ_GETRECOVERYCODE             =       "getRecoveryCode"
private let REQ_TEMPPASSWORD                =       "getTempPassword"
private let REQ_CONFIRMAUTHCODE             =       "confirmAuthCode"
private let REQ_CHECKNICKNAME               =       "checkNickName"
private let REQ_UPLOADPROFILE               =       "uploadProfile"
private let REQ_SAVETIMELINE                =       "saveTimeLine"
private let REQ_SAVETEXTTIMELINE            =       "saveTextTimeline"
private let REQ_GETMYTIMELINE               =       "getMyTimeLine"
private let REQ_GETUSERINFOBYID             =       "getUserInfoById"
private let REQ_DELETEFRIEND                =       "deleteFriend"
private let REQ_MAKEFRIEND                  =       "makeFriend"
private let REQ_CHANGENICKNAME              =       "changeNickName"
private let REQ_CHANGEPASSWORD              =       "changePassword"
private let REQ_SETPUBLICTIMELINE           =       "setPublicTimeline"
private let REQ_SETPUBLICLOCATION           =       "setPublicLocation"
private let REQ_GETNEARBYUSER               =       "getNearbyUser"
private let REQ_GETNEARBYTIMELINEDETAIL     =       "getNearbyTimelineWithDetail"
private let REQ_GETMYTIMELINEWITHDETAIL     =       "getMyTimeLineWithDetail"
private let REQ_SETLOCATION                 =       "setLocation"
private let REQ_DELETEBADGECOUNT            =       "deleteNoteCount"
private let REQ_GETNEARBYTIMELINE           =       "getNearbyTimeline"
private let REQ_GETTIMELINEDETAIL           =       "getTimelineDetail"
private let REQ_LIKETIMELINE                =       "likeTimeline"
private let REQ_UNLIKETIMELINE              =       "unlikeTimeline"
private let REQ_SAVERESPOND                 =       "saveRespond"
private let REQ_GETBLOCKUSERS               =       "getBlockUser"
private let REQ_SETBLOCKUSER                =       "setBlockUser"
private let REQ_SETUNBLOCKUSER              =       "setUnblockUser"
private let REQ_BLOCKFRIENDLIST             =       "blockFriendList"
private let REQ_MAKEGROUP                   =       "makeGroup"
private let REQ_SETGROUPPROFILE             =       "setGroupProfile"
private let REQ_SETGROUPNICKNAME            =       "setGroupNickname"
private let REQ_SETGROUPPARTICIPANT         =       "setGroupParticipant"
private let REQ_GETALLGROUP                 =       "getAllGroup"
private let REQ_SEARCHUSER                  =       "searchUser"
private let REQ_SEARCHGROUP                 =       "searchGroup"
private let REQ_GETNEARBYGROUP              =       "getNearbyGroup"
private let REQ_SETGROUPOWNER               =       "setGroupOwner"
private let REQ_UPLOADFILE                  =       "uploadFile"
private let REQ_SETCOUNTRY                  =       "setCountry"
private let REQ_DELETETIMELINE              =       "deleteMyTimeline"
private let REQ_REGISTERTOKEN               =       "registerToken"
private let REQ_GETNOTE                     =       "getNote"
private let REQ_GETONLINEMESSAGE            =       "getOnlineMessage"
private let REQ_SENDONLINEMESSAGE           =       "sendOnlineMessage"
private let REQ_REDUECEBAGECOUNT            =       "deleteNoteCount"
private let REQ_LOGOUT                      =       "logout"
private let REQ_CHECKDEVICEID               =       "checkDeviceId"
private let REQ_SETBADGECOUNT               =       "setNoteCount"

private let REQ_SETPAYMENT                  =       "setPayment"
private let REQ_SETSCHOOL                   =       "setSchool"
private let REQ_SETVILLAGE                  =       "setVillage"
private let REQ_SETCOUNTRY2                 =       "setCountry2"
private let REQ_SETWORKING                  =       "setWorking"
private let REQ_SETINTEREST                 =       "setInterest"

private let REQ_GROUPREQUEST                =       "groupRequest"
private let REQ_GETGROUPREQUEST             =       "getGroupRequest"
private let REQ_ACCEPTGROUPREQUEST          =       "acceptGroupRequest"
private let REQ_DECLINEGROUPREQUEST         =       "declineGroupRequest"
private let REQ_GETGROUPREQUESTBYID         =       "getGroupRequestById"
private let REQ_GETGROUPPROFILE             =       "getGroupProfile"

// request parmaters
private let PARAM_ID                        =       "id"
private let PARAM_TYPE                      =       "type"
private let PARAM_NAME                      =       "name"
private let PARAM_FILENAME                  =       "filename"
private let PARAM_FILE                      =       "file"
private let PARAM_CONTENT                   =       "content"
private let PARAM_LATITUDE                  =       "latitude"
private let PARAM_LONGITUDE                 =       "longitude"
private let PARAM_TIMELINEID                =       "timeline_id"
private let PARAM_USERID                    =       "user_id"
private let PARAM_FRIENDLIST                =       "friend_list"

private let PARAM_MESSAGE                   =       "message"
private let PARAM_ISIMAGE                   =       "is_image"
private let PARAM_WIDTH                     =       "width"
private let PARAM_HEIGHT                    =       "height"
private let PARAM_GROUPNAME                 =       "group_name"

// response paramters
private let RES_RESULTCODE                  =       "result_code"
private let RES_IDX                         =       "idx"
private let RES_ID                          =       "id"
private let RES_USER_INFOS                  =       "user_infos"
private let RES_USER_INFO                   =       "user_info"
private let RES_GROUPINFOS                  =       "group_infos"
private let RES_GROUPINFO                   =       "group_info"
private let RES_NAME                        =       "name"
private let RES_NICKNAME                    =       "nickname"
private let RES_EMAIL                       =       "email"
private let RES_BG_RUL                      =       "bg_url"
private let RES_PHOTO_URL                   =       "photo_url"
private let RES_PHONE_NUMBER                =       "phone_number"
private let RES_LABEL                       =       "label"
private let RES_SEX                         =       "sex"
private let RES_COUNTRY                     =       "country"
private let RES_REQUEST                     =       "is_request"
private let RES_WECHATID                    =       "wechat_id"
private let RES_SCHOOL                      =       "school"
private let RES_VILLAGE                     =       "village"
private let RES_COUNTRY2                    =       "country2"
private let RES_WORKING                     =       "working"
private let RES_INTEREST                    =       "interest"

private let RES_TIMELINE                    =       "time_line"
private let RES_CONTENT                     =       "content"
private let RES_USER_ID                     =       "user_id"
private let RES_USER_NAME                   =       "user_name"
private let RES_FILE_URL                    =       "file_url"
private let RES_FILENAME                    =       "filename"
private let RES_FILE_URL_ONE                =       "file_url"

private let RES_PARTICIPANT                 =       "participant"
private let RES_PROFILE                     =       "profile"

private let RES_FRIENDINFOS                 =       "friend_infos"

private let RES_ISPUBLICLOCATION            =       "is_location_public"
private let RES_ISPUBLICTIMELINE            =       "is_timeline_public"

private let RES_ISFRIEND                    =       "is_friend"

private let RES_LATITUDE                    =       "latitude"
private let RES_LONGITUDE                   =       "longitude"
private let RES_LASTLOGIN                   =       "last_login"
private let RES_REGTIME                     =       "reg_time"
private let RES_REGDATE                     =       "reg_date"

private let RES_RESPONDINFO                 =       "respond_info"
private let RES_LIKEUSERNAME                =       "like_username"


private let RES_LIKECOUNT                   =       "like_count"
private let RES_RESPONDCOUNT                =       "respond_count"
private let RES_LIKEUSERLIST                =       "like_user_list"
private let RES_RESPONDUSERLIST             =       "respond_user_list"
private let RES_ISLIKE                      =       "is_like"
private let RES_RESPONDTIME                 =       "respond_time"

private let RES_TEMPPWD                     =       "temp_password"

private let RES_QQID                        =       "qq_id"
private let RES_NOTEINFO                    =       "note_info"

private let RES_MESSAGEINFOS                =       "message_infos"
private let RES_MESSAGE                     =       "message"
private let RES_TYPE                        =       "type"
private let RES_HEIGHT                      =       "height"
private let RES_WIDTH                       =       "width"
private let RES_GROUPREQUESTS               =       "group_requests"
private let RES_USERPHOTO                   =       "user_photo"

private let RES_GROUPURLS                   =       "group_urls"

class WebService {
    
    static let REQ_REGISTER                     =       "register"
    static let REQ_REGISTERWITHPHONE            =       "registerWithPhone"
    static let REQ_REGISTERWITHWECHAT           =       "registerWithWechat"
    static let REQ_REGISTERWITHQQ               =       "registerWithQQ"
    
    static let CODE_SUCCESS                     =       0
    static let CODE_UNREGISTERED               =       104
    static let CODE_INVALIDPASSWORD            =       105
    static let CODE_FAILURE                    =       400

    // user login 
    class func login(username: String!, password: String!, success:(status: Bool, message: String, user: UserEntity!)->Void, failure: (resultCode: Int, message: String)->Void) {
        
        let deviceId = CommonUtils.uuidString()
        let url = BASE_URL + REQ_LOGIN + "/\(username)/\(password)/\(deviceId)/\(DEVICE_TYPE)"
        let escapeURL = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        Alamofire.request(.GET, escapeURL!, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let result_code = jsonResult[RES_RESULTCODE].int!
                        
                    if (result_code == CODE_SUCCESS) {
                        
                        let user = UserEntity()
                        user._idx = Int(jsonResult[RES_USER_INFO][RES_IDX].string!)!
                        user._name = jsonResult[RES_USER_INFO][RES_NAME].string!
                        user._email = jsonResult[RES_USER_INFO][RES_EMAIL].string!
                        user._photoUrl = jsonResult[RES_USER_INFO][RES_PHOTO_URL].string!
                        user._phoneNumber = jsonResult[RES_USER_INFO][RES_PHONE_NUMBER].string!
                        user._gender = (Int(jsonResult[RES_USER_INFO][RES_SEX].string!) == 0 ? .MALE : .FEMALE)
                        user._countryCode = jsonResult[RES_USER_INFO][RES_COUNTRY].string!
                        user._wechatId = jsonResult[RES_USER_INFO][RES_WECHATID].string!
                        user._qqId = jsonResult[RES_USER_INFO][RES_QQID].string!
                        user._isPublicLocation = (Int(jsonResult[RES_USER_INFO][RES_ISPUBLICLOCATION].string!) == 1)
                        user._isPublicTimeLine = (Int(jsonResult[RES_USER_INFO][RES_ISPUBLICTIMELINE].string!) == 1)
                        user._school = jsonResult[RES_USER_INFO][RES_SCHOOL].string!
                        user._village = jsonResult[RES_USER_INFO][RES_VILLAGE].string!
                        user._favCountry = jsonResult[RES_USER_INFO][RES_COUNTRY2].string!
                        user._working = jsonResult[RES_USER_INFO][RES_WORKING].string!
                        user._interest = jsonResult[RES_USER_INFO][RES_INTEREST].string!
                        
                        success(status: true, message: "", user: user)
                        
                    } else if (result_code == CODE_UNREGISTERED) {
                        
                        failure(resultCode: result_code, message: Constants.UNREGISTERED_USER)
                        
                    } else if (result_code == CODE_INVALIDPASSWORD) {
                        
                        failure(resultCode: result_code, message: Constants.WRONG_PASSWORD)
                    } else {
                        
                        failure(resultCode: CODE_FAILURE, message: "")
                    }
                    
                case  .Failure(let error):
                    print("failure to login: \(error)")
                    failure(resultCode: CODE_FAILURE, message: Constants.FAILURE_TO_LOGIN)
                }
        }
    }
    
    class func loginWithWechat(username: String!, success:(status: Bool, message: String, user: UserEntity!)->Void, failure: (resultCode: Int, message: String)->Void) {
        
        let deviceId = CommonUtils.uuidString()
        let url = BASE_URL + REQ_LOGINWECHAT + "/\(username)/\(deviceId)/\(DEVICE_TYPE)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let result_code = jsonResult[RES_RESULTCODE].int!
                    
                    if (result_code == CODE_SUCCESS) {
                        
                        let user = UserEntity()
                        user._idx = Int(jsonResult[RES_USER_INFO][RES_IDX].string!)!
                        user._name = jsonResult[RES_USER_INFO][RES_NAME].string!
                        user._email = jsonResult[RES_USER_INFO][RES_EMAIL].string!
                        user._password = Constants.DEFAULT_WECHAT_PWD
                        user._photoUrl = jsonResult[RES_USER_INFO][RES_PHOTO_URL].string!
                        user._phoneNumber = jsonResult[RES_USER_INFO][RES_PHONE_NUMBER].string!
                        user._gender = (Int(jsonResult[RES_USER_INFO][RES_SEX].string!) == 0 ? .MALE : .FEMALE)
                        user._countryCode = jsonResult[RES_USER_INFO][RES_COUNTRY].string!
                        user._wechatId = jsonResult[RES_USER_INFO][RES_WECHATID].string!
                        user._qqId = jsonResult[RES_USER_INFO][RES_QQID].string!
                        user._isPublicLocation = (Int(jsonResult[RES_USER_INFO][RES_ISPUBLICLOCATION].string!) == 1)
                        user._isPublicTimeLine = (Int(jsonResult[RES_USER_INFO][RES_ISPUBLICTIMELINE].string!) == 1)
                        
                        user._school = jsonResult[RES_USER_INFO][RES_SCHOOL].string!
                        user._village = jsonResult[RES_USER_INFO][RES_VILLAGE].string!
                        user._favCountry = jsonResult[RES_USER_INFO][RES_COUNTRY2].string!
                        user._working = jsonResult[RES_USER_INFO][RES_WORKING].string!
                        user._interest = jsonResult[RES_USER_INFO][RES_INTEREST].string!
                        
                        success(status: true, message: "", user: user)
                        
                    } else if (result_code == CODE_UNREGISTERED) {
                        
                        failure(resultCode: result_code, message: Constants.FAILURE_TO_LOGIN)
                        
                    } else if (result_code == CODE_INVALIDPASSWORD) {
                        
                        failure(resultCode: result_code, message: Constants.WRONG_PASSWORD)
                    } else {
                        
                        failure(resultCode: CODE_FAILURE, message: "")
                    }
                    
                case  .Failure(let error):
                    print("failure to login: \(error)")
                    failure(resultCode: CODE_FAILURE, message: Constants.FAILURE_TO_LOGIN)
            }
        }
    }
    
    class func loginWithQQ(username: String!, success:(status: Bool, message: String, user: UserEntity!)->Void, failure: (resultCode: Int, message: String)->Void) {
        
        let deviceId = CommonUtils.uuidString()
        let url = BASE_URL + REQ_LOGINQQ + "/\(username)/\(deviceId)/\(DEVICE_TYPE)"
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let result_code = jsonResult[RES_RESULTCODE].int!
                    
                    if (result_code == CODE_SUCCESS) {
                        
                        let user = UserEntity()
                        user._idx = Int(jsonResult[RES_USER_INFO][RES_IDX].string!)!
                        user._name = jsonResult[RES_USER_INFO][RES_NAME].string!
                        user._email = jsonResult[RES_USER_INFO][RES_EMAIL].string!
                        user._password = Constants.DEFAULT_QQ_PWD
                        user._photoUrl = jsonResult[RES_USER_INFO][RES_PHOTO_URL].string!
                        user._phoneNumber = jsonResult[RES_USER_INFO][RES_PHONE_NUMBER].string!
                        user._gender = (Int(jsonResult[RES_USER_INFO][RES_SEX].string!) == 0 ? .MALE : .FEMALE)
                        user._countryCode = jsonResult[RES_USER_INFO][RES_COUNTRY].string!
                        user._wechatId = jsonResult[RES_USER_INFO][RES_WECHATID].string!
                        user._qqId = jsonResult[RES_USER_INFO][RES_QQID].string!
                        user._isPublicLocation = (Int(jsonResult[RES_USER_INFO][RES_ISPUBLICLOCATION].string!) == 1)
                        user._isPublicTimeLine = (Int(jsonResult[RES_USER_INFO][RES_ISPUBLICTIMELINE].string!) == 1)
                        
                        user._school = jsonResult[RES_USER_INFO][RES_SCHOOL].string!
                        user._village = jsonResult[RES_USER_INFO][RES_VILLAGE].string!
                        user._favCountry = jsonResult[RES_USER_INFO][RES_COUNTRY2].string!
                        user._working = jsonResult[RES_USER_INFO][RES_WORKING].string!
                        user._interest = jsonResult[RES_USER_INFO][RES_INTEREST].string!
                        
                        success(status: true, message: "", user: user)
                        
                    } else if (result_code == CODE_UNREGISTERED) {
                        
                        failure(resultCode: result_code, message: Constants.FAILURE_TO_LOGIN)
                        
                    } else if (result_code == CODE_INVALIDPASSWORD) {
                        
                        failure(resultCode: CODE_INVALIDPASSWORD, message: Constants.WRONG_PASSWORD)
                    } else {
                        
                        failure(resultCode: CODE_FAILURE, message: "")
                    }
                    
                case  .Failure(let error):
                    print("failure to login: \(error)")
                    failure(resultCode: CODE_FAILURE, message: Constants.FAILURE_TO_LOGIN)
                }
        }
    }
    
    // get friends
    class func getFriends(user_id: Int, pageIndex: Int, completion:(status: Bool, message: String, friendList: [FriendEntity])->Void) {
        
        let url = BASE_URL +  REQ_GETFRIENDS + "/\(user_id)" + "/" + "\(pageIndex)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        var _friendList = [FriendEntity]()
                        
                        let _friends = jsonResult[RES_FRIENDINFOS].array!
                        
                        for index in 0 ..< _friends.count {
                            
                            let _friend = FriendEntity()
                            
                            _friend._idx = Int(_friends[index][RES_ID].string!)!
                            _friend._name = _friends[index][RES_NAME].string!
                            _friend._photoUrl = _friends[index][RES_PHOTO_URL].string!                            
                            _friend._gender = ((Int(_friends[index][RES_SEX].string!) == 0) ? .MALE : .FEMALE)
                            _friend._lastLogin = _friends[index][RES_LASTLOGIN].string!
                            _friend.location = CLLocationCoordinate2D(latitude: Double(_friends[index][RES_LATITUDE].string!)!, longitude: Double(_friends[index][RES_LONGITUDE].string!)!)
                            _friend._countryCode = _friends[index][RES_COUNTRY].string!
                            _friend._favCountry = _friends[index][RES_COUNTRY2].string!
                            _friend._isFriend = true
                            
                            _friendList.append(_friend)
                        }
                        
                        completion(status: true, message: "", friendList: _friendList)
                        
                    } else {
                        
                        completion(status: false, message: Constants.FAIL_TO_CONNECT, friendList: [])
                    }
                    
                case  .Failure(let error):
                    
                    debugPrint("failure to login: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, friendList: [])
                }
        }
    }
    
    // get block user list
    class func getBlockUsers(user_id: Int, completion: (status: Bool, message: String, blockList: [FriendEntity]) -> Void) {
        
        let url = BASE_URL + REQ_GETBLOCKUSERS + "/\(user_id)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    var blockList = [FriendEntity]()
                    
                    let blockUsers = jsonResult[RES_USER_INFOS].array!
                    for index in 0 ..< blockUsers.count {
                        
                        let blockUser = FriendEntity()
                        blockUser._idx = Int(jsonResult[RES_USER_INFOS][index][RES_ID].string!)!
                        blockUser._name = jsonResult[RES_USER_INFOS][index][RES_NAME].string!
                        blockUser._photoUrl = jsonResult[RES_USER_INFOS][index][RES_PHOTO_URL].string!
                        blockUser.location = CLLocationCoordinate2D(latitude: Double(jsonResult[RES_USER_INFOS][index][RES_LATITUDE].string!)!, longitude: Double(jsonResult[RES_USER_INFOS][index][RES_LONGITUDE].string!)!)
                        blockUser._lastLogin = jsonResult[RES_USER_INFOS][index][RES_LASTLOGIN].string!
                        blockList.append(blockUser)
                    }
                    
                    completion(status: true, message: "", blockList: blockList)
                    
                } else {
                    
                    completion(status: false, message: "", blockList: [])
                }
                
            case .Failure(let error):
                debugPrint("error to get block list: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT, blockList: [])
            }
        }
    }
    
    // get room information with participant name
    class func getRoomInfo(userId: Int, participantName: String, completion: (status: Bool, participants: [FriendEntity]) -> Void) {
        
        var participants = [FriendEntity]()
        let url = BASE_URL + REQ_GETROOMINFO + "/\(userId)/" + participantName
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let result_code = jsonResult[RES_RESULTCODE].int!
                    
                if result_code == CODE_SUCCESS {
                    
                    let arrParticipants = jsonResult[RES_USER_INFOS].array!
                    for participant in arrParticipants {
                       
                        guard Int(participant[RES_ID].string!) != userId else {
                            continue
                        }
                        
                        let _participant = FriendEntity()
                        _participant._idx = Int(participant[RES_ID].string!)!
                        _participant._name = participant[RES_NAME].string!
                        _participant._photoUrl = participant[RES_PHOTO_URL].string!
                        _participant._isFriend = (participant[RES_ISFRIEND].int! == 1)
                        _participant.location = CLLocationCoordinate2D(latitude: Double(participant[RES_LATITUDE].string!)!, longitude: Double(participant[RES_LONGITUDE].string!)!)
                        _participant._lastLogin = participant[RES_LASTLOGIN].string!
                        _participant._countryCode = participant[RES_COUNTRY].string!
                        _participant._favCountry = participant[RES_COUNTRY2].string!
                        
                        participants.append(_participant)                        
                    }
                }
                
                if participants.count == 0 {
                    
                    completion(status: false, participants: [])
                } else {
                    
                    completion(status: true, participants: participants)
                }
                
            case .Failure(let error):
                
                debugPrint("fail to get room info: \(error)")
                completion(status: false, participants: [])
            }
        }
    }
    
    class func getRoomAndGroupInfo(userId: Int, participantName: String, roomName: String, completion: (status: Bool, room: RoomEntity?, group: GroupEntity?) -> Void) {
        
        let url = BASE_URL + REQ_GETROOMANDGROUPINFO + "/\(userId)/\(participantName)/\(roomName)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let result_code = jsonResult[RES_RESULTCODE].int!
                    
                    if result_code == CODE_SUCCESS {
                        
                        var participants = [FriendEntity]()
                        
                        let arrParticipants = jsonResult[RES_USER_INFOS].array!
                        for participant in arrParticipants {
                            guard Int(participant[RES_ID].string!) != userId else {
                                continue
                            }
                            
                            let _participant = FriendEntity()
                            _participant._idx = Int(participant[RES_ID].string!)!
                            _participant._name = participant[RES_NAME].string!
                            _participant._photoUrl = participant[RES_PHOTO_URL].string!
                            _participant._isFriend = (participant[RES_ISFRIEND].int! == 1)
                            _participant.location = CLLocationCoordinate2D(latitude: Double(participant[RES_LATITUDE].string!)!, longitude: Double(participant[RES_LONGITUDE].string!)!)
                            _participant._lastLogin = participant[RES_LASTLOGIN].string!
                            _participant._countryCode = participant[RES_COUNTRY].string!
                            _participant._favCountry = participant[RES_COUNTRY2].string!
                            
                            participants.append(_participant)
                        }
                        
                        guard participants.count > 0 else {
                            completion(status: false, room: nil, group: nil)
                            return
                        }
                        
                        // create room
                        let updatedRoom: RoomEntity = RoomEntity(name: roomName)
                        updatedRoom._participantList = participants
                        updatedRoom._participants = updatedRoom.participantsWithoutLeaveMembers(true)
                        updatedRoom.makeRoomDisplayName()
                        
                        // if group room
                        if participants.count != 1 {
                            
                            let _group = jsonResult[RES_GROUPINFO]
                            let group = GroupEntity()
                            group.ownerID = Int(_group[RES_ID].string!)
                            group.name = _group[RES_NAME].string!
                            group.nickname = _group[RES_NICKNAME].string!
                            group.participants = _group[RES_PARTICIPANT].string!
                            group.profileUrl = _group[RES_PROFILE].string!
                            group.regDate = _group[RES_REGDATE].string!
                            group.countryCode = _group[RES_COUNTRY].string!
                            
                            let jsonUrls = _group[RES_GROUPURLS].array!
                            for jsonUrl in jsonUrls {
                                group.profileUrls.append(jsonUrl.string!)
                            }
                            
                            // group message get room info
                            completion(status: true, room: updatedRoom, group: group)
                            return
                        }
                        
                        // single chat meesage get room info
                        completion(status: true, room: updatedRoom, group: nil)
                    } else {
                        
                        completion(status: false, room: nil, group: nil)
                    }
                case .Failure(let error):
                    
                    debugPrint("fail to get room info: \(error)")
                    completion(status: false, room: nil, group: nil)
                }
        }
    }
    
    // send email address for email authentication
    class func getAuthCode(email: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_GETAUTHCODE + "/" + email
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                if let resultCode = jsonResult[RES_RESULTCODE].int {
                    
                    if resultCode == CODE_SUCCESS {
                        completion(status: true, message: Constants.CODE_SENT)
                    } else {
                        completion(status: false, message: "")
                    }
                } else {                    
                    completion(status: false, message: "")
                }
                
            case .Failure(let error):
                
                debugPrint("get authcode error: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
            
        }
    }
    
    // auth code verification
    class func verifyCode(email: String, code: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_CONFIRMAUTHCODE + "/" + email + "/" + code
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                if let resultCode = jsonResult[RES_RESULTCODE].int {
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true, message: Constants.VERIFY_SUCESS)
                        
                    } else {
                        
                        completion(status: false, message: "")
                    }
                    
                } else {
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
                
            case .Failure(let error):
                
                debugPrint("verify code error: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    // upload user profile image
    class func addUserImage(id: Int, photoPath: String, completion: (status: Bool, message: String, photo_url: String) -> Void) {
        
        let url = BASE_URL + REQ_UPLOADPROFILE
        
        Alamofire.upload(
            .POST,
            url,
            multipartFormData: {  multipartFormData in
                
                multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: photoPath), name: "file")
                multipartFormData.appendBodyPart(data: "\(id)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "id")
                
            }, encodingCompletion: { encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .Success(let result):
                            
                            let jsonResult = JSON(result)
                            
                            
                            if let resultCode = jsonResult[RES_RESULTCODE].int {
                                
                                if resultCode == CODE_SUCCESS {
                                    
                                    let photourl = jsonResult[RES_PHOTO_URL].string!
                                    
                                    completion(status: true, message: "", photo_url: photourl)
                                    
                                } else {
                                    
                                    completion(status: false, message: Constants.PHOTO_UPLOAD_FAIL, photo_url: "")
                                }
                                
                            } else {
                                
                                completion(status: false, message: Constants.PHOTO_UPLOAD_FAIL, photo_url: "")
                            }
                            
                        case .Failure(let error):
                            
                            debugPrint(error)

                            completion(status: false, message: Constants.PHOTO_UPLOAD_FAIL, photo_url: "")
                        }
                    }
                case .Failure(let encodingError):
                    
                    debugPrint(encodingError)
                    
                    completion(status: false, message: Constants.PHOTO_UPLOAD_FAIL, photo_url: "")
                }
        })
    }
    
    // check if nickname is available or not
    class func checkNickName(nickname: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_CHECKNICKNAME + "/" + nickname
        
        let escapeURL = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        Alamofire.request(.GET, escapeURL!, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                if let resultCode = jsonResult[RES_RESULTCODE].int {
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true, message: Constants.NICK_AVAILABLE)
                        
                    } else {
                        
                        completion(status: false, message: Constants.NICK_CONFLICT)
                    }
                    
                } else {
                    
                    completion(status: false, message: Constants.NICK_CONFLICT)
                }
                
            case .Failure(let error):
                
                debugPrint("check nick name error: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
                
            }
        }
    }
    
    // sign up
    class func registerUser(url: String, completion: (status: Bool, message: String, idx: Int) -> Void) {
        
        let regUrl = BASE_URL + url
        Alamofire.request(.GET, regUrl, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
            case .Success(let result):
                
                let jsonResult = JSON(result)
                if let resultCode = jsonResult[RES_RESULTCODE].int {
                    
                    if resultCode == CODE_SUCCESS {
                      
                        let idx = jsonResult[RES_ID].int!
                        completion(status: true, message: "", idx: idx)
                        
                    } else if resultCode == 101 {
                        
                        completion(status: false, message: Constants.NICK_CONFLICT, idx: 0)
                        
                    } else if resultCode == 102 {
                        
                        completion(status: false, message: Constants.EXIST_EMAIL, idx: 0)
                        
                    } else if resultCode == 118 {
                    
                        completion(status: false, message: Constants.EXIST_WECHAT, idx: 0)
                        
                    } else if resultCode == 112 {
                        
                        completion(status: false, message: Constants.EXIST_PHONE, idx: 0)
                    } else {
                        completion(status: false, message: Constants.REGISTER_FAIL, idx: 0)
                    }
                    
                } else {
                    
                    completion(status: false, message: Constants.REGISTER_FAIL, idx: 0)
                }

                
            case .Failure(let error):
                
                debugPrint("register fail: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT, idx: 0)
            }
        }
    }
    
    // get users with saved filter
    class func getNearbyUsers(id: Int, lat: Double, long: Double, distance: Int, ageStart: Int, ageEnd: Int, sex: Int, lastLogin: Int, relation: Int, pageIndex: Int, completion: (status: Bool, message: String, nearbyUsers: [FriendEntity]) -> Void) {
        
        let url = BASE_URL + REQ_GETNEARBYUSER + "/\(id)/\(lat)/\(long)/\(distance)/\(ageStart)/\(ageEnd)/\(sex)/\(lastLogin)/\(relation)/\(pageIndex)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    if resultCode == CODE_SUCCESS {
                        
                        var _friendList = [FriendEntity]()
                        
                        let _friends = jsonResult[RES_USER_INFOS].array!
                        for index in 0 ..< _friends.count {
                            
                            let _friend = FriendEntity()
                            
                            _friend._idx = Int(_friends[index][RES_ID].string!)!
                            _friend._name = _friends[index][RES_NAME].string!
                            _friend._photoUrl = _friends[index][RES_PHOTO_URL].string!
                            _friend._gender = (Int(_friends[index][RES_SEX].string!) == 0 ? .MALE : .FEMALE)
                            _friend.location = CLLocationCoordinate2D(latitude: Double(_friends[index][RES_LATITUDE].string!)!, longitude: Double(_friends[index][RES_LONGITUDE].string!)!)
                            _friend._lastLogin = _friends[index][RES_LASTLOGIN].string!
                            _friend._isFriend = (_friends[index][RES_ISFRIEND].int! == 1)
                            _friend._isPublic = (Int(_friends[index][RES_ISPUBLICLOCATION].string!)! == 1)
                            _friend._countryCode = _friends[index][RES_COUNTRY].string!
                            _friend._favCountry = _friends[index][RES_COUNTRY2].string!
                            
                            _friendList.append(_friend)
                        }
                        
                        completion(status: true, message: "", nearbyUsers: _friendList)
                        
                    } else {
                        
                        completion(status: true, message: "", nearbyUsers: [])
                    }
                    
                case .Failure(let error):
                    
                    debugPrint("error to get near by users: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, nearbyUsers: [])
                }
        }
    }
    
    // get nearby timeline ( user's latitude and longitude, distance, age, sex, lastLogin Time, relation)
    class func getNearbyTimeLineDetail(id: Int, lat: Double, long: Double, distance: Int, ageStart: Int, ageEnd: Int, sex: Int, lastLogin: Int, relation: Int, pageIndex: Int, completion: (status: Bool, message: String, nearbyTimeLine: [TimeLineEntity]) -> Void) {
        
        let url = BASE_URL + REQ_GETNEARBYTIMELINEDETAIL + "/\(id)/\(lat)/\(long)/\(distance)/\(ageStart)/\(ageEnd)/\(sex)/\(lastLogin)/\(relation)/\(pageIndex)"
        
//        print(url)
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)                    
                    var timeLineList: [TimeLineEntity] = []
                    
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        let arrTimeLines = jsonResult[RES_TIMELINE].array!
                        
//                        print(arrTimeLines)
                        
                        for index in 0 ..< arrTimeLines.count {
                            
                            let timeLine = TimeLineEntity()
                            timeLine.id = Int(arrTimeLines[index][RES_IDX].string!)!
                            timeLine.content = arrTimeLines[index][RES_CONTENT].string!
                            timeLine.likeCount = arrTimeLines[index][RES_LIKECOUNT].int!
                            timeLine.replyCount = arrTimeLines[index][RES_RESPONDCOUNT].int!
                            timeLine.postedTime = arrTimeLines[index][RES_REGTIME].string!
                            timeLine.countryCode = arrTimeLines[index][RES_COUNTRY].string!
                            timeLine.favCountry = arrTimeLines[index][RES_COUNTRY2].string!
                            timeLine.location = CLLocationCoordinate2D(latitude: Double(arrTimeLines[index][RES_LATITUDE].string!)!, longitude: Double(arrTimeLines[index][RES_LONGITUDE].string!)!)
                            timeLine.user_id = Int(arrTimeLines[index][RES_USER_ID].string!)!
                            timeLine.user_name = arrTimeLines[index][RES_NAME].string!
                            timeLine.photo_url = arrTimeLines[index][RES_PHOTO_URL].string!
                            
                            let fileUrls = arrTimeLines[index][RES_FILE_URL].array!
                            for fIndex in 0 ..< fileUrls.count {
                                timeLine.file_url.append(fileUrls[fIndex].string!)
                            }
                            
                            let likeusers = arrTimeLines[index][RES_LIKEUSERNAME].array!
                            for likeUser in likeusers {
                                timeLine.likeUsers.append(likeUser.string!)
                            }
                            
                            let responds = arrTimeLines[index][RES_RESPONDINFO].array!
                            for respond in responds {
                                let reply = ReplyEntity()
                                reply._id = Int(respond[RES_ID].string!)
                                reply._userName = respond[RES_NAME].string!
                                reply._content = respond[RES_CONTENT].string!
                                reply._userProfile = respond[RES_PHOTO_URL].string!
                                timeLine.replies.append(reply)
                            }                            
                            timeLineList.append(timeLine)
                        }
                        
                        completion(status: true, message: "", nearbyTimeLine: timeLineList)
                        
                    } else {
                        
                        completion(status: false, message: "", nearbyTimeLine: [])
                    }
                    
                case  .Failure(let error):
                    
                    debugPrint("failure to getAllTimeLine: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, nearbyTimeLine: [])
                }
        }
    }
    
    // get nearby timeline ( user's latitude and longitude, distance, age, sex, lastLogin Time, relation)
    class func getNearbyTimeLine(id: Int, lat: Double, long: Double, distance: Int, ageStart: Int, ageEnd: Int, sex: Int, lastLogin: Int, relation: Int, pageIndex: Int, completion: (status: Bool, message: String, nearbyTimeLine: [TimeLineEntity]) -> Void) {
        
        let url = BASE_URL + REQ_GETNEARBYTIMELINE + "/\(id)/\(lat)/\(long)/\(distance)/\(ageStart)/\(ageEnd)/\(sex)/\(lastLogin)/\(relation)/\(pageIndex)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    var timeLineList: [TimeLineEntity] = []
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        if let arrTimeLine = jsonResult[RES_TIMELINE].array {
                            
                            if arrTimeLine.count > 0 {
                                
                                for index in 0 ..< arrTimeLine.count {
                                    
                                    let timeLine = TimeLineEntity()
                                    
                                    timeLine.id = Int(jsonResult[RES_TIMELINE][index][RES_IDX].string!)!
                                    timeLine.content = jsonResult[RES_TIMELINE][index][RES_CONTENT].string!
                                    timeLine.likeCount = jsonResult[RES_TIMELINE][index][RES_LIKECOUNT].int!
                                    timeLine.replyCount = jsonResult[RES_TIMELINE][index][RES_RESPONDCOUNT].int!
                                    timeLine.postedTime = jsonResult[RES_TIMELINE][index][RES_REGTIME].string!
                                    
                                    timeLine.location = CLLocationCoordinate2D(latitude: Double(jsonResult[RES_TIMELINE][index][RES_LATITUDE].string!)!, longitude: Double(jsonResult[RES_TIMELINE][index][RES_LONGITUDE].string!)!)
                                    
                                    
                                    timeLine.user_id = Int(jsonResult[RES_TIMELINE][index][RES_USER_ID].string!)!
                                    timeLine.user_name = jsonResult[RES_TIMELINE][index][RES_NAME].string!
                                    timeLine.photo_url = jsonResult[RES_TIMELINE][index][RES_PHOTO_URL].string!
                                    timeLine.countryCode = jsonResult[RES_TIMELINE][index][RES_COUNTRY].string!
                                    timeLine.favCountry = jsonResult[RES_TIMELINE][index][RES_COUNTRY2].string!
                                    
                                    let fileUrls = arrTimeLine[index][RES_FILE_URL].array
                                    if fileUrls != nil {
                                        for fIndex in 0 ..< fileUrls!.count {
                                            timeLine.file_url.append(fileUrls![fIndex].string!)
                                        }
                                    }
                                    timeLineList.append(timeLine)
                                }
                                
                                completion(status: true, message: "", nearbyTimeLine: timeLineList)
                                
                                
                            } else {
                                
                                completion(status: false, message: "", nearbyTimeLine: [])
                            }
                            
                        } else {
                            
                            completion(status: false, message: "", nearbyTimeLine: [])
                        }
                        
                    } else {
                        
                        completion(status: false, message: "", nearbyTimeLine: [])
                    }
                    
                case  .Failure(let error):
                    
                    debugPrint("failure to getAllTimeLine: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, nearbyTimeLine: [])
                }
        }
    }
    
    // nearby groups
    class func getNearbyGroups(userId: Int, lat: Double, long: Double, distance: Int, pageIndex: Int, completion:(status: Bool, message: String, list: [GroupEntity]?) -> Void) {
        
        let url = BASE_URL + REQ_GETNEARBYGROUP + "/\(userId)/\(lat)/\(long)/\(distance)/\(pageIndex)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { response in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    if resultCode == CODE_SUCCESS {
                        
                        var groupList = [GroupEntity]()
                        
                        let arrGroups = jsonResult[RES_GROUPINFOS].array!
                        for index in 0 ..< arrGroups.count {
                            
                            let model = GroupEntity()
                            model.name = arrGroups[index][RES_NAME].string!
                            model.nickname = arrGroups[index][RES_NICKNAME].string!
                            model.participants = arrGroups[index][RES_PARTICIPANT].string!
                            model.profileUrl = arrGroups[index][RES_PROFILE].string!
                            model.ownerID = Int(arrGroups[index][RES_USER_ID].string!)!
                            model.regDate = arrGroups[index][RES_REGDATE].string!.displayRegTime()
                            model.countryCode = arrGroups[index][RES_COUNTRY].string!
                            model.isRequested = (arrGroups[index][RES_REQUEST].int! == 1)
                            
                            let jsonUrls = arrGroups[index][RES_GROUPURLS].array!
                            for jsonUrl in jsonUrls {
                                model.profileUrls.append(jsonUrl.string!)
                            }
                            
                            groupList.append(model)
                        }
                        
                        completion(status: true, message: "", list: groupList)
                        
                    } else {
                        completion(status: false, message: "", list: nil)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to get nearby groups: \(error)")
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, list: nil)
                }
        }
    }
    
    // save timeline with only text
    class func postTimeLine(id: Int, latitude: Double, longitude: Double, postMsg: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SAVETEXTTIMELINE
        
        let params = [
            "id": id,
            "content": postMsg,
            "latitude": "\(latitude)",
            "longitude": "\(longitude)"
        ]
        
        Alamofire.request(.POST, url, parameters: params as? [String : AnyObject]).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true, message: Constants.SUCCESS_TO_POST_TIMELINE)
                    
                } else {
                    
                    completion(status: false, message: Constants.FAIL_TO_POST_TIMELINE)
                }
                
                
            case .Failure(let error):
                
                debugPrint("post time line error: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_POST_TIMELINE)
            }
        }

    }
    
    // save timeline with text and image
    class func postTimeLine(id: Int, latitude: Double, longitude: Double, postMsg: String, photoPaths: [String], completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SAVETIMELINE
        
        Alamofire.upload(
            .POST,
            url,
            multipartFormData: {  multipartFormData in
                
                multipartFormData.appendBodyPart(data: "\(id)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_ID)
                multipartFormData.appendBodyPart(data: postMsg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_CONTENT)
                multipartFormData.appendBodyPart(data: "\(latitude)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_LATITUDE)
                multipartFormData.appendBodyPart(data: "\(longitude)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_LONGITUDE)
                
                for index in 0 ..< photoPaths.count {
                    
                    multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: photoPaths[index]), name: "file[\(index)]")
                }
                
            }, encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .Success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .Success(let result):
                            
                            let jsonResult = JSON(result)
                            
                            if let resultCode = jsonResult[RES_RESULTCODE].int {
                                
                                if resultCode == CODE_SUCCESS {
                                    
                                    completion(status: true, message: Constants.SUCCESS_TO_POST_TIMELINE)
                                    
                                } else {
                                    
                                    completion(status: false, message: Constants.FAIL_TO_POST_TIMELINE)
                                }
                                
                            } else {
                                
                                completion(status: false, message: Constants.FAIL_TO_POST_TIMELINE)
                            }
                            
                        case .Failure(let error):
                            
                            debugPrint(error)
                            
                            completion(status: false, message: Constants.FAIL_TO_POST_TIMELINE)
                        }
                    }
                case .Failure(let encodingError):
                    
                    debugPrint(encodingError)
                    
                    completion(status: false, message: Constants.FAIL_TO_POST_TIMELINE)
                }
        })
    }
    
    class func getTimeLineDetail(timeLineId: Int, userId: Int, completion: (status: Bool, userLastLogin: String, isFriend: Bool, isLike: Bool, likeUsers: [FriendEntity], replys: [ReplyEntity]) -> Void) {
        
        let url = BASE_URL + REQ_GETTIMELINEDETAIL + "/\(timeLineId)/\(userId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)

                var likeUsers = [FriendEntity]()
                var replys = [ReplyEntity]()
                
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    let isFriend = (jsonResult[RES_TIMELINE][RES_ISFRIEND].int! == 1)
                    let userLastLogin = jsonResult[RES_TIMELINE][RES_LASTLOGIN].string!
                    let isLike = (jsonResult[RES_TIMELINE][RES_ISLIKE].int! == 1)
                    
                    let arrLikeUsers = jsonResult[RES_TIMELINE][RES_LIKEUSERLIST].array!
                    
                    for index in 0 ..< arrLikeUsers.count {
                        
                        let likeUser = FriendEntity()
                        
                        likeUser._idx = Int(jsonResult[RES_TIMELINE][RES_LIKEUSERLIST][index][RES_ID].string!)!
                        likeUser._name = jsonResult[RES_TIMELINE][RES_LIKEUSERLIST][index][RES_NAME].string!
                        likeUser._photoUrl = jsonResult[RES_TIMELINE][RES_LIKEUSERLIST][index][RES_PHOTO_URL].string!
                        
                        likeUsers.append(likeUser)
                    }
                    
                    let arrReplys = jsonResult[RES_TIMELINE][RES_RESPONDUSERLIST].array!
                    
                    for index in 0 ..< arrReplys.count {
                        
                        let reply = ReplyEntity()
                        
                        reply._userId = Int(jsonResult[RES_TIMELINE][RES_RESPONDUSERLIST][index][RES_ID].string!)!
                        reply._userName = jsonResult[RES_TIMELINE][RES_RESPONDUSERLIST][index][RES_NAME].string!
                        reply._userProfile = jsonResult[RES_TIMELINE][RES_RESPONDUSERLIST][index][RES_PHOTO_URL].string!
                        reply._replyTime = jsonResult[RES_TIMELINE][RES_RESPONDUSERLIST][index][RES_RESPONDTIME].string!
                        reply._content = jsonResult[RES_TIMELINE][RES_RESPONDUSERLIST][index][RES_CONTENT].string!
                        
                        replys.append(reply)
                    }
                    
                    completion(status: true, userLastLogin: userLastLogin, isFriend: isFriend, isLike: isLike, likeUsers: likeUsers, replys: replys)
                    
                    
                } else {
                    
                    completion(status: false, userLastLogin: "", isFriend: false, isLike: false, likeUsers: [], replys: [])
                }
                
            case .Failure(let error):
                
                debugPrint("fail to get timeline detail: \(error)")
                
                completion(status: false, userLastLogin: "", isFriend: false, isLike: false, likeUsers: [], replys: [])
            }
        }
        
    }
    
    class func likeTimeLine(timeLineId: Int, userId: Int, like: Bool, completion: (status: Bool) -> Void) {
        
        var url = ""
        
        if (like) {
        
            url = BASE_URL + REQ_LIKETIMELINE
            
        } else {
            
            url = BASE_URL + REQ_UNLIKETIMELINE
        }
        
        url += "/\(timeLineId)/\(userId)"
        
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success( let result):
                
                let jsonresult = JSON(result)
                
                let resultCode = jsonresult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true)
                } else {
                    
                    completion(status: false)
                }
                
            case .Failure(let error):
                
                debugPrint("fail to like/dislike timeline: \(error)")
                
                completion(status: false)
            }
        }
        
        
    }
    
    class func sendReply(timeLineId: Int, userId: Int, replyMsg: String, completion: (status: Bool, reply: ReplyEntity) -> Void) {
        
        
        let url = BASE_URL + REQ_SAVERESPOND
        
        let params = [
            PARAM_TIMELINEID: "\(timeLineId)",
            PARAM_USERID: "\(userId)",
            PARAM_CONTENT: "\(replyMsg)"
        ]
        
        Alamofire.request(.POST, url, parameters: params).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    let reply = ReplyEntity()
                    
                    reply._replyTime = jsonResult[RES_REGTIME].string!
                    
                    completion(status: true, reply: reply)
                    
                } else {
                    
                    completion(status: false, reply: ReplyEntity())
                }
                
            case .Failure(let error):
                
                debugPrint("fail to send a respond: \(error)")
                
                completion(status: false, reply: ReplyEntity())                
            }
        }
        
    }
    
    // get all timeline with page index for selected user
    class func getUserTimeLineDetail(id: Int, pageIndex: Int, completion: (status: Bool, message: String, timeLineList: [TimeLineEntity]) -> Void) {
        
        let url = BASE_URL +  REQ_GETMYTIMELINEWITHDETAIL + "/\(id)" + "/\(pageIndex)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        var timeLineList: [TimeLineEntity] = []
                        
                        let arrTimeLine = jsonResult[RES_TIMELINE].array!
                        for index in 0 ..< arrTimeLine.count {
                            
                            let timeLine = TimeLineEntity()
                            
                            timeLine.id = Int(arrTimeLine[index][RES_IDX].string!)!
                            timeLine.content = arrTimeLine[index][RES_CONTENT].string!
                            timeLine.user_id = Int(arrTimeLine[index][RES_USER_ID].string!)!
                            timeLine.user_name = arrTimeLine[index][RES_USER_NAME].string!
                            timeLine.photo_url = arrTimeLine[index][RES_PHOTO_URL].string!
                            timeLine.likeCount = arrTimeLine[index][RES_LIKECOUNT].int!
                            timeLine.replyCount = arrTimeLine[index][RES_RESPONDCOUNT].int!
                            timeLine.postedTime = arrTimeLine[index][RES_REGTIME].string!
                            timeLine.location = CLLocationCoordinate2D(latitude: Double(arrTimeLine[index][RES_LATITUDE].string!)!, longitude: Double(arrTimeLine[index][RES_LONGITUDE].string!)!)
                            timeLine.countryCode = arrTimeLine[index][RES_COUNTRY].string!
                            
                            let fileUrls = arrTimeLine[index][RES_FILE_URL].array!
                            for fIndex in 0 ..< fileUrls.count {
                                timeLine.file_url.append(fileUrls[fIndex].string!)
                            }
                            
                            let likeusers = arrTimeLine[index][RES_LIKEUSERNAME].array!
                            for likeUser in likeusers {
                                timeLine.likeUsers.append(likeUser.string!)
                            }
                            
                            let responds = arrTimeLine[index][RES_RESPONDINFO].array!
                            for respond in responds {
                                let reply = ReplyEntity()
                                reply._id = Int(respond[RES_ID].string!)
                                reply._userName = respond[RES_NAME].string!
                                reply._content = respond[RES_CONTENT].string!
                                reply._userProfile = respond[RES_PHOTO_URL].string!
                                timeLine.replies.append(reply)
                            }
                            
                            timeLineList.append(timeLine)
                        }
                        
                        completion(status: true, message: "", timeLineList: timeLineList)
                    } else {
                        completion(status: false, message: Constants.FAIL_TO_CONNECT, timeLineList: [])
                    }
                    
                case  .Failure(let error):
                    
                    debugPrint("failure to getAllTimeLine: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, timeLineList: [])
                }
        }
    }
    
    // get all timeline with page index for selected user
    class func getUserTimeLine(id: Int, pageIndex: Int, completion: (status: Bool, message: String, timeLineList: [TimeLineEntity]) -> Void) {
        
        let url = BASE_URL +  REQ_GETMYTIMELINE + "/\(id)" + "/\(pageIndex)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    
                    var timeLineList: [TimeLineEntity] = []
                    
                    if let resultCode = jsonResult[RES_RESULTCODE].int {
                        
                        if resultCode == CODE_SUCCESS {
                            
                            if let arrTimeLine = jsonResult[RES_TIMELINE].array {
                                
                                if arrTimeLine.count > 0 {
                                    
                                    for index in 0 ..< arrTimeLine.count {
                                        
                                        let timeLine = TimeLineEntity()
                                        
                                        timeLine.id = Int(jsonResult[RES_TIMELINE][index][RES_IDX].string!)!
                                        timeLine.content = jsonResult[RES_TIMELINE][index][RES_CONTENT].string!
                                        timeLine.user_id = Int(jsonResult[RES_TIMELINE][index][RES_USER_ID].string!)!
                                        timeLine.user_name = jsonResult[RES_TIMELINE][index][RES_USER_NAME].string!
                                        timeLine.photo_url = jsonResult[RES_TIMELINE][index][RES_PHOTO_URL].string!
                                        
                                        timeLine.likeCount = jsonResult[RES_TIMELINE][index][RES_LIKECOUNT].int!
                                        timeLine.replyCount = jsonResult[RES_TIMELINE][index][RES_RESPONDCOUNT].int!
                                        timeLine.postedTime = jsonResult[RES_TIMELINE][index][RES_REGTIME].string!
                                        
                                        timeLine.location = CLLocationCoordinate2D(latitude: Double(jsonResult[RES_TIMELINE][index][RES_LATITUDE].string!)!, longitude: Double(jsonResult[RES_TIMELINE][index][RES_LONGITUDE].string!)!)
                                        
                                        
                                        let fileUrls = arrTimeLine[index][RES_FILE_URL].array
                                        if fileUrls != nil {
                                            for fIndex in 0 ..< fileUrls!.count {
                                                timeLine.file_url.append(fileUrls![fIndex].string!)
                                            }
                                        }
                                        
                                        timeLineList.append(timeLine)
                                    }
                                    
                                    completion(status: true, message: "", timeLineList: timeLineList)
                                    
                                    
                                } else {
                                    
                                    completion(status: true, message: Constants.NO_TIMELINE, timeLineList: [])
                                }
                                
                            } else {
                                
                                completion(status: true, message: Constants.NO_TIMELINE, timeLineList: [])
                            }
                            
                        } else {
                            
                            completion(status: false, message: Constants.FAIL_TO_CONNECT, timeLineList: [])
                        }
                        
                    } else {
                        
                        completion(status: false, message: Constants.FAIL_TO_CONNECT, timeLineList: [])
                    }
                    
                    
                case  .Failure(let error):
                    
                    debugPrint("failure to getAllTimeLine: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, timeLineList: [])
                }
        }
    }
    
    // get user information
    class func getUserInfo(id: Int, otherId: Int, completion: (status: Bool, message: String, user: FriendEntity?, timeLineList: [String]?) -> Void) {
        
        let url = BASE_URL + REQ_GETUSERINFOBYID + "/\(id)/\(otherId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        let user = FriendEntity()
                        
                        user._idx = Int(jsonResult[RES_USER_INFO][RES_IDX].string!)!
                        user._name = jsonResult[RES_USER_INFO][RES_NAME].string!
                        user._photoUrl = jsonResult[RES_USER_INFO][RES_PHOTO_URL].string!
                        user._lastLogin = jsonResult[RES_USER_INFO][RES_LASTLOGIN].string!
                        user._regDate = jsonResult[RES_USER_INFO][RES_REGTIME].string!
                        user._gender = (Int(jsonResult[RES_USER_INFO][RES_SEX].string!) == 0 ? .MALE : .FEMALE)
                        user._isFriend = (jsonResult[RES_USER_INFO][RES_ISFRIEND].int! == 1)
                        user.location = CLLocationCoordinate2D(latitude: Double(jsonResult[RES_USER_INFO][RES_LATITUDE].string!)!, longitude: Double(jsonResult[RES_USER_INFO][RES_LONGITUDE].string!)!)
                        user._countryCode = jsonResult[RES_USER_INFO][RES_COUNTRY].string!
                        user._school = jsonResult[RES_USER_INFO][RES_SCHOOL].string!
                        user._village = jsonResult[RES_USER_INFO][RES_VILLAGE].string!
                        user._favCountry = jsonResult[RES_USER_INFO][RES_COUNTRY2].string!
                        user._working = jsonResult[RES_USER_INFO][RES_WORKING].string!
                        user._interest = jsonResult[RES_USER_INFO][RES_INTEREST].string!
                        
                        let fileUrls = jsonResult[RES_USER_INFO][RES_TIMELINE].array!
                        var timeLineFileUrls = [String]()
                        for file in fileUrls {
                            timeLineFileUrls.append(file.string!)
                        }

                        completion(status: true, message: "", user: user, timeLineList: timeLineFileUrls)
                        
                    } else {
                        
                        completion(status: false, message: Constants.FAIL_TO_CONNECT, user: nil,  timeLineList: nil)
                    }
                    
                case  .Failure(let error):
                    
                    debugPrint("failure to getAllTimeLine: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, user: nil,  timeLineList: nil)
                }
        }
    }
    
    class func makeFriend(user_id: Int, other_id: Int, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_MAKEFRIEND + "/\(user_id)" + "/\(other_id)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                debugPrint(jsonResult)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true, message: Constants.SUCCESS_ADD_FRIEND)
                    
                } else {
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
                
                
            case .Failure(let error):
                
                debugPrint("make friend error: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func deleteFriend(user_id: Int, other_id: Int, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_DELETEFRIEND + "/\(user_id)" + "/\(other_id)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true, message: Constants.SUCCESS_DELETE)
                    } else {
                        
                        completion(status: false, message: Constants.FAIL_TO_CONNECT)
                    }
                    
                    
                case .Failure(let error):
                    
                    debugPrint("make friend error: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
        }
    }
    
    class func changeNickname(id: Int, nickname: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_CHANGENICKNAME + "/\(id)/\(nickname)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true, message: "")
                    
                } else {
                    
                    completion(status: true, message: Constants.ALEADY_EXIST_NICKNAME)
                }
                
            case .Failure(let error):
                
                debugPrint("fail to change nickname: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func changePassword(id: Int, currentPwd: String, newPwd: String, completion:(status: Bool, message: String) -> Void) {

        let url = BASE_URL + REQ_CHANGEPASSWORD + "/\(id)/\(currentPwd)/\(newPwd)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true, message: "")
                    
                } else {
                    
                    completion(status: true, message: Constants.PWD_RESET_ERROR)
                }
                
                
            case .Failure(let error):
                
                debugPrint("fail to change password: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    // shareStatus: 0 - no public, 1 - public
    class func shareLocation(id: Int, shareStatus: Int, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SETPUBLICLOCATION + "/\(id)/\(shareStatus)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true, message: "")
                    
                } else {
                
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
                
            case .Failure(let error):
                
                debugPrint("fail to share location: \(error)")
                
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func shareTimeLine(id: Int, shareStatus: Int, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SETPUBLICTIMELINE + "/\(id)/\(shareStatus)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true, message: "")
                        
                    } else {
                        
                        completion(status: false, message: Constants.FAIL_TO_CONNECT)
                    }
                    
                case .Failure(let error):
                    
                    debugPrint("fail to share timeline: \(error)")
                    
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
        }
    }
    
    class func setMyLocation(id: Int, lat: Double, long:  Double, completion: (status: Bool) -> Void) {

        let url = BASE_URL + REQ_SETLOCATION + "/\(id)/\(lat)/\(long)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                if resultCode == CODE_SUCCESS {
                    completion(status: true)
                } else {
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to synch my location: \(error)")
                completion(status: false)
            }
        }
    }
    
    class func setBlockUser(user_id: Int, blockId: Int, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SETBLOCKUSER + "/\(user_id)/\(blockId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true, message: "")
                } else {
                    completion(status: false, message: "")
                }
                
            case .Failure(let error):
                debugPrint("Fail to block: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func setUnblockUser(user_id: Int, unblockId: Int, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SETUNBLOCKUSER + "/\(user_id)/\(unblockId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        completion(status: true, message: "")
                    } else {
                        completion(status: false, message: "")
                    }
                    
                case .Failure(let error):
                    debugPrint("Fail to block: \(error)")
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
        }
    }
    
    class func unblockUsers(userId: Int, unblockIdList: [String], completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_BLOCKFRIENDLIST
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(unblockIdList, options: [])
        let jsonString = String(data: jsonData, encoding: NSUTF8StringEncoding)
        
        let params: [String: AnyObject] = [
            PARAM_ID: "\(userId)",
            PARAM_FRIENDLIST: jsonString!
        ]
        
        print(JSON(params))
        
        Alamofire.request(.POST, url, parameters: params).validate()
        .responseJSON { (response) in
            
            switch response.result {
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true, message: "")
                } else {
                    completion(status: false, message: "")
                }
                
            case .Failure(let error):
                debugPrint("fail to unblock users: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func sendCode(code: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_GETRECOVERYCODE + "/\(code)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result  {
                
            case .Success( let result ):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true, message: "")
                } else {
                    completion(status: false, message: "")
                }
            case .Failure(let error):
                debugPrint("Fail to get recovery code: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }        
    }
    
    class func getTempPassword(emailorPhone: String, verifyCode: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_TEMPPASSWORD + "/" + emailorPhone + "/" + verifyCode
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonresult = JSON(result)
                let resultCode = jsonresult[RES_RESULTCODE].int
                
                if resultCode == CODE_SUCCESS {
                    
                    let tempPassword = jsonresult[RES_TEMPPWD].string!
                    completion(status: true, message: tempPassword)
                    
                } else {
                    completion(status: false, message: "")
                }
                
            case .Failure(let error):
                debugPrint("Fail to get password: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func searchFriend(userId: Int, name: String, completion: (status: Bool, message: String, searchUser: FriendEntity?) -> Void) {
        
        let url = BASE_URL + REQ_SEARCHUSER + "/\(userId)/" + name
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                let searchUser = FriendEntity()
                if resultCode == CODE_SUCCESS {
                    
                    searchUser._idx = Int(jsonResult[RES_USER_INFO][RES_ID].string!)!
                    searchUser._name = jsonResult[RES_USER_INFO][RES_NAME].string!
                    searchUser._photoUrl = jsonResult[RES_USER_INFO][RES_PHOTO_URL].string!
                    searchUser._isFriend = (jsonResult[RES_USER_INFO][RES_ISFRIEND].int! == 1)
                    
                    completion(status: true, message: "", searchUser: searchUser)
                } else {
                    
                    completion(status: false, message: "", searchUser: nil)
                }
                
            case .Failure(let error):
                debugPrint("Fail to search users: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT, searchUser: nil)
            }
        }
    }
    
    class func searchGroup(name: String, completion: (status: Bool, message: String, searchList: [GroupEntity]?) -> Void) {
        
        let url = BASE_URL + REQ_SEARCHGROUP + "/" + name
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    var grouplist = [GroupEntity]()
                    
                    if resultCode == CODE_SUCCESS {
                        
                        let arrGroups = jsonResult[RES_GROUPINFOS].array!
                        
                        for index in 0 ..< arrGroups.count {
                            
                            let model = GroupEntity()
                            model.name = arrGroups[index][RES_NAME].string!
                            model.nickname = arrGroups[index][RES_NICKNAME].string!
                            model.participants = arrGroups[index][RES_PARTICIPANT].string!
                            model.profileUrl = arrGroups[index][RES_PROFILE].string!
                            model.ownerID = Int(arrGroups[index][RES_USER_ID].string!)!
                            model.regDate = arrGroups[index][RES_REGDATE].string!.displayRegTime()
                            model.isRequested = (arrGroups[index][RES_REQUEST].int! == 1)
                            
                            let jsonUrls = arrGroups[index][RES_GROUPURLS].array!
                            for jsonUrl in jsonUrls {
                                model.profileUrls.append(jsonUrl.string!)
                            }
                            
                            grouplist.append(model)
                        }
                        
                        completion(status: true, message: "", searchList: grouplist)
                        
                    } else {
                        completion(status: false, message: "", searchList: nil)
                    }
                case .Failure(let error):
                    debugPrint("fail to search group: \(error)")
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, searchList: nil)
                }
        }
    }
    
    class func loadGroup(userId: Int, completion: (status: Bool, message: String, list: [GroupEntity]?) -> Void) {
        
        let url = BASE_URL + REQ_GETALLGROUP + "/\(userId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    var grouplist = [GroupEntity]()
                    if resultCode == CODE_SUCCESS {
                        
                        let arrGroups = jsonResult[RES_GROUPINFOS].array!
                        for index in 0 ..< arrGroups.count {
                            
                            let model = GroupEntity()
                            model.name = arrGroups[index][RES_NAME].string!
                            model.nickname = arrGroups[index][RES_NICKNAME].string!
                            model.participants = arrGroups[index][RES_PARTICIPANT].string!
                            model.profileUrl = arrGroups[index][RES_PROFILE].string!
                            model.ownerID = Int(arrGroups[index][RES_USER_ID].string!)!
                            model.regDate = arrGroups[index][RES_REGDATE].string!.displayRegTime()
                            model.countryCode = arrGroups[index][RES_COUNTRY].string!
                            
                            let jsonUrls = arrGroups[index][RES_GROUPURLS].array!
                            for jsonUrl in jsonUrls {
                                model.profileUrls.append(jsonUrl.string!)
                            }
                            
                            grouplist.append(model)
                        }
                        
                        completion(status: true, message: "", list: grouplist)
                        
                    } else {
                        completion(status: false, message: "", list: nil)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to load group list: \(error)")
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, list: nil)
                }
        }
    }
    
    class func setGroupProfile(groupName: String, photoPath: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SETGROUPPROFILE
        
        Alamofire.upload(
            .POST,
            url,
            multipartFormData: {  multipartFormData in
                
                multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: photoPath), name: PARAM_FILE)
                multipartFormData.appendBodyPart(data: groupName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_NAME)
                
            }, encodingCompletion: { encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .Success(let result):
                            
                            let jsonResult = JSON(result)
                            let resultCode = jsonResult[RES_RESULTCODE].int!
                            
                            if resultCode == CODE_SUCCESS {
                                let photoUrl = jsonResult[RES_FILE_URL_ONE].string!
                                completion(status: true, message: photoUrl)
                                
                            } else {
                                completion(status: false, message: Constants.PHOTO_UPLOAD_FAIL)
                            }
                            
                        case .Failure(let error):
                            
                            debugPrint(error)
                            completion(status: false, message: Constants.PHOTO_UPLOAD_FAIL)
                        }
                    }
                case .Failure(let encodingError):
                    
                    debugPrint(encodingError)
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
        })
    }
    
    class func uploadGroup(ownerId: Int, name: String, participants: String, completion:(status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_MAKEGROUP + "/\(ownerId)/" + name + "/" + participants
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            switch response.result {
                
            case .Success(let result):
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true, message: "")
                } else {
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
            case .Failure(let error):
                debugPrint("failt to upload group: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func changeGroupNickname(groupName: String, nickname: String, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SETGROUPNICKNAME + "/" + groupName + "/" + nickname
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
            case .Success(let result):
                
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                if resultCode == CODE_SUCCESS {
                    completion(status: true, message: "")
                } else {
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }
            case .Failure(let error):
                debugPrint("fail to change group nickname: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func uploadFile(image: UIImage, type: Int, fileName: String, userId: Int, model: ChatEntity, completion: (status: Bool, message: String, completedModel: ChatEntity) -> Void) {
        
        let url = BASE_URL + REQ_UPLOADFILE
        
        let imageData = UIImageJPEGRepresentation(image, 0.7)
        
        guard imageData != nil else {
            completion(status: false, message: "image nil", completedModel: model)
            return
        }
        
        Alamofire.upload(
            .POST,
            url,
            multipartFormData: {  multipartFormData in
                
                multipartFormData.appendBodyPart(data: imageData!, name: PARAM_FILE, fileName: fileName, mimeType: "image/png")
                multipartFormData.appendBodyPart(data: "\(userId)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_ID)
                multipartFormData.appendBodyPart(data: "\(type)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_TYPE)
                multipartFormData.appendBodyPart(data: "\(fileName)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_FILENAME)
                
            }, encodingCompletion: { encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .Success(let result):
                            
                            let jsonResult = JSON(result)
                            
                            let resultCode = jsonResult[RES_RESULTCODE].int!
                            if resultCode == CODE_SUCCESS {
                                
                                let fileUrl = jsonResult[RES_FILE_URL_ONE].string!
                                let fileName = jsonResult[RES_FILENAME].string!
                                
                                model._fileName = fileName                                
                                model._content = fileUrl
//                                model.imageModel!.originalURL = fileUrl
                                
                                print("upload file url: ------------- \(fileUrl)")
                                
                                completion(status: true, message: "", completedModel: model)
                                
                            } else {
                                completion(status: false, message: "", completedModel: model)
                            }
                            
                        case .Failure(let error):
                            
                            debugPrint(error)
                            completion(status: false, message: Constants.FAIL_TO_CONNECT, completedModel: model)
                        }
                    }
                case .Failure(let encodingError):
                    
                    debugPrint(encodingError)
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, completedModel: model)
                }
        })
    }
    
    class func uploadFile(uploadData: NSData, type: Int, fileName: String, userId: Int, model: ChatEntity, completion: (status: Bool, message: String, completedModel: ChatEntity) -> Void) {
       
        let url = BASE_URL + REQ_UPLOADFILE

        Alamofire.upload(
            .POST,
            url,
            multipartFormData: {  multipartFormData in
                multipartFormData.appendBodyPart(data: uploadData, name: PARAM_FILE, fileName: fileName, mimeType: "video/quicktime")
                multipartFormData.appendBodyPart(data: "\(userId)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_ID)
                multipartFormData.appendBodyPart(data: "\(type)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_TYPE)
                multipartFormData.appendBodyPart(data: "\(fileName)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: PARAM_FILENAME)
                
            }, encodingCompletion: { encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .Success(let result):
                            
                            let jsonResult = JSON(result)
                            
                            let resultCode = jsonResult[RES_RESULTCODE].int!
                            if resultCode == CODE_SUCCESS {
                                
                                let fileUrl = jsonResult[RES_FILE_URL_ONE].string!
                                let fileName = jsonResult[RES_FILENAME].string!
                                
                                model._fileName = fileName
                                model._content = fileUrl
                                
                                print("upload file url: ------------- \(fileUrl)")
                                
                                completion(status: true, message: "", completedModel: model)
                                
                            } else {
                                completion(status: false, message: "", completedModel: model)
                            }
                            
                        case .Failure(let error):
                            
                            debugPrint(error)
                            completion(status: false, message: Constants.FAIL_TO_CONNECT, completedModel: model)
                        }
                    }
                case .Failure(let encodingError):
                    
                    debugPrint(encodingError)
                    completion(status: false, message: Constants.FAIL_TO_CONNECT, completedModel: model)
                }
        })
    }
    
    class func setCountryCode(userId: Int, countryCode: String, completion:(status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_SETCOUNTRY + "/\(userId)/" + countryCode
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            switch response.result {
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true, message: "")
                } else {
                    completion(status: false, message: Constants.FAIL_TO_CONNECT)
                }                
                
            case .Failure(let error):
                debugPrint("fail to set country: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func setGroupOwner(roomName: String, ownerId: Int, completion: (status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_SETGROUPOWNER + "/\(roomName)/\(ownerId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case.Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true)
                } else {
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to set group owner: \(roomName) - \(error)")
                completion(status: false)
            }
        }
    }
    
    // delete timeline
    class func deleteTimeLine(timeLineId: Int, completion: (status: Bool, message: String) -> Void) {
        
        let url = BASE_URL + REQ_DELETETIMELINE + "/\(timeLineId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true, message: "")
                } else {
                    completion(status: false, message: "")
                }
                
            case .Failure(let error):
                debugPrint("fail to delete timeline: \(error)")
                completion(status: false, message: Constants.FAIL_TO_CONNECT)
            }
        }
    }
    
    class func getWeChatAccessToken(url: String, completion: (status: Bool, token: (String, String)) -> Void) {
        
        let escapedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        Alamofire.request(.GET, escapedUrl!, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                let jsonResult = JSON(result)
                let resultCode = jsonResult["access_token"].string!
                let openId = jsonResult["openid"].string!
                completion(status: true, token: (resultCode, openId))
                
            case .Failure(let error):
                debugPrint("get access token for wechat login:\(error)")
                completion(status: false, token: ("", ""))
            }
        }
    }
    
    class func getWeChatUserInfo(url: String, completion: (status: Bool, headImageUrl: String, nickname: String) -> Void) {
        
        let escapedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        Alamofire.request(.GET, escapedUrl!, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
            case .Success(let result):
                let jsonResult = JSON(result)
                
                var headImageUrl = ""
                if let _headImageUrl = jsonResult["headimgurl"].string {
                    headImageUrl = _headImageUrl
                }
                
                var nickname = ""
                if let _nickname = jsonResult["nickname"].string {
                    nickname = _nickname
                    if nickname.length > kNicknameMaxLength {
                        nickname = nickname.substringToIndex(nickname.startIndex.advancedBy(kNicknameMaxLength))
                    }
                }
                
                completion(status: true, headImageUrl: headImageUrl, nickname: nickname)

            case .Failure(let error):
                debugPrint("fail to get user info: \(error)")
                completion(status: false, headImageUrl: "", nickname: "")
            }
        }
    }
    
    class func registerDeviceToken(token: String, userId: Int, completion: (status: Bool) -> Void) {
        let url = BASE_URL + REQ_REGISTERTOKEN + "/\(userId)/\(token)"
        let escapedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        Alamofire.request(.GET, escapedUrl!, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                let jsonResult = JSON(result)
                
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true)
                } else {
                    
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to resgister device token: \(error)")
                completion(status: false)
            }
        }
    }
    
    class func reduceBadgeCount(userId: Int, count: Int, completion: (status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_REDUECEBAGECOUNT + "/\(userId)/\(count)"
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true)
                } else {
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to reduce badge count: \(error)")
                completion(status: false)
            }
            
        }
    }
    
    class func getNoteData(completion: (status: Bool, noti: TimeLineEntity?) -> Void) {
        
        let url = BASE_URL + REQ_GETNOTE
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
            
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int
                
                if resultCode == CODE_SUCCESS {
                    
                    let timeLine = TimeLineEntity()
                    timeLine.content = jsonResult[RES_NOTEINFO][RES_CONTENT].string!
                    timeLine.postedTime = jsonResult[RES_NOTEINFO][RES_REGDATE].string!
                    timeLine.user_name = Constants.APP_NAME
                    
                    let fileUrls = jsonResult[RES_NOTEINFO][RES_FILE_URL].array!
                    for fIndex in 0 ..< fileUrls.count {
                        timeLine.file_url.append(fileUrls[fIndex].string!)
                    }
                    
                    completion(status: true, noti: timeLine)
                    
                } else {
                    completion(status: false, noti: nil)
                }
                
            case .Failure(let error):
                debugPrint("fail to get noti: \(error)")
                completion(status: false, noti: nil)
            }
        }
    }
    
    class func loadOnlineMessage(userId: Int, pageIndex: Int, completion: (status: Bool, contents: [(Int, String)]?) -> Void) {
        
        let url = BASE_URL + REQ_GETONLINEMESSAGE + "/\(userId)/\(pageIndex)"
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                print(jsonResult)
                
                if resultCode == CODE_SUCCESS {
                    
                    var contents = [(Int, String)]()
                    
                    let messages = jsonResult[RES_MESSAGEINFOS].array!
                    for message in messages {
                        
                        let msg = message[RES_MESSAGE].string!
                        let sentTime = message[RES_REGDATE].string!
                        let type = Int(message[RES_TYPE].string!)!
                        let width = Int(message[RES_WIDTH].string!)!
                        let height = Int(message[RES_HEIGHT].string!)!
                        
                        var fullMsg = ""
                        if msg.hasPrefix(UPLOADPATH) {
                            fullMsg = Constants.KEY_IMAGE_MARKER + msg + Constants.KEY_SEPERATOR + "\(width)" + Constants.KEY_SEPERATOR + "\(height)" + Constants.KEY_SEPERATOR + msg.fileNamFromUrl() + Constants.KEY_SEPERATOR + sentTime.convertTimeString()
                        } else {
                            fullMsg = msg + Constants.KEY_SEPERATOR + sentTime.convertTimeString()
                        }
                        
                        contents.append((type, fullMsg))
                    }
                    
                    completion(status: true, contents: contents)
                } else {
                    
                    completion(status: false, contents: nil)
                }
                
            case .Failure(let error):
                debugPrint("fail to get online message: \(error)")
                completion(status: false, contents: nil)
            }
        }
    }
    
    class func sendOnlineMessage(userId: Int, message: String, isImage: Bool, width: Int, height: Int, completion: (status: Bool) -> Void) {
        
        let params = [
            PARAM_ID: userId,
            PARAM_MESSAGE: message.encodeString()!,
            PARAM_ISIMAGE: isImage ? "1" : "0",
            PARAM_WIDTH: width,
            PARAM_HEIGHT: height
        ]
        
        let url = BASE_URL + REQ_SENDONLINEMESSAGE
        
        Alamofire.request(.POST, url, parameters: params as? [String : AnyObject]).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let jsonResult = JSON(result)
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true)
                    } else {
                        
                        completion(status: false)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to send online message: \(error)")
                    completion(status: false)
                }
        }
    }
    
    class func logout(userId: Int, completion: (status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_LOGOUT + "/\(userId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                debugPrint("response: \(JSON(result))")
                completion(status: true)
            case .Failure(let error):
                debugPrint("fail to logout:\(error)")
                completion(status: false)
            }
        }
    }
    
    // user address will be email or phonenumber
    class func checkDeviceId(username: String, completion: (status: Bool, validId: Int) -> Void) {
        
        let deviceId = CommonUtils.uuidString()
        let url = BASE_URL + REQ_CHECKDEVICEID + "/\(username)/\(deviceId)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    // valid user
                    completion(status: true, validId: 0)
                    
                } else if resultCode == CODE_UNREGISTERED {
                    
                    // unregistered user
                    completion(status: true, validId: 1)
                } else {
                    
                    // login with already logged in account
                    completion(status: true, validId: 2)
                }
                
            case .Failure(let error):
                debugPrint("fail to check deviceId: \(error)")
                completion(status: false, validId: -1)
            }
        }
    }
    
    class func setBadgeCount(userId: Int, count: Int) {
        
        let url = BASE_URL + REQ_SETBADGECOUNT + "/\(userId)/\(count)"
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                debugPrint(result)
                
            case .Failure(let error):
                debugPrint("fail to set badge count: \(error)")
            }
        }
    }
    
    class func setPayment(userId: Int, amount: Int, completion: (status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_SETPAYMENT + "/\(userId)/\(amount)"
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                debugPrint("success to set payment: \(JSON(result))")
                completion(status: true)
                
            case .Failure(let error):
                debugPrint("fail to set payment: \(error)")
                completion(status: false)
            }
        }
        
    }
    
    // set participant to server
    // update server database
    class func setParticipantToServer(name: String, participants: String, completion: (status: Bool, groupProfileUrls: [String]?) -> Void) {
        
        let url = BASE_URL + REQ_SETGROUPPARTICIPANT + "/" + name + "/" + participants
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { response in
                
                switch response.result {
                case .Success(let result):
                    let jsonResult = JSON(result)
                    let resultCode = jsonResult[RES_RESULTCODE].int!
                    
                    if resultCode == CODE_SUCCESS {
                        
                        var groupProfileUrls = [String]()
                        let jsonUrls = jsonResult[RES_GROUPURLS].array!
                        for url in jsonUrls {
                            groupProfileUrls.append(url.string!)
                        }
                        
                        completion(status: true, groupProfileUrls: groupProfileUrls)
                    } else {
                        completion(status: false, groupProfileUrls: nil)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to update group participants: \(error)")
                    completion(status: false, groupProfileUrls: nil)                    
                }}
    }
    
//    //updated group participant
//    /**
//     - parameter name: room name
//     - parameter participants: room participants idx array (1_2_3_....)
//     */
//    class func updateGroupParticipants(name: String, participants: String, completion: (status: Bool) -> Void) {
//        
//        let url = BASE_URL + REQ_SETGROUPPARTICIPANT + "/" + name + "/" + participants
//        
//        Alamofire.request(.GET, url, parameters: nil).validate()
//            .responseJSON { response in
//                
//                switch response.result {
//                case .Success(let result):
//                    let jsonResult = JSON(result)
//                    let resultCode = jsonResult[RES_RESULTCODE].int!
//                    
//                    if resultCode == CODE_SUCCESS {
//                        completion(status: true)
//                    } else {
//                        completion(status: false)
//                    }
//                    
//                case .Failure(let error):
//                    debugPrint("fail to update group participants: \(error)")
//                    completion(status: false)
//                    
//                }}
//    }
//    
//    class func setLeaveMemberToServer(roomName: String, participants: String, completion: (status: Bool) -> Void) {
//        
//        let url = BASE_URL + REQ_SETGROUPPARTICIPANT + "/\(roomName)/\(participants)"
//        
//        Alamofire.request(.GET, url, parameters: nil).validate()
//        .responseJSON { (response) in
//            
//            switch response.result {
//                
//            case .Success(let result):
//                
//                let json = JSON(result)
//                let resultCode = json[RES_RESULTCODE].int
//                
//                if resultCode == CODE_SUCCESS {
//                    
//                    completion(status: true)
//                } else {
//                    completion(status: false)
//                }
//                
//            case .Failure(let error):
//                debugPrint("fail to set group participants: \(error)")
//                completion(status: false)
//            }
//        }
//    }
    
    class func setSchool(userId: Int, name: String, completion:(status: Bool) -> Void) {

        let url = BASE_URL + REQ_SETSCHOOL + "/\(userId)/\(name.encodeString()!)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let json = JSON(result)
                let resultCode = json[RES_RESULTCODE].int
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true)
                } else {
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to set group participants: \(error)")
                completion(status: false)
            }
        }
    }
    
    class func setVillage(userId: Int, name: String, completion:(status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_SETVILLAGE + "/\(userId)/\(name.encodeString()!)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let json = JSON(result)
                    let resultCode = json[RES_RESULTCODE].int
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true)
                    } else {
                        completion(status: false)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to set group participants: \(error)")
                    completion(status: false)
                }
        }
    }
    
    class func setFavCountry(userId: Int, name: String, completion:(status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_SETCOUNTRY2 + "/\(userId)/\(name.encodeString()!)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let json = JSON(result)
                    let resultCode = json[RES_RESULTCODE].int
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true)
                    } else {
                        completion(status: false)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to set group participants: \(error)")
                    completion(status: false)
                }
        }
    }
    
    class func setWorking(userId: Int, name: String, completion:(status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_SETWORKING + "/\(userId)/\(name.encodeString()!)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let json = JSON(result)
                    let resultCode = json[RES_RESULTCODE].int
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true)
                    } else {
                        completion(status: false)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to set group participants: \(error)")
                    completion(status: false)
                }
        }
    }
    
    class func setInterest(userId: Int, name: String, completion:(status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_SETINTEREST + "/\(userId)/\(name.encodeString()!)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .Success(let result):
                    
                    let json = JSON(result)
                    let resultCode = json[RES_RESULTCODE].int
                    
                    if resultCode == CODE_SUCCESS {
                        
                        completion(status: true)
                    } else {
                        completion(status: false)
                    }
                    
                case .Failure(let error):
                    debugPrint("fail to set group participants: \(error)")
                    completion(status: false)
                }
        }
    }
    
    class func sendGroupRequest(userId: Int, requestGroup: GroupEntity, content: String, completion: (status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_GROUPREQUEST
        
        let params: [String: AnyObject] = [
            PARAM_ID: "\(userId)",
            PARAM_CONTENT: content.encodeString()!,
            PARAM_USERID: "\(userId)",
            PARAM_GROUPNAME: requestGroup.name
        ]
        
        Alamofire.request(.POST, url, parameters: params).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let json = JSON(result)
                let resultCode = json[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    completion(status: true)
                } else {
                    
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to send a group request: \(error)")
                completion(status: false)
            }
        }
    }
    
    class func getGroupRequestByUserId(userId: Int, roomName: String, completion: (status: Bool, request: GroupRequestEntity?) -> Void) {
        
        let url = BASE_URL + REQ_GETGROUPREQUESTBYID + "/\(roomName)/\(userId)"
        
        Alamofire.request(.GET, url).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    let requestArray = jsonResult[RES_GROUPREQUESTS].array!
                    
                    if requestArray.count == 0 {
                        completion(status: true, request: nil)
                    }
                    
                    let jsonRequest = requestArray[0]
                    let request = GroupRequestEntity()
                    request.groupName = roomName
                    request.userId = Int(jsonRequest[RES_USER_ID].string!)!
                    request.username = jsonRequest[RES_USER_NAME].string!
                    request.userPhoto = jsonRequest[RES_USERPHOTO].string!
                    request.content = jsonRequest[RES_CONTENT].string!
                    
                    completion(status: true, request: request)
                    
                } else {
                    completion(status: false, request: nil)
                }
                
            case .Failure(let error):
                debugPrint("fail to get group request by user id: \(error)")
                completion(status: false, request: nil)
            }
        }
    }
    
    class func getGroupRequest(roomName: String, completion: (status: Bool, requests: [GroupRequestEntity]?) -> Void) {
        
        
        let url = BASE_URL + REQ_GETGROUPREQUEST + "/\(roomName)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case . Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    
                    var requests = [GroupRequestEntity]()
                    let requestArray = jsonResult[RES_GROUPREQUESTS].array!
                    for jsonRequest in requestArray {
                        
                        let request = GroupRequestEntity()
                        request.groupName = roomName
                        request.userId = Int(jsonRequest[RES_USER_ID].string!)!
                        request.username = jsonRequest[RES_USER_NAME].string!
                        request.userPhoto = jsonRequest[RES_USERPHOTO].string!
                        request.content = jsonRequest[RES_CONTENT].string!
                        
                        requests.append(request)
                    }
                    
                    completion(status: true, requests: requests)                    
                } else {
                    
                    completion(status: false, requests: [])
                }
                
            case .Failure(let error):
                debugPrint("fail to get group requests: \(error)")
                completion(status: false, requests: nil)
            }
        }
    }
    
    class func acceptGroupRequest(request: GroupRequestEntity, participants: String, completion: (status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_ACCEPTGROUPREQUEST + "/\(request.userId)/\(request.groupName)/\(participants)"
        
        Alamofire.request(.GET, url, parameters: nil).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true)
                } else {
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to accpet group request: \(error)")
                completion(status: false)
            }
        }
    }
    
    class func declineGroupRequest(request: GroupRequestEntity, completion: (status: Bool) -> Void) {
        
        let url = BASE_URL + REQ_DECLINEGROUPREQUEST + "/\(request.userId)/\(request.groupName)"
        
        Alamofire.request(.GET, url).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    completion(status: true)
                } else {
                    completion(status: false)
                }
                
            case .Failure(let error):
                debugPrint("fail to decline group request: \(error)")
                completion(status: false)
            }
        }
    }
    
    class func getGroupProfile(roomName: String, completion: (status: Bool, groupProfileUrls: [String]?) -> Void) {
        
        let url = BASE_URL + REQ_GETGROUPPROFILE + "/\(roomName)"
        
        Alamofire.request(.GET, url).validate()
        .responseJSON { (response) in
            
            switch response.result {
                
            case .Success(let result):
                
                let jsonResult = JSON(result)
                let resultCode = jsonResult[RES_RESULTCODE].int!
                
                if resultCode == CODE_SUCCESS {
                    var groupProfileUrls = [String]()
                    let jsonUrls = jsonResult[RES_GROUPURLS].array!
                    
                    for jsonUrl in jsonUrls {
                        groupProfileUrls.append(jsonUrl.string!)
                    }
                    
                    completion(status: true, groupProfileUrls: groupProfileUrls)
                } else {
                    
                    completion(status: false, groupProfileUrls: nil)
                }
                
            case .Failure(let error):
                debugPrint("fail to get group profile: \(error)")
                
                completion(status: false, groupProfileUrls: nil)
            }
        }
    }
}






