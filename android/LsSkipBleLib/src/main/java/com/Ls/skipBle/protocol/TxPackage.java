package com.Ls.skipBle.protocol;

import android.util.Log;

public class TxPackage {
    private static final String TAG = TxPackage.class.getSimpleName();

    private static BlePackage blePackage = new BlePackage();

    /**
     * 发送包打包
     * @param cmd
     * @param len
     * @return
     */
    private static byte[] blePktReady(byte[] data, int cmd, int len) {
        byte[][] tmp = new byte[6][BlePackageParamDef.DATA_PAYLOAD_LEN];
        data[0] = (byte) BlePackageParamDef.PACKAGE_HEADER;
        data[1] = (byte) BlePackageParamDef.PROTOCOL_ID;

        int init_val = cmd + len;
        //Log.i(TAG, "init_val: "+init_val);
        int crc = PackageUtils.calculateCrc(init_val, data, BlePackageParamDef.PKT_DATA_START_POS, len);
        //Log.i(TAG, "crc: "+crc);
        data[2] = (byte) crc;
        data[3] = (byte) ((crc >> 8) & 0xff);
        data[4] = (byte) cmd;
        data[5] = (byte) len;
        data[6] = (byte) ((len >> 8) & 0xff);

        int rest = data.length;
        int idx = 0;
        int i = 0;
        for ( ; i < 6; i++ ) {
            if ( i == 0 ) {
                if ( rest <= BlePackageParamDef.DATA_PAYLOAD_LEN ) {
                    System.arraycopy(data, idx, tmp[i], 0, rest);
                    i++;
                    break;
                } else {
                    System.arraycopy(data, idx, tmp[i], 0, BlePackageParamDef.DATA_PAYLOAD_LEN);
                    rest = rest - BlePackageParamDef.DATA_PAYLOAD_LEN;
                    idx = idx + BlePackageParamDef.DATA_PAYLOAD_LEN;
                }
            } else {
                tmp[i][0] = (byte)i;
                if ( rest <= BlePackageParamDef.REST_FRAME_PAYLOAD_MAX_LEN ) {
                    System.arraycopy(data, idx, tmp[i], 1, rest);
                    i++;
                    break;
                } else {
                    System.arraycopy(data, idx, tmp[i], 1, BlePackageParamDef.REST_FRAME_PAYLOAD_MAX_LEN);
                    rest = rest - BlePackageParamDef.REST_FRAME_PAYLOAD_MAX_LEN;
                    idx = idx + BlePackageParamDef.REST_FRAME_PAYLOAD_MAX_LEN;
                }
            }
        }
        idx = 0;
        byte[] result = new byte[i*BlePackageParamDef.DATA_PAYLOAD_LEN];
        for ( int j = 0; j < i; j++ ) {
            System.arraycopy(tmp[j], 0, result, idx, BlePackageParamDef.DATA_PAYLOAD_LEN);
            idx += tmp[j].length;
            Log.i(TAG, String.valueOf(tmp[j].length) + " " + i + " " + j);
        }
        return result;
    }

    public static byte[] syncDeviceTime(final int utc) {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = (byte) ( utc & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+1] = (byte) ( (utc >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+2] = (byte) ( (utc >> 16) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+3] = (byte) ( (utc >> 24) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+4] = (byte) ( 480 & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+5] = (byte) ( (480 >> 8) & 0xff );
        return blePktReady(data, SkipProtocolDef.CMD_SYNC_DEV_TIME, 6);
    }

    public static byte[] setSkipMode(final int utc,
                            final int mode,
                            final int setParam,
                            final int start_secs) {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = (byte) ( mode & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+1] = (byte) ( setParam & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+2] = (byte) ( (setParam >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+3] = (byte) ( utc & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+4] = (byte) ( (utc >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+5] = (byte) ( (utc >> 16) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+6] = (byte) ( (utc >> 24) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+7] = (byte) ( start_secs & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+8] = (byte) ( (start_secs >> 8) & 0xff );
        return blePktReady(data, SkipProtocolDef.CMD_SET_JUMP_MODE, 9);
    }

    public static byte[] stopSkip() {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        return blePktReady(data, SkipProtocolDef.CMD_STOP_JUMP, 1);
    }

    public static byte[] writeSkipRealTimeResultRsp(int pkt_idx) {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = 0;
        data[BlePackageParamDef.PKT_DATA_START_POS+1] = (byte)pkt_idx;
        return blePktReady(data, SkipProtocolDef.CMD_REALTIME_RESULT_DATA, 2);
    }

    public static byte[] writeSkipHistoryResultRsp(int pkt_idx) {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = 0;
        data[BlePackageParamDef.PKT_DATA_START_POS+1] = (byte)pkt_idx;
        return blePktReady(data, SkipProtocolDef.CMD_HISTORY_RESULT_DATA, 2);
    }

    public static byte[] writeSkipDevReset() {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        return blePktReady(data, SkipProtocolDef.CMD_RESET_DEV, 1);
    }

    public static byte[] writeSkipDevRevert() {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        return blePktReady(data, SkipProtocolDef.CMD_REVERT_DEV, 1);
    }

    public static byte[] writeSkipSetDevAdvName(byte[] name, final int name_len) {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = (byte)name_len;
        for (int i=0 ; i < name_len; i++ ) {
            data[BlePackageParamDef.PKT_DATA_START_POS+1+i] = name[i];
        }
        return blePktReady(data, SkipProtocolDef.CMD_SET_DEV_ADV_NAME, name_len+1);
    }

    public static byte[] writeSkipGenerateECCKey() {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        for (int i=0 ; i < 4; i++ ) {
            data[BlePackageParamDef.PKT_DATA_START_POS+i] = 0;
        }
        return blePktReady(data, SkipProtocolDef.CMD_GEN_ECC_KEY, 4);
    }

    public static byte[] writeSkipGetPublicKey() {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        return blePktReady(data, SkipProtocolDef.CMD_GET_DEV_PUB_KEY, 1);
    }


    public static byte[] writeSkipBondDev(String address) {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        for (int i=0 ; i < 4; i++ ) {
            data[BlePackageParamDef.PKT_DATA_START_POS+i] = (byte)0;
            if(i==3)
            data[BlePackageParamDef.PKT_DATA_START_POS+i] = (byte)1;
        }
        byte[] adds=HexUtil.hexStringToBytes(address);
        for (int i=0 ; i < adds.length; i++ ) {
            data[BlePackageParamDef.PKT_DATA_START_POS+i+4] = adds[i];
        }
        return blePktReady(data, SkipProtocolDef.CMD_BOND_DEV, 24);
    }
    public static byte[] writeSkipBondDev() {
        byte[] data = new byte[BlePackageParamDef.DATA_PAYLOAD_LEN];
        for (int i=0 ; i < 24; i++ ) {
            data[BlePackageParamDef.PKT_DATA_START_POS+i] = (byte)1;
        }
        return blePktReady(data, SkipProtocolDef.CMD_BOND_DEV, 24);
    }
}
