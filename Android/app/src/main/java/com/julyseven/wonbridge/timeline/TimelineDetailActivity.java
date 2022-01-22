package com.julyseven.wonbridge.timeline;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.search.core.SearchResult;
import com.baidu.mapapi.search.geocode.GeoCodeResult;
import com.baidu.mapapi.search.geocode.GeoCoder;
import com.baidu.mapapi.search.geocode.OnGetGeoCoderResultListener;
import com.baidu.mapapi.search.geocode.ReverseGeoCodeOption;
import com.baidu.mapapi.search.geocode.ReverseGeoCodeResult;
import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.TimelineImageAdapter;
import com.julyseven.wonbridge.adapter.TimelineLikeUserAdapter;
import com.julyseven.wonbridge.adapter.TimelineRespondsAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.RespondEntity;
import com.julyseven.wonbridge.model.TimelineEntity;
import com.julyseven.wonbridge.utils.NonScrollListView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


public class TimelineDetailActivity extends CommonActivity implements View.OnClickListener, OnGetGeoCoderResultListener {

    TimelineEntity _timeline;

    TextView ui_txvLikeCount, ui_txvRespondCount, ui_txvLikeMembers, ui_txvLastLogin, ui_txvFriendState, ui_txvRegTime, ui_txvAddress, ui_txvDelete;
    LinearLayout ui_lytLikeUsers;
    ImageView ui_imvLike, ui_imvSend;
    EditText ui_edtMessage;
    ScrollView ui_scrollview;

    RecyclerView ui_recyclerImage, ui_recyclerLikeUser;
    NonScrollListView ui_lstResponds;
    TimelineImageAdapter _imageAdapter;
    TimelineLikeUserAdapter _userAdapter;
    TimelineRespondsAdapter _respondsAdapter;

    ArrayList<String> _imagePaths = new ArrayList<>();
    ArrayList<FriendEntity> _likeUsers = new ArrayList<>();
    ArrayList<RespondEntity> _responds = new ArrayList<>();

    boolean _isHearted = false;

    GeoCoder _geoCoder = null;

    String _address = "";

