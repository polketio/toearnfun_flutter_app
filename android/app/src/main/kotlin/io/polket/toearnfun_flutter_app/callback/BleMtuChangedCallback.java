package io.polket.toearnfun_flutter_app.callback;


import io.polket.toearnfun_flutter_app.exception.BleException;

public abstract class BleMtuChangedCallback extends BleBaseCallback {

    public abstract void onSetMTUFailure(BleException exception);

    public abstract void onMtuChanged(int mtu);

}
