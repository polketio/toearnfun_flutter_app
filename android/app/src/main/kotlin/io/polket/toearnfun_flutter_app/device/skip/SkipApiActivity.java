package io.polket.toearnfun_flutter_app.device.skip;

import android.annotation.SuppressLint;
import android.util.Log;
import android.widget.Toast;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import com.Ls.fileTrans.FileTransManager;
import com.Ls.fileTrans.FileTransParamDef;
import com.Ls.fileTrans.FileTransReceivePack;
import com.Ls.fileTrans.FileTransSendPack;
import com.Ls.fileTrans.FileTransUUIDs;
import com.Ls.fileTrans.ReceiveFileDataCallback;
import com.Ls.fileTrans.SendFileDataCallback;
import com.Ls.skipBle.ReceiveDataCallback;
import com.Ls.skipBle.SkipBleReceivePack;
import com.Ls.skipBle.SkipBleSendPack;
import com.Ls.skipBle.SkipBleUUIDs;
import com.Ls.skipBle.SkipDisplayData;
import com.Ls.skipBle.SkipParamDef;
import com.Ls.skipBle.SkipResultData;
import io.polket.toearnfun_flutter_app.BluetoothFlutterPlugin;
import io.polket.toearnfun_flutter_app.DeviceApiActivity;
import io.polket.toearnfun_flutter_app.R;
import io.polket.toearnfun_flutter_app.bluetooth.BleManager;
import io.polket.toearnfun_flutter_app.data.BleDevice;
import io.polket.toearnfun_flutter_app.exception.BleException;
import io.polket.toearnfun_flutter_app.utils.HexUtil;

import io.flutter.plugin.common.MethodChannel;


public class SkipApiActivity {
    public static final String KEY_DATA = "key_data";
    private static final String TAG = SkipApiActivity.class.getSimpleName();

    private SkipBleSendPack txPack = new SkipBleSendPack();
    private SkipBleReceivePack rxPack = new SkipBleReceivePack();

    private FileTransSendPack txFilePack = new FileTransSendPack();
    private FileTransReceivePack rxFilePack = new FileTransReceivePack();

    private static int tmp_used_sec = 0;
    private static int tmp_skip_cnt = 0;
    private static int tmp_trip_cnt = 0;
    private static int tmp_batt_per = 0;
    private static MethodChannel.Result mResult = null;
    private static EventChannel.EventSink mEventChannel;

    public void setMethodChannelResult(MethodChannel.Result result) {
        this.mResult = result;
    }

    public void setEventChannelEventSink(EventChannel.EventSink eventChannel) {
        this.mEventChannel = eventChannel;
    }


