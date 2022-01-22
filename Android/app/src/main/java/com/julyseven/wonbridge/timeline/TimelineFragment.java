package com.julyseven.wonbridge.timeline;


import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Typeface;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.baidu.location.BDLocation;
import com.baidu.location.BDLocationListener;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.InfoWindow;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.MyLocationConfiguration;
import com.baidu.mapapi.map.MyLocationData;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.model.LatLng;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.gun0912.tedpermission.PermissionListener;
import com.gun0912.tedpermission.TedPermission;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.TimelineAdapter;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.model.RespondEntity;
import com.julyseven.wonbridge.model.TimelineEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.utils.CustomSupportMapFragment;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import static com.julyseven.wonbridge.R.id;
import static com.julyseven.wonbridge.R.layout;

/**
 * Created by sss on 8/22/2016.
 */
public class TimelineFragment extends BaseFragment implements View.OnClickListener, OnMapReadyCallback {

    TimelineActivity _context;
    private ListView ui_lstTimeLine;
    TextView ui_txvRadius, ui_txvFriendCount;

    View view;
    private TimelineAdapter _adapter;
    private ArrayList<TimelineEntity> _timelineData = new ArrayList<>();

    LocationClient mLocClient;
    public MyLocationListenner myListener = new MyLocationListenner();
    private MyLocationConfiguration.LocationMode mCurrentMode;

    FrameLayout ui_fltBaiduMap;
    MapView mBaiduMapView;
    BaiduMap mBaiduMap;

    FrameLayout ui_fltGoogleMap;
    CustomSupportMapFragment ui_googleMapFragment;
    GoogleMap mGoogleMap;

    LocationManager _locationManager;

    InfoWindow _baiduInfoWindow = null;
    com.google.android.gms.maps.model.Marker _googleInfoWindow = null;

    SwipyRefreshLayout ui_refreshLayout;
    int _pageIndex = 0;

