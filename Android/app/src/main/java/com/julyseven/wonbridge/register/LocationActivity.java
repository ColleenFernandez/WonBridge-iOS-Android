package com.julyseven.wonbridge.register;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.WonBridgeApplication;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;

import org.json.JSONException;
import org.json.JSONObject;

public class LocationActivity extends CommonActivity implements View.OnClickListener {

    String _photoPath = "";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_location);

        if (getIntent().getStringExtra(Constants.KEY_PHOTOPATH) != null) {
            _photoPath = getIntent().getStringExtra(Constants.KEY_PHOTOPATH);
        }
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.signup));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);
        imvBack.setVisibility(View.GONE);

        TextView txvSkip = (TextView) findViewById(R.id.txv_skip);
        txvSkip.setOnClickListener(this);

        TextView txvCountry= (TextView) findViewById(R.id.txv_countryname);
        txvCountry.setText(Commons.getCountryName(this));

    }

    public void setCountryCode() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETCOUNTRY;

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), Commons.getCountryCode(this));
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseCountryResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
                showAlertDialog(getString(R.string.error));
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void parseCountryResponse(String json){

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){

            }

        }catch (JSONException e){

            e.printStackTrace();
        }

        gotoComplete();


    }

    private void onSkip() {

        setCountryCode();
    }

    public void gotoComplete() {

        Intent intent = new Intent(LocationActivity.this, CompleteRegisterActivity.class);

        if (_photoPath.length() > 0) {
            intent.putExtra(Constants.KEY_PHOTOPATH, _photoPath);
        }

        startActivity(intent);

        finish();
    }

    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                break;

            case R.id.txv_skip:
                onSkip();
                break;

        }

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            onSkip();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

}
