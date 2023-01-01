package io.polket.toearnfun_flutter_app;


import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.Ls.fileTrans.FileTransManager;
import io.polket.toearnfun_flutter_app.bluetooth.BleManager;
import io.polket.toearnfun_flutter_app.comm.Observer;
import io.polket.toearnfun_flutter_app.comm.ObserverManager;
import io.polket.toearnfun_flutter_app.data.BleDevice;
import io.polket.toearnfun_flutter_app.device.DeviceSettingProfiles;
import io.polket.toearnfun_flutter_app.device.skip.SkipApiActivity;
import io.polket.toearnfun_flutter_app.dfu.DfuManager;
import io.polket.toearnfun_flutter_app.exception.BleException;
import io.polket.toearnfun_flutter_app.utils.HexUtil;

import no.nordicsemi.android.dfu.DfuProgressListener;
import no.nordicsemi.android.dfu.DfuServiceInitiator;
import no.nordicsemi.android.dfu.DfuServiceListenerHelper;


public class DeviceApiActivity extends AppCompatActivity implements Observer {
    public static final String KEY_DATA = "key_data";
    private static final String TAG = DeviceApiActivity.class.getSimpleName();

    private static int dev_type = DeviceType.NULL_DEVICE;
    private static TextView logcat_textView;
    private static ScrollView logcat_scrollView;
    private TextView ble_name, ble_mac;
    private Toolbar toolbar;
    private static BleDevice bleDevice;

    private static final int SELECT_FILE_REQ = 1;

    public static final int ZIP_TYPE_OLD_OTA = 1;
    public static final int ZIP_TYPE_NEW_OTA = 2;
    public static final int ZIP_TYPE_IMAGE = 3;

    private static int zip_type = 0;

    private SkipApiActivity skipApi = new SkipApiActivity();

    public static void setDeviceType(int type)
    {
        dev_type = type;
    }

    public static int getDeviceType()
    {
        return dev_type;
    }

    public static BleDevice getBleDevice()
    {
        return bleDevice;
    }
    public void setBleDevice(BleDevice device)
    {
        bleDevice=device;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_device_api);
        initData();
        initView();
        if(DeviceType.SKIP_DEVICE == getDeviceType()) {
            skipApi.init(bleDevice);
        }
        ObserverManager.getInstance().addObserver(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            DfuServiceInitiator.createDfuNotificationChannel(this);

            final NotificationChannel channel = new NotificationChannel(DfuManager.CONNECTED_DEVICE_CHANNEL, "Background connections", NotificationManager.IMPORTANCE_LOW);
            channel.setDescription("Shows a notification when a device is connected in background.");
            channel.setShowBadge(false);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

            final NotificationChannel fileChannel = new NotificationChannel(DfuManager.FILE_SAVED_CHANNEL, "Files", NotificationManager.IMPORTANCE_LOW);
            fileChannel.setDescription("Shows notifications when new files has been saved.");
            fileChannel.setShowBadge(false);
            fileChannel.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);

            final NotificationChannel proximityChannel = new NotificationChannel(DfuManager.PROXIMITY_WARNINGS_CHANNEL, "Proximity warnings", NotificationManager.IMPORTANCE_LOW);
            proximityChannel.setDescription("Shows notifications when a proximity device got out of range.");
            proximityChannel.setShowBadge(false);
            proximityChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

