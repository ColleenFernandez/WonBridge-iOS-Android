package com.julyseven.wonbridge.timeline;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.adapter.TimelineAdapter;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.RespondEntity;
import com.julyseven.wonbridge.model.TimelineEntity;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;

public class TimelineListActivity extends CommonActivity implements View.OnClickListener {


    private ListView ui_lstTimeLine;
    private TimelineAdapter _adapter;
    private ArrayList<TimelineEntity> _timelineData = new ArrayList<>();

    private int _userId = 0;
    private String _userName = "";

    SwipyRefreshLayout ui_refreshLayout;
    int _pageIndex = 0;

    public boolean _isFromAll = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_timeline_list);

        _userId = getIntent().getIntExtra(Constants.KEY_USER_ID, 0);
        _userName = getIntent().getStringExtra(Constants.KEY_USERNAME);

        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(_userName + " " + getString(R.string.detimeline));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_lstTimeLine = (ListView) findViewById(R.id.lst_timeline);

        _adapter = new TimelineAdapter(this);
        ui_lstTimeLine.setAdapter(_adapter);

        ui_refreshLayout = (SwipyRefreshLayout) findViewById(R.id.refresh);
        ui_refreshLayout.setOnRefreshListener(new SwipyRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh(SwipyRefreshLayoutDirection direction) {
                if (direction == SwipyRefreshLayoutDirection.TOP) {
                    getMyTimeline(true);
                } else if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
                    getMyTimeline(false);
                }
            }
        });

    }

    public void getMyTimeline(final boolean isRefresh) {

        if (isRefresh)
            _pageIndex = 1;
        else
            _pageIndex++;

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETMYTIMELINEWITHDETAIL;

        String params = String.format("/%d/%d", _userId, _pageIndex);
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseTimelineResponse(json, isRefresh);

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
                    entity.set_content(timeline.getString(ReqConst.RES_CONTENT));
                    entity.set_userId(timeline.getInt(ReqConst.RES_USERID));
                    entity.set_userProfile(timeline.getString(ReqConst.RES_PHOTO_URL));
                    entity.set_userName(timeline.getString(ReqConst.RES_USERNAME));
                    entity.set_likeCount(timeline.getInt(ReqConst.RES_LIKECOUNT));
                    entity.set_respondCount(timeline.getInt(ReqConst.RES_RESPONDCOUNT));
                    entity.set_writeTime(timeline.getString(ReqConst.RES_REGTIME));
                    entity.set_latitude((float) timeline.getDouble(ReqConst.RES_LATITUDE));
                    entity.set_longitude((float) timeline.getDouble(ReqConst.RES_LONGITUDE));
                    entity.set_country(timeline.getString(ReqConst.RES_COUNTRY));

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

            }

            _adapter.setDatas(_timelineData);

        }catch (JSONException e){
            e.printStackTrace();
        }


    }


    private void onBack() {
        finish();
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
            getMyTimeline(true);

        _isFromAll = false;
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;


        }

    }



}
