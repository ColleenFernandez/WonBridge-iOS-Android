package com.julyseven.wonbridge.Chatting;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.julyseven.wonbridge.commons.Constants;


/**
 * Created by JIS on 12/25/2015.
 */
public class ConnectionBroadcastReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {

        Intent mIntentForService = new Intent(context, ConnectionMgrService.class);
        mIntentForService.putExtra(Constants.XMPP_START, Constants.XMPP_FROMBROADCAST);
        context.startService(mIntentForService);

    }
}