    View ui_headerview;


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
            view = inflater.inflate(layout.fragment_timeline, container, false);
            ui_headerview = LayoutInflater.from(_context).inflate(layout.timeline_header, null, false);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        loadLayout();

        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        if (!Commons.g_isChina) {
            FragmentManager fm = getChildFragmentManager();
            ui_googleMapFragment = (CustomSupportMapFragment) fm.findFragmentById(R.id.googlemap);

            if (ui_googleMapFragment == null) {
                ui_googleMapFragment = CustomSupportMapFragment.newInstance();
                fm.beginTransaction().replace(R.id.googlemap, ui_googleMapFragment).commit();
            }
        }
    }

    @Override
    public void onResume() {
        super.onResume();

        if (!_context._isFromAll)
            getNearbyTimeline(true);

        _context._isFromAll = false;

        if (Commons.g_isChina) {
            mBaiduMapView.onResume();

        } else {
            if (mGoogleMap == null) {

                mGoogleMap = ui_googleMapFragment.getMap();
                ui_googleMapFragment.getMapAsync(this);

                mGoogleMap.setInfoWindowAdapter(new MyInfoWindowAdapter());

                mGoogleMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
                    @Override
                    public boolean onMarkerClick(com.google.android.gms.maps.model.Marker marker) {

                        if (marker.getTitle() == null)
                            return true;

                        try {
                            int sex = Integer.valueOf(marker.getTitle().split(":")[1]).intValue();

                            if (sex != 2) // if public
                                showGoogleTooltip(marker);

                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }

                        return true;
                    }
                });

                mGoogleMap.setOnInfoWindowClickListener(new GoogleMap.OnInfoWindowClickListener() {
                    @Override
                    public void onInfoWindowClick(com.google.android.gms.maps.model.Marker marker) {

                        int user_id = Integer.valueOf(marker.getTitle().split(":")[0]).intValue();

                        for (final FriendEntity friendEntity : _context._nearbyUsers) {
                            if (friendEntity.get_idx() == user_id) {
                                gotoUserProfile(friendEntity);
                                return;
                            }
                        }
                    }
                });

                if (ContextCompat.checkSelfPermission(_context, Manifest.permission.ACCESS_FINE_LOCATION)
                        == PackageManager.PERMISSION_GRANTED || ContextCompat.checkSelfPermission(_context, android.Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED)
                    mGoogleMap.setMyLocationEnabled(true);
            }
        }

        String[] PERMISSIONS = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.READ_PHONE_STATE};

        if (Commons.hasPermissions(_context, PERMISSIONS)){
            startTracking();

        } else {
            new TedPermission(_context)
                    .setPermissionListener(permissionlistener)
                    .setDeniedMessage("If you reject permission,you can not use this service\n\nPlease turn on permissions at [Setting] > [Permission]")
                    .setPermissions(PERMISSIONS)
                    .check();
        }
    }

    private void loadLayout() {

        ImageButton imvAddTimeline = (ImageButton) view.findViewById(id.imv_add_timeline);
        imvAddTimeline.setOnClickListener(this);

        ImageView imvScaleGoogleMap = (ImageView) ui_headerview.findViewById(id.imv_scale_googlemap);
        imvScaleGoogleMap.setOnClickListener(this);

        ImageView imvScaleBaiduMap = (ImageView) ui_headerview.findViewById(id.imv_scale_baidumap);
        imvScaleBaiduMap.setOnClickListener(this);

        ImageView imvSetLocation = (ImageView) ui_headerview.findViewById(id.imv_set_location);
        imvSetLocation.setOnClickListener(this);

        ui_txvRadius = (TextView) ui_headerview.findViewById(id.txv_radius);
        ui_txvFriendCount = (TextView) ui_headerview.findViewById(id.txv_friend_count);

        ui_lstTimeLine = (ListView) view.findViewById(id.lst_timeline);

        ui_refreshLayout = (SwipyRefreshLayout) view.findViewById(id.refresh);
        ui_refreshLayout.setOnRefreshListener(new SwipyRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh(SwipyRefreshLayoutDirection direction) {
                if (direction == SwipyRefreshLayoutDirection.TOP) {
                    getNearbyTimeline(true);
                } else if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
                    getNearbyTimeline(false);
                }
            }
        });

        _adapter = new TimelineAdapter(_context);
        ui_lstTimeLine.setAdapter(_adapter);
        ui_lstTimeLine.addHeaderView(ui_headerview);

        ui_fltBaiduMap = (FrameLayout) ui_headerview.findViewById(id.flt_baidumap);
        ui_fltGoogleMap = (FrameLayout) ui_headerview.findViewById(id.flt_googlemap);

        updateFriendInfo();

        if (Commons.g_isChina) {

            ui_fltBaiduMap.setVisibility(View.VISIBLE);
            ui_fltGoogleMap.setVisibility(View.GONE);

            mBaiduMapView = (MapView) ui_headerview.findViewById(R.id.bmapView);

            mCurrentMode = MyLocationConfiguration.LocationMode.NORMAL;

            mBaiduMap = mBaiduMapView.getMap();
            // 开启定位图层
            mBaiduMap.setMyLocationEnabled(true);
            mBaiduMap.setMyLocationConfigeration(new MyLocationConfiguration(
                    mCurrentMode, true, null));

            // 定位初始化
            mLocClient = new LocationClient(_context);
            mLocClient.registerLocationListener(myListener);

            mBaiduMap.setOnMarkerClickListener(new BaiduMap.OnMarkerClickListener() {
                @Override
                public boolean onMarkerClick(Marker marker) {

                    showBaiduToolTip(marker);
                    return false;
                }
            });

            mBaiduMap.setOnMapTouchListener(new BaiduMap.OnMapTouchListener() {
                @Override
                public void onTouch(MotionEvent motionEvent) {
                    if (_baiduInfoWindow != null)
                        mBaiduMap.hideInfoWindow();

                    if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
                        enableSwipyRefresh(true);
                    }else{
                        enableSwipyRefresh(false);
                    }
                }
            });

        } else {

            ui_fltBaiduMap.setVisibility(View.GONE);
            ui_fltGoogleMap.setVisibility(View.VISIBLE);

        }

    }

    public void enableSwipyRefresh(boolean enable) {

        ui_lstTimeLine.requestDisallowInterceptTouchEvent(!enable);
        ui_refreshLayout.setEnabled(enable);
    }

    public void addMarkers() {

        if (!isAdded())
            return;

        if (Commons.g_isChina) {

            mBaiduMap.clear();

            for (FriendEntity friendEntity : _context._nearbyUsers) {

                LatLng latLng = new LatLng(friendEntity.get_latitude(), friendEntity.get_longitude());

                BitmapDescriptor bitmap = BitmapDescriptorFactory.fromResource(R.drawable.icon_void_map);

                if (friendEntity.is_isPublic()) {

                    if (friendEntity.get_sex() == 0)
                        bitmap = BitmapDescriptorFactory
                                .fromResource(R.drawable.icon_man_map);
                    else
                        bitmap = BitmapDescriptorFactory.fromResource(R.drawable.icon_woman_map);
                }

                OverlayOptions option = new MarkerOptions()
                        .position(latLng)
                        .title(String.valueOf(friendEntity.get_idx()))
                        .icon(bitmap);

                mBaiduMap.addOverlay(option);
            }

        } else {

            if (mGoogleMap == null)
                return;

            mGoogleMap.clear();

            float latitude = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
            float longitude = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

            if (latitude != 0 && longitude != 0) {
                com.google.android.gms.maps.model.LatLng ll = new com.google.android.gms.maps.model.LatLng(latitude, longitude);
                mGoogleMap.addMarker(new com.google.android.gms.maps.model.MarkerOptions().position(ll));
            }

            for (FriendEntity friendEntity : _context._nearbyUsers) {

                float lat = friendEntity.get_latitude();
                float lng = friendEntity.get_longitude();

                com.google.android.gms.maps.model.LatLng latLng = new com.google.android.gms.maps.model.LatLng(lat, lng);

                Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.icon_void_map);

                if (friendEntity.is_isPublic()) {

                    if (friendEntity.get_sex() == 0)
                        bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.icon_man_map);
                    else
                        bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.icon_woman_map);
                }

                int sex = friendEntity.get_sex();
                if (!friendEntity.is_isPublic())
                    sex = 2;

                mGoogleMap.addMarker(new com.google.android.gms.maps.model.MarkerOptions()
                        .position(latLng)
                        .title(String.valueOf(friendEntity.get_idx()) + ":" + sex)
                        .snippet(friendEntity.get_name())
                        .icon(com.google.android.gms.maps.model.BitmapDescriptorFactory.fromBitmap(bitmap)));
            }


        }
    }

    public void showBaiduToolTip(Marker marker) {

        float lat = (float) marker.getPosition().latitude;
        float lng = (float) marker.getPosition().longitude;
        String title = marker.getTitle();

        if (_baiduInfoWindow != null) {
            mBaiduMap.hideInfoWindow();
            _baiduInfoWindow = null;
        }

        for (final FriendEntity friendEntity : _context._nearbyUsers) {

            if (friendEntity.get_idx() == Integer.valueOf(title).intValue()) {

                if (!friendEntity.is_isPublic())
                    return;

                LinearLayout linearLayout = new LinearLayout(_context);
                linearLayout.setOrientation(LinearLayout.HORIZONTAL);

                int dp10 = Commons.GetPixelValueFromDp(_context, 10);
                int dp4 = Commons.GetPixelValueFromDp(_context, 4);
                int dp12 = Commons.GetPixelValueFromDp(_context, 12);

                TextView txvTrans = new TextView(_context);
                txvTrans.setText(friendEntity.get_name());
                txvTrans.setPadding(dp10, 0, dp10, dp4);
                txvTrans.setTextColor(Color.TRANSPARENT);
                txvTrans.setGravity(Gravity.CENTER_HORIZONTAL);

                TextView txvTooltip = new TextView(_context);
                txvTooltip.setText(friendEntity.get_name());
                txvTooltip.setTypeface(null, Typeface.BOLD_ITALIC);
                txvTooltip.setPadding(dp10, 0, dp10, dp4);
                txvTooltip.setTextColor(Color.WHITE);
                txvTooltip.setGravity(Gravity.CENTER_HORIZONTAL);

                linearLayout.addView(txvTrans);
                linearLayout.addView(txvTooltip);

                LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)txvTooltip.getLayoutParams();
                params.setMargins(dp12, 0, 0, 0); //substitute parameters for left, top, right, bottom
                txvTooltip.setLayoutParams(params);

                txvTooltip.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        gotoUserProfile(friendEntity);
                    }
                });

                if (friendEntity.get_sex() == 0)
                    txvTooltip.setBackgroundResource(R.drawable.icon_man_info_map);
                else
                    txvTooltip.setBackgroundResource(R.drawable.icon_woman_info_map);

                _baiduInfoWindow = new InfoWindow(linearLayout, new LatLng(lat, lng), -dp12);

                mBaiduMap.showInfoWindow(_baiduInfoWindow);

                return;
            }
        }

    }


    public void showGoogleTooltip(com.google.android.gms.maps.model.Marker marker) {
        marker.showInfoWindow();
    }

    public void refresh() {

        if (_context == null)
            return;

        if (!isAdded())
            return;

        updateFriendInfo();

        addMarkers();
    }

    public void updateFriendInfo() {

        int distance = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_DISTANCE, 10);
        ui_txvRadius.setText(getString(R.string.radius) + distance + "km" + getString(R.string.in_friend));

        int publicFriend = 0;
        int privateFriend = 0;

        for (FriendEntity friendEntity : _context._nearbyUsers) {
            if (friendEntity.is_isFriend()) {
                if (friendEntity.is_isPublic()) {
                    publicFriend++;
                } else {
                    privateFriend++;
                }
            }
        }

        int allFriend = privateFriend + publicFriend;

        ui_txvFriendCount.setText(allFriend + getString(R.string.man_unit) + "(" + getString(R.string.public_info) + " " + publicFriend + getString(R.string.man_unit) +
                ", " + getString(R.string.private_info) + " " + privateFriend + getString(R.string.man_unit) + ")");
    }

    public void getNearbyTimeline(final boolean isRefresh) {

        if (isRefresh)
            _pageIndex = 1;
        else
            _pageIndex++;

        float lat = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
        float lng = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

        int distance = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_DISTANCE, 10);
        int ageStart = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_AGE_START, 1);
        int ageEnd = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_AGE_END, 100);

        int sex = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_SEX, 2);
        int lastLogin = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_LASTLOGIN, 7);
        int relation = Preference.getInstance().getValue(_context, PrefConst.PREFKEY_RELATION, 0);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETNEARBYTIMELINEDETAIL;

        String params = String.format("/%d/%s/%s/%d/%d/%d/%d/%d/%d/%d", Commons.g_user.get_idx(), lat, lng, distance, ageStart, ageEnd, sex, lastLogin, relation, _pageIndex);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseTimelineResponse(json, isRefresh);

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

    public void parseTimelineResponse(String json, boolean isRefresh){

        try{

            if (isRefresh) {
                _timelineData.clear();
            }
            ui_refreshLayout.setRefreshing(false);

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

                JSONArray timelines = response.getJSONArray(ReqConst.RES_TIMELINE);

                for (int i = 0; i < timelines.length(); i++) {

                    JSONObject timeline = (JSONObject) timelines.get(i);

                    TimelineEntity entity = new TimelineEntity();
                    entity.set_id(timeline.getInt(ReqConst.RES_IDX));
                    entity.set_userId(timeline.getInt(ReqConst.RES_USERID));
                    entity.set_userName(timeline.getString(ReqConst.RES_NAME));
                    entity.set_userProfile(timeline.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_content(timeline.getString(ReqConst.RES_CONTENT));
                    entity.set_likeCount(timeline.getInt(ReqConst.RES_LIKECOUNT));
                    entity.set_respondCount(timeline.getInt(ReqConst.RES_RESPONDCOUNT));
                    entity.set_writeTime(timeline.getString(ReqConst.RES_REGTIME));
                    entity.set_latitude((float) timeline.getDouble(ReqConst.RES_LATITUDE));
                    entity.set_longitude((float) timeline.getDouble(ReqConst.RES_LONGITUDE));
                    entity.set_country(timeline.getString(ReqConst.RES_COUNTRY));
                    entity.set_country2(timeline.getString(ReqConst.RES_COUNTRY2));

                    JSONArray fileurls = timeline.getJSONArray(ReqConst.RES_FILE_URL);
                    for (int j = 0; j < fileurls.length(); j++) {
                        entity.get_fileUrls().add(fileurls.getString(j));
                    }

                    JSONArray responds = timeline.getJSONArray(ReqConst.RES_RESPONDINFO);
                    for (int j = 0; j < responds.length(); j++) {
                        JSONObject respond = responds.getJSONObject(j);
                        RespondEntity respondEntity = new RespondEntity();
                        respondEntity.set_id(respond.getInt(ReqConst.RES_ID));
                        respondEntity.set_userName(respond.getString(ReqConst.RES_NAME));
                        respondEntity.set_content(respond.getString(ReqConst.RES_CONTENT));
                        respondEntity.set_userProfile(respond.getString(ReqConst.RES_PHOTO_URL));
                        entity.get_2responds().add(respondEntity);
                    }

                    JSONArray likeusers = timeline.getJSONArray(ReqConst.RES_LIKEUSERNAME);
                    for (int j = 0; j < likeusers.length(); j++) {
                        entity.get_likeUsernames().add(likeusers.getString(j));
                    }

                    _timelineData.add(entity);
                }

                if (isRefresh) {
                    if (Commons.g_notiData != null) {

                        if (_timelineData.size() > 1)
                            _timelineData.add(1, Commons.g_notiData);
                        else
                            _timelineData.add(Commons.g_notiData);
                    }
                }

                _adapter.setDatas(_timelineData);

            }

        }catch (JSONException e){
            e.printStackTrace();
        }


    }

    PermissionListener permissionlistener = new PermissionListener() {
        @Override
        public void onPermissionGranted() {

            String[] PERMISSIONS = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.READ_PHONE_STATE};

            if (Commons.hasPermissions(_context, PERMISSIONS)){
                startTracking();
            }
        }

        @Override
        public void onPermissionDenied(ArrayList<String> deniedPermissions) {
        }


    };

    public boolean checkLocationEnabled()
    {
        _locationManager = (LocationManager) _context.getSystemService( Context.LOCATION_SERVICE );

        if ( !_locationManager.isProviderEnabled( LocationManager.GPS_PROVIDER ) ) {
            buildAlertMessageNoGps();
            return false;
        }

        return true;
    }
    private void buildAlertMessageNoGps() {

        final AlertDialog.Builder builder = new AlertDialog.Builder(_context);
        builder.setMessage("Your GPS seems to be disabled, do you want to enable it?")
                .setCancelable(false)
                .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog,  final int id) {
                        startActivityForResult(new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS), Constants.PICK_FROM_GPSSETTINGS);
                    }
                })
                .setNegativeButton("No", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        updateMyLocationWithSavedData();
                        dialog.cancel();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.show();

    }

    public void startTracking() {

        if (Commons.g_isFirstLocCaptured) {
            updateMyLocationWithSavedData();
            return;
        }

        if (!checkLocationEnabled())
            return;

        if (Commons.g_isChina) {

            LocationClientOption option = new LocationClientOption();
            option.setOpenGps(true); // 打开gps
            option.setCoorType("bd09ll"); // 设置坐标类型
//        option.setScanSpan(1000);     // disable span for video call

            mLocClient.setLocOption(option);
            mLocClient.start();

        } else {

            if (ContextCompat.checkSelfPermission(_context, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    || ContextCompat.checkSelfPermission(_context, android.Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {

                if (_locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                    _locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, mLocationListener);
                }

                if (_locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)){
                    _locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, mLocationListener);
                }

            }
        }
    }

    public void stopTracking() {

        if (Commons.g_isChina) {
            mLocClient.stop();
        }
    }

    public void syncMyLocationToServer() {

        float lat = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
        float lng = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

        if (lat == 0 || lng == 0) return;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETLOCATION;

        String params = String.format("/%d/%f/%f", Commons.g_user.get_idx(), lat, lng);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseSyncResponse(json);

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

    public void parseSyncResponse(String json) {

        try{

            JSONObject response = new JSONObject(json);

            int result_code = response.getInt(ReqConst.RES_CODE);

            if (result_code == ReqConst.CODE_SUCCESS){

            }

        }catch (JSONException e){
            e.printStackTrace();
        }
    }

    public void updateMyLocationWithSavedData() {

        float lat = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
        float lng = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);
        float radius = Preference.getInstance().getValue(_context, Constants.KEY_RADIUS, 0.0f);

        if (lat == 0 || lng == 0)
            return;

        if (Commons.g_isChina) {

            MyLocationData locData = new MyLocationData.Builder()
                    .accuracy(radius)
                    // 此处设置开发者获取到的方向信息，顺时针0-360
                    .direction(100).latitude(lat)
                    .longitude(lng).build();

            mBaiduMap.setMyLocationData(locData);

            LatLng ll = new LatLng(lat, lng);
            MapStatus.Builder builder = new MapStatus.Builder();
            builder.target(ll).zoom(18.0f);

            mBaiduMap.animateMapStatus(MapStatusUpdateFactory.newMapStatus(builder.build()));

        } else {

            com.google.android.gms.maps.model.LatLng ll = new com.google.android.gms.maps.model.LatLng(lat, lng);

            mGoogleMap.addMarker(new com.google.android.gms.maps.model.MarkerOptions().position(ll));
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(ll, 15.0f));

        }
    }


    public void gotoWriteTimeline() {

        Intent intent = new Intent(getActivity(), WriteTimelineActivity.class);
        startActivity(intent);
    }

    public void gotoLargeMap() {

        Intent intent = new Intent(getActivity(), LargeMapActivity.class);
        intent.putExtra(Constants.KEY_NEARBYUSERS, _context._nearbyUsers);
        startActivity(intent);
    }

    public void gotoUserProfile(FriendEntity friendEntity) {

        Intent intent = new Intent(_context, UserProfileActivity.class);
        intent.putExtra(Constants.KEY_FRIEND, friendEntity);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        _context.startActivity(intent);

    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {

            case id.imv_add_timeline:
                gotoWriteTimeline();
                break;

            case id.imv_scale_baidumap:
            case id.imv_scale_googlemap:
                gotoLargeMap();
                break;

            case id.imv_set_location:
                Commons.g_isFirstLocCaptured = false;
                startTracking();
                break;
        }
    }


    @Override
    public void onMapReady(GoogleMap googleMap) {

        float latitude = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
        float longitude = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

        com.google.android.gms.maps.model.LatLng ll = new com.google.android.gms.maps.model.LatLng(latitude, longitude);
        mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(ll, 15.0f));

        addMarkers();

    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == Constants.PICK_FROM_GPSSETTINGS) {

            if (resultCode == 0) {
                startTracking();
            }
        }
    }

    @Override
    public void onPause() {

        if (Commons.g_isChina)
            mBaiduMapView.onPause();


        super.onPause();
    }




    @Override
    public void onDestroyView() {
        super.onDestroyView();

    }

    @Override
    public void onDestroy() {

        if (Commons.g_isChina) {

            // 退出时销毁定位
            mLocClient.stop();
            // 关闭定位图层
            mBaiduMap.setMyLocationEnabled(false);
            mBaiduMapView.onDestroy();
            mBaiduMapView = null;

        } else {

            if (ContextCompat.checkSelfPermission(_context, Manifest.permission.ACCESS_FINE_LOCATION)
                    == PackageManager.PERMISSION_GRANTED || ContextCompat.checkSelfPermission(_context, android.Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED)
                mGoogleMap.setMyLocationEnabled(false);

        }

        super.onDestroy();
    }



    public class MyLocationListenner implements BDLocationListener {

        @Override
        public void onReceiveLocation(BDLocation location) {
            // map view 销毁后不在处理新接收的位置
            if (location == null || mBaiduMapView == null) {
                return;
            }

            float radius = location.getRadius();

            MyLocationData locData = new MyLocationData.Builder()
                    .accuracy(radius)
                    // 此处设置开发者获取到的方向信息，顺时针0-360
                    .direction(100).latitude(location.getLatitude())
                    .longitude(location.getLongitude()).build();

            mBaiduMap.setMyLocationData(locData);

            if (!Commons.g_isFirstLocCaptured) {

                Commons.g_isFirstLocCaptured = true;

                Preference.getInstance().put(_context, Constants.KEY_LATITUDE, (float) location.getLatitude());
                Preference.getInstance().put(_context, Constants.KEY_LONGITUDE, (float) location.getLongitude());
                Preference.getInstance().put(_context, Constants.KEY_RADIUS, radius);

                LatLng ll = new LatLng(location.getLatitude(),
                        location.getLongitude());

                MapStatus.Builder builder = new MapStatus.Builder();
                builder.target(ll).zoom(18.0f);

                mBaiduMap.animateMapStatus(MapStatusUpdateFactory.newMapStatus(builder.build()));

                getNearbyTimeline(true);
                _context.getNearbyUsers(true);
                addMarkers();

                syncMyLocationToServer();

                stopTracking();
            }
        }

        public void onReceivePoi(BDLocation poiLocation) {
        }
    }

    private final LocationListener mLocationListener = new LocationListener() {
        @Override
        public void onLocationChanged(final Location location) {

            double latitude = location.getLatitude();
            double longitude = location.getLongitude();

            if (!Commons.g_isFirstLocCaptured) {

                Commons.g_isFirstLocCaptured = true;

                Preference.getInstance().put(_context, Constants.KEY_LATITUDE, (float) latitude);
                Preference.getInstance().put(_context, Constants.KEY_LONGITUDE, (float) longitude);

                if (ContextCompat.checkSelfPermission(_context, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                        || ContextCompat.checkSelfPermission(_context, android.Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    _locationManager.removeUpdates(mLocationListener);
                }

                if (mGoogleMap != null) {

                    com.google.android.gms.maps.model.LatLng ll = new com.google.android.gms.maps.model.LatLng(latitude, longitude);
                    mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(ll, 15.0f));
                }

                getNearbyTimeline(true);
                _context.getNearbyUsers(true);
                addMarkers();

                syncMyLocationToServer();

                stopTracking();
            }

        }

        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
        }

        @Override
        public void onProviderEnabled(String provider) {
        }

        @Override
        public void onProviderDisabled(String provider) {
        }
    };

    class MyInfoWindowAdapter implements GoogleMap.InfoWindowAdapter {

        MyInfoWindowAdapter(){

        }

        @Override
        public View getInfoContents(com.google.android.gms.maps.model.Marker marker) {
            return null;
        }

        @Override
        public View getInfoWindow(com.google.android.gms.maps.model.Marker marker) {

            View myContentsView = _context.getLayoutInflater().inflate(R.layout.custom_info_contents, null);

            if (marker.getTitle() == null || marker.getTitle().length() == 0)
                return null;

            TextView txvTooltip = (TextView)myContentsView.findViewById(id.txv_tooltip);
            txvTooltip.setText(marker.getSnippet());

            TextView txvTrans = (TextView) myContentsView.findViewById(id.txv_trans);
            txvTrans.setText(marker.getSnippet());

            int sex = Integer.valueOf(marker.getTitle().split(":")[1]).intValue();

            if (sex == 0) {
                txvTooltip.setBackgroundResource(R.drawable.icon_man_info_map);
            } else if (sex == 1){
                txvTooltip.setBackgroundResource(R.drawable.icon_woman_info_map);
            } else {
                return null;
            }

            return myContentsView;
        }

    }


}
