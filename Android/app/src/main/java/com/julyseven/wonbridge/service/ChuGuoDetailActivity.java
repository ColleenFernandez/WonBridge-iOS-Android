package com.julyseven.wonbridge.service;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.mypage.QAActivity;

public class ChuGuoDetailActivity extends CommonActivity implements View.OnClickListener {


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chuguo_detail);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText("重磅消息，新一一批澳洲打工工度假签证将于9⽉ 5⽇申请");

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvChuguoQA = (TextView) findViewById(R.id.txv_chuguo_qa);
        txvChuguoQA.setOnClickListener(this);

    }

    public void gotoQaOnline() {

        Intent intent = new Intent(ChuGuoDetailActivity.this, GroupChattingActivity.class);
        intent.putExtra(Constants.KEY_ONLINE_SERVICE, true);
        startActivity(intent);
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

            case R.id.txv_chuguo_qa:
                gotoQaOnline();
                break;


        }

    }


}