            final NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(channel);
            notificationManager.createNotificationChannel(fileChannel);
            notificationManager.createNotificationChannel(proximityChannel);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.pedometer_functions, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    protected void onResume() {
        super.onResume();
        DeviceSettingProfiles.initActivityContext(this);
        DfuManager.initActivityContext(this);
        DfuServiceListenerHelper.registerProgressListener(this, mDfuProgressListener);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        BleManager.getInstance().unregisterCustomDataRxCallback(bleDevice);
        BleManager.getInstance().unregisterFileDataRxCallback(bleDevice);
        ObserverManager.getInstance().deleteObserver(this);
        DfuServiceListenerHelper.unregisterProgressListener(this, mDfuProgressListener);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final String deviceMac = bleDevice.getMac();
        if(TextUtils.isEmpty(deviceMac)){
            Toast.makeText(DeviceApiActivity.this, "undefined.....", Toast.LENGTH_LONG).show();
            return false;
        }
       /* handleDeviceFunction(item.getItemId());
        if(DeviceType.SKIP_DEVICE == getDeviceType()) {
            skipApi.handleDeviceFunction(bleDevice, item.getItemId());
        }*/
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void disConnected(BleDevice device) {
        if (device != null && bleDevice != null && device.getKey().equals(bleDevice.getKey())) {
            BleManager.getInstance().cleanCommand();
            finish();
        }
    }

    private void initView() {
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(getString(R.string.show_device));
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        ble_name = (TextView) findViewById(R.id.ble_name);
        ble_mac = (TextView) findViewById(R.id.ble_mac);
        logcat_textView = (TextView) findViewById(R.id.logcat_text_view);
        logcat_textView.setMovementMethod(ScrollingMovementMethod.getInstance());
        logcat_scrollView = (ScrollView) findViewById(R.id.logcat_scroll_view);

        String name = bleDevice.getName();
        String mac = bleDevice.getMac();



        ble_name.setText(String.valueOf(this.getString(R.string.name) + name));
        ble_mac.setText(String.valueOf(this.getString(R.string.mac) + mac));

        Button clean_btn = (Button) findViewById(R.id.clean_btn);
        clean_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                cleanText(logcat_textView);
            }
        });
    }

    private void initData() {
        bleDevice = getIntent().getParcelableExtra(KEY_DATA);
        if (bleDevice == null)
            finish();
    }

    private void openFileChooser() {
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("application/zip");
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        if (intent.resolveActivity(getPackageManager()) != null) {
            // file browser has been found on the device
            startActivityForResult(intent, SELECT_FILE_REQ);
        } else {
            Log.i(TAG, "there is no any file browser app, let's try to download one");
            // there is no any file browser app, let's try to download one
        }
    }

    @Override
    protected void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case SELECT_FILE_REQ: {
                // and read new one
                final Uri uri = data.getData();
                /*
                 * The URI returned from application may be in 'file' or 'content' schema. 'File' schema allows us to create a File object and read details from if
                 * directly. Data from 'Content' schema must be read by Content Provider. To do that we are using a Loader.
                 */
                Log.i(TAG, uri.getPath());

                if(ZIP_TYPE_OLD_OTA == zip_type) {
                    DfuManager.getInstance().startDfuProgress(bleDevice.getDevice(), uri);
                }
                else if(ZIP_TYPE_NEW_OTA == zip_type) {
                    SkipApiActivity api = new SkipApiActivity();
                    BleManager.getInstance().registerFileDataRxCallback(DeviceApiActivity.getBleDevice(), api.fileRxDataCallback);
                    try {
                        Thread.sleep(230);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    //FileTransManager.getInstance().startDfuProgress(this, uri, false);
                    FileTransManager.getInstance().startDfuProgress(this, uri, false);
                }
                else if(ZIP_TYPE_IMAGE == zip_type) {
                    SkipApiActivity api = new SkipApiActivity();
                    BleManager.getInstance().registerFileDataRxCallback(DeviceApiActivity.getBleDevice(), api.fileRxDataCallback);
                    try {
                        Thread.sleep(230);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    FileTransManager.getInstance().startImageProgress(this, uri);
                }
                break;
            }

            default:
                break;
        }
    }

    private final DfuProgressListener mDfuProgressListener = new DfuProgressListener() {
        @Override
        public void onDeviceConnecting(String deviceAddress) {
            final String s = "OTA service connecting: " + deviceAddress;
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onDeviceConnected(String deviceAddress) {
            final String s = "OTA service connected: ." + deviceAddress;
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onDfuProcessStarting(String deviceAddress) {
            final String s = "Starting OTA process...";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onEnablingDfuMode(@NonNull final String deviceAddress) {
            final String s = "Enable device enter ota mode.";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onDfuProcessStarted(String deviceAddress) {
            final String s = "OTA process started";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onProgressChanged(String deviceAddress, int percent, float speed, float avgSpeed, int currentPart, int partsTotal) {
            @SuppressLint("DefaultLocale")
            final String s = "progress: " + percent + "%, " + "Speed: " + String.format("%.2f", avgSpeed) + "KB/s";
            Log.i(TAG, "progress:" + percent + " partsTotal:" + partsTotal);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onFirmwareValidating(String deviceAddress) {
            final String s = "Firmware Validating...";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onDeviceDisconnecting(String deviceAddress) {
            final String s = "OTA service disconnecting.";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onDeviceDisconnected(String deviceAddress) {
            final String s = "OTA service disconnected with device";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onDfuCompleted(String deviceAddress) {
            final String s = "OTA completed";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onDfuAborted(String deviceAddress) {
            final String s = "OTA aborted";
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }

        @Override
        public void onError(String deviceAddress, int error, int errorType, String message) {
            final String s = "Err code: " + error + ", Type: " + errorType + ", message: " + message;
            Log.i(TAG, s);
            runOnUiThread(new Runnable() { public void run() { addText(s); }});
        }
    };

    private BleManager.LcWriteBleCallback mSettingCallback = new BleManager.LcWriteBleCallback() {
        @Override
        public void onWriteSuccess(int current, int total, byte[] justWrite) {
            super.onWriteSuccess(current, total, justWrite);
            if ( current == total ) {
                final String s = "[写入][成功]" + getTag();
                Log.i(TAG, s);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        addText(s);
                    }
                });
            }
        }

        @Override
        public void onWriteFailure(BleException exception) {
            super.onWriteFailure(exception);
            final String s = "[写入][失败]" + getTag() + ": " + exception.toString();
            Log.i(TAG, s);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    addText(s);
                }
            });
        }
    };

    private BleManager.LcReadBleCallback mVersionInfoCallback = new BleManager.LcReadBleCallback() {
        @Override
        public void onReadSuccess(byte[] data) {
            super.onReadSuccess(data);
            final String s = "[读取][成功]" + getTag() + " " + HexUtil.byteToAsciiString(data);
            Log.i(TAG, s);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    addText(s);
                }
            });
        }

        @Override
        public void onReadFailure(BleException exception) {
            super.onReadFailure(exception);
            final String s = "[读取][失败]" + getTag() + ": " + exception.toString();
            Log.i(TAG, s);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    addText(s);
                }
            });
        }
    };



    /**
     * 处理设备功能
     * @param index
     */
    private void handleDeviceFunction(int index)
    {
        switch (index)
        {
            case R.id.fun_hardware_ver: {
                mVersionInfoCallback.setTag("读取硬件版本");
                BleManager.getInstance().readHardwareVer(bleDevice, mVersionInfoCallback);
            } break;

            case R.id.fun_software_ver: {
                mVersionInfoCallback.setTag("读取软件版本");
                BleManager.getInstance().readSoftwareVer(bleDevice, mVersionInfoCallback);
            } break;

            case R.id.fun_firmware_ver: {
                mVersionInfoCallback.setTag("读取固件版本");
                BleManager.getInstance().readFirmwareVer(bleDevice, mVersionInfoCallback);
            } break;

            case R.id.fun_old_ota_mode:{
                mSettingCallback.setTag("旧版OTA");
                zip_type = ZIP_TYPE_OLD_OTA;
                openFileChooser();
            }break;

            case R.id.fun_new_ota_mode:{
                mSettingCallback.setTag("新版OTA");
                zip_type = ZIP_TYPE_NEW_OTA;
                openFileChooser();
            }break;

            case R.id.fun_image_trans:{
                mSettingCallback.setTag("图库传输");
                zip_type = ZIP_TYPE_IMAGE;
                openFileChooser();
            }break;

            case R.id.fun_set_adv_name:{
                mSettingCallback.setTag("获取设备公钥");
                zip_type = ZIP_TYPE_IMAGE;
             //   openFileChooser();
            }break;

        }
    }


    private static void addText(String content) {
      /*  logcat_textView.append(content);
        logcat_textView.append("\n");
        logcat_scrollView.fullScroll(View.FOCUS_DOWN);*/
    }

    private void cleanText(TextView textView) {
       // textView.setText("");
    }

    public static void outputLog(final String str) {
      //  addText(str);
    }
}
