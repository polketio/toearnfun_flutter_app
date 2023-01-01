package io.polket.toearnfun_flutter_app.device;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ExpandableListView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import io.polket.toearnfun_flutter_app.R;
import io.polket.toearnfun_flutter_app.adapter.SettingAdapter;
import io.polket.toearnfun_flutter_app.bluetooth.BleManager;
import io.polket.toearnfun_flutter_app.bluetooth.ErrorCode;
import io.polket.toearnfun_flutter_app.exception.OtherException;

import java.util.ArrayList;
import java.util.List;

@SuppressLint({ "DefaultLocale", "NewApi" })
public class Dialog  {

    private static final String TAG = Dialog.class.getSimpleName();
    public static final  String SETTING_PROFIES_ACTION="com.bluetooth.demo.setting.profiles.ACTION";

    private static AlertDialog dialog;
    private static int lastGroupIndex = 0;
    private static EditText currentEditView;

    /**
     * 获取字符串资源内容
     * @param id
     * @return
     */
    public static String getResourceString(Context ctx, int id){
        if(ctx == null){
            return "null";
        }
        return ctx.getResources().getString(id);
    }


    /**
     * Single Choice Dialog View
     */
    public static void showSingleChoiceDialog(Context ctx, String title, CharSequence[] items, final IDialogActionListener listener)
    {
        if(items == null || ctx == null){
            return ;
        }
        // Strings to Show In Dialog with Radio Buttons
        // Creating and Building the Dialog
        AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
        builder.setTitle(title);
        builder.setSingleChoiceItems(items, -1,new DialogInterface.OnClickListener()
        {
            public void onClick(DialogInterface dialog, int which)
            {
                listener.onSingleChoiceItemValue(which);
                dialog.dismiss();
            }
        });
        dialog = builder.create();
        dialog.show();
    }


    /**
     * 判断是否存在设置项
     * @param items
     * @return
     */
    public static List<SettingItem> getEditSettingItem(List<SettingItem> items){
        if(items==null || items.size() ==0){
            return null;
        }
        List<SettingItem> editItems=new ArrayList<SettingItem>();
        for(SettingItem item:items){
            if(item.getOptions() == SettingOptions.Text){
                editItems.add(item);
            }
        }
        return editItems;
    }


