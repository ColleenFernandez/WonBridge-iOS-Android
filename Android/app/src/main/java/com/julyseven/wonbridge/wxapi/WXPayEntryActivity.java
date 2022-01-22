package com.julyseven.wonbridge.wxapi;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.mypage.WechatPayEvent;
import com.julyseven.wonbridge.register.WechatLoggedInEvent;
import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import de.greenrobot.event.EventBus;

public class WXPayEntryActivity extends CommonActivity implements IWXAPIEventHandler {


	private IWXAPI api;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.pay_result);

		api = WXAPIFactory.createWXAPI(this, Constants.WECHAT_APP_ID);
		api.handleIntent(getIntent(), this);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
		api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {

	}


	public void onSuccessResp() {

		new Thread() {
			@Override
			public void run () {
				try {
					Thread.sleep(500);
				} catch (Exception ex) {
					ex.printStackTrace();
				}

				EventBus.getDefault().post(new WechatPayEvent(true, ""));
			}
		}.start();
	}

	public void onFailedResp() {

		new Thread() {
			@Override
			public void run () {
				try {
					Thread.sleep(500);
				} catch (Exception ex) {
					ex.printStackTrace();
				}

				EventBus.getDefault().post(new WechatPayEvent(false, ""));
			}
		}.start();
	}

	@Override
	public void onResp(BaseResp resp) {

		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {

			if (resp.errCode == 0) {
				onSuccessResp();
			} else if (resp.errCode == -2) {

			} else {
				onFailedResp();
			}
			finish();
		}
	}
}