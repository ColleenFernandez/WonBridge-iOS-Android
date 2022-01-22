package com.julyseven.wonbridge;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.julyseven.wonbridge.commons.Constants;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;


public class AppRegister extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		final IWXAPI api = WXAPIFactory.createWXAPI(context, null);

		api.registerApp(Constants.WECHAT_APP_ID);
	}
}
