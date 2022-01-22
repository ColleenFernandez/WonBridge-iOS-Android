package com.julyseven.wonbridge.mypage;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.util.Xml;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
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
import com.julyseven.wonbridge.utils.MD5;
import com.julyseven.wonbridge.utils.Util;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.xmlpull.v1.XmlPullParser;

import java.io.StringReader;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;

import de.greenrobot.event.EventBus;

public class ChargeVipActivity extends CommonActivity implements View.OnClickListener {


    PayReq req;
    IWXAPI msgApi;
    Map<String, String> resultunifiedorder;
    StringBuffer sb;

    FrameLayout ui_fltSilver, ui_fltGold, ui_fltDiamond;
    ImageView ui_imvSilver, ui_imvGold, ui_imvDiamond;

    int _curMode = -1;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_charge_vip);

        msgApi = WXAPIFactory.createWXAPI(this, Constants.WECHAT_APP_ID, false);

        req = new PayReq();
        sb = new StringBuffer();

        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.charge_vip));

        ui_fltSilver = (FrameLayout) findViewById(R.id.flt_silver);
        ui_imvSilver = (ImageView) findViewById(R.id.imv_silver_open);

        ui_fltGold = (FrameLayout) findViewById(R.id.flt_gold);
        ui_imvGold = (ImageView) findViewById(R.id.imv_gold_open);

        ui_fltDiamond = (FrameLayout) findViewById(R.id.flt_diamond);
        ui_imvDiamond = (ImageView) findViewById(R.id.imv_diamond_open);

        RelativeLayout rltSilver = (RelativeLayout) findViewById(R.id.rlt_silver);
        rltSilver.setOnClickListener(this);

        RelativeLayout rltGold = (RelativeLayout) findViewById(R.id.rlt_gold);
        rltGold.setOnClickListener(this);

        RelativeLayout rltDiamond = (RelativeLayout) findViewById(R.id.rlt_diamond);
        rltDiamond.setOnClickListener(this);

        TextView txvPay1 = (TextView) ui_fltSilver.findViewById(R.id.txv_wechatpay);
        txvPay1.setOnClickListener(this);

        TextView txvPay2 = (TextView) ui_fltGold.findViewById(R.id.txv_wechatpay);
        txvPay2.setOnClickListener(this);

        TextView txvPay3 = (TextView) ui_fltDiamond.findViewById(R.id.txv_wechatpay);
        txvPay3.setOnClickListener(this);

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        selectMode(0);

    }

    public void selectMode(int mode) {

        if (_curMode == mode)
            return;

        _curMode = mode;

        ui_fltSilver.setVisibility(View.GONE);
        ui_fltGold.setVisibility(View.GONE);
        ui_fltDiamond.setVisibility(View.GONE);

        ui_imvSilver.setBackgroundResource(R.drawable.icon_fold);
        ui_imvGold.setBackgroundResource(R.drawable.icon_fold);
        ui_imvDiamond.setBackgroundResource(R.drawable.icon_fold);

        switch (mode) {

            case 0:     // silver
                ui_fltSilver.setVisibility(View.VISIBLE);
                ui_imvSilver.setBackgroundResource(R.drawable.icon_opened);
                break;

            case 1: // gold
                ui_fltGold.setVisibility(View.VISIBLE);
                ui_imvGold.setBackgroundResource(R.drawable.icon_opened);
                break;

            case 2: // diamond
                ui_fltDiamond.setVisibility(View.VISIBLE);
                ui_imvDiamond.setBackgroundResource(R.drawable.icon_opened);
                break;


        }
    }


    public void onWechatPay() {

        if (msgApi.isWXAppSupportAPI()) {

            GetPrepayIdTask getPrepayId = new GetPrepayIdTask();
            getPrepayId.execute();
        } else {
            showAlertDialog(getString(R.string.install_wechat));
        }
    }

    private void onBack() {
        finish();
    }


    private String genPackageSign(List<NameValuePair> params) {
        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < params.size(); i++) {
            sb.append(params.get(i).getName());
            sb.append('=');
            sb.append(params.get(i).getValue());
            sb.append('&');
        }
        sb.append("key=");
        sb.append(Constants.WECHAT_SECRET);

        String packageSign = MD5.getMessageDigest(sb.toString().getBytes()).toUpperCase();
        Log.e("orion", packageSign);
        return packageSign;
    }

    private String genAppSign(List<NameValuePair> params) {
        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < params.size(); i++) {
            sb.append(params.get(i).getName());
            sb.append('=');
            sb.append(params.get(i).getValue());
            sb.append('&');
        }
        sb.append("key=");
        sb.append(Constants.WECHAT_SECRET);

        this.sb.append("sign str\n" + sb.toString() + "\n\n");
        String appSign = MD5.getMessageDigest(sb.toString().getBytes()).toUpperCase();
        Log.e("orion", appSign);
        return appSign;
    }

    private String toXml(List<NameValuePair> params) {
        StringBuilder sb = new StringBuilder();
        sb.append("<xml>");
        for (int i = 0; i < params.size(); i++) {
            sb.append("<" + params.get(i).getName() + ">");

            sb.append(params.get(i).getValue());
            sb.append("</" + params.get(i).getName() + ">");
        }
        sb.append("</xml>");

        Log.e("orion", sb.toString());
        return sb.toString();
    }

    private class GetPrepayIdTask extends AsyncTask<Void, Void, Map<String, String>> {

        private ProgressDialog dialog;

        @Override
        protected void onPreExecute() {
            dialog = ProgressDialog.show(ChargeVipActivity.this, getString(R.string.app_tip),
                    getString(R.string.getting_prepayid));
        }

        @Override
        protected void onPostExecute(Map<String, String> result) {
            if (dialog != null) {
                dialog.dismiss();
            }
            sb.append("prepay_id\n" + result.get("prepay_id") + "\n\n");
            // show.setText(sb.toString());

            resultunifiedorder = result;

            // 获取支付请求数据，发起支付请求
            genPayReq();
        }

        @Override
        protected void onCancelled() {
            super.onCancelled();
        }

        @Override
        protected Map<String, String> doInBackground(Void... params) {

            String url = String.format("https://api.mch.weixin.qq.com/pay/unifiedorder");
            String entity = genProductArgs();

            Log.e("orion", entity);

            byte[] buf = Util.httpPost(url, entity);

            String content = new String(buf);
            Log.e("orion", content);
            Map<String, String> xml = decodeXml(content);

            return xml;
        }
    }

    public Map<String, String> decodeXml(String content) {

        try {
            Map<String, String> xml = new HashMap<String, String>();
            XmlPullParser parser = Xml.newPullParser();
            parser.setInput(new StringReader(content));
            int event = parser.getEventType();
            while (event != XmlPullParser.END_DOCUMENT) {

                String nodeName = parser.getName();
                switch (event) {
                    case XmlPullParser.START_DOCUMENT:

                        break;
                    case XmlPullParser.START_TAG:

                        if ("xml".equals(nodeName) == false) {
                            // 实例化student对象
                            xml.put(nodeName, parser.nextText());
                        }
                        break;
                    case XmlPullParser.END_TAG:
                        break;
                }
                event = parser.next();
            }

            return xml;
        } catch (Exception e) {
            Log.e("orion", e.toString());
        }
        return null;

    }

    private String genNonceStr() {
        Random random = new Random();
        return MD5.getMessageDigest(String.valueOf(random.nextInt(10000)).getBytes());
    }

    private long genTimeStamp() {
        return System.currentTimeMillis() / 1000;
    }

    private String genOutTradNo() {
        Random random = new Random();
        return MD5.getMessageDigest(String.valueOf(random.nextInt(10000)).getBytes());
    }

    //
    private String genProductArgs() {
        // StringBuffer xml = new StringBuffer();

        try {
            String nonceStr = genNonceStr();

            // xml.append("</xml>");
            List<NameValuePair> packageParams = new LinkedList<NameValuePair>();
            packageParams.add(new BasicNameValuePair("appid", Constants.WECHAT_APP_ID));
            packageParams.add(new BasicNameValuePair("body", "Membership"));
            packageParams.add(new BasicNameValuePair("mch_id", Constants.MCH_ID));
            packageParams.add(new BasicNameValuePair("nonce_str", nonceStr));
            packageParams.add(new BasicNameValuePair("notify_url", "http://weixin.qq.com"));
            packageParams.add(new BasicNameValuePair("out_trade_no", genOutTradNo()));
            packageParams.add(new BasicNameValuePair("spbill_create_ip", "127.0.0.1"));//"127.0.0.1"
            packageParams.add(new BasicNameValuePair("total_fee", "2000"));
            packageParams.add(new BasicNameValuePair("trade_type", "APP"));

            String sign = genPackageSign(packageParams);
            packageParams.add(new BasicNameValuePair("sign", sign));

            String xmlstring = toXml(packageParams);

            return xmlstring;

        } catch (Exception e) {
            Log.e("TAG", "genProductArgs fail, ex = " + e.getMessage());
            return null;
        }

    }



    private void genPayReq() {

        req.appId = Constants.WECHAT_APP_ID;
        req.partnerId = Constants.MCH_ID;
        req.prepayId = resultunifiedorder.get("prepay_id");
        req.packageValue = "Sign=WXPay";
        req.nonceStr =  resultunifiedorder.get("nonce_str");//genNonceStr();
        req.timeStamp = String.valueOf(genTimeStamp());

        List<NameValuePair> signParams = new LinkedList<NameValuePair>();
        signParams.add(new BasicNameValuePair("appid", req.appId));
        signParams.add(new BasicNameValuePair("noncestr", req.nonceStr));
        signParams.add(new BasicNameValuePair("package", req.packageValue));
        signParams.add(new BasicNameValuePair("partnerid", req.partnerId));
        signParams.add(new BasicNameValuePair("prepayid", req.prepayId));
        signParams.add(new BasicNameValuePair("timestamp", req.timeStamp));

        req.sign = genAppSign(signParams);

        sb.append("sign\n" + req.sign + "\n\n");

        sendPayReq();
    }

    /**
     * 发起支付请求
     */
    private void sendPayReq() {
        msgApi.registerApp(Constants.WECHAT_APP_ID);
        msgApi.sendReq(req);
    }


    public void onSuccessPay(int ammount) {

        showProgress();

        String url = ReqConst.SERVER_URL + ReqConst.REQ_SETPAYMENT;

        String params = String.format("/%d/%d", Commons.g_user.get_idx(), ammount);

        url += params;

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String json) {

                parsePayResponse(json);
            }
        }, new Response.ErrorListener(){
            @Override
            public void onErrorResponse(VolleyError error) {
                closeProgress();
            }
        });

        stringRequest.setRetryPolicy(new DefaultRetryPolicy(Constants.VOLLEY_TIME_OUT,
                0, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));

        WonBridgeApplication.getInstance().addToRequestQueue(stringRequest, url);
    }

    public void parsePayResponse(String json) {

        closeProgress();
        showAlertDialog(getString(R.string.success_wechat_pay));
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;

            case R.id.txv_wechatpay:
                onWechatPay();
                break;

            case R.id.rlt_silver:
                selectMode(0);
                break;

            case R.id.rlt_gold:
                selectMode(1);
                break;

            case R.id.rlt_diamond:
                selectMode(2);
                break;
        }

    }

    public void onEventMainThread(final WechatPayEvent event) {

        runOnUiThread(new Runnable() {
            @Override
            public void run() {

                if(event.isSuccessful()) {
                    onSuccessPay(20);
                } else {
                    showAlertDialog(getString(R.string.failed_wechat_pay));
                }
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        EventBus.getDefault().register(this);
    }

    @Override
    public void onStop() {
        EventBus.getDefault().unregister(this);
        super.onStop();
    }


}
