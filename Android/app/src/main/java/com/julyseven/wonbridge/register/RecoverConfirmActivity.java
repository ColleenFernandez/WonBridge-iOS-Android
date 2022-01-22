package com.julyseven.wonbridge.register;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
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
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.commons.ReqConst;

import org.json.JSONException;
import org.json.JSONObject;

public class RecoverConfirmActivity extends CommonActivity implements View.OnClickListener {

    EditText ui_edtEmail, ui_edtCode;
    TextView ui_txvSend, ui_txvError;
    boolean _isVerified = false;

    String _email;
    String _phone;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recover_confirm);

        _email = getIntent().getStringExtra("email");
        _phone = getIntent().getStringExtra("phone");
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.recover_title));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        ui_txvSend = (TextView) findViewById(R.id.txv_sendcode);
        ui_txvSend.setOnClickListener(this);

        TextView txvOk = (TextView) findViewById(R.id.txv_ok);
        txvOk.setOnClickListener(this);

        ui_edtEmail = (EditText) findViewById(R.id.edt_email);
        ui_edtEmail.setEnabled(false);

        if (_email != null)
            ui_edtEmail.setText(_email);
        else
            ui_edtEmail.setText("+" + _phone);

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

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtCode.getWindowToken(), 0);
                return false;
            }
        });
    }

    private void onSendCode() {

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtCode.getWindowToken(), 0);

        ui_txvError.setVisibility(View.INVISIBLE);

        sendCode();

    }

    public void sendCode(){

        String url = ReqConst.SERVER_URL + ReqConst.REQ_GETRECOVERYCODE;

        String params;

        if (_email != null)
            params = String.format("/%s", _email);
        else
            params = String.format("/%s", _phone);

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
                ui_txvError.setText(getString(R.string.not_registered_user));
                ui_txvError.setVisibility(View.VISIBLE);
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }


    }

    private void onVerify() {

        if (ui_edtCode.getText().length() == 0) {
            ui_txvError.setText(getString(R.string.verify_code));
            ui_txvError.setVisibility(View.VISIBLE);
            return;
        }

        ui_txvError.setVisibility(View.INVISIBLE);

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtEmail.getWindowToken(), 0);

        verifyCode();

    }

    private void verifyCode() {

        String url = ReqConst.SERVER_URL + ReqConst.REQ_TEMPPASSWORD;

        String params;

        if (_email != null)
            params = String.format("/%s", _email);
        else
            params = String.format("/%s", _phone);

        params += String.format("/%s", ui_edtCode.getText().toString());

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

                String tempPwd = object.getString(ReqConst.RES_RESTEMPPWD);

                showPassword(tempPwd);

            } else {
                ui_txvError.setText(getString(R.string.wrong_code));
                ui_txvError.setVisibility(View.VISIBLE);
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }
    }

    public void showPassword(String pwd) {

        AlertDialog alertDialog = new AlertDialog.Builder(_context).create();

        alertDialog.setTitle(getString(R.string.app_name));
        alertDialog.setMessage(getString(R.string.temp_pwd_prefix) + String.format(" \"%s\".", pwd) + getString(R.string.temp_pwd_suffix));

        alertDialog.setButton(AlertDialog.BUTTON_POSITIVE, _context.getString(R.string.ok),

                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        finish();
                    }
                });
        //alertDialog.setIcon(R.drawable.banner);
        alertDialog.show();

    }

    private void onBack() {
        finish();
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

        }

    }


}
