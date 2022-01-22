package com.julyseven.wonbridge.register;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;

public class SplashActivity extends CommonActivity {


    private String _room = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        _room = getIntent().getStringExtra(Constants.KEY_ROOM);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {

                gotoLogin();
            }
        }, 2000);

    }

    public void gotoLogin() {

        Intent intent = new Intent(SplashActivity.this, LoginActivity.class);

        if (_room != null)
            intent.putExtra(Constants.KEY_ROOM, _room);

        startActivity(intent);
        finish();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }


}
