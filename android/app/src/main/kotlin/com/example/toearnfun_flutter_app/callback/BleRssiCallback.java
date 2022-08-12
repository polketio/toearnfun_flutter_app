package com.example.toearnfun_flutter_app.callback;


import com.example.toearnfun_flutter_app.exception.BleException;

public abstract class BleRssiCallback extends BleBaseCallback{

    public abstract void onRssiFailure(BleException exception);

    public abstract void onRssiSuccess(int rssi);

}