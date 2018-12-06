package br.edu.ifba.sei;

import android.app.job.JobParameters;
import android.app.job.JobService;
import android.content.Intent;
import android.util.Log;
import android.widget.EditText;

public class SEICheckerJobService extends JobService {

    @Override
    public boolean onStartJob(JobParameters params) {
        Log.i("SEI-Mobile", "Iniciando serviço");
        Intent intent = new Intent(this, org.qtproject.qt5.android.bindings.QtActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
        Util.scheduleJob(getApplicationContext()); // reschedule the job
        return true;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        return true;
    }
}
