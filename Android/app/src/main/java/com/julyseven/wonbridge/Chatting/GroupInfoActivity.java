package com.julyseven.wonbridge.Chatting;

import android.Manifest;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.bumptech.glide.Glide;
import com.github.paolorotolo.expandableheightlistview.ExpandableHeightGridView;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.GroupMemberAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.message.SelectFriendActivity;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.utils.BitmapUtils;
import com.julyseven.wonbridge.utils.Database;
import com.julyseven.wonbridge.utils.MultiPartRequest;
import com.soundcloud.android.crop.Crop;

import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smack.chat.Chat;
import org.jivesoftware.smack.chat.ChatManager;
import org.jivesoftware.smack.packet.Message;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import static android.view.inputmethod.InputMethodManager.SHOW_FORCED;

public class GroupInfoActivity extends CommonActivity implements View.OnClickListener, AdapterView.OnItemClickListener {

    ArrayList<FriendEntity> _members = new ArrayList<>();
    ArrayList<FriendEntity> _newParticipants = new ArrayList<>();
    ArrayList<FriendEntity> _banishParticipants = new ArrayList<>();
    GroupEntity _group;
    RoomEntity _roomEntity;


    private ExpandableHeightGridView ui_gridMembers;
    GroupMemberAdapter _adapter;
    TextView ui_txvTitle, ui_txvCount, ui_txvGroupName;
    ImageView ui_imvEditProfile, ui_imvGroupProfile, ui_imvGroupTop, ui_imvGroupSound;
    LinearLayout ui_lytGroupNoti, ui_lytGroupDelegate;


    FriendEntity _plusFriend = new FriendEntity();
    FriendEntity _minusFriend = new FriendEntity();

    boolean _isGroupOwner = true;

