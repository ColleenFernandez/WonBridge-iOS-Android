package com.julyseven.wonbridge.model;

/**
 * Created by JIS on 9/15/2016.
 */
public class ServiceItemEntity {

    int _id = 0;
    String _name = "";
    String _imageUrl = "";

    public ServiceItemEntity(int idx, String itemName, String imageUrl) {

        _id = idx;
        _name = itemName;
        _imageUrl = imageUrl;
    }

    public int get_id() {
        return _id;
    }

    public void set_id(int _id) {
        this._id = _id;
    }

    public String get_name() {
        return _name;
    }

    public void set_name(String _name) {
        this._name = _name;
    }

    public String get_imageUrl() {
        return _imageUrl;
    }

    public void set_imageUrl(String _imageUrl) {
        this._imageUrl = _imageUrl;
    }
}
