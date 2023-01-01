package io.polket.toearnfun_flutter_app.device.skip;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.InputType;
import android.util.Log;

import com.Ls.fileTrans.FileTransManager;
import com.Ls.skipBle.SkipParamDef;
import io.polket.toearnfun_flutter_app.R;
import io.polket.toearnfun_flutter_app.bluetooth.BleManager;
import io.polket.toearnfun_flutter_app.data.BleDevice;
import io.polket.toearnfun_flutter_app.device.DeviceSettingProfiles;
import io.polket.toearnfun_flutter_app.device.Dialog;
import io.polket.toearnfun_flutter_app.device.IDialogActionListener;
import io.polket.toearnfun_flutter_app.device.SettingItem;
import io.polket.toearnfun_flutter_app.device.SettingOptions;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


@SuppressLint({ "DefaultLocale", "NewApi" })
public class SkipSettingProfiles  {

    private static final String TAG = SkipSettingProfiles.class.getSimpleName();
    private SkipApiActivity api = new SkipApiActivity();

    /**
     * 获取字符串资源内容
     * @param id
     * @return
     */
    public static String getResourceString(int id){
        if(DeviceSettingProfiles.getDevSettingContext() == null){
            return "null";
        }
        return DeviceSettingProfiles.getDevSettingContext().getResources().getString(id);
    }


    /**
     *
     */
    public void syncDeviceTime(final BleDevice bleDevice, final BleManager.LcWriteBleCallback callback) {
        int utc = (int)(System.currentTimeMillis() / 1000);
        Log.i(TAG, "syncDeviceTime:" + utc);
        api.syncDeviceTime(bleDevice, utc, callback);
    }

    public void setSkipMode(final BleDevice bleDevice, final BleManager.LcWriteBleCallback callback)
    {
        final String Mode = getResourceString(R.string.str_fun_set_jump_mode);
        final String StartSecs = getResourceString(R.string.str_fun_set_start_secs);
        final String Param = getResourceString(R.string.str_fun_set_jump_param);

        final String[] JUMP_MODE = new String[]{
                getResourceString(R.string.count_down),
                getResourceString(R.string.count_back),
                getResourceString(R.string.free_jump),
        };

        //init setting items
        List<SettingItem> items = new ArrayList<SettingItem>();

        SettingItem jumpModeItem = new SettingItem(SettingOptions.SingleChoice);
        jumpModeItem.setTitle(Mode);
        jumpModeItem.setChoiceItems(Arrays.asList(JUMP_MODE));

        SettingItem StartSecsItem=new SettingItem();
        StartSecsItem.setOptions(SettingOptions.Text);
        StartSecsItem.setTitle(StartSecs);
        StartSecsItem.setInputType(InputType.TYPE_CLASS_TEXT);

        SettingItem paramItem=new SettingItem();
        paramItem.setOptions(SettingOptions.Text);
        paramItem.setTitle(Param);
        paramItem.setInputType(InputType.TYPE_CLASS_TEXT);

        //add item to list
        items.add(jumpModeItem);
        items.add(StartSecsItem);
        items.add(paramItem);

        //show setting dialog
        Context ctx = DeviceSettingProfiles.getDevSettingContext();
        Dialog.showSettingDialog(ctx, Mode, items, new IDialogActionListener() {
            @Override
            public void onSettingItems(List<SettingItem> items)
            {
                int mode = 0xFF;
                int ParamInt = 0;
                int startSecs = 3;
                String paramStr = "";
                for(SettingItem item:items) {
                    if(item.getTitle().equalsIgnoreCase(Mode)) {
                        mode = item.getIndex();
                    }
                    if(SkipParamDef.MODE_COUNT_DOWN == mode && item.getTitle().equalsIgnoreCase(Param)) {
                        paramStr = item.getTextViewValue();
                        ParamInt = Integer.parseInt(paramStr);
                        if(ParamInt > SkipParamDef.TIME_SECS_MAX_VAL)
                            ParamInt = SkipParamDef.TIME_SECS_MAX_VAL;
                        //Log.i(TAG, "Count Down >> mode: "+mode+", param: "+param);
                    }
                    else if(SkipParamDef.MODE_COUNT_BACK == mode && item.getTitle().equalsIgnoreCase(Param)) {
                        paramStr = item.getTextViewValue();
                        ParamInt = Integer.parseInt(paramStr);
                        if(ParamInt > SkipParamDef.SKIP_CNT_MAX_VAL)
                            ParamInt = SkipParamDef.SKIP_CNT_MAX_VAL;
                        //Log.i(TAG,"Count back >> mode: "+mode+", param: "+param);
                    }

                    if(item.getTitle().equalsIgnoreCase(StartSecs)) {
                        paramStr = item.getTextViewValue();
                        if(paramStr != "") {
                            startSecs = Integer.parseInt(paramStr);
                            if (startSecs > SkipParamDef.START_SKIP_SECS_MAX_VAL)
                                startSecs = SkipParamDef.START_SKIP_SECS_MAX_VAL;
                            Log.i(TAG, "Count Down >> mode: "+mode+", startSecs: "+startSecs);
                        }
                    }
                }

                //call interface
                if( (SkipParamDef.MODE_COUNT_DOWN == mode && ParamInt <= 0) || (SkipParamDef.MODE_COUNT_BACK == mode && ParamInt <= 0) ) {
                    Log.i(TAG,"Invalid param");
                    return;
                }
                int utc = (int)(System.currentTimeMillis() / 1000);
                Log.i(TAG,"utc:"+utc+", mode: "+mode+", param: "+ParamInt);
                api.setSkipMode(bleDevice, utc, mode, ParamInt, startSecs, callback);
            }
        });
    }