    private Uri _imageCaptureUri;
    String _photoPath = "";


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_group_info);

        GroupEntity group = (GroupEntity) getIntent().getSerializableExtra(Constants.KEY_GROUP);

        _group = Commons.g_user.getGroup(group.get_groupName());

        if (_group == null)
            _group = group;

        _roomEntity = Commons.g_user.getRoom(_group.get_groupName());

        _members = new ArrayList<>();

        String[] leaveMemberIds = _roomEntity.get_leaveMembers().split("_");
        ArrayList<String> idList = new ArrayList<>(Arrays.asList(leaveMemberIds));

        for (FriendEntity friendEntity : _roomEntity.get_participantList()) {

            if (!idList.contains(String.valueOf(friendEntity.get_idx()))) {
                _members.add(friendEntity);
            }
        }

        _isGroupOwner = (_group.get_ownerIdx() == Commons.g_user.get_idx());

        loadLayout();
    }

    private void loadLayout() {

        ui_txvTitle = (TextView) findViewById(R.id.header_title);

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_imvEditProfile = (ImageView) findViewById(R.id.imv_edit_profile);

        ui_lytGroupNoti = (LinearLayout) findViewById(R.id.lyt_group_noti);
        ui_lytGroupNoti.setOnClickListener(this);

        ui_lytGroupDelegate = (LinearLayout) findViewById(R.id.lyt_group_delegate);
        ui_lytGroupDelegate.setOnClickListener(this);

        ui_imvGroupProfile = (ImageView) findViewById(R.id.imv_profile);
        ui_imvGroupProfile.setOnClickListener(this);
        Glide.with(_context).load(_group.get_groupProfileUrl()).placeholder(R.drawable.img_group).error(R.drawable.img_group).into(ui_imvGroupProfile);

        ui_txvGroupName = (TextView) findViewById(R.id.txv_groupname);
        ui_txvGroupName.setOnClickListener(this);

        ui_txvCount = (TextView) findViewById(R.id.txv_member_count);

        ui_imvGroupSound = (ImageView) findViewById(R.id.imv_group_sound);
        ui_imvGroupSound.setSelected(Preference.getInstance().getValue(this, PrefConst.PREFKEY_NOTISOUND + _group.get_groupName(), true));
        ui_imvGroupSound.setOnClickListener(this);

        ui_imvGroupTop = (ImageView) findViewById(R.id.imv_group_top);
        ui_imvGroupTop.setSelected(Preference.getInstance().getValue(this, PrefConst.PREFKEY_TOP + _group.get_groupName(), false));
        ui_imvGroupTop.setOnClickListener(this);

        TextView txvGroupOut = (TextView) findViewById(R.id.txv_groupout);
        txvGroupOut.setOnClickListener(this);

        ui_gridMembers = (ExpandableHeightGridView) findViewById(R.id.grd_users);
        ui_gridMembers.setExpanded(true);
        ui_gridMembers.setOnItemClickListener(this);


        _plusFriend.set_name("+");
        _members.add(_plusFriend);

        if (_isGroupOwner) {
            _minusFriend.set_name("-");
            _members.add(_minusFriend);
        }

        _adapter = new GroupMemberAdapter(this);
        ui_gridMembers.setAdapter(_adapter);

        updateUI();

    }


    public void updateUI() {

        ui_txvGroupName.setText(_group.get_groupNickname());

        if (_isGroupOwner) {
            ui_imvEditProfile.setVisibility(View.VISIBLE);
            ui_lytGroupNoti.setVisibility(View.VISIBLE);
            ui_lytGroupDelegate.setVisibility(View.VISIBLE);

        } else {
            ui_imvEditProfile.setVisibility(View.GONE);
            ui_lytGroupNoti.setVisibility(View.GONE);
            ui_lytGroupDelegate.setVisibility(View.GONE);
        }

        int memberCount = _isGroupOwner ? _members.size() - 1 : _members.size();
        ui_txvTitle.setText(getString(R.string.group_info) + String.format("(%d)", memberCount));
        ui_txvCount.setText(getString(R.string.group_member_count) + String.format("(%d)", memberCount));
        _adapter.setDatas(_members);
    }

    public void inviteUser() {

        Intent intent = new Intent(GroupInfoActivity.this, SelectFriendActivity.class);
        intent.putExtra(Constants.KEY_MEMBERS, getRealMembers());
        intent.putExtra(Constants.KEY_INVITE, true);
        startActivityForResult(intent, Constants.PICK_FROM_INVITE);

    }

    public void banishUser() {

        Intent intent = new Intent(GroupInfoActivity.this, SelectFriendActivity.class);
        intent.putExtra(Constants.KEY_MEMBERS, getRealMembers());
        intent.putExtra(Constants.KEY_INVITE, false);
        startActivityForResult(intent, Constants.PICK_FROM_BANISH);
    }


    public void onChangeProfile() {

        if (!_isGroupOwner)
            return;

        String[] PERMISSIONS = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE};

        if (Commons.hasPermissions(this, PERMISSIONS)){

            final String[] items = {getString(R.string.take_photo), getString(R.string.choose_gallery), getString(R.string.cancel)};

            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setItems(items, new DialogInterface.OnClickListener() {

                public void onClick(DialogInterface dialog, int item) {
                    if (item == 0) {
                        doTakePhoto();

                    } else if (item == 1) {
                        doTakeGallery();
                    } else {

                    }
                }
            });
            AlertDialog alert = builder.create();
            alert.show();
        }else {
            ActivityCompat.requestPermissions(this, PERMISSIONS, Constants.REQUST_PERMISSION);
        }
    }

    public void doTakePhoto(){

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

        String picturePath = BitmapUtils.getTempFolderPath() + "photo_temp.png";
        _imageCaptureUri = Uri.fromFile(new File(picturePath));

        intent.putExtra(MediaStore.EXTRA_OUTPUT, _imageCaptureUri);
        startActivityForResult(intent, Constants.PICK_FROM_CAMERA);

    }

    private void doTakeGallery(){

        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType(MediaStore.Images.Media.CONTENT_TYPE);
        startActivityForResult(intent, Constants.PICK_FROM_ALBUM);
    }



    private void beginCrop(Uri source) {
        Uri destination = Uri.fromFile(BitmapUtils.getOutputMediaFile(this));
        Crop.of(source, destination).asSquare().start(this);
    }

    /*Upload the userPhoto to server*/
    public void uploadImage() {

        showProgress();

        //if no profile photo
        if (_photoPath.length() == 0) {
            closeProgress();
            return;
        }

        try {

            File file = new File(_photoPath);

            Map<String, String> params = new HashMap<String, String>();
            params.put(ReqConst.PARAM_NAME, String.valueOf(_group.get_groupName()));

            String url = ReqConst.SERVER_URL + ReqConst.REQ_SETGROUPPROFILE;

            MultiPartRequest reqMultiPart = new MultiPartRequest(url, new Response.ErrorListener() {

                @Override
                public void onErrorResponse(VolleyError error) {

                    showToast(getString(R.string.photo_upload_fail));
                }
            }, new Response.Listener<String>() {

                @Override
                public void onResponse(String json) {

                    ParseUploadImgResponse(json);
                }
            }, file, ReqConst.PARAM_FILE, params);

            reqMultiPart.setRetryPolicy(new DefaultRetryPolicy(
                    Constants.VOLLEY_TIME_OUT, 0,
                    DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

            WonBridgeApplication.getInstance().addToRequestQueue(reqMultiPart, url);

        } catch (Exception e) {

            closeProgress();
            e.printStackTrace();
            showAlertDialog(getString(R.string.photo_upload_fail));
        }
    }

    public void ParseUploadImgResponse(String json){

        closeProgress();

        try{
            JSONObject response = new JSONObject(json);
            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == 0){
                String photoUrl = response.getString(ReqConst.RES_FILE_URL);
                _group.set_groupProfileUrl(photoUrl);
                showAlertDialog(getString(R.string.success_updated));
            }
            else {
                showAlertDialog(getString(R.string.photo_upload_fail));
            }
        }catch (JSONException e){
            e.printStackTrace();
            showAlertDialog(getString(R.string.photo_upload_fail));
        }

    }


    public void onChangeGroupName() {

        if (!_isGroupOwner)
            return;

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag_change_groupname, null);

        final Dialog confirmDlg = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        confirmDlg.setContentView(dialoglayout);
        confirmDlg.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);

        final EditText edtNickname = (EditText) dialoglayout.findViewById(R.id.edt_nickname);
        edtNickname.setText(_group.get_groupNickname());
        edtNickname.setSelection(edtNickname.getText().length());
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(edtNickname, SHOW_FORCED);

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {

                if (edtNickname.getText().length() > 0) {
                    changeNickname(edtNickname.getText().toString());
                    confirmDlg.dismiss();
                }
            }
        });

        confirmDlg.show();
    }

    public void changeNickname(final String nickname) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETGROUPNICKNAME;

        String paramname = nickname.toString().replace(" ", "%20");
        paramname = paramname.replace("/", Constants.SLASH);

        try {
            paramname = URLEncoder.encode(paramname, "utf-8");
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String params = String.format("/%s/%s", _group.get_groupName(), paramname);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseNameResponse(json, nickname);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseNameResponse(String json, String name){

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){
                _group.set_groupNickname(name);
                updateUI();
            } else {
                showAlertDialog(getString(R.string.error));
            }

        } catch (JSONException e){
            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

    }

    public void onGroupSound() {

        ui_imvGroupSound.setSelected(!ui_imvGroupSound.isSelected());
        Preference.getInstance().put(this, PrefConst.PREFKEY_NOTISOUND + _group.get_groupName(), ui_imvGroupSound.isSelected());
    }

    public void onGroupTop() {

        ui_imvGroupTop.setSelected(!ui_imvGroupTop.isSelected());
        Preference.getInstance().put(this, PrefConst.PREFKEY_TOP + _group.get_groupName(), ui_imvGroupTop.isSelected());
    }

    public void gotoGroupNoti() {

        if (!_isGroupOwner)
            return;

        Intent intent = new Intent(GroupInfoActivity.this, GroupNotiActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_GROUPNOTI);
    }

    public void gotoGroupDelegate() {

        Intent intent = new Intent(GroupInfoActivity.this, SelectFriendActivity.class);
        intent.putExtra(Constants.KEY_MEMBERS, getRealMembers());
        intent.putExtra(Constants.KEY_INVITE, false);
        intent.putExtra(Constants.KEY_DELEGATE, true);
        startActivityForResult(intent, Constants.PICK_FROM_DELEGATE);
    }

    public void showDelegateDiag() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag_delegate, null);

        final Dialog deleteDiag = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        deleteDiag.setContentView(dialoglayout);

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                deleteDiag.dismiss();
            }
        });

        deleteDiag.show();
    }

    public void showConfirmOutDiag() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag, null);

        final Dialog deleteDiag = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        deleteDiag.setContentView(dialoglayout);

        TextView txvCancel = (TextView) dialoglayout.findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                deleteDiag.dismiss();
            }
        });

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                deleteRoom(_roomEntity);
                deleteDiag.dismiss();
            }
        });

        deleteDiag.show();
    }

    public void deleteRoom(RoomEntity roomEntity) {

        // delete room from database
        Database.deleteRoom(roomEntity);
        Commons.g_user.get_roomList().remove(roomEntity);

        // delete room from server
        Commons.g_user.get_groupList().remove(_group);

        sendLeaveMessage();

        setLeaveMemeberToServer();
    }

    public void setLeaveMemeberToServer() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETGROUPPARTICIPANT;

        String params = String.format("/%s/%s", _roomEntity.get_name(), _roomEntity.makeParticipantsWithoutLeaveMemeber(false));
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseLeaveMemberResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseLeaveMemberResponse(String json){

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                Intent intent = new Intent();
                intent.putExtra(Constants.KEY_GROUPOUT, true);
                setResult(RESULT_OK, intent);
                finish();
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

    }

    public void sendLeaveMessage() {

        String statusMessage = Commons.g_user.get_name() + "$" + Constants.KEY_LEAVEROOM_MARKER;

        sendStatusMessageToRoom(statusMessage, false);
    }



    public String getRoomInfoString(RoomEntity roomEntity) {

        return Constants.KEY_ROOM_MARKER + roomEntity.get_name() + ":" + roomEntity.get_participants() + ":" + Commons.g_user.get_name() + Constants.KEY_SEPERATOR;
    }

    public void sendGroupNoti(String noti) {

        String statusMessage = Constants.KEY_GROUPNOTI_MARKER + noti;

        sendStatusMessageToRoom(statusMessage, true);
    }

    public void sendDelegateMessage(int delegaterIdx) {

        String name = "";
        for (FriendEntity friend : _roomEntity.get_participantList()) {
            if (friend.get_idx() == delegaterIdx) {
                name = friend.get_name();
            }
        }

        String statusMessage = name + "$" + _roomEntity.get_name() + "$" +
                Constants.KEY_DELEGATE_MARKER;

        sendStatusMessageToRoom(statusMessage, true);
    }


    public void setGroupOwner(int delegateIdx) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETGROUPOWNER;

        String params = String.format("/%s/%d", _roomEntity.get_name(), delegateIdx);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseOwnerResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseOwnerResponse(String json){

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){
                //_isGroupOwner = false;
                _members.remove(_members.size() - 1);
                updateUI();
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

    }


    public void sendInviteMessage(ArrayList<FriendEntity> friends) {

        String names = "";

        for (FriendEntity friend : friends) {
            names += friend.get_name() + ",";
        }
        names = names.substring(0, names.length() - 1);

        String statusMessage = names + "$" + Constants.KEY_INVITE_MARKER;

        sendStatusMessageToRoom(statusMessage, true);
    }

    public void sendBanishMessage(ArrayList<FriendEntity> banishUsers) {

        String names = "";
        String ids = "";

        for (FriendEntity friend : banishUsers) {
            names += friend.get_name() + ",";
            ids += friend.get_idx() + "_";
        }
        names = names.substring(0, names.length() - 1);
        ids = ids.substring(0, ids.length() - 1);

        String fullMessage = getRoomInfoString(_roomEntity) + Constants.KEY_SYSTEM_MARKER + names + "$" + ids + "$" + Constants.KEY_BANISH_MARKER + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();

        ChatManager chatManager = ChatManager.getInstanceFor(ConnectionMgrService.mConnection);

        ArrayList<FriendEntity> all = new ArrayList<>();
        all.addAll(_roomEntity.get_participantList());
        all.addAll(banishUsers);    // include banish users. cause participant list not include banished users.

        String[] leaveMemberIds = _roomEntity.get_leaveMembers().split("_");
        ArrayList<String> leaveIdList = new ArrayList<>(Arrays.asList(leaveMemberIds));

        for (int i = 0; i <= all.size(); i++) {

            String address = "";

            if (i < all.size()) {

                FriendEntity friendEntity = all.get(i);

                // if leave member
                if (leaveIdList.contains(String.valueOf(friendEntity.get_idx())))
                    continue;
                else
                    address = Commons.idxToAddr(friendEntity.get_idx());

            } else {  // me
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

    public void sendStatusMessageToRoom(String statusMessage, boolean toMe) {

        String fullMessage = getRoomInfoString(_roomEntity) + Constants.KEY_SYSTEM_MARKER + statusMessage + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();

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


    public ArrayList<FriendEntity> getRealMembers() {

        // remove +, -
        ArrayList<FriendEntity> members = new ArrayList<>();
        members.addAll(_members);

        if (_isGroupOwner)
            members.remove(members.size() - 1);   // -

        members.remove(members.size() - 1);   // +

        return members;
    }

    public void setParticipantToServer() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETGROUPPARTICIPANT;

        String params = String.format("/%s/%s", _roomEntity.get_name(), _roomEntity.makeParticipantsWithoutLeaveMemeber(true));
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseParticipantResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseParticipantResponse(String json){

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                _group.get_profileUrls().clear();

                JSONArray jsonUrls = response.getJSONArray(ReqConst.RES_GROUPURLS);
                for (int j = 0 ; j < jsonUrls.length(); j++) {
                    _group.get_profileUrls().add((jsonUrls.getString(j)));
                }
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

    }

    private void onBack() {

        if (_newParticipants.size() > 0 || _banishParticipants.size() > 0) {

            Intent intent = new Intent();
            intent.putExtra(Constants.KEY_NEWPARTICIPANTS, _newParticipants);
            intent.putExtra(Constants.KEY_BANISHPARTICIPANTS, _banishParticipants);
            setResult(RESULT_OK, intent);
        }

        finish();
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode){

            case Constants.PICK_FROM_INVITE: {

                if (resultCode == RESULT_OK) {

                    _newParticipants = (ArrayList<FriendEntity>) data.getSerializableExtra(Constants.KEY_NEWPARTICIPANTS);

                    if (_newParticipants.size() > 0) {

                        for (FriendEntity newFriend : _newParticipants) {

                            if (!_roomEntity.get_participantList().contains(newFriend)) {
                                _roomEntity.get_participantList().add(newFriend);
                            } else {

                                String[] ids = _roomEntity.get_leaveMembers().split("_");
                                ArrayList<String> stringList = new ArrayList<>(Arrays.asList(ids));

                                // if invite leave member
                                if (stringList.contains(String.valueOf(newFriend.get_idx()))) {

                                    stringList.remove(String.valueOf(newFriend.get_idx()));

                                    String leaveMembers = "";
                                    for (String id : stringList) {
                                        leaveMembers += id + "_";
                                    }

                                    if (leaveMembers.length() > 0) {
                                        leaveMembers = leaveMembers.substring(0, leaveMembers.length() - 1);
                                    }

                                    _roomEntity.set_leaveMembers(leaveMembers);

                                }
                            }
                        }

                        _roomEntity.set_participants(_roomEntity.makeParticipantsWithoutLeaveMemeber(true));
                        Database.updateRoom(_roomEntity);

                        setParticipantToServer();

                        if (_isGroupOwner)
                            _members.remove(_members.size() - 1);   // -

                        _members.remove(_members.size() - 1);   // +

                        _members.addAll(_newParticipants);
                        _members.add(_plusFriend);

                        if (_isGroupOwner)
                            _members.add(_minusFriend);

                        updateUI();

                        sendInviteMessage(_newParticipants);

                    }
                }
            }
            break;

            case Constants.PICK_FROM_BANISH:

                if (resultCode == RESULT_OK) {

                    _banishParticipants = (ArrayList<FriendEntity>) data.getSerializableExtra(Constants.KEY_BANISHPARTICIPANTS);

                    for (FriendEntity banishFriend : _banishParticipants) {
                        if (_roomEntity.get_participantList().contains(banishFriend))
                            _roomEntity.get_participantList().remove(banishFriend);
                    }

                    _roomEntity.set_participants(_roomEntity.makeParticipantsWithoutLeaveMemeber(true));
                    Database.updateRoom(_roomEntity);

                    setParticipantToServer();

                    if (_isGroupOwner)
                        _members.remove(_members.size() - 1);   // -

                    _members.remove(_members.size() - 1);   // +
                    _members.removeAll(_banishParticipants);
                    _members.add(_plusFriend);

                    if (_isGroupOwner)
                        _members.add(_minusFriend);

                    updateUI();

                    sendBanishMessage(_banishParticipants);

                }

                break;


            case Constants.PICK_FROM_DELEGATE:

                if (resultCode == RESULT_OK) {

                    int delegateIdx = data.getIntExtra(Constants.KEY_DELEGATEIDX, -1);

                    if (delegateIdx != -1) {
                        sendDelegateMessage(delegateIdx);
                        setGroupOwner(delegateIdx);
                        //_group.set_ownerIdx(delegateIdx);

                    }
                }
                break;

            case Constants.PICK_FROM_GROUPNOTI:

                if (resultCode == RESULT_OK) {

                    String noti = data.getStringExtra(Constants.KEY_GROUPNOTI);

                    if (noti != null)
                        sendGroupNoti(noti);
                }

                break;

            case Crop.REQUEST_CROP: {

                if (resultCode == RESULT_OK){
                    try {

                        File outFile = BitmapUtils.getOutputMediaFile(this);

                        InputStream in = getContentResolver().openInputStream(Uri.fromFile(outFile));
                        BitmapFactory.Options bitOpt = new BitmapFactory.Options();
                        Bitmap bitmap = BitmapFactory.decodeStream(in, null, bitOpt);
                        in.close();

                        ExifInterface ei = new ExifInterface(outFile.getAbsolutePath());
                        int orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                                ExifInterface.ORIENTATION_NORMAL);

                        Bitmap returnedBitmap = bitmap;

                        switch (orientation) {

                            case ExifInterface.ORIENTATION_ROTATE_90:
                                returnedBitmap = BitmapUtils.rotateImage(bitmap, 90);
                                // Free up the memory
                                bitmap.recycle();
                                bitmap = null;
                                break;
                            case ExifInterface.ORIENTATION_ROTATE_180:
                                returnedBitmap = BitmapUtils.rotateImage(bitmap, 180);
                                // Free up the memory
                                bitmap.recycle();
                                bitmap = null;
                                break;
                            case ExifInterface.ORIENTATION_ROTATE_270:
                                returnedBitmap = BitmapUtils.rotateImage(bitmap, 270);
                                // Free up the memory
                                bitmap.recycle();
                                bitmap = null;
                                break;

                            default:
                                returnedBitmap = bitmap;
                        }

                        Bitmap w_bmpSizeLimited = Bitmap.createScaledBitmap(returnedBitmap, Constants.PROFILE_IMAGE_SIZE, Constants.PROFILE_IMAGE_SIZE, true);

                        BitmapUtils.saveOutput(outFile, w_bmpSizeLimited);

                        //set The bitmap data to image View
                        ui_imvGroupProfile.setImageBitmap(w_bmpSizeLimited);
                        _photoPath = outFile.getAbsolutePath();

                        uploadImage();

                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                break;
            }
            case Constants.PICK_FROM_ALBUM:

                if (resultCode == RESULT_OK){
                    _imageCaptureUri = data.getData();
                }

            case Constants.PICK_FROM_CAMERA:
            {
                if (resultCode == RESULT_OK) {
                    try {

                        _photoPath = BitmapUtils.getRealPathFromURI(this, _imageCaptureUri);
                        beginCrop(_imageCaptureUri);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                break;
            }
        }


    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

        if (_isGroupOwner) {

            if (position == _members.size() - 2) { // +
                inviteUser();
            } else if (position == _members.size() - 1) { // -
                banishUser();
            }
        } else {

            if (position == _members.size() - 1) {  // +
                inviteUser();
            }
        }
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;

            case R.id.imv_profile:
                onChangeProfile();
                break;

            case R.id.txv_groupname:
                onChangeGroupName();
                break;

            case R.id.imv_group_sound:
                onGroupSound();
                break;

            case R.id.imv_group_top:
                onGroupTop();
                break;

            case R.id.lyt_group_noti:
                gotoGroupNoti();
                break;

            case R.id.lyt_group_delegate:
                gotoGroupDelegate();
                break;

            case R.id.txv_groupout:

                _isGroupOwner = (_group.get_ownerIdx() == Commons.g_user.get_idx());

                if (_isGroupOwner) {
                    showDelegateDiag();
                } else {
                    showConfirmOutDiag();
                }

                break;

        }

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            onBack();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

}
