package com.example.toearnfun_flutter_app.comm;

import com.example.toearnfun_flutter_app.data.BleDevice;

public interface Observable {

    void addObserver(Observer obj);

    void deleteObserver(Observer obj);

    void notifyObserver(BleDevice bleDevice);
}
