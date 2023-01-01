package io.polket.toearnfun_flutter_app.device;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;

import io.polket.toearnfun_flutter_app.data.BleDevice;


@SuppressLint({ "DefaultLocale", "NewApi" })
public class DeviceSettingProfiles  {

    private static final String TAG = DeviceSettingProfiles.class.getSimpleName();

    private static Context baseContext;

    /*private static final String[] APP_PERMISSIONS = new String[]{
            "GPS",
            "Notification",
            "Accessibility"
    };*/

    public static void initActivityContext(Activity activity){
        baseContext = activity;
    }

    public static Context getDevSettingContext() {
        return baseContext;
    }

    /**
     * 获取字符串资源内容
     * @param id
     * @return
     */
    public static String getResourceString(int id){
        if(baseContext == null){
            return "null";
        }
        return baseContext.getResources().getString(id);
    }


    /**
     *
     */
    /*public static void showAppPermissionSetting(final IDialogActionListener listener)
    {
        String title = baseContext.getResources().getString(R.string.title_app_permission);
        Dialog.showSingleChoiceDialog(baseContext, title, APP_PERMISSIONS, new IDialogActionListener()
        {
            @Override
            public void onSingleChoiceItemValue(int index)
            {
                if(index==0){
                    Intent intent=new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                    listener.onIntentResults(intent);
                }
                else if(index==1){
                    Intent intent=new Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS");
                    listener.onIntentResults(intent);
                }
                else if(index==2){
                    Intent intent=new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
                    listener.onIntentResults(intent);
                }
                else{
                    listener.onIntentResults(null);
                }
            }
        });

    }*/

    /**
     * 判断设备是否已连接
     * @param bleDevice
     * @return
     */
    private static boolean isConnected(BleDevice bleDevice){
        return true;
        //		if(TextUtils.isEmpty(deviceMac)){
        //			return false;
        //		}
        //		DeviceConnectState state=LsBleManager.getInstance().checkDeviceConnectState(deviceMac);
        //		if(state==DeviceConnectState.CONNECTED_SUCCESS){
        //			return true;
        //		}
        //		else{
        //			return false;
        //		}
    }

}

