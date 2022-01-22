package com.julyseven.wonbridge.base;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Vibrator;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Commons;

/**
 * Created by sss on 8/21/2016.
 */
public abstract class BaseActivity extends AppCompatActivity implements Handler.Callback {

    public Context _context = null;

    public Handler _handler = null;

    private ProgressDialog _progressDlg;

    private Vibrator _vibrator;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        _context = this;

        _vibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE);
        _handler = new Handler(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {

        closeProgress();

        try {
            if (_vibrator != null)
                _vibrator.cancel();
        } catch (Exception e) {
        }
        _vibrator = null;

        super.onDestroy();
    }

    /** 뒤로가기 두번눌렀을때 앱 꺼지게 하기 위한 기발 */
    public boolean _isEndFlag = true;

    /** 뒤로가기 2번누르는 시간 */
    public static final int BACK_TWO_CLICK_DELAY_TIME = 3000; // ms

    public Runnable _exitRunner = new Runnable() {

        @Override
        public void run() {

            _isEndFlag = false;
        }
    };

    public void onExit() {

        if (_isEndFlag == false) {

            Toast.makeText(this, getString(R.string.str_back_one_more_end),
                    Toast.LENGTH_SHORT).show();
            _isEndFlag = true;

            _handler.postDelayed(_exitRunner, BACK_TWO_CLICK_DELAY_TIME);

        } else if (_isEndFlag == true) {

            Commons.g_isAppRunning = false;
            finish();
        }
    }

    public void showProgress(String strMsg,  boolean cancelable) {

        if (_progressDlg != null)
            return;

        try {
            _progressDlg = new ProgressDialog(_context, R.style.MyDialogTheme);
            _progressDlg.setCancelable(cancelable);
            _progressDlg
                    .setProgressStyle(android.R.style.Widget_ProgressBar_Large);
            _progressDlg.show();

        } catch (Exception e) {
        }
    }

    public void showProgress() {
        showProgress("", false);
    }

    public void closeProgress() {

        if(_progressDlg == null) {
            return;
        }

        _progressDlg.dismiss();
        _progressDlg = null;
    }

    public void showAlertDialog(String msg) {

        AlertDialog alertDialog = new AlertDialog.Builder(_context).create();

        alertDialog.setTitle(getString(R.string.app_name));
        alertDialog.setMessage(msg);

        alertDialog.setButton(AlertDialog.BUTTON_POSITIVE, _context.getString(R.string.ok),

                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {

                    }
                });
        //alertDialog.setIcon(R.drawable.banner);
        alertDialog.show();

    }

    /**
     *  show toast
     * @param toast_string
     */
    public void showToast(String toast_string) {

        Toast.makeText(_context, toast_string, Toast.LENGTH_SHORT).show();
    }

    public void vibrate() {

        if (_vibrator != null)
            _vibrator.vibrate(500);
    }

    @Override
    public boolean handleMessage(Message msg) {

        switch (msg.what) {

            default:
                break;
        }

        return false;
    }

}
