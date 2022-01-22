package com.julyseven.wonbridge.mypage;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;

public class QAActivity extends CommonActivity implements View.OnClickListener {


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mypage_qa);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.mypage_service));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        LinearLayout lytQaPhone = (LinearLayout) findViewById(R.id.lyt_qa_phone);
        lytQaPhone.setOnClickListener(this);

        LinearLayout lytQaEmail = (LinearLayout) findViewById(R.id.lyt_qa_email);
        lytQaEmail.setOnClickListener(this);

        LinearLayout lytQaOnline = (LinearLayout) findViewById(R.id.lyt_qa_online);
        lytQaOnline.setOnClickListener(this);

        LinearLayout lytHelp = (LinearLayout) findViewById(R.id.lyt_help);
        lytHelp.setOnClickListener(this);


    }

    public void gotoQaPhone() {

//        Intent intent = new Intent(QAActivity.this, QAPhoneActivity.class);
//        startActivity(intent);

        if (Commons.g_isChina) {
            String permissions[] = {Manifest.permission.CALL_PHONE};

            if (ContextCompat.checkSelfPermission(_context, Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {

                Intent intent = new Intent(Intent.ACTION_DIAL);
                intent.setData(Uri.parse("tel:" + getString(R.string.service_phone_number)));
                startActivity(intent);
            } else {
                ActivityCompat.requestPermissions(Commons.g_commonActivity, permissions, Constants.REQUST_PERMISSION);
            }
        } else {
            showAlertDialog(getString(R.string.not_use_phone));
        }
    }

    public void gotoQaEmail() {

//        Intent intent = new Intent(QAActivity.this, QAEmailActivity.class);
//        startActivity(intent);

        startActivity(new Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:" + getString(R.string.service_email))));

    }

    public void gotoQaOnline() {

        Intent intent = new Intent(QAActivity.this, GroupChattingActivity.class);
        intent.putExtra(Constants.KEY_ONLINE_SERVICE, true);
        startActivity(intent);
    }

    public void gotoHelp() {

        Intent intent = new Intent(QAActivity.this, HelpActivity.class);
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

            case R.id.lyt_qa_email:
                gotoQaEmail();
                break;

            case R.id.lyt_qa_phone:
                gotoQaPhone();
                break;

            case R.id.lyt_qa_online:
                gotoQaOnline();
                break;

            case R.id.lyt_help:
                gotoHelp();
                break;

        }

    }


}