    private ReceiveDataCallback customRxDataCallback = new ReceiveDataCallback() {
        @Override
        public void onReceiveDisplayData(SkipDisplayData display) {
            if (tmp_used_sec != display.getSkipSecSum() || tmp_skip_cnt != display.getSkipCntSum() || tmp_trip_cnt != display.getTripCnt() || tmp_batt_per != display.getBatteryPercent()) {
                tmp_used_sec = display.getSkipSecSum();
                tmp_skip_cnt = display.getSkipCntSum();
                tmp_trip_cnt = display.getTripCnt();
                tmp_batt_per = display.getBatteryPercent();
                String modeStr = "";
                String ParamStr = "";
                switch (display.getMode()) {
                    case SkipParamDef.MODE_COUNT_DOWN: {
                        modeStr = "倒计时";
                        ParamStr = "秒";
                    }
                    break;

                    case SkipParamDef.MODE_COUNT_BACK: {
                        modeStr = "倒计数";
                        ParamStr = "次";
                    }
                    break;

                    case SkipParamDef.MODE_FREE_JUMP: {
                        modeStr = "自由跳";
                    }
                    break;

                    default:
                        break;
                }
              /*  final String s = "模式: " + modeStr + ", 设置: " + display.getSetting() + ParamStr + ", 时间: " + Integer.toString(display.getSkipSecSum()) + ", 次数: " + Integer.toString(display.getSkipCntSum()) +
                        ", 绊绳: " + Integer.toString(display.getTripCnt()) + ", 电量:" + Integer.toString(display.getBatteryPercent()) + ", 有效时长:" + Integer.toString(display.getSkipValidSec());
               */
                //1实时结果数据上传
                final String param = "{" +
                        "\"messageType\":\"1\", \"messageContext\":{" +
                        "\"mode\": " + display.getMode() + ", " +
                        "\"setting\": " + display.getSetting() + ", " +
                        "\"skipSecSum\": " + display.getSkipSecSum() + ", " +
                        "\"skipCntSum\": " + display.getSkipCntSum() + ", " +
                        "\"batteryPercent\": " + display.getBatteryPercent() + ", " +
                        "\"skipValidSec\": " + display.getSkipValidSec() +
                        "}}";

                if (mEventChannel != null)
                    mEventChannel.success(param);
            }
        }

        @Override
        public void onReceiveSkipRealTimeResultData(SkipResultData result, int pkt_idx) {
            //  String str = "[接收][成功] 跳绳实时结果: " + "(" + pkt_idx + ")";
            String str = "SkipRealTimeResult: " + "(" + pkt_idx + ")";
            str += "UTC: " + Integer.toString(result.getUtc());
            switch (result.getMode()) {
                case SkipParamDef.MODE_COUNT_DOWN: {
                    str += " 倒计时: " + Integer.toString(result.getSetting()) + "秒";
                }
                break;

                case SkipParamDef.MODE_COUNT_BACK: {
                    str += " 倒计数: " + Integer.toString(result.getSetting()) + "次";
                }
                break;

                case SkipParamDef.MODE_FREE_JUMP: {
                    str += " 自由跳";
                }
                break;

                default:
                    break;
            }
          /*
            str += " 总时长: " + Integer.toString(result.getSkipSecSum()) + "秒";
            str += " 总次数: " + Integer.toString(result.getSkipCntSum()) + "次";
            str += " 有效时长: " + Integer.toString(result.getSkipValidSec()) + "秒";
            str += " 平均频次: " + Integer.toString(result.getFreqAvg()) + "次";
            str += " 最快频次: " + Integer.toString(result.getFreqMax()) + "次";
            str += " 最大连跳: " + Integer.toString(result.getConsecutiveSkipMaxNum()) + "次";
            str += " 绊绳次数: " + Integer.toString(result.getSkipTripNum()) + "次";
            */
            /*str += " 跳绳组: ";
            for(int i=0;i<result.getSkipGroupNum();i++) {
                str += Integer.toString(result.getSkipGroupEleSkipSecs(i)) + "," + Integer.toString(result.getSkipGroupEleSkipCnt(i)) + " ";
            }*/

            //2，跳绳结果上传
            final String param = "{\"messageType\":\"2\", " +
                    "\"messageContext\": {" +
                    "\"timestamp\": " + result.getUtc() + ", " +
                    "\"skipSecSum\": " + result.getSkipSecSum() + ", " +
                    "\"skipCntSum\": " + result.getSkipCntSum() + ", " +
                    "\"skipValidSec\": " + result.getSkipValidSec() + ", " +
                    "\"freqAvg\": " + result.getFreqAvg() + ", " +
                    "\"freqMax\": " + result.getFreqMax() + ", " +
                    "\"consecutiveSkipMaxNum\": " + result.getConsecutiveSkipMaxNum() + ", " +
                    "\"skipTripNum\": " + result.getSkipTripNum() + ", " +
                    "\"signature\": \"" + HexUtil.encodeHexStr(result.getSignature(), true) + "\"" +
                    "}}";
            if (mEventChannel != null)
                mEventChannel.success(param);
        }

        @Override
        public void onReceiveSkipHistoryResultData(SkipResultData result, int pkt_idx) {
            // String str = "[接收][成功] 跳绳历史结果: " + "(" + pkt_idx + ")";
            String str = "SkipResultData: " + "(" + pkt_idx + ")";
            str += "UTC: " + Integer.toString(result.getUtc());
            switch (result.getMode()) {
                case SkipParamDef.MODE_COUNT_DOWN: {
                    str += " 倒计时: " + Integer.toString(result.getSetting()) + "秒";
                }
                break;

                case SkipParamDef.MODE_COUNT_BACK: {
                    str += " 倒计数: " + Integer.toString(result.getSetting()) + "次";
                }
                break;

                case SkipParamDef.MODE_FREE_JUMP: {
                    str += " 自由跳";
                }
                break;

                default:
                    break;
            }



           /* str += " 总时长: " + Integer.toString(result.getSkipSecSum()) + "秒";
            str += " 总次数: " + Integer.toString(result.getSkipCntSum()) + "次";
            str += " 有效时长: " + Integer.toString(result.getSkipValidSec()) + "秒";
            str += " 平均频次: " + Integer.toString(result.getFreqAvg()) + "次";
            str += " 最快频次: " + Integer.toString(result.getFreqMax()) + "次";
            str += " 最大连跳: " + Integer.toString(result.getConsecutiveSkipMaxNum()) + "次";
            str += " 绊绳次数: " + Integer.toString(result.getSkipTripNum()) + "次";*/

            /*str += " 跳绳组: ";
            for(int i=0;i<result.getSkipGroupNum();i++) {
                str += Integer.toString(result.getSkipGroupEleSkipSecs(i)) + "," + Integer.toString(result.getSkipGroupEleSkipCnt(i)) + " ";
            }*/

            //3，跳绳历史数据上传
            final String param = "{\"messageType\":\"3\", " +
                    "\"messageContext\": {" +
                    "\"timestamp\": " + result.getUtc() + ", " +
                    "\"skipSecSum\": " + result.getSkipSecSum() + ", " +
                    "\"skipCntSum\": " + result.getSkipCntSum() + ", " +
                    "\"skipValidSec\": " + result.getSkipValidSec() + "\", " +
                    "\"freqAvg\": " + result.getFreqAvg() + ", " +
                    "\"freqMax\": " + result.getFreqMax() + ", " +
                    "\"consecutiveSkipMaxNum\": " + result.getConsecutiveSkipMaxNum() + ", " +
                    "\"skipTripNum\": " + result.getSkipTripNum() + ", " +
                    "\"signature\": \"" + HexUtil.encodeHexStr(result.getSignature(), true) + "\"" +
                    "}}";
            if (mEventChannel != null)
                mEventChannel.success(param);

        }

        @Override
        public void onReceiveEnteredOtaMode(String mac) {
            super.onReceiveEnteredOtaMode(mac);
            final String s = "[接收][成功] 进入OTA模式, mac:" + mac;
            //  mResult.success(s);
        }

        @Override
        public void onReceiveEnteredFactoryMode() {
            super.onReceiveEnteredFactoryMode();
            final String s = "[接收][成功] 进入工厂模式";
            //    mResult.success(s);
        }

        @Override
        public void onReceiveRevertDevice() {
            super.onReceiveRevertDevice();
            final String s = "[接收][成功] 恢复出厂";
            //  mResult.success(s);
        }

    };


