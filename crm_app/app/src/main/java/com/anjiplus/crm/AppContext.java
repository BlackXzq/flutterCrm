package com.anjiplus.crm;

import android.support.multidex.MultiDexApplication;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSession;

/**
 * @author hailong .
 *         Create on 2018/1/12
 */

public class AppContext extends MultiDexApplication {
    private static AppContext mInstance;

    @Override
    public void onCreate() {
        super.onCreate();
        HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier() {
            @Override
            public boolean verify(String s, SSLSession sslSession) {
                return true;
            }
        });
        mInstance = this;
    }

    public static AppContext getInstance() {
        return mInstance;
    }
}
