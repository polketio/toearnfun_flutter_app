package com.Ls.skipBle.protocol;

import android.util.Log;

import com.Ls.skipBle.ReceiveDataCallback;
import com.Ls.skipBle.SkipDisplayData;
import com.Ls.skipBle.SkipResultData;

public class RxPackage {
    private static final String TAG = RxPackage.class.getSimpleName();

    private static BlePackage blePackage = new BlePackage();

    private static int ByteToInt(byte val) {
        return (val & 0xff);
    }

    private void parseBlePktHead(byte[] data) {
        blePackage.setPacket_head(ByteToInt(data[0]));
        blePackage.setProto_id(ByteToInt(data[1]));
        blePackage.setCrc(ByteToInt(data[2]) + (ByteToInt(data[3]) << 8));
        blePackage.setCmd(ByteToInt(data[4]));
        blePackage.setPayloadLen(ByteToInt(data[5]) + (ByteToInt(data[6]) << 8));
        //Log.i("tag", Integer.toHexString(seq) + " " + Integer.toHexString(proto_id) + " " + Integer.toHexString(cmd) + " " + Integer.toHexString(crc32) + " " + len);
    }

    /**
     * 接收包处理
     *
     * @param data
     * @return
     */
    public void onListenBleIndication(byte[] data, final ReceiveDataCallback receiveDataCallback) {
        BlePackage retPackage = onRxPackageConsist(data);
        onRxPackageParse(retPackage, receiveDataCallback);
    }


    private BlePackage onRxPackageConsist(byte[] data) {
        BlePackage retPackage = new BlePackage();
//        Log.i(TAG, ByteToInt(data[0]) + "  " + ByteToInt(data[1]));
        if ((ByteToInt(data[0]) == BlePackageParamDef.PACKAGE_HEADER) && (ByteToInt(data[1]) == BlePackageParamDef.PROTOCOL_ID)) {
            if (data.length < BlePackageParamDef.PKT_DATA_START_POS) {
                blePackage.resetPackage();
                Log.i(TAG, "Rx err len");
                return retPackage;
            }
            blePackage.resetPackage();
            parseBlePktHead(data);
            for (int i = 0; i < data.length - BlePackageParamDef.PKT_DATA_START_POS; i++) {
                blePackage.setPayloadEle(i, data[i + BlePackageParamDef.PKT_DATA_START_POS]);
            }
            blePackage.setRx_idx(data.length - BlePackageParamDef.PKT_DATA_START_POS);
            //Log.i(TAG, "++++1" + HexUtil.encodeHexStr(blePackage.getPayload()));
        } else {
            int frame_seq = ByteToInt(data[0]);
            if (data.length < 2 || frame_seq <= 0) {
                blePackage.resetPackage();
                return retPackage;
            }
            if (blePackage.getRx_idx() != ((frame_seq - 1) * BlePackageParamDef.REST_FRAME_PAYLOAD_MAX_LEN + BlePackageParamDef.FIRST_FRAME_PAYLOAD_MAX_LEN)) {
                //Log.i(TAG, "++++22 " + blePackage.getRx_idx() + " " + ( (frame_seq - 1)*blePackage.REST_FRAME_PAYLOAD_MAX_LEN + blePackage.FIRST_FRAME_PAYLOAD_MAX_LEN ));
                blePackage.resetPackage();
                return retPackage;
            }
            blePackage.setFrame_seq(frame_seq);
            for (int i = 1; i < data.length; i++) {
                if ((i + blePackage.getRx_idx() - 1) < blePackage.getPayloadLen()) {
                    blePackage.setPayloadEle(i + blePackage.getRx_idx() - 1, data[i]);
                }
            }
            blePackage.setRx_idx(blePackage.getRx_idx() + data.length - 1);
            //Log.i(TAG, "++++2" + HexUtil.encodeHexStr(blePackage.getPayload()));
        }

        //Log.i(TAG, "head: "+blePackage.getPacket_head()+"id: "+blePackage.getProto_id()+"id: "+blePackage.getRx_idx()+"payloadLen: "+blePackage.getPayloadLen());
        if ((BlePackageParamDef.PACKAGE_HEADER == blePackage.getPacket_head()) && (BlePackageParamDef.PROTOCOL_ID == blePackage.getProto_id())) {
            if (blePackage.getRx_idx() >= blePackage.getPayloadLen()) {
                int rx_crc = blePackage.getCrc();
                int crc_init_val = blePackage.getCmd() + blePackage.getPayloadLen();
                int cal_crc = PackageUtils.calculateCrc(crc_init_val, blePackage.getPayload(), 0, blePackage.getPayloadLen());
                if (rx_crc == cal_crc) {
//                    Log.i(TAG, "RxCmd: " + blePackage.getCmd());
                    retPackage.setCmd(blePackage.getCmd());
                    retPackage.setPayload(blePackage.getPayload());
                    retPackage.setPayloadLen(blePackage.getPayloadLen());
                    blePackage.resetPackage();
                } else {
                    Log.i(TAG, "Err rx_crc32: " + rx_crc);
                    Log.i(TAG, "Err cal_crc32: " + cal_crc);
                }
            }
        }
        if (blePackage.getCmd() == SkipProtocolDef.CMD_REALTIME_RESULT_DATA) {
            String s = HexUtil.encodeHexStr(data);
            Log.i(TAG, "2.2.2" + s);

        }
//         Log.i(TAG, "++++++++++++++" + HexUtil.encodeHexStr(data));
        String s = HexUtil.encodeHexStr(data);
        // Log.i(TAG, "++++++++++++++---" + retPackage.getCmd() + " " + HexUtil.encodeHexStr(retPackage.getPayload()));
        return retPackage;
    }

