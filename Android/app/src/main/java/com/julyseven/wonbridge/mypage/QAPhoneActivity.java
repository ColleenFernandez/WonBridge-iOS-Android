package com.julyseven.wonbridge.mypage;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;

public class QAPhoneActivity extends CommonActivity implements View.OnClickListener {


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qa_phone);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.qa_phone));

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
