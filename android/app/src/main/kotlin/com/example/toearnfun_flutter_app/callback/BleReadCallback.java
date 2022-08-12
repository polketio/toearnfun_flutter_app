package com.example.toearnfun_flutter_app.callback;


import com.example.toearnfun_flutter_app.exception.BleException;

public abstract class BleReadCallback extends BleBaseCallback {

    public abstract void onReadSuccess(byte[] data);

    public abstract void onReadFailure(BleException exception);

}
