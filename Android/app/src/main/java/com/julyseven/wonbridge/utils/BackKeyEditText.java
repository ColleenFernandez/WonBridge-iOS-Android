package com.julyseven.wonbridge.utils;

import android.content.Context;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.julyseven.wonbridge.Chatting.GroupChattingActivity;

/**
 * Created by JIS on 9/25/2016.
 */

public class BackKeyEditText extends EditText {

    Context mContext;

    public BackKeyEditText(Context context) {
        super(context);
        mContext = context;
    }

    public BackKeyEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;

    }

    public boolean onKeyPreIme(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK &&
                event.getAction() == KeyEvent.ACTION_UP) {

            if (mContext instanceof GroupChattingActivity) {
                ((GroupChattingActivity) mContext).onBackKeyPressedOnKeyboard();
            }

            return false;
        }
        return super.dispatchKeyEvent(event);
    }

}
