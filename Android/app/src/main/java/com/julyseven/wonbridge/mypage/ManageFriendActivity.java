package com.julyseven.wonbridge.mypage;

import android.os.Bundle;
import android.view.View;
import android.widget.GridView;
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
import com.julyseven.wonbridge.adapter.FriendSelectAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.utils.Database;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class ManageFriendActivity extends CommonActivity implements View.OnClickListener{

    private TextView ui_txvConfirm;
    private ImageView ui_imvBack;
    private GridView ui_gridFriends;

    LinearLayout ui_lytNoFriend, ui_lytFriends;

    private FriendSelectAdapter _adapter;

    private UserEntity _user;

    private int _selectedFriendsCounter = 0;

    private ArrayList<FriendEntity> _blockUserData = new ArrayList<>();
    private ArrayList<FriendEntity> _selectedUserData = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_manage_friend);

        _user = Commons.g_user;

        loadLayout();
    }
    private void loadLayout(){

        ui_txvConfirm = (TextView)findViewById(R.id.txv_confirm);
        ui_txvConfirm.setOnClickListener(this);
        ui_gridFriends = (GridView)findViewById(R.id.grid_friend_select);

        ui_lytFriends = (LinearLayout) findViewById(R.id.lyt_friends);
        ui_lytNoFriend = (LinearLayout) findViewById(R.id.lyt_nofriend);

        initBlockUsers();

        _adapter = new FriendSelectAdapter(this);
        ui_gridFriends.setAdapter(_adapter);
        _adapter.setUsers(_blockUserData);

        ui_imvBack = (ImageView)findViewById(R.id.imv_back);
        ui_imvBack.setOnClickListener(this);

    }

    public void initBlockUsers() {

        _blockUserData.clear();

        for (FriendEntity friend : Commons.g_user.get_blockList()) {
            friend.set_isSelected(false);
            _blockUserData.add(friend);
        }

        if (_blockUserData.size() == 0) {
            ui_lytNoFriend.setVisibility(View.VISIBLE);
            ui_lytFriends.setVisibility(View.INVISIBLE);
            ui_txvConfirm.setVisibility(View.INVISIBLE);
        } else {
            ui_lytNoFriend.setVisibility(View.INVISIBLE);
            ui_lytFriends.setVisibility(View.VISIBLE);
            ui_txvConfirm.setVisibility(View.VISIBLE);
        }

        _selectedFriendsCounter = 0;
        ui_txvConfirm.setText(getString(R.string.unblock_friend));
    }

    public void plusFriend() {

        _selectedFriendsCounter++;
        ui_txvConfirm.setText(getString(R.string.unblock_friend) + "(" + _selectedFriendsCounter + ")");
    }

    public void minusFriend() {

        _selectedFriendsCounter--;
        if(_selectedFriendsCounter <= 0) {
            _selectedFriendsCounter = 0;
            ui_txvConfirm.setText(getString(R.string.unblock_friend));
        } else {
            ui_txvConfirm.setText(getString(R.string.unblock_friend) + "(" + _selectedFriendsCounter + ")");
        }

    }

    public void unblockUsers() {

        _selectedUserData.clear();

        for (FriendEntity friendEntity : _blockUserData) {

            if (friendEntity.is_isSelected()) {
                _selectedUserData.add(friendEntity);
            }
        }

        if (_selectedUserData.size() == 0)
            return;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_BLOCKFRIENDLIST;

        StringRequest stringRequest = new StringRequest(Request.Method.POST, url , new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseUnblockUserResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                showAlertDialog(getString(R.string.error));
            }
        }) {
            @Override
            protected Map<String, String> getParams() {

                Map<String, String> params = new HashMap<>();

                try {
                    params.put(ReqConst.PARAM_ID, String.valueOf(_user.get_idx()));

                    JSONArray friendIds = new JSONArray();

                    for (FriendEntity friendEntity : _selectedUserData) {
                        friendIds.put(String.valueOf(friendEntity.get_idx()));
                    }

                    params.put(ReqConst.PARAM_FRIENDLIST, friendIds.toString());

                } catch (Exception e) {
                }

                return params;
            }
        };

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseUnblockUserResponse(String json) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                for (FriendEntity friendEntity : _selectedUserData) {

                    Database.deleteBlock(friendEntity.get_idx());
                    _user.get_blockList().remove(friendEntity);
                }

                _selectedUserData.clear();
                initBlockUsers();
                _adapter.setUsers(_blockUserData);
            }

        } catch (JSONException e){
            e.printStackTrace();
        }

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){

            case R.id.imv_back:
                finish();
                break;
            case R.id.txv_confirm:
                unblockUsers();
                break;
        }
    }
}
