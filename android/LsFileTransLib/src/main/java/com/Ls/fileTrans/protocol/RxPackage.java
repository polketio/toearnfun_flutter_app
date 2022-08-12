package com.Ls.fileTrans.protocol;

import android.util.Log;

import com.Ls.fileTrans.ReceiveFileDataCallback;

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
     * @param data
     * @return
     */
    public void onListenBleFileNotification(byte[] data, final ReceiveFileDataCallback receiveFileDataCallback) {
        BlePackage retPackage = onRxPackageConsist(data);
        onRxPackageParse(retPackage, receiveFileDataCallback);
    }


    private BlePackage onRxPackageConsist(byte[] data) {
        BlePackage retPackage = new BlePackage();
        Log.i(TAG, ByteToInt(data[0]) + "  " + ByteToInt(data[1]));
        if ( ( ByteToInt(data[0]) == BlePackageParamDef.PACKAGE_HEADER) && (ByteToInt(data[1]) == BlePackageParamDef.PROTOCOL_ID) ) {
            if (data.length < BlePackageParamDef.PKT_DATA_START_POS) {
                blePackage.resetPackage();
                Log.i(TAG, "Rx err len");
                return retPackage;
            }
            blePackage.resetPackage();
            parseBlePktHead(data);
            for ( int i = 0; i < data.length - BlePackageParamDef.PKT_DATA_START_POS; i++ ) {
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
            if( blePackage.getRx_idx() != ( (frame_seq - 1)*BlePackageParamDef.REST_FRAME_PAYLOAD_MAX_LEN + BlePackageParamDef.FIRST_FRAME_PAYLOAD_MAX_LEN ) ) {
                //Log.i(TAG, "++++22 " + blePackage.getRx_idx() + " " + ( (frame_seq - 1)*blePackage.REST_FRAME_PAYLOAD_MAX_LEN + blePackage.FIRST_FRAME_PAYLOAD_MAX_LEN ));
                blePackage.resetPackage();
                return retPackage;
            }
            blePackage.setFrame_seq(frame_seq);
            for ( int i = 1; i < data.length; i++ ) {
                if ( (i + blePackage.getRx_idx() - 1) < blePackage.getPayloadLen() ) {
                    blePackage.setPayloadEle(i + blePackage.getRx_idx() - 1, data[i]);
                }
            }
            blePackage.setRx_idx(blePackage.getRx_idx() + data.length - 1);
            //Log.i(TAG, "++++2" + HexUtil.encodeHexStr(blePackage.getPayload()));
        }

        //Log.i(TAG, "head: "+blePackage.getPacket_head()+"id: "+blePackage.getProto_id()+"id: "+blePackage.getRx_idx()+"payloadLen: "+blePackage.getPayloadLen());
        if ( (BlePackageParamDef.PACKAGE_HEADER == blePackage.getPacket_head()) && (BlePackageParamDef.PROTOCOL_ID == blePackage.getProto_id()) ) {
            if ( blePackage.getRx_idx() >= blePackage.getPayloadLen()) {
                int rx_crc = blePackage.getCrc();
                int crc_init_val = blePackage.getCmd() + blePackage.getPayloadLen();
                int cal_crc = PackageUtils.calculateCrc(crc_init_val ,blePackage.getPayload(), 0, blePackage.getPayloadLen());
                if ( rx_crc == cal_crc ) {
                    Log.i(TAG, "RxCmd: " + blePackage.getCmd());
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

        //Log.i(TAG, "++++++++++++++" + HexUtil.encodeHexStr(data));
        //Log.i(TAG, "++++++++++++++---" + retPackage.getCmd() + " " + HexUtil.encodeHexStr(retPackage.getPayload()));
        return retPackage;
    }

    private void onRxPackageParse(BlePackage retPackage, final ReceiveFileDataCallback receiveFileDataCallback) {
        /*if(retPackage.getCmd() != 0) {
            Log.i(TAG, "getCmd: " + retPackage.getCmd());
        }*/

        switch (retPackage.getCmd()) {
            case FileTransProtocolDef.CMD_TEXT_INFO: {
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());
                int error_code = (buf[0] & 0xff);
                Log.i(TAG, "CMD_TEXT_INFO rsp >> " + error_code);
                receiveFileDataCallback.onReceiveHeadInfoRspData(error_code);
            } break;

            case FileTransProtocolDef.CMD_OTA_INFO: {
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());
                int error_code = (buf[0] & 0xff);
                Log.i(TAG, "CMD_OTA_INFO rsp >> " + error_code);
                receiveFileDataCallback.onReceiveHeadInfoRspData(error_code);
            } break;

            case FileTransProtocolDef.CMD_IMAGE_INFO: {
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());
                int error_code = (buf[0] & 0xff);
                Log.i(TAG, "CMD_IMAGE_INFO rsp >> " + error_code);
                receiveFileDataCallback.onReceiveHeadInfoRspData(error_code);
            } break;

            case FileTransProtocolDef.CMD_TRANS_DONE: {
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());
                int error_code = (buf[0] & 0xff);
                Log.i(TAG, "CMD_TRANS_DONE rsp >> " + error_code);
            } break;

            case FileTransProtocolDef.CMD_TRANS_RSP_SW: {
                Log.i(TAG, "CMD_TRANS_RSP_SW rsp >> ");
                receiveFileDataCallback.onReceiveFileRspSw(0);
            } break;

            case FileTransProtocolDef.CMD_TRANS_RX_LEN: {
                byte[] buf = new byte[retPackage.getPayloadLen()];
                System.arraycopy(retPackage.getPayload(), 0, buf, 0, retPackage.getPayloadLen());
                int rx_len = ( buf[0] & 0xff ) + ( ( buf[1] & 0xff ) << 8 ) + ( ( buf[2] & 0xff ) << 16 ) + ( ( buf[3] & 0xff ) << 24 );
                Log.i(TAG, "CMD_TRANS_RX_LEN rsp >> " + rx_len);
                receiveFileDataCallback.onReceiveFileRxDataLen(rx_len);
            } break;

            default:
                break;
        }

    }

}
