package com.julyseven.wonbridge.model;

import com.julyseven.wonbridge.commons.Constants;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

/**
 * Created by JIS on 9/15/2016.
 */
public class GroupRequestEntity implements Serializable{

    String _groupName = "";
    int _userId = 0;
    String _username = "";
    String _userPhoto = "";
    String _content = "";


    public String get_groupName() {
        return _groupName;
    }

    public void set_groupName(String _groupName) {
        this._groupName = _groupName;
    }

    public int get_userId() {
        return _userId;
    }

    public void set_userId(int _userId) {
        this._userId = _userId;
    }

    public String get_username() {
        return _username;
    }

    public void set_username(String _username) {
        this._username = _username;
    }

    public String get_userPhoto() {
        return _userPhoto;
    }

    public void set_userPhoto(String _userPhoto) {
        this._userPhoto = _userPhoto;
    }

    public String get_content() {
        return _content;
    }

    public void set_content(String _content) {
        this._content = _content;
    }
}
