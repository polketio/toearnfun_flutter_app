package com.Ls.fileTrans;

public abstract class ReceiveFileDataCallback {

    public ReceiveFileDataCallback() {}

    public void onReceiveHeadInfoRspData(int error_code){}

    public void onReceiveFileRspSw(int error_code){}

    public void onReceiveFileRxDataLen(int rx_len){}
}
