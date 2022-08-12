package com.Ls.skipBle.protocol;

public class SkipProtocolDef {
    //发送指令
    public static final int CMD_SYNC_DEV_TIME = 0x80;
    public static final int CMD_SET_JUMP_MODE = 0x81;
    public static final int CMD_STOP_JUMP = 0x82;
    public static final int CMD_FIND_DEV = 0x83;

    public static final int CMD_GEN_ECC_KEY = 0x84;
    public static final int CMD_GET_DEV_PUB_KEY = 0x85;
    public static final int CMD_BOND_DEV = 0x86;

    public static final int CMD_RESET_DEV = 0xF7;
    public static final int CMD_REVERT_DEV = 0xF8;
    public static final int CMD_SET_DEV_ADV_NAME = 0xF9;
    public static final int CMD_DEV_FAC_TEST = 0xFD;
    public static final int CMD_BURN_DEV_SEQ = 0xFE;

    //接收指令
    public static final int CMD_DISPLAY_DATA = 0x01;
    public static final int CMD_REALTIME_RESULT_DATA = 0x02;
    public static final int CMD_HISTORY_RESULT_DATA = 0x03;
}
