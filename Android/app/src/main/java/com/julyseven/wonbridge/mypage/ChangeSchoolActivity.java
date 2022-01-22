package com.julyseven.wonbridge.mypage;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
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
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;
import com.julyseven.wonbridge.model.CountryEntity;
import com.julyseven.wonbridge.register.InputUserInfoActivity;
import com.julyseven.wonbridge.register.SelectSchoolActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URLEncoder;

public class ChangeSchoolActivity extends CommonActivity implements View.OnClickListener {


    EditText ui_edtSchool;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_change_school);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.change_school));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvCancel = (TextView) findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(this);

        TextView txvOkay = (TextView) findViewById(R.id.txv_ok);
        txvOkay.setOnClickListener(this);

        TextView txvSelect = (TextView) findViewById(R.id.txv_select);
        txvSelect.setOnClickListener(this);

        ui_edtSchool = (EditText) findViewById(R.id.edt_school);
        ui_edtSchool.setText(Commons.g_user.get_school());

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtSchool.getWindowToken(), 0);
                return false;
            }
        });
    }

    public void onChangeSchool() {

        if (ui_edtSchool.getText().length() == 0) {
            return;
        }

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtSchool.getWindowToken(), 0);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETSCHOOL;

        String school = ui_edtSchool.getText().toString().replace(" ", "%20");
        school = school.replace("/", Constants.SLASH);

        try {
            school = URLEncoder.encode(school, "utf-8");
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), school);

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseSchoolResponse(json);
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

    public void parseSchoolResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                Commons.g_user.set_school(ui_edtSchool.getText().toString());
                setResult(RESULT_OK);
                finish();
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

    }

    public void gotoSelectSchool() {

        Intent intent = new Intent(ChangeSchoolActivity.this, SelectSchoolActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_SCHOOL);
    }

    private void onBack() {
        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == Constants.PICK_FROM_SCHOOL) {

            if (resultCode == RESULT_OK) {
                ui_edtSchool.setText(data.getStringExtra(Constants.KEY_SCHOOL));
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
            case R.id.txv_cancel:
                onBack();
                break;

            case R.id.txv_ok:
                onChangeSchool();
                break;

            case R.id.txv_select:
                gotoSelectSchool();
                break;

        }

    }


}
