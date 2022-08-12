package com.Ls.fileTrans;

import android.annotation.SuppressLint;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.util.Log;

import com.Ls.fileTrans.parse.FileTransImgParse;
import com.Ls.fileTrans.protocol.TxPackage;
import com.Ls.fileTrans.parse.FileTransDfuParse;

import java.io.IOException;



public class FileTransManager {
    private static final String TAG = "FileTransManager";

    private static String transFilePath;

    public static final int TRANS_STEP_NULL = 0;
    public static final int TRANS_STEP_RSP_EN = 1;
    public static final int TRANS_STEP_IN_PROGRESS = 2;
    public static final int TRANS_STEP_DONE = 3;

    private static boolean file_trans_rsp_en = false;
    private static int file_trans_rx_len = 0;

    private static int file_trans_type = FileTransParamDef.FILE_TYPE_NULL;
    private final int ONE_PKT_MAX_SIZE = 243;
    private static int dfu_bin_size = 0;
    private static int left_file_size = 0;
    private static int step = TRANS_STEP_NULL;
    private static byte[] file_buf;
    private static final int post_delay_ms = 80;
    Handler fileTxDelayHandle = new Handler();


    /*private static int[] crc16_tab_h = {
            0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,
            0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,
            0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,
            0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,
            0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,
            0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,
            0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x01,0xC0,
            0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40,0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,
            0x00,0xC1,0x81,0x40,0x01,0xC0,0x80,0x41,0x01,0xC0,0x80,0x41,0x00,0xC1,0x81,0x40
    };

    private static int[] crc16_tab_l = {
            0x00,0xC0,0xC1,0x01,0xC3,0x03,0x02,0xC2,0xC6,0x06,0x07,0xC7,0x05,0xC5,0xC4,0x04,0xCC,0x0C,0x0D,0xCD,0x0F,0xCF,0xCE,0x0E,0x0A,0xCA,0xCB,0x0B,0xC9,0x09,
            0x08,0xC8,0xD8,0x18,0x19,0xD9,0x1B,0xDB,0xDA,0x1A,0x1E,0xDE,0xDF,0x1F,0xDD,0x1D,0x1C,0xDC,0x14,0xD4,0xD5,0x15,0xD7,0x17,0x16,0xD6,0xD2,0x12,0x13,0xD3,
            0x11,0xD1,0xD0,0x10,0xF0,0x30,0x31,0xF1,0x33,0xF3,0xF2,0x32,0x36,0xF6,0xF7,0x37,0xF5,0x35,0x34,0xF4,0x3C,0xFC,0xFD,0x3D,0xFF,0x3F,0x3E,0xFE,0xFA,0x3A,
            0x3B,0xFB,0x39,0xF9,0xF8,0x38,0x28,0xE8,0xE9,0x29,0xEB,0x2B,0x2A,0xEA,0xEE,0x2E,0x2F,0xEF,0x2D,0xED,0xEC,0x2C,0xE4,0x24,0x25,0xE5,0x27,0xE7,0xE6,0x26,
            0x22,0xE2,0xE3,0x23,0xE1,0x21,0x20,0xE0,0xA0,0x60,0x61,0xA1,0x63,0xA3,0xA2,0x62,0x66,0xA6,0xA7,0x67,0xA5,0x65,0x64,0xA4,0x6C,0xAC,0xAD,0x6D,0xAF,0x6F,
            0x6E,0xAE,0xAA,0x6A,0x6B,0xAB,0x69,0xA9,0xA8,0x68,0x78,0xB8,0xB9,0x79,0xBB,0x7B,0x7A,0xBA,0xBE,0x7E,0x7F,0xBF,0x7D,0xBD,0xBC,0x7C,0xB4,0x74,0x75,0xB5,
            0x77,0xB7,0xB6,0x76,0x72,0xB2,0xB3,0x73,0xB1,0x71,0x70,0xB0,0x50,0x90,0x91,0x51,0x93,0x53,0x52,0x92,0x96,0x56,0x57,0x97,0x55,0x95,0x94,0x54,0x9C,0x5C,
            0x5D,0x9D,0x5F,0x9F,0x9E,0x5E,0x5A,0x9A,0x9B,0x5B,0x99,0x59,0x58,0x98,0x88,0x48,0x49,0x89,0x4B,0x8B,0x8A,0x4A,0x4E,0x8E,0x8F,0x4F,0x8D,0x4D,0x4C,0x8C,
            0x44,0x84,0x85,0x45,0x87,0x47,0x46,0x86,0x82,0x42,0x43,0x83,0x41,0x81,0x80,0x40
    };

    int ota_crc16_calc(byte data[], int len, int preval)
    {
        int ucCRCHi = (preval & 0xff00) >> 8;
        int ucCRCLo = preval & 0x00ff;
        int idx;

        for(int i = 0; i < len; ++i) {
            idx = (ucCRCLo ^ data[i]) & 0x00ff;
            ucCRCLo = ucCRCHi ^ (crc16_tab_h[idx])&0xFF;
            ucCRCHi = (crc16_tab_l[idx]&0xFF);
        }

        return (((ucCRCHi & 0x00ff) << 8) | (ucCRCLo & 0x00ff)) & 0xffff;
    }*/


