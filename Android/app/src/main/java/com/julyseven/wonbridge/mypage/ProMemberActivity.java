package com.julyseven.wonbridge.mypage;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;

public class ProMemberActivity extends CommonActivity implements View.OnClickListener {


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_promember);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.charge_service));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        LinearLayout lytCharge = (LinearLayout) findViewById(R.id.lyt_charge);
        lytCharge.setOnClickListener(this);

        LinearLayout lytVip= (LinearLayout) findViewById(R.id.lyt_vip);
        lytVip.setOnClickListener(this);

        LinearLayout lytOnline = (LinearLayout) findViewById(R.id.lyt_online);
        lytOnline.setOnClickListener(this);
    }

    private void onCharge() {

        Intent intent = new Intent(ProMemberActivity.this, ChargeActivity.class);
        startActivity(intent);
    }

    private void onChargeVip() {

        Intent intent = new Intent(ProMemberActivity.this, ChargeVipActivity.class);
        startActivity(intent);
    }

    private void onChargeOnline() {

        Intent intent = new Intent(ProMemberActivity.this, ChargeOnlineActivity.class);
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

            case R.id.lyt_charge:
                onCharge();
                break;

            case R.id.lyt_vip:
                onChargeVip();
                break;

            case R.id.lyt_online:
                onChargeOnline();
                break;

        }

    }


}
