package com.Ls.fileTrans;

import com.Ls.fileTrans.protocol.RxPackage;

public class FileTransReceivePack {

    public void onListenBleFileNotification(byte[] data, final ReceiveFileDataCallback receiveFileDataCallback) {
        RxPackage rxPackage = new RxPackage();
        rxPackage.onListenBleFileNotification(data, receiveFileDataCallback);
    }

}
