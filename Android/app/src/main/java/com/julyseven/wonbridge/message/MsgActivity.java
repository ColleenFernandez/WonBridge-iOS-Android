package com.julyseven.wonbridge.message;

import android.app.Dialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.Chatting.ConnectionMgrService;
import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.ChattingListAdapter;
import com.julyseven.wonbridge.base.CommonTabActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.model.RoomEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.utils.Database;

import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smack.chat.Chat;
import org.jivesoftware.smack.chat.ChatManager;
import org.jivesoftware.smack.packet.Message;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

public class MsgActivity extends CommonTabActivity implements View.OnClickListener {

    ListView ui_lstChatting;
    ChattingListAdapter _adapter = null;
    private ArrayList<RoomEntity> _roomDatas = new ArrayList<>();


    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_message);

        loadLayout();

        String room = getIntent().getStringExtra(Constants.KEY_ROOM);

        if (room != null) {
            Intent intent = new Intent(_context, GroupChattingActivity.class);
            intent.putExtra(Constants.KEY_ROOM, room);
            _context.startActivity(intent);
        }
    }

    @Override
    public void loadLayout(){

        super.loadLayout();

        ui_lytMsg.setBackgroundColor(0xff23262b);
        ui_txvMsg.setTextColor(getResources().getColor(R.color.colorWhiteBlue));
        ui_imvMsg.setImageResource(R.drawable.button_massage_on);

        ui_lstChatting = (ListView) findViewById(R.id.chatting_lsv);
        _adapter = new ChattingListAdapter(this);
        ui_lstChatting.setAdapter(_adapter);

        ui_lstChatting.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                RoomEntity roomEntity = _roomDatas.get(position);
                Intent intent = new Intent(_context, GroupChattingActivity.class);
                intent.putExtra(Constants.KEY_ROOM, roomEntity.get_name());
                _context.startActivity(intent);
            }
        });

        ImageButton imvButton = (ImageButton) findViewById(R.id.imv_add_chat);
        imvButton.setOnClickListener(this);

        refresh();

    }

    public void onClickRead(int pos) {

        RoomEntity roomEntity = _roomDatas.get(pos);
        roomEntity.init_recentCounter();
        Database.updateRoom(roomEntity);
        refresh();
    }

    public void onClickDelete(final int pos) {

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
                deleteRoom(pos);
                deleteDiag.dismiss();
            }
        });

        deleteDiag.show();

    }

    public void deleteRoom(int pos) {

        RoomEntity roomEntity = _roomDatas.get(pos);

        if (!roomEntity.isGroup()) {        // 1:1

            Database.deleteRoom(roomEntity);
            Commons.g_user.get_roomList().remove(roomEntity);
            refresh();

        } else {

            GroupEntity group = Commons.g_user.getGroup(roomEntity.get_name());

            // if me is group owner
            if (group != null && group.get_ownerIdx() == Commons.g_user.get_idx()) {
                showDelegateDiag();

            } else {

                // delete room from database
                Database.deleteRoom(roomEntity);
                Commons.g_user.get_roomList().remove(roomEntity);

                // delete room from server
                Commons.g_user.get_groupList().remove(Commons.g_user.getGroup(roomEntity.get_name()));

                refresh();

                sendLeaveMessage(roomEntity);
                setLeaveMemeberToServer(roomEntity);
            }
        }
    }

    public void setLeaveMemeberToServer(RoomEntity roomEntity) {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETGROUPPARTICIPANT;

        String params = String.format("/%s/%s", roomEntity.get_name(), roomEntity.makeParticipantsWithoutLeaveMemeber(false));
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

            }

        } catch (JSONException e){
            e.printStackTrace();
        }

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

    public void sendLeaveMessage(RoomEntity roomEntity) {

        ChatManager chatManager = ChatManager.getInstanceFor(ConnectionMgrService.mConnection);

        String[] leaveMemberIds = roomEntity.get_leaveMembers().split("_");
        ArrayList<String> leaveIdList = new ArrayList<>(Arrays.asList(leaveMemberIds));

        for (FriendEntity friendEntity : roomEntity.get_participantList()) {

            // if leave member
            if (leaveIdList.contains(String.valueOf(friendEntity.get_idx())))
                continue;

            String address = Commons.idxToAddr(friendEntity.get_idx());

            final Chat newChat = chatManager.createChat(address);

            final Message message = new Message();

            String fullMessage = getRoomInfoString(roomEntity) + Constants.KEY_SYSTEM_MARKER  + Commons.g_user.get_name() + "$" + Constants.KEY_LEAVEROOM_MARKER + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();
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


    public String getRoomInfoString(RoomEntity roomEntity) {

        return Constants.KEY_ROOM_MARKER + roomEntity.get_name() + ":" + roomEntity.get_participants() + ":" + Commons.g_user.get_name() + Constants.KEY_SEPERATOR;
    }

    public void refresh() {

        setUnRead();

        ArrayList<RoomEntity> allRoom = new ArrayList<>();
        allRoom.addAll(Commons.g_user.get_roomList());

        ArrayList<RoomEntity> roomEntities = new ArrayList<>();

        for (RoomEntity room : allRoom){

            if (room.get_recentContent().length() > 0){
                roomEntities.add(room);
            }
        }

        Collections.sort(roomEntities, new Comparator<RoomEntity>() {
            @Override
            public int compare(RoomEntity lhs, RoomEntity rhs) {
                return rhs.get_recentTime().compareTo(lhs.get_recentTime());
            }
        });

        ArrayList<RoomEntity> topRooms = new ArrayList<>();
        ArrayList<RoomEntity> notTopRooms = new ArrayList<>();

        // move top group to top
        for (RoomEntity roomEntity : roomEntities) {

            boolean top = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_TOP + roomEntity.get_name(), false);
            if (top) {
                topRooms.add(roomEntity);
            } else {
                notTopRooms.add(roomEntity);
            }
        }

        _roomDatas.clear();

        _roomDatas.addAll(topRooms);
        _roomDatas.addAll(notTopRooms);

        _adapter.setRoomData(_roomDatas);
    }

    public void gotoSelect() {

        startActivity(new Intent(MsgActivity.this, SelectFriendActivity.class));
    }


    @Override
    protected void onResume() {
        super.onResume();
        refresh();
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()){

            case R.id.lyt_timeline:
                gotoTimeline();
                break;

            case R.id.lyt_mypage:
                gotoMyPage();
                break;

            case R.id.lyt_contact:
                gotoContact();
                break;

            case R.id.lyt_service:
                gotoService();
                break;

            case R.id.imv_add_chat:
                gotoSelect();
                break;

        }

    }



}
