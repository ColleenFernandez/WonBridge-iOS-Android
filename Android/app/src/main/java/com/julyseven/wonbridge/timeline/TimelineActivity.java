package com.julyseven.wonbridge.timeline;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.ImageView;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.base.CommonTabActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;


public class TimelineActivity extends CommonTabActivity implements View.OnClickListener {

    TabLayout ui_tabLayout;
    ViewPager ui_viewPager;

    ArrayList<FriendEntity> _nearbyUsers = new ArrayList<>();

    TimelineFragment _timelineFragment;
    TimelineUserFragment _usergridFragment;
    TimelineGroupFragment _groupFragment;

    int _pageIndex = 0;

    public boolean _isFromAll = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_timeline);

        loadLayout();
    }

    @Override
    public void loadLayout() {

        super.loadLayout();

        ui_lytTimeLine.setBackgroundColor(0xff23262b);
        ui_txvTimeLine.setTextColor(getResources().getColor(R.color.colorWhiteBlue));
        ui_imvTimeLine.setImageResource(R.drawable.button_nearby_on);

        setUnRead();

        ImageView imvSetting = (ImageView) findViewById(R.id.imv_setting);
        imvSetting.setOnClickListener(this);

        ui_viewPager = (ViewPager)findViewById(R.id.viewpager);
        setupViewPager(ui_viewPager);

        ui_tabLayout = (TabLayout)findViewById(R.id.tabs);
        ui_tabLayout.setupWithViewPager(ui_viewPager);

    }


    private void setupViewPager(ViewPager viewPager){

        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());

        _timelineFragment = new TimelineFragment();
        _usergridFragment = new TimelineUserFragment();
        _groupFragment = new TimelineGroupFragment();

        adapter.addFrag(_timelineFragment, getString(R.string.timeline));
        adapter.addFrag(_usergridFragment, getString(R.string.user));
        adapter.addFrag(_groupFragment, getString(R.string.group));
        viewPager.setAdapter(adapter);
    }

    public void getNearbyUsers(final boolean isRefresh) {

        float lat = Preference.getInstance().getValue(this, Constants.KEY_LATITUDE, 0.0f);
        float lng = Preference.getInstance().getValue(this, Constants.KEY_LONGITUDE, 0.0f);

        if (isRefresh)
            _pageIndex = 1;
        else
            _pageIndex++;

        int distance = Preference.getInstance().getValue(this, PrefConst.PREFKEY_DISTANCE, 10);
        int ageStart = Preference.getInstance().getValue(this, PrefConst.PREFKEY_AGE_START, 1);
        int ageEnd = Preference.getInstance().getValue(this, PrefConst.PREFKEY_AGE_END, 100);

        int sex = Preference.getInstance().getValue(this, PrefConst.PREFKEY_SEX, 2);
        int lastLogin = Preference.getInstance().getValue(this, PrefConst.PREFKEY_LASTLOGIN, 7);
        int relation = Preference.getInstance().getValue(this, PrefConst.PREFKEY_RELATION, 0);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETNEARBYUSER;

        String params = String.format("/%d/%s/%s/%d/%d/%d/%d/%d/%d/%d", Commons.g_user.get_idx(), lat, lng, distance, ageStart, ageEnd, sex, lastLogin, relation, _pageIndex);

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseNearbyUsersResponse(json, isRefresh);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                error.printStackTrace();
                _usergridFragment.ui_refreshLayout.setRefreshing(false);
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseNearbyUsersResponse(String json, boolean isRefresh) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (isRefresh)
                _nearbyUsers.clear();

            _usergridFragment.ui_refreshLayout.setRefreshing(false);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray friends = response.getJSONArray(ReqConst.RES_USERINFOS);

                for (int i = 0; i < friends.length(); i++) {

                    JSONObject friend = (JSONObject) friends.get(i);

                    FriendEntity entity = new FriendEntity();
                    entity.set_idx(friend.getInt(ReqConst.RES_ID));
                    entity.set_name(friend.getString(ReqConst.RES_NAME));
                    entity.set_photoUrl(friend.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_sex(friend.getInt(ReqConst.RES_SEX));
                    entity.set_latitude((float) friend.getDouble(ReqConst.RES_LATITUDE));
                    entity.set_longitude((float) friend.getDouble(ReqConst.RES_LONGITUDE));
                    entity.set_lastLogin(friend.getString(ReqConst.RES_LASTLOGIN));
                    entity.set_isFriend(friend.getInt(ReqConst.RES_ISFRIEND) == 1);
                    entity.set_isPublic(friend.getInt(ReqConst.RES_ISPUBLICLOCATION) == 1);
                    entity.set_country(friend.getString(ReqConst.RES_COUNTRY));
                    entity.set_country2(friend.getString(ReqConst.RES_COUNTRY2));

                    _nearbyUsers.add(entity);
                }

            }

            _timelineFragment.refresh();
            _usergridFragment.refresh();

        }catch (JSONException e){
            e.printStackTrace();
        }
    }


    public void enableSwipeRefresh(boolean enable) {

        if (_timelineFragment != null)
            _timelineFragment.enableSwipyRefresh(enable);
    }



    private void gotoFilter() {

        Intent intent = new Intent(this, FilterActivity.class);
        startActivity(intent);
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == Constants.PICK_FROM_ALLTEXT) {
            _isFromAll = true;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (!_isFromAll)
            getNearbyUsers(true);

    }

    @Override
    public void onClick(View view) {

        switch (view.getId()){

            case R.id.lyt_msg:
                gotoMessage();
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

            case R.id.imv_setting:
                gotoFilter();
                break;
        }

    }


    class ViewPagerAdapter extends FragmentPagerAdapter {

        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
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

        public void addFrag(Fragment fragment, String title) {

            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {

            // return null to display only the icon
            return mFragmentTitleList.get(position);
        }
    }


}
