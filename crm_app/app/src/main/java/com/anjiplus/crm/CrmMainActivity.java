package com.anjiplus.crm;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.anji.plus.crm.R;
import com.anjiplus.crm.utils.Commons;
import com.anjiplus.crm.utils.GPSUtil;
import com.anjiplus.crm.utils.StatusbarUtil;
import com.zbar.lib.CaptureActivity;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Map;

import io.flutter.facade.Flutter;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.view.FlutterView;

public class CrmMainActivity extends AppCompatActivity {
    private static final String TAG = "FtpMainActivity";
    private FlutterView flutterView;
    //权限
    private BasicMessageChannel permissionChannel;
    private MethodChannel.Result permissionResult;

    //扫描
    private BasicMessageChannel scanChannel;
    private MethodChannel.Result scanResult;

    private int scanRequestCode = 0x11;

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
    }

    public static String getJson(String fileName, Context context) {
        //将json数据变成字符串
        StringBuilder stringBuilder = new StringBuilder();
        try {
            //获取assets资源管理器
            AssetManager assetManager = context.getAssets();
            //通过管理器打开文件并读取
            BufferedReader bf = new BufferedReader(new InputStreamReader(
                    assetManager.open(fileName)));
            String line;
            while ((line = bf.readLine()) != null) {
                stringBuilder.append(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return stringBuilder.toString();
    }

    @SuppressLint("InlinedApi")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            finish();
            return;
        }
        View v1 = getLayoutInflater().inflate(R.layout.activity_main, null);
        setContentView(v1);
        StatusbarUtil.transparentLightStatusBar(this);
        flutterView = Flutter.createView(this, getLifecycle(), "route");

        //初始化，flutter装入Activity
        final LinearLayout layout = findViewById(R.id.ll_header_mainactivity1);
        layout.addView(flutterView);
        final FlutterView.FirstFrameListener[] listeners = new FlutterView.FirstFrameListener[1];
        listeners[0] = new FlutterView.FirstFrameListener() {
            @Override
            public void onFirstFrame() {
                layout.setVisibility(View.VISIBLE);
            }
        };
        flutterView.addFirstFrameListener(listeners[0]);

        //版本更新
        new MethodChannel(flutterView, Commons.apkinstallChannel).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if (methodCall.method.equals(Commons.apkInstallMethod)) {
                            Object parameter = methodCall.arguments();
                            if (parameter instanceof Map) {
                                String value = (String) ((Map) parameter).get("path");
                                PackageInstaller.installApk(getApplicationContext(), value);
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );

        //权限
        permissionChannel = new BasicMessageChannel<String>(
                flutterView, Commons.permissionChannel, StringCodec.INSTANCE);
        permissionChannel.setMessageHandler((o, reply) -> {

        });

        //权限管理
        new MethodChannel(flutterView, Commons.permissionChannel).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if (methodCall.method.equals(Commons.permissionMethod)) {
                            CrmMainActivity.this.permissionResult = result;
                            requestPermission(methodCall.argument("permission"));
                        } else if (methodCall.method.equals(Commons.openSettingsMethod)) {
                            openSettings();
                        } else if (methodCall.method.equals(Commons.openGpsServiceMethod)) {
                            //位置服务，gps定位
                            if (!GPSUtil.isOpen(CrmMainActivity.this)) {
                                Toast.makeText(CrmMainActivity.this, "请打开定位服务", Toast.LENGTH_LONG).show();
                                Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                                startActivityForResult(intent, 0x22);
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );


        //条形码/二维码扫描
        scanChannel = new BasicMessageChannel<String>(
                flutterView, Commons.scanChannel, StringCodec.INSTANCE);
        scanChannel.setMessageHandler((o, reply) -> {

        });
        new MethodChannel(flutterView, Commons.scanChannel).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if (methodCall.method.equals(Commons.scanMethod)) {
                            CrmMainActivity.this.scanResult = result;
                            Intent intent = new Intent(CrmMainActivity.this, CaptureActivity.class);
                            startActivityForResult(intent, scanRequestCode);
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );
    }

    /************** 权限部分 **************/
    private void openSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:" + getPackageName()));
        intent.addCategory(Intent.CATEGORY_DEFAULT);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }


    private String getManifestPermission(String permission) {
        String res;
        switch (permission) {
            case "RECORD_AUDIO":
                res = Manifest.permission.RECORD_AUDIO;
                break;
            case "CALL_PHONE":
                res = Manifest.permission.CALL_PHONE;
                break;
            case "CAMERA":
                res = Manifest.permission.CAMERA;
                break;
            case "WRITE_EXTERNAL_STORAGE":
                res = Manifest.permission.WRITE_EXTERNAL_STORAGE;
                break;
            case "READ_EXTERNAL_STORAGE":
                res = Manifest.permission.READ_EXTERNAL_STORAGE;
                break;
            case "READ_PHONE_STATE":
                res = Manifest.permission.READ_PHONE_STATE;
                break;
            case "ACCESS_FINE_LOCATION":
                res = Manifest.permission.ACCESS_FINE_LOCATION;
                break;
            case "ACCESS_COARSE_LOCATION":
                res = Manifest.permission.ACCESS_COARSE_LOCATION;
                break;
            case "WHEN_IN_USE_LOCATION":
                res = Manifest.permission.ACCESS_FINE_LOCATION;
                break;
            case "ALWAYS_LOCATION":
                res = Manifest.permission.ACCESS_FINE_LOCATION;
                break;
            case "READ_CONTACTS":
                res = Manifest.permission.READ_CONTACTS;
                break;
            case "SEND_SMS":
                res = Manifest.permission.SEND_SMS;
                break;
            case "READ_SMS":
                res = Manifest.permission.READ_SMS;
                break;
            case "VIBRATE":
                res = Manifest.permission.VIBRATE;
                break;
            case "WRITE_CONTACTS":
                res = Manifest.permission.WRITE_CONTACTS;
                break;
            default:
                res = "ERROR";
                break;
        }
        return res;
    }

    private void requestPermission(String permission) {
        permission = getManifestPermission(permission);
        Log.i("SimplePermission", "Requesting permission : " + permission);
        String[] perm = {permission};
        ActivityCompat.requestPermissions(this, perm, 0);
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        int status = 0;
        String permission = permissions[0];
        Log.i("FtpMainActivity", "INIT Requesting permission status : " + status);
        if (requestCode == 0 && grantResults.length > 0) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(CrmMainActivity.this, permission)) {
                //denied
                status = 2;
            } else {
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    //allowed
                    status = 3;
                } else {
                    //set to never ask again
                    Log.e("FtpMainActivity", "set to never ask again" + permission);
                    status = 4;
                }
            }
        }
        this.permissionResult.success(status);
        Log.i("FtpMainActivity", "Requesting permission status : " + status);
    }

    /************** end 权限部分**************/
    @Override
    public void onBackPressed() {
        if (this.flutterView != null) {
            this.flutterView.popRoute();
        } else {
            super.onBackPressed();
        }
    }

    //扫描回调
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == scanRequestCode && resultCode == 1) {
            this.scanResult.success(data.getStringExtra("resultCode"));
        }
    }

}