    /**
     * 根据设置项，初始化EditText View
     * @param items
     * @param listView
     */
    public static void initEditTextView(final Context ctx, LinearLayout layout, List<SettingItem> items, final ExpandableListView listView, final OnEditTextViewListener listener){
        List<SettingItem> editItems=getEditSettingItem(items);
        if(editItems==null || editItems.size()==0){
            return ;
        }
        for(final SettingItem item:editItems){
            //add edit text cell
            LayoutInflater layoutInflater = (LayoutInflater) ctx.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            View editCellView= layoutInflater.inflate(R.layout.setting_item, null);
            TextView titleView=(TextView) editCellView.findViewById(R.id.setting_title_text_view);
            titleView.setText(item.getTitle());

            final EditText editView=(EditText) editCellView.findViewById(R.id.edit_text_view);
            editView.setInputType(item.getInputType());//InputType.TYPE_CLASS_TEXT
            final TextView valueTextView=(TextView) editCellView.findViewById(R.id.setting_value_text_view);
            editView.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    if(s != null && s.length() > 0)
                    {
                        String editValue=editView.getText().toString().trim();
                        valueTextView.setText(editValue);
                        //更新内容
                        item.setEditValue(editValue);
                        item.setTextViewValue(editValue);
                        //回调文本内容
                        listener.onEditTextResults(editView,item);
                    }
                }
            });
            //			editView.setOnFocusChangeListener(focusChangeListener);
            editCellView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(lastGroupIndex!=-1){
                        listView.collapseGroup(lastGroupIndex);
                        lastGroupIndex=-1;
                    }
                    logMessage("on  setOnClickListener >> "+v);
                    listener.onEditTextResults(editView,item);
                    valueTextView.setVisibility(View.GONE);
                    editView.setVisibility(View.VISIBLE);
                    editView.setEnabled(true);
                    editView.setHint(getResourceString(ctx, R.string.label_please_enter));
                    editView.requestFocus();
                    //弹出系统输入键盘
                    InputMethodManager imm = (InputMethodManager) ctx.getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.showSoftInput(editView, InputMethodManager.SHOW_IMPLICIT);
                }
            });
            layout.addView(editCellView);
        }
    }

    /**
     * 展示设备功能设置项
     * @param title
     * @param items
     * @param listener
     */
    public static void showSettingDialog(final Context ctx, String title, List<SettingItem> items, final IDialogActionListener listener)
    {
        if(items == null || ctx == null){
            return ;
        }

        currentEditView = null;
        final List<SettingItem> settings = new ArrayList<SettingItem>();
        for(SettingItem item:items){
            if(item.getOptions()!=SettingOptions.Text){
                settings.add(item);
            }
        }
        final List<SettingItem> editSettings = new ArrayList<SettingItem>();
        // Strings to Show In Dialog with Radio Buttons
        // Creating and Building the Dialog
        AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
        builder.setTitle(title);
        //add timepicker
        final View dialogView = LayoutInflater.from(ctx).inflate(R.layout.function_list, null);
        LinearLayout layout=(LinearLayout) dialogView.findViewById(R.id.functions_list_layout);
        //初始化function list
        final ExpandableListView expandableListView=(ExpandableListView) dialogView.findViewById(R.id.device_functions_list);
        //初始化EditTextView
        initEditTextView(ctx, layout, items,expandableListView,new OnEditTextViewListener() {
            @Override
            public void onEditTextResults(EditText editView,SettingItem item) {
            currentEditView = editView;
            if(!editSettings.contains(item)){
                editSettings.add(item);
            }
            }
        });
        //init list adapter
        final SettingAdapter expandableListAdapter = new SettingAdapter(ctx, settings);
        expandableListView.setAdapter(expandableListAdapter);
        expandableListView.setOnGroupExpandListener(new ExpandableListView.OnGroupExpandListener() {
            @Override
            public void onGroupExpand(int groupPosition) {
                //collapse the old expanded group, if not the same
                //as new group to expand
                if(groupPosition != lastGroupIndex && lastGroupIndex!=-1){
                    //update item value
                    expandableListAdapter.notifyDataSetChanged();
                    expandableListView.collapseGroup(lastGroupIndex);
                }
                lastGroupIndex = groupPosition;
                //隐藏输入键盘及去除焦点
                if(currentEditView!=null){
                    //获取当前文本的输入内容
                    logMessage("current edit input text >> "+currentEditView.getText().toString().trim());
                    InputMethodManager imm = (InputMethodManager) ctx.getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(currentEditView.getWindowToken(), 0);
                    currentEditView=null;
                }
            }
        });
        //重点击事件
        expandableListView.setOnGroupCollapseListener(new ExpandableListView.OnGroupCollapseListener() {
            @Override
            public void onGroupCollapse(int groupPosition) {
                //update item value
                expandableListAdapter.notifyDataSetChanged();
            }
        });

        //set click listener
        builder.setPositiveButton("OK", new AlertDialog.OnClickListener(){
            @Override
            public void onClick(DialogInterface dialog, int which) {
            if(lastGroupIndex!=-1){
                //update item value
                expandableListAdapter.notifyDataSetChanged();
                expandableListView.collapseGroup(lastGroupIndex);
                lastGroupIndex=-1;
            }
            //回调设置信息
            List<SettingItem> results=new ArrayList<SettingItem>();
            results.addAll(settings);
            results.addAll(editSettings);
            listener.onSettingItems(results);
            dialog.dismiss();
            }
        });
        dialog = builder.setView(dialogView).create();
        dialog.show();
    }


    /**
     * 发送设置失败的广播
     * @param msg
     */
    private static void sendSettingFailureBroadcast(Context ctx, String msg)
    {
        //
        logMessage("send broadcast >>"+msg);
        Intent errorIntent = new Intent();
        errorIntent.setAction(SETTING_PROFIES_ACTION);
        errorIntent.addFlags(Intent.FLAG_INCLUDE_STOPPED_PACKAGES);

        errorIntent.putExtra("errorMsg", getResourceString(ctx, R.string.title_error_parameter) +" \r\n "+msg);
        //以广播的形式，回调设置失败的原因
        //		baseContext.sendBroadcast(errorIntent);
        LocalBroadcastManager.getInstance(ctx).sendBroadcast(errorIntent);
    }


    /*   *//**
     * 检查设置项
     * @param items
     * @param callback
     */
    public static boolean checkSettingItems(Context ctx, List<SettingItem> items, BleManager.LcWriteBleCallback callback)
    {
        if(items == null || items.size() == 0){
            callback.onWriteFailure(new OtherException(ErrorCode.getCodeName(ErrorCode.PARAMETER_ERROR_CODE)));
            //sendSettingFailureBroadcast("no setting items");
            logMessage("on setting items  is failure ....");
            return false;
        }
        boolean isSuccess=true;
        for(SettingItem item:items){
            if(item.getOptions() == SettingOptions.TimePicker){
                if(item.getTime() == null || item.getTime().length() == 0){
                    //sendSettingFailureBroadcast(item.getTitle()+"="+item.getTime());
                    logMessage("on setting items  time is failure ....");
                    isSuccess = false;
                    break ;
                }
                if(item.getOptions() == SettingOptions.Text){
                    if(TextUtils.isEmpty(item.getTextViewValue())){
                        //logMessage("on setting items  text is failure ....");
                        sendSettingFailureBroadcast(ctx,item.getTitle()+"="+item.getTextViewValue());
                        isSuccess = false;
                        break;
                    }
                }
            }
        }
        if(!isSuccess){
            logMessage("on setting items  all is failure ....");
            callback.onWriteFailure(new OtherException(ErrorCode.getCodeName(ErrorCode.PARAMETER_ERROR_CODE)));
            return false;
        }
        return true;
    }


    /**
     * log message
     * @param msg
     */
    public static void logMessage(String msg){
        Log.e(TAG, msg);
    }
}

