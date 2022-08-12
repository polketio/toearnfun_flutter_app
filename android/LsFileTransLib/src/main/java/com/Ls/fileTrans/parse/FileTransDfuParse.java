package com.Ls.fileTrans.parse;

import android.util.Log;

import com.Ls.fileTrans.FileTransParamDef;
import com.Ls.fileTrans.FileTransSendPack;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;


public class FileTransDfuParse {
    private static final String TAG = "FileTransDfu";

    //Param
    private static int dev_type;
    private static int project_num;
    private static int version;
    private static int firmware_crc16;
    private static int bin_size;

    //Bin
    private static final String BIN_FILE_NAME = "ble_app_skip_phy6222.hex16.bin";

    //Json
    private static final String JSON_FILE_NAME = "manifest.json";
    private static final String JSON_FIRMWARE_CRC_NAME = "firmware_crc16";
    private static final String JSON_PROJECT_NUM_NAME = "project_number";
    private static final String JSON_DEV_TYPE_NAME = "device_type";
    private static final String JSON_APP_VER_NAME = "application_version";

    public static int getDfuBinSize() {
        return bin_size;
    }

    public static void parseDfuZipFile(String filePath) {
        try {
            readDfuJsonInfoFile(filePath);
            getDfuBinFileSize(filePath);
        }catch (Exception e) {
            bin_size = 0;
        }finally {
            FileTransSendPack tx = new FileTransSendPack();
            tx.setDfuInfo(FileTransParamDef.OTA_TYPE_APPLICATION, bin_size, dev_type, project_num, version, firmware_crc16, 0);
        }
    }


    private static void getDfuBinFileSize(String filePath) throws IOException {
        ZipFile zf = new ZipFile(filePath);
        InputStream in = new BufferedInputStream(new FileInputStream(filePath));
        ZipInputStream zin = new ZipInputStream(in);
        ZipEntry ze;
        bin_size = 0;
        while ((ze = zin.getNextEntry()) != null) {
            if (ze.isDirectory()) {
                //Do nothing
            } else {
                if (ze.getName().equals(BIN_FILE_NAME)) {
                    InputStream is = zf.getInputStream(ze);
                    bin_size = is.available();
                    is.close();
                    Log.i(TAG, "bin_size" + ": " +  bin_size);
                }
            }
        }
        in.close();
        zin.closeEntry();
    }

    private static void readDfuJsonInfoFile(String filePath) throws Exception {
        ZipFile zf = new ZipFile(filePath);
        InputStream in = new BufferedInputStream(new FileInputStream(filePath));
        ZipInputStream zin = new ZipInputStream(in);
        ZipEntry ze;
        while ((ze = zin.getNextEntry()) != null) {
            if (ze.isDirectory()) {
                //Do nothing
            } else {
                if (ze.getName().equals(JSON_FILE_NAME)) {
                    StringBuilder stringBuilder = new StringBuilder();
                    BufferedReader br = new BufferedReader(new InputStreamReader(zf.getInputStream(ze)));
                    String line;
                    while ((line = br.readLine()) != null) {
                        //Log.i(TAG, line);
                        stringBuilder.append(line);
                    }
                    br.close();

                    try {
                        //Log.i(TAG, stringBuilder.toString());
                        JSONObject json = new JSONObject(stringBuilder.toString());
                        JSONObject manifest = json.getJSONObject("manifest");
                        JSONObject application = manifest.getJSONObject("application");
                        JSONObject init_packet_data = application.getJSONObject("init_packet_data");
                        dev_type = init_packet_data.getInt(JSON_DEV_TYPE_NAME);
                        project_num = init_packet_data.getInt(JSON_PROJECT_NUM_NAME);
                        version = init_packet_data.getInt(JSON_APP_VER_NAME);
                        firmware_crc16 = init_packet_data.getInt(JSON_FIRMWARE_CRC_NAME);
                        Log.i(TAG, JSON_DEV_TYPE_NAME + ": " +  dev_type);
                        Log.i(TAG, JSON_PROJECT_NUM_NAME + ": " + project_num);
                        Log.i(TAG, JSON_FIRMWARE_CRC_NAME + ": " + firmware_crc16);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        in.close();
        zin.closeEntry();
    }


    public static void readDfuBinFile(String filePath, byte[] buf, int len) throws Exception {
        ZipFile zf = new ZipFile(filePath);
        InputStream in = new BufferedInputStream(new FileInputStream(filePath));
        ZipInputStream zin = new ZipInputStream(in);
        ZipEntry ze;
        while ((ze = zin.getNextEntry()) != null) {
            if (ze.isDirectory()) {
                //Do nothing
            } else {
                if (ze.getName().equals(BIN_FILE_NAME)) {
                    InputStream is = zf.getInputStream(ze);
                    int read_whole_len = 0;
                    int bin_file_len = is.available();
                    int left_read_len = bin_file_len;
                    //Log.i(TAG, "bin_file_len: " + bin_file_len);
                    while(read_whole_len < bin_file_len) {
                        int read_len = is.read(buf, read_whole_len, left_read_len);
                        read_whole_len += read_len;
                        left_read_len -= read_len;
                        //Log.i(TAG, "left_read_len: " + left_read_len);
                    }
                    //Log.i(TAG, "read_whole_len: " + read_whole_len);
                    is.close();
                }
            }
        }
        in.close();
        zin.closeEntry();
    }

}