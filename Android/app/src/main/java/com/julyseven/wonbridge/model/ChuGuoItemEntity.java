package com.julyseven.wonbridge.model;

/**
 * Created by JIS on 9/15/2016.
 */
public class ChuGuoItemEntity {

    String _name = "";
    int _imageId = 0;

    public ChuGuoItemEntity(String itemName, int imageId) {

        _name = itemName;
        _imageId = imageId;
    }

    public String get_name() {
        return _name;
    }

    public void set_name(String _name) {
        this._name = _name;
    }

    public int get_imageId() {
        return _imageId;
    }

    public void set_imageId(int _imageId) {
        this._imageId = _imageId;
    }
}
