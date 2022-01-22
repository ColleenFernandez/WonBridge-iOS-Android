package com.julyseven.wonbridge.timeline;


import android.app.Dialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.Chatting.ConnectionMgrService;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.ContactsGroupAdapter;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.GroupEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;

import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smack.chat.Chat;
import org.jivesoftware.smack.chat.ChatManager;
import org.jivesoftware.smack.packet.Message;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by sss on 8/22/2016.
 */
public class TimelineGroupFragment extends BaseFragment implements View.OnClickListener {

    TimelineActivity _context;
    private ListView ui_lstGroup;

    EditText ui_edtSearch;

    View view;
    private ContactsGroupAdapter _adapter;
    private ArrayList<GroupEntity> _allGroupDatas = new ArrayList<>();
    private ArrayList<GroupEntity> _groupDatas = new ArrayList<>();

    SwipyRefreshLayout ui_refreshLayout;
    int _pageIndex = 0;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        _context = (TimelineActivity) getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        if (view != null) {
            ViewGroup parent = (ViewGroup) view.getParent();
            if (parent != null)
                parent.removeView(view);
        }

        try {
            view = inflater.inflate(R.layout.fragment_timelinegroup, container, false);
        } catch (Exception ex) {

        }

        loadLayout();

        return view;
    }

    public void loadLayout() {

        ui_lstGroup = (ListView)view.findViewById(R.id.lst_group);

        ui_refreshLayout = (SwipyRefreshLayout) view.findViewById(R.id.refresh);
        ui_refreshLayout.setOnRefreshListener(new SwipyRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh(SwipyRefreshLayoutDirection direction) {
                if (direction == SwipyRefreshLayoutDirection.TOP) {
                    getNearbyGroup(true);
                } else if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
                    getNearbyGroup(false);
                }
            }
        });

        _adapter = new ContactsGroupAdapter(_context, this);
        _adapter.set_isSearch(true);
        ui_lstGroup.setAdapter(_adapter);

        ImageView imvSearch = (ImageView) view.findViewById(R.id.imv_search);
        imvSearch.setOnClickListener(this);

        ui_edtSearch = (EditText) view.findViewById(R.id.edt_search);
        ui_edtSearch.addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                                      int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() == 0)
                    setAllGroups();
            }
        });

        ui_edtSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    searchGroup();
                    return true;
                }
                return false;
            }
        });

    }

    public void getNearbyGroup(final boolean isRefresh) {

        if (isRefresh)
            _pageIndex = 1;
        else
            _pageIndex++;

        float lat = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
        float lng = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

        int distance = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_DISTANCE, 10);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETNEARBYGROUP ;

        String params = String.format("/%d/%s/%s/%d/%d", Commons.g_user.get_idx(), lat, lng, distance, _pageIndex);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseGroupResponse(json, isRefresh);

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

    public void parseGroupResponse(String json, boolean isRefresh){

        try{

            if (isRefresh) {
                _allGroupDatas.clear();
            }
            ui_refreshLayout.setRefreshing(false);

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
                    entity.set_isRequested(group.getInt(ReqConst.RES_ISREQUEST) == 1);

                    JSONArray jsonUrls = group.getJSONArray(ReqConst.RES_GROUPURLS);
                    for (int j = 0 ; j < jsonUrls.length(); j++) {
                        entity.get_profileUrls().add((jsonUrls.getString(j)));
                    }

                    _allGroupDatas.add(entity);
                }

                _groupDatas.clear();
                _groupDatas.addAll(_allGroupDatas);
                _adapter.setContactData(_groupDatas);
            }

        }catch (JSONException e){
            e.printStackTrace();
        }

    }

    public void setAllGroups() {

        _groupDatas.clear();
        _groupDatas.addAll(_allGroupDatas);
        _adapter.setContactData(_groupDatas);
    }

    public void searchGroup() {

        String name = ui_edtSearch.getText().toString();

        if (name == null || name.length() == 0) {
            setAllGroups();
            return;
        }

        hideKeyboard();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SEARCHGROUP;

        String paramname = name.toString().replace(" ", "%20");
        paramname = paramname.replace("/", Constants.SLASH);

        try {
            paramname = URLEncoder.encode(paramname, "utf-8");
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String params = String.format("/%s", paramname);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {
                parseSearchResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                _context.showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseSearchResponse(String json){

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            _groupDatas.clear();

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
                    entity.set_regDate(group.getString(ReqConst.RES_REGDATE));
                    entity.set_country(group.getString(ReqConst.RES_COUNTRY));
                    entity.set_isRequested(group.getInt(ReqConst.RES_ISREQUEST) == 1);

                    JSONArray jsonUrls = group.getJSONArray(ReqConst.RES_GROUPURLS);
                    for (int j = 0 ; j < jsonUrls.length(); j++) {
                        entity.get_profileUrls().add((jsonUrls.getString(j)));
                    }

                    _groupDatas.add(entity);
                }

            }

            _adapter.setContactData(_groupDatas);

        } catch (JSONException e){
            e.printStackTrace();
            _context.showAlertDialog(getString(R.string.error));
        }

    }


    public void showRequestGroupDiag(final GroupEntity groupEntity) {

        if (groupEntity.is_isRequested())
            return;

        final int MAX_CHARS = 100;

        LayoutInflater inflater = _context.getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag_reuest_group, null);

        final Dialog dialog = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        dialog.setContentView(dialoglayout);

        TextView txvGroupname = (TextView) dialoglayout.findViewById(R.id.txv_groupname);
        txvGroupname.setText(_context.getString(R.string.group_name) + " : " + groupEntity.get_groupNickname());

        final TextView txvLeaveChars = (TextView) dialoglayout.findViewById(R.id.txv_leaveChars);

        final EditText edtInput = (EditText) dialoglayout.findViewById(R.id.edt_content);

        edtInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                txvLeaveChars.setText(String.valueOf(MAX_CHARS - s.length()));
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        final TextView txvSend = (TextView) dialoglayout.findViewById(R.id.txv_send);
        txvSend.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                dialog.dismiss();
                sendGroupRequestMessage(groupEntity);
                sendGroupRequest(groupEntity, edtInput.getText().toString());
            }
        });

        TextView txvCancel = (TextView) dialoglayout.findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                dialog.dismiss();
            }
        });

        dialog.show();
    }

    public void sendGroupRequestMessage(GroupEntity groupEntity) {

        String roomInfo = Constants.KEY_ROOM_MARKER + groupEntity.get_groupName() + ":" + groupEntity.get_participants() + ":" + Commons.g_user.get_name() + Constants.KEY_SEPERATOR;
        String requestMessage = Commons.g_user.get_name() + "$" + groupEntity.get_groupName() + "$" + Constants.KEY_REQUEST_MARKER;
        String fullMessage = roomInfo + Constants.KEY_SYSTEM_MARKER + requestMessage + Constants.KEY_SEPERATOR + Commons.getCurrentUTCTimeString();

        String address = Commons.idxToAddr(groupEntity.get_ownerIdx());

        ChatManager chatManager = ChatManager.getInstanceFor(ConnectionMgrService.mConnection);
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

    public void sendGroupRequest(final GroupEntity groupEntity, final String content) {

        _context.showProgress();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GROUPREQUEST;

        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                parseGroupResponse(response, groupEntity);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                _context.closeProgress();
                _context.showAlertDialog(_context.getString(R.string.error));
            }
        }){
            @Override
            protected Map<String,String> getParams(){
                Map<String,String> params = new HashMap<>();
                params.put(ReqConst.PARAM_ID, String.valueOf(Commons.g_user.get_idx()));
                try {

                    String message = content;
                    if (message.length() == 0)
                        message = _context.getString(R.string.default_request_group);

                    message = message.replace(" ", "%20");
                    message = URLEncoder.encode(message, "utf-8");
                    params.put(ReqConst.PARAM_CONTENT, message);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                params.put(ReqConst.PARAM_USERID, String.valueOf(Commons.g_user.get_idx()));
                params.put(ReqConst.PARAM_GROUPNAME, groupEntity.get_groupName());

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

    public void parseGroupResponse(String json, GroupEntity groupEntity){

        _context.closeProgress();

        try {

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){
                groupEntity.set_isRequested(true);
                _adapter.notifyDataSetChanged();
                showRequestCompleteDiag();
            } else {
                _context.showAlertDialog(getString(R.string.error));
            }

        } catch (JSONException e){
            e.printStackTrace();
            _context.showAlertDialog(getString(R.string.error));
        }

    }


    public void showRequestCompleteDiag() {

        LayoutInflater inflater = _context.getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.diag_delegate, null);

        final Dialog deleteDiag = new Dialog(_context, R.style.DeleteAlertDialogStyle);
        deleteDiag.setContentView(dialoglayout);

        TextView txvQuestion = (TextView) dialoglayout.findViewById(R.id.txv_question);
        txvQuestion.setText(_context.getString(R.string.note_group_request));

        TextView txvOk = (TextView) dialoglayout.findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(new View.OnClickListener() {

            public void onClick(View v) {
                deleteDiag.dismiss();
            }
        });

        deleteDiag.show();
    }


    public void hideKeyboard() {

        InputMethodManager imm = (InputMethodManager) _context.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtSearch.getWindowToken(), 0);
    }


    @Override
    public void onClick(View v) {

        switch (v.getId()) {

            case R.id.imv_search:
                searchGroup();
                break;
        }

    }

    @Override
    public void onResume() {

        getNearbyGroup(true);
        super.onResume();
    }
}
