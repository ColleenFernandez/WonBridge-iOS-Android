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

public class ChangeInterestActivity extends CommonActivity implements View.OnClickListener {


    EditText ui_edtInterest;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_change_interest);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.change_interest));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvCancel = (TextView) findViewById(R.id.txv_cancel);
        txvCancel.setOnClickListener(this);

        TextView txvOkay = (TextView) findViewById(R.id.txv_ok);
        txvOkay.setOnClickListener(this);

        ImageView imvDelete = (ImageView) findViewById(R.id.imv_delete);
        imvDelete.setOnClickListener(this);

        ui_edtInterest = (EditText) findViewById(R.id.edt_interest);
        ui_edtInterest.setText(Commons.g_user.get_interest());

        LinearLayout lytContainer = (LinearLayout) findViewById(R.id.lyt_container);
        lytContainer.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(ui_edtInterest.getWindowToken(), 0);
                return false;
            }
        });


        int[] ids = { R.id.txv_interest1, R.id.txv_interest2, R.id.txv_interest3,
                R.id.txv_interest4, R.id.txv_interest5, R.id.txv_interest6};

        for (int i = 0; i < ids.length; i++) {
            TextView txv = (TextView) findViewById(ids[i]);
            txv.setOnClickListener(this);
        }

    }

    public void onChangeInterest() {

        if (ui_edtInterest.getText().length() == 0) {
            return;
        }

        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(ui_edtInterest.getWindowToken(), 0);

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETINTEREST;

        String working = ui_edtInterest.getText().toString().replace(" ", "%20");
        working = working.replace("/", Constants.SLASH);

        try {
            working = URLEncoder.encode(working, "utf-8");
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String params = String.format("/%d/%s", Commons.g_user.get_idx(), working);

        url += params;

        showProgress();

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parseInterestResponse(json);
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

    public void parseInterestResponse(String json){

        closeProgress();

        try{

            JSONObject object = new JSONObject(json);

            int result_code = object.getInt(ReqConst.RES_CODE);

            if(result_code == ReqConst.CODE_SUCCESS){
                Commons.g_user.set_interest(ui_edtInterest.getText().toString());
                setResult(RESULT_OK);
                finish();
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
                onChangeInterest();
                break;

            case R.id.imv_delete:
                ui_edtInterest.setText("");
                break;

            case R.id.txv_interest1:
            case R.id.txv_interest2:
            case R.id.txv_interest3:
            case R.id.txv_interest4:
            case R.id.txv_interest5:
            case R.id.txv_interest6:

                TextView txv1 = (TextView) view;
                ui_edtInterest.setText(txv1.getText());

                break;

        }

    }


}
