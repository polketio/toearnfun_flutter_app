package com.Ls.skipBle;

public class SkipResultData {
    private int utc;
    private int mode;
    private int setting;
    private int skip_sec_sum;
    private int skip_cnt_sum;
    private int freq_avg;
    private int freq_max;
    private int consecutive_skip_max_num;
    private int skip_group_num;
    private int skip_group[][] = new int[SkipParamDef.SKIP_GROUP_MAX_NUM][2];
    private int skip_valid_sec;

    public SkipResultData() {}

    public void reset() {
        this.utc = 0;
        this.mode = 0;
        this.setting = 0;
        this.skip_sec_sum = 0;
        this.skip_cnt_sum = 0;
        this.freq_avg = 0;
        this.freq_max = 0;
        this.consecutive_skip_max_num = 0;
        this.skip_group_num = 0;
        for(int i=0;i<SkipParamDef.SKIP_GROUP_MAX_NUM;i++) {
            for(int j=0;j<2;j++) {
                skip_group[i][j] = 0;
            }
        }
        this.skip_valid_sec = 0;
    }

    public void setUtc(int utc) { this.utc = utc; }
    public int getUtc() { return this.utc; }

    public void setMode(int mode) { this.mode = mode; }
    public int getMode() { return this.mode; }

    public void setSetting(int setting) { this.setting = setting; }
    public int getSetting() { return this.setting; }

    public void setSkipSecSum(int skip_sec_sum) { this.skip_sec_sum = skip_sec_sum; }
    public int getSkipSecSum() { return this.skip_sec_sum; }

    public void setSkipCntSum(int skip_cnt_sum) { this.skip_cnt_sum = skip_cnt_sum; }
    public int getSkipCntSum() { return this.skip_cnt_sum; }

    public void setFreqAvg(int freq_avg) { this.freq_avg = freq_avg; }
    public int getFreqAvg() { return this.freq_avg; }

    public void setFreqMax(int freq_max) { this.freq_max = freq_max; }
    public int getFreqMax() { return this.freq_max; }

    public void setConsecutiveSkipMaxNum(int consecutive_skip_max_num) { this.consecutive_skip_max_num = consecutive_skip_max_num; }
    public int getConsecutiveSkipMaxNum() { return this.consecutive_skip_max_num; }

    public void setSkipGroupNum(int skip_group_num) { this.skip_group_num = skip_group_num; }
    public int getSkipGroupNum() { return this.skip_group_num; }

    public int getSkipTripNum() {
        if(this.skip_group_num > 0)
            return this.skip_group_num - 1;
        else
            return 0;
    }

    public void setSkipGroupEle(int group_num, int skip_secs, int skip_cnt) {
        if(group_num >= SkipParamDef.SKIP_GROUP_MAX_NUM)
            return;
        this.skip_group[group_num][0] = skip_secs;
        this.skip_group[group_num][1] = skip_cnt;
    }

    public int getSkipGroupEleSkipSecs(int group_num) { return this.skip_group[group_num][0]; }
    public int getSkipGroupEleSkipCnt(int group_num) { return this.skip_group[group_num][1]; }

    public void setSkipValidSec(int skip_valid_sec) { this.skip_valid_sec = skip_valid_sec; }
    public int getSkipValidSec() { return this.skip_valid_sec; }
}
