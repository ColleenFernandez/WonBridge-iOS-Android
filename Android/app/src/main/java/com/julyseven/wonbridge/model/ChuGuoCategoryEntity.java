package com.julyseven.wonbridge.model;

/**
 * Created by JIS on 9/15/2016.
 */
public class ChuGuoCategoryEntity {

    String _categoryName = "";
    int _imageUrl = 0;
    String _country = "";
    String _description = "";


    public String get_categoryName() {
        return _categoryName;
    }

    public void set_categoryName(String _categoryName) {
        this._categoryName = _categoryName;
    }

    public int get_imageUrl() {
        return _imageUrl;
    }

    public void set_imageUrl(int _imageUrl) {
        this._imageUrl = _imageUrl;
    }

    public String get_country() {
        return _country;
    }

    public void set_country(String _country) {
        this._country = _country;
    }

    public String get_description() {
        return _description;
    }

    public void set_description(String _description) {
        this._description = _description;
    }
}


