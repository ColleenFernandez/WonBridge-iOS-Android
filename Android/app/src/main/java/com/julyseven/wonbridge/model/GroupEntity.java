package com.julyseven.wonbridge.model;

import com.julyseven.wonbridge.adapter.StringAdapter;
import com.julyseven.wonbridge.commons.Constants;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

/**
 * Created by JIS on 9/15/2016.
 */
public class GroupEntity implements Serializable{

    int _ownerIdx = 0;
    String _groupName = "";
    String _groupNickname = "";
    String _participants = "";
    String _groupProfileUrl = "";
    String _regDate = "";
    boolean _isRequested = false;
    String _country = "CN";
    ArrayList<String> _profileUrls = new ArrayList<>();


    public GroupEntity() {

    }


    public String get_groupName() {
        return _groupName;
    }

    public void set_groupName(String _groupName) {
        this._groupName = _groupName;
    }


    public String get_regDate() {
        return _regDate;
    }

    public void set_regDate(String _regDate) {
        this._regDate = _regDate;
    }

    public boolean is_isRequested() {
        return _isRequested;
    }

    public void set_isRequested(boolean _isRequested) {
        this._isRequested = _isRequested;
    }

    public int get_ownerIdx() {
        return _ownerIdx;
    }

    public void set_ownerIdx(int _ownerIdx) {
        this._ownerIdx = _ownerIdx;
    }

    public String get_groupNickname() {

        if (_groupNickname.length() == 0) {
            return Constants.DEFAULT_GROUPNAME;
        }

        return _groupNickname;
    }

    public void set_groupNickname(String _groupNickname) {
        this._groupNickname = _groupNickname;
    }

    public String get_participants() {
        return _participants;
    }

    public void set_participants(String _participants) {
        this._participants = _participants;
    }

    public String get_groupProfileUrl() {
        return _groupProfileUrl;
    }

    public void set_groupProfileUrl(String _groupProfileUrl) {
        this._groupProfileUrl = _groupProfileUrl;
    }

    public String get_country() {
        return _country;
    }

    public void set_country(String _country) {
        this._country = _country;
    }

    public ArrayList<String> get_profileUrls() {
        return _profileUrls;
    }

    public void set_profileUrls(ArrayList<String> _profileUrls) {
        this._profileUrls = _profileUrls;
    }

    public int getMemeberCount() {

        if (_participants.length() > 0) {
            return _participants.split("_").length;
        }

        return 0;

    }

    public void removeParticipant(int idx) {

        String[] ids = _participants.split("_");
        ArrayList<String> idList = new ArrayList<>(Arrays.asList(ids));

        if (idList.contains(String.valueOf(idx))) {
            idList.remove(String.valueOf(idx));
        }

        Collections.sort(idList, new Comparator<String>() {
            @Override
            public int compare(String lhs, String rhs) {
                return new Integer(lhs).compareTo(new Integer(rhs));
            }
        });

        String participant = "";
        for (String id : idList) {
            participant += id + "_";
        }

        if (participant.length() > 0)
            participant = participant.substring(0, participant.length() - 1);

        _participants = participant;

    }

    @Override
    public boolean equals(Object o) {

        GroupEntity other = (GroupEntity) o;
        return (get_groupName().equalsIgnoreCase(other.get_groupName()));
    }
}
