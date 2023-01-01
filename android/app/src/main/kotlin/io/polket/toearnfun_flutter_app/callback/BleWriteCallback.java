package io.polket.toearnfun_flutter_app.callback;


import io.polket.toearnfun_flutter_app.exception.BleException;

public abstract class BleWriteCallback extends BleBaseCallback{

    public abstract void onWriteSuccess(int current, int total, byte[] justWrite);

    public abstract void onWriteFailure(BleException exception);
}
