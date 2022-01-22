package com.julyseven.wonbridge.register;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
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

import java.net.URLEncoder;

public class InputUserInfoActivity extends CommonActivity implements View.OnClickListener {

    String _photoPath = "";
    EditText ui_edtSchool, ui_edtVillage, ui_edtWorking, ui_edtInterest;
    TextView ui_txvCountry;

    CountryEntity _selectedCountry;
    String _selectedSchool = "";
    String _selectedVillage = "";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_input_userinfo);

        if (getIntent().getStringExtra(Constants.KEY_PHOTOPATH) != null) {
            _photoPath = getIntent().getStringExtra(Constants.KEY_PHOTOPATH);
        }
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.user_info));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);
        imvBack.setVisibility(View.GONE);

        TextView txvOk = (TextView) findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(this);

        TextView txvSchool = (TextView) findViewById(R.id.txv_school);
        txvSchool.setOnClickListener(this);

        TextView txvVillage = (TextView) findViewById(R.id.txv_village);
        txvVillage.setOnClickListener(this);

        TextView txvCountry = (TextView) findViewById(R.id.txv_country2);
        txvCountry.setOnClickListener(this);

        int[] ids = {R.id.txv_working1, R.id.txv_working2, R.id.txv_working3,
                R.id.txv_working4, R.id.txv_working5, R.id.txv_working6,
                R.id.txv_interest1, R.id.txv_interest2, R.id.txv_interest3,
                R.id.txv_interest4, R.id.txv_interest5, R.id.txv_interest6};

        for (int i = 0; i < ids.length; i++) {
            TextView txv = (TextView) findViewById(ids[i]);
            txv.setOnClickListener(this);
        }

        ui_edtSchool = (EditText) findViewById(R.id.edt_school);
        ui_edtVillage = (EditText) findViewById(R.id.edt_village);
        ui_txvCountry = (TextView) findViewById(R.id.txv_country);
        ui_txvCountry.setOnClickListener(this);
        ui_edtWorking = (EditText) findViewById(R.id.edt_working);
        ui_edtInterest = (EditText) findViewById(R.id.edt_interest);


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


    public void setCountryCode() {

        showProgress();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETCOUNTRY;

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), Commons.getCountryCode(this));
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

               setSchool();
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                setSchool();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }


    public void setSchool() {

        if (ui_edtSchool.getText().length() == 0) {
            setVillage();
            return;
        }

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETSCHOOL;

        try {
            String school = ui_edtSchool.getText().toString().trim().replace(" ", "%20");
            school = school.replace("/", Constants.SLASH);
            school = URLEncoder.encode(school, "utf-8");

            String params = String.format("/%d/%s", Commons.g_user.get_idx(), school);
            url += params;
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                setVillage();
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                setVillage();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void setVillage() {

        if (ui_edtVillage.getText().length() == 0) {
            setCountry2();
            return;
        }

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETVILLAGE;

        try {
            String village = ui_edtVillage.getText().toString().trim().replace(" ", "%20");
            village = village.replace("/", Constants.SLASH);
            village = URLEncoder.encode(village, "utf-8");

            String params = String.format("/%d/%s", Commons.g_user.get_idx(), village);
            url += params;
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                setCountry2();
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                setCountry2();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void setCountry2() {

        if (_selectedCountry == null) {
            setWorking();
            return;
        }

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETCOUNTRY2;

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), _selectedCountry.getCountryCode());
        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                setWorking();
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                setWorking();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void setWorking() {

        if (ui_edtWorking.getText().length() == 0) {
            setInterest();
            return;
        }

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETWORKING;

        try {
            String working = ui_edtWorking.getText().toString().trim().replace(" ", "%20");
            working = working.replace("/", Constants.SLASH);
            working = URLEncoder.encode(working, "utf-8");

            String params = String.format("/%d/%s", Commons.g_user.get_idx(), working);
            url += params;
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                setInterest();
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                setInterest();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    public void setInterest() {

        if (ui_edtInterest.getText().length() == 0) {
            gotoComplete();
            return;
        }

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETINTEREST;

        try {
            String interest = ui_edtInterest.getText().toString().trim().replace(" ", "%20");
            interest = interest.replace("/", Constants.SLASH);
            interest = URLEncoder.encode(interest, "utf-8");

            String params = String.format("/%d/%s", Commons.g_user.get_idx(), interest);
            url += params;
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                gotoComplete();
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                gotoComplete();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);

    }

    private void onSkip() {

        setCountryCode();
    }

    public void gotoSelectSchool() {

        Intent intent = new Intent(InputUserInfoActivity.this, SelectSchoolActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_SCHOOL);

    }


    public void gotoSelectVillage() {

        Intent intent = new Intent(InputUserInfoActivity.this, SelectVillageActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_VILLAGE);

    }

    public void gotoSelectCountry() {

        Intent intent = new Intent(InputUserInfoActivity.this, SelectCountryActivity.class);
        intent.putExtra(Constants.KEY_ONLY_COUNTRY, true);
        startActivityForResult(intent, Constants.PICK_FROM_COUNTRY);
    }

    public void gotoComplete() {

        closeProgress();

        Intent intent = new Intent(InputUserInfoActivity.this, CompleteRegisterActivity.class);

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
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == Constants.PICK_FROM_COUNTRY) {

            if (resultCode == RESULT_OK) {

                _selectedCountry = (CountryEntity) data.getSerializableExtra(Constants.KEY_COUNTRY);
                ui_txvCountry.setText(_selectedCountry.getCountryName());
            }
        } else if (requestCode == Constants.PICK_FROM_SCHOOL) {

            if (resultCode == RESULT_OK) {

                _selectedSchool = data.getStringExtra(Constants.KEY_SCHOOL);
                ui_edtSchool.setText(_selectedSchool);
            }
        } else if (requestCode == Constants.PICK_FROM_VILLAGE) {

            if (resultCode == RESULT_OK) {

                _selectedVillage = data.getStringExtra(Constants.KEY_VILLAGE);
                ui_edtVillage.setText(_selectedVillage);
            }
        }


        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                break;

            case R.id.txv_ok:
                onSkip();
                break;

            case R.id.txv_working1:
            case R.id.txv_working2:
            case R.id.txv_working3:
            case R.id.txv_working4:
            case R.id.txv_working5:
            case R.id.txv_working6:

                TextView txv1 = (TextView) view;
                ui_edtWorking.setText(txv1.getText());

                break;

            case R.id.txv_interest1:
            case R.id.txv_interest2:
            case R.id.txv_interest3:
            case R.id.txv_interest4:
            case R.id.txv_interest5:
            case R.id.txv_interest6:

                TextView txv2 = (TextView) view;
                ui_edtInterest.setText(txv2.getText());

                break;

            case R.id.txv_country:
            case R.id.txv_country2:
                gotoSelectCountry();
                break;

            case R.id.txv_school:
                gotoSelectSchool();
                break;

            case R.id.txv_village:
                gotoSelectVillage();
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
