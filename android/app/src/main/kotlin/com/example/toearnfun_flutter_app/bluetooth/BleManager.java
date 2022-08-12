package com.example.toearnfun_flutter_app.bluetooth;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.ScanRecord;
import android.bluetooth.le.ScanResult;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.Ls.fileTrans.FileTransUUIDs;
import com.Ls.fileTrans.ReceiveFileDataCallback;
import com.Ls.skipBle.ReceiveDataCallback;
import com.Ls.skipBle.SkipBleUUIDs;
import com.example.toearnfun_flutter_app.DeviceApiActivity;
import com.example.toearnfun_flutter_app.DeviceType;
import com.example.toearnfun_flutter_app.callback.BleGattCallback;
import com.example.toearnfun_flutter_app.callback.BleIndicateCallback;
import com.example.toearnfun_flutter_app.callback.BleMtuChangedCallback;
import com.example.toearnfun_flutter_app.callback.BleNotifyCallback;
import com.example.toearnfun_flutter_app.callback.BleReadCallback;
import com.example.toearnfun_flutter_app.callback.BleRssiCallback;
import com.example.toearnfun_flutter_app.callback.BleScanAndConnectCallback;
import com.example.toearnfun_flutter_app.callback.BleScanCallback;
import com.example.toearnfun_flutter_app.callback.BleWriteCallback;
import com.example.toearnfun_flutter_app.data.BleCommand;
import com.example.toearnfun_flutter_app.data.BleDevice;
import com.example.toearnfun_flutter_app.data.BleScanState;
import com.example.toearnfun_flutter_app.device.skip.SkipApiActivity;
import com.example.toearnfun_flutter_app.exception.BleException;
import com.example.toearnfun_flutter_app.exception.OtherException;
import com.example.toearnfun_flutter_app.scan.BleScanRuleConfig;
import com.example.toearnfun_flutter_app.scan.BleScanner;
import com.example.toearnfun_flutter_app.utils.BleLog;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentLinkedQueue;

@TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
public class BleManager {

    private static final String TAG = BleManager.class.getSimpleName();

    private Application context;
    private BleScanRuleConfig bleScanRuleConfig;
    private BluetoothAdapter bluetoothAdapter;
    private MultipleBluetoothController multipleBluetoothController;
    private BluetoothManager bluetoothManager;

    private boolean bleProcessing;
    private boolean lcProcessing;
    private ConcurrentLinkedQueue<BleCommand> commandQueue = new ConcurrentLinkedQueue<BleCommand>();
    private ConcurrentLinkedQueue<LcBleComm> LcBleCommsQueue = new ConcurrentLinkedQueue<LcBleComm>();

    private Handler mHandler = new Handler();

    public static final int DEFAULT_SCAN_TIME = 10000;
    private static final int DEFAULT_MAX_MULTIPLE_DEVICE = 7;
    private static final int DEFAULT_OPERATE_TIME = 5000;
    private static final int DEFAULT_CONNECT_RETRY_COUNT = 0;
    private static final int DEFAULT_CONNECT_RETRY_INTERVAL = 5000;
    private static final int DEFAULT_MTU = 23;
    private static final int DEFAULT_MAX_MTU = 512;
    private static final int DEFAULT_WRITE_DATA_SPLIT_COUNT = 120;   //BlePackageParamDef.BLE_FRAME_MAX_LEN
    private static final int DEFAULT_CONNECT_OVER_TIME = 10000;

    private int maxConnectCount = DEFAULT_MAX_MULTIPLE_DEVICE;
    private int operateTimeout = DEFAULT_OPERATE_TIME;
    private int reConnectCount = DEFAULT_CONNECT_RETRY_COUNT;
    private long reConnectInterval = DEFAULT_CONNECT_RETRY_INTERVAL;
    private int splitWriteNum = DEFAULT_WRITE_DATA_SPLIT_COUNT;
    private long connectOverTime = DEFAULT_CONNECT_OVER_TIME;

    private boolean rxFileNotifyEnabled = false;


    public static BleManager getInstance() {
        return BleManagerHolder.sBleManager;
    }

    private static class BleManagerHolder {
        private static final BleManager sBleManager = new BleManager();
    }

    public void init(Application app) {
        if (context == null && app != null) {
            context = app;
            if (isSupportBle()) {
                bluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
            }
            bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            multipleBluetoothController = new MultipleBluetoothController();
            bleScanRuleConfig = new BleScanRuleConfig();
        }
    }

