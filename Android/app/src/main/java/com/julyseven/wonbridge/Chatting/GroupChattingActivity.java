package com.julyseven.wonbridge.Chatting;

import android.Manifest;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.media.MediaPlayer;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AlertDialog;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.webkit.MimeTypeMap;
import android.widget.AbsListView;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.ImageGalleryAdapter;
import com.julyseven.wonbridge.adapter.VideoGalleryAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.message.SelectFriendActivity;
import com.julyseven.wonbridge.model.EmojiEntity;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.GroupRequestEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.model.VideoEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.register.LoginActivity;
import com.julyseven.wonbridge.utils.BackKeyEditText;
import com.julyseven.wonbridge.utils.BitmapUtils;
import com.julyseven.wonbridge.utils.CustomMultiPartEntity;
import com.julyseven.wonbridge.utils.Database;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smack.chat.Chat;
import org.jivesoftware.smack.chat.ChatManager;
import org.jivesoftware.smack.packet.Message;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import me.relex.circleindicator.CircleIndicator;


public class GroupChattingActivity extends CommonActivity implements View.OnClickListener {

    private FrameLayout ui_fytMoreBar;
    private LinearLayout ui_lytMoreBar, ui_lytMessage;
    private ImageView ui_imvBack, ui_imvGallery, ui_imvVideo, ui_imvCamera, ui_imvCall, ui_imvVideoCall, ui_imvGift,
                    ui_imvMore, ui_imvEmoji, ui_imvSendText, ui_imvMenu, ui_imvSound;
    private TextView ui_txvTitle, ui_txvBlock, ui_txvAccept, ui_txvSend;
    private RelativeLayout ui_rltEmoji;

    private GridView ui_gridView;

    private ViewPager ui_emojiViewpager;

    private BackKeyEditText ui_edtMessage;

    private ListView ui_lstChatting;
    public GroupChattingAdapter _chattingAdapter;

    private SwipyRefreshLayout ui_refreshLayout;

    GroupChatManager _groupChat = null;

    private Uri _imageCaptureUri;
    private String _capturePath = "";


    RoomEntity _roomEntity = null;
    String _roomName = "";

    int _recentLoadCounter = 1;

    private UserEntity _user;

    final String orderBy = MediaStore.Images.Media.DATE_TAKEN;
    private ArrayList<String> _imageUrls = new ArrayList<>();
    private ArrayList<VideoEntity> _videoUrls = new ArrayList<>();
    private ImageGalleryAdapter _imageAdapter;

    private PopupWindow ui_popupSetting;
    private boolean _isSettingShown = false;

    private boolean _isFriendRequest = false;

    private int _morebarState = 0; // 0: hidden, 1: keyboard, 2: morebar

    private MediaPlayer _player;

    private boolean _isOnlineService = false;

    int _pageIndex = 0;

