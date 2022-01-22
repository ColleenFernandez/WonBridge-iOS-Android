package com.julyseven.wonbridge.register;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.baidu.android.pushservice.PushConstants;
import com.baidu.android.pushservice.PushManager;
import com.julyseven.wonbridge.Chatting.ConnectionMgrService;
import com.julyseven.wonbridge.Chatting.LoggedInEvent;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.message.MsgActivity;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.model.TimelineEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.timeline.TimelineActivity;
import com.julyseven.wonbridge.utils.Database;
import com.tencent.connect.UserInfo;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import org.jivesoftware.smack.SmackConfiguration;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

import de.greenrobot.event.EventBus;

public class LoginActivity extends CommonActivity implements View.OnClickListener {

    EditText ui_edtID, ui_edtPwd;
    TextView ui_txvLogin, ui_txvForget, ui_txvSingUp;
    private UserEntity _user;

    ImageView ui_imvSplash;

    private int _reqCounter = 0;

    private LinearLayout ui_rootView;

    private String _room = null;

    boolean _autoLogin = false;

    private IWXAPI api;
    String _wechatId = "";
    String _qqId = "";

    public static Tencent mTencent;
    private static boolean isServerSideLogin = false;
    private UserInfo mInfo;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        api = WXAPIFactory.createWXAPI(this, Constants.WECHAT_APP_ID, false);

        mTencent = Tencent.createInstance(Constants.QQ_APP_ID, this);

        PushManager.startWork(getApplicationContext(), PushConstants.LOGIN_TYPE_API_KEY, Constants.BAIDU_PUSH_APIKEY);

        _room = getIntent().getStringExtra(Constants.KEY_ROOM);

        Database.init(getApplicationContext());
        SmackConfiguration.DEBUG = true;

        Commons.g_isFirstLocCaptured = false;
        Commons.g_user = null;

        String countryCode = Commons.getCountryCode(this);

        if (countryCode.equalsIgnoreCase("CN")) {
            Commons.g_isChina = true;
        } else {
            Commons.g_isChina = false;
        }

        Commons.g_isSocialLogin = false;

        loadLayout();