    public void stopSkip(final BleDevice bleDevice, final BleManager.LcWriteBleCallback callback) {
        Log.i(TAG, "stopSkip");
        api.stopSkip(bleDevice, callback);
    }

    public void devReset(final BleDevice bleDevice, final BleManager.LcWriteBleCallback callback) {
        Log.i(TAG, "devReset");
        api.devReset(bleDevice, callback);
    }

    public void devRevert(final BleDevice bleDevice, final BleManager.LcWriteBleCallback callback) {
        Log.i(TAG, "devReset");
        api.devRevert(bleDevice, callback);
    }

    public void setDevAdvName(final BleDevice bleDevice, final BleManager.LcWriteBleCallback callback) {
        Log.i(TAG, "setDevAdvName");
        final String SetAdvName = getResourceString(R.string.str_fun_set_adv_name);

        //init setting items
        List<SettingItem> items = new ArrayList<SettingItem>();

        SettingItem SetAdvNameItem=new SettingItem();
        SetAdvNameItem.setOptions(SettingOptions.Text);
        SetAdvNameItem.setTitle(SetAdvName);
        SetAdvNameItem.setInputType(InputType.TYPE_CLASS_TEXT);

        //add item to list
        items.add(SetAdvNameItem);

        //show setting dialog
        Context ctx = DeviceSettingProfiles.getDevSettingContext();
        Dialog.showSettingDialog(ctx, SetAdvName, items, new IDialogActionListener() {
            String paramStr = "";
            @Override
            public void onSettingItems(List<SettingItem> items) {
                for(SettingItem item:items) {
                    if(item.getTitle().equalsIgnoreCase(SetAdvName)) {
                        byte[] name = new byte[18];
                        paramStr = item.getTextViewValue();
                        int name_len = paramStr.length();
                        Log.i(TAG, "name_len: " + name_len);
                        if(name_len > 18)
                            return;
                        for (int i = 0; i < paramStr.length(); i++) {
                            name[i] = (byte)paramStr.charAt(i);
                        }
                        api.setDevAdvName(name, name_len, bleDevice, callback);
                    }
                }
            }
        });
    }


    public void setFontHeadInfo(final BleDevice bleDevice, final BleManager.LcWriteBleCallback callback) {
        Log.i(TAG, "setFontHeadInfo");
        final String SetFontTrans = getResourceString(R.string.str_fun_font_trans);

        //init setting items
        List<SettingItem> items = new ArrayList<SettingItem>();

        SettingItem SetTextItem=new SettingItem();
        SetTextItem.setOptions(SettingOptions.Text);
        SetTextItem.setTitle(SetFontTrans);
        SetTextItem.setInputType(InputType.TYPE_CLASS_TEXT);

        //add item to list
        items.add(SetTextItem);

        //show setting dialog
        Context ctx = DeviceSettingProfiles.getDevSettingContext();
        Dialog.showSettingDialog(ctx, SetFontTrans, items, new IDialogActionListener() {
            String paramStr = "";
            @Override
            public void onSettingItems(List<SettingItem> items) {
                for(SettingItem item:items) {
                    if(item.getTitle().equalsIgnoreCase(SetFontTrans)) {
                        paramStr = item.getTextViewValue();
                        FileTransManager trans = new FileTransManager();
                        trans.startTextTransProgress(DeviceSettingProfiles.getDevSettingContext(), R.raw.font_lib, paramStr, paramStr.length());
                    }
                }
            }
        });
    }
}

