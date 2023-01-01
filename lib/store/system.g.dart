// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SystemStore on _SystemStore, Store {
  late final _$currentBlockNumberAtom =
      Atom(name: '_SystemStore.currentBlockNumber', context: context);

  @override
  int get currentBlockNumber {
    _$currentBlockNumberAtom.reportRead();
    return super.currentBlockNumber;
  }

  @override
  set currentBlockNumber(int value) {
    _$currentBlockNumberAtom.reportWrite(value, super.currentBlockNumber, () {
      super.currentBlockNumber = value;
    });
  }

  late final _$updateCurrentBlockNumberAsyncAction =
      AsyncAction('_SystemStore.updateCurrentBlockNumber', context: context);

  @override
  Future<void> updateCurrentBlockNumber(int value) {
    return _$updateCurrentBlockNumberAsyncAction
        .run(() => super.updateCurrentBlockNumber(value));
  }

  @override
  String toString() {
    return '''
currentBlockNumber: ${currentBlockNumber}
    ''';
  }
}