    private void onRxPackageParse(BlePackage retPackage, final ReceiveDataCallback receiveDataCallback) {
        /*if(retPackage.getCmd() != 0) {
            Log.i(TAG, "getCmd: " + retPackage.getCmd());
        }*/

        switch (retPackage.getCmd()) {

            case SkipProtocolDef.CMD_DISPLAY_DATA: {
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());
                int mode = (buf[0] & 0xff);
                int setting = (buf[1] & 0xff) + ((buf[2] & 0xff) << 8);
                int skip_sec_sum = (buf[3] & 0xff) + ((buf[4] & 0xff) << 8);
                int skip_cnt_sum = (buf[5] & 0xff) + ((buf[6] & 0xff) << 8);
                int trip_cnt = (buf[7] & 0xff);
                int battery_per = (buf[8] & 0xff);
                int skip_valid_sec = 0;
                if (retPackage.getPayloadLen() >= 11) {
                    skip_valid_sec = (buf[9] & 0xff) + ((buf[10] & 0xff) << 8);
                }
                SkipDisplayData display = new SkipDisplayData(mode, setting, skip_sec_sum, skip_cnt_sum, trip_cnt, battery_per, skip_valid_sec);
//                Log.i(TAG, "mode >> " + display.getMode() + " set >> " + display.getSetting() + " skip_secs >> " + display.getSkipSecSum() +
//                        " skip_cnt >> " + display.getSkipCntSum()+ " trip_cnt >> " + display.getTripCnt() + " battery_per >> " + display.getBatteryPercent() + " valid sec >> " + display.getSkipValidSec());
                receiveDataCallback.onReceiveDisplayData(display);
            }
            break;

            case SkipProtocolDef.CMD_REALTIME_RESULT_DATA:
            case SkipProtocolDef.CMD_HISTORY_RESULT_DATA: {
                Log.i(TAG, "CMD_HISTORY_RESULT_DATA: " + retPackage.getCmd() + " " + HexUtil.encodeHexStr(retPackage.getPayload()));
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());
                SkipResultData ret = new SkipResultData();
                ret.reset();
                ret.setUtc((buf[0] & 0xff) + ((buf[1] & 0xff) << 8) + ((buf[2] & 0xff) << 16) + ((buf[3] & 0xff) << 24));
                ret.setMode((buf[4] & 0xff));
                ret.setSetting((buf[5] & 0xff) + ((buf[6] & 0xff) << 8));
                ret.setSkipSecSum((buf[7] & 0xff) + ((buf[8] & 0xff) << 8));
                ret.setSkipCntSum((buf[9] & 0xff) + ((buf[10] & 0xff) << 8));
                ret.setFreqAvg((buf[11] & 0xff) + ((buf[12] & 0xff) << 8));
                ret.setFreqMax((buf[13] & 0xff) + ((buf[14] & 0xff) << 8));
                ret.setConsecutiveSkipMaxNum((buf[15] & 0xff) + ((buf[16] & 0xff) << 8));
                int skip_miss_cnt = (buf[17] & 0xff);
                ret.setSkipGroupNum(skip_miss_cnt + 1);
                ret.setSkipValidSec((buf[18] & 0xff) + ((buf[19] & 0xff) << 8));
                int pkt_idx = (buf[20] & 0xff);

                //load signature
                int signatureLen = 64;
                byte[] signature = new byte[signatureLen];
                for (int i = 0; i < signatureLen; i++) {
                    signature[i] = buf[20 + i];
                }
                ret.setSignature(signature);

                if (SkipProtocolDef.CMD_REALTIME_RESULT_DATA == retPackage.getCmd()) {
                    receiveDataCallback.onReceiveSkipRealTimeResultData(ret, pkt_idx);
                } else if (SkipProtocolDef.CMD_HISTORY_RESULT_DATA == retPackage.getCmd()) {
                    receiveDataCallback.onReceiveSkipHistoryResultData(ret, pkt_idx);
                }
            }
            break;

