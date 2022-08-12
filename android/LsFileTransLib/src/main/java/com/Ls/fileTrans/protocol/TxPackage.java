package com.Ls.fileTrans.protocol;

import android.content.Context;
import android.util.Log;

import com.Ls.fileTrans.FileTransParamDef;

import java.io.IOException;
import java.io.InputStream;

public class TxPackage {
    private static final String TAG = TxPackage.class.getSimpleName();

    private static BlePackage blePackage = new BlePackage();

    private static final int one_char_bytes = 32;
    private static int bitMapByteNum = 0;
    private static byte[] bitMapBuf = new byte[30*one_char_bytes];

    /**
     * 发送包打包
     * @param cmd
     * @param len
     * @return
     */
    private static byte[] blePktReady(byte[] data, int cmd, int len) {
        byte[] result = new byte[len + BlePackageParamDef.PKT_DATA_START_POS];

        result[0] = (byte) BlePackageParamDef.PACKAGE_HEADER;
        result[1] = (byte) BlePackageParamDef.PROTOCOL_ID;

        int init_val = cmd + len;
        //Log.i(TAG, "init_val: "+init_val);
        int crc = PackageUtils.calculateCrc(init_val, data, BlePackageParamDef.PKT_DATA_START_POS, len);
        //Log.i(TAG, "crc: "+crc);
        result[2] = (byte) crc;
        result[3] = (byte) ((crc >> 8) & 0xff);
        result[4] = (byte) cmd;
        result[5] = (byte) len;
        result[6] = (byte) ((len >> 8) & 0xff);

        System.arraycopy(data, BlePackageParamDef.PKT_DATA_START_POS, result, BlePackageParamDef.PKT_DATA_START_POS, len);

        return result;
    }

