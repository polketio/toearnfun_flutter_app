package io.polket.toearnfun_flutter_app.bluetooth;

import android.annotation.SuppressLint;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class ErrorCode {
    public static final int UNKNOWN_ERROR = -1;
    public static final int UNINITIALIZED = -2;
    public static final int PARAMETER_ERROR_CODE = 1;
    public static final int FILE_FORMAT_ERROR_CODE = 2;
    public static final int FILE_UPDATE_MODEL_ERROR_CODE = 3;
    public static final int FILE_CHECK_MODEL_ERROR_CODE = 4;
    public static final int BLE_MANAGER_STATE_ERROR_CODE = 5;
    public static final int DEVICE_NOT_CONNECTED = 7;
    public static final int DEVICE_UNSUPPORTED = 8;
    public static final int DEVICE_RETRUN_FAIL = 9;
    public static final int FILE_VERIFY_ERROR_CODE = 9;
    public static final int DATA_RECEIVE_ERROR_CODE = 10;
    public static final int LOW_BATTERY = 11;
    public static final int CODE_VERSION_NOT_MATCH = 12;
    public static final int FILE_HEADER_CHECK_FAIL = 13;
    public static final int FLASH_SAVE_FAIL = 14;
    public static final int SCAN_ERROR = 15;
    public static final int CONNECTION_FAILED = 17;
    public static final int CONNECTION_ERROR = 21;
    public static final int BlLUETOOTH_DISABLE = 23;
    public static final int ABNORMAL_DISCONNECT = 24;
    public static final int WRITE_CHARACTERISTIC_FAILURE = 25;
    public static final int CANCEL_UPGRADE = 26;
    public static final int DEVICE_CONFIG_FAILURE = 27;
    public static final int SETTING_TIMEOUT = 28;
    public static final int ADD_REMINDER_FAILURE = 29;
    private static Map errorCodeMap;

    public ErrorCode() {
    }

    @SuppressLint({"UseSparseArrays"})
    private static Map getErrorCodeMap() {
        if (errorCodeMap != null && errorCodeMap.size() != 0) {
            return errorCodeMap;
        } else {
            HashMap<Integer, String> var0 = new HashMap<Integer, String>();
            var0.put(-1, "unknown");
            var0.put(-2, "uninitialized");
            var0.put(1, "parameter error");
            var0.put(2, "file format error");
            var0.put(3, "update model error");
            var0.put(4, "check model error");
            var0.put(5, "working status error");
            var0.put(7, "device not connected");
            var0.put(8, "device unsupported");
            var0.put(9, "file verification error");
            var0.put(10, "failed to receive data");
            var0.put(11, "low battery");
            var0.put(12, "code version error");
            var0.put(13, "file header verify error");
            var0.put(14, "flash save failed");
            var0.put(15, "scan timeout");
            var0.put(17, "connect failed");
            var0.put(21, "connect error");
            var0.put(23, "bluetooth disable");
            var0.put(24, "abnormal disconnect");
            var0.put(25, "write characteristic failed");
            var0.put(26, "cancel upgrading by user");
            return errorCodeMap = Collections.unmodifiableMap(var0);
        }
    }

    public static String getCodeName(int var0) {
        String var1 = (String)getErrorCodeMap().get(var0);
        if (var1 == null || var1.length() == 0) {
            var1 = "null";
        }

        return var1;
    }
}
