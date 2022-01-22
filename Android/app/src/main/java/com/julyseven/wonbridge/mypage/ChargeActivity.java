package com.julyseven.wonbridge.mypage;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;

public class ChargeActivity extends CommonActivity implements View.OnClickListener {


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_charge);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.charge));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        LinearLayout lytManagePoint = (LinearLayout) findViewById(R.id.lyt_manage_point);
        lytManagePoint.setOnClickListener(this);

        LinearLayout lytDaxiang = (LinearLayout) findViewById(R.id.lyt_daxiang);
        lytDaxiang.setOnClickListener(this);

        TextView txvCharge = (TextView) findViewById(R.id.txv_charge);
        txvCharge.setOnClickListener(this);

    }

    public void onCharge() {



    }


    public void gotoManagePoint() {


    }


    public void gotoDaxiang() {


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


            case R.id.txv_charge:
                onCharge();
                break;

            case R.id.lyt_manage_point:
                gotoManagePoint();
                break;

            case R.id.lyt_daxiang:
                gotoDaxiang();
                break;

        }

    }


}
