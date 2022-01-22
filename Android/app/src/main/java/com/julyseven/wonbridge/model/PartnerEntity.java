package com.julyseven.wonbridge.model;

/**
 * Created by JIS on 9/15/2016.
 */
public class PartnerEntity {

    String _partnerName = "";
    String _photoUrl = "";

    public PartnerEntity() {
    }

    public String get_partnerName() {
        return _partnerName;
    }

    public void set_partnerName(String _partnerName) {
        this._partnerName = _partnerName;
    }

    public String get_photoUrl() {
        return _photoUrl;
    }

    public void set_photoUrl(String _photoUrl) {
        this._photoUrl = _photoUrl;
    }
}
