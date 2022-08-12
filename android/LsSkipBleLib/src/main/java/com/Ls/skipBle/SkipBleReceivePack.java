package com.Ls.skipBle;

import com.Ls.skipBle.protocol.RxPackage;

public class SkipBleReceivePack {

    public void onListenBleIndication(byte[] data, final ReceiveDataCallback receiveDataCallback) {
        RxPackage rxPackage = new RxPackage();
        rxPackage.onListenBleIndication(data, receiveDataCallback);
    }

}
