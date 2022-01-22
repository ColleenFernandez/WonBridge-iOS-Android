package com.julyseven.wonbridge.Chatting;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.VideoView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;

public class VideoPreviewActivity extends CommonActivity implements View.OnClickListener {


    VideoView ui_videoView;

    String _videoPath = "";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_preview);

        _videoPath = getIntent().getStringExtra(Constants.KEY_VIDEOPATH);

        loadLayout();
    }

    private void loadLayout() {

        TextView txvCancel = (TextView) findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(this);

        TextView txvOk = (TextView) findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(this);

        ImageView imvPlay = (ImageView) findViewById(R.id.imv_play);
        imvPlay.setOnClickListener(this);

        ui_videoView = (VideoView) findViewById(R.id.videoview);

        try {
            ui_videoView.setMediaController(null);
            ui_videoView.requestFocus();
            ui_videoView.setVideoURI(Uri.parse(_videoPath));
            ui_videoView.seekTo(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

    }


    public void playVideo() {

        ui_videoView.seekTo(0);
        ui_videoView.start();
    }

    public void onSend() {

        Intent intent = new Intent();
        intent.putExtra(Constants.KEY_VIDEOPATH, _videoPath);
        setResult(RESULT_OK, intent);
        finish();
    }

    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.txv_cancel:
                onBack();
                break;

            case R.id.imv_play:
                playVideo();
                break;

            case R.id.txv_ok:
                onSend();
                break;


        }

    }


}
