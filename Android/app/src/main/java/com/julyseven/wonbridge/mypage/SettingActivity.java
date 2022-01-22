package com.julyseven.wonbridge.mypage;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;

public class SettingActivity extends CommonActivity implements View.OnClickListener {


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setting);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.mypage_setting));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        LinearLayout lytChangePwd = (LinearLayout) findViewById(R.id.lyt_change_pwd);
        lytChangePwd.setOnClickListener(this);

        if (Commons.g_isSocialLogin)
            lytChangePwd.setVisibility(View.GONE);

        LinearLayout lytManageFriend = (LinearLayout) findViewById(R.id.lyt_manage_friend);
        lytManageFriend.setOnClickListener(this);

        LinearLayout lytManagePoint = (LinearLayout) findViewById(R.id.lyt_manage_point);
        lytManagePoint.setOnClickListener(this);

        TextView txvLogout = (TextView) findViewById(R.id.txv_logout);
        txvLogout.setOnClickListener(this);

    }

    public void onLogout() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag, null);

        final Dialog confirmDlg = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        confirmDlg.setContentView(dialoglayout);

        TextView txvQuestion = (TextView) dialoglayout.findViewById(R.id.txv_question);
        txvQuestion.setText(_context.getString(R.string.logout_note));

        TextView txvCancel = (TextView) dialoglayout.findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                confirmDlg.dismiss();
            }
        });

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                processLogout();
                confirmDlg.dismiss();
            }
        });

        confirmDlg.show();

    }

    public void processLogout() {

        Commons.g_isAppRunning = false;

        showProgress();

        Preference.getInstance().put(this, PrefConst.PREFKEY_USEREMAIL, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_USERPWD, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_XMPPID, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_WECHATID, "");
        Preference.getInstance().put(this, PrefConst.PREFKEY_QQID, "");
        Commons.g_xmppService.disconnect();

        logout();
    }

    public void logout() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_LOGOUT;
        String params = String.format("/%d", Commons.g_user.get_idx());

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseLogoutResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                setResult(RESULT_OK);
                finish();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseLogoutResponse(String json){

        closeProgress();
        setResult(RESULT_OK);
        finish();
    }

    public void onChangePwd() {

        Intent intent = new Intent(SettingActivity.this, ChangePwdActivity.class);
        startActivity(intent);
    }

    public void gotoManagePoint() {

        Intent intent = new Intent(SettingActivity.this, ManagePointActivity.class);
        startActivity(intent);

    }


    public void gotoManageFriend() {

        Intent intent = new Intent(SettingActivity.this, ManageFriendActivity.class);
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


            case R.id.txv_logout:
                onLogout();
                break;

            case R.id.lyt_manage_point:
                gotoManagePoint();
                break;

            case R.id.lyt_manage_friend:
                gotoManageFriend();
                break;

            case R.id.lyt_change_pwd:
                onChangePwd();
                break;

        }

    }


}
