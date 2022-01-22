package com.julyseven.wonbridge.message;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.Chatting.GroupChatItem;
import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.FriendSelectAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.utils.Database;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.TimeZone;

public class SelectFriendActivity extends CommonActivity implements View.OnClickListener{

    private TextView ui_txvConfirm;
    private ImageView ui_imvBack;
    private GridView ui_gridFriends;

    private FriendSelectAdapter _adapter;

    private UserEntity _user;

    private int _selectedFriendsCounter = 0;

    ArrayList<FriendEntity> _members = new ArrayList<>();   // friends already chatting with

    private ArrayList<FriendEntity> _allFriendData = new ArrayList<>();
    private ArrayList<FriendEntity> _friendData = new ArrayList<>();

    SwipyRefreshLayout ui_refreshLayout;
    int _pageIndex = 1;
    boolean _isInvite = true;
    boolean _isDelegate = false;
    boolean _isFrom1_1 = false;
    FriendEntity _selectedDelegater = null;

    boolean _isMakingRoom = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_friend);

        _user = Commons.g_user;

        _members = (ArrayList<FriendEntity>) getIntent().getSerializableExtra(Constants.KEY_MEMBERS);
        _isInvite = getIntent().getBooleanExtra(Constants.KEY_INVITE, true);
        _isDelegate = getIntent().getBooleanExtra(Constants.KEY_DELEGATE, false);
        _isFrom1_1 = getIntent().getBooleanExtra(Constants.KEY_FROM_1_1, false);

        _isMakingRoom = false;

        loadLayout();
    }


    private void loadLayout(){

        ui_txvConfirm = (TextView)findViewById(R.id.txv_confirm);
        ui_txvConfirm.setOnClickListener(this);
        ui_gridFriends = (GridView)findViewById(R.id.grid_friend_select);

        ui_imvBack = (ImageView)findViewById(R.id.imv_back);
        ui_imvBack.setOnClickListener(this);

        ui_refreshLayout = (SwipyRefreshLayout) findViewById(R.id.refresh);
        ui_refreshLayout.setOnRefreshListener(new SwipyRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh(SwipyRefreshLayoutDirection direction) {
                if (direction == SwipyRefreshLayoutDirection.TOP) {
                    getFriendList(true);
                } else if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
                    getFriendList(false);
                }
            }
        });

        _adapter = new FriendSelectAdapter (this);

        if (_isDelegate)
            _adapter.set_isSelectOne(true);

        ui_gridFriends.setAdapter(_adapter);

        //getFriendList(true);
        initFriends();
    }


    public void getFriendList(final boolean isRefresh) {

        if (isRefresh)
            _pageIndex = 1;
        else
            _pageIndex++;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETFRIENDLIST;

        String params = String.format("/%d/%d", _user.get_idx(), _pageIndex);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseFriendResponse(json, isRefresh);

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

    public void parseFriendResponse(String json, boolean isRefresh){

        try{

            ui_refreshLayout.setRefreshing(false);

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray friends = response.getJSONArray(ReqConst.RES_FRIENDINFOS);

                for (int i = 0; i < friends.length(); i++) {

                    JSONObject friend = (JSONObject) friends.get(i);
                    FriendEntity entity = new FriendEntity();

                    entity.set_idx(friend.getInt(ReqConst.RES_ID));
                    entity.set_name(friend.getString(ReqConst.RES_NAME));
                    entity.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_lastLogin(friend.getString(ReqConst.RES_LASTLOGIN));
                    entity.set_latitude((float)friend.getDouble(ReqConst.RES_LATITUDE));
                    entity.set_longitude((float) friend.getDouble(ReqConst.RES_LONGITUDE));
                    entity.set_sex(friend.getInt(ReqConst.RES_SEX));
                    entity.set_country(friend.getString(ReqConst.RES_COUNTRY));

                    if (!_user.get_friendList().contains(friend))
                        _user.get_friendList().add(entity);
                }
            }

            initFriends();

        }catch (JSONException e){
            e.printStackTrace();
        }

    }

    public void initFriends() {

        _friendData.clear();

        if (_isInvite) {

            for (FriendEntity friend : _user.get_friendList()) {

                if (_members != null) {
                    if (!_members.contains(friend)) {
                        _friendData.add(friend);
                    }
                } else {
                    _friendData.add(friend);
                }
            }
        } else {
            _friendData.addAll(_members);
        }

        for (FriendEntity friend : _friendData) {
            friend.set_isSelected(false);
        }

        _selectedFriendsCounter = 0;
        _adapter.setUsers(_friendData);

    }

    public void plusFriend() {

        _selectedFriendsCounter++;
        ui_txvConfirm.setText(getString(R.string.confirm) + "(" + _selectedFriendsCounter + ")");
    }

    public void minusFriend() {

        _selectedFriendsCounter--;
        if(_selectedFriendsCounter <= 0) {
            _selectedFriendsCounter = 0;
            ui_txvConfirm.setText(getString(R.string.confirm));
        } else {
            ui_txvConfirm.setText(getString(R.string.confirm) + "(" + _selectedFriendsCounter + ")");
        }

    }

    public void selectOneFriend(FriendEntity selected) {

        for (FriendEntity friendEntity : _friendData) {

            if (friendEntity.equals(selected))
                friendEntity.set_isSelected(true);
            else
                friendEntity.set_isSelected(false);
        }

        _adapter.setUsers(_friendData);
        _selectedDelegater = selected;
    }

    public void makeRoom() {

        if (_isMakingRoom) return;

        _isMakingRoom = true;

        ArrayList<FriendEntity> participantList = new ArrayList<>();

        if (_members != null)
            participantList.addAll(_members);

        ArrayList<FriendEntity> newParticipants = new ArrayList<>();

        for (FriendEntity friend : _friendData) {

            if (friend.is_isSelected()) {
                participantList.add(friend);
                newParticipants.add(friend);
            }
        }

        if (newParticipants.size() > 0) {       // exist selected user

            // +로 유저를 선택했거나, 1:1 채팅에서 왔으면 방을 새로 만든다.
            if (_members == null || _isFrom1_1) {

                RoomEntity room = new RoomEntity(participantList);

                if (!_user.get_roomList().contains(room)) {

                    if (participantList.size() == 1) {      // 1:1
                        _user.get_roomList().add(room);
                        Database.createRoom(room);
                        gotoChattingRoom(room);
                    } else {
                        uploadGroup(room);
                    }

                } else {
                    gotoChattingRoom(room);
                }
            } else { // 그룹채팅 설정에서 +로 선택한 경우 초대만 한다.

                Intent intent = new Intent();
                intent.putExtra(Constants.KEY_NEWPARTICIPANTS, newParticipants);
                setResult(RESULT_OK, intent);

                finish();
            }
        }
    }




    public void showConfirmBanishDiag() {

        ArrayList<FriendEntity> banishParticipants = new ArrayList<>();

        for (FriendEntity friend : _friendData) {

            if (friend.is_isSelected()) {
                banishParticipants.add(friend);
            }
        }

        if (banishParticipants.size() > 0) {

            LayoutInflater inflater = getLayoutInflater();
            View dialoglayout = inflater.inflate(R.layout.diag_banish, null);

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
                    banishUsers();
                    deleteDiag.dismiss();
                }
            });

            deleteDiag.show();
        }
    }

    public void banishUsers() {

        ArrayList<FriendEntity> banishParticipants = new ArrayList<>();

        for (FriendEntity friend : _friendData) {

            if (friend.is_isSelected()) {
                banishParticipants.add(friend);
            }
        }

        Intent intent = new Intent();
        intent.putExtra(Constants.KEY_BANISHPARTICIPANTS, banishParticipants);
        setResult(RESULT_OK, intent);

        finish();
    }

    public void showConfirmDelegateDiag() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag_confirm_delegate, null);

        final Dialog deleteDiag = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        deleteDiag.setContentView(dialoglayout);

        TextView txvQuestion = (TextView) dialoglayout.findViewById(R.id.txv_question);
        txvQuestion.setText(_selectedDelegater.get_name() + getString(R.string.confirm_delegate));

        TextView txvCancel = (TextView) dialoglayout.findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                deleteDiag.dismiss();
            }
        });

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {

                deleteDiag.dismiss();
                Intent intent = new Intent();
                intent.putExtra(Constants.KEY_DELEGATEIDX, _selectedDelegater.get_idx());
                setResult(RESULT_OK, intent);
                finish();
            }
        });

        deleteDiag.show();
    }

    public void uploadGroup(final RoomEntity roomEntity) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_MAKEGROUP;
        String params = String.format("/%d/%s/%s", Commons.g_user.get_idx(), roomEntity.get_name(), roomEntity.get_participants());

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseGroupResponse(json, roomEntity);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                showAlertDialog(getString(R.string.error));
                _isMakingRoom = false;
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parseGroupResponse(String json, RoomEntity roomEntity){

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){

                _user.get_roomList().add(roomEntity);

                // add invite message
                String names = "";

                for (FriendEntity friend : roomEntity.get_participantList()) {
                    names += friend.get_name() + ",";
                }
                names = names.substring(0, names.length() - 1);

                String statusMessage = names + "$" + Constants.KEY_INVITE_MARKER;

                String roomInfo = Constants.KEY_ROOM_MARKER + roomEntity.get_name() + ":" + roomEntity.get_participants() + ":" + _user.get_name() + Constants.KEY_SEPERATOR;
                String fullMessage = roomInfo + Constants.KEY_SYSTEM_MARKER + statusMessage + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();
                GroupChatItem chatItem = new GroupChatItem(_user.get_idx(), roomEntity.get_name(), fullMessage);
                Database.createMessage(chatItem);

                roomEntity.set_recentContent(statusMessage);
                roomEntity.set_recentTime(Commons.getCurrentUTCTimeString());
                Database.createRoom(roomEntity);

                GroupEntity groupEntity = new GroupEntity();
                groupEntity.set_groupName(roomEntity.get_name());
                groupEntity.set_participants(roomEntity.get_participants());
                groupEntity.set_ownerIdx(_user.get_idx());
                groupEntity.set_country(_user.get_country());

                for (FriendEntity friendEntity : roomEntity.get_participantList()) {
                    groupEntity.get_profileUrls().add(friendEntity.get_photoUrl());
                }

                if (groupEntity.get_profileUrls().size() < 4)
                    groupEntity.get_profileUrls().add(Commons.g_user.get_photoUrl());

                // yyyy-MM-dd HH:mm:ss
                TimeZone utcTimeZone = TimeZone.getTimeZone("UTC");
                Calendar now = Calendar.getInstance(utcTimeZone);

                int year = now.get(Calendar.YEAR);
                int month = now.get(Calendar.MONTH) + 1;
                int date = now.get(Calendar.DATE);

                int hour = now.get(Calendar.HOUR_OF_DAY);
                int min = now.get(Calendar.MINUTE);
                int sec = now.get(Calendar.SECOND);

                String time = String.format("%d-%02d-%02d %02d:%02d:%02d", year, month, date, hour, min, sec);

                groupEntity.set_regDate(Commons.getDisplayRegTimeString(time));
                _user.get_groupList().add(groupEntity);

                gotoChattingRoom(roomEntity);
            }else {
                showAlertDialog(getString(R.string.error));
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

        _isMakingRoom = false;

    }


    public void gotoChattingRoom(RoomEntity room) {

        if (Commons.g_chattingActivity != null) {
            Commons.g_chattingActivity.onExit();
        }

        Intent intent = new Intent(SelectFriendActivity.this, GroupChattingActivity.class);
        intent.putExtra(Constants.KEY_ROOM, room.get_name());
        startActivity(intent);
        finish();
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()){

            case R.id.imv_back:
                finish();
                break;
            case R.id.txv_confirm:

                if (_isDelegate) {

                    if (_selectedDelegater != null)
                        showConfirmDelegateDiag();
                } else {
                    if (_isInvite)
                        makeRoom();
                    else
                        showConfirmBanishDiag();
                }
                break;
        }
    }
}
