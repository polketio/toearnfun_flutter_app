package io.polket.toearnfun_flutter_app.callback;

import io.polket.toearnfun_flutter_app.data.BleDevice;

public interface BleScanPresenterImp {

    void onScanStarted(boolean success);

    void onScanning(BleDevice bleDevice);

}
