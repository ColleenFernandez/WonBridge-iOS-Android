package com.julyseven.wonbridge.model;

/**
 * Created by JIS on 9/26/2016.
 */

public class VideoEntity {

    int _id;
    String _path;
    int _duration;

    public int get_id() {
        return _id;
    }

    public void set_id(int _id) {
        this._id = _id;
    }

    public String get_path() {
        return _path;
    }

    public void set_path(String _path) {
        this._path = _path;
    }

    public int get_duration() {
        return _duration;
    }

    public void set_duration(int _duration) {
        this._duration = _duration;
    }
}


