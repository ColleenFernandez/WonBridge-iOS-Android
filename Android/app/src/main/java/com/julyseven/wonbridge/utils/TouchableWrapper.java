package com.julyseven.wonbridge.utils;

import android.content.Context;
import android.view.MotionEvent;
import android.widget.FrameLayout;

import com.julyseven.wonbridge.timeline.TimelineActivity;
import com.julyseven.wonbridge.timeline.TimelineFragment;

/**
 * Created by JIS on 10/7/2016.
 */

public class TouchableWrapper extends FrameLayout {

    Context _context;

    public TouchableWrapper(Context context) {
        super(context);
        _context = context;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {

        switch (event.getAction()) {

            case MotionEvent.ACTION_DOWN:
                ((TimelineActivity) _context).enableSwipeRefresh(false);
                break;

            case MotionEvent.ACTION_UP:
                ((TimelineActivity) _context).enableSwipeRefresh(true);
                break;
        }
        return super.dispatchTouchEvent(event);
    }
}