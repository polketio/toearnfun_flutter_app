package com.Ls.fileTrans.protocol;

public class PackageUtils {
    private static final String TAG = PackageUtils.class.getSimpleName();

    public static int calculateCrc(int init_val, byte[] data, int start_pos, int size) {
        int crc = init_val;
        for ( int i = start_pos; i < (start_pos + size); i++ ) {
            crc += ( data[i] & 0xff );
        }
        return (crc & 0xffff);
    }

}
