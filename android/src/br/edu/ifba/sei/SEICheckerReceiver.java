package br.edu.ifba.sei;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.util.Log;
import android.content.Intent;

public class SEICheckerReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.i("sei-mobile", "Scheduling job");
        Util.scheduleJob(context);
    }
}
