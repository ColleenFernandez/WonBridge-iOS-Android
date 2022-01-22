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

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URLEncoder;

public class ChangeNicknameActivity extends CommonActivity implements View.OnClickListener {


    TextView ui_txvExist;
    EditText ui_edtNickName;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_change_nickname);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.change_nickname));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvCancel = (TextView) findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(this);

        TextView txvOkay = (TextView) findViewById(R.id.txv_ok);
        txvOkay.setOnClickListener(this);

        ImageView imvDelete = (ImageView) findViewById(R.id.imv_delete);
        imvDelete.setOnClickListener(this);

        ui_txvExist = (TextView) findViewById(R.id.txv_exist_nick);

        ui_edtNickName = (EditText) findViewById(R.id.edt_ncikname);
        ui_edtNickName.setText(Commons.g_user.get_name());

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtNickName.getWindowToken(), 0);
                return false;
            }
        });
    }

    public void onChangeName() {

        if (ui_edtNickName.getText().length() < 2) {
            ui_txvExist.setText(getString(R.string.input_nickname));
            ui_txvExist.setVisibility(View.VISIBLE);
            return;
        }

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtNickName.getWindowToken(), 0);

        ui_txvExist.setVisibility(View.INVISIBLE);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_CHANGENICKNAME;

        String nickname = ui_edtNickName.getText().toString().replace(" ", "%20");
        nickname = nickname.replace("/", Constants.SLASH);

        try {
            nickname = URLEncoder.encode(nickname, "utf-8");
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), nickname);

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseNicknameResponse(json);
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

    public void parseNicknameResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                Commons.g_user.set_name(ui_edtNickName.getText().toString());
                setResult(RESULT_OK);
                finish();
            }else {
                ui_txvExist.setText(getString(R.string.exist_nickname));
                ui_txvExist.setVisibility(View.VISIBLE);
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
                onChangeName();
                break;

            case R.id.imv_delete:
                ui_edtNickName.setText("");
                break;

        }

    }


}
