package io.polket.toearnfun_flutter_app.dfu;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.net.Uri;
import android.util.Log;

import no.nordicsemi.android.dfu.DfuServiceInitiator;

public class DfuManager {
    private static Context baseContext = null;
    private static final String TAG = DfuManager.class.getSimpleName();

    public static final String CONNECTED_DEVICE_CHANNEL = "connected_device_channel";
    public static final String FILE_SAVED_CHANNEL = "file_saved_channel";
    public static final String PROXIMITY_WARNINGS_CHANNEL = "proximity_warnings_channel";

    public static void initActivityContext(Activity activity){
        baseContext = activity;
    }

    public static DfuManager getInstance() {
        return DfuManagerHolder.sDfuManager;
    }

    private static class DfuManagerHolder {
        private static final DfuManager sDfuManager = new DfuManager();
    }


    /**
     * 启动DFU升级服务
     *
     * @param bluetoothDevice 蓝牙设备
     * @param keepBond        升级后是否保持连接
     * @param force           将DFU设置为true将防止跳转到DFU Bootloader引导加载程序模式
     * @param PacketsReceipt  启用或禁用数据包接收通知（PRN）过程。
     *                        默认情况下，在使用Android Marshmallow或更高版本的设备上禁用PEN，并在旧设备上启用。
     * @param numberOfPackets 如果启用分组接收通知过程，则此方法设置在接收PEN之前要发送的分组数。 PEN用于同步发射器和接收器。
     * @param uri             约定匹配的ZIP文件的路径。
     */
    private void startDFU(BluetoothDevice bluetoothDevice, boolean keepBond, boolean force,
                          boolean PacketsReceipt, int numberOfPackets, int mtu, Uri uri) {

        Log.i(TAG, "startDFU");
        final DfuServiceInitiator dfuStart = new DfuServiceInitiator(bluetoothDevice.getAddress())
                .setDeviceName(bluetoothDevice.getName())
                .setKeepBond(keepBond)
                .setForceDfu(force)
                .setPacketsReceiptNotificationsEnabled(PacketsReceipt)
                .setPacketsReceiptNotificationsValue(numberOfPackets);
        //dfuStart.setZip(R.raw.update);
        dfuStart.setZip(uri, uri.getPath());
        dfuStart.start(baseContext, DfuService.class);
    }

    public void startDfuProgress(BluetoothDevice bluetoothDevice, Uri uri) {
        startDFU(bluetoothDevice,true, false, false, 0, 243, uri);
    }
}
