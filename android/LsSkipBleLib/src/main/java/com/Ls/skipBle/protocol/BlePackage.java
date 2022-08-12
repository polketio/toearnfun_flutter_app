package com.Ls.skipBle.protocol;

class BlePackageParamDef {
    public static final int DATA_PAYLOAD_LEN = 113;
    public static final int PKT_DATA_START_POS = 7;
    public static final int BLE_FRAME_MAX_LEN = (DATA_PAYLOAD_LEN - PKT_DATA_START_POS);
    public static final int FIRST_FRAME_PAYLOAD_MAX_LEN = DATA_PAYLOAD_LEN;
    public static final int REST_FRAME_PAYLOAD_MAX_LEN = (DATA_PAYLOAD_LEN + 1);

    public static final int PACKAGE_HEADER = 0xFC;
    public static final int PROTOCOL_ID = 0xA0;
}

public class BlePackage {
    private int head;
    private int proto_id;
    private int crc;
    private int cmd;
    private int payload_len;
    private byte[] payload;
    private int rx_idx;
    private int frame_seq;



    public BlePackage() {
        head = 0;
        proto_id = 0;
        crc = 0;
        cmd = 0;
        payload_len = 0;
        payload = new byte[BlePackageParamDef.FIRST_FRAME_PAYLOAD_MAX_LEN];
        rx_idx = 0;
        frame_seq = 0;
    }

    public int getPacket_head() {
        return head;
    }

    public void setPacket_head(int head) { this.head = head; }

    public int getProto_id() {
        return proto_id;
    }

    public void setProto_id(int proto_id) { this.proto_id = proto_id; }

    public int getCmd() {
        return cmd;
    }

    public void setCmd(int cmd) {
        this.cmd = cmd;
    }

    public int getCrc() {
        return crc;
    }

    public void setCrc(int crc) {
        this.crc = crc;
    }

    public int getPayloadLen() {
        return payload_len;
    }

    public void setPayloadLen(int len) { this.payload_len = len; }

    public byte[] getPayload() { return payload; }

    public void setPayload(byte[] buf) { System.arraycopy(buf, 0, this.payload, 0, payload.length); }

    public void setPayloadEle(int index, byte value) {
        payload[index] = value;
    }

    public int getRx_idx() {
        return rx_idx;
    }

    public void setRx_idx(int rx_idx) {
        this.rx_idx = rx_idx;
    }

    public int getFrame_seq() {
        return frame_seq;
    }

    public void setFrame_seq(int frame_seq) {
        this.frame_seq = frame_seq;
    }

    public void resetPackage() {
        head = 0;
        proto_id = 0;
        crc = 0;
        cmd = 0;
        payload_len = 0;
        for (int i = 0; i < payload.length; i++) {
            payload[i] = 0;
        }
        rx_idx = 0;
        frame_seq = 0;
    }

}