    public void init(BleDevice mBleDevice) {
        BleManager.getInstance().registerCustomDataRxCallback(mBleDevice, customRxDataCallback);
        // fileTransSendPackInit();
    }

    public void onListenBleFileNotification(byte[] data, final ReceiveFileDataCallback receiveFileDataCallback) {
        rxFilePack.onListenBleFileNotification(data, new ReceiveFileDataCallback() {
            @Override
            public void onReceiveHeadInfoRspData(int error_code) {
                receiveFileDataCallback.onReceiveHeadInfoRspData(error_code);
            }

            @Override
            public void onReceiveFileRspSw(int error_code) {
                receiveFileDataCallback.onReceiveFileRspSw(error_code);
            }

            @Override
            public void onReceiveFileRxDataLen(int rx_len) {
                receiveFileDataCallback.onReceiveFileRxDataLen(rx_len);
            }
        });
    }


    /* Ble protocol */
    public void onListenBleIndication(byte[] data, final ReceiveDataCallback receiveDataCallback) {
        rxPack.onListenBleIndication(data, new ReceiveDataCallback() {
            @Override
            public void onReceiveDisplayData(SkipDisplayData display) {
                receiveDataCallback.onReceiveDisplayData(display);
//                Log.i(TAG, "onReceiveDisplayData");
            }

            @Override
            public void onReceiveSkipRealTimeResultData(SkipResultData result, int pkt_idx) {
                onWriteSkipRealTimeResultRsp(BluetoothFlutterPlugin.mBleDevice, pkt_idx);
                receiveDataCallback.onReceiveSkipRealTimeResultData(result, pkt_idx);
                Log.i(TAG, "onReceiveSkipRealTimeResultData");
            }

            @Override
            public void onReceiveSkipHistoryResultData(SkipResultData result, int pkt_idx) {
                onWriteSkipHistoryResultRsp(BluetoothFlutterPlugin.mBleDevice, pkt_idx);
                receiveDataCallback.onReceiveSkipHistoryResultData(result, pkt_idx);
                Log.i(TAG, "onReceiveSkipHistoryResultData");
            }

            @Override
            public void onReceiveRevertDevice() {
                receiveDataCallback.onReceiveRevertDevice();
            }

            @SuppressLint("LongLogTag")
            @Override
            public void onReceivewriteSkipGenerateECCKey(String cmd, String data) {
                receiveDataCallback.onReceivewriteSkipGenerateECCKey(cmd, data);
                if (mResult != null) {
                    mResult.success(data);
                }
                Log.i("onReceivewriteSkipGenerateECCKey", data);
            }

            @SuppressLint("LongLogTag")
            @Override
            public void onReceivewriteSkipGetPublicKey(String cmd, String data) {
                receiveDataCallback.onReceivewriteSkipGetPublicKey(cmd, data);
                if (mResult != null) {
                    mResult.success(data);
                }
                Log.i("onReceivewriteSkipGetPublicKey", data);
            }

            @SuppressLint("LongLogTag")
            @Override
            public void onReceivewriteSkipBondDev(String data) {
                receiveDataCallback.onReceivewriteSkipBondDev(data);
                if (mResult != null) {
                    mResult.success(data);
                }
                Log.i("onReceivewriteSkipBondDev", data);
            }
        });
    }


