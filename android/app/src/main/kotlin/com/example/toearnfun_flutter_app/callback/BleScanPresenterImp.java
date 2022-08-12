package com.example.toearnfun_flutter_app.callback;

import com.example.toearnfun_flutter_app.data.BleDevice;

public interface BleScanPresenterImp {

    void onScanStarted(boolean success);

    void onScanning(BleDevice bleDevice);

}
