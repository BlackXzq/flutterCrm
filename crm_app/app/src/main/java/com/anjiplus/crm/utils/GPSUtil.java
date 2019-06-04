package com.anjiplus.crm.utils;

import android.app.Activity;
import android.content.Context;
import android.location.LocationManager;
import android.os.Build;
import android.provider.Settings;

/**
 * @author hailong .
 *         Create on 2018/2/2
 */

public class GPSUtil {
    public static boolean isOpen(Activity mContext) {
        if (Build.VERSION.SDK_INT < 19) {
            LocationManager myLocationManager = (LocationManager) mContext.getSystemService(Context.LOCATION_SERVICE);
            return myLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        } else {
            int state = Settings.Secure.getInt(mContext.getContentResolver(), Settings.Secure.LOCATION_MODE, Settings.Secure.LOCATION_MODE_OFF);
            if (state == Settings.Secure.LOCATION_MODE_OFF) {
                return false;
            } else {
                return true;
            }
        }
    }
}
