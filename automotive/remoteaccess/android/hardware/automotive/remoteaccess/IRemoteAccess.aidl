/*
 * Copyright (C) 2022 The Android Open Source Project
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

package android.hardware.automotive.remoteaccess;

import android.hardware.automotive.remoteaccess.ApState;
import android.hardware.automotive.remoteaccess.IRemoteTaskCallback;
import android.hardware.automotive.remoteaccess.ScheduleInfo;
import android.hardware.automotive.remoteaccess.TaskType;

/**
 * The remote access HAL.
 *
 * <p>This HAL represents an external system that is always on even when Android
 * is powered off. It is capable of wakeing up and notifying Android when a
 * remote task arrives.
 *
 * <p>For cloud-based remote access, a cloud server will issue the remote task
 * to the external system, which will then be forwarded to Android. The client
 * is expected to call {@code setRemoteTaskCallback} to register the remote
 * task callback and uses the information returned from {@code getVehicleId},
 * {@code getWakeupServiceName} and {@code getProcessorId} to register with
 * a remote server.
 *
 * <p>For serverless remote access, the remote task comes from the external
 * system alone and no server is involved. The external system may support
 * scheduling a remote task to executed later through {@code scheduleTask}.
 *
 * <p>For both cloud-based and serverless remote access, the ideal use case
 * is to wake up Android when the vehicle is not in use and then shutdown
 * Android after the task is complete. However, user may access the vehicle
 * during this period, and Android must not be shutdown if this happens.
 *
 * <p>If this interface is implemented, then VHAL property
 * {@code VEHICLE_IN_USE} must be supported to represent whether the vehicle is
 * currently in use. Android will check this before sending the shutdown
 * request.
 *
 * <p>The external power controller system must also check whether vehicle is
 * in use upon receiving the shutdown request and makes sure that an
 * user-unexpected shutdown must not happen.
 */
@VintfStability
interface IRemoteAccess {
    /**
     * Gets a unique vehicle ID that could be recognized by wake up server.
     *
     * <p>This vehicle ID is provisioned during car production and is registered
     * with the wake up server.
     *
     * @return a unique vehicle ID.
     */
    String getVehicleId();

    /**
     * Gets the name for the remote wakeup server.
     *
     * <p>This name will be provided to remote task server during registration
     * and used by remote task server to find the remote wakeup server to
     * use for waking up the device. This name must be pre-negotiated between
     * the remote wakeup server/client and the remote task server/client and
     * must be unique. We recommend the format to be a human readable string
     * with reverse domain name notation (reverse-DNS), e.g.
     * "com.google.vehicle.wakeup".
     */
    String getWakeupServiceName();

    /**
     * Gets a unique processor ID that could be recognized by wake up client.
     *
     * <p>This processor ID is used to identify each processor in the vehicle.
     * The wake up client which handles many processors determines which
     * processor to wake up from the processor ID.
     *
     * <p> The processor ID must be unique in the vehicle.
     */
    String getProcessorId();

    /**
     * Sets a callback to be called when a remote task is requested.
     *
     * @param callback A callback to be called when a remote task is requested.
     */
    void setRemoteTaskCallback(IRemoteTaskCallback callback);

    /**
     * Clears a previously set remote task callback.
     *
     * If no callback was set, this operation is no-op.
     */
    void clearRemoteTaskCallback();

    /**
     * Notifies whether AP is ready to receive remote tasks.
     *
     * <p>Wakeup client should store and use this state until a new call with a
     * different state arrives.
     *
     * <p>If {@code isReadyForRemoteTask} is true, the wakeup client may send
     * the task received from the server to AP immediately.
     *
     * <p>If {@code isReadyForRemoteTask} is false, it must store the received
     * remote tasks and wait until AP is ready to receive tasks. If it takes too
     * long for AP to become ready, the task must be reported to remote task
     * server as failed. Implementation must make sure no duplicate tasks are
     * delivered to AP.
     *
     * <p>If {@code isWakeupRequired} is true, it must try to wake up AP when a
     * remote task arrives or when there are pending requests.
     *
     * <p>If {@code isWakeupRequired} is false, it must not try to wake up AP.
     */
    void notifyApStateChange(in ApState state);

    /**
     * Returns whether task scheduling is supported.
     *
     * <p>If this returns {@code true}, user may use {@link scheduleTask} to schedule a task to be
     * executed at a later time. If the device is off when the task is scheduled to be executed,
     * the device will be woken up to execute the task.
     *
     * @return {@code true} if serverless remote task scheduling is supported.
     */
    boolean isTaskScheduleSupported();

    /**
     * Returns the supported task types for scheduling.
     *
     * <p>If task scheduling is not supported, this returns an empty array.
     *
     * <p>Otherwise, at least {@code TaskType.CUSTOM} must be supported.
     *
     * @return An array of supported task types.
     */
    TaskType[] getSupportedTaskTypesForScheduling();

    /**
     * Schedules a task to be executed later even when the vehicle is off.
     *
     * <p>If {@link isTaskScheduleSupported} returns {@code false}. This is no-op.
     *
     * <p>This sends a scheduled task message to a device external to Android so that the device
     * can wake up Android and deliver the task through {@link IRemoteTaskCallback}.
     *
     * <p>Note that the scheduled task execution is on a best-effort basis. Multiple situations
     * might cause the task not to execute successfully:
     *
     * <ul>
     * <li>The vehicle is low on battery and the other device decides not to wake up Android.
     * <li>User turns off vehicle while the task is executing.
     * <li>The task logic itself fails.
     *
     * <p>Must return {@code EX_ILLEGAL_ARGUMENT} if a pending schedule with the same
     * {@code scheduleId} for this client exists.
     *
     * <p>Must return {@code EX_ILLEGAL_ARGUMENT} if the task type is not supported.
     *
     * <p>Must return {@code EX_ILLEGLA_ARGUMENT} if the scheduleInfo is not valid (e.g. count is
     * a negative number).
     */
    void scheduleTask(in ScheduleInfo scheduleInfo);

    /**
     * Unschedules a scheduled task.
     *
     * <p>If {@link isTaskScheduleSupported} returns {@code false}. This is no-op.
     *
     * <p>Does nothing if a pending schedule with {@code clientId} and {@code scheduleId} does not
     * exist.
     */
    void unscheduleTask(String clientId, String scheduleId);

    /**
     * Unschedules all scheduled tasks for the client.
     *
     * <p>If {@link isTaskScheduleSupported} returns {@code false}. This is no-op.
     */
    void unscheduleAllTasks(String clientId);

    /**
     * Returns whether the specified task is scheduled.
     *
     * <p>If {@link isTaskScheduleSupported} returns {@code false}, This must return {@code false}.
     */
    boolean isTaskScheduled(String clientId, String scheduleId);

    /**
     * Gets all pending scheduled tasks for the client.
     *
     * <p>If {@link isTaskScheduleSupported} returns {@code false}. This must return empty array.
     *
     * <p>The finished scheduled tasks will not be included.
     */
    List<ScheduleInfo> getAllPendingScheduledTasks(String clientId);
}
