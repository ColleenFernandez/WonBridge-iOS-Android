package com.julyseven.wonbridge.model;

import android.content.Context;

import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.preference.Preference;

import java.io.Serializable;

/**
 * Created by HGS on 12/16/2015.
 */
public class FriendEntity implements Serializable{

    private int _idx = 0;
    private String _name = "";
    private String _phoneNumber = "";
    private String _label = "";
    private String _bgUrl = "";
    private String _photoUrl = "";
    private int _sex = 0;    // 0: man 1: woman
    float _latitude = 0.0f;
    float _longitude = 0.0f;
    String _lastLogin = "";
    String _regDate = "";
    private int _blockStatus = 1;   // 1 unblock, 0 block
    private boolean _isSelected = false;
    private boolean _isFriend = false;
    private boolean _isPublic = false;
    private String _country = "CN";
    private String _country2 = "";
    String _school = "";
    String _village = "";
    String _working = "";
    String _interest = "";

    public int get_idx() {
        return _idx;
    }

    public void set_idx(int _idx) {
        this._idx = _idx;
    }

    public String get_name() {
        return _name;
    }

    public void set_name(String _name) {
        this._name = _name;
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

    public String get_bgUrl() {
        return _bgUrl;
    }

    public void set_bgUrl(String _bgUrl) {
        this._bgUrl = _bgUrl;
    }

    public String get_photoUrl() {
        return _photoUrl;
    }

    public void set_photoUrl(String _photoUrl) {
        this._photoUrl = _photoUrl;
    }

    public int get_blockStatus() {
        return _blockStatus;
    }

    public void set_blockStatus(int _blockStatus) {
        this._blockStatus = _blockStatus;
    }

    public boolean is_isSelected() {
        return _isSelected;
    }

    public void set_isSelected(boolean _isSelected) {
        this._isSelected = _isSelected;
    }

    public int get_sex() {
        return _sex;
    }

    public void set_sex(int _sex) {
        this._sex = _sex;
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

    public String get_lastLogin() {
        return _lastLogin;
    }

    public void set_lastLogin(String _lastLogin) {
        this._lastLogin = _lastLogin;
    }

    public boolean is_isFriend() {
        return _isFriend;
    }

    public void set_isFriend(boolean _isFriend) {
        this._isFriend = _isFriend;
    }

    public boolean is_isPublic() {
        return _isPublic;
    }

    public void set_isPublic(boolean _isPublic) {
        this._isPublic = _isPublic;
    }

    public String get_regDate() {
        return _regDate;
    }

    public void set_regDate(String _regDate) {
        this._regDate = _regDate;
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

    @Override
    public boolean equals(Object o) {

        FriendEntity other = (FriendEntity) o;

        if (get_idx() == other.get_idx())
            return true;

        return false;
    }

    public int getDistance(Context context) {

        float lat = Preference.getInstance().getValue(context, Constants.KEY_LATITUDE, 0.0f);
        float lng = Preference.getInstance().getValue(context, Constants.KEY_LONGITUDE, 0.0f);
        int distance = (int) Commons.calcDistance(lat, lng, _latitude, _longitude);

        return distance;
    }
}


