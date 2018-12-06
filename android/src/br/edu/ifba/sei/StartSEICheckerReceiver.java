package br.edu.ifba.sei;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.util.Log;
import android.content.Intent;

public class StartSEICheckerReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.i("SEI-Mobile", "Escalonando job");
        Util.scheduleJob(context);
    }
}
