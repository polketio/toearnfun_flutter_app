package com.example.toearnfun_flutter_app.comm;


import com.example.toearnfun_flutter_app.data.BleDevice;

public interface Observer {

    void disConnected(BleDevice bleDevice);
}
