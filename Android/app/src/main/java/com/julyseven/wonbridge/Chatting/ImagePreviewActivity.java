package com.julyseven.wonbridge.Chatting;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.VideoView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.utils.TouchImageView;

public class ImagePreviewActivity extends CommonActivity implements View.OnClickListener {

    TouchImageView ui_imvPreview;

    String _imagePath = "";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_image_preview);

        _imagePath = getIntent().getStringExtra(Constants.KEY_IMAGEPATH);

        loadLayout();
    }

    private void loadLayout() {

        ui_imvPreview = (TouchImageView) findViewById(R.id.imv_preview);
        Glide.with(this).load(_imagePath).asBitmap().into(new SimpleTarget<Bitmap>() {
            @Override
            public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                ui_imvPreview.setImageBitmap(resource);
            }
        });

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

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