        checkKeyboardHeight();
    }

    private void loadLayout() {

        ui_imvSplash = (ImageView) findViewById(R.id.imv_splash);
        ui_imvSplash.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return true;
            }
        });

        ui_edtID = (EditText) findViewById(R.id.edt_id);
        ui_edtPwd = (EditText) findViewById(R.id.edt_pwd);

        ui_txvLogin = (TextView) findViewById(R.id.txv_login);
        ui_txvLogin.setOnClickListener(this);

        ui_txvForget = (TextView)findViewById(R.id.txv_forget);
        ui_txvForget.setOnClickListener(this);

        ui_txvSingUp = (TextView) findViewById(R.id.txv_signup);
        ui_txvSingUp.setOnClickListener(this);

        ImageView imvWechat = (ImageView) findViewById(R.id.imv_wechat);
        imvWechat.setOnClickListener(this);

        ImageView imvQq = (ImageView) findViewById(R.id.imv_qq);
        imvQq.setOnClickListener(this);

        // container
        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtID.getWindowToken(), 0);
                return false;
            }
        });

        // load saved user
        String email = Preference.getInstance().getValue(this,
                PrefConst.PREFKEY_USEREMAIL, "");
        String userpwd = Preference.getInstance().getValue(this,
                PrefConst.PREFKEY_USERPWD, "");
        String wechatId = Preference.getInstance().getValue(this, PrefConst.PREFKEY_WECHATID, "");
        String qqId = Preference.getInstance().getValue(this, PrefConst.PREFKEY_QQID, "");

        ui_edtID.setText(email);
        ui_edtPwd.setText(userpwd);

        if(email.length() > 0 && userpwd.length() > 0){
            checkDeviceId(true);
        } else if (wechatId.length() > 0){
            processWechatLogin(wechatId, true);
        } else if (qqId.length() > 0){
            processQQLogin(qqId, true);
        } else {

            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    ui_imvSplash.setVisibility(View.GONE);
                }
            }, 1000);
        }


    }

    private void checkKeyboardHeight() {

        ui_rootView = (LinearLayout) findViewById(R.id.lyt_container);

        ui_rootView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                Rect r = new Rect();

                ui_rootView.getWindowVisibleDisplayFrame(r);

                int screenHeight = ui_rootView.getRootView().getHeight();
                int keyboardHeight = screenHeight - (r.bottom);

                if (keyboardHeight > 150) {

                    if (keyboardHeight != Preference.getInstance().getValue(LoginActivity.this, PrefConst.KEYBOARD_HEIGHT, 0))
                        Preference.getInstance().put(LoginActivity.this, PrefConst.KEYBOARD_HEIGHT, keyboardHeight);
                }
            }
        });
    }

    public boolean checkValid() {

        if (ui_edtID.getText().length() == 0) {

            showAlertDialog(getString(R.string.input_id));
            return false;

        } else if (ui_edtPwd.getText().length() == 0) {

            showAlertDialog(getString(R.string.input_pwd));
            return false;

        }
        return true;

    }


    public void checkDeviceId(boolean auto) {

        _autoLogin = auto;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_CHECKDEVICEID;

        String params = String.format("/%s/%s", ui_edtID.getText().toString(), Commons.getDeviceId(this));

        url += params;

        if (!_autoLogin)
            showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseCheckResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                onConnectError();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseCheckResponse(String json){

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                processLogin(true);

            } else if(result_code == ReqConst.CODE_UNREGUSER){

                closeProgress();
                ui_imvSplash.setVisibility(View.GONE);
                showAlertDialog(getString(R.string.unregistered_user));

            } else {
                closeProgress();
                ui_imvSplash.setVisibility(View.GONE);
                showLogoutDiag();
            }

        }catch (JSONException e){

            closeProgress();
            e.printStackTrace();

            onConnectError();
        }

    }

    public void showLogoutDiag() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag, null);

        final Dialog dialog = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        dialog.setContentView(dialoglayout);

        TextView txvQuestion = (TextView) dialoglayout.findViewById(R.id.txv_question);
        txvQuestion.setText(_context.getString(R.string.wrong_device));

        TextView txvCancel = (TextView) dialoglayout.findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                dialog.dismiss();
                finish();
            }
        });

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                dialog.dismiss();
                processLogin(false);
            }
        });

        dialog.show();
    }


    public void processLogin(boolean auto){

        String url = ReqConst.SERVER_URL + ReqConst.REQ_LOGIN;

        String params = String.format("/%s/%s/%s/%d", ui_edtID.getText().toString(), ui_edtPwd.getText().toString(), Commons.getDeviceId(this), Constants.ANDROID);

        url += params;

        _autoLogin = auto;

        if (!_autoLogin)
            showProgress();

        Log.d("login Url ==>", url);

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseLoginResponse(json, 0);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                onConnectError();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    // 0:  email or phone, 1:wechat, 2:qq
    public void parseLoginResponse(String json, int type){

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){

                JSONObject response = object.getJSONObject(ReqConst.RES_USERINFO);

                _user = new UserEntity();

                _user.set_idx(response.getInt(ReqConst.RES_IDX));
                _user.set_name(response.getString(ReqConst.RES_NAME));
                _user.set_email(response.getString(ReqConst.RES_EMAIL));
                _user.set_phoneNumber(response.getString(ReqConst.RES_PHONE_NUMBER));
                _user.set_label(response.getString(ReqConst.RES_LABEL));
                _user.set_sex(response.getInt(ReqConst.RES_SEX));
                _user.set_bgUrl(response.getString(ReqConst.RES_BG_URL));
                _user.set_photoUrl(response.getString(ReqConst.RES_PHOTO_URL));
                _user.set_isPublicLocation(response.getInt(ReqConst.RES_ISPUBLICLOCATION) == 1);
                _user.set_isPublicTimeline(response.getInt(ReqConst.RES_ISPUBLICTIMELINE) == 1);
                _user.set_country(response.getString(ReqConst.RES_COUNTRY));
                _user.set_wechatId(response.getString(ReqConst.RES_WECHATID));
                _user.set_qqId(response.getString(ReqConst.RES_QQID));
                _user.set_school(response.getString(ReqConst.RES_SCHOOL));
                _user.set_village(response.getString(ReqConst.RES_VILLAGE));
                _user.set_country2(response.getString(ReqConst.RES_COUNTRY2));
                _user.set_working(response.getString(ReqConst.RES_WORKING));
                _user.set_interest(response.getString(ReqConst.RES_INTEREST));

                if (type == 0) {
                    Preference.getInstance().put(this, PrefConst.PREFKEY_USEREMAIL, ui_edtID.getText().toString().trim());
                    Preference.getInstance().put(this, PrefConst.PREFKEY_USERPWD, ui_edtPwd.getText().toString().trim());
                    Commons.g_isSocialLogin = false;
                } else if (type == 1) {
                    Preference.getInstance().put(this, PrefConst.PREFKEY_WECHATID, _wechatId);
                    Preference.getInstance().put(this, PrefConst.PREFKEY_USERPWD, Constants.DEFAULT_WECHAT_PWD);
                    Commons.g_isSocialLogin = true;
                } else if (type == 2) {
                    Preference.getInstance().put(this, PrefConst.PREFKEY_QQID, _qqId);
                    Preference.getInstance().put(this, PrefConst.PREFKEY_USERPWD, Constants.DEFAULT_QQ_PWD);
                    Commons.g_isSocialLogin = true;
                }

                Preference.getInstance().put(this,
                        PrefConst.PREFKEY_XMPPID, String.valueOf(_user.get_idx()));

                String lastLoginEmail = Preference.getInstance().getValue(getApplicationContext(), PrefConst.PREFKEY_LASTLOGINID, "");

                // init database if new user login
                if (!lastLoginEmail.equals(_user.get_email())) {

                    Preference.getInstance().put(getApplicationContext(), PrefConst.PREFKEY_LASTLOGINID, _user.get_email());
                    Database.initDatabase();
                }

                Commons.g_user = _user;

                getFriendList();

            }else if(result_code == ReqConst.CODE_UNREGUSER){

                closeProgress();
                ui_imvSplash.setVisibility(View.GONE);

                if (type == 0)
                    showAlertDialog(getString(R.string.unregistered_user));
                else
                    showGotoSignupDiag();

            }else if(result_code == ReqConst.CODE_INVALIDPWD){

                closeProgress();
                ui_imvSplash.setVisibility(View.GONE);
                showAlertDialog(getString(R.string.checkPwd));
            } else {
                closeProgress();
                ui_imvSplash.setVisibility(View.GONE);
            }

        }catch (JSONException e){

            closeProgress();
            e.printStackTrace();

            onConnectError();
        }

    }

    public void processWechatLogin(String wechatId, boolean auto){

        _wechatId = wechatId;

        _autoLogin = auto;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_LOGINWECHAT;

        String params = String.format("/%s/%s/0", wechatId, Commons.getDeviceId(this));

        url += params;

        Log.d("login Url ==>", url);

        if (!_autoLogin)
            showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseLoginResponse(json, 1);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                onConnectError();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }


    public void processQQLogin(String qqId, boolean auto){

        _qqId = qqId;

        _autoLogin = auto;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_LOGINQQ;

        String params = String.format("/%s/%s/0", qqId, Commons.getDeviceId(this));

        url += params;

        Log.d("login Url ==>", url);

        if (!_autoLogin)
            showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseLoginResponse(json, 2);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                onConnectError();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void getFriendList() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETFRIENDLIST;

        String params = String.format("/%d/%d", _user.get_idx(), 1);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseFriendResponse(json);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                getBlockUsers();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseFriendResponse(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {

                JSONArray friends = response.getJSONArray(ReqConst.RES_FRIENDINFOS);

                Database.deleteAllFriends();

                for (int i = 0; i < friends.length(); i++) {

                    JSONObject friend = (JSONObject) friends.get(i);
                    FriendEntity entity = new FriendEntity();

                    entity.set_idx(friend.getInt(ReqConst.RES_ID));
                    entity.set_name(friend.getString(ReqConst.RES_NAME));
                    entity.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_lastLogin(friend.getString(ReqConst.RES_LASTLOGIN));
                    entity.set_latitude((float) friend.getDouble(ReqConst.RES_LATITUDE));
                    entity.set_longitude((float) friend.getDouble(ReqConst.RES_LONGITUDE));
                    entity.set_sex(friend.getInt(ReqConst.RES_SEX));
                    entity.set_country(friend.getString(ReqConst.RES_COUNTRY));
                    entity.set_country2(friend.getString(ReqConst.RES_COUNTRY2));
                    entity.set_isFriend(true);

                    Commons.g_user.get_friendList().add(entity);
                    Database.createFriend(entity.get_idx());

                }
            }


        } catch (JSONException e) {
            e.printStackTrace();
        }

        getBlockUsers();
    }

    public void getBlockUsers() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETBLOCKUSERS;

        String params = String.format("/%d", _user.get_idx());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseBlockResponse(json);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                getNotiData();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                                                            0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseBlockResponse(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {

                JSONArray friends = response.getJSONArray(ReqConst.RES_USERINFOS);

                Database.deleteAllBlocks();

                for (int i = 0; i < friends.length(); i++) {

                    JSONObject friend = (JSONObject) friends.get(i);
                    FriendEntity entity = new FriendEntity();

                    entity.set_idx(friend.getInt(ReqConst.RES_ID));
                    entity.set_name(friend.getString(ReqConst.RES_NAME));
                    entity.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_lastLogin(friend.getString(ReqConst.RES_LASTLOGIN));
                    entity.set_latitude((float) friend.getDouble(ReqConst.RES_LATITUDE));
                    entity.set_longitude((float) friend.getDouble(ReqConst.RES_LONGITUDE));
                    entity.set_country(friend.getString(ReqConst.RES_COUNTRY));

                    Commons.g_user.get_blockList().add(entity);
                    Database.createBlock(entity.get_idx());
                }
            }


        } catch (JSONException e) {
            e.printStackTrace();
        }

        getNotiData();
    }

    public void getNotiData() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETNOTE;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseNotiResponse(json);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                registerToken();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseNotiResponse(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {

                JSONObject note = response.getJSONObject(ReqConst.RES_NOTEINFO);

                TimelineEntity entity = new TimelineEntity();
                entity.set_content(note.getString(ReqConst.RES_CONTENT));
                entity.set_writeTime(note.getString(ReqConst.RES_REGDATE));
                entity.set_userName(Constants.WONBRIDGE);
                entity.set_link(note.getString(ReqConst.RES_LINK));

                JSONArray fileurls = note.getJSONArray(ReqConst.RES_FILE_URL);
                for (int j = 0; j < fileurls.length(); j++) {
                    entity.get_fileUrls().add(fileurls.getString(j));
                }

                Commons.g_notiData = entity;
            }


        } catch (JSONException e) {
            e.printStackTrace();
        }

        registerToken();
    }

    public void registerToken() {

        String token = Preference.getInstance().getValue(this, PrefConst.PREFKEY_BAIDU_TOKEN, null);

        if (token == null) {
            loadGroupFromServer();
            return;
        }

        String url = ReqConst.SERVER_URL + ReqConst.REQ_REGISTERTOKEN;

        String params = String.format("/%d/%s", _user.get_idx(), token);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseTokenResponse(json);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                loadGroupFromServer();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseTokenResponse(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }

        loadGroupFromServer();
    }

    public void loadGroupFromServer() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETALLGROUP;
        String params = String.format("/%d", Commons.g_user.get_idx());

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseGroupListResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                loadRoomUserInfo();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }


    public void parseGroupListResponse(String json) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray groups = response.getJSONArray(ReqConst.RES_GROUPINFOS);

                for (int i = 0; i < groups.length(); i++) {

                    JSONObject group = (JSONObject) groups.get(i);
                    GroupEntity entity = new GroupEntity();
                    entity.set_groupName(group.getString(ReqConst.RES_NAME));
                    entity.set_groupNickname(group.getString(ReqConst.RES_NICKNAME));
                    entity.set_participants(group.getString(ReqConst.RES_PARTICIPANT));
                    entity.set_groupProfileUrl(group.getString(ReqConst.RES_PROFILE));
                    entity.set_ownerIdx(group.getInt(ReqConst.RES_USERID));
                    entity.set_regDate(Commons.getDisplayRegTimeString(group.getString(ReqConst.RES_REGDATE)));
                    entity.set_country(group.getString(ReqConst.RES_COUNTRY));

                    JSONArray jsonUrls = group.getJSONArray(ReqConst.RES_GROUPURLS);
                    for (int j = 0 ; j < jsonUrls.length(); j++) {
                        entity.get_profileUrls().add((jsonUrls.getString(j)));
                    }

                    Commons.g_user.get_groupList().add(entity);
                }
            }

        }catch (JSONException e){
            e.printStackTrace();
        }

        loadRoomUserInfo();
    }

    public void loadRoomUserInfo() {

        ArrayList<RoomEntity> roomEntities =  Database.getAllRoom();

        // if database has not group from server, add it.
        for (GroupEntity group : Commons.g_user.get_groupList()) {

            RoomEntity roomFromGroup = new RoomEntity(group.get_groupName(), group.get_participants(), "", "", 0, "");

            if (!roomEntities.contains(roomFromGroup)) {
                Database.createRoom(roomFromGroup);
                roomEntities.add(roomFromGroup);
            }
        }

        _reqCounter = roomEntities.size();

        if (_reqCounter > 0) {

            for (RoomEntity room : roomEntities) {
                getRoomUserInfo(room);
            }
        } else {
            loginToChattingServer();
        }
    }

    public void getRoomUserInfo(final RoomEntity room){

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETROOMINFO;

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), room.makeParticipantsWithLeaveMemeber());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseRoomInfoResponse(json, room);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                _reqCounter--;

                if (_reqCounter <= 0)
                    loginToChattingServer();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseRoomInfoResponse(String json, RoomEntity room){

        _reqCounter--;

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray friends = response.getJSONArray(ReqConst.RES_USERINFOS);

                ArrayList<FriendEntity> participants = new ArrayList<FriendEntity>();

                // get participants data
                for (int i = 0; i < friends.length(); i++) {

                    JSONObject friend = (JSONObject) friends.get(i);

                    int idx = friend.getInt(ReqConst.RES_ID);

                    if (idx == Commons.g_user.get_idx())
                        continue;

                    if (Commons.g_user.isFriend(idx)) {
                        participants.add(Commons.g_user.getFriend(idx));

                    } else {

                        FriendEntity entity = new FriendEntity();
                        entity.set_idx(friend.getInt(ReqConst.RES_ID));
                        entity.set_name(friend.getString(ReqConst.RES_NAME));
                        entity.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                        entity.set_isFriend(friend.getInt(ReqConst.RES_ISFRIEND) ==  1);
                        entity.set_latitude((float) friend.getDouble(ReqConst.RES_LATITUDE));
                        entity.set_longitude((float) friend.getDouble(ReqConst.RES_LONGITUDE));
                        entity.set_lastLogin(friend.getString(ReqConst.RES_LASTLOGIN));
                        entity.set_country(friend.getString(ReqConst.RES_COUNTRY));
                        entity.set_country2(friend.getString(ReqConst.RES_COUNTRY2));
                        participants.add(entity);
                    }
                }

                // make room
                room.set_participantList(participants);

                if (!Commons.g_user.get_roomList().contains(room))
                    Commons.g_user.get_roomList().add(room);
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

        if (_reqCounter <= 0) {
            loginToChattingServer();
        }

    }


    public void loginToChattingServer() {

        if (ConnectionMgrService.mConnection == null || !ConnectionMgrService.mConnection.isConnected()) {

            Intent mServiceIntent = new Intent(LoginActivity.this, ConnectionMgrService.class);
            mServiceIntent.putExtra(Constants.XMPP_START, Constants.XMPP_FROMLOGIN);
            startService(mServiceIntent);

            Log.d("XMPP", "not connected go to login from login activity");

        } else {

            closeProgress();
            gotoTimeLine();

            Log.d("XMPP", "already connected from broadcast");
        }
    }

    public void showGotoSignupDiag() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag, null);

        final Dialog dialog = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        dialog.setContentView(dialoglayout);

        TextView txvQuestion = (TextView) dialoglayout.findViewById(R.id.txv_question);
        txvQuestion.setText(_context.getString(R.string.not_registered_social));

        TextView txvCancel = (TextView) dialoglayout.findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                dialog.dismiss();
            }
        });

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                dialog.dismiss();
                gotoSignup();
            }
        });

        dialog.show();
    }

    private void gotoTimeLine() {

        Commons.g_isAppRunning = true;

        Intent intent;

        if (_room != null){

            intent = new Intent(this, MsgActivity.class);
            intent.putExtra(Constants.KEY_ROOM, _room);
        } else {
            intent = new Intent(this, TimelineActivity.class);
        }

        intent.putExtra(Constants.KEY_FROMLOGIN, true);

        startActivity(intent);
        finish();
    }

    public void gotoSignup() {

        Intent intent = new Intent(this, SignUpActivity.class);
        startActivity(intent);

    }

    public void gotoRecoverPwd() {

        Intent intent = new Intent(this, RecoverPwdActivity.class);
        startActivity(intent);

    }

    public void onConnectError() {

        AlertDialog alertDialog = new AlertDialog.Builder(this).create();

        alertDialog.setTitle(getString(R.string.app_name));
        alertDialog.setMessage(getString(R.string.error));

        alertDialog.setButton(AlertDialog.BUTTON_POSITIVE, getString(R.string.ok),

                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {

                        if (_autoLogin)
                            finish();
                    }
                });
        alertDialog.show();
    }

    public void onLoginWithWechat() {

        if (api.isWXAppSupportAPI()) {

            String wechatId = Preference.getInstance().getValue(this, PrefConst.PREFKEY_WECHAT_OPENID, null);

            if (wechatId == null) {

                showProgress();
                SendAuth.Req req = new SendAuth.Req();
                req.scope = "snsapi_userinfo";
                req.state = "wechat_sdk_access";
                api.sendReq(req);
            } else {
                processWechatLogin(wechatId, false);
            }

        } else {
            showAlertDialog(getString(R.string.install_wechat));
        }
    }


    public void onLoginWithQQ() {

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
                processQQLogin(qqId, false);
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
                Preference.getInstance().put(LoginActivity.this, PrefConst.PREFKEY_QQ_OPENID, openId);
                processQQLogin(openId, false);
            }

            @Override
            public void onComplete(final Object response) {

                Preference.getInstance().put(LoginActivity.this, PrefConst.PREFKEY_QQ_OPENID, openId);
                processQQLogin(openId, false);

                JSONObject json = (JSONObject)response;
                if (json.has("figureurl")){
                    try {
                        String photoUrl = json.getString("figureurl_qq_2");
                        Preference.getInstance().put(LoginActivity.this, PrefConst.PREFKEY_QQ_PHOTOURL, photoUrl);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }

                if (json.has("nickname")) {
                    try {
                        String nickname = json.getString("nickname");
                        if (nickname.length() > 15)
                            nickname = nickname.substring(0, 15);
                        Preference.getInstance().put(LoginActivity.this, PrefConst.PREFKEY_QQ_NICKNAME, nickname);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }

            @Override
            public void onCancel() {
                Preference.getInstance().put(LoginActivity.this, PrefConst.PREFKEY_QQ_OPENID, openId);
                processQQLogin(openId, false);
            }
        };

        mInfo = new UserInfo(this, mTencent.getQQToken());
        mInfo.getUserInfo(listener);

    }


    IUiListener loginListener = new BaseUiListener() {
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


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.txv_login:

                if (checkValid()) {
                    checkDeviceId(false);
                }

                break;

            case R.id.txv_forget:
                gotoRecoverPwd();
                break;

            case R.id.txv_signup:
                gotoSignup();
                break;

            case R.id.imv_wechat:
                onLoginWithWechat();
                break;


            case R.id.imv_qq:
                onLoginWithQQ();
                break;

        }
    }


    public void onEventMainThread(LoggedInEvent event) {

        closeProgress();

        if(event.isSuccessful()) {
            gotoTimeLine();
        } else {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    onConnectError();
                }
            });

        }
    }

    public void onEventMainThread(final WechatLoggedInEvent event) {

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                closeProgress();

                if(event.isSuccessful()) {
                    processWechatLogin(event.get_wechatId(), false);
                } else {
                    showAlertDialog(getString(R.string.failed_wechat));
                }
            }
        });


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
