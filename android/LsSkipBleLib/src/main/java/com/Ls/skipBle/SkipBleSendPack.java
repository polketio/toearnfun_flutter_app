package com.Ls.skipBle;

import com.Ls.skipBle.protocol.TxPackage;

public class SkipBleSendPack {
    public byte[] syncDeviceTime(final int utc) {
        return TxPackage.syncDeviceTime(utc);
    }

    public byte[] setSkipMode(final int utc,
                              final int mode,
                              final int setParam,
                              final int start_secs) {
        return TxPackage.setSkipMode(utc, mode, setParam, start_secs);
    }

    public byte[] stopSkip() {
        return TxPackage.stopSkip();
    }

    public byte[] writeSkipRealTimeResultRsp(int pkt_idx) {
        return TxPackage.writeSkipRealTimeResultRsp(pkt_idx);
    }

    public byte[] writeSkipHistoryResultRsp(int pkt_idx) {
        return TxPackage.writeSkipHistoryResultRsp(pkt_idx);
    }

    public byte[] writeSkipDevReset() {
        return TxPackage.writeSkipDevReset();
    }

    public byte[] writeSkipDevRevert() {
        return TxPackage.writeSkipDevRevert();
    }

    public byte[] writeSkipSetDevAdvName(byte[] name, int name_len) {
        return TxPackage.writeSkipSetDevAdvName(name, name_len);
    }

    public byte[] writeSkipGenerateECCKey() {
        return TxPackage.writeSkipGenerateECCKey();
    }

    public byte[] writeSkipGetPublicKey() {
        return TxPackage.writeSkipGetPublicKey();
    }

    public byte[] writeSkipBondDev(int nonce, byte[] address) {
        return TxPackage.writeSkipBondDev(nonce, address);
    }
}
