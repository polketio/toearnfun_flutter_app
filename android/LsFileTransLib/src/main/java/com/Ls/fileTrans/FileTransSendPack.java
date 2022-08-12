package com.Ls.fileTrans;

import android.content.Context;
import android.util.Log;

import com.Ls.fileTrans.protocol.HexUtil;
import com.Ls.fileTrans.protocol.TxPackage;

public class FileTransSendPack {

    private static SendFileDataCallback sendPack;

    public void setSendPackHandle(SendFileDataCallback handle) {
        sendPack = handle;
    }

    public void setTextInfo(Context ctx, int res_id, final String text, int text_len) {
        sendPack.txCtrlPoint(TxPackage.setTextInfo(ctx, res_id, text, text_len));
    }

    public void setTransRspEnable() {
        sendPack.txCtrlPoint(TxPackage.setFileTransRspEnable());
    }

    public void setTextTransDone() {
        sendPack.txCtrlPoint(TxPackage.setTextTransDone());
        sendPack.txDone();;
    }

    public void setDfuTransDone() {
        sendPack.txCtrlPoint(TxPackage.setDfuTransDone());
        sendPack.txDone();
    }

    public void setImageTransDone() {
        sendPack.txCtrlPoint(TxPackage.setImageTransDone());
        sendPack.txDone();
    }

    public void setDfuInfo(int ota_type, int file_size, int device_type, int project_num, int version, int firmware_crc16, int prnn) {
        //Log.i("FileTrans1", "-------------" + HexUtil.encodeHexStr(TxPackage.setDfuInfo(ota_type, file_size, device_type, project_num, version, firmware_crc16, prnn)));
        sendPack.txCtrlPoint(TxPackage.setDfuInfo(ota_type, file_size, device_type, project_num, version, firmware_crc16, prnn));
    }

    public void setImageInfo(int file_size, int device_type, int project_num, int file_crc16, int major_ver, int minor_ver) {
        sendPack.txCtrlPoint(TxPackage.setImageInfo(file_size, device_type, project_num, file_crc16, major_ver, minor_ver));
    }

    public void sendFileData(byte[] payload) {
        sendPack.txFileData(payload);
    }
}