    boolean _isResponding = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_timeline_detail);

        _isResponding = false;

        if (getIntent().getSerializableExtra(Constants.KEY_TIMELINE) != null) {
            _timeline = (TimelineEntity) getIntent().getSerializableExtra(Constants.KEY_TIMELINE);
        }

        loadLayout();

        if (Commons.g_isChina) {

            _geoCoder = GeoCoder.newInstance();
            _geoCoder.setOnGetGeoCodeResultListener(this);
            _geoCoder.reverseGeoCode(new ReverseGeoCodeOption()
                    .location(new LatLng(_timeline.get_latitude(), _timeline.get_longitude())));

        }

    }

    private void loadLayout() {

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(_timeline.get_userName());

        TextView txvList = (TextView) findViewById(R.id.txv_list);
        txvList.setOnClickListener(this);

        ImageView imvPhoto = (ImageView) findViewById(R.id.imv_photo);
        Glide.with(_context).load(_timeline.get_userProfile()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(imvPhoto);
        imvPhoto.setOnClickListener(this);

        TextView txvContent = (TextView) findViewById(R.id.txv_content);
        txvContent.setText(_timeline.get_content());
        txvContent.setMovementMethod(LinkMovementMethod.getInstance());

        ui_scrollview = (ScrollView) findViewById(R.id.scrollview);

        ui_txvLastLogin = (TextView) findViewById(R.id.txv_lastLogin);
        ui_txvFriendState = (TextView) findViewById(R.id.txv_friendState);

        ui_txvRegTime = (TextView) findViewById(R.id.txv_regtime);
        ui_txvRegTime.setText(Commons.getDisplayLocalTimeString(_timeline.get_writeTime()));

        ui_txvAddress = (TextView) findViewById(R.id.txv_address);

        if (!Commons.g_isChina) {

            _address = "";

            new AsyncTask<Void, Void, Void>() {
                @Override
                protected Void doInBackground(Void... params) {
                    // We send the message here.
                    // You should also check if the username is valid here.
                    try {
                        getAddress();
                    } catch (Exception e) {
                    }
                    return null;
                }

                @Override
                protected void onPostExecute(Void aVoid) {
                    super.onPostExecute(aVoid);
                    ui_txvAddress.setText(_address);
                }
            }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

        }
        ui_txvLikeCount = (TextView) findViewById(R.id.txv_likeCount);
        ui_txvLikeCount.setText(String.valueOf(_timeline.get_likeCount()));

        ui_txvRespondCount = (TextView) findViewById(R.id.txv_msgCount);
        ui_txvRespondCount.setText(String.valueOf(_timeline.get_respondCount()));

        ui_lytLikeUsers = (LinearLayout) findViewById(R.id.lyt_like_users);
        ui_txvLikeMembers = (TextView) findViewById(R.id.txv_like_members);
        ui_txvLikeMembers.setOnClickListener(this);

        ui_imvLike = (ImageView) findViewById(R.id.imv_like);
        ui_imvLike.setSelected(_isHearted);
        ui_imvLike.setOnClickListener(this);

        ui_txvDelete = (TextView) findViewById(R.id.txv_delete);
        ui_txvDelete.setOnClickListener(this);
        if (_timeline.get_userId() == Commons.g_user.get_idx()) {
            ui_txvDelete.setVisibility(View.VISIBLE);
            ui_imvLike.setVisibility(View.GONE);
        } else {
            ui_txvDelete.setVisibility(View.GONE);
            ui_imvLike.setVisibility(View.VISIBLE);
        }

        ui_imvSend = (ImageView) findViewById(R.id.imv_send_text);
        ui_imvSend.setOnClickListener(this);

        ui_edtMessage = (EditText) findViewById(R.id.edt_message);
        ui_edtMessage.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.length() != 0) {
                    ui_imvSend.setSelected(true);
                } else {
                    ui_imvSend.setSelected(false);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        ui_recyclerImage = (RecyclerView) findViewById(R.id.recycler_image);
        LinearLayoutManager layoutManager1 = new LinearLayoutManager(
                this, LinearLayoutManager.HORIZONTAL, false);
        ui_recyclerImage.setLayoutManager(layoutManager1);

        _imageAdapter = new TimelineImageAdapter(this, ui_recyclerImage);
        ui_recyclerImage.setAdapter(_imageAdapter);

        ui_recyclerLikeUser = (RecyclerView) findViewById(R.id.recycler_like_users);
        LinearLayoutManager layoutManager2 = new LinearLayoutManager(
                this, LinearLayoutManager.HORIZONTAL, false);
        ui_recyclerLikeUser.setLayoutManager(layoutManager2);

        _userAdapter = new TimelineLikeUserAdapter(this);
        ui_recyclerLikeUser.setAdapter(_userAdapter);

        ui_lstResponds = (NonScrollListView) findViewById(R.id.lst_responds);
        _respondsAdapter = new TimelineRespondsAdapter(this);
        ui_lstResponds.setAdapter(_respondsAdapter);

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtMessage.getWindowToken(), 0);
                return false;
            }
        });

        setImages();

        getTimelineDetail();

    }



    public void getTimelineDetail() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETTIMELINEDETAIL;

        String params = String.format("/%d/%d", _timeline.get_id(), Commons.g_user.get_idx());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseTimelineInfoResponse(json);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseTimelineInfoResponse(String json) {

        try {

            _likeUsers.clear();
            _responds.clear();

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {

                JSONObject jsonTimeline = response.getJSONObject(ReqConst.RES_TIMELINE);

                _timeline.set_userLastLogin(jsonTimeline.getString(ReqConst.RES_LASTLOGIN));
                _timeline.set_isFriend(jsonTimeline.getInt(ReqConst.RES_ISFRIEND) == 1);

                JSONArray jsonLikeUsers = jsonTimeline.getJSONArray(ReqConst.RES_LIKEUSERLIST);
                for (int i = 0; i < jsonLikeUsers.length(); i++) {

                    JSONObject likeuser = jsonLikeUsers.getJSONObject(i);
                    FriendEntity friend = new FriendEntity();
                    friend.set_idx(likeuser.getInt(ReqConst.RES_ID));
                    friend.set_name(likeuser.getString(ReqConst.RES_NAME));
                    friend.set_photoUrl(likeuser.getString(ReqConst.RES_PHOTO_URL));
                    _likeUsers.add(friend);
                }

                JSONArray jsonResponds = jsonTimeline.getJSONArray(ReqConst.RES_RESPONDUSERLIST);
                for (int i = 0; i < jsonResponds.length(); i++) {

                    JSONObject respond = jsonResponds.getJSONObject(i);
                    RespondEntity entity = new RespondEntity();
                    entity.set_userId(respond.getInt(ReqConst.RES_ID));
                    entity.set_userName(respond.getString(ReqConst.RES_NAME));
                    entity.set_userProfile(respond.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_writeTime(respond.getString(ReqConst.RES_RESPONDTIME));
                    entity.set_content(respond.getString(ReqConst.RES_CONTENT));
                    _responds.add(entity);

                }

                _isHearted = (jsonTimeline.getInt(ReqConst.RES_ISLIKE) == 1);

            } else {
                showToast(getString(R.string.deleted_timeline));
            }

            updateTimelineInfo();

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void updateTimelineInfo() {

        ui_txvLastLogin.setText(Commons.getDisplayLocalTimeString(_timeline.get_userLastLogin()));

        if (_timeline.is_isFriend())
            ui_txvFriendState.setText(getString(R.string.friend_state));
        else
            ui_txvFriendState.setText("");

        ui_imvLike.setSelected(_isHearted);

        setLikeUsers();
        setResponds();
    }

    public void getAddress() {

        _address = Commons.getGeoLocation(TimelineDetailActivity.this, _timeline.get_latitude(), _timeline.get_longitude());
    }

    public void setImages() {

        for (String path : _timeline.get_fileUrls()) {
            if (path.length() > 0)
                _imagePaths.add(path);
        }

        _imageAdapter.setDatas(_imagePaths);

        if (_imagePaths.size() > 0) {
            ui_recyclerImage.setVisibility(View.VISIBLE);
        } else {
            ui_recyclerImage.setVisibility(View.GONE);
        }
    }

    public void setLikeUsers() {

        _userAdapter.setDatas(_likeUsers);

        if (_likeUsers.size() > 0) {
            ui_lytLikeUsers.setVisibility(View.VISIBLE);
            ui_txvLikeMembers.setText("(" + _likeUsers.size() + ") >");
        } else {
            ui_lytLikeUsers.setVisibility(View.GONE);
        }

        ui_txvLikeCount.setText(String.valueOf(_likeUsers.size()));
    }

    public void setResponds() {

        _respondsAdapter.setDatas(_responds);
        ui_txvRespondCount.setText(String.valueOf(_responds.size()));
    }

    public void likeTimeline(boolean yesNo) {

        if (_timeline.get_userId() == Commons.g_user.get_idx()) {
            return;
        }

        String url = ReqConst.SERVER_URL + ReqConst.REQ_LIKETIMELINE;

        if (!yesNo)
            url = ReqConst.SERVER_URL + ReqConst.REQ_UNLIKETIMELINE;

        String params = String.format("/%d/%d", _timeline.get_id(), Commons.g_user.get_idx());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseLikeResponse(json);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }


    public void parseLikeResponse(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {

                _isHearted = !_isHearted;
                ui_imvLike.setSelected(_isHearted);

                FriendEntity me = new FriendEntity();
                me.set_idx(Commons.g_user.get_idx());
                me.set_name(Commons.g_user.get_name());
                me.set_photoUrl(Commons.g_user.get_photoUrl());

                if (_isHearted && !_likeUsers.contains(me)) {
                    _likeUsers.add(me);
                } else if (!_isHearted && _likeUsers.contains(me)) {
                    _likeUsers.remove(me);
                }

                setLikeUsers();
            }


        } catch (Exception ex) {
            ex.printStackTrace();
        }


    }

    private void sendRespond() {

        if (ui_edtMessage.getText().toString().trim().length() == 0)
            return;

        if (_isResponding) {
            showToast(getString(R.string.saving));
            return;
        }

        _isResponding = true;

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtMessage.getWindowToken(), 0);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SAVERESPOND;

        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                parseRespondResponse(response);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                showToast(getString(R.string.fail_upload_timeline));
                closeProgress();
                _isResponding = false;
            }
        }){
            @Override
            protected Map<String,String> getParams(){
                Map<String,String> params = new HashMap<>();
                try {
                    String content = ui_edtMessage.getText().toString().trim().replace(" ", "%20");
                    content = URLEncoder.encode(content, "utf-8");
                    params.put(ReqConst.PARAM_CONTENT, content);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                params.put(ReqConst.PARAM_TIMELINEID, String.valueOf(_timeline.get_id()));
                params.put(ReqConst.PARAM_USERID, String.valueOf(Commons.g_user.get_idx()));

                return params;
            }

            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String,String> params = new HashMap<>();
                params.put("Content-Type","application/x-www-form-urlencoded");
                return params;
            }
        };

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }


    private void parseRespondResponse(String json) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                RespondEntity respondEntity = new RespondEntity();
                respondEntity.set_content(ui_edtMessage.getText().toString());
                ui_edtMessage.setText("");
                respondEntity.set_userId(Commons.g_user.get_idx());
                respondEntity.set_userName(Commons.g_user.get_name());
                respondEntity.set_userProfile(Commons.g_user.get_photoUrl());
                respondEntity.set_writeTime(response.getString(ReqConst.RES_REGTIME));

                _responds.add(respondEntity);

                setResponds();

                ui_scrollview.post(new Runnable() {
                    @Override
                    public void run() {
                        ui_scrollview.fullScroll(View.FOCUS_DOWN);
                    }
                });

            } else {
                showAlertDialog(getString(R.string.error));
            }

        }catch (JSONException e){
            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

        _isResponding = false;
    }


    public void showDeleteConfirm() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag, null);

        final Dialog dialog = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        dialog.setContentView(dialoglayout);

        TextView txvQuestion = (TextView) dialoglayout.findViewById(R.id.txv_question);
        txvQuestion.setText(_context.getString(R.string.confirm_delete_timeline));

        TextView txvCancel = (TextView) dialoglayout.findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                dialog.dismiss();
            }
        });

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                deleteTimeline();
                dialog.dismiss();
            }
        });

        dialog.show();
    }

    public void deleteTimeline() {

        showProgress();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_DELETETIMELINE;

        String params = String.format("/%d", _timeline.get_id());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseDeleteResponse(json);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }


    public void parseDeleteResponse(String json) {

        closeProgress();

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS) {
                finish();
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }


    }

    private void gotoTimelineList() {

        Intent intent = new Intent(TimelineDetailActivity.this, TimelineListActivity.class);
        intent.putExtra(Constants.KEY_USER_ID, _timeline.get_userId());
        intent.putExtra(Constants.KEY_USERNAME, _timeline.get_userName());
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }


    private void gotoProfile() {

        if (_timeline.get_userId() == Commons.g_user.get_idx())
            return;

        Intent intent = new Intent(TimelineDetailActivity.this, UserProfileActivity.class);

        FriendEntity friendEntity = new FriendEntity();
        friendEntity.set_idx(_timeline.get_userId());
        friendEntity.set_name(_timeline.get_userName());
        friendEntity.set_photoUrl(_timeline.get_userProfile());
        intent.putExtra(Constants.KEY_FRIEND, friendEntity);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        startActivity(intent);
        finish();
    }

    private void gotoLikeUsers() {

        Intent intent = new Intent(TimelineDetailActivity.this, LikeUsersActivity.class);
        intent.putExtra(Constants.KEY_USERNAME, _timeline.get_userName());
        intent.putExtra(Constants.KEY_LIKEUSER, _likeUsers);
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

            case R.id.txv_list:
                gotoTimelineList();
                break;

            case R.id.imv_photo:
                gotoProfile();
                break;

            case R.id.imv_like:
                likeTimeline(!_isHearted);
                break;

            case R.id.txv_like_members:
                gotoLikeUsers();
                break;

            case R.id.imv_send_text:
                if (ui_edtMessage.length() > 0 ) {
                    sendRespond();
                }
                break;

            case R.id.txv_delete:
                showDeleteConfirm();
                break;

        }

    }


    @Override
    public void onGetReverseGeoCodeResult(ReverseGeoCodeResult result) {

        if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {

        }
        ui_txvAddress.setText(result.getAddress());

    }


    @Override
    public void onGetGeoCodeResult(GeoCodeResult result) {
        if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {
            return;
        }
    }

}
