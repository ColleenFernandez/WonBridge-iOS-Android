package com.julyseven.wonbridge.wxapi;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import org.json.JSONException;
import org.json.JSONObject;

import com.julyseven.wonbridge.Chatting.LoggedInEvent;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.register.WechatLoggedInEvent;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import de.greenrobot.event.EventBus;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler {

	private IWXAPI api;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// setContentView(R.layout.entry);

		api = WXAPIFactory.createWXAPI(this, Constants.WECHAT_APP_ID, false);
		api.handleIntent(getIntent(), this);

		finish();
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

	@Override
	public void onResp(BaseResp resp) {
		int result = 0;

		switch (resp.errCode) {
		case BaseResp.ErrCode.ERR_OK:
			result = R.string.errcode_success;
			auth(resp);
			break;
		case BaseResp.ErrCode.ERR_USER_CANCEL:
			result = R.string.errcode_cancel;
			finishResp();
			break;
		case BaseResp.ErrCode.ERR_AUTH_DENIED:
			result = R.string.errcode_deny;
			finishResp();
			break;
		default:
			result = R.string.errcode_unknown;
			finishResp();
			break;
		}

	}

	public void finishResp() {

		new Thread() {
			@Override
			public void run () {
				try {
					Thread.sleep(500);
				} catch (Exception ex) {
					ex.printStackTrace();
				}

				EventBus.getDefault().post(new WechatLoggedInEvent(false, ""));
			}
		}.start();
	}

	private void auth(BaseResp resp) {
		Log.e("tag", "---ErrCode:" + resp.errCode);

		final String code = ((SendAuth.Resp) resp).code;

		new Thread() {
			public void run() {
				URL url;
				BufferedReader reader = null;
				String s = "";
				try {
					url = new URL(
							"https://api.weixin.qq.com/sns/oauth2/access_token?appid="
									+ Constants.WECHAT_APP_ID + "&secret="
									+ Constants.WECHAT_SECRET + "&code=" + code
									+ "&grant_type=authorization_code");
					URLConnection con = url.openConnection();
					reader = new BufferedReader(new InputStreamReader(
							con.getInputStream()));
					String line = reader.readLine().toString();
					s += line;
					while ((line = reader.readLine()) != null) {
						s = s + line;
					}
				} catch (MalformedURLException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					if (reader != null) {
						try {
							reader.close();
						} catch (IOException e) {
							e.printStackTrace();
						}
					}
				}
				Log.i("tag", "response: " + s);
				JSONObject jsonObj;
				String accessToken = "";
				String openId = "";
				try {
					jsonObj = new JSONObject(s);
					accessToken = jsonObj.getString("access_token");
					openId = jsonObj.getString("openid");

				} catch (JSONException e) {
					e.printStackTrace();
				}

				try {
					Thread.sleep(500);
				} catch (Exception ex) {
					ex.printStackTrace();
				}
				
				BufferedReader br = null;
				String response = "";

				try {
					URL userUrl = new URL(
							"https://api.weixin.qq.com/sns/userinfo?access_token="
									+ accessToken + "&openid=" + openId);
					URLConnection conn = userUrl.openConnection();
					br = new BufferedReader(new InputStreamReader(
							conn.getInputStream()));
					String tmpStr = br.readLine();
					response = tmpStr;
					if ((tmpStr = br.readLine()) != null) {
						response += tmpStr;
					}
				} catch (MalformedURLException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}

				Log.i("WECHAT", response);

				if (openId != null && openId.length() > 0) {

					String photoUrl = "";
					String nickname = "";

					if (response.length() > 0) {

						try {
							JSONObject jsonObject = new JSONObject(response);
							photoUrl = jsonObject.getString("headimgurl");
							nickname = jsonObject.getString("nickname");
							if (nickname.length() > 15)
								nickname = nickname.substring(0, 15);
						} catch (Exception ex) {
							ex.printStackTrace();
						}

					}

					Preference.getInstance().put(WXEntryActivity.this, PrefConst.PREFKEY_WECHAT_OPENID, openId);

					if (photoUrl.length() > 0)
						Preference.getInstance().put(WXEntryActivity.this, PrefConst.PREFKEY_WECHAT_PHOTOURL, photoUrl);

					if (nickname.length() > 0)
						Preference.getInstance().put(WXEntryActivity.this, PrefConst.PREFKEY_WECHAT_NICKNAME, nickname);

					EventBus.getDefault().post(new WechatLoggedInEvent(true, openId));
				} else
					EventBus.getDefault().post(new WechatLoggedInEvent(false, ""));
			};
		}.start();
	}
}