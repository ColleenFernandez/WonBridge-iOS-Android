package com.julyseven.wonbridge.model;

import android.content.Context;

import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.preference.Preference;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by JIS on 9/11/2016.
 */
public class TimelineEntity implements Serializable {

    int _id = 0;
    int _userId = 0;
    String _userProfile = "";
    String _userName = "";
    String _content = "";
    String _userLastLogin = "";
    String _country = "CN";
    String _country2 = "";
    boolean _isFriend = false;
    int _likeCount = 0;
    int _respondCount = 0;
    float _latitude = 0.0f;
    float _longitude = 0.0f;
    String _writeTime = "";
    String _link = "";

    ArrayList<String> _fileUrls = new ArrayList<>();
    ArrayList<String> _likeUsernames = new ArrayList<>();
    ArrayList<RespondEntity> _2responds = new ArrayList<>();


    public int get_id() {
        return _id;
    }

    public void set_id(int _id) {
        this._id = _id;
    }

    public int get_userId() {
        return _userId;
    }

    public void set_userId(int _userId) {
        this._userId = _userId;
    }

    public String get_userProfile() {
        return _userProfile;
    }

    public void set_userProfile(String _userProfile) {
        this._userProfile = _userProfile;
    }

    public String get_userName() {
        return _userName;
    }

    public void set_userName(String _userName) {
        this._userName = _userName;
    }

    public String get_content() {
        return _content;
    }

    public void set_content(String _content) {
        this._content = _content;
    }

    public ArrayList<String> get_fileUrls() {
        return _fileUrls;
    }

    public void set_fileUrls(ArrayList<String> _fileUrls) {
        this._fileUrls = _fileUrls;
    }

    public int get_likeCount() {
        return _likeCount;
    }

    public void set_likeCount(int _likeCount) {
        this._likeCount = _likeCount;
    }

    public int get_respondCount() {
        return _respondCount;
    }

    public void set_respondCount(int _respondCount) {
        this._respondCount = _respondCount;
    }

    public float get_latitude() {
        return _latitude;
    }

    public void set_latitude(float _latitude) {
        this._latitude = _latitude;
    }

    public float get_longitude() {
        return _longitude;
    }

    public void set_longitude(float _longitude) {
        this._longitude = _longitude;
    }

    public String get_writeTime() {
        return _writeTime;
    }

    public void set_writeTime(String _writeTime) {
        this._writeTime = _writeTime;
    }

    public String get_userLastLogin() {
        return _userLastLogin;
    }

    public void set_userLastLogin(String _userLastLogin) {
        this._userLastLogin = _userLastLogin;
    }

    public boolean is_isFriend() {
        return _isFriend;
    }

    public void set_isFriend(boolean _isFriend) {
        this._isFriend = _isFriend;
    }

    public String get_country() {
        return _country;
    }

    public void set_country(String _country) {
        this._country = _country;
    }

    public String get_country2() {
        return _country2;
    }

    public void set_country2(String _country2) {
        this._country2 = _country2;
    }

    public ArrayList<String> get_likeUsernames() {
        return _likeUsernames;
    }

    public String get_link() {
        return _link;
    }

    public void set_link(String _link) {
        this._link = _link;
    }

    public void set_likeUsernames(ArrayList<String> _likeUsernames) {
        this._likeUsernames = _likeUsernames;
    }

    public ArrayList<RespondEntity> get_2responds() {
        return _2responds;
    }

    public void set_2responds(ArrayList<RespondEntity> _2responds) {
        this._2responds = _2responds;
    }

    public int getDistance(Context context) {

        float lat = Preference.getInstance().getValue(context, Constants.KEY_LATITUDE, 0.0f);
        float lng = Preference.getInstance().getValue(context, Constants.KEY_LONGITUDE, 0.0f);
        int distance = (int) Commons.calcDistance(lat, lng, _latitude, _longitude);

        return distance;
    }
}
