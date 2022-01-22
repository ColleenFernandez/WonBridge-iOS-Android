package com.julyseven.wonbridge.model;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by sss on 8/23/2016.
 */
public class UserEntity implements Serializable {

    int _idx = 0;
    int _age = 0;
    String _bgUrl = "";
    String _phoneNumber = "";
    String _email = "";
    String _label = "";
    String _password = "";
    String _name = "";
    int _sex = 0;   // 0: man 1: woman
    String _photoUrl= "";
    String _location = "";
    String _regdate = "";
    boolean _isPublicLocation = true;
    boolean _isPublicTimeline = true;
    private String _country = "CN";
    String _wechatId = "";
    String _qqId = "";
    String _school = "";
    String _village = "";
    String _country2 = "";
    String _working = "";
    String _interest = "";



    public String get_bgUrl() {
        return _bgUrl;
    }

    public void set_bgUrl(String _bgUrl) {
        this._bgUrl = _bgUrl;
    }

    public String get_phoneNumber() {
        return _phoneNumber;
    }

    public void set_phoneNumber(String _phoneNumber) {
        this._phoneNumber = _phoneNumber;
    }

    public String get_label() {
        return _label;
    }

    public void set_label(String _label) {
        this._label = _label;
    }

    public String get_email() {
        return _email;
    }

    public void set_email(String _email) {
        this._email = _email;
    }

    public String get_password() {
        return _password;
    }

    public void set_password(String _password) {
        this._password = _password;
    }

    private ArrayList<FriendEntity> _friendList = new ArrayList<FriendEntity>();
    private ArrayList<FriendEntity> _blockList = new ArrayList<FriendEntity>();
    private ArrayList<RoomEntity> _roomList = new ArrayList<RoomEntity>();
    private ArrayList<GroupEntity> _groupList = new ArrayList<>();

    public ArrayList<FriendEntity> get_friendList() {
        return _friendList;
    }

    public void set_friendList(ArrayList<FriendEntity> _friendList) {
        this._friendList = _friendList;
    }

    public ArrayList<FriendEntity> get_blockList() {
        return _blockList;
    }

    public void set_blockList(ArrayList<FriendEntity> _blockList) {
        this._blockList = _blockList;
    }

    public ArrayList<RoomEntity> get_roomList() {
        return _roomList;
    }

    public void set_roomList(ArrayList<RoomEntity> _roomList) {
        this._roomList = _roomList;
    }

    public String get_wechatId() {
        return _wechatId;
    }

    public void set_wechatId(String _wechatId) {
        this._wechatId = _wechatId;
    }

    public String get_school() {
        return _school;
    }

    public void set_school(String _school) {
        this._school = _school;
    }

    public String get_village() {
        return _village;
    }

    public void set_village(String _village) {
        this._village = _village;
    }

    public String get_country2() {
        return _country2;
    }

    public void set_country2(String _country2) {
        this._country2 = _country2;
    }

    public String get_working() {
        return _working;
    }

    public void set_working(String _working) {
        this._working = _working;
    }

    public String get_interest() {
        return _interest;
    }

    public void set_interest(String _interest) {
        this._interest = _interest;
    }

    public RoomEntity getRoom(String roomName) {

        for (RoomEntity room : _roomList) {
            if (room.get_name().equals(roomName))
                return room;
        }

        return null;
    }

    public boolean isBlockUser(int friend) {

        for (FriendEntity entity : get_blockList()) {

            if (entity.get_idx() == friend)
                return true;
        }

        return false;
    }

    public boolean isBlockUser(FriendEntity friend) {

        if (get_blockList().contains(friend))
            return true;

        return false;
    }

    public boolean isFriend(int idx) {

        for (FriendEntity friend : _friendList) {

            if (friend.get_idx() == idx)
                return true;
        }

        return false;
    }

    public FriendEntity getFriend(int idx) {

        for (FriendEntity friend : _friendList) {

            if (friend.get_idx() == idx)
                return friend;
        }

        return null;
    }

    public int get_idx() {
        return _idx;
    }

    public void set_idx(int _idx) {
        this._idx = _idx;
    }

    public int get_age() {
        return _age;
    }

    public void set_age(int _age) {
        this._age = _age;
    }

    public String get_name() {
        return _name;
    }

    public void set_name(String _name) {
        this._name = _name;
    }

    public int get_sex() {
        return _sex;
    }

    public void set_sex(int _sex) {
        this._sex = _sex;
    }

    public String get_photoUrl() {
        return _photoUrl;
    }

    public void set_photoUrl(String _photoUrl) {
        this._photoUrl = _photoUrl;
    }

    public String get_location() {
        return _location;
    }

    public void set_location(String _location) {
        this._location = _location;
    }


    public String get_regdate() {
        return _regdate;
    }

    public void set_regdate(String _regdate) {
        this._regdate = _regdate;
    }

    public boolean is_isPublicLocation() {
        return _isPublicLocation;
    }

    public void set_isPublicLocation(boolean _isPublicLocation) {
        this._isPublicLocation = _isPublicLocation;
    }

    public boolean is_isPublicTimeline() {
        return _isPublicTimeline;
    }

    public void set_isPublicTimeline(boolean _isPublicTimeline) {
        this._isPublicTimeline = _isPublicTimeline;
    }

    public ArrayList<GroupEntity> get_groupList() {
        return _groupList;
    }

    public void set_groupList(ArrayList<GroupEntity> _groupList) {
        this._groupList = _groupList;
    }

    public String get_country() {
        return _country;
    }

    public void set_country(String _country) {
        this._country = _country;
    }

    public String get_qqId() {
        return _qqId;
    }

    public void set_qqId(String _qqId) {
        this._qqId = _qqId;
    }

    public GroupEntity getGroup(String groupname) {

        for (GroupEntity groupEntity : _groupList) {

            if (groupEntity.get_groupName().equals(groupname))
                return groupEntity;
        }

        return null;
    }
}
