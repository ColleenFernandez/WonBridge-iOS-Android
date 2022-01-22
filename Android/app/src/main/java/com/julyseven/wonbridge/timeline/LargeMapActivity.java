package com.julyseven.wonbridge.timeline;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

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
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.preference.Preference;

import java.util.ArrayList;

public class LargeMapActivity extends CommonActivity implements View.OnClickListener, BaiduMap.OnMapLoadedCallback, OnMapReadyCallback {

    FrameLayout ui_fltBaiduMap, ui_fltGoogleMap;

    MapView mBaiduMapView;
    BaiduMap mBaiduMap;

    com.google.android.gms.maps.SupportMapFragment ui_googleMapFragment;
    GoogleMap mGoogleMap;


    private MyLocationConfiguration.LocationMode mCurrentMode;

    MapStatus ms;

    ArrayList<FriendEntity> _nearbyUsers = new ArrayList<>();

    InfoWindow _baiduInfoWindow = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_large_map);

        _nearbyUsers = (ArrayList<FriendEntity>)getIntent().getSerializableExtra(Constants.KEY_NEARBYUSERS);

        loadLayout();
    }

    private void loadLayout() {

        ImageView imvSetLocation = (ImageView) findViewById(R.id.imv_set_location);
        imvSetLocation.setOnClickListener(this);

        ImageView imvSmallGoogleMap = (ImageView) findViewById(R.id.imv_small_googlemap);
        imvSmallGoogleMap.setOnClickListener(this);

        ImageView imvSmallBaiduMap = (ImageView) findViewById(R.id.imv_small_baidumap);
        imvSmallBaiduMap.setOnClickListener(this);

        ui_fltBaiduMap = (FrameLayout) findViewById(R.id.flt_baidumap);
        ui_fltGoogleMap = (FrameLayout) findViewById(R.id.flt_googlemap);

        if (Commons.g_isChina) {

            ui_fltBaiduMap.setVisibility(View.VISIBLE);
            ui_fltGoogleMap.setVisibility(View.GONE);

            mCurrentMode = MyLocationConfiguration.LocationMode.NORMAL;

            mBaiduMapView = (MapView) findViewById(R.id.bmapView);
            mBaiduMap = mBaiduMapView.getMap();
            mBaiduMap.setOnMapLoadedCallback(this);
            // 开启定位图层
            mBaiduMap.setMyLocationEnabled(true);
            mBaiduMap.setMyLocationConfigeration(new MyLocationConfiguration(
                    mCurrentMode, true, null));

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
                }
            });

            updateMyLocation();


        } else {

            ui_fltBaiduMap.setVisibility(View.GONE);
            ui_fltGoogleMap.setVisibility(View.VISIBLE);

            ui_googleMapFragment = (com.google.android.gms.maps.SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.googlemap);
            ui_googleMapFragment.getMapAsync(this);

            mGoogleMap = ui_googleMapFragment.getMap();

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

                    for (final FriendEntity friendEntity : _nearbyUsers) {
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

    public void showBaiduToolTip(Marker marker) {

        float lat = (float) marker.getPosition().latitude;
        float lng = (float) marker.getPosition().longitude;
        String title = marker.getTitle();

        if (_baiduInfoWindow != null) {
            mBaiduMap.hideInfoWindow();
            _baiduInfoWindow = null;
        }

        for (final FriendEntity friendEntity : _nearbyUsers) {

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


    public void updateMyLocation() {

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
            builder.target(ll).zoom(16.0f);

            mBaiduMap.animateMapStatus(MapStatusUpdateFactory.newMapStatus(builder.build()));

        } else {

            com.google.android.gms.maps.model.LatLng ll = new com.google.android.gms.maps.model.LatLng(lat, lng);
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(ll, 15.0f));

        }


    }

    public void addMarkers() {

        if (Commons.g_isChina) {

            mBaiduMap.clear();

            for (FriendEntity friendEntity : _nearbyUsers) {

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

            for (FriendEntity friendEntity : _nearbyUsers) {

                com.google.android.gms.maps.model.LatLng latLng = new com.google.android.gms.maps.model.LatLng(friendEntity.get_latitude(), friendEntity.get_longitude());

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

    private void onSetLocation() {

        updateMyLocation();
    }

    public void gotoUserProfile(FriendEntity friendEntity) {

        Intent intent = new Intent(_context, UserProfileActivity.class);
        intent.putExtra(Constants.KEY_FRIEND, friendEntity);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        _context.startActivity(intent);

    }

    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_small_googlemap:
            case R.id.imv_small_baidumap:
                onBack();
                break;

            case R.id.imv_set_location:
                onSetLocation();
                 break;

        }

    }

    @Override
    public void onPause() {

        if (Commons.g_isChina)
            mBaiduMapView.onPause();

        super.onPause();
    }

    @Override
    public void onResume() {

        if (Commons.g_isChina)
            mBaiduMapView.onResume();

        super.onResume();
    }

    @Override
    public void onDestroy() {

        if (Commons.g_isChina) {
            // 关闭定位图层
            mBaiduMap.setMyLocationEnabled(false);
            mBaiduMapView.onDestroy();
            mBaiduMapView = null;
        }

        super.onDestroy();
    }


    @Override
    public void onMapLoaded() {
        // TODO Auto-generated method stub
        ms = new MapStatus.Builder().zoom(18.0f).build();
        mBaiduMap.animateMapStatus(MapStatusUpdateFactory.newMapStatus(ms));

        addMarkers();
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {

        float latitude = Preference.getInstance().getValue(_context, Constants.KEY_LATITUDE, 0.0f);
        float longitude = Preference.getInstance().getValue(_context, Constants.KEY_LONGITUDE, 0.0f);

        com.google.android.gms.maps.model.LatLng ll = new com.google.android.gms.maps.model.LatLng(latitude, longitude);

        mGoogleMap.addMarker(new com.google.android.gms.maps.model.MarkerOptions().position(ll));
        mGoogleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(ll, 15.0f));

        addMarkers();

    }

    class MyInfoWindowAdapter implements GoogleMap.InfoWindowAdapter {

        MyInfoWindowAdapter(){

        }

        @Override
        public View getInfoContents(com.google.android.gms.maps.model.Marker marker) {
            return null;
        }

        @Override
        public View getInfoWindow(com.google.android.gms.maps.model.Marker marker) {

            View myContentsView = getLayoutInflater().inflate(R.layout.custom_info_contents, null);

            if (marker.getTitle() == null || marker.getTitle().length() == 0)
                return null;

            TextView txvTooltip = ((TextView)myContentsView.findViewById(R.id.txv_tooltip));
            txvTooltip.setText(marker.getSnippet());

            TextView txvTrans = (TextView) myContentsView.findViewById(R.id.txv_trans);
            txvTrans.setText(marker.getSnippet());

            int sex = Integer.valueOf(marker.getTitle().split(":")[1]).intValue();

            if (sex == 0) {
                txvTooltip.setBackgroundResource(R.drawable.icon_man_info_map);
            } else if (sex == 1) {
                txvTooltip.setBackgroundResource(R.drawable.icon_woman_info_map);
            } else {
                return null;
            }

            return myContentsView;
        }

    }

}
