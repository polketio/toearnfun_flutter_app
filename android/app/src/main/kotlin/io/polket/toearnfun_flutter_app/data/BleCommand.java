package io.polket.toearnfun_flutter_app.data;

import android.bluetooth.BluetoothDevice;

import java.util.UUID;

public class BleCommand {
    public static int READ = 10000;

    private BluetoothDevice bluetoothDevice;
    private UUID serviceUUID;
    private UUID characteristicUUID;
    private byte[] data;
    private int type;

    public BleCommand(BluetoothDevice bluetoothDevice, UUID serviceUUID, UUID characteristicUUID, int type) {
        this.bluetoothDevice = bluetoothDevice;
        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
        this.type = type;
    }

    public BleCommand(BluetoothDevice bluetoothDevice, UUID serviceUUID, UUID characteristicUUID, byte[] data, int type) {
        this.bluetoothDevice = bluetoothDevice;
        this.serviceUUID = serviceUUID;
        this.characteristicUUID = characteristicUUID;
        this.data = data;
        this.type = type;
    }

    public BluetoothDevice getBluetoothDevice() {
        return bluetoothDevice;
    }

    public int getType() {
        return type;
    }

    public UUID getServiceUUID() {
        return serviceUUID;
    }

    public UUID getCharacteristicUUID() {
        return characteristicUUID;
    }

    public byte[] getData() {
        return data;
    }
}
