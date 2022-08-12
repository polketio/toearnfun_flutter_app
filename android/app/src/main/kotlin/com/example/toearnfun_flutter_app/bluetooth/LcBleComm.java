package com.example.toearnfun_flutter_app.bluetooth;

import com.example.toearnfun_flutter_app.data.BleDevice;

public class LcBleComm {
    public static int READ = 10000;
    public static int WRITE = 10001;

    private BleDevice bleDevice;
    private String serviceUUID;
    private String characteristicUUID;
    private byte[] data;
    private int type;
    private BleManager.LcWriteBleCallback lcWriteBleCallback;
    private BleManager.LcReadBleCallback lcReadBleCallback;

    public LcBleComm(BleDevice bleDevice, String serviceUUID, String characteristicUUID, int type, BleManager.LcReadBleCallback callback) {
        this.bleDevice = bleDevice;
        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
        this.type = type;
        this.lcReadBleCallback = callback;
    }

    public LcBleComm(BleDevice bleDevice, String serviceUUID, String characteristicUUID, byte[] data, int type, BleManager.LcWriteBleCallback callback) {
        this.bleDevice = bleDevice;
        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
        this.data = data;
        this.type = type;
        this.lcWriteBleCallback = callback;
    }

    public BleDevice getBleDevice() {
        return bleDevice;
    }

    public int getType() {
        return type;
    }

    public String getServiceUUID() {
        return serviceUUID;
    }

    public String getCharacteristicUUID() {
        return characteristicUUID;
    }

    public byte[] getData() {
        return data;
    }

    public BleManager.LcWriteBleCallback getLcWriteBleCallback() {
        return lcWriteBleCallback;
    }

    public BleManager.LcReadBleCallback getLcReadBleCallback() {
        return lcReadBleCallback;
    }
}
