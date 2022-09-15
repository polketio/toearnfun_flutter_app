package com.Ls.skipBle;

public abstract class ReceiveDataCallback {

    public ReceiveDataCallback() {}

    public void onReceiveDisplayData(SkipDisplayData display){}

    //02 跳绳结果上传
    public void onReceiveSkipRealTimeResultData(SkipResultData result, int pkt_idx){}
    //03 跳绳历史数据上传
    public void onReceiveSkipHistoryResultData(SkipResultData result, int pkt_idx){}

    public void onReceiveEnteredOtaMode(String mac) {}

    public void onReceiveEnteredFactoryMode() {}

    public void onReceiveRevertDevice() {}

    public void onReceivewriteSkipGenerateECCKey(String cmd,String data ) {}
    public void onReceivewriteSkipGetPublicKey(String cmd,String data) {}
}
