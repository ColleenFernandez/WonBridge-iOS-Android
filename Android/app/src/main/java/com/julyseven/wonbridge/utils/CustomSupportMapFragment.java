package com.julyseven.wonbridge.utils;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.android.gms.maps.SupportMapFragment;

/**
 * Created by JIS on 10/7/2016.
 */

public class CustomSupportMapFragment extends SupportMapFragment {

    public View mOriginalContentView;
    public TouchableWrapper mTouchView;

    public CustomSupportMapFragment() {
        super();
    }

    public static CustomSupportMapFragment newInstance() {
        return new CustomSupportMapFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup parent, Bundle savedInstanceState) {
        mOriginalContentView = super.onCreateView(inflater, parent, savedInstanceState);
        mTouchView = new TouchableWrapper(getActivity());
        mTouchView.addView(mOriginalContentView);
        return mTouchView;
    }

    @Override
    public View getView() {
        return mOriginalContentView;
    }
}