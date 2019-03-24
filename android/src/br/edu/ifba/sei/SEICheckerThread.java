package br.edu.ifba.sei;

import java.lang.Runnable;

import android.util.Log;

import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.FormBody;
import okhttp3.CookieJar;
import okhttp3.Cookie;
import okhttp3.HttpUrl;

import java.io.IOException;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.List;
import java.util.ArrayList;

import okhttp3.logging.HttpLoggingInterceptor;

import okio.Buffer;

class SEICheckerThread implements Runnable
{
    private OkHttpClient client = new OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
//        .addInterceptor(new HttpLoggingInterceptor().setLevel(HttpLoggingInterceptor.Level.BODY))
        .cookieJar(new MyCookieJar())
        .build();

    private String login = null;
    private String password = null;

    private class MyCookieJar implements CookieJar {
        private List<Cookie> cookies;

        @Override
        public void saveFromResponse(HttpUrl url, List<Cookie> cookies) {
            this.cookies =  cookies;
        }

        @Override
        public List<Cookie> loadForRequest(HttpUrl url) {
            if (cookies != null)
                return cookies;
            return new ArrayList<Cookie>();
        }
    }

    private String get(String url) throws IOException {
        Log.i("SEI-mobile", "Using client: " + client);
        Request request = new Request.Builder()
            .url(url)
            .build();

        try (Response response = client.newCall(request).execute()) {
          return response.body().string();
        }
    }

    private String bodyToString(final RequestBody request){
            try {
                final RequestBody copy = request;
                final Buffer buffer = new Buffer();
                copy.writeTo(buffer);
                return buffer.readUtf8();
            }
            catch (final IOException e) {
                return "did not work";
            }
    }

    private String post(String url, String params, String hdnCaptcha) throws IOException {
        Log.i("SEI-mobile", "Using client: " + client);
        Log.i("SEI-mobile", "Tentando logar com hdnCaptcha: " + hdnCaptcha);
        RequestBody requestBody = new FormBody.Builder()
                .add("hdnCaptcha", hdnCaptcha)
                .add("hdnIdSistema", "100000100")
                .add("hdnMenuSistema", "")
                .add("hdnModuloSistema", "")
                .add("hdnSiglaOrgaoSistema", "IFBA")
                .add("pwdSenha", password)
                .add("hdnSiglaSistema", "SEI")
                .add("sbmLogin", "Acessar")
                .add("selOrgao", "0")
                .add("txtUsuario", login)
                .build();

        Request request = new Request.Builder()
                .addHeader("Content-Type", "application/x-www-form-urlencoded")
                .url(url)
                .post(requestBody)
                .build();

        try (Response response = client.newCall(request).execute()) {
            Log.i("SEI-mobile", "Return code: " + response.code());
            return response.body().string();
        }
    }

    public SEICheckerThread(String login, String password) {
        this.login = login;
        this.password = password;
    }

    @Override
    public void run() {
        try {
            String response = get("https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA&sigla_sistema=SEI");
            Pattern r = Pattern.compile("name=\"hdnCaptcha\".*value=\"(.*)\"");
            Matcher m = r.matcher(response);
            String hdnCaptcha;
            if(m.find()) {
                hdnCaptcha = m.group(1);
                response = post("https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA&sigla_sistema=SEI",
                                "hdnCaptcha=" + hdnCaptcha + "&hdnIdSistema=100000100&hdnMenuSistema=&hdnModuloSistema=&hdnSiglaOrgaoSistema=IFBA&hdnSiglaSistema=SEI&pwdSenha=iFba_4$s&sbmLogin=Acessar&selOrgao=0&txtUsuario=sandroandrade",
                                hdnCaptcha);

//                        int maxLogSize = 2000;
//                        for(int i = 0; i <= response.length() / maxLogSize; i++) {
//                            int start = i * maxLogSize;
//                            int end = (i+1) * maxLogSize;
//                            end = end > response.length() ? response.length() : end;
//                            Log.i("SEI-mobile", response.substring(start, end));
//                        }
                r = Pattern.compile("<title>(.*?)</title>");
                m = r.matcher(response);
                if(m.find())
                    Log.i("SEI-mobile", "Title: " + m.group(1));
            }
        } catch (IOException e) {}
    }
}
