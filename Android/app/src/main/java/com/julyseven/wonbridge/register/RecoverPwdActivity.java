package com.julyseven.wonbridge.register;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
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

public class RecoverPwdActivity extends CommonActivity implements View.OnClickListener {

    EditText ui_edtEmail;
    TextView ui_txvSend, ui_txvOk, ui_txvCountry, ui_txvError;
    LinearLayout ui_lytCountry;

    CountryEntity _selectedCountry;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recover_pwd);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.recover_title));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_lytCountry = (LinearLayout) findViewById(R.id.lyt_country);
        ui_lytCountry.setVisibility(View.GONE);

        ui_txvCountry = (TextView) findViewById(R.id.txv_country);
        ui_txvCountry.setOnClickListener(this);

        ui_txvSend = (TextView) findViewById(R.id.txv_sendcode);
        ui_txvSend.setOnClickListener(this);

        ui_txvOk = (TextView) findViewById(R.id.txv_ok);
        ui_txvOk.setVisibility(View.GONE);
        ui_txvOk.setOnClickListener(this);

        ui_edtEmail = (EditText) findViewById(R.id.edt_phone);

        ui_txvError = (TextView) findViewById(R.id.txv_error);
        ui_txvError.setText(getString(R.string.social_pwd_forget));

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                hideKeyboard();
                return false;
            }
        });

        ui_edtEmail.addTextChangedListener(new TextWatcher() {
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
    }

    public void hideKeyboard() {

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtEmail.getWindowToken(), 0);
    }

    public void onSendCode() {

        hideKeyboard();

        String email = ui_edtEmail.getText().toString();

        ui_txvError.setVisibility(View.INVISIBLE);

        if (Commons.isValidMail(email)) {
            sendCode(email, true);
        } else if (Commons.isValidMobile(email)) {
            gotoRecoverPhone();
        } else {
            ui_txvError.setVisibility(View.VISIBLE);
            ui_txvError.setText(getString(R.string.input_right_email_phone));
        }

    }

    public void sendCode(final String emailOrPhone, final boolean isEmail){

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETRECOVERYCODE;

        String params = String.format("/%s", emailOrPhone);

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseCodeResponse(json, emailOrPhone, isEmail);
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

    public void parseCodeResponse(String json, String emailOrPhone,  boolean isEmail){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                gotoRecoverConfirm(emailOrPhone, isEmail);
            }else {
                ui_txvError.setText(getString(R.string.not_registered_user));
                ui_txvError.setVisibility(View.VISIBLE);
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }


    }

    public void gotoRecoverConfirm(String emailOrPhone, boolean isEmail) {

        Intent intent = new Intent(RecoverPwdActivity.this, RecoverConfirmActivity.class);

        if (isEmail)
            intent.putExtra("email", emailOrPhone);
        else
            intent.putExtra("phone", emailOrPhone);

        startActivity(intent);
        finish();
    }


    public void gotoRecoverPhone() {

        ui_lytCountry.setVisibility(View.VISIBLE);
        ui_txvOk.setVisibility(View.VISIBLE);
        ui_txvSend.setVisibility(View.GONE);
    }

    private void gotoSelectCountry() {

        Intent intent = new Intent(RecoverPwdActivity.this, SelectCountryActivity.class);
        startActivityForResult(intent, Constants.PICK_FROM_COUNTRY);
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
        }

        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;


            case R.id.txv_country:
                gotoSelectCountry();
                break;

            case R.id.txv_sendcode:
                onSendCode();
                break;

            case R.id.txv_ok:

                String code = "86";

                if (_selectedCountry != null)
                    code = _selectedCountry.getCountryPhoneCode();

                String phone = code + ui_edtEmail.getText().toString();
                sendCode(phone, false);
                break;

        }

    }


}
