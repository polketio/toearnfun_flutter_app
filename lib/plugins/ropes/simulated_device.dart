import 'dart:math';

import 'package:flustars/flustars.dart';
import 'package:hash/hash.dart';
import 'package:realm/realm.dart';
import 'package:toearnfun_flutter_app/plugins/ropes/bluetooth_device.dart';
import 'package:toearnfun_flutter_app/store/plugin_store.dart';
import 'package:toearnfun_flutter_app/types/bluetooth_device.dart';
import 'dart:typed_data';
import 'package:sec/sec.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/src/utils.dart' as utils;
import 'package:toearnfun_flutter_app/types/training_report.dart';
import 'package:toearnfun_flutter_app/utils/bytes.dart';
import 'package:toearnfun_flutter_app/utils/crypto.dart';
import 'package:web3dart/crypto.dart';

class SimulatedDeviceConnector implements JumpRopeDeviceConnector {
  SimulatedDeviceConnector._internal();

  factory SimulatedDeviceConnector() => _instance;

  static late final SimulatedDeviceConnector _instance =
      SimulatedDeviceConnector._internal();

  bool _initialized = false;
  Set<JumpRopeDeviceObserver> observers = <JumpRopeDeviceObserver>{};
  FitnessDevice? connectedDevice;
  PluginStore? _store;
  bool autoConnect = false;
  String targetDeviceKey = '';
  BigInt? devicePrivateKey;

  void init(PluginStore store) {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _store = store;
  }

  @override
  void addObserver(JumpRopeDeviceObserver o) {
    observers.add(o);
    LogUtil.d('observers count = ${observers.length}');
  }

  @override
  void removeObserver(JumpRopeDeviceObserver o) {
    observers.remove(o);
  }

  @override
  bool autoScanAndConnect(String deviceKey) {
    final connectedDevices = _store!.devices.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      for (var d in connectedDevices) {
        if (d.pubKey == deviceKey) {
          Future.delayed(const Duration(seconds: 2), () async {
            await connect(d);
          });
          return true;
        }
      }
    }
    return false;
  }

  @override
  Future<bool> connect(FitnessDevice device) async {
    connectedDevice = device;
    _store!.devices.updateCurrentConnected(device);

    for (var o in observers) {
      o.onConnectSuccess(device);
    }
    return true;
  }

  @override
  Future<String> generateNewKeypair() async {
    Random rng = Random.secure(); //安全随机数发生器
    devicePrivateKey = generateNewPrivateKey(rng);
    final publicKey = EC.secp256r1.createPublicKey(devicePrivateKey!, true);
    final pkHex = hex.encode(publicKey);
    return pkHex;
  }

  @override
  Future<String> getPublicKey() async {
    if (devicePrivateKey != null) {
      final publicKey = EC.secp256r1.createPublicKey(devicePrivateKey!, true);
      final pkHex = hex.encode(publicKey);
      return pkHex;
    }
    return await generateNewKeypair();
  }

  @override
  Future<void> scanDevice() async {
    FitnessDevice device = FitnessDevice('Simulated', '333-333-333-333');
    device.simulated = true;
    device.pubKey = await getPublicKey();
    device.prvKey = hex.encode(utils.encodeBigInt(devicePrivateKey!));

    for (var o in observers) {
      o.onScanning(device);
    }
  }

  @override
  Future<String> setSkipMode() {
    // TODO: implement setSkipMode
    throw UnimplementedError();
  }

  @override
  Future<String> sigBindDevice(String accountId, int deviceNonce) async {
    if (devicePrivateKey == null) {
      return '';
    }
    accountId = accountId.replaceFirst('0x', '');
    List<int> data = [];
    final nonce = int32Bytes(deviceNonce, Endian.little);
    var dec = hex.decode(accountId);
    final accountHash = RIPEMD160().update(dec).digest();
    data.addAll(nonce);
    data.addAll(accountHash);
    final message = SHA256().update(data).digest();
    final signature =
        _generateSignature(devicePrivateKey!, Uint8List.fromList(message));
    return signature;
  }

  @override
  Future<bool> stopConnect() async {
    return false;
  }

  @override
  Future<String> stopSkip() {
    // TODO: implement stopSkip
    throw UnimplementedError();
  }

  Future<void> testsecp256r1() async {
    final privateKey = BigInt.parse(
      'c57304b3a53051600d7035fc593083810a8fa250e6a7a2803cf6a0f3c2750503',
      radix: 16,
    );

    final publicKey = EC.secp256r1.createPublicKey(privateKey, true);
    final pkHex = hex.encode(publicKey);
    print('Public Key: $pkHex');

    final message = hex.decode(
        '9d2a7f66e054a4f1b2458a7e465971f46f8f3d0727e6249b1e34ea39f32b7828');

    final signature =
        EC.secp256r1.generateSignature(privateKey, Uint8List.fromList(message));

    print(
        'signature: ${hex.encode(utils.encodeBigInt(signature.r))}${hex.encode(utils.encodeBigInt(signature.s))}');
  }

  String _generateSignature(BigInt privateKey, Uint8List message) {
    final signature = EC.secp256r1.generateSignature(privateKey, message);

    final data = BytesBuilder();
    data.add(utils.encodeBigInt(signature.r));
    data.add(utils.encodeBigInt(signature.s));
    if (data.length == 65) {
      return hex.encode(data.takeBytes().sublist(1));
    } else {
      return hex.encode(data.takeBytes());
    }
  }

  TrainingReport? generateRandomReport() {
    if (connectedDevice == null) {
      return null;
    }
    if (!connectedDevice!.simulated) {
      return null;
    }
    if (connectedDevice!.prvKey.isEmpty) {
      return null;
    }

    int reportTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    var rng = Random();
    final trainingDuration = rng.nextInt(180);
    final totalJumpRopeCount = rng.nextInt(900);
    final averageSpeed = rng.nextInt(300);
    final maxSpeed = rng.nextInt(300);
    final interruptions = rng.nextInt(4);
    TrainingReport report = TrainingReport(
      ObjectId(),
      reportTime: reportTime,
      trainingDuration: trainingDuration,
      totalJumpRopeCount: totalJumpRopeCount,
      averageSpeed: averageSpeed,
      maxSpeed: maxSpeed,
      maxJumpRopeCount: totalJumpRopeCount,
      interruptions: interruptions,
      jumpRopeDuration: trainingDuration,
      status: ReportStatus.notReported.name,
      deviceKey: connectedDevice!.pubKey,
    );

    final raw = report.encodeData();
    final message = Hash.sha256(raw);

    final privateKey = BigInt.parse(
      connectedDevice!.prvKey,
      radix: 16,
    );

    final signature =
        _generateSignature(privateKey, Uint8List.fromList(hex.decode(message)));
    report.signature = signature;

    _store!.report.addTrainingReport(report);
    return report;
  }
}