    public static byte[] setTextInfo(Context ctx, int res_id, final String text, int text_len) {
        byte[] data = new byte[BlePackageParamDef.BLE_PKT_MAX_LEN];

        final int file_len = text_len*one_char_bytes;
        int file_crc = 0;
        final int scene_type = 0;
        final int text_width = 16;
        final int text_height = 16;
        final int char_num = text_len;

        int offset = 11;
        int unicode = 0;

        Log.i(TAG, "text.length: " + text.length());

        for (int i = 0; i < text_len; i++)
        {
            unicode = text.charAt(i) & 0xffff;
            Log.i(TAG, "Unicode: " + Integer.toHexString(unicode));
            data[BlePackageParamDef.PKT_DATA_START_POS + offset] = (byte) ( unicode & 0xff );
            offset++;
            data[BlePackageParamDef.PKT_DATA_START_POS + offset] = (byte) ( (unicode >> 8) & 0xff );
            offset++;

            readCharBitMapToBuf(ctx, res_id, bitMapBuf, i*one_char_bytes, unicode);
            for(int j=0;j<one_char_bytes;j++) {
                file_crc += bitMapBuf[i*one_char_bytes+j] & 0xFF;
            }
        }
        bitMapByteNum = text_len*one_char_bytes;

        Log.i(TAG, "file_crc: " + Integer.toHexString(file_crc&0xFFFF));
        data[BlePackageParamDef.PKT_DATA_START_POS] = (byte) ( file_len & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+1] = (byte) ( (file_len >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+2] = (byte) ( (file_len >> 16) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+3] = (byte) ( (file_len >> 24) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+4] = (byte) ( file_crc & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+5] = (byte) ( (file_crc >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+6] = (byte) ( scene_type & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+7] = (byte) ( text_width & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+8] = (byte) ( text_height & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+9] = (byte) ( char_num & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+10] = (byte) ( (char_num >> 8) & 0xff );

        /*String test_str = "";
        for(int i=0;i<bitMapByteNum;i++) {
            test_str += Integer.toHexString(bitMapBuf[i]&0xFF);
            test_str += ", ";
        }
        Log.i(TAG, "Buf string: " + test_str);*/


        /*byte[] txData = blePktReady(data, FontTransProtocolDef.CMD_TEXT_INFO, offset);
        Log.i(TAG, "offset: " + offset);
        for (int i = 0; i < (offset + BlePackageParamDef.PKT_DATA_START_POS); i++)
        {
            Log.i(TAG, "data" + "[" + i + "]: " + Integer.toHexString(txData[i]&0xFF));
        }*/

        return blePktReady(data, FileTransProtocolDef.CMD_TEXT_INFO, offset);
    }

    public static void readCharBitMapToBuf(Context ctx, int res_id, byte[] buf, int idx, int unicode)
    {
        try {
            InputStream inputStream = ctx.getResources().openRawResource(res_id);
            int skip_bytes = unicode * one_char_bytes;
            inputStream.skip(skip_bytes);
            inputStream.read(buf, idx, one_char_bytes);
            inputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
            Log.i(TAG, "bin catch err: " + e);
        }
    }

    /*public static String StringToUnicode(String s)
    {
        String as[] = new String[s.length()];
        String s1 = "";
        for (int i = 0; i < s.length(); i++)
        {
            as[i] = Integer.toHexString(s.charAt(i) & 0xffff);
            s1 = s1 + "\\u" + as[i];
        }
        return s1;
    }*/

    public static byte[] setFileTransRspEnable()
    {
        byte[] data = new byte[BlePackageParamDef.BLE_PKT_MAX_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = 1;

        return blePktReady(data, FileTransProtocolDef.CMD_TRANS_RSP_SW, 1);
    }

    public static byte[] setTextTransDone()
    {
        byte[] data = new byte[BlePackageParamDef.BLE_PKT_MAX_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = FileTransParamDef.FILE_TYPE_TXT;

        return blePktReady(data, FileTransProtocolDef.CMD_TRANS_DONE, 1);
    }

    public static byte[] setTextTransFile()
    {
        byte[] buf = new byte[bitMapByteNum];
        Log.i(TAG, "buf.length: " + bitMapByteNum);
        System.arraycopy(bitMapBuf, 0, buf, 0, buf.length);

        String test_str = "";
        for(int i=0;i<bitMapByteNum;i++) {
            test_str += Integer.toHexString(bitMapBuf[i]&0xFF);
            test_str += ", ";
        }
        Log.i(TAG, "Buf string: " + test_str);

        return buf;
    }


    public static byte[] setDfuInfo(int file_type, int file_size, int device_type, int project_num, int version, int firmware_crc16, int prnn) {
        byte[] data = new byte[BlePackageParamDef.BLE_PKT_MAX_LEN];

        data[BlePackageParamDef.PKT_DATA_START_POS] = (byte) ( file_type & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+1] = (byte) ( file_size & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+2] = (byte) ( (file_size >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+3] = (byte) ( (file_size >> 16) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+4] = (byte) ( (file_size >> 24) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+5] = (byte) ( device_type & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+6] = (byte) ( (device_type >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+7] = (byte) ( project_num & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+8] = (byte) ( (project_num >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+9] = (byte) ( version & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+10] = (byte) ( (version >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+11] = (byte) ( firmware_crc16 & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+12] = (byte) ( (firmware_crc16 >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+13] = (byte) ( prnn & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+14] = (byte) ( (prnn >> 8) & 0xff );

        return blePktReady(data, FileTransProtocolDef.CMD_OTA_INFO, 15);
    }

    public static byte[] setDfuTransDone()
    {
        byte[] data = new byte[BlePackageParamDef.BLE_PKT_MAX_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = FileTransParamDef.FILE_TYPE_OTA;

        return blePktReady(data, FileTransProtocolDef.CMD_TRANS_DONE, 1);
    }


    public static byte[] setImageInfo(int file_size, int device_type, int project_num, int file_crc16, int major_ver, int minor_ver) {
        byte[] data = new byte[BlePackageParamDef.BLE_PKT_MAX_LEN];

        data[BlePackageParamDef.PKT_DATA_START_POS] = (byte) ( file_size & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+1] = (byte) ( (file_size >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+2] = (byte) ( (file_size >> 16) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+3] = (byte) ( (file_size >> 24) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+4] = (byte) ( device_type & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+5] = (byte) ( (device_type >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+6] = (byte) ( project_num & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+7] = (byte) ( (project_num >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+8] = (byte) ( file_crc16 & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+9] = (byte) ( (file_crc16 >> 8) & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+10] = (byte) ( major_ver & 0xff );
        data[BlePackageParamDef.PKT_DATA_START_POS+11] = (byte) ( minor_ver & 0xff );

        return blePktReady(data, FileTransProtocolDef.CMD_IMAGE_INFO, 12);
    }

    public static byte[] setImageTransDone()
    {
        byte[] data = new byte[BlePackageParamDef.BLE_PKT_MAX_LEN];
        data[BlePackageParamDef.PKT_DATA_START_POS] = FileTransParamDef.FILE_TYPE_IMAGE;

        return blePktReady(data, FileTransProtocolDef.CMD_TRANS_DONE, 1);
    }
}
