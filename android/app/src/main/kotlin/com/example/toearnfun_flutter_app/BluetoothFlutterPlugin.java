package com.example.toearnfun_flutter_app;
import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothGatt;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.Ls.skipBle.SkipBleUUIDs;
import com.Ls.skipBle.protocol.HexUtil;
import com.example.toearnfun_flutter_app.bluetooth.BleManager;
import com.example.toearnfun_flutter_app.callback.BleGattCallback;
import com.example.toearnfun_flutter_app.callback.BleMtuChangedCallback;
import com.example.toearnfun_flutter_app.callback.BleScanCallback;
import com.example.toearnfun_flutter_app.comm.ObserverManager;
import com.example.toearnfun_flutter_app.data.BleDevice;
import com.example.toearnfun_flutter_app.exception.BleException;
import com.example.toearnfun_flutter_app.scan.BleScanRuleConfig;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BluetoothFlutterPlugin  implements FlutterPlugin {
    Context applicationContext;
    Activity mActivity;
    private static final String TAG = MainActivity.class.getSimpleName();
    MethodChannel.Result mResult=null;
    String param="";
    BleDevice mBleDevice=null;
    private static final int REQUEST_CODE_OPEN_GPS = 1;
    private static final int REQUEST_CODE_PERMISSION_LOCATION = 2;
    BluetoothFlutterPlugin(Activity activity)
    {
        mActivity=activity;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        //可以利用binding对象获取到Android中需要的Context对象
         applicationContext = binding.getApplicationContext();

        //设置channel名称，之后flutter中也要一样
        MethodChannel channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), "BluetoothFlutterPlugin");

        //把当前的MethodCallHandler设置
        channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                String method = call.method;
                mResult=result;
                if (method.equals("getText")) {

                    //调用原生的方法，这里为了方便，我就把方法写在当前类了
                    String str = getText();

                    //将结果返回给flutter
                    mResult.success(str);

                    //这里也有error的方法，可以看情况使用
                    //result.error("code", "message", "detail");
                } else if(method.equals("scanDevice")){
                    checkPermissions();
                //    mResult.success(param);
                } else if(method.equals("connect"))
                {
                    connect(mBleDevice);
                }else {
                    //Flutter传过来id方法名没有找到，就调此方法
                    result.notImplemented();
                }
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull @NotNull FlutterPluginBinding binding) {
        
    }

    private String getText() {
        return "hello world";
    }
    private void checkBluetoothIsOpen()
    {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
            Toast.makeText(applicationContext, applicationContext.getString(R.string.please_open_blue), Toast.LENGTH_LONG).show();
            return;
        }
    }


    private void checkPermissions() {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!bluetoothAdapter.isEnabled()) {
            Toast.makeText(applicationContext, applicationContext.getString(R.string.please_open_blue), Toast.LENGTH_LONG).show();
            return;
        }

        String[] permissions = {Manifest.permission.ACCESS_FINE_LOCATION};
        List<String> permissionDeniedList = new ArrayList<>();
        for (String permission : permissions) {
            int permissionCheck = ContextCompat.checkSelfPermission(applicationContext, permission);
            if (permissionCheck == PackageManager.PERMISSION_GRANTED) {
                onPermissionGranted(permission);
            } else {
                permissionDeniedList.add(permission);
            }
        }
        if (!permissionDeniedList.isEmpty()) {
            String[] deniedPermissions = permissionDeniedList.toArray(new String[permissionDeniedList.size()]);
            ActivityCompat.requestPermissions(mActivity, deniedPermissions, REQUEST_CODE_PERMISSION_LOCATION);
        }
    }

    private void onPermissionGranted(String permission) {
        switch (permission) {
            case Manifest.permission.ACCESS_FINE_LOCATION:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !checkGPSIsOpen()) {
                    new AlertDialog.Builder(applicationContext)
                            .setTitle(R.string.notifyTitle)
                            .setMessage(R.string.gpsNotifyMsg)
                            .setNegativeButton(R.string.cancel,
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            mActivity.finish();
                                        }
                                    })
                            .setPositiveButton(R.string.setting,
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                                            mActivity.startActivityForResult(intent, REQUEST_CODE_OPEN_GPS);
                                        }
                                    })

                            .setCancelable(false)
                            .show();
                } else {
                    setScanRule();
                    startScan();
                }
                break;
        }
    }


    private void setScanRule() {
        String[] uuids;
        String str_uuid ="0000ffd0-0000-1000-8000-00805f9b34fb";
        if (TextUtils.isEmpty(str_uuid)) {
            uuids = null;
        } else {
            uuids = str_uuid.split(",");
        }
        UUID[] serviceUuids = null;
        if (uuids != null && uuids.length > 0) {
            serviceUuids = new UUID[uuids.length];
            for (int i = 0; i < uuids.length; i++) {
                String name = uuids[i];
                String[] components = name.split("-");
                if (components.length != 5) {
                    serviceUuids[i] = null;
                } else {
                    serviceUuids[i] = UUID.fromString(uuids[i]);
                }
            }
        }

        String[] names;
        String str_name =""; //et_name.getText().toString();
        if (TextUtils.isEmpty(str_name)) {
            names = null;
        } else {
            names = str_name.split(",");
        }

        String mac ="";// et_mac.getText().toString();

     //   boolean isAutoConnect = sw_auto.isChecked();
   //     boolean isFuzzy = sw_fuzzy.isChecked();

        boolean isAutoConnect =false;
        boolean isFuzzy = true;
                BleScanRuleConfig scanRuleConfig = new BleScanRuleConfig.Builder()
                .setServiceUuids(serviceUuids)      // 只扫描指定的服务的设备，可选
                .setDeviceName(isFuzzy, names)   // 只扫描指定广播名的设备，可选
                .setDeviceMac(mac)                  // 只扫描指定mac的设备，可选
                .setAutoConnect(isAutoConnect)      // 连接时的autoConnect参数，可选，默认false
                .setScanTimeOut(10000)              // 扫描超时时间，可选，默认10秒
                .build();
        BleManager.getInstance().initScanRule(scanRuleConfig);
    }

    private void startScan() {
        BleManager.getInstance().scan(new BleScanCallback() {
            @Override
            public void onScanStarted(boolean success) {
              //  mDeviceAdapter.clearScanDevice();
              //  mDeviceAdapter.notifyDataSetChanged();
              //  img_loading.startAnimation(operat ingAnim);
              //  img_loading.setVisibility(View.VISIBLE);
              //  btn_scan.setText(getString(R.string.stop_scan));
            }

            @Override
            public void onLeScan(BleDevice bleDevice) {
                super.onLeScan(bleDevice);
            }
            @Override
            public void onScanning(BleDevice bleDevice) {
                mBleDevice =bleDevice;
                if (bleDevice.getRssi()> (Integer.parseInt("-100"))) {
                    param="{\"name\":"+bleDevice.getName()+",\"mac\":"+bleDevice.getMac()+",\"Rssi\":"+bleDevice.getRssi()+"}";
                    Toast.makeText(mActivity, bleDevice.getMac()+"   "+bleDevice.getName(), Toast.LENGTH_LONG).show();
                    mResult.success(param);
                }
            }

            @Override
            public void onScanFinished(List<BleDevice> scanResultList) {

         //       img_loading.clearAnimation();
         //       img_loading.setVisibility(View.INVISIBLE);
         //       btn_scan.setText(getString(R.string.start_scan));


            }
        });
    }
    private boolean checkGPSIsOpen() {
        LocationManager locationManager = (LocationManager) applicationContext.getSystemService(Context.LOCATION_SERVICE);
        if (locationManager == null)
            return false;
        return locationManager.isProviderEnabled(android.location.LocationManager.GPS_PROVIDER);
    }

    private void connect(final BleDevice bleDevice) {
        BleManager.getInstance().connect(bleDevice, new BleGattCallback() {
            @Override
            public void onStartConnect() {
                //progressBar.setVisibility(View.VISIBLE);
            }

            @Override
            public void onConnectFail(BleDevice bleDevice, BleException exception) {
              /*  img_loading.clearAnimation();
                img_loading.setVisibility(View.INVISIBLE);
                btn_scan.setText(getString(R.string.start_scan));
                progressBar.setVisibility(View.GONE);*/
                Toast.makeText(mActivity, mActivity.getString(R.string.connect_fail), Toast.LENGTH_LONG).show();
            }



            @Override
            public void onConnectSuccess(BleDevice bleDevice, BluetoothGatt gatt, int status) {
              /*  progressBar.setVisibility(View.GONE);
                mDeviceAdapter.addDevice(bleDevice);
                mDeviceAdapter.notifyDataSetChanged();*/

                Toast.makeText(mActivity, mActivity.getString(R.string.connect_suc), Toast.LENGTH_LONG).show();

                BleManager.getInstance().setMtu(bleDevice, 247, new BleMtuChangedCallback() {
                    @Override
                    public void onSetMTUFailure(BleException exception) {
                        Log.i(TAG, "[写入][失败] MTU设置" + exception.toString());
                    }

                    @Override
                    public void onMtuChanged(int mtu) {
                        Log.i(TAG, "[写入][成功] MTU设置： " + mtu);
                    }
                });
            }

            @Override
            public void onDisConnected(boolean isActiveDisConnected, BleDevice bleDevice, BluetoothGatt gatt, int status) {
           //     progressBar.setVisibility(View.GONE);
           //     mDeviceAdapter.removeDevice(bleDevice);
            //    mDeviceAdapter.notifyDataSetChanged();

                if (isActiveDisConnected) {
                    Toast.makeText(mActivity, mActivity.getString(R.string.active_disconnected), Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(mActivity, mActivity.getString(R.string.disconnected), Toast.LENGTH_LONG).show();
                    ObserverManager.getInstance().notifyObserver(bleDevice);
                }

            }
        });
    }

}