    public static boolean getFileTransRspSwState() { return file_trans_rsp_en; }
    public static int getFileTransType(){
        return file_trans_type;
    }

    public void startTextTransProgress(Context ctx, int res_id, final String text, int text_len)
    {
        file_trans_rsp_en = false;
        file_trans_type = FileTransParamDef.FILE_TYPE_TXT;
        FileTransSendPack tx = new FileTransSendPack();
        tx.setTextInfo(ctx, res_id, text, text_len);
        file_buf = TxPackage.setTextTransFile();
        left_file_size = file_buf.length;
    }

    public String getProgressPercentString() {
        int sent_size = dfu_bin_size - left_file_size;
        float percent = ((float)(sent_size*100) / dfu_bin_size);
        return String.format("%.1f", percent);
    }

    public void startDfuProgress(Context ctx, Uri uri, boolean trans_rsp_en) {
        if(trans_rsp_en) {
            file_trans_rsp_en = true;
        }
        else {
            file_trans_rsp_en = false;
        }

        String filePath = uri.getPath();
        if(filePath.startsWith("/document/raw:")) {
            filePath = filePath.replaceFirst("/document/raw:", "");
            transFilePath = filePath;
        }
        else {
            transFilePath = getRealPath(ctx, uri);
        }
        Log.i(TAG, "FilePath: " + transFilePath);
        try {
            file_trans_type = FileTransParamDef.FILE_TYPE_OTA;
            FileTransDfuParse.parseDfuZipFile(transFilePath);
            dfu_bin_size = FileTransDfuParse.getDfuBinSize();
            file_buf = new byte[dfu_bin_size];
            FileTransDfuParse.readDfuBinFile(transFilePath, file_buf, file_buf.length);
            Log.i(TAG, "file_buf len: " + file_buf.length);
            left_file_size = dfu_bin_size;
            step = TRANS_STEP_IN_PROGRESS;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public void startImageProgress(Context ctx, Uri uri) {
        file_trans_rsp_en = false;
        String filePath = uri.getPath();
        if(filePath.startsWith("/document/raw:")) {
            filePath = filePath.replaceFirst("/document/raw:", "");
            transFilePath = filePath;
        }
        else {
            transFilePath = getRealPath(ctx, uri);
        }
        Log.i(TAG, "FilePath: " + transFilePath);
        try {
            file_trans_type = FileTransParamDef.FILE_TYPE_IMAGE;
            FileTransImgParse.parseImgZipFile(transFilePath);
            dfu_bin_size = FileTransImgParse.getImgBinSize();
            file_buf = new byte[dfu_bin_size];
            FileTransImgParse.readImgBinFile(transFilePath, file_buf, file_buf.length);
            Log.i(TAG, "file_buf len: " + file_buf.length);
            left_file_size = dfu_bin_size;
            step = TRANS_STEP_IN_PROGRESS;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void sendTransFileContent() {
        int len = left_file_size;
        if (len > ONE_PKT_MAX_SIZE) {
            len = ONE_PKT_MAX_SIZE;
        }
        byte[] buf = new byte[len];

        if(FileTransParamDef.FILE_TYPE_TXT == file_trans_type) {
            Log.i(TAG, "continue trans: " + (file_buf.length - left_file_size));
            System.arraycopy(file_buf, file_buf.length - left_file_size, buf, 0, len);
        }
        else if(FileTransParamDef.FILE_TYPE_OTA == file_trans_type || FileTransParamDef.FILE_TYPE_IMAGE == file_trans_type) {
            try {
                Log.i(TAG, "left_file_size: " + left_file_size);
                System.arraycopy(file_buf, file_buf.length - left_file_size, buf, 0, len);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        FileTransSendPack tx = new FileTransSendPack();
        tx.sendFileData(buf);
        left_file_size -= len;
        if(left_file_size <= 0)
            step = TRANS_STEP_DONE;
        fileTxDelayHandle.postDelayed(runnableFile, post_delay_ms);
    }

    private void sendTransFileDone() throws IOException {
        Log.i(TAG, "sendTransFileDone");
        FileTransSendPack tx = new FileTransSendPack();
        if(FileTransParamDef.FILE_TYPE_TXT == file_trans_type) {
            tx.setTextTransDone();
        }
        else if(FileTransParamDef.FILE_TYPE_OTA == file_trans_type) {
            tx.setDfuTransDone();
        }
        else if(FileTransParamDef.FILE_TYPE_IMAGE == file_trans_type) {
            tx.setImageTransDone();
        }
    }


    Runnable runnableFile = new Runnable() {
        @Override
        public void run() {
            //延时发送防止失败
            if(file_trans_rsp_en) {
                if(step == TRANS_STEP_RSP_EN) {
                    FileTransSendPack tx = new FileTransSendPack();
                    tx.setTransRspEnable();
                }
                else if(step == TRANS_STEP_IN_PROGRESS) {
                    fileTransStepByStep(file_trans_rx_len);
                }
                else if(step == TRANS_STEP_DONE) {
                    try {
                        sendTransFileDone();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
            else {
                if(step == TRANS_STEP_IN_PROGRESS) {
                    sendTransFileContent();
                }
                else if(step == TRANS_STEP_DONE) {
                    try {
                        sendTransFileDone();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

        }
    };


    public static FileTransManager getInstance() {
        return FileTransManager.FileTransManagerHolder.sManager;
    }

    private static class FileTransManagerHolder {
        private static final FileTransManager sManager = new FileTransManager();
    }


    public void fileTransProgress() {
        step = TRANS_STEP_IN_PROGRESS;
        fileTxDelayHandle.postDelayed(runnableFile, post_delay_ms);
    }


    public void fileTransSetRspEn() {
        step = TRANS_STEP_RSP_EN;
        fileTxDelayHandle.postDelayed(runnableFile, post_delay_ms);
    }

    public void fileTransSetRxLen(int rx_len) {
        step = TRANS_STEP_IN_PROGRESS;
        file_trans_rx_len = rx_len;
        fileTxDelayHandle.postDelayed(runnableFile, post_delay_ms);
    }

    public void fileTransStepByStep(int offset) {
        Log.i(TAG, "offset: " + offset);
        step = TRANS_STEP_IN_PROGRESS;
        left_file_size = dfu_bin_size - offset;
        if(left_file_size <= 0) {
            step = TRANS_STEP_DONE;
            try {
                sendTransFileDone();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return;
        }

        int len = left_file_size;
        if (len > ONE_PKT_MAX_SIZE) {
            len = ONE_PKT_MAX_SIZE;
        }
        byte[] buf = new byte[len];

        if(FileTransParamDef.FILE_TYPE_TXT == file_trans_type) {
            Log.i(TAG, "continue trans: " + (file_buf.length - left_file_size));
            System.arraycopy(file_buf, file_buf.length - left_file_size, buf, 0, len);
        }
        else if(FileTransParamDef.FILE_TYPE_OTA == file_trans_type || FileTransParamDef.FILE_TYPE_IMAGE == file_trans_type) {
            try {
                Log.i(TAG, "left_file_size: " + left_file_size);
                System.arraycopy(file_buf, file_buf.length - left_file_size, buf, 0, len);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        FileTransSendPack tx = new FileTransSendPack();
        tx.sendFileData(buf);
    }

    @SuppressLint("NewApi")
    public String getRealPath(final Context context, final Uri uri) {
         final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

         // DocumentProvider
         if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
             // ExternalStorageProvider
             if (isExternalStorageDocument(uri)) {
                 final String docId = DocumentsContract.getDocumentId(uri);
                 final String[] split = docId.split(":");
                 final String type = split[0];

                 if ("primary".equalsIgnoreCase(type)) {
                     return Environment.getExternalStorageDirectory() + "/" + split[1];
                 }
             }
             // DownloadsProvider
             else if (isDownloadsDocument(uri)) {
                 final String id = DocumentsContract.getDocumentId(uri);
                 final Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));
                 return getDataColumn(context, contentUri, null, null);
             }
             // MediaProvider
             else if (isMediaDocument(uri)) {
                 final String docId = DocumentsContract.getDocumentId(uri);
                 final String[] split = docId.split(":");
                 final String type = split[0];

                 Uri contentUri = null;
                 if ("image".equals(type)) {
                     contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                 } else if ("video".equals(type)) {
                     contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                 } else if ("audio".equals(type)) {
                     contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                 }

                 final String selection = "_id=?";
                 final String[] selectionArgs = new String[]{split[1]};
                 return getDataColumn(context, contentUri, selection, selectionArgs);
             }
         }
         // MediaStore (and general)
         else if ("content".equalsIgnoreCase(uri.getScheme())) {
             return getDataColumn(context, uri, null, null);
         }
         // File
         else if ("file".equalsIgnoreCase(uri.getScheme())) {
             return uri.getPath();
         }
         return null;
     }

/**
       * Get the value of the data column for this Uri. This is useful for
       * MediaStore Uris, and other file-based ContentProviders.
       *
       * @param context       The context.
       * @param uri           The Uri to query.
       * @param selection     (Optional) Filter used in the query.
       * @param selectionArgs (Optional) Selection arguments used in the query.
       * @return The value of the _data column, which is typically a file path.
       */
     public String getDataColumn(Context context, Uri uri, String selection,
                                 String[] selectionArgs) {

         Cursor cursor = null;
         final String column = "_data";
         final String[] projection = {column};

         try {
             cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
             if (cursor != null && cursor.moveToFirst()) {
                 final int column_index = cursor.getColumnIndexOrThrow(column);
                 return cursor.getString(column_index);
             }
         } finally {
             if (cursor != null)
                 cursor.close();
         }
         return null;
     }

/**
      * @param uri The Uri to check.
      * @return Whether the Uri authority is ExternalStorageProvider.
      */
     public boolean isExternalStorageDocument(Uri uri) {
         return "com.android.externalstorage.documents".equals(uri.getAuthority());
     }

     /**
      * @param uri The Uri to check.
      * @return Whether the Uri authority is DownloadsProvider.
      */
     public boolean isDownloadsDocument(Uri uri) {
         return "com.android.providers.downloads.documents".equals(uri.getAuthority());
     }

     /**
      * @param uri The Uri to check.
      * @return Whether the Uri authority is MediaProvider.
      */
     public boolean isMediaDocument(Uri uri) {
         return "com.android.providers.media.documents".equals(uri.getAuthority());
     }
}
