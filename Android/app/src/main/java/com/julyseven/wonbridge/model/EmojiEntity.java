package com.julyseven.wonbridge.model;

import android.content.Context;

import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.preference.Preference;

import java.io.Serializable;

/**
 * Created by HGS on 12/16/2015.
 */
public class EmojiEntity implements Serializable{

    int _emojiId = 0;
    String _emojiString = "";

    public EmojiEntity(int idx, String str) {
        _emojiId = idx;
        _emojiString = str;
    }

    public int get_emojiId() {
        return _emojiId;
    }

    public void set_emojiId(int _emojiId) {
        this._emojiId = _emojiId;
    }

    public String get_emojiString() {
        return _emojiString;
    }

    public void set_emojiString(String _emojiString) {
        this._emojiString = _emojiString;
    }
}


