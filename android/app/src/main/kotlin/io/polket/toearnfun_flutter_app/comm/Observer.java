package io.polket.toearnfun_flutter_app.comm;


import io.polket.toearnfun_flutter_app.data.BleDevice;

public interface Observer {

    void disConnected(BleDevice bleDevice);
}