    public void syncDeviceTime(BleDevice bleDev,
                               final int utc,
                               BleManager.LcWriteBleCallback callback) {
        Log.i(TAG, "utc: " + utc);
        byte[] d = txPack.syncDeviceTime(utc);
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    public void setSkipMode(BleDevice bleDev,
                            final int utc,
                            final int mode,
                            final int setParam,
                            final int start_secs,
                            BleManager.LcWriteBleCallback callback) {
        byte[] d = txPack.setSkipMode(utc, mode, setParam, start_secs);
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    public void stopSkip(BleDevice bleDev,
                         BleManager.LcWriteBleCallback callback) {
        byte[] d = txPack.stopSkip();
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        //Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    public void devReset(BleDevice bleDev,
                         BleManager.LcWriteBleCallback callback) {
        byte[] d = txPack.writeSkipDevReset();
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        //Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    public void devRevert(BleDevice bleDev,
                          BleManager.LcWriteBleCallback callback) {
        byte[] d = txPack.writeSkipDevRevert();
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        //Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    public void setDevAdvName(byte[] name,
                              int name_len,
                              BleDevice bleDev,
                              BleManager.LcWriteBleCallback callback) {
        byte[] d = txPack.writeSkipSetDevAdvName(name, name_len);
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        //Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    private void onWriteSkipRealTimeResultRsp(BleDevice bleDev, int pkt_idx) {
        byte[] d = txPack.writeSkipRealTimeResultRsp(pkt_idx);

        String sd = HexUtil.encodeHexStr(d);
        Log.i("02 跳绳结果上传:", sd);

        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                new BleManager.LcWriteBleCallback(bleDev) {
                    @Override
                    public void onWriteSuccess(int current, int total, byte[] justWrite) {
                        super.onWriteSuccess(current, total, justWrite);
                        if (current == total) {
                            Log.i(TAG, "[写入][成功] 实时结果数据响应");
                        }
                    }

                    @Override
                    public void onWriteFailure(BleException exception) {
                        super.onWriteFailure(exception);
                        Log.i(TAG, "[写入][失败] 实时结果数据响应" + exception.toString());
                    }
                });
    }

    private void onWriteSkipHistoryResultRsp(BleDevice bleDev, int pkt_idx) {
        byte[] d = txPack.writeSkipHistoryResultRsp(pkt_idx);
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                new BleManager.LcWriteBleCallback(bleDev) {
                    @Override
                    public void onWriteSuccess(int current, int total, byte[] justWrite) {
                        super.onWriteSuccess(current, total, justWrite);
                        if (current == total) {
                            Log.i(TAG, "[写入][成功] 历史结果数据响应");
                        }
                    }

                    @Override
                    public void onWriteFailure(BleException exception) {
                        super.onWriteFailure(exception);
                        Log.i(TAG, "[写入][失败] 历史结果数据响应" + exception.toString());
                    }
                });
    }


