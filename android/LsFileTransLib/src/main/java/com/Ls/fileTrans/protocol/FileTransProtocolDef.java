package com.Ls.fileTrans.protocol;

public class FileTransProtocolDef {
    //指令
    public static final int CMD_TEXT_INFO = 0x01;
    public static final int CMD_OTA_INFO = 0x02;
    public static final int CMD_IMAGE_INFO = 0x03;
    public static final int CMD_TRANS_DONE = 0x10;
    public static final int CMD_TRANS_RSP_SW = 0x11;

    public static final int CMD_TRANS_RX_LEN = 0x80;
}
