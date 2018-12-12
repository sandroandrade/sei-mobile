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

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.MediaType;

public class SEICheckerJobService extends JobService {

    public static final String EXTRA_MESSAGE = "br.edu.ifba.sei.MESSAGE";
    public static final String CHANNEL_ID = "br.edu.ifba.sei.MYCHANNEL";

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
        Log.i("SEI-Mobile", "Iniciando serviço");

        createNotificationChannel();

        Intent intent = new Intent(this, org.qtproject.qt5.android.bindings.QtActivity.class);
        intent.putExtra(EXTRA_MESSAGE, "Message from scheduled job!");
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);
        //startActivity(intent);

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

        Util.scheduleJob(getApplicationContext()); // reschedule the job

        Thread thread = new Thread(new Runnable(){
            private OkHttpClient client = new OkHttpClient.Builder()
                .connectTimeout(15, TimeUnit.SECONDS)
                .readTimeout(15, TimeUnit.SECONDS)
                .build();
            private String get(String url) throws IOException {
                Request request = new Request.Builder()
                    .url(url)
                    .build();

                try (Response response = client.newCall(request).execute()) {
                  return response.body().string();
                }
            }
            private String post(String url, String params) throws IOException {
                RequestBody body = RequestBody.create(MediaType.get("application/x-www-form-urlencoded"), params);
                Request request = new Request.Builder()
                    .url(url)
                    .post(body)
                    .build();
                try (Response response = client.newCall(request).execute()) {
                    return response.body().string();
                }
            }
            @Override
            public void run() {
                try {
                    String response = get("https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA&sigla_sistema=SEI");
                    Pattern r = Pattern.compile("name=\"hdnCaptcha\".*value=\"(.*)\"");
                    Matcher m = r.matcher(response);
                    String hdnCaptcha;
                    if(m.find())
                        hdnCaptcha = m.group(1);
//                    String response = post("https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA\&sigla_sistema=SEI",
//                                           "hdnCaptcha=" + internal.hdnCaptcha + "&hdnIdSistema=100000100&hdnMenuSistema=&hdnModuloSistema=&hdnSiglaOrgaoSistema=IFBA&hdnSiglaSistema=SEI&pwdSenha=iFba_4$s&sbmLogin=Acessar&selOrgao=0&txtUsuario=sandroandrade");

//                    int maxLogSize = 2000;
//                    for(int i = 0; i <= response.length() / maxLogSize; i++) {
//                        int start = i * maxLogSize;
//                        int end = (i+1) * maxLogSize;
//                        end = end > response.length() ? response.length() : end;
//                        Log.i("SEI-mobile", response.substring(start, end));
//                    }

                } catch (IOException e) {}
            }
        });
        thread.start();

        return true;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        return true;
    }

}
