package br.edu.ifba.sei;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.job.JobParameters;
import android.app.job.JobService;
import android.content.Intent;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.util.Log;
import android.content.SharedPreferences;
import android.content.Context;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class SEICheckerJobService extends JobService {

    private static final String EXTRA_MESSAGE = "br.edu.ifba.sei.MESSAGE";
    private static final String CHANNEL_ID = "br.edu.ifba.sei.MYCHANNEL";
    public static final String PREFERENCE_ID = "br.edu.ifba.sei.PREFERENCE_FILE_KEY";

    public static void startMyService(Context ctx) {
        Log.i("sei-mobile", "Service scheduled? " + Util.isScheduled(ctx));
        if (!Util.isScheduled(ctx)) {
            Log.i("sei-mobile", "Scheduling service");
            Util.scheduleJob(ctx);
        }
    }

    private void createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "My Notification Channel";
            String description = "My Notification Channel";
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private int createID() {
        Date now = new Date();
        int id = Integer.parseInt(new SimpleDateFormat("ddHHmmss",  Locale.US).format(now));
        return id;
    }

    @Override
    public boolean onStartJob(JobParameters params) {
        Log.i("sei-mobile", "Initing service");

        SharedPreferences sharedPreferences = getSharedPreferences(PREFERENCE_ID, Context.MODE_PRIVATE);
        String login = sharedPreferences.getString("sei-mobile-login", null);
        String password = sharedPreferences.getString("sei-mobile-password", null);
        if (login == null || password == null || login.equals("") || password.equals("")) {
            Log.i("sei-mobile", "Service not configured!");
            Log.i("sei-mobile", "Scheduling job");
            Util.scheduleJob(getApplicationContext()); // reschedule the job
            return true;
        }
        else {
            Log.i("sei-mobile", "Service CONFIGURED! sei-mobile-login: " + login);
        }

        createNotificationChannel();

        Intent intent = new Intent(this, org.qtproject.qt5.android.bindings.QtActivity.class);
        intent.putExtra(EXTRA_MESSAGE, "Message from scheduled job!");
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.notification_icon)
                .setContentTitle("Message from scheduled job!")
                .setContentText("Here goes the message")
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true);

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);

        // notificationId is a unique int for each notification that you must define
        notificationManager.notify(createID(), mBuilder.build());

        Thread thread = new Thread(new SEICheckerThread(login, password));
        thread.start();
        try {
            thread.join();
            Log.i("sei-mobile", "Scheduling job");
            Util.scheduleJob(getApplicationContext()); // reschedule the job
        } catch (InterruptedException e) {}

        return true;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        return true;
    }
}