    /**
     * Get the Context
     *
     * @return
     */
    public Context getContext() {
        return context;
    }

    /**
     * Get the BluetoothManager
     *
     * @return
     */
    public BluetoothManager getBluetoothManager() {
        return bluetoothManager;
    }

    /**
     * Get the BluetoothAdapter
     *
     * @return
     */
    public BluetoothAdapter getBluetoothAdapter() {
        return bluetoothAdapter;
    }

    /**
     * get the ScanRuleConfig
     *
     * @return
     */
    public BleScanRuleConfig getScanRuleConfig() {
        return bleScanRuleConfig;
    }

    /**
     * Get the multiple Bluetooth Controller
     *
     * @return
     */
    public MultipleBluetoothController getMultipleBluetoothController() {
        return multipleBluetoothController;
    }

    /**
     * Configure scan and connection properties
     *
     * @param config
     */
    public void initScanRule(BleScanRuleConfig config) {
        this.bleScanRuleConfig = config;
    }

    /**
     * Get the maximum number of connections
     *
     * @return
     */
    public int getMaxConnectCount() {
        return maxConnectCount;
    }

    /**
     * Set the maximum number of connections
     *
     * @param count
     * @return BleManager
     */
    public BleManager setMaxConnectCount(int count) {
        if (count > DEFAULT_MAX_MULTIPLE_DEVICE)
            count = DEFAULT_MAX_MULTIPLE_DEVICE;
        this.maxConnectCount = count;
        return this;
    }

    /**
     * Get operate timeout
     *
     * @return
     */
    public int getOperateTimeout() {
        return operateTimeout;
    }

    /**
     * Set operate timeout
     *
     * @param count
     * @return BleManager
     */
    public BleManager setOperateTimeout(int count) {
        this.operateTimeout = count;
        return this;
    }

    /**
     * Get connect retry count
     *
     * @return
     */
    public int getReConnectCount() {
        return reConnectCount;
    }

    /**
     * Get connect retry interval
     *
     * @return
     */
    public long getReConnectInterval() {
        return reConnectInterval;
    }

    /**
     * Set connect retry count and interval
     *
     * @param count
     * @return BleManager
     */
    public BleManager setReConnectCount(int count) {
        return setReConnectCount(count, DEFAULT_CONNECT_RETRY_INTERVAL);
    }

    /**
     * Set connect retry count and interval
     *
     * @param count
     * @return BleManager
     */
    public BleManager setReConnectCount(int count, long interval) {
        if (count > 10)
            count = 10;
        if (interval < 0)
            interval = 0;
        this.reConnectCount = count;
        this.reConnectInterval = interval;
        return this;
    }


    /**
     * Get operate split Write Num
     *
     * @return
     */
    public int getSplitWriteNum() {
        return splitWriteNum;
    }

    /**
     * Set split Writ eNum
     *
     * @param num
     * @return BleManager
     */
    public BleManager setSplitWriteNum(int num) {
        if (num > 0) {
            this.splitWriteNum = num;
        }
        return this;
    }

    /**
     * Get operate connect Over Time
     *
     * @return
     */
    public long getConnectOverTime() {
        return connectOverTime;
    }

    /**
     * Set connect Over Time
     *
     * @param time
     * @return BleManager
     */
    public BleManager setConnectOverTime(long time) {
        if (time <= 0) {
            time = 100;
        }
        this.connectOverTime = time;
        return this;
    }

    /**
     * print log?
     *
     * @param enable
     * @return BleManager
     */
    public BleManager enableLog(boolean enable) {
        BleLog.isPrint = enable;
        return this;
    }

    /**
     * scan device around
     *
     * @param callback
     */
    public void scan(BleScanCallback callback) {
        if (callback == null) {
            throw new IllegalArgumentException("BleScanCallback can not be Null!");
        }

        if (!isBlueEnable()) {
            BleLog.e("Bluetooth not enable!");
            callback.onScanStarted(false);
            return;
        }

        UUID[] serviceUuids = bleScanRuleConfig.getServiceUuids();
        String[] deviceNames = bleScanRuleConfig.getDeviceNames();
        String deviceMac = bleScanRuleConfig.getDeviceMac();
        boolean fuzzy = bleScanRuleConfig.isFuzzy();
        long timeOut = bleScanRuleConfig.getScanTimeOut();

        BleScanner.getInstance().scan(serviceUuids, deviceNames, deviceMac, fuzzy, timeOut, callback);
    }

