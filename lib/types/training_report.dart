class SkipResultData {
  int reportTime = 0; //时间戳
  int trainingDuration = 0; //跳绳总时长
  int totalJumpRopeCount = 0; //跳绳总次数
  int averageSpeed = 0; //平均频次
  int maxSpeed = 0; //最快频次
  int maxJumpRopeCount = 0; //最大连跳次数
  int interruptions = 0; //绊绳次数
  int jumpRopeDuration = 0; //有效跳绳时长
  int status = 0;
  String signature = "";

  SkipResultData();

  /*
    {
        "messageType": "2",
        "messageContext": {
            "timestamp": "1667966002",  //时间戳
            "skipSecSum": "11", //跳绳总时长
            "skipCntSum": "40", //跳绳总次数
            "skipValidSec": "11", //有效跳绳时长
            "freqAvg": "218", //平均频次
            "freqMax": "260", //最快频次
            "consecutiveSkipMaxNum": "13", //最大连跳次数
            "skipTripNum": "3", //绊绳次数
            "signature": "21f7a9272057cb1ced5bbd6b81ae4261e236ec5f260562de1cceb490576656ba6348b5725a0968057e470436e901a603033fdc4662b21bf6617c0a199a9da7a4"
        }
    }
   */
  SkipResultData.fromJson(Map<String, dynamic> json)
      : reportTime = json['timestamp'],
        trainingDuration = json['skipSecSum'],
        totalJumpRopeCount = json['skipCntSum'],
        averageSpeed = json['freqAvg'],
        maxSpeed = json['freqMax'],
        maxJumpRopeCount = json['consecutiveSkipMaxNum'],
        interruptions = json['skipTripNum'],
        jumpRopeDuration = json['skipValidSec'],
        signature = json['signature'];
}

class SkipDisplayData {
  int mode = 0; //跳绳模式
  int setting = 0; //跳绳设置
  int trainingDuration = 0; //跳绳总时长
  int totalJumpRopeCount = 0; //跳绳总次数
  int batteryPercent = 0; //平均频次
  int jumpRopeDuration = 0; //有效跳绳时长

  /*
    {
        "messageType": "1",
        "messageContext": {
            "mode": "自由跳",
            "setting": "0",
            "skipSecSum": "0",
            "skipCntSum": "0",
            "batteryPercent": "100",
            "skipValidSec": "0"
        }
    }
   */

  SkipDisplayData.fromJson(Map<String, dynamic> json)
      : mode = json['mode'],
        setting = json['setting'],
        trainingDuration = json['skipSecSum'],
        totalJumpRopeCount = json['skipCntSum'],
        batteryPercent = json['batteryPercent'],
        jumpRopeDuration = json['skipValidSec'];
}
