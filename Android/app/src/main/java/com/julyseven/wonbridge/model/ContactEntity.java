package com.julyseven.wonbridge.model;

/**
 * Created by JIS on 9/15/2016.
 */
public class ContactEntity {

    String _contactName = "";
    String _nickName = "";
    String _photoUrl = "";
    boolean _isMember = false;

    public ContactEntity(String contactname, String nickname, boolean isMember) {

        _contactName = contactname;
        _nickName = nickname;
        _isMember = isMember;
    }

    public String get_contactName() {
        return _contactName;
    }

    public void set_contactName(String _contactName) {
        this._contactName = _contactName;
    }

    public String get_nickName() {
        return _nickName;
    }

    public void set_nickName(String _nickName) {
        this._nickName = _nickName;
    }

    public boolean is_isMember() {
        return _isMember;
    }

    public void set_isMember(boolean _isMember) {
        this._isMember = _isMember;
    }

    public String get_photoUrl() {
        return _photoUrl;
    }

    public void set_photoUrl(String _photoUrl) {
        this._photoUrl = _photoUrl;
    }
}