    public void writeSkipGenerateECCKey(BleDevice bleDev,
                                        BleManager.LcWriteBleCallback callback) {
        byte[] d = txPack.writeSkipGenerateECCKey();
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        //Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        Log.i(TAG, "writeSkipGenerateECCKey");
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    public void writeSkipGetPublicKey(BleDevice bleDev,
                                      BleManager.LcWriteBleCallback callback) {
        byte[] d = txPack.writeSkipGetPublicKey();
        String strd = HexUtil.encodeHexStr(d);
        //Log.i(TAG, HexUtil.encodeHexStr(data));
        //Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }

    public void writeSkipBondDev(BleDevice bleDev, int none, byte[] address,
                                 BleManager.LcWriteBleCallback callback) {
       /* String address="422d0010f16ae8539c53eb57a912890244a9eb5a";
        String none="100";*/
        byte[] d = txPack.writeSkipBondDev(none, address);
        //Log.i(TAG, HexUtil.encodeHexStr(data));
//        Log.i("绑定设备", HexUtil.encodeHexStr(d));
//        Log.i(TAG, HexUtil.encodeHexStr(d));
        String uuid_service = SkipBleUUIDs.SERVICE_UUID;
        String uuid_write = SkipBleUUIDs.WRITE_CHARACTERISTIC_UUID;
        BleManager.getInstance().lcWrite(
                bleDev,
                uuid_service,
                uuid_write,
                d,
                callback);
    }


    // ********************  File Trans Part *******************************/
    /*private void fileTransSendPackInit() {
        FileTransSendPack tx = new FileTransSendPack();
        tx.setSendPackHandle(sendFileDataCb);
    }
*/
  /*  private SendFileDataCallback sendFileDataCb = new SendFileDataCallback()
    {
        public void txCtrlPoint(byte[] payload) {
            Log.i("FileTransDfu", "txCtrlPoint");
            String uuid_service = FileTransUUIDs.SERVICE_UUID;
            String uuid_write = FileTransUUIDs.WRITE_CHARACTERISTIC_UUID;

            BleManager.getInstance().lcRawWrite(
                    DeviceApiActivity.getBleDevice(),
                    uuid_service,
                    uuid_write,
                    payload,
                    mSettingCallback);
        }

        public void txFileData(byte[] payload) {
            String uuid_service = FileTransUUIDs.SERVICE_UUID;
            String uuid_write = FileTransUUIDs.FILE_DATA_CHARACTERISTIC_UUID;

            if(FileTransParamDef.FILE_TYPE_TXT == FileTransManager.getFileTransType()) {
                mSettingCallback.setTag("字符传输");
            }
            else if(FileTransParamDef.FILE_TYPE_OTA == FileTransManager.getFileTransType()) {
                FileTransManager dfuManager = new FileTransManager();
                mSettingCallback.setTag("升级进度: " + dfuManager.getProgressPercentString()+"%");
                //Log.i("FileTransDfu", "进度: " + dfuManager.getProgressPercentString()+"%");
            }
            else if(FileTransParamDef.FILE_TYPE_IMAGE == FileTransManager.getFileTransType()) {
                FileTransManager imageManager = new FileTransManager();
                mSettingCallback.setTag("传输进度: " + imageManager.getProgressPercentString()+"%");
                //Log.i("FileTransDfu", "进度: " + imageManager.getProgressPercentString()+"%");
            }

            BleManager.getInstance().lcRawWrite(
                    DeviceApiActivity.getBleDevice(),
                    uuid_service,
                    uuid_write,
                    payload,
                    mSettingCallback);
        }

        public void txDone() {
            mSettingCallback.setTag("");
            final String s = "进度: " + "100%";
            DeviceApiActivity a = new DeviceApiActivity();
            a.outputLog(s);
            Log.i("FileTransDfu", "txDone");
        }
    };*/


    public ReceiveFileDataCallback fileRxDataCallback = new ReceiveFileDataCallback() {
        @Override
        public void onReceiveHeadInfoRspData(int error_code) {
            final String s = "onReceiveHeadInfoRspData: " + error_code;
            DeviceApiActivity a = new DeviceApiActivity();
            a.outputLog(s);
            Log.i("FileTrans", s);
            if (error_code == 0) {
                FileTransManager pg = new FileTransManager();
                if (false == FileTransManager.getFileTransRspSwState()) {
                    pg.fileTransProgress();
                } else {
                    pg.fileTransSetRspEn();
                }
            }
        }

        @Override
        public void onReceiveFileRspSw(int error_code) {
            final String s = "onReceiveFileRspSw";
            Log.i("FileTrans", s);
            DeviceApiActivity a = new DeviceApiActivity();
            a.outputLog(s);
            FileTransManager pg = new FileTransManager();
            pg.fileTransSetRxLen(0);
        }

        @Override
        public void onReceiveFileRxDataLen(int rx_len) {
            final String s = "onReceiveFileRxLen: " + rx_len;
            Log.i("FileTrans", "onReceiveFileRxLen: " + rx_len);
            DeviceApiActivity a = new DeviceApiActivity();
            a.outputLog(s);
            FileTransManager pg = new FileTransManager();
            pg.fileTransSetRxLen(rx_len);
        }

    };


}

