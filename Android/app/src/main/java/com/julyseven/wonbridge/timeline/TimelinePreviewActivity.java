package com.julyseven.wonbridge.timeline;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.TimelinePreviewAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.utils.TouchImageView;

import java.util.ArrayList;

public class TimelinePreviewActivity extends CommonActivity implements View.OnClickListener {

    ViewPager ui_viewPager;
    TimelinePreviewAdapter _adapter;
    TextView ui_txvImageNo;

    ArrayList<String> _imagePaths = new ArrayList<>();


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_timeline_preview);

        _imagePaths = getIntent().getStringArrayListExtra(Constants.KEY_IMAGEPATH);

        loadLayout();
    }

    private void loadLayout() {

        ui_txvImageNo = (TextView) findViewById(R.id.txv_timeline_no);
        ui_txvImageNo.setText("1 / " + _imagePaths.size());

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_viewPager = (ViewPager) findViewById(R.id.viewpager);
        _adapter = new TimelinePreviewAdapter(this);
        ui_viewPager.setAdapter(_adapter);
        _adapter.setDatas(_imagePaths);

        ui_viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            }

            @Override
            public void onPageSelected(int position) {
                ui_txvImageNo.setText((position + 1) + " / " + _imagePaths.size());
            }

            @Override
            public void onPageScrollStateChanged(int state) {
            }
        });
    }


    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;


        }

    }


}
