package com.julyseven.wonbridge.register;

import android.Manifest;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.gun0912.tedpermission.PermissionListener;
import com.gun0912.tedpermission.TedPermission;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.tencent.connect.UserInfo;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import org.json.JSONObject;

import java.util.ArrayList;

import de.greenrobot.event.EventBus;

public class SignUpActivity extends CommonActivity implements View.OnClickListener {

    private IWXAPI api;

    public static Tencent mTencent;
    private static boolean isServerSideLogin = false;
    private UserInfo mInfo;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);

        api = WXAPIFactory.createWXAPI(this, Constants.WECHAT_APP_ID, false);

        mTencent = Tencent.createInstance(Constants.QQ_APP_ID, this);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.signup));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvPhone = (TextView) findViewById(R.id.txv_signup_phone);
        txvPhone.setOnClickListener(this);

        TextView txvEmail = (TextView) findViewById(R.id.txv_signup_email);
        txvEmail.setOnClickListener(this);

        ImageView imvWechat = (ImageView) findViewById(R.id.imv_wechat);
        imvWechat.setOnClickListener(this);

        ImageView imvQQ = (ImageView) findViewById(R.id.imv_qq);
        imvQQ.setOnClickListener(this);

        String[] PERMISSIONS = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE};

        if (!Commons.hasPermissions(_context, PERMISSIONS)){
            new TedPermission(_context)
                    .setPermissionListener(new PermissionListener() {
                        @Override
                        public void onPermissionGranted() {

                        }

                        @Override
                        public void onPermissionDenied(ArrayList<String> deniedPermissions) {

                        }
                    })
                    .setDeniedMessage("If you reject permission,you can not use this service\n\nPlease turn on permissions at [Setting] > [Permission]")
                    .setPermissions(PERMISSIONS)
                    .check();
        }
    }

    private void onSignupWithEmail() {

        Intent intent = new Intent(SignUpActivity.this, InputEmailActivity.class);
        startActivity(intent);
    }


    private void onSignupWithPhone() {

        Intent intent = new Intent(SignUpActivity.this, InputPhoneActivity.class);
        startActivity(intent);
    }

    public void onSigupWithWechat() {

        if (api.isWXAppSupportAPI()) {

            String wechatId = Preference.getInstance().getValue(this, PrefConst.PREFKEY_WECHAT_OPENID, null);

            if (wechatId == null) {
                showProgress();
                SendAuth.Req req = new SendAuth.Req();
                req.scope = "snsapi_userinfo";
                req.state = "wechat_sdk_access";
                api.sendReq(req);
            } else {
                gotoProfile(wechatId, true);
            }

        } else {
            showAlertDialog(getString(R.string.install_wechat));
        }
    }

    public void onSignupWithQQ() {

        if (mTencent.isSupportSSOLogin(this)) {

            String qqId = Preference.getInstance().getValue(this, PrefConst.PREFKEY_QQ_OPENID, null);

            if (qqId == null) {
                if (!mTencent.isSessionValid()) {
                    mTencent.login(this, "all", loginListener);
                    isServerSideLogin = false;
                } else {
                    if (isServerSideLogin) { // Server-Side 模式的登陆, 先退出，再进行SSO登陆
                        mTencent.logout(this);
                        mTencent.login(this, "all", loginListener);
                        isServerSideLogin = false;
                        return;
                    }
                    mTencent.logout(this);
                }
            } else {
                gotoProfile(qqId, false);
            }


        } else {
            showAlertDialog(getString(R.string.install_qq));
        }

    }

    public void initOpenidAndToken(JSONObject jsonObject) {
        try {
            String token = jsonObject.getString(com.tencent.connect.common.Constants.PARAM_ACCESS_TOKEN);
            String expires = jsonObject.getString(com.tencent.connect.common.Constants.PARAM_EXPIRES_IN);
            String openId = jsonObject.getString(com.tencent.connect.common.Constants.PARAM_OPEN_ID);
            if (!TextUtils.isEmpty(token) && !TextUtils.isEmpty(expires)
                    && !TextUtils.isEmpty(openId)) {
                mTencent.setAccessToken(token, expires);
                mTencent.setOpenId(openId);
                getQQUserInfo(openId);

            }
        } catch(Exception e) {
        }
    }

    public void getQQUserInfo(final String openId) {

        IUiListener listener = new IUiListener() {

            @Override
            public void onError(UiError e) {
                Preference.getInstance().put(SignUpActivity.this, PrefConst.PREFKEY_QQ_OPENID, openId);
                gotoProfile(openId, false);
            }

            @Override
            public void onComplete(final Object response) {

                Preference.getInstance().put(SignUpActivity.this, PrefConst.PREFKEY_QQ_OPENID, openId);
                gotoProfile(openId, false);

                JSONObject json = (JSONObject)response;
                if (json.has("figureurl")){
                    try {
                        String photoUrl = json.getString("figureurl_qq_2");
                        Preference.getInstance().put(SignUpActivity.this, PrefConst.PREFKEY_QQ_PHOTOURL, photoUrl);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }

                if (json.has("nickname")) {
                    try {
                        String nickname = json.getString("nickname");
                        if (nickname.length() > 15)
                            nickname = nickname.substring(0, 15);
                        Preference.getInstance().put(SignUpActivity.this, PrefConst.PREFKEY_QQ_NICKNAME, nickname);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }

            @Override
            public void onCancel() {
                Preference.getInstance().put(SignUpActivity.this, PrefConst.PREFKEY_QQ_OPENID, openId);
                gotoProfile(openId, false);
            }
        };

        mInfo = new UserInfo(this, mTencent.getQQToken());
        mInfo.getUserInfo(listener);

    }


    IUiListener loginListener = new SignUpActivity.BaseUiListener() {
        @Override
        protected void doComplete(JSONObject values) {
            initOpenidAndToken(values);
        }
    };

    private class BaseUiListener implements IUiListener {

        @Override
        public void onComplete(Object response) {
            if (null == response) {
                showAlertDialog(getString(R.string.failed_qq));
                return;
            }
            JSONObject jsonResponse = (JSONObject) response;
            if (null != jsonResponse && jsonResponse.length() == 0) {
                showAlertDialog(getString(R.string.failed_qq));
                return;
            }
            doComplete((JSONObject)response);
        }

        protected void doComplete(JSONObject values) {

        }

        @Override
        public void onError(UiError e) {
            showAlertDialog(getString(R.string.failed_qq));
            Log.d("TAG", e.errorDetail);

        }

        @Override
        public void onCancel() {
            if (isServerSideLogin) {
                isServerSideLogin = false;
            }
            showAlertDialog(getString(R.string.failed_qq));
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == com.tencent.connect.common.Constants.REQUEST_LOGIN ||
                requestCode == com.tencent.connect.common.Constants.REQUEST_APPBAR) {
            Tencent.onActivityResultData(requestCode,resultCode,data,loginListener);
        }

        super.onActivityResult(requestCode, resultCode, data);
    }


    public void gotoProfile(String social_id, boolean isWechat) {

        Intent intent = new Intent(SignUpActivity.this, InputProfileActivity.class);

        if (isWechat)
            intent.putExtra(Constants.KEY_WECHATID, social_id.toString());
        else
            intent.putExtra(Constants.KEY_QQID, social_id.toString());

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

            case R.id.txv_signup_email:
                onSignupWithEmail();
                break;

            case R.id.txv_signup_phone:
                onSignupWithPhone();
                break;

            case R.id.imv_wechat:
                onSigupWithWechat();
                break;

            case R.id.imv_qq:
                onSignupWithQQ();
                break;


        }

    }

    public void onEventMainThread(WechatLoggedInEvent event) {

        closeProgress();

        if(event.isSuccessful()) {
            gotoProfile(event.get_wechatId(), true);
        } else {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    showAlertDialog(getString(R.string.failed_wechat));
                }
            });

        }
    }


    @Override
    public void onStart() {
        super.onStart();
        EventBus.getDefault().register(this);
    }

    @Override
    public void onStop() {
        EventBus.getDefault().unregister(this);
        super.onStop();
    }


}
