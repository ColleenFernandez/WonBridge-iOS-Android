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
public class RespondEntity implements Serializable {

    int _id = 0;
    int _userId = 0;
    String _userProfile = "";
    String _userName = "";
    String _content = "";
    String _writeTime = "";

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

    public String get_writeTime() {
        return _writeTime;
    }

    public void set_writeTime(String _writeTime) {
        this._writeTime = _writeTime;
    }
}
