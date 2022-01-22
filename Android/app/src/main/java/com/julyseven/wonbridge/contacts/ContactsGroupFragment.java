package com.julyseven.wonbridge.contacts;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ListView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.ContactsGroupAdapter;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.message.MsgActivity;
import com.julyseven.wonbridge.message.SelectFriendActivity;
import com.julyseven.wonbridge.model.GroupEntity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ContactsGroupFragment extends BaseFragment implements View.OnClickListener{

    CommonActivity _context;

    ListView ui_lstContacts;
    ContactsGroupAdapter _adapter = null;

    private ArrayList<GroupEntity> _allGroupDatas = new ArrayList<>();

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        this._context = (CommonActivity) getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_contacts_group, container, false);

        ui_lstContacts = (ListView) view.findViewById(R.id.lst_contacts_group);
        _adapter = new ContactsGroupAdapter(_context, this);
        _adapter.set_isSearch(false);
        ui_lstContacts.setAdapter(_adapter);

        ImageButton imvAddGroup = (ImageButton) view.findViewById(R.id.imv_add_group);
        imvAddGroup.setOnClickListener(this);

        return view;
    }

    public void setGroups() {

        _allGroupDatas.clear();
        _allGroupDatas.addAll(Commons.g_user.get_groupList());

        _adapter.setContactData(_allGroupDatas);
    }

    public void loadGroupFromServer() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETALLGROUP;
        String params = String.format("/%d", Commons.g_user.get_idx());

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseRoomListResponse(json);
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


    public void parseRoomListResponse(String json) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                Commons.g_user.get_groupList().clear();

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

                setGroups();
            }

        }catch (JSONException e){
            e.printStackTrace();
        }

    }


    public void gotoSelect() {

        startActivity(new Intent(_context, SelectFriendActivity.class));
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {

            case R.id.imv_add_group:

                gotoSelect();
                break;
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        loadGroupFromServer();
    }
}
