package com.julyseven.wonbridge.base;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.contacts.ContactsActivity;
import com.julyseven.wonbridge.message.MsgActivity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.mypage.MyPageActivity;
import com.julyseven.wonbridge.service.ServiceActivity;
import com.julyseven.wonbridge.timeline.TimelineActivity;

/**
 * Created by sss on 8/24/2016.
 */
public class CommonTabActivity extends CommonActivity implements View.OnClickListener{

    protected LinearLayout ui_lytTimeLine, ui_lytMsg, ui_lytMyPage, ui_lytContact, ui_lytService;
    protected ImageView ui_imvTimeLine, ui_imvMyPage, ui_imvContact, ui_imvMsg, ui_imvService;
    protected TextView ui_txvTimeLine, ui_txvMyPage, ui_txvContact, ui_txvMsg, ui_txvService;

    protected TextView ui_txvUnread;
    protected UserEntity _user;

    @Override
    public void onCreate(Bundle savedInstanceState){

        super.onCreate(savedInstanceState);

        _user = Commons.g_user;
        Commons.g_currentActivity = this;
    }

    public void loadLayout() {

        ui_lytTimeLine = (LinearLayout) findViewById(R.id.lyt_timeline);
        ui_txvTimeLine = (TextView)findViewById(R.id.txv_timeline);
        ui_imvTimeLine = (ImageView)findViewById(R.id.imv_timeline);

        ui_lytMsg = (LinearLayout) findViewById(R.id.lyt_msg);
        ui_txvMsg = (TextView)findViewById(R.id.txv_msg);
        ui_imvMsg = (ImageView)findViewById(R.id.imv_msg);

        ui_lytMyPage = (LinearLayout) findViewById(R.id.lyt_mypage);
        ui_imvMyPage = (ImageView)findViewById(R.id.imv_mypage);
        ui_txvMyPage = (TextView)findViewById(R.id.txv_mypage);

        ui_lytContact = (LinearLayout) findViewById(R.id.lyt_contact);
        ui_imvContact = (ImageView)findViewById(R.id.imv_contact);
        ui_txvContact = (TextView)findViewById(R.id.txv_contact);

        ui_lytService = (LinearLayout) findViewById(R.id.lyt_service);
        ui_imvService = (ImageView)findViewById(R.id.imv_service);
        ui_txvService = (TextView)findViewById(R.id.txv_service);

        ui_lytTimeLine.setOnClickListener(this);
        ui_lytMsg.setOnClickListener(this);
        ui_lytMyPage.setOnClickListener(this);
        ui_lytContact.setOnClickListener(this);
        ui_lytService.setOnClickListener(this);

        ui_txvUnread = (TextView) findViewById(R.id.txv_unread);
    }

    public void setUnRead() {

        int unread = 0;

        for (RoomEntity room :_user.get_roomList()) {
            unread += room.get_recentCounter();
        }

        if (unread == 0) {
            ui_txvUnread.setVisibility(View.INVISIBLE);
        } else {
            ui_txvUnread.setVisibility(View.VISIBLE);
            ui_txvUnread.setText(String.valueOf(unread));
        }

        updateBadgeCount(unread);
    }

    public void gotoTimeline() {

        Intent intent = new Intent(this, TimelineActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        overridePendingTransition(0, 0);
        finish();
    }

    public void gotoMessage() {

        Intent intent = new Intent(this, MsgActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        overridePendingTransition(0, 0);
        finish();
    }

    public void gotoMyPage() {

        Intent intent = new Intent(this, MyPageActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        overridePendingTransition(0, 0);
        finish();
    }

    public void gotoContact() {

        Intent intent = new Intent(this, ContactsActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        overridePendingTransition(0, 0);
        finish();
    }

    public void gotoService() {

        Intent intent = new Intent(this, ServiceActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        overridePendingTransition(0, 0);
        finish();
    }

    @Override
    public void onClick(View view) {

    }


    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {

            onExit();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }


}
