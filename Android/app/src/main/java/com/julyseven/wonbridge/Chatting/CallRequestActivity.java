package com.julyseven.wonbridge.Chatting;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Vibrator;
import android.support.v4.app.ActivityCompat;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.logger.Logger;

public class CallRequestActivity extends CommonActivity implements View.OnClickListener {

    String _roomId = "";
    String _callerName = "";
    int _callerId = 0;
    boolean _videoEnabled = true;

    MediaPlayer _player;
    private Vibrator _vibrator;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        Commons.g_callRequestActivity = this;

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

        setContentView(R.layout.activity_call_request);

        _roomId = getIntent().getStringExtra(Constants.VIDEO_ROOM_ID);
        _callerName = getIntent().getStringExtra(Constants.VIDEO_CALLER_NAME);
        _callerId = getIntent().getIntExtra(Constants.VIDEO_CALLER_ID, 0);
        _videoEnabled = getIntent().getBooleanExtra(Constants.VIDEO_ENABLED, true);

        _player = MediaPlayer.create(this, R.raw.ring);
        _player.setLooping(true);
        _player.start();

        _vibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE);
        long[] pattern = {0, 100, 1000};
        _vibrator.vibrate(pattern, 0);

        TelephonyManager telephonyManager = (TelephonyManager) this
                .getSystemService(Context.TELEPHONY_SERVICE);

        PhoneStateListener phoneStateListener = new PhoneStateListener() {
            @Override
            public void onCallStateChanged(int state, String incomingNumber) {

                switch (state) {

                    case TelephonyManager.CALL_STATE_RINGING:
                        Logger.d(getClass().getSimpleName(), "Incoming call: "
                                + incomingNumber);
                        try {
                            if (_player != null)
                                _player.pause();
                        } catch (IllegalStateException e) {

                        }
                        break;

                    case TelephonyManager.CALL_STATE_IDLE:
                        Logger.d(getClass().getSimpleName(), "Call State Idle");
                        try {
                            if (_player != null)
                                _player.start();
                        } catch (IllegalStateException e) {

                        }
                        break;
                }

                super.onCallStateChanged(state, incomingNumber);
            }
        };

        telephonyManager.listen(phoneStateListener,
                PhoneStateListener.LISTEN_CALL_STATE);

        loadLayout();
    }

    private void loadLayout() {

        TextView txvContactName = (TextView) findViewById(R.id.contact_name_call);
        txvContactName.setText(_callerName);

        TextView txvCallerName = (TextView) findViewById(R.id.txv_caller_name);
        txvCallerName.setText(_callerName);

        ImageButton btnAccept = (ImageButton) findViewById(R.id.btn_accept);
        btnAccept.setOnClickListener(this);

        ImageButton btnDecline = (ImageButton) findViewById(R.id.btn_decline);
        btnDecline.setOnClickListener(this);

    }


    public void onAccept() {

        String[] PERMISSIONS = {Manifest.permission.MODIFY_AUDIO_SETTINGS, Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA};

        if (Commons.hasPermissions(Commons.g_commonActivity, PERMISSIONS)){
            Commons.g_xmppService.sendVideoAccept(_callerId);
            Commons.g_xmppService.gotoCallActivity(_roomId, _callerName, _videoEnabled, false, _callerId);
            finish();
        } else {
            ActivityCompat.requestPermissions(Commons.g_commonActivity, PERMISSIONS, Constants.REQUST_PERMISSION);
        }

    }



    public void onDecline() {

        Commons.g_xmppService.sendVideoDecline(_callerId);
        finish();
    }

    private void onBack() {
        finish();
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if(grantResults[0]== PackageManager.PERMISSION_GRANTED){
            Commons.g_xmppService.gotoCallActivity(_roomId, _callerName, _videoEnabled, false, _callerId);
        }
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;

            case R.id.btn_accept:
                onAccept();
                break;

            case R.id.btn_decline:
                onDecline();
                break;

        }

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

    public void onCancel() {

        Toast.makeText(this, Constants.VIDEO_CHATTING_CANCEL, Toast.LENGTH_SHORT).show();
        finish();

    }


    @Override
    protected void onDestroy() {

        super.onDestroy();

        if (_player != null) {
            _player.stop();
            _player = null;
        }

        if (_vibrator != null) {
            _vibrator.cancel();
            _vibrator = null;
        }

        Commons.g_callRequestActivity = null;

    }
}
