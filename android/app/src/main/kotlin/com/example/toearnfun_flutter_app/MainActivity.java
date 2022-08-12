package com.example.toearnfun_flutter_app;

import androidx.annotation.NonNull;

import com.example.toearnfun_flutter_app.bluetooth.BleManager;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        BleManager.getInstance().init(getApplication());
        BleManager.getInstance()
                .enableLog(true)
                .setReConnectCount(1, 5000)
                .setConnectOverTime(20000)
                .setOperateTimeout(5000);

        //插件实例的注册...
        flutterEngine.getPlugins().add(new BluetoothFlutterPlugin(this));
        //这个是必写，别删除！！
        GeneratedPluginRegistrant.registerWith(flutterEngine);


    }
}