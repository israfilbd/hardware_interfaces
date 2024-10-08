/*
 * Copyright (C) 2020 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
///////////////////////////////////////////////////////////////////////////////
// THIS FILE IS IMMUTABLE. DO NOT EDIT IN ANY CASE.                          //
///////////////////////////////////////////////////////////////////////////////

// This file is a snapshot of an AIDL file. Do not edit it manually. There are
// two cases:
// 1). this is a frozen version file - do not edit this in any case.
// 2). this is a 'current' file. If you make a backwards compatible change to
//     the interface (from the latest frozen version), the build system will
//     prompt you to update this file with `m <name>-update-api`.
//
// You must not make a backward incompatible change to any AIDL file built
// with the aidl_interface module type with versions property set. The module
// type is used to build AIDL files in a way that they can be used across
// independently updatable components of the system. If a device is shipped
// with such a backward incompatible change, it has a high risk of breaking
// later when a module using the interface is updated, e.g., Mainline modules.

package android.hardware.biometrics.fingerprint;
/* @hide */
@VintfStability
interface ISession {
  void generateChallenge();
  void revokeChallenge(in long challenge);
  android.hardware.biometrics.common.ICancellationSignal enroll(in android.hardware.keymaster.HardwareAuthToken hat);
  android.hardware.biometrics.common.ICancellationSignal authenticate(in long operationId);
  android.hardware.biometrics.common.ICancellationSignal detectInteraction();
  void enumerateEnrollments();
  void removeEnrollments(in int[] enrollmentIds);
  void getAuthenticatorId();
  void invalidateAuthenticatorId();
  void resetLockout(in android.hardware.keymaster.HardwareAuthToken hat);
  void close();
  /**
   * @deprecated use onPointerDownWithContext instead.
   */
  void onPointerDown(in int pointerId, in int x, in int y, in float minor, in float major);
  /**
   * @deprecated use onPointerUpWithContext instead.
   */
  void onPointerUp(in int pointerId);
  void onUiReady();
  android.hardware.biometrics.common.ICancellationSignal authenticateWithContext(in long operationId, in android.hardware.biometrics.common.OperationContext context);
  android.hardware.biometrics.common.ICancellationSignal enrollWithContext(in android.hardware.keymaster.HardwareAuthToken hat, in android.hardware.biometrics.common.OperationContext context);
  android.hardware.biometrics.common.ICancellationSignal detectInteractionWithContext(in android.hardware.biometrics.common.OperationContext context);
  void onPointerDownWithContext(in android.hardware.biometrics.fingerprint.PointerContext context);
  void onPointerUpWithContext(in android.hardware.biometrics.fingerprint.PointerContext context);
  void onContextChanged(in android.hardware.biometrics.common.OperationContext context);
  void onPointerCancelWithContext(in android.hardware.biometrics.fingerprint.PointerContext context);
  /**
   * @deprecated use isHardwareIgnoringTouches in OperationContext from onContextChanged instead
   */
  void setIgnoreDisplayTouches(in boolean shouldIgnore);
}
