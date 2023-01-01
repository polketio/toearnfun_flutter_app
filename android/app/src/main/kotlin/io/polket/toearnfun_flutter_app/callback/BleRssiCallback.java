package io.polket.toearnfun_flutter_app.callback;


import io.polket.toearnfun_flutter_app.exception.BleException;

public abstract class BleRssiCallback extends BleBaseCallback{

    public abstract void onRssiFailure(BleException exception);

    public abstract void onRssiSuccess(int rssi);

}