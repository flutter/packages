// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The types and functions here correspond directly to corresponding Windows
// types and functions, so the Windows docs are the definitive source of
// documentation.
// ignore_for_file: public_member_api_docs

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'guid.dart';

typedef BOOL = Int32;
typedef BYTE = Uint8;
typedef DWORD = Uint32;
typedef UINT = Uint32;
typedef HANDLE = IntPtr;
typedef HMODULE = HANDLE;
typedef HRESULT = Int32;
typedef LPCVOID = Pointer<NativeType>;
typedef LPCWSTR = Pointer<Utf16>;
typedef LPDWORD = Pointer<DWORD>;
typedef LPWSTR = Pointer<Utf16>;
typedef LPVOID = Pointer<NativeType>;
typedef PUINT = Pointer<UINT>;
typedef PWSTR = Pointer<Pointer<Utf16>>;
typedef WCHAR = Uint16;

const int NULL = 0;

// https://learn.microsoft.com/windows/win32/fileio/maximum-file-path-limitation?tabs=registry
const int MAX_PATH = 260;

// https://learn.microsoft.com/windows/win32/seccrypto/common-hresult-values
// ignore: non_constant_identifier_names
final int E_FAIL = 0x80004005.toSigned(32);
// ignore: non_constant_identifier_names
final int E_INVALIDARG = 0x80070057.toSigned(32);

// https://learn.microsoft.com/windows/win32/api/winerror/nf-winerror-failed#remarks
// ignore: non_constant_identifier_names
bool FAILED(int hr) => hr < 0;

// https://learn.microsoft.com/windows/win32/api/shlobj_core/ne-shlobj_core-known_folder_flag
const int KF_FLAG_DEFAULT = 0x00000000;

final DynamicLibrary _dllKernel32 = DynamicLibrary.open('kernel32.dll');
final DynamicLibrary _dllVersion = DynamicLibrary.open('version.dll');
final DynamicLibrary _dllShell32 = DynamicLibrary.open('shell32.dll');

// https://learn.microsoft.com/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
typedef _FFITypeSHGetKnownFolderPath = HRESULT Function(
    Pointer<GUID>, DWORD, HANDLE, PWSTR);
typedef FFITypeSHGetKnownFolderPathDart = int Function(
    Pointer<GUID>, int, int, Pointer<Pointer<Utf16>>);
// ignore: non_constant_identifier_names
final FFITypeSHGetKnownFolderPathDart SHGetKnownFolderPath =
    _dllShell32.lookupFunction<_FFITypeSHGetKnownFolderPath,
        FFITypeSHGetKnownFolderPathDart>('SHGetKnownFolderPath');

// https://learn.microsoft.com/windows/win32/api/winver/nf-winver-getfileversioninfow
typedef _FFITypeGetFileVersionInfoW = BOOL Function(
    LPCWSTR, DWORD, DWORD, LPVOID);
typedef FFITypeGetFileVersionInfoW = int Function(
    Pointer<Utf16>, int, int, Pointer<NativeType>);
// ignore: non_constant_identifier_names
final FFITypeGetFileVersionInfoW GetFileVersionInfo = _dllVersion
    .lookupFunction<_FFITypeGetFileVersionInfoW, FFITypeGetFileVersionInfoW>(
        'GetFileVersionInfoW');

// https://learn.microsoft.com/windows/win32/api/winver/nf-winver-getfileversioninfosizew
typedef _FFITypeGetFileVersionInfoSizeW = DWORD Function(LPCWSTR, LPDWORD);
typedef FFITypeGetFileVersionInfoSizeW = int Function(
    Pointer<Utf16>, Pointer<Uint32>);
// ignore: non_constant_identifier_names
final FFITypeGetFileVersionInfoSizeW GetFileVersionInfoSize =
    _dllVersion.lookupFunction<_FFITypeGetFileVersionInfoSizeW,
        FFITypeGetFileVersionInfoSizeW>('GetFileVersionInfoSizeW');

// https://learn.microsoft.com/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror
typedef _FFITypeGetLastError = DWORD Function();
typedef FFITypeGetLastError = int Function();
// ignore: non_constant_identifier_names
final FFITypeGetLastError GetLastError = _dllKernel32
    .lookupFunction<_FFITypeGetLastError, FFITypeGetLastError>('GetLastError');

// https://learn.microsoft.com/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulefilenamew
typedef _FFITypeGetModuleFileNameW = DWORD Function(HMODULE, LPWSTR, DWORD);
typedef FFITypeGetModuleFileNameW = int Function(int, Pointer<Utf16>, int);
// ignore: non_constant_identifier_names
final FFITypeGetModuleFileNameW GetModuleFileName = _dllKernel32.lookupFunction<
    _FFITypeGetModuleFileNameW,
    FFITypeGetModuleFileNameW>('GetModuleFileNameW');

// https://learn.microsoft.com/windows/win32/api/winver/nf-winver-verqueryvaluew
typedef _FFITypeVerQueryValueW = BOOL Function(LPCVOID, LPCWSTR, LPVOID, PUINT);
typedef FFITypeVerQueryValueW = int Function(
    Pointer<NativeType>, Pointer<Utf16>, Pointer<NativeType>, Pointer<Uint32>);
// ignore: non_constant_identifier_names
final FFITypeVerQueryValueW VerQueryValue =
    _dllVersion.lookupFunction<_FFITypeVerQueryValueW, FFITypeVerQueryValueW>(
        'VerQueryValueW');

// https://learn.microsoft.com/windows/win32/api/fileapi/nf-fileapi-gettemppathw
typedef _FFITypeGetTempPathW = DWORD Function(DWORD, LPWSTR);
typedef FFITypeGetTempPathW = int Function(int, Pointer<Utf16>);
// ignore: non_constant_identifier_names
final FFITypeGetTempPathW GetTempPath = _dllKernel32
    .lookupFunction<_FFITypeGetTempPathW, FFITypeGetTempPathW>('GetTempPathW');
