package com.julyseven.wonbridge.register;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
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

import org.json.JSONException;
import org.json.JSONObject;

public class InputPhoneActivity extends CommonActivity implements View.OnClickListener {

    EditText ui_edtphone, ui_edtCode;
    TextView ui_txvSend, ui_txvError, ui_txvCountry, ui_txvCountryCode;
    boolean _isVerified = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_input_phone);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.phone_signup));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_txvCountry = (TextView) findViewById(R.id.txv_country);
        ui_txvCountry.setOnClickListener(this);
        ui_txvCountry.setText(Commons.getCountryName(this));

        ui_txvCountryCode = (TextView) findViewById(R.id.txv_countrycode);
        ui_txvCountryCode.setText(Commons.getPhoneCode(this));

        ui_txvSend = (TextView) findViewById(R.id.txv_sendcode);
        ui_txvSend.setOnClickListener(this);

        TextView txvOk = (TextView) findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(this);

        TextView txvNext = (TextView) findViewById(R.id.txv_next);
        txvNext.setOnClickListener(this);

        ui_edtphone = (EditText) findViewById(R.id.edt_phone);
        ui_edtphone.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                ui_txvError.setVisibility(View.INVISIBLE);
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        ui_edtCode = (EditText) findViewById(R.id.edt_code);
        ui_edtCode.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                ui_txvError.setVisibility(View.INVISIBLE);
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        ui_txvError = (TextView) findViewById(R.id.txv_error);
        ui_txvError.setVisibility(View.INVISIBLE);

        TextView txvAgree = (TextView) findViewById(R.id.txv_agree);

        Spannable spannableString = new SpannableString(getString(R.string.agree_terms));
        spannableString.setSpan(new ForegroundColorSpan(Color.argb(0xff, 0x5f, 0x99, 0xfb)), 11, 15, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        spannableString.setSpan(new ForegroundColorSpan(Color.argb(0xff, 0x5f, 0x99, 0xfb)), 17, 26, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        txvAgree.setText(spannableString);

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtphone.getWindowToken(), 0);
                return false;
            }
        });
    }

    private void onSendCode() {

        if (ui_edtphone.length() == 0) {
            ui_txvError.setText(getString(R.string.input_phone));
            ui_txvError.setVisibility(View.VISIBLE);
            return;
        }

        ui_txvError.setVisibility(View.INVISIBLE);

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtphone.getWindowToken(), 0);

        sendCode();

    }

    public void sendCode(){

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETAUTHCODE;

        String phonenumber = ui_txvCountryCode.getText().toString().substring(1) + ui_edtphone.getText().toString();

        String params = String.format("/%s", phonenumber.toString());

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseCodeResponse(json);
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

    public void parseCodeResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                ui_txvSend.setText(getString(R.string.resend_code));
                showAlertDialog(getString(R.string.code_sent));
            }else {
                ui_txvError.setText(getString(R.string.exist_phone));
                ui_txvError.setVisibility(View.VISIBLE);
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }


    }

    private void onVerify() {

        if (ui_edtphone.length() == 0) {
            ui_txvError.setText(getString(R.string.input_phone));
            ui_txvError.setVisibility(View.VISIBLE);
            return;
        }

        if (ui_edtCode.getText().length() == 0) {
            ui_txvError.setText(getString(R.string.verify_code));
            ui_txvError.setVisibility(View.VISIBLE);
            return;
        }

        ui_txvError.setVisibility(View.INVISIBLE);

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtphone.getWindowToken(), 0);

        verifyCode();

    }

    private void verifyCode() {


        String url = ReqConst.SERVER_URL + ReqConst.REQ_CONFIRMAUTHCODE;

        String phonenumber = ui_txvCountryCode.getText().toString().substring(1) + ui_edtphone.getText().toString();

        String params = String.format("/%s/%s", phonenumber, ui_edtCode.getText().toString());

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseVerifyResponse(json);
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

    public void parseVerifyResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                _isVerified = true;
                showAlertDialog(getString(R.string.verify_success));
            }else {
                ui_txvError.setText(getString(R.string.wrong_code));
                ui_txvError.setVisibility(View.VISIBLE);
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }

    }

    private void onNext() {

        if (!_isVerified) {
            ui_txvError.setText(getString(R.string.verify_phone));
            ui_txvError.setVisibility(View.VISIBLE);
            return;
        }

        gotoProfile();
    }

    private void gotoProfile() {

        Intent intent = new Intent(InputPhoneActivity.this, InputProfileActivity.class);

        String phonenumber = ui_txvCountryCode.getText().toString().substring(1) + ui_edtphone.getText().toString();
        intent.putExtra(Constants.KEY_PHONENUMBER, phonenumber);
        startActivity(intent);
        finish();
    }

    private void gotoSelectCountry() {

        Intent intent = new Intent(InputPhoneActivity.this, SelectCountryActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_COUNTRY);
    }

    private void onBack() {
        finish();
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == Constants.PICK_FROM_COUNTRY) {

            if (resultCode == RESULT_OK) {

                CountryEntity country = (CountryEntity) data.getSerializableExtra(Constants.KEY_COUNTRY);
                ui_txvCountry.setText(country.getCountryName());
                ui_txvCountryCode.setText("+" + country.getCountryPhoneCode());
            }
        }

        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;

            case R.id.txv_sendcode:
                onSendCode();
                break;

            case R.id.txv_ok:
                onVerify();
                break;

            case R.id.txv_next:
                onNext();
                break;

            case R.id.txv_country:
                gotoSelectCountry();
                break;

        }

    }


}
