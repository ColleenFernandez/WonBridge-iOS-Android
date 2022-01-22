package com.julyseven.wonbridge.Chatting;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;

public class GroupNotiActivity extends CommonActivity implements View.OnClickListener {

    public static final int MAX_CHARS = 1000;

    TextView ui_txvLeaveChars, ui_txvSave;
    EditText ui_edtContent;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_noti);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.group_noti));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_txvSave = (TextView) findViewById(R.id.txv_send);
        ui_txvSave.setOnClickListener(this);

        ui_txvLeaveChars = (TextView) findViewById(R.id.txv_leaveChars);

        ui_edtContent = (EditText) findViewById(R.id.edt_content);
        ui_edtContent.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                ui_txvLeaveChars.setText(String.valueOf(MAX_CHARS - s.length()));
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

    }


    public void onSave() {

        if (ui_edtContent.getText().length() == 0)
            return;

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtContent.getWindowToken(), 0);

        Intent intent = new Intent();
        intent.putExtra(Constants.KEY_GROUPNOTI, ui_edtContent.getText().toString());
        setResult(RESULT_OK, intent);
        finish();
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

            case R.id.txv_send:
                onSave();
                break;



        }

    }


}
