package com.Ls.skipBle;

public abstract class ReceiveDataCallback {

    public ReceiveDataCallback() {}

    public void onReceiveDisplayData(SkipDisplayData display){}

    public void onReceiveSkipRealTimeResultData(SkipResultData result, int pkt_idx){}

    public void onReceiveSkipHistoryResultData(SkipResultData result, int pkt_idx){}

    public void onReceiveEnteredOtaMode(String mac) {}

    public void onReceiveEnteredFactoryMode() {}

    public void onReceiveRevertDevice() {}

    public void onReceivewriteSkipGenerateECCKey(String cmd,String data ) {}
    public void onReceivewriteSkipGetPublicKey(String cmd,String data) {}
}
