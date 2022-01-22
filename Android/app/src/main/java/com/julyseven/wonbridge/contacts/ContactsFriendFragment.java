package com.julyseven.wonbridge.contacts;

import android.content.Context;
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
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.ContactsFriendAdapter;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

/**
 * Created by sss on 8/24/2016.
 */
public class ContactsFriendFragment extends BaseFragment implements View.OnClickListener {

    CommonActivity _context;

    RelativeLayout ui_rltSearch;
    LinearLayout ui_lytAddFriend;

    ListView ui_lstContacts;
    ContactsFriendAdapter _adapter = null;

    private ArrayList<FriendEntity> _allFriendData = new ArrayList<>();

    EditText ui_edtSearch;

    SwipyRefreshLayout ui_refreshLayout;
    int _pageIndex = 1;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        this._context = (CommonActivity) getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_contacts_friend, container, false);

        ui_rltSearch = (RelativeLayout) view.findViewById(R.id.rlt_search);
        ui_rltSearch.setVisibility(View.INVISIBLE);

        ui_lytAddFriend = (LinearLayout) view.findViewById(R.id.lyt_add_friend);
        ui_lytAddFriend.setOnClickListener(this);

        ui_lstContacts = (ListView) view.findViewById(R.id.lst_contacts_friend);
        _adapter = new ContactsFriendAdapter(_context);
        ui_lstContacts.setAdapter(_adapter);

        ui_refreshLayout = (SwipyRefreshLayout) view.findViewById(R.id.refresh);
        ui_refreshLayout.setOnRefreshListener(new SwipyRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh(SwipyRefreshLayoutDirection direction) {
                if (direction == SwipyRefreshLayoutDirection.TOP) {
                    // getFriendList(true);
                } else if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
                    getFriendList(false);
                }
            }
        });

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
                    setFriends();
            }
        });

        ui_edtSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    searchFriend();
                    return true;
                }
                return false;
            }
        });

        return view;
    }

    public void setFriends() {

        _allFriendData.clear();

        for (FriendEntity friendEntity : Commons.g_user.get_friendList()) {
            if (!Commons.g_user.isBlockUser(friendEntity))
                _allFriendData.add(friendEntity);
        }

        Collections.sort(_allFriendData, new Comparator<FriendEntity>() {
            @Override
            public int compare(FriendEntity lhs, FriendEntity rhs) {
                return lhs.get_name().compareTo(rhs.get_name());
            }
        });

        _adapter.set_isSearch(false);
        _adapter.setContactData(_allFriendData);

    }

    public void getFriendList(final boolean isRefresh) {

        if (isRefresh)
            _pageIndex = 1;
        else
            _pageIndex++;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETFRIENDLIST;

        String params = String.format("/%d/%d", Commons.g_user.get_idx(), _pageIndex);
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
                    entity.set_isFriend(true);

                    if (!Commons.g_user.get_friendList().contains(friend))
                        Commons.g_user.get_friendList().add(entity);
                }
            }


        }catch (JSONException e){
            e.printStackTrace();
        }

        setFriends();

    }


    public void searchFriend() {

        String name = ui_edtSearch.getText().toString();

        if (name == null || name.length() == 0)
            return;

        hideKeyboard();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SEARCHUSER;

        String paramname = name.toString().replace(" ", "%20");
        paramname = paramname.replace("/", Constants.SLASH);

        try {
            paramname = URLEncoder.encode(paramname, "utf-8");

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), paramname);
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

            _allFriendData.clear();

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONObject friend = response.getJSONObject(ReqConst.RES_USERINFO);

                FriendEntity entity = new FriendEntity();
                entity.set_idx(friend.getInt(ReqConst.RES_ID));
                entity.set_name(friend.getString(ReqConst.RES_NAME));
                entity.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                entity.set_isFriend(friend.getInt(ReqConst.RES_ISFRIEND) ==  1);

                _allFriendData.add(entity);

            }

            _adapter.set_isSearch(true);
            _adapter.setContactData(_allFriendData);

        } catch (JSONException e){
            e.printStackTrace();
            _context.showAlertDialog(getString(R.string.error));
        }

    }


    public void hideKeyboard() {

        InputMethodManager imm = (InputMethodManager) _context.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtSearch.getWindowToken(), 0);
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {

            case R.id.imv_search:
                searchFriend();
                break;


            case R.id.lyt_add_friend:
                ui_lytAddFriend.setVisibility(View.INVISIBLE);
                ui_rltSearch.setVisibility(View.VISIBLE);
                break;

        }

    }

    @Override
    public void onResume() {
        super.onResume();

        setFriends();
    }
}