    /**
     * scan device then connect
     *
     * @param callback
     */
    public void scanAndConnect(BleScanAndConnectCallback callback) {
        if (callback == null) {
            throw new IllegalArgumentException("BleScanAndConnectCallback can not be Null!");
        }

        if (!isBlueEnable()) {
            BleLog.e("Bluetooth not enable!");
            callback.onScanStarted(false);
            return;
        }

        UUID[] serviceUuids = bleScanRuleConfig.getServiceUuids();
        String[] deviceNames = bleScanRuleConfig.getDeviceNames();
        String deviceMac = bleScanRuleConfig.getDeviceMac();
        boolean fuzzy = bleScanRuleConfig.isFuzzy();
        long timeOut = bleScanRuleConfig.getScanTimeOut();

        BleScanner.getInstance().scanAndConnect(serviceUuids, deviceNames, deviceMac, fuzzy, timeOut, callback);
    }

    /**
     * connect a known device
     *
     * @param bleDevice
     * @param bleGattCallback
     * @return
     */
    public BluetoothGatt connect(BleDevice bleDevice, BleGattCallback bleGattCallback) {
        if (bleGattCallback == null) {
            throw new IllegalArgumentException("BleGattCallback can not be Null!");
        }

        if (!isBlueEnable()) {
            BleLog.e("Bluetooth not enable!");
            bleGattCallback.onConnectFail(bleDevice, new OtherException("Bluetooth not enable!"));
            return null;
        }

        if (Looper.myLooper() == null || Looper.myLooper() != Looper.getMainLooper()) {
            BleLog.w("Be careful: currentThread is not MainThread!");
        }

        if (bleDevice == null || bleDevice.getDevice() == null) {
            bleGattCallback.onConnectFail(bleDevice, new OtherException("Not Found Device Exception Occurred!"));
        } else {
            BleBluetooth bleBluetooth = multipleBluetoothController.buildConnectingBle(bleDevice);
            boolean autoConnect = bleScanRuleConfig.isAutoConnect();
            return bleBluetooth.connect(bleDevice, autoConnect, bleGattCallback);
        }

        return null;
    }

    /**
     * connect a device through its mac without scan,whether or not it has been connected
     *
     * @param mac
     * @param bleGattCallback
     * @return
     */
    public BluetoothGatt connect(String mac, BleGattCallback bleGattCallback) {
        BluetoothDevice bluetoothDevice = getBluetoothAdapter().getRemoteDevice(mac);
        BleDevice bleDevice = new BleDevice(bluetoothDevice, 0, null, 0);
        return connect(bleDevice, bleGattCallback);
    }


    /**
     * Cancel scan
     */
    public void cancelScan() {
        BleScanner.getInstance().stopLeScan();
    }

    /**
     * notify
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_notify
     * @param callback
     */
    public void notify(BleDevice bleDevice,
                       String uuid_service,
                       String uuid_notify,
                       BleNotifyCallback callback) {
        notify(bleDevice, uuid_service, uuid_notify, false, callback);
    }

