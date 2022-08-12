package com.Ls.skipBle;

public class SkipDisplayData {
    private int mode;
    private int setting;
    private int skip_secs_sum;
    private int skip_cnt_sum;
    private int trip_cnt;
    private int battery_per;
    private int skip_valid_sec;

    public SkipDisplayData(int mode, int setting, int skip_secs_sum, int skip_cnt_sum, int trip_cnt, int battery_per, int skip_valid_sec) {
        this.mode = mode;
        this.setting = setting;
        this.skip_secs_sum = skip_secs_sum;
        this.skip_cnt_sum = skip_cnt_sum;
        this.trip_cnt = trip_cnt;
        this.battery_per = battery_per;
        this.skip_valid_sec = skip_valid_sec;
    }

    public int getMode() {
        return this.mode;
    }

    public int getSetting() {
        return this.setting;
    }

    public int getSkipSecSum() {
        return this.skip_secs_sum;
    }

    public int getSkipCntSum() {
        return this.skip_cnt_sum;
    }

    public int getTripCnt() {
        return this.trip_cnt;
    }

    public int getBatteryPercent() {
        return this.battery_per;
    }

    public int getSkipValidSec() { return this.skip_valid_sec; }
}