            case SkipProtocolDef.CMD_SET_DEV_ADV_NAME: {
                Log.i(TAG, "CMD_SET_DEV_ADV_NAME: " + retPackage.getCmd() + " " + HexUtil.encodeHexStr(retPackage.getPayload()));
            }
            break;


            //NFT
            case SkipProtocolDef.CMD_GEN_ECC_KEY: {
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());

                //load public key
                int keyLen = 33;
                byte[] key = new byte[keyLen];
                for (int i = 0; i < keyLen; i++) {
                    key[i] = buf[i];
                }
                Log.i(TAG, "CMD_GEN_ECC_KEY: " + retPackage.getCmd() + " " + HexUtil.encodeHexStr(key));
                //  String hex=HexUtil.HexUtil.encodeHexStr(retPackage.getPayload());
                receiveDataCallback.onReceivewriteSkipGenerateECCKey(retPackage.getCmd() + "", HexUtil.encodeHexStr(key));
            }
            break;


            case SkipProtocolDef.CMD_GET_DEV_PUB_KEY: {

                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());

                //load public key
                int keyLen = 33;
                byte[] key = new byte[keyLen];
                for (int i = 0; i < keyLen; i++) {
                    key[i] = buf[i];
                }
                Log.i(TAG, "CMD_GET_DEV_PUB_KEY: " + retPackage.getCmd() + " " + HexUtil.encodeHexStr(key));
                receiveDataCallback.onReceivewriteSkipGetPublicKey(retPackage.getCmd() + "", HexUtil.encodeHexStr(key));

            }
            break;


            case SkipProtocolDef.CMD_BOND_DEV: {
                Log.i(TAG, "CMD_BOND_DEV: " + retPackage.getCmd() + " " + HexUtil.encodeHexStr(retPackage.getPayload()));
                receiveDataCallback.onReceivewriteSkipBondDev(HexUtil.encodeHexStr(retPackage.getPayload()));
            }
            break;

        }
    }

}
