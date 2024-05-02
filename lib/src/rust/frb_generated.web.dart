// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.32.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/smtc_flutter.dart';
import 'api/system_theme.dart';
import 'api/tag_reader.dart';
import 'api/utils.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_web.dart';

abstract class RustLibApiImplPlatform extends BaseApiImpl<RustLibWire> {
  RustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  CrossPlatformFinalizerArg
      get rust_arc_decrement_strong_count_SmtcFlutterPtr => wire
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter;

  @protected
  SmtcFlutter
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          dynamic raw);

  @protected
  SmtcFlutter
      dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          dynamic raw);

  @protected
  SmtcFlutter
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          dynamic raw);

  @protected
  RustStreamSink<SMTCControlEvent> dco_decode_StreamSink_smtc_control_event_Sse(
      dynamic raw);

  @protected
  RustStreamSink<SystemTheme> dco_decode_StreamSink_system_theme_Sse(
      dynamic raw);

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  bool dco_decode_bool(dynamic raw);

  @protected
  int dco_decode_i_32(dynamic raw);

  @protected
  List<String> dco_decode_list_String(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  String? dco_decode_opt_String(dynamic raw);

  @protected
  Uint8List? dco_decode_opt_list_prim_u_8_strict(dynamic raw);

  @protected
  (int, int, int, int) dco_decode_record_u_8_u_8_u_8_u_8(dynamic raw);

  @protected
  SMTCControlEvent dco_decode_smtc_control_event(dynamic raw);

  @protected
  SMTCState dco_decode_smtc_state(dynamic raw);

  @protected
  SystemTheme dco_decode_system_theme(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  int dco_decode_usize(dynamic raw);

  @protected
  SmtcFlutter
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          SseDeserializer deserializer);

  @protected
  SmtcFlutter
      sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          SseDeserializer deserializer);

  @protected
  SmtcFlutter
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          SseDeserializer deserializer);

  @protected
  RustStreamSink<SMTCControlEvent> sse_decode_StreamSink_smtc_control_event_Sse(
      SseDeserializer deserializer);

  @protected
  RustStreamSink<SystemTheme> sse_decode_StreamSink_system_theme_Sse(
      SseDeserializer deserializer);

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer);

  @protected
  Uint8List? sse_decode_opt_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  (int, int, int, int) sse_decode_record_u_8_u_8_u_8_u_8(
      SseDeserializer deserializer);

  @protected
  SMTCControlEvent sse_decode_smtc_control_event(SseDeserializer deserializer);

  @protected
  SMTCState sse_decode_smtc_state(SseDeserializer deserializer);

  @protected
  SystemTheme sse_decode_system_theme(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  int sse_decode_usize(SseDeserializer deserializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          SmtcFlutter self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          SmtcFlutter self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          SmtcFlutter self, SseSerializer serializer);

  @protected
  void sse_encode_StreamSink_smtc_control_event_Sse(
      RustStreamSink<SMTCControlEvent> self, SseSerializer serializer);

  @protected
  void sse_encode_StreamSink_system_theme_Sse(
      RustStreamSink<SystemTheme> self, SseSerializer serializer);

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer);

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_list_prim_u_8_strict(
      Uint8List? self, SseSerializer serializer);

  @protected
  void sse_encode_record_u_8_u_8_u_8_u_8(
      (int, int, int, int) self, SseSerializer serializer);

  @protected
  void sse_encode_smtc_control_event(
      SMTCControlEvent self, SseSerializer serializer);

  @protected
  void sse_encode_smtc_state(SMTCState self, SseSerializer serializer);

  @protected
  void sse_encode_system_theme(SystemTheme self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_usize(int self, SseSerializer serializer);
}

// Section: wire_class

class RustLibWire implements BaseWire {
  RustLibWire.fromExternalLibrary(ExternalLibrary lib);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          dynamic ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          dynamic ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
              ptr);
}

@JS('wasm_bindgen')
external RustLibWasmModule get wasmModule;

@JS()
@anonymous
class RustLibWasmModule implements WasmModule {
  @override
  external Object /* Promise */ call([String? moduleName]);

  @override
  external RustLibWasmModule bind(dynamic thisArg, String moduleName);

  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          dynamic ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedrust_asyncRwLockSMTCFlutter(
          dynamic ptr);
}