    /**
     * notify
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_notify
     * @param useCharacteristicDescriptor
     * @param callback
     */
    public void notify(BleDevice bleDevice,
                       String uuid_service,
                       String uuid_notify,
                       boolean useCharacteristicDescriptor,
                       BleNotifyCallback callback) {
        if (callback == null) {
            throw new IllegalArgumentException("BleNotifyCallback can not be Null!");
        }

        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            callback.onNotifyFailure(new OtherException("This device not connect!"));
        } else {
            bleBluetooth.newBleConnector()
                    .withUUIDString(uuid_service, uuid_notify)
                    .enableCharacteristicNotify(callback, uuid_notify, useCharacteristicDescriptor);
        }
    }

    /**
     * indicate
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_indicate
     * @param callback
     */
    public void indicate(BleDevice bleDevice,
                         String uuid_service,
                         String uuid_indicate,
                         BleIndicateCallback callback) {
        indicate(bleDevice, uuid_service, uuid_indicate, false, callback);
    }

    /**
     * indicate
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_indicate
     * @param useCharacteristicDescriptor
     * @param callback
     */
    public void indicate(BleDevice bleDevice,
                         String uuid_service,
                         String uuid_indicate,
                         boolean useCharacteristicDescriptor,
                         BleIndicateCallback callback) {
        if (callback == null) {
            throw new IllegalArgumentException("BleIndicateCallback can not be Null!");
        }

        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            callback.onIndicateFailure(new OtherException("This device not connect!"));
        } else {
            bleBluetooth.newBleConnector()
                    .withUUIDString(uuid_service, uuid_indicate)
                    .enableCharacteristicIndicate(callback, uuid_indicate, useCharacteristicDescriptor);
        }
    }

    /**
     * stop notify, remove callback
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_notify
     * @return
     */
    public boolean stopNotify(BleDevice bleDevice,
                              String uuid_service,
                              String uuid_notify) {
        return stopNotify(bleDevice, uuid_service, uuid_notify, false);
    }

    /**
     * stop notify, remove callback
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_notify
     * @param useCharacteristicDescriptor
     * @return
     */
    public boolean stopNotify(BleDevice bleDevice,
                              String uuid_service,
                              String uuid_notify,
                              boolean useCharacteristicDescriptor) {
        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            return false;
        }
        boolean success = bleBluetooth.newBleConnector()
                .withUUIDString(uuid_service, uuid_notify)
                .disableCharacteristicNotify(useCharacteristicDescriptor);
        if (success) {
            bleBluetooth.removeNotifyCallback(uuid_notify);
        }
        return success;
    }

    /**
     * stop indicate, remove callback
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_indicate
     * @return
     */
    public boolean stopIndicate(BleDevice bleDevice,
                                String uuid_service,
                                String uuid_indicate) {
        return stopIndicate(bleDevice, uuid_service, uuid_indicate, false);
    }

    /**
     * stop indicate, remove callback
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_indicate
     * @param useCharacteristicDescriptor
     * @return
     */
    public boolean stopIndicate(BleDevice bleDevice,
                                String uuid_service,
                                String uuid_indicate,
                                boolean useCharacteristicDescriptor) {
        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            return false;
        }
        boolean success = bleBluetooth.newBleConnector()
                .withUUIDString(uuid_service, uuid_indicate)
                .disableCharacteristicIndicate(useCharacteristicDescriptor);
        if (success) {
            bleBluetooth.removeIndicateCallback(uuid_indicate);
        }
        return success;
    }

    /**
     * write
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_write
     * @param data
     * @param callback
     */
    public void write(BleDevice bleDevice,
                      String uuid_service,
                      String uuid_write,
                      byte[] data,
                      BleWriteCallback callback) {
        write(bleDevice, uuid_service, uuid_write, data, true, callback);
    }

    /**
     * write
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_write
     * @param data
     * @param split
     * @param callback
     */
    public void write(BleDevice bleDevice,
                      String uuid_service,
                      String uuid_write,
                      byte[] data,
                      boolean split,
                      BleWriteCallback callback) {

        write(bleDevice, uuid_service, uuid_write, data, split, true, 0, callback);
    }

    /**
     * write
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_write
     * @param data
     * @param split
     * @param sendNextWhenLastSuccess
     * @param intervalBetweenTwoPackage
     * @param callback
     */
    public void write(BleDevice bleDevice,
                      String uuid_service,
                      String uuid_write,
                      byte[] data,
                      boolean split,
                      boolean sendNextWhenLastSuccess,
                      long intervalBetweenTwoPackage,
                      BleWriteCallback callback) {

        if (callback == null) {
            throw new IllegalArgumentException("BleWriteCallback can not be Null!");
        }

        if (data == null) {
            BleLog.e("data is Null!");
            callback.onWriteFailure(new OtherException("data is Null!"));
            return;
        }

        if (data.length > 120 && !split) {     //BlePackageParamDef.BLE_FRAME_MAX_LEN
            BleLog.w("Be careful: data's length beyond 20! Ensure MTU higher than 23, or use spilt write!");
        }

        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            callback.onWriteFailure(new OtherException("This device not connect!"));
        } else {
//            if (split && data.length > getSplitWriteNum()) {
                new SplitWriter().splitWrite(bleBluetooth, uuid_service, uuid_write, data,
                        sendNextWhenLastSuccess, intervalBetweenTwoPackage, callback);
//            } else {
//                bleBluetooth.newBleConnector()
//                        .withUUIDString(uuid_service, uuid_write)
//                        .writeCharacteristic(data, callback, uuid_write);
//            }
        }
    }

    /**
     * read
     *
     * @param bleDevice
     * @param uuid_service
     * @param uuid_read
     * @param callback
     */
    public void read(BleDevice bleDevice,
                     String uuid_service,
                     String uuid_read,
                     BleReadCallback callback) {
        if (callback == null) {
            throw new IllegalArgumentException("BleReadCallback can not be Null!");
        }

        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            callback.onReadFailure(new OtherException("This device is not connected!"));
        } else {
            bleBluetooth.newBleConnector()
                    .withUUIDString(uuid_service, uuid_read)
                    .readCharacteristic(callback, uuid_read);
        }
    }

    /**
     * read Rssi
     *
     * @param bleDevice
     * @param callback
     */
    public void readRssi(BleDevice bleDevice,
                         BleRssiCallback callback) {
        if (callback == null) {
            throw new IllegalArgumentException("BleRssiCallback can not be Null!");
        }

        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            callback.onRssiFailure(new OtherException("This device is not connected!"));
        } else {
            bleBluetooth.newBleConnector().readRemoteRssi(callback);
        }
    }

    /**
     * set Mtu
     *
     * @param bleDevice
     * @param mtu
     * @param callback
     */
    public void setMtu(BleDevice bleDevice,
                       int mtu,
                       BleMtuChangedCallback callback) {
        if (callback == null) {
            throw new IllegalArgumentException("BleMtuChangedCallback can not be Null!");
        }

        if (mtu > DEFAULT_MAX_MTU) {
            BleLog.e("requiredMtu should lower than 512 !");
            callback.onSetMTUFailure(new OtherException("requiredMtu should lower than 512 !"));
            return;
        }

        if (mtu < DEFAULT_MTU) {
            BleLog.e("requiredMtu should higher than 23 !");
            callback.onSetMTUFailure(new OtherException("requiredMtu should higher than 23 !"));
            return;
        }

        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        if (bleBluetooth == null) {
            callback.onSetMTUFailure(new OtherException("This device is not connected!"));
        } else {
            bleBluetooth.newBleConnector().setMtu(mtu, callback);

            //Clark add
            splitWriteNum = mtu;
        }
    }

    /**
     * requestConnectionPriority
     *
     * @param connectionPriority Request a specific connection priority. Must be one of
     *                           {@link BluetoothGatt#CONNECTION_PRIORITY_BALANCED},
     *                           {@link BluetoothGatt#CONNECTION_PRIORITY_HIGH}
     *                           or {@link BluetoothGatt#CONNECTION_PRIORITY_LOW_POWER}.
     * @throws IllegalArgumentException If the parameters are outside of their
     *                                  specified range.
     */
    public boolean requestConnectionPriority(BleDevice bleDevice, int connectionPriority) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
            if (bleBluetooth == null) {
                return false;
            } else {
                return bleBluetooth.newBleConnector().requestConnectionPriority(connectionPriority);
            }
        }
        return false;
    }

    /**
     * is support ble?
     *
     * @return
     */
    public boolean isSupportBle() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2
                && context.getApplicationContext().getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE);
    }

    /**
     * Open bluetooth
     */
    @SuppressLint("MissingPermission")
    public void enableBluetooth() {
        if (bluetoothAdapter != null) {
            bluetoothAdapter.enable();
        }
    }

    /**
     * Disable bluetooth
     */
    @SuppressLint("MissingPermission")
    public void disableBluetooth() {
        if (bluetoothAdapter != null) {
            if (bluetoothAdapter.isEnabled())
                bluetoothAdapter.disable();
        }
    }

    /**
     * judge Bluetooth is enable
     *
     * @return
     */
    public boolean isBlueEnable() {
        return bluetoothAdapter != null && bluetoothAdapter.isEnabled();
    }


    public BleDevice convertBleDevice(BluetoothDevice bluetoothDevice) {
        return new BleDevice(bluetoothDevice);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public BleDevice convertBleDevice(ScanResult scanResult) {
        if (scanResult == null) {
            throw new IllegalArgumentException("scanResult can not be Null!");
        }
        BluetoothDevice bluetoothDevice = scanResult.getDevice();
        int rssi = scanResult.getRssi();
        ScanRecord scanRecord = scanResult.getScanRecord();
        byte[] bytes = null;
        if (scanRecord != null)
            bytes = scanRecord.getBytes();
        long timestampNanos = scanResult.getTimestampNanos();
        return new BleDevice(bluetoothDevice, rssi, bytes, timestampNanos);
    }

    public BleBluetooth getBleBluetooth(BleDevice bleDevice) {
        if (multipleBluetoothController != null) {
            return multipleBluetoothController.getBleBluetooth(bleDevice);
        }
        return null;
    }

    public BluetoothGatt getBluetoothGatt(BleDevice bleDevice) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            return bleBluetooth.getBluetoothGatt();
        return null;
    }

    public List<BluetoothGattService> getBluetoothGattServices(BleDevice bleDevice) {
        BluetoothGatt gatt = getBluetoothGatt(bleDevice);
        if (gatt != null) {
            return gatt.getServices();
        }
        return null;
    }

    public List<BluetoothGattCharacteristic> getBluetoothGattCharacteristics(BluetoothGattService service) {
        return service.getCharacteristics();
    }

    public void removeConnectGattCallback(BleDevice bleDevice) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.removeConnectGattCallback();
    }

    public void removeRssiCallback(BleDevice bleDevice) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.removeRssiCallback();
    }

    public void removeMtuChangedCallback(BleDevice bleDevice) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.removeMtuChangedCallback();
    }

    public void removeNotifyCallback(BleDevice bleDevice, String uuid_notify) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.removeNotifyCallback(uuid_notify);
    }

    public void removeIndicateCallback(BleDevice bleDevice, String uuid_indicate) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.removeIndicateCallback(uuid_indicate);
    }

    public void removeWriteCallback(BleDevice bleDevice, String uuid_write) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.removeWriteCallback(uuid_write);
    }

    public void removeReadCallback(BleDevice bleDevice, String uuid_read) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.removeReadCallback(uuid_read);
    }

    public void clearCharacterCallback(BleDevice bleDevice) {
        BleBluetooth bleBluetooth = getBleBluetooth(bleDevice);
        if (bleBluetooth != null)
            bleBluetooth.clearCharacterCallback();
    }

    public BleScanState getScanSate() {
        return BleScanner.getInstance().getScanState();
    }

    public List<BleDevice> getAllConnectedDevice() {
        if (multipleBluetoothController == null)
            return null;
        return multipleBluetoothController.getDeviceList();
    }

    /**
     * @param bleDevice
     * @return State of the profile connection. One of
     * {@link BluetoothProfile#STATE_CONNECTED},
     * {@link BluetoothProfile#STATE_CONNECTING},
     * {@link BluetoothProfile#STATE_DISCONNECTED},
     * {@link BluetoothProfile#STATE_DISCONNECTING}
     */
    @SuppressLint("MissingPermission")
    public int getConnectState(BleDevice bleDevice) {
        if (bleDevice != null) {
            return bluetoothManager.getConnectionState(bleDevice.getDevice(), BluetoothProfile.GATT);
        } else {
            return BluetoothProfile.STATE_DISCONNECTED;
        }
    }

    public boolean isConnected(BleDevice bleDevice) {
        return getConnectState(bleDevice) == BluetoothProfile.STATE_CONNECTED;
    }

    public boolean isConnected(String mac) {
        List<BleDevice> list = getAllConnectedDevice();
        for (BleDevice bleDevice : list) {
            if (bleDevice != null) {
                if (bleDevice.getMac().equals(mac)) {
                    return true;
                }
            }
        }
        return false;
    }

    public void disconnect(BleDevice bleDevice) {
        if (multipleBluetoothController != null) {
            multipleBluetoothController.disconnect(bleDevice);
        }
    }

    public void disconnectAllDevice() {
        if (multipleBluetoothController != null) {
            multipleBluetoothController.disconnectAllDevice();
        }
    }

    public void destroy() {
        if (multipleBluetoothController != null) {
            multipleBluetoothController.destroy();
        }
    }



    private void lcQueueCleanup() {
        lcProcessing = false;
        LcBleComm comm;
        for (;;) {
            comm = LcBleCommsQueue.poll();
            if (comm != null) {
                if ( comm.getType() == LcBleComm.READ ) {
                    comm.getLcReadBleCallback().onReadFailure(new OtherException("Peripheral Disconnected"));
                } else if ( comm.getType() == LcBleComm.WRITE ) {
                    comm.getLcWriteBleCallback().onWriteFailure(new OtherException("Peripheral Disconnected"));
                }
            }
            else {
                break;
            }
        }
    }


    // command finished, queue the next command
    private void lcCommandCompleted() {
        Log.d(TAG,"LC Processing Complete");
        lcProcessing = false;
        lcProcessCommands();
    }

    // process the queue
    private void lcProcessCommands() {
        Log.d(TAG,"LC Processing Commands");

        if (lcProcessing) { return; }

        LcBleComm comm = LcBleCommsQueue.poll();
        if (comm != null) {
            if (comm.getType() == LcBleComm.READ) {
                Log.d(TAG,"LC Read " + comm.getCharacteristicUUID());
                lcProcessing = true;
                read(comm.getBleDevice(), comm.getServiceUUID(), comm.getCharacteristicUUID(), comm.getLcReadBleCallback());
            } else if (comm.getType() == LcBleComm.WRITE) {
                Log.d(TAG,"LC Write " + comm.getCharacteristicUUID());
                lcProcessing = true;
                write(comm.getBleDevice(), comm.getServiceUUID(), comm.getCharacteristicUUID(), comm.getData(), comm.getLcWriteBleCallback());

            } else {
                // this shouldn't happen
                throw new RuntimeException("Unexpected BLE Command type " + comm.getType());
            }
        } else {
            Log.d(TAG, "Command Queue is empty.");
        }

    }

    public void lcRawWrite(BleDevice bleDevice,
                        String uuid_service,
                        String uuid_write,
                        byte[] data,
                        LcWriteBleCallback callback) {
        BleBluetooth bleBluetooth = multipleBluetoothController.getBleBluetooth(bleDevice);
        bleBluetooth.newBleConnector()
                        .withUUIDString(uuid_service, uuid_write)
                        .writeCharacteristic(data, callback, uuid_write);
    }

    public void lcWrite(BleDevice bleDevice,
                        String uuid_service,
                        String uuid_write,
                        //byte[][] frames,
                        byte[] data,
                        LcWriteBleCallback callback) {
        LcBleComm comm = new LcBleComm(bleDevice, uuid_service, uuid_write, data, LcBleComm.WRITE, callback);
        LcBleCommsQueue.add(comm);
        if (!lcProcessing) {
            lcProcessCommands();
        }
    }

    public void lcRead(BleDevice bleDevice,
                     String uuid_service,
                     String uuid_read,
                     LcReadBleCallback callback) {

        LcBleComm comm = new LcBleComm(bleDevice, uuid_service, uuid_read, LcBleComm.READ, callback);
        LcBleCommsQueue.add(comm);
        if (!lcProcessing) {
            lcProcessCommands();
        }
    }

    public void cleanCommand() {
        lcQueueCleanup();
    }

    public void readHardwareVer(BleDevice bleDevice,
                                LcReadBleCallback callback) {
        String uuid_service = SkipBleUUIDs.VERSION_SERVICE_UUID;
        String uuid_read = SkipBleUUIDs.HW_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcRead(
                bleDevice,
                uuid_service,
                uuid_read,
                callback);
    }

    public void readSoftwareVer(BleDevice bleDevice,
                                LcReadBleCallback callback) {
        String uuid_service = SkipBleUUIDs.VERSION_SERVICE_UUID;
        String uuid_read = SkipBleUUIDs.SW_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcRead(
                bleDevice,
                uuid_service,
                uuid_read,
                callback);
    }

    public void readFirmwareVer(BleDevice bleDevice,
                                LcReadBleCallback callback) {
        String uuid_service = SkipBleUUIDs.VERSION_SERVICE_UUID;
        String uuid_read = SkipBleUUIDs.FW_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcRead(
                bleDevice,
                uuid_service,
                uuid_read,
                callback);
    }



    public static class LcWriteBleCallback extends BleWriteCallback {
        private String tag = "";
        private BleDevice bleDevice;

        public LcWriteBleCallback() {}

        public LcWriteBleCallback(BleDevice bleDevice) {
            this.bleDevice = bleDevice;
        }

        @Override
        public void onWriteSuccess(int current, int total, byte[] justWrite) {
            if ( current == total ) {
                BleManager.getInstance().lcCommandCompleted();
            }
        }

        @Override
        public void onWriteFailure(BleException exception) {
            BleManager.getInstance().lcCommandCompleted();
        }

        public String getTag() {
            return tag;
        }

        public void setTag(String tag) {
            this.tag = tag;
        }


    }

    public static class LcReadBleCallback extends BleReadCallback{
        private String tag = "";
        @Override
        public void onReadSuccess(byte[] data) {
            BleManager.getInstance().lcCommandCompleted();
        }

        @Override
        public void onReadFailure(BleException exception) {
            BleManager.getInstance().lcCommandCompleted();
        }

        public String getTag() {
            return tag;
        }

        public void setTag(String tag) {
            this.tag = tag;
        }

    }


    public void registerCustomDataRxCallback(final BleDevice bleDevice, final ReceiveDataCallback receiveDataCallback) {
        BleManager.getInstance().indicate(
                bleDevice,
                SkipBleUUIDs.SERVICE_UUID,
                SkipBleUUIDs.INDICATION_CHARACTERISTIC_UUID,
                new BleIndicateCallback() {

                    @Override
                    public void onIndicateSuccess() {
//                        runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                                addText(logcat_textView, "notify success");
//                            }
//                        });
                        //Log.i(TAG, "notify success");
                    }

                    @Override
                    public void onIndicateFailure(final BleException exception) {
//                        runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                                addText(logcat_textView, exception.toString());
//                            }
//                        });
                        //Log.i(TAG, "notify failed:" + exception.toString());
                    }

                    @Override
                    public void onCharacteristicChanged(byte[] data) {
                        if(DeviceType.SKIP_DEVICE == DeviceApiActivity.getDeviceType()) {
                            SkipApiActivity api = new SkipApiActivity();
                            api.onListenBleIndication(data, receiveDataCallback);
                        }
                    }
                });
    }

    public void unregisterCustomDataRxCallback(final BleDevice bleDevice) {
        BleManager.getInstance().clearCharacterCallback(bleDevice);
        BleManager.getInstance().stopIndicate(
                bleDevice,
                SkipBleUUIDs.SERVICE_UUID,
                SkipBleUUIDs.INDICATION_CHARACTERISTIC_UUID);
    }


    public void registerFileDataRxCallback(final BleDevice bleDevice, final ReceiveFileDataCallback receiveFileDataCallback) {
        if(true == rxFileNotifyEnabled)
            return;

        BleManager.getInstance().notify(
                bleDevice,
                FileTransUUIDs.SERVICE_UUID,
                FileTransUUIDs.NOTIFY_CHARACTERISTIC_UUID,
                new BleNotifyCallback() {

                    @Override
                    public void onNotifySuccess() {
                        rxFileNotifyEnabled = true;
                    }

                    @Override
                    public void onNotifyFailure(final BleException exception) {
                    }

                    @Override
                    public void onCharacteristicChanged(byte[] data) {
                        if(DeviceType.SKIP_DEVICE == DeviceApiActivity.getDeviceType()) {
                            SkipApiActivity api = new SkipApiActivity();
                            api.onListenBleFileNotification(data, receiveFileDataCallback);
                        }
                    }
                });
    }

    public void unregisterFileDataRxCallback(final BleDevice bleDevice) {
        if(false == rxFileNotifyEnabled)
            return;
        BleManager.getInstance().clearCharacterCallback(bleDevice);
        BleManager.getInstance().stopNotify(
                bleDevice,
                FileTransUUIDs.SERVICE_UUID,
                FileTransUUIDs.NOTIFY_CHARACTERISTIC_UUID);
        rxFileNotifyEnabled = false;
    }


    private MyRunnable mClearMsgRunnable = new MyRunnable();

    private class MyRunnable implements Runnable {
        private BleDevice bleDevice;

        public void setBleDevice(BleDevice bleDevice) {
            this.bleDevice = bleDevice;
        }

        @Override
        public void run() {
            //onWriteCheckUnsentData(bleDevice);
        }
    }

    /**
     * 将字节数组转换成16进制数据,带格式转换 e.g 00-AA-BB
     * @param data
     * @return
     */
    public static String byte2hex(byte[] data)
    {
        if(data==null)
        {
            return "";
        }

        String HS = "";
        String STMP = "";
        for (int n=data.length - 1;n>=0;n--)
        {
            STMP=(Integer.toHexString(data[n]&0XFF));
            if(STMP.length()==1)
            {
                HS=HS+"0"+STMP;
            }
            else
            {
                HS=HS+STMP;
            }
            if(n!=0)
            {
                HS=HS+":";
            }
        }
        return   HS.toUpperCase();
    }
}
