package com.example.toearnfun_flutter_app.device;

import android.content.Intent;

import java.util.List;

public abstract class IDialogActionListener {

    public void onSingleChoiceItemValue(int index){};

    public void onTimeChoiceValue(int hour,int minute){};

    public void onTitleAndTimeChoiceValue(String title,int hour,int minute){};

    public void onMultiChoiceItemValue(List<Integer> items){};

    public void onIntentResults(Intent intent){};

    public void onSettingItems(List<SettingItem> items){};

    public void onBindingResults(int verifyCode){};

    //public void onKchiingReminderCreate(SettingItem item,KReminder reminder){};

    //public void onRepeatSettingCreate(SettingItem item,KRepeatSetting repeatSetting){}
}