    private ArrayList<GroupRequestEntity> _groupRequests = new ArrayList<>();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_chatting);

        checkKeyboardHeight();

        _user = Commons.g_user;

        String roomName = getIntent().getStringExtra(Constants.KEY_ROOM);
        _isFriendRequest = getIntent().getBooleanExtra(Constants.KEY_FRIENDREQUEST, false);
        _isOnlineService = getIntent().getBooleanExtra(Constants.KEY_ONLINE_SERVICE, false);

        if (!_isOnlineService)
            Commons.g_chattingActivity = this;
        else
            Commons.g_onlineActivity = this;

        if (roomName != null) {
            _roomEntity = _user.getRoom(roomName);
            _roomName = _roomEntity.get_name();
            _groupChat = new GroupChatManager(this, ConnectionMgrService.mConnection, _roomName);
            enterRoom();
        } else {
            _roomName = Constants.KEY_ONLINE_SERVICEROOM;
        }

        loadLayout();

        _player = MediaPlayer.create(this, R.raw.chatting);

    }

    private void loadLayout(){

        ui_txvTitle = (TextView) findViewById(R.id.chatting_title);
        ui_txvTitle.setText(getRoomTitle());

        ui_imvBack = (ImageView)findViewById(R.id.imv_back);
        ui_imvBack.setOnClickListener(this);

        ui_fytMoreBar = (FrameLayout) findViewById(R.id.fyt_morebar);

        int morBarHeight = Preference.getInstance().getValue(this, PrefConst.KEYBOARD_HEIGHT, 0);

        if (morBarHeight != 0) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) ui_fytMoreBar.getLayoutParams();
            params.height = morBarHeight;
            ui_fytMoreBar.setLayoutParams(params);

        }
        ui_fytMoreBar.setVisibility(View.GONE);

        ui_lytMoreBar = (LinearLayout)findViewById(R.id.lyt_morebar);

        ui_imvMore = (ImageView)findViewById(R.id.imv_more);
        ui_imvMore.setOnClickListener(this);

        ui_edtMessage = (BackKeyEditText) findViewById(R.id.edt_message);

        ui_imvGallery = (ImageView)findViewById(R.id.imv_gallery);
        ui_imvGallery.setOnClickListener(this);

        ui_imvCamera = (ImageView)findViewById(R.id.imv_camera);
        ui_imvCamera.setOnClickListener(this);

        ui_imvVideo = (ImageView)findViewById(R.id.imv_video);
        ui_imvVideo.setOnClickListener(this);

        ui_imvEmoji  = (ImageView)findViewById(R.id.imv_emoji);
        ui_imvEmoji.setOnClickListener(this);

        ui_imvSendText = (ImageView)findViewById(R.id.imv_send_text);
        ui_imvSendText.setOnClickListener(this);

        ui_imvCall = (ImageView) findViewById(R.id.imv_call);
        ui_imvCall.setOnClickListener(this);

        ui_imvVideoCall = (ImageView) findViewById(R.id.imv_video_call);
        ui_imvVideoCall.setOnClickListener(this);

        ui_imvGift = (ImageView) findViewById(R.id.imv_gift);
        ui_imvGift.setOnClickListener(this);

        ui_gridView = (GridView)findViewById(R.id.gridview);
        ui_gridView.setVisibility(View.GONE);

        ui_rltEmoji = (RelativeLayout) findViewById(R.id.rlt_emoji);
        ui_rltEmoji.setVisibility(View.GONE);

        ui_lytMessage = (LinearLayout) findViewById(R.id.lyt_message);
        ui_txvSend = (TextView) findViewById(R.id.txv_send);
        ui_txvSend.setVisibility(View.GONE);
        ui_txvSend.setOnClickListener(this);

        ui_lstChatting = (ListView)findViewById(R.id.lst_chatting);
        _chattingAdapter = new GroupChattingAdapter(this);
        ui_lstChatting.setAdapter(_chattingAdapter);

        ui_imvMenu = (ImageView) findViewById(R.id.imv_menu);
        ui_imvMenu.setOnClickListener(this);

        if (_isOnlineService)
            ui_imvMenu.setVisibility(View.GONE);

        ui_txvAccept = (TextView) findViewById(R.id.txv_accept);
        ui_txvAccept.setVisibility(View.GONE);
        ui_txvAccept.setOnClickListener(this);

        ui_emojiViewpager = (ViewPager) findViewById(R.id.emoji_pager);
        setupEmojiViewPager();

        ui_refreshLayout = (SwipyRefreshLayout)findViewById(R.id.refresh);

        if (_isOnlineService)
            ui_refreshLayout.setDirection(SwipyRefreshLayoutDirection.TOP);
        else
            ui_refreshLayout.setDirection(SwipyRefreshLayoutDirection.TOP);

        ui_refreshLayout.setOnRefreshListener(new SwipyRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh(SwipyRefreshLayoutDirection direction) {

                if (direction == SwipyRefreshLayoutDirection.TOP) {

                    if (!_isOnlineService) {
                        _recentLoadCounter++;
                        ui_lstChatting.setTranscriptMode(AbsListView.TRANSCRIPT_MODE_NORMAL);
                        startRefreshThread();
                    } else {
                        getOnlineMessage(true);
                    }
                } else if (direction == SwipyRefreshLayoutDirection.BOTTOM) {

                    if (_isOnlineService)
                        getOnlineMessage(false);
                }
            }
        });


        ui_lstChatting.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                if (_morebarState == 1) {
                    hideKeyboard();
                    ui_edtMessage.clearFocus();
                } else {
                    setNormalInputState();
                }

                _morebarState = 0;

                return false;
            }
        });

        ui_edtMessage.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.length() != 0) {
                    ui_imvSendText.setSelected(true);
                } else {
                    ui_imvSendText.setSelected(false);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        ui_edtMessage.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {

                if (hasFocus) {

                    _morebarState = 1;
                    hideEmoji();
                    ui_fytMoreBar.setVisibility(View.INVISIBLE);

                } else {
                    //lost focus
                }
            }
        });


        if (!_isOnlineService) {
            // if block user
            if (!_roomEntity.isGroup()) {

                if (_user.get_blockList().contains(_roomEntity.get_participantList().get(0))) {
                    setBlockState();
                }
            }

            new Thread(new Runnable() {
                @Override
                public void run() {
                    getFirstChattingList();
                }
            }).start();

            getRoomInfo();
        } else {
            getOnlineMessage(true);
        }


    }

    public String getRoomTitle() {

        if (_isOnlineService)
            return getString(R.string.qa_online);

        String title = "";

        if (!_roomEntity.isGroup()) {

            FriendEntity other = _roomEntity.get_participantList().get(0);
            title = other.get_name();
        } else {

            int leaveCount = 0;
            if (_roomEntity.get_leaveMembers().length() > 0) {
                leaveCount = _roomEntity.get_leaveMembers().split("_").length;
            }

            if (_user.get_groupList().contains(_user.getGroup(_roomEntity.get_name())))
                title = _user.getGroup(_roomEntity.get_name()).get_groupNickname() + "(" + (_roomEntity.get_participantList().size() - leaveCount + 1) + ")";
            else
                title = getString(R.string.group) + "(" + (_roomEntity.get_participantList().size() - leaveCount + 1) + ")";
        }

        return title;
    }

    private void setupEmojiViewPager(){

        EmojiViewPagerAdapter adapter = new EmojiViewPagerAdapter(getSupportFragmentManager());

        for (int i = 0; i < 2; i++) {

            EmojiFragment fragment = new EmojiFragment();

            Bundle bundle = new Bundle();
            bundle.putInt(Constants.KEY_EMOJI_PAGE, i);
            fragment.setArguments(bundle);
            adapter.addFrag(fragment);

        }

        ui_emojiViewpager.setAdapter(adapter);

        CircleIndicator indicator = (CircleIndicator) findViewById(R.id.emoji_indicator);
        indicator.setViewPager(ui_emojiViewpager);
    }

    public void showSettingPopup(boolean visible) {

        if (!visible) {
            ui_popupSetting.dismiss();
            return;
        }

        LayoutInflater layoutInflater
                = (LayoutInflater)getBaseContext()
                .getSystemService(LAYOUT_INFLATER_SERVICE);

        View popupView;

        popupView = layoutInflater.inflate(R.layout.popup_chatting_setting, null);

        ui_imvSound = (ImageView) popupView.findViewById(R.id.imv_soundOnOff);
        setSoundOn(Preference.getInstance().getValue(this, PrefConst.PREFKEY_NOTISOUND + _roomEntity.get_name(), true));
        ui_imvSound.setOnClickListener(this);

        TextView txvGroupChatting = (TextView) popupView.findViewById(R.id.txv_set_groupchatting);
        txvGroupChatting.setOnClickListener(this);

        ui_txvBlock = (TextView) popupView.findViewById(R.id.txv_set_block);

        if (_user.get_blockList().contains(_roomEntity.get_participantList().get(0))) {
            ui_txvBlock.setSelected(true);
            ui_txvBlock.setText(getString(R.string.unblock_friend));
            setBlockState();
        } else {
            ui_txvBlock.setSelected(false);
            ui_txvBlock.setText(getString(R.string.block));
        }

        ui_txvBlock.setOnClickListener(this);

        ui_popupSetting = new PopupWindow(popupView, Commons.GetPixelValueFromDp(this, 240), ViewGroup.LayoutParams.WRAP_CONTENT);
        ui_popupSetting.setBackgroundDrawable(new BitmapDrawable());
        ui_popupSetting.setOutsideTouchable(true);
        ui_popupSetting.showAsDropDown(ui_imvMenu);



    }

    public void gotoGroupInfo() {

        Intent intent = new Intent(GroupChattingActivity.this, GroupInfoActivity.class);

        if (_user.getGroup(_roomEntity.get_name()) != null)
            intent.putExtra(Constants.KEY_GROUP, _user.getGroup(_roomEntity.get_name()));
        else {
            GroupEntity group = new GroupEntity();
            group.set_groupName(_roomEntity.get_name());
            group.set_participants(_roomEntity.get_participants());
            intent.putExtra(Constants.KEY_GROUP, group);
        }

        startActivityForResult(intent, Constants.PICK_FROM_GROUPINFO);

    }

    public void showKeyboard() {

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
    }

    public void hideKeyboard() {

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtMessage.getWindowToken(), 0);
    }

    public void setNormalInputState() {

        ui_fytMoreBar.setVisibility(View.GONE);

        ui_gridView.setVisibility(View.GONE);
        ui_rltEmoji.setVisibility(View.GONE);
        ui_lytMoreBar.setVisibility(View.VISIBLE);
        ui_lytMessage.setVisibility(View.VISIBLE);
        ui_txvSend.setVisibility(View.GONE);
        ui_imvEmoji.setSelected(false);

        ui_imvMore.setSelected(false);
    }


    public void setBlockState() {

        setNormalInputState();
        ui_edtMessage.setText(getString(R.string.blocking));

        ui_edtMessage.setEnabled(false);
        ui_imvMore.setEnabled(false);
        ui_imvSendText.setEnabled(false);
        ui_imvSendText.setSelected(false);
        ui_imvEmoji.setEnabled(false);
    }

    public void setUnBlockState() {

        setNormalInputState();
        ui_edtMessage.setText("");

        ui_edtMessage.setEnabled(true);
        ui_imvMore.setEnabled(true);
        ui_imvSendText.setEnabled(true);
        ui_imvEmoji.setEnabled(true);
    }



    public void setSoundOn(boolean onOff) {

        Preference.getInstance().put(this, PrefConst.PREFKEY_NOTISOUND + _roomEntity.get_name(), onOff);
        ui_imvSound.setSelected(onOff);
    }


    public void setBlock(boolean yesNo) {

        if (yesNo) {
            blockUser();
        } else {
            unblockUser();
        }
    }

    public void blockUser() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETBLOCKUSER;

        String params = String.format("/%d/%d", _user.get_idx(), _roomEntity.get_participantList().get(0).get_idx());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseBlockUserResponse(json);

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

    public void parseBlockUserResponse(String json) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                FriendEntity friendEntity = _roomEntity.get_participantList().get(0);
                Database.createBlock(friendEntity.get_idx());
                _user.get_blockList().add(friendEntity);

                ui_txvBlock.setText(getString(R.string.unblock_friend));
                ui_txvBlock.setSelected(true);

                setBlockState();

            }

        } catch (JSONException e){
            e.printStackTrace();
        }

    }


    public void unblockUser() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETUNBLOCKUSER;

        String params = String.format("/%d/%d", _user.get_idx(), _roomEntity.get_participantList().get(0).get_idx());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseUnblockUserResponse(json);

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

    public void parseUnblockUserResponse(String json) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                FriendEntity friendEntity = _roomEntity.get_participantList().get(0);
                Database.deleteBlock(friendEntity.get_idx());
                _user.get_blockList().remove(friendEntity);
                ui_txvBlock.setText(getString(R.string.block));
                ui_txvBlock.setSelected(false);

                setUnBlockState();
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

    }

    public void inviteUser() {

        ArrayList<FriendEntity> members = new ArrayList<>();

        String[] leaveMemberIds = _roomEntity.get_leaveMembers().split("_");
        ArrayList<String> idList = new ArrayList<>(Arrays.asList(leaveMemberIds));

        for (FriendEntity friendEntity : _roomEntity.get_participantList()) {

            if (!idList.contains(String.valueOf(friendEntity.get_idx()))) {
                members.add(friendEntity);
            }
        }

        Intent intent = new Intent(GroupChattingActivity.this, SelectFriendActivity.class);
        intent.putExtra(Constants.KEY_MEMBERS, members);
        intent.putExtra(Constants.KEY_INVITE, true);
        intent.putExtra(Constants.KEY_FROM_1_1, true);
        startActivity(intent);


    }

    public void getFirstChattingList() {

        final ArrayList<GroupChatItem> recents = Database.getRecentMessage(_roomName, _recentLoadCounter);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                _chattingAdapter.addItems(recents);
                _chattingAdapter.notifyDataSetChanged();
            }
        });
    }

    public void startRefreshThread() {

        new Thread(new Runnable() {
            @Override
            public void run() {
                getChattingList();
            }
        }).start();
    }


    public void getChattingList() {

        final ArrayList<GroupChatItem> recents = Database.getRecentMessage(_roomName, _recentLoadCounter);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {

                int prevCount = _chattingAdapter.getCount();

                _chattingAdapter.clearAll();
                _chattingAdapter.addItems(recents);
                _chattingAdapter.notifyDataSetChanged();
                ui_lstChatting.setSelection(_chattingAdapter.getCount() - prevCount);

                ui_refreshLayout.setRefreshing(false);
//                ui_lstChatting.smoothScrollToPosition(0);

            }
        });
    }

    public void getOnlineMessage(final boolean isRefresh) {

        if (isRefresh)
            _pageIndex = 1;
        else
            _pageIndex++;


        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETONLINEMESSAGE ;

        String params = String.format("/%d/%d", Commons.g_user.get_idx(), _pageIndex);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseOnlineResponse(json, isRefresh);

            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                ui_refreshLayout.setRefreshing(false);
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseOnlineResponse(String json, boolean isRefresh){

        try{

            if (isRefresh) {
                _chattingAdapter.clearAll();
            }
            ui_refreshLayout.setRefreshing(false);

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray messages = response.getJSONArray(ReqConst.RES_MESSAGEINFOS);

                for (int i = messages.length() - 1; i >= 0; i--) {

                    JSONObject one = messages.getJSONObject(i);
                    String msg = one.getString(ReqConst.RES_MESSAGE);
                    String regTime = one.getString(ReqConst.RES_REGDATE);
                    int type = one.getInt(ReqConst.RES_TYPE);
                    int width = one.getInt(ReqConst.RES_WIDTH);
                    int height = one.getInt(ReqConst.RES_HEIGHT);

                    String fullMessage;

                    if (msg.startsWith(ReqConst.UPLOADPATH))
                        fullMessage = getRoomInfoString() + Constants.KEY_IMAGE_MARKER + msg + Constants.KEY_SEPERATOR + width + Constants.KEY_SEPERATOR + height + Constants.KEY_SEPERATOR + Commons.getFileNameWithExtFromUrl(msg) + Constants.KEY_SEPERATOR + Commons.convertTimeString(regTime);
                    else
                        fullMessage = getRoomInfoString() + msg + Constants.KEY_SEPERATOR + Commons.convertTimeString(regTime);

                    GroupChatItem chatItem;

                    if (type == 0)  // sent
                        chatItem = new GroupChatItem(_user.get_idx(), _roomName, fullMessage);
                    else // received from admin
                        chatItem = new GroupChatItem(0, _roomName, fullMessage);

                    _chattingAdapter.addItem(chatItem);

                }

            }

            _chattingAdapter.notifyDataSetChanged();

        }catch (JSONException e){
            e.printStackTrace();
        }

    }

    public void enterRoom() {

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params) {
                // We send the message here.
                // You should also check if the username is valid here.
                try {
                    _groupChat.enterRoom(String.valueOf(_user.get_idx()));
                } catch (Exception e) {
                    showToast(getString(R.string.chatting_error));
                }
                return null;
            }

            @Override
            protected void onPostExecute(Void aVoid) {
                super.onPostExecute(aVoid);

                if (!_groupChat.isJoined) {
                    enterRoomRetry();
                    showToast(getString(R.string.chatting_error));
                } else {

                    if (_isFriendRequest) {
                        sendTextMessage(_user.get_name() + Constants.FRIEND_REQUEST_SENT);
                    }
                    showToast(getString(R.string.chatting_success));
                }
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    public void enterRoomRetry() {

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params) {
                // We send the message here.
                // You should also check if the username is valid here.
                try {
                    _groupChat.enterRoom(String.valueOf(_user.get_idx()));
                } catch (Exception e) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            showToast(getString(R.string.error));
                        }
                    });
                }
                return null;
            }

            @Override
            protected void onPostExecute(Void aVoid) {
                super.onPostExecute(aVoid);

                if (!_groupChat.isJoined)
                    showToast(getString(R.string.chatting_error));
                else {
                    if (_isFriendRequest) {
                        sendTextMessage(_user.get_name() + " " + Constants.FRIEND_REQUEST_SENT);
                    }
                    showToast(getString(R.string.chatting_success));
                }
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }


    public void reenterRoom() {

        try {
            _groupChat.reenterRoom(String.valueOf(_user.get_idx()));
        } catch (Exception e) {
            showToast(getString(R.string.chatting_error));
        }
    }

    public void updateRoomTitle() {
        ui_txvTitle.setText(getRoomTitle());
    }

    public void getRoomInfo(){

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETROOMINFO;

        String params = String.format("/%d/%s", _user.get_idx(), _roomEntity.get_participants());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseRoomInfoResponse(json);
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

    public void parseRoomInfoResponse(String json){

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray participants = response.getJSONArray(ReqConst.RES_USERINFOS);

                // get participants data
                for (int i = 0; i < participants.length(); i++) {

                    JSONObject friend = (JSONObject) participants.get(i);

                    int idx = friend.getInt(ReqConst.RES_ID);

                    FriendEntity participant = _roomEntity.getParticipant(idx);
                    if (participant != null) {
                        participant.set_name(friend.getString(ReqConst.RES_NAME));
                        participant.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                        participant.set_isFriend(friend.getInt(ReqConst.RES_ISFRIEND) == 1);
                        participant.set_latitude((float) friend.getDouble(ReqConst.RES_LATITUDE));
                        participant.set_longitude((float) friend.getDouble(ReqConst.RES_LONGITUDE));
                        participant.set_lastLogin(friend.getString(ReqConst.RES_LASTLOGIN));
                    }
                }

                updateAcceptMenu();

            }

        } catch (JSONException e){
            e.printStackTrace();
        }

        getGroupRequest();

    }

    public void addChat(int sender, String body) {

        ui_lstChatting.setTranscriptMode(AbsListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);

        GroupChatItem chatItem = new GroupChatItem(sender, _roomName, body);
        _chattingAdapter.addItem(chatItem);
        _chattingAdapter.notifyDataSetChanged();

    }

    public void addChat(GroupChatItem chatItem) {

        ui_lstChatting.setTranscriptMode(AbsListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
        _chattingAdapter.addItem(chatItem);
        _chattingAdapter.notifyDataSetChanged();
    }

    public GroupChatItem addChat(int sender, String message, GroupChatItem.StatusType type) {

        ui_lstChatting.setTranscriptMode(AbsListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);

        GroupChatItem chatItem = new GroupChatItem(sender, _roomName, message, type);

        _chattingAdapter.addItem(chatItem);
        _chattingAdapter.notifyDataSetChanged();

        return chatItem;
    }

    public String getRoomInfoString() {

        if (_isOnlineService)
            return Constants.KEY_ROOM_MARKER + Constants.KEY_ONLINE_SERVICEROOM + ":" + _user.get_idx() + ":" + _user.get_name() + Constants.KEY_SEPERATOR;

        return Constants.KEY_ROOM_MARKER + _roomName + ":" + _roomEntity.get_participants() + ":" + _user.get_name() + Constants.KEY_SEPERATOR;
    }

    public ArrayList<Integer> getParticipants() {

        ArrayList<Integer> returned = new ArrayList<>();

        for (FriendEntity friend : _roomEntity.get_participantList()) {

            int idx = friend.get_idx();

            if (idx != _user.get_idx())
                returned.add(Integer.valueOf(idx));
        }

        return returned;
    }


    // basic send message
    // ROOM#[roomname]:[roomparticipants]:[sendername]#message#time
    // ROOM#1_2:1_2_3:에스오#message#time, ROOM#1_2:1_2_3:에스오#FILE#url#filename#time
    public void sendTextMessage(final String chat_message) {

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params) {
                // We send the message here.
                // You should also check if the username is valid here.
                try {

                    // send both group message and message for outside user
                    String fullMessage = getRoomInfoString() + chat_message + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();

                    // send group message for inside user
                    _groupChat.sendMessage(fullMessage);

                    // update room recent conversation
                    _roomEntity.set_recentContent(getMessage(fullMessage));
                    _roomEntity.set_recentTime(getFullTime(fullMessage));
                    Database.updateRoom(_roomEntity);

                    // write message into db
                    GroupChatItem chatItem = new GroupChatItem(_user.get_idx(), _roomEntity.get_name(), fullMessage);
                    Database.createMessage(chatItem);

                    // send message for outside user
                    sendTextMessage(getParticipants(), fullMessage);

                } catch (SmackException.NotConnectedException e) {
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPostExecute(Void aVoid) {
                String fullMessage = getRoomInfoString() + chat_message + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();

                // for image, video, file added already
                if (getType(fullMessage) == GroupChatItem.ChatType.TEXT ||
                        getType(fullMessage) == GroupChatItem.ChatType.SYSTEM)
                    addChat(_user.get_idx(), fullMessage);

                super.onPostExecute(aVoid);
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    // send message for outside users
    public void sendTextMessage(ArrayList<Integer> participants, String chat_message) {

        String[] leaveMemberIds = _roomEntity.get_leaveMembers().split("_");
        ArrayList<String> idList = new ArrayList<>(Arrays.asList(leaveMemberIds));

        for (Integer participant : participants) {

            int idx = participant.intValue();

            // if not leave member
            if (!idList.contains(String.valueOf(idx))) {
                sendTextMessage(Commons.idxToAddr(idx), chat_message);
            }
        }
    }

    // send message for outside individual user
    public void sendTextMessage(String address, String chat_message) {
        // Listview is updated with our new message
        ChatManager chatManager = ChatManager.getInstanceFor(ConnectionMgrService.mConnection);

        final Chat newChat = chatManager.createChat(address);

        final Message message = new Message();
        message.setBody(chat_message);

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params) {
                // We send the message here.
                // You should also check if the username is valid here.
                try {
                    newChat.sendMessage(message);
                } catch (SmackException.NotConnectedException e) {
                }
                return null;
            }

            @Override
            protected void onPostExecute(Void aVoid) {
                super.onPostExecute(aVoid);
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }


    public void sendImage(String imgPath, String filename, int width, int height) {

        File file = new File(imgPath);

        if (!file.exists()) return;

        String chat_message = Constants.KEY_IMAGE_MARKER + imgPath + Constants.KEY_SEPERATOR + width + Constants.KEY_SEPERATOR + height + Constants.KEY_SEPERATOR + filename;
        String fullMessage = getRoomInfoString() + chat_message + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();
        GroupChatItem chatItem = addChat(_user.get_idx(), fullMessage, GroupChatItem.StatusType.START_UPLOADING);

        new Uploadtask().execute(imgPath, String.valueOf(GroupChatItem.ChatType.IMAGE.ordinal()), chatItem);

    }


    public void sendVideo(String videoPath, String filename, int width, int height) {

        File file = new File(videoPath);

        if (!file.exists()) return;

        if (file.length() > Constants.LIMIT_FILE) {
            showAlertDialog(getString(R.string.file_overflow));
            return;
        }

        String chat_message = Constants.KEY_VIDEO_MARKER + videoPath + Constants.KEY_SEPERATOR + width + Constants.KEY_SEPERATOR + height + Constants.KEY_SEPERATOR + filename;
        String fullMessage = getRoomInfoString() + chat_message + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();
        GroupChatItem chatItem = addChat(_user.get_idx(), fullMessage, GroupChatItem.StatusType.START_UPLOADING);

        new Uploadtask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, videoPath, String.valueOf(GroupChatItem.ChatType.VIDEO.ordinal()), chatItem);

    }

    public void sendEmoji(EmojiEntity emoji) {

        if (_isOnlineService)
            sendOnlineMessage(emoji.get_emojiString(), false, 0, 0);
        else
            sendTextMessage(emoji.get_emojiString());
    }


    public String getFullTime(String body) {

        return body.substring(body.lastIndexOf(Constants.KEY_SEPERATOR) + 1);
    }



    // ROOM#1_2#message#time, ROOM#1_2#FILE#message#time
    public String getMessage(String body) {

        String body1 = body.substring(body.indexOf(Constants.KEY_SEPERATOR) + 1, body.lastIndexOf(Constants.KEY_SEPERATOR));
        String message = body1.substring(body1.indexOf(Constants.KEY_SEPERATOR) + 1);

        if (getType(body) == GroupChatItem.ChatType.VIDEO ||
                getType(body) == GroupChatItem.ChatType.IMAGE ||
                getType(body) == GroupChatItem.ChatType.FILE ) {
            message = Commons.g_currentActivity.getString(R.string.transfer_file);
        }else if (getType(body) == GroupChatItem.ChatType.SYSTEM) {
            message = message.substring(Constants.KEY_SYSTEM_MARKER.length());
        }

        return message;
    }

    public GroupChatItem.ChatType getType(String body) {

        String body1 = body.substring(body.indexOf(Constants.KEY_SEPERATOR) + 1);
        body1 = body1.substring(body1.indexOf(Constants.KEY_SEPERATOR) + 1);
        GroupChatItem.ChatType type = GroupChatItem.ChatType.TEXT;

        if (body1.startsWith(Constants.KEY_FILE_MARKER))
            type = GroupChatItem.ChatType.FILE;
        else if (body1.startsWith(Constants.KEY_IMAGE_MARKER))
            type = GroupChatItem.ChatType.IMAGE;
        else if (body1.startsWith(Constants.KEY_VIDEO_MARKER))
            type = GroupChatItem.ChatType.VIDEO;
        else if (body1.startsWith(Constants.KEY_SYSTEM_MARKER))
            type = GroupChatItem.ChatType.SYSTEM;

        return type;
    }

    public RoomEntity get_roomEntity() {

        return _roomEntity;
    }

    public Bitmap saveThumbnail(String filepath) {

        Bitmap thumb = null;

        File file = new File(filepath);

        if (!file.exists())
            return thumb;

        try {
            thumb = ThumbnailUtils.createVideoThumbnail(filepath,
                    MediaStore.Images.Thumbnails.MINI_KIND);

            String filename = BitmapUtils.getVideoThumbFolderPath() + Commons.fileNameWithoutExtFromPath(filepath) + ".png";
            File thumbFile = new File(filename);

            if (thumb != null)
                BitmapUtils.saveOutput(thumbFile, thumb);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return thumb;
    }

    public void onSuccessUpload(String fileurl, String filename, GroupChatItem chatItem) {

        String marker = Constants.KEY_IMAGE_MARKER;

        GroupChatItem.ChatType type = chatItem.getType();

        if (type == GroupChatItem.ChatType.VIDEO)
            marker = Constants.KEY_VIDEO_MARKER;
        else if (type == GroupChatItem.ChatType.FILE)
            marker = Constants.KEY_FILE_MARKER;

        String message;

        if (chatItem.getType() == GroupChatItem.ChatType.IMAGE || chatItem.getType() == GroupChatItem.ChatType.VIDEO) {
            message = marker + fileurl + Constants.KEY_SEPERATOR + chatItem.getImageWidth() + Constants.KEY_SEPERATOR + chatItem.getImageHeight() + Constants.KEY_SEPERATOR + filename;
        } else {
            message = marker + fileurl + Constants.KEY_SEPERATOR + filename;
        }

        if (_isOnlineService)
            sendOnlineMessage(fileurl, true, chatItem.getImageWidth(), chatItem.getImageHeight());
        else
            sendTextMessage(message);

    }

    public void onFailUpload() {

        if (_isOnlineService)
            showAlertDialog(getString(R.string.transfer_fail));
        else
            sendTextMessage(getString(R.string.transfer_fail));
    }


    public void showImage(String url, boolean mine) {

        Intent intent = new Intent(this, ImagePreviewActivity.class);
        intent.putExtra(Constants.KEY_IMAGEPATH, url);
        startActivity(intent);

    }

    public void showFile(String filename) {

        String filepath = BitmapUtils.getDownloadFolderPath() + filename;
        File file = new File(filepath);

        if (!file.exists())
            return;

        MimeTypeMap myMime = MimeTypeMap.getSingleton();
        Intent newIntent = new Intent(android.content.Intent.ACTION_VIEW);
        String ext = Commons.fileExtFromUrl(filepath).substring(1);
        String mimeType = myMime.getMimeTypeFromExtension(ext);
        newIntent.setDataAndType(Uri.parse(filepath), mimeType);

        try {
            startActivity(newIntent);
        } catch (android.content.ActivityNotFoundException e) {
            showToast(getString(R.string.not_support_file));
        }
    }

    public void showDownloadDialog(final GroupChatItem chatItem) {

        final String url = chatItem.getFileUrl();
        final String filename = chatItem.getFilename();

        String filepath = BitmapUtils.getDownloadFolderPath() + filename;
        File file = new File(filepath);

        // already save to file
        if (file.exists()) {
            showFile(filename);
            return;
        }

        AlertDialog alertDialog = new AlertDialog.Builder(_context).create();

        alertDialog.setTitle(getString(R.string.app_name));
        alertDialog.setMessage(filename + " " + getString(R.string.download_confirm));

        alertDialog.setButton(AlertDialog.BUTTON_POSITIVE,
                _context.getString(R.string.ok),
                new android.content.DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        chatItem.set_status(GroupChatItem.StatusType.START_DOWNLOADING);
                        _chattingAdapter.notifyDataSetChanged();
                    }
                });

        alertDialog.setButton(AlertDialog.BUTTON_NEGATIVE,
                getString(R.string.cancel),
                new android.content.DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });

        alertDialog.show();
    }




    public void updateAcceptMenu() {

        if (_roomEntity.get_participantList().size() == 1) {

            if (_roomEntity.get_participantList().get(0).is_isFriend() || _user.isBlockUser(_roomEntity.get_participantList().get(0))) {
                ui_txvAccept.setVisibility(View.GONE);
                ui_imvMenu.setVisibility(View.VISIBLE);
            } else {
                ui_txvAccept.setVisibility(View.VISIBLE);
                ui_imvMenu.setVisibility(View.GONE);
            }
        } else {
            ui_txvAccept.setVisibility(View.GONE);
            ui_imvMenu.setVisibility(View.VISIBLE);
        }
    }

    public void acceptFriendRequest() {

        sendTextMessage(_user.get_name() + Constants.FRIEND_REQUEST_ACCEPT);
        makeFriend();
    }

    public void makeFriend() {

        FriendEntity friendEntity = _roomEntity.get_participantList().get(0);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_MAKEFRIEND;

        String params = String.format("/%d/%d", _user.get_idx(), friendEntity.get_idx());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseMakeResponse(json);

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

    public void parseMakeResponse(String json){

        try{

            FriendEntity friendEntity = _roomEntity.get_participantList().get(0);

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                friendEntity.set_isFriend(true);

                if (!_user.get_friendList().contains(friendEntity)) {
                    _user.get_friendList().add(friendEntity);
                    Database.createFriend(friendEntity.get_idx());
                }
                updateAcceptMenu();

            }

        }catch (JSONException e){
            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

    }

    public void removeBanishUsers(ArrayList<String> idArray) {

        _chattingAdapter.deleteUserMessage(idArray);

        ArrayList<FriendEntity> copy = new ArrayList<>();
        copy.addAll(_roomEntity.get_participantList());

        for (int i = 0; i < copy.size(); i++) {

            FriendEntity friendEntity = copy.get(i);

            if (idArray.contains(String.valueOf(friendEntity.get_idx()))) {
                _roomEntity.get_participantList().remove(friendEntity);
            }
        }

        Database.updateRoom(_roomEntity);
     }


    public void showImageGallery() {

        String[] PERMISSIONS = {Manifest.permission.READ_EXTERNAL_STORAGE};

        if (Commons.hasPermissions(this, PERMISSIONS)) {

            if (_imageUrls.size() == 0) {

                final String[] columns = {MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID};

                Cursor imagecursor = managedQuery(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
                        null, orderBy + " DESC");

                for (int i = 0; i < imagecursor.getCount(); i++) {
                    imagecursor.moveToPosition(i);
                    int dataColumnIndex = imagecursor.getColumnIndex(MediaStore.Images.Media.DATA);
                    _imageUrls.add(imagecursor.getString(dataColumnIndex));

                }
            }

            _imageAdapter = new ImageGalleryAdapter(this, _imageUrls);

            ui_gridView.setVisibility(View.VISIBLE);
            ui_lytMoreBar.setVisibility(View.INVISIBLE);
            ui_imvMore.setSelected(true);
            ui_txvSend.setVisibility(View.VISIBLE);
            ui_lytMessage.setVisibility(View.INVISIBLE);
            ui_gridView.setNumColumns(4);
            ui_gridView.setAdapter(_imageAdapter);

        } else {
            ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
        }
    }


    public void showVideoGallery() {

        String[] PERMISSIONS = {Manifest.permission.READ_EXTERNAL_STORAGE};

        if (Commons.hasPermissions(this, PERMISSIONS)) {

            if (_videoUrls.size() == 0) {

                String[] videoParams = {MediaStore.Video.Media._ID,
                        MediaStore.Video.Media.DATA,
                        MediaStore.Video.VideoColumns.DURATION};

                Cursor videoCursor = managedQuery(
                        MediaStore.Video.Media.EXTERNAL_CONTENT_URI, videoParams, null,
                        null, orderBy + " DESC");

                for (int i = 0; i < videoCursor.getCount(); i++) {

                    videoCursor.moveToPosition(i);

                    VideoEntity entity = new VideoEntity();
                    entity.set_path(videoCursor.getString(videoCursor.getColumnIndex(MediaStore.Video.Media.DATA)));
                    entity.set_id(videoCursor.getInt(videoCursor.getColumnIndex(MediaStore.Video.Media._ID)));
                    entity.set_duration(videoCursor.getInt(videoCursor.getColumnIndex(MediaStore.Video.VideoColumns.DURATION)));

                    _videoUrls.add(entity);

                }

            }

            ui_gridView.setVisibility(View.VISIBLE);
            ui_lytMoreBar.setVisibility(View.INVISIBLE);
            ui_imvMore.setSelected(true);
            ui_lytMessage.setVisibility(View.INVISIBLE);
            ui_gridView.setNumColumns(3);
            ui_gridView.setAdapter(new VideoGalleryAdapter(this, _videoUrls));

        } else {
            ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
        }
    }


    public void onTakePhoto() {

        String[] PERMISSIONS = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE};

        if (Commons.hasPermissions(this, PERMISSIONS)) {

            Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

            _capturePath = BitmapUtils.getTempFolderPath() + "temp.png";
            _imageCaptureUri = Uri.fromFile(new File(_capturePath));

            intent.putExtra(MediaStore.EXTRA_OUTPUT, _imageCaptureUri);
            startActivityForResult(intent, Constants.PICK_FROM_CAMERA);
        } else {
            ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
        }

    }

    public void onSendImage() {

        if (_imageAdapter.getCheckedItems().size() == 0)
            return;

        setNormalInputState();

        for (String path : _imageAdapter.getCheckedItems()) {

            String filename = Commons.fileNameWithoutExtFromUrl(path) + ".png";

            Bitmap w_bmpGallery = BitmapUtils.loadOrientationAdjustedBitmap(path);

            String w_strLimitedImageFilePath = BitmapUtils.getUploadImageFilePath(w_bmpGallery, filename);

            if (w_strLimitedImageFilePath != null) {
                path = w_strLimitedImageFilePath;
            }

            Bitmap bitmap = BitmapFactory.decodeFile(path);

            int width = bitmap.getWidth();
            int height = bitmap.getHeight();
            bitmap.recycle();
            w_bmpGallery.recycle();

            sendImage(path, filename, width, height);

       }

        playSendSound();

    }

    public void onAudioCall() {

        if (_isOnlineService) return;

        // 1:1
        if (!_roomEntity.isGroup()) {

            FriendEntity otherUser = _roomEntity.get_participantList().get(0);

            if (otherUser.is_isFriend()) {

                String[] PERMISSIONS = {Manifest.permission.MODIFY_AUDIO_SETTINGS, Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA};

                if (Commons.hasPermissions(this, PERMISSIONS)) {
                    Commons.g_xmppService.sendVideoRequest(otherUser.get_idx(), otherUser.get_name(), false);
                } else {
                    ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
                }

            }

        }

    }


    public void onVideoCall() {

        if (_isOnlineService) return;

        // 1:1
        if (!_roomEntity.isGroup()) {

            FriendEntity otherUser = _roomEntity.get_participantList().get(0);

            if (otherUser.is_isFriend()) {

                String[] PERMISSIONS = {Manifest.permission.MODIFY_AUDIO_SETTINGS, Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA};

                if (Commons.hasPermissions(this, PERMISSIONS)) {
                    Commons.g_xmppService.sendVideoRequest(otherUser.get_idx(), otherUser.get_name(), true);
                } else {
                    ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
                }

            }

        }

    }

    public void onGift() {

        if (_isOnlineService) return;

        // 1:1
        if (!_roomEntity.isGroup()) {


        }

    }


    public void showEmoji() {

        ui_fytMoreBar.setVisibility(View.VISIBLE);
        ui_lytMoreBar.setVisibility(View.GONE);
        ui_rltEmoji.setVisibility(View.VISIBLE);
        ui_imvEmoji.setSelected(true);

        if (_morebarState == 1) {
            _morebarState = 2;
            hideKeyboard();
            ui_edtMessage.clearFocus();
        }
    }


    public void hideEmoji() {

        ui_imvEmoji.setSelected(false);
        ui_rltEmoji.setVisibility(View.GONE);

        _morebarState = 1;
        ui_edtMessage.requestFocus();
        ui_fytMoreBar.setVisibility(View.INVISIBLE);
        showKeyboard();

    }

    public void playSendSound() {

        _player.start();
    }


    public void sendOnlineMessage(final String message, final boolean isImage, final int width, final int height) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SENDONLINEMESSAGE;

        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                parseSendResponse(response);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                showToast(getString(R.string.fail_upload_timeline));
                closeProgress();
            }
        }){
            @Override
            protected Map<String,String> getParams(){
                Map<String,String> params = new HashMap<>();
                params.put(ReqConst.PARAM_ID, String.valueOf(Commons.g_user.get_idx()));

                if (isImage)
                    params.put(ReqConst.PARAM_ISIMAGE, "1");
                else
                    params.put(ReqConst.PARAM_ISIMAGE, "0");

                params.put(ReqConst.PARAM_WIDTH, String.valueOf(width));
                params.put(ReqConst.PARAM_HEIGHT, String.valueOf(height));


                try {
                    String content = message.replace(" ", "%20");
                    content = URLEncoder.encode(content, "utf-8");
                    params.put(ReqConst.PARAM_MESSAGE, content);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

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

    public void parseSendResponse(String json){

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){
            } else {
                showAlertDialog(getString(R.string.error));
            }

        }catch (JSONException e){
            showAlertDialog(getString(R.string.error));
            e.printStackTrace();
        }

    }

    public void getGroupRequest() {

        GroupEntity group = _user.getGroup(_roomEntity.get_name());

        // if me is group owner
        if (group != null && group.get_ownerIdx() == _user.get_idx()) {

            String url = ReqConst.SERVER_URL + ReqConst.REQ_GETGROUPREQUEST;

            String params = String.format("/%s", _roomEntity.get_name());
            url += params;

            StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
                @Override
                public void onResponse(String json) {
                    parseGroupRequestResponse(json);
                }
            }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {
                }
            });

            stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                    0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

            WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

        }
    }

    public void parseGroupRequestResponse(String json){

        try {

            _groupRequests.clear();

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray requestArray = response.getJSONArray(ReqConst.RES_GROUPREQUESTS);

                for (int i = 0; i < requestArray.length(); i++) {

                    JSONObject request = requestArray.getJSONObject(i);

                    GroupRequestEntity requestEntity = new GroupRequestEntity();
                    requestEntity.set_groupName(_roomEntity.get_name());
                    requestEntity.set_userId(request.getInt(ReqConst.RES_USERID));
                    requestEntity.set_username(request.getString(ReqConst.RES_USERNAME));
                    requestEntity.set_userPhoto(request.getString(ReqConst.RES_USERPHOTO));
                    requestEntity.set_content(request.getString(ReqConst.RES_CONTENT));

                    _groupRequests.add(requestEntity);
                }
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

        if (_groupRequests.size() > 0) {
            showAcceptGroupDiag(0);
        }

    }

    public void showAcceptGroupDiag(final int reqIdx) {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag_accept_group, null);

        final Dialog dialog = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        dialog.setContentView(dialoglayout);

        final GroupRequestEntity requestEntity = _groupRequests.get(reqIdx);

        ImageView imvUserPhoto = (ImageView) dialoglayout.findViewById(R.id.imv_user_photo);
        Glide.with(_context).load(requestEntity.get_userPhoto()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(imvUserPhoto);

        TextView txvUsername = (TextView) dialoglayout.findViewById(R.id.txv_username);
        txvUsername.setText(requestEntity.get_username());

        TextView txvCount = (TextView) dialoglayout.findViewById(R.id.txv_count);
        txvCount.setText((reqIdx + 1) + " / " + _groupRequests.size());

        TextView txvContent = (TextView) dialoglayout.findViewById(R.id.txv_content);
        txvContent.setText(requestEntity.get_content());

        final TextView txvAccept = (TextView) dialoglayout.findViewById(R.id.txv_accept);
        txvAccept.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {

                acceptGroupRequest(requestEntity);
                dialog.dismiss();

                // show next request diag
                if (reqIdx + 1 < _groupRequests.size()) {
                    showAcceptGroupDiag(reqIdx + 1);
                }

            }
        });

        TextView txvDecline = (TextView) dialoglayout.findViewById(R.id.txv_decline);
        txvDecline.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {

                declineGroupRequest(requestEntity);
                dialog.dismiss();

                // show next request diag
                if (reqIdx + 1 < _groupRequests.size()) {
                    showAcceptGroupDiag(reqIdx + 1);
                }
            }
        });

        dialog.show();
    }



    public void acceptGroupRequest(final GroupRequestEntity requestEntity) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_ACCEPTGROUPREQUEST;

        FriendEntity friendEntity = new FriendEntity();

        friendEntity.set_idx(requestEntity.get_userId());
        friendEntity.set_name(requestEntity.get_username());
        friendEntity.set_photoUrl(requestEntity.get_userPhoto());

        if (_roomEntity.get_participantList().contains(friendEntity))
            return;

        _roomEntity.get_participantList().add(friendEntity);

        String participants = _roomEntity.makeParticipantsWithoutLeaveMemeber(true);
        _roomEntity.set_participants(participants);
        Database.updateRoom(_roomEntity);

        sendAcceptGroupMessage(requestEntity);

        String params = String.format("/%d/%s/%s", requestEntity.get_userId(), requestEntity.get_groupName(), participants);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }



    public void sendAcceptGroupMessage(GroupRequestEntity requestEntity) {

        String acceptMessage = requestEntity.get_username() + "$" + _roomEntity.get_name() + "$" +
                Constants.KEY_ADD_MARKER;

        sendStatusMessageToRoom(acceptMessage, true);
    }

    public void sendStatusMessageToRoom(String statusMessage, boolean toMe) {

        String fullMessage = getRoomInfoString() + Constants.KEY_SYSTEM_MARKER + statusMessage + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();

        ChatManager chatManager = ChatManager.getInstanceFor(ConnectionMgrService.mConnection);

        String[] leaveMemberIds = _roomEntity.get_leaveMembers().split("_");
        ArrayList<String> leaveIdList = new ArrayList<>(Arrays.asList(leaveMemberIds));

        for (int i = 0; i <= _roomEntity.get_participantList().size(); i++) {

            String address = "";

            if (i < _roomEntity.get_participantList().size()) {

                FriendEntity friendEntity = _roomEntity.get_participantList().get(i);

                // if leave member
                if (leaveIdList.contains(String.valueOf(friendEntity.get_idx())))
                    continue;
                else
                    address = Commons.idxToAddr(friendEntity.get_idx());

            } else {  // me

                if (!toMe)
                    break;

                address = Commons.idxToAddr(Commons.g_user.get_idx());
            }

            final Chat newChat = chatManager.createChat(address);

            final Message message = new Message();
            message.setBody(fullMessage);

            new AsyncTask<Void, Void, Void>() {
                @Override
                protected Void doInBackground(Void... params) {
                    // We send the message here.
                    // You should also check if the username is valid here.
                    try {
                        newChat.sendMessage(message);
                    } catch (SmackException.NotConnectedException e) {
                    }
                    return null;
                }

                @Override
                protected void onPostExecute(Void aVoid) {
                    super.onPostExecute(aVoid);
                }
            }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        }

    }

    public void declineGroupRequest(GroupRequestEntity requestEntity) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_DECLINEGROUPREQUEST;

        String params = String.format("/%d/%s", requestEntity.get_userId(), requestEntity.get_groupName());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }


    public void getGroupRequestByUserId(int userIdx, String roomName) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETGROUPREQUESTBYID;

        String params = String.format("/%s/%d", roomName, userIdx);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseUserGroupRequest(json);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseUserGroupRequest(String json) {

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray requestArray = response.getJSONArray(ReqConst.RES_GROUPREQUESTS);

                if (requestArray.length() == 0)
                    return;

                JSONObject request = requestArray.getJSONObject(0);

                GroupRequestEntity requestEntity = new GroupRequestEntity();
                requestEntity.set_groupName(_roomEntity.get_name());
                requestEntity.set_userId(request.getInt(ReqConst.RES_USERID));
                requestEntity.set_username(request.getString(ReqConst.RES_USERNAME));
                requestEntity.set_userPhoto(request.getString(ReqConst.RES_USERPHOTO));
                requestEntity.set_content(request.getString(ReqConst.RES_CONTENT));

                showAcceptGroupDiag(requestEntity);

            }

        } catch (JSONException e){
            e.printStackTrace();
        }
    }

    public void showAcceptGroupDiag(final GroupRequestEntity requestEntity) {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag_accept_group, null);

        final Dialog dialog = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        dialog.setContentView(dialoglayout);

        ImageView imvUserPhoto = (ImageView) dialoglayout.findViewById(R.id.imv_user_photo);
        Glide.with(_context).load(requestEntity.get_userPhoto()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(imvUserPhoto);

        TextView txvUsername = (TextView) dialoglayout.findViewById(R.id.txv_username);
        txvUsername.setText(requestEntity.get_username());

        TextView txvCount = (TextView) dialoglayout.findViewById(R.id.txv_count);
        txvCount.setVisibility(View.GONE);

        TextView txvContent = (TextView) dialoglayout.findViewById(R.id.txv_content);
        txvContent.setText(requestEntity.get_content());

        final TextView txvAccept = (TextView) dialoglayout.findViewById(R.id.txv_accept);
        txvAccept.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {

                acceptGroupRequest(requestEntity);
                dialog.dismiss();
            }
        });

        TextView txvDecline = (TextView) dialoglayout.findViewById(R.id.txv_decline);
        txvDecline.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {

                declineGroupRequest(requestEntity);
                dialog.dismiss();

            }
        });

        dialog.show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == Constants.PICK_FROM_GROUPINFO) {

            if (resultCode == RESULT_OK) {

                ArrayList<FriendEntity> newParticipants = (ArrayList<FriendEntity>) data.getSerializableExtra(Constants.KEY_NEWPARTICIPANTS);
                ArrayList<FriendEntity> banishParticipants = (ArrayList<FriendEntity>) data.getSerializableExtra(Constants.KEY_BANISHPARTICIPANTS);
                boolean isOut = data.getBooleanExtra(Constants.KEY_GROUPOUT, false);

                if (newParticipants != null || banishParticipants != null) {
                    updateRoomTitle();
                } else if (isOut) {     // out of group
                    finish();
                }

            }

        } else if (requestCode == Constants.PICK_FROM_VIDEO) {

            if (resultCode == RESULT_OK) {

                String path = data.getStringExtra(Constants.KEY_VIDEOPATH);
                String filename = Commons.fileNameWithExtFromUrl(path);

                saveThumbnail(path);
                String thumbfilename = BitmapUtils.getVideoThumbFolderPath() + Commons.fileNameWithoutExtFromPath(path) + ".png";

                Bitmap bitmap = BitmapFactory.decodeFile(thumbfilename);

                int width = bitmap.getWidth();
                int height = bitmap.getHeight();
                bitmap.recycle();

                sendVideo(path, filename, width, height);

                setNormalInputState();

                playSendSound();
            }

        }  else if (requestCode == Constants.PICK_FROM_CAMERA) {

            if (resultCode == RESULT_OK) {

                String filename = "IMAGE_" + System.currentTimeMillis() + ".png";

                Bitmap w_bmpGallery = BitmapUtils.loadOrientationAdjustedBitmap(_capturePath);

                String w_strFilePath = "";
                String w_strLimitedImageFilePath = BitmapUtils.getUploadImageFilePath(w_bmpGallery, filename);
                if (w_strLimitedImageFilePath != null) {
                    w_strFilePath = w_strLimitedImageFilePath;
                }

                Bitmap bitmap = BitmapFactory.decodeFile(w_strFilePath);

                int width = bitmap.getWidth();
                int height = bitmap.getHeight();
                bitmap.recycle();
                w_bmpGallery.recycle();

                sendImage(w_strFilePath, filename, width, height);

                playSendSound();
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if(grantResults[0]== PackageManager.PERMISSION_GRANTED){
            //resume tasks needing this permission
        }
    }

    public void onBackKeyPressedOnKeyboard() {

        ui_edtMessage.clearFocus();
        ui_fytMoreBar.setVisibility(View.GONE);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){

            case R.id.imv_back:
                onExit();
                break;

            case R.id.imv_more:

                if (ui_imvEmoji.isSelected()) {

                    ui_imvEmoji.setSelected(false);
                    ui_fytMoreBar.setVisibility(View.VISIBLE);
                    ui_lytMoreBar.setVisibility(View.VISIBLE);
                    ui_rltEmoji.setVisibility(View.GONE);

                } else if (ui_imvMore.isSelected()) {

                    ui_gridView.setVisibility(View.GONE);
                    ui_lytMoreBar.setVisibility(View.VISIBLE);
                    ui_lytMessage.setVisibility(View.VISIBLE);
                    ui_txvSend.setVisibility(View.GONE);

                    ui_imvMore.setSelected(false);

                } else {

                    if (_morebarState == 0) {
                        ui_fytMoreBar.setVisibility(View.VISIBLE);
                        _morebarState = 2;
                        ui_edtMessage.clearFocus();
                    } else if (_morebarState == 1) {
                        _morebarState = 2;
                        hideKeyboard();
                        ui_fytMoreBar.setVisibility(View.VISIBLE);
                        ui_lytMoreBar.setVisibility(View.VISIBLE);
                        ui_edtMessage.clearFocus();
                    } else {
                        _morebarState = 1;
                        ui_edtMessage.requestFocus();
                        ui_fytMoreBar.setVisibility(View.INVISIBLE);
                        showKeyboard();
                    }

                }

                break;

            case R.id.txv_send:
                onSendImage();

                break;

            case R.id.imv_gallery:
                showImageGallery();
                break;

            case R.id.imv_video:
                showVideoGallery();
                break;

            case R.id.imv_camera:
                onTakePhoto();
                break;

            case R.id.imv_emoji:

                if (!ui_imvEmoji.isSelected()) {
                    showEmoji();
                } else {
                    hideEmoji();
                }

                break;

            case R.id.imv_send_text:

                if (ui_edtMessage.length() > 0 ){

                    if (_isOnlineService) {

                        sendOnlineMessage(ui_edtMessage.getText().toString(), false, 0, 0);
                        String fullMessage = getRoomInfoString() + ui_edtMessage.getText().toString() + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();
                        addChat(_user.get_idx(), fullMessage);
                        ui_edtMessage.getText().toString();
                        ui_edtMessage.setText("");

                        playSendSound();

                    } else {

                        if (_groupChat.isJoined) {

                            sendTextMessage(ui_edtMessage.getText().toString());
                            ui_edtMessage.getText().toString();
                            ui_edtMessage.setText("");

                            playSendSound();

                        }
                    }
                }

                break;

            case R.id.imv_call:
                onAudioCall();
                break;


            case R.id.imv_video_call:
                onVideoCall();
                break;

            case R.id.imv_gift:
                onGift();
                break;

            case R.id.imv_menu:

                // 1:1
                if (!_roomEntity.isGroup()) {

                    _isSettingShown = !_isSettingShown;
                    showSettingPopup(_isSettingShown);
                } else {
                    gotoGroupInfo();
                }

                break;

            case R.id.txv_accept:
                acceptFriendRequest();
                break;

            // setting menu
            case R.id.imv_soundOnOff:
                setSoundOn(!ui_imvSound.isSelected());
                break;

            case R.id.txv_set_block:
                setBlock(!ui_txvBlock.isSelected());
                break;

            case R.id.txv_set_groupchatting:

                ui_popupSetting.dismiss();
                inviteUser();
                break;


        }
    }



    public void onItemClick(GroupChatItem chatItem) {

        if (chatItem.get_status() == GroupChatItem.StatusType.NORMAL) {

            switch (chatItem.getType()) {

                case TEXT:
                    break;

                case IMAGE:
                    if (chatItem.getSender() == _user.get_idx())
                        showImage(chatItem.getFileUrl(), true);
                    else
                        showImage(chatItem.getFileUrl(), false);
                    break;

                case VIDEO:
                    if (chatItem.getSender() != _user.get_idx())
                        showFile(chatItem.getFilename());
                    break;

                case FILE:

                    if (chatItem.getSender() != _user.get_idx())
                        showDownloadDialog(chatItem);
                    break;
            }
        }
    }


    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {

            if (_morebarState == 2) {

                setNormalInputState();
                _morebarState = 0;

            } else {
                onExit();
            }

            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

    public void onExit() {

        if (!_isOnlineService) {

            if (_chattingAdapter.getCount() > 0) {

                GroupChatItem lastItem = (GroupChatItem) _chattingAdapter.getItem(_chattingAdapter.getCount() - 1);

                String recentMsg = lastItem.getMessage();
                String recentTime = lastItem.getTime();

                if (lastItem.getType() == GroupChatItem.ChatType.VIDEO ||
                        lastItem.getType() == GroupChatItem.ChatType.IMAGE ||
                        lastItem.getType() == GroupChatItem.ChatType.FILE ) {
                    recentMsg = getString(R.string.transfer_file);
                }

                _roomEntity.init_recentCounter();
                _roomEntity.set_recentContent(recentMsg);
                _roomEntity.set_recentTime(recentTime);
                Database.updateRoom(_roomEntity);

                Commons.g_currentActivity.setUnRead();
            }
        }

        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (_groupChat != null) {

            _groupChat.leaveRoom();
            _groupChat = null;
        }

        Commons.g_chattingActivity = null;
        Commons.g_onlineActivity = null;

        if (_player != null) {
            _player.stop();
        }

        _player = null;
    }


    @Override
    protected void onPause() {

        super.onPause();

        if (_morebarState == 1) {
            ui_fytMoreBar.setVisibility(View.GONE);
            _morebarState = 0;
            ui_edtMessage.clearFocus();
        }

        hideKeyboard();
    }

    @Override
    protected void onResume() {

        super.onResume();
        checkConnection();
    }

    public void checkConnection() {

        if (!_isOnlineService) {
            if (Commons.g_xmppService == null || !Commons.g_xmppService.isConnected || !_groupChat.isJoined) {
                showToast(getString(R.string.chatting_connecting));
            }
        }
    }

    private void checkKeyboardHeight() {

        final View ui_rootView = findViewById(R.id.rootView);

        ui_rootView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                Rect r = new Rect();

                ui_rootView.getWindowVisibleDisplayFrame(r);

                int screenHeight = ui_rootView.getRootView().getHeight();
                int keyboardHeight = screenHeight - (r.bottom);

                if (keyboardHeight > 150) {

                    if (keyboardHeight != Preference.getInstance().getValue(GroupChattingActivity.this, PrefConst.KEYBOARD_HEIGHT, 0)) {
                        Preference.getInstance().put(GroupChattingActivity.this, PrefConst.KEYBOARD_HEIGHT, keyboardHeight);

                        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) ui_fytMoreBar.getLayoutParams();
                        params.height = keyboardHeight;
                        ui_fytMoreBar.setLayoutParams(params);
                    }
                }
            }
        });
    }



    class EmojiViewPagerAdapter extends FragmentPagerAdapter {

        private final List<Fragment> mFragmentList = new ArrayList<>();

        public EmojiViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFrag(Fragment fragment) {

            mFragmentList.add(fragment);
        }


    }

    private class Uploadtask extends AsyncTask<Object, Integer, String> {

        long totalSize = 0;
        GroupChatItem _chatItem = null;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }

        @Override
        protected void onProgressUpdate(Integer... progress) {

            _chatItem.set_progress(progress[0]);

            if (_chatItem.getType() == GroupChatItem.ChatType.FILE)
                _chattingAdapter.notifyDataSetChanged();

        }

        @Override
        protected String doInBackground(Object... params) {

            String filename = (String) params[0];
            String type = (String) params[1];
            _chatItem = (GroupChatItem) params[2];
            return upload(filename, type);
        }

        private String upload(String filepath, String type) {

            String responseString = "no";
            String urlString = ReqConst.SERVER_URL + ReqConst.REQ_UPLOADFILE;

            File sourceFile = new File(filepath);
            if (!sourceFile.isFile()) {
                return responseString;
            }

            HttpClient httpclient = new DefaultHttpClient();
            HttpPost httppost = new HttpPost(urlString);

            try {
                CustomMultiPartEntity entity = new CustomMultiPartEntity(new CustomMultiPartEntity.ProgressListener() {

                    @Override
                    public void transferred(long num) {
                        publishProgress((int) ((num / (float) totalSize) * 100));
                    }
                });

                String filename = Commons.fileNameWithExtFromPath(filepath);
                filename = URLEncoder.encode(filename, "utf-8").replace("+", "%20");

                entity.addPart(ReqConst.PARAM_ID, new StringBody(String.valueOf(_user.get_idx())));
                entity.addPart(ReqConst.PARAM_TYPE, new StringBody(type));
                entity.addPart(ReqConst.PARAM_FILENAME, new StringBody(filename));
                entity.addPart(ReqConst.PARAM_FILE, new FileBody(sourceFile));
                totalSize = entity.getContentLength();
                httppost.setEntity(entity);
                HttpResponse response = httpclient.execute(httppost);
                HttpEntity r_entity = response.getEntity();
                responseString = EntityUtils.toString(r_entity);

            } catch (ClientProtocolException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }

            return responseString;

        }

        @Override
        protected void onPostExecute(String result) {

            try {

                JSONObject response = new JSONObject(result);

                int resultCode = response.getInt(ReqConst.RES_CODE);

                if (resultCode == ReqConst.CODE_SUCCESS) {

                    _chatItem.set_status(GroupChatItem.StatusType.NORMAL);

                    String file = response.getString(ReqConst.RES_FILE_URL);

                    Log.d("send_image", "filename = " + file);

                    String filename = response.getString(ReqConst.RES_FILENAME);
                    _chattingAdapter.setFileUrl(_chatItem, file);
                    onSuccessUpload(file, filename, _chatItem);

                } else {
                    _chattingAdapter._chatList.remove(_chatItem);
                    onFailUpload();
                }

            } catch (Exception ex) {
                _chattingAdapter._chatList.remove(_chatItem);
                onFailUpload();
            }

            _chattingAdapter.notifyDataSetChanged();

            super.onPostExecute(result);

        }

    }


}
