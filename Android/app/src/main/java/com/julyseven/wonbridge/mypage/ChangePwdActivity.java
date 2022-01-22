package com.julyseven.wonbridge.mypage;

import android.content.Context;
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
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;

import org.json.JSONException;
import org.json.JSONObject;


public class ChangePwdActivity extends CommonActivity implements View.OnClickListener {


    EditText ui_edtCurrentPwd, ui_edtNewPwd, ui_edtPwdConfirm;
    TextView ui_txvConfirmError;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_change_pwd);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.change_pwd));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvCancel = (TextView) findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(this);

        TextView txvOkay = (TextView) findViewById(R.id.txv_ok);
        txvOkay.setOnClickListener(this);

        ui_edtCurrentPwd = (EditText) findViewById(R.id.edt_current_pwd);
        ui_edtNewPwd = (EditText) findViewById(R.id.edt_new_pwd);
        ui_edtPwdConfirm = (EditText) findViewById(R.id.edt_pwd_confirm);

        ui_txvConfirmError = (TextView) findViewById(R.id.txv_pwd_error);

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtCurrentPwd.getWindowToken(), 0);
                return false;
            }
        });
    }

    public boolean checkValid() {

        if (ui_edtCurrentPwd.getText().length() < 4 || ui_edtNewPwd.getText().length() < 4) {
            ui_txvConfirmError.setText(getString(R.string.input_pwd));
            ui_txvConfirmError.setVisibility(View.VISIBLE);
            return false;
        }

        if (!ui_edtNewPwd.getText().toString().equals(ui_edtPwdConfirm.getText().toString())) {
            ui_txvConfirmError.setText(getString(R.string.confirm_pwd_error));
            ui_txvConfirmError.setVisibility(View.VISIBLE);
            return false;
        }

        return true;
    }

    public void onChangePwd() {

        if (!checkValid())
            return;

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtCurrentPwd.getWindowToken(), 0);

        ui_txvConfirmError.setVisibility(View.INVISIBLE);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_CHANGEPASSWORD;

        String currentPwd = ui_edtCurrentPwd.getText().toString();
        String newPwd = ui_edtNewPwd.getText().toString();

        String params = String.format("/%d/%s/%s", Commons.g_user.get_idx(), currentPwd, newPwd);

        if (Commons.g_user.get_wechatId().length() > 0) {
            params = String.format("/%d/%s/%s", Commons.g_user.get_idx(), Constants.DEFAULT_WECHAT_PWD, Constants.DEFAULT_WECHAT_PWD);
        }

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parsePwdResponse(json);
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

    public void parsePwdResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                Commons.g_user.set_password(ui_edtNewPwd.getText().toString());
                Preference.getInstance().put(this, PrefConst.PREFKEY_USERPWD, Commons.g_user.get_password());
                finish();
            }else {
                ui_txvConfirmError.setText(getString(R.string.pwd_error));
                ui_txvConfirmError.setVisibility(View.VISIBLE);
            }
        }catch (JSONException e){

            e.printStackTrace();
            showAlertDialog(getString(R.string.error));
        }


    }

    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
            case R.id.txv_cancel:
                onBack();
                break;

            case R.id.txv_ok:
                onChangePwd();
                break;


        }

    }


}
