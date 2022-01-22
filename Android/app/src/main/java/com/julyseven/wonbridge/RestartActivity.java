package com.julyseven.wonbridge;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;

import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.register.LoginActivity;
import com.julyseven.wonbridge.register.SplashActivity;

/**
 * Created by HGS on 12/11/2015.
 */
public class RestartActivity extends CommonActivity implements View.OnClickListener {

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);

        if(!Commons.g_isAppRunning){

            String room = getIntent().getStringExtra(Constants.KEY_ROOM);

            Intent goIntro = new Intent(this, LoginActivity.class);

            if (room != null)
                goIntro.putExtra(Constants.KEY_ROOM, room);

            startActivity(goIntro);
        }

        finish();
    }

    @Override
    protected void onDestroy(){

        super.onDestroy();
    }

    @Override
    public void onClick(View view){

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event){

        return true;
    }
}
