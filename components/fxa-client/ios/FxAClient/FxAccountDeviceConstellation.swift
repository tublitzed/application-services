/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import os

public protocol DeviceConstellationProtocol {
    // Get local + remote devices.
    func state() -> ConstellationState?
    // Refresh the list of remote devices.
    func refreshState()
    // Observe changes to the list of devices.
    func registerDeviceObserver(observer: DeviceConstellationObserver)

    func setLocalDeviceName(name: String)

    // Poll for events we might have missed (e.g. no push notification)
    func pollForEvents()
    // Send an event to another device such as Send Tab.
    func sendEventToDevice(targetDeviceId: String, e: DeviceEventOutgoing)

    // Register our push subscription with the FxA server.
    func setDevicePushSubscription(sub: DevicePushSubscription)
    // Used by Push when receiving a message: will call DeviceEventsObserver.onEvents.
    func processRawIncomingDeviceEvent(pushPayload: String)
}

public protocol DeviceConstellationObserver: class {
    func onStateUpdate(newState: ConstellationState)
}

public protocol DeviceEventsObserver: class {
    func onEvents(events: [DeviceEvent])
}

public struct ConstellationState {
    public let localDevice: Device?
    public let remoteDevices: [Device]
}

public class DeviceConstellation: DeviceConstellationProtocol {
    var constellationState: ConstellationState?
    let account: FirefoxAccount
    weak var observer: DeviceConstellationObserver?
    weak var eventObserver: DeviceEventsObserver?

    required init(account: FirefoxAccount) {
        self.account = account
    }

    public func state() -> ConstellationState? {
        return constellationState
    }

    public func refreshState() {
        fxaQueue.async {
            os_log("Refreshing device list...")
            do {
                let devices = try self.account.fetchDevicesSync()
                let localDevice = devices.first { $0.isCurrentDevice }
                if localDevice?.subscriptionExpired ?? false {
                    os_log("Current device needs push endpoint registration.")
                }
                let remoteDevices = devices.filter { !$0.isCurrentDevice }

                let newState = ConstellationState(localDevice: localDevice, remoteDevices: remoteDevices)
                self.constellationState = newState

                log("Refreshed device list; saw \(devices.count) device(s).")

                if let obs = self.observer {
                    DispatchQueue.main.async { obs.onStateUpdate(newState: newState) }
                }
            } catch {
                log("Failure fetching the device list: \(error).")
                return
            }
        }
    }

    func initDevice(name: String, type: DeviceType, capabilities: [DeviceCapability]) {
        // This is already wrapped in a `fxaQueue.async`, no need to re-wrap.
        do {
            try account.initializeDeviceSync(name: name, deviceType: type, supportedCapabilities: capabilities)
        } catch {
            log("Failure initializing device: \(error).")
        }
    }

    func ensureCapabilities(capabilities: [DeviceCapability]) {
        // This is already wrapped in a `fxaQueue.async`, no need to re-wrap.
        do {
            try account.ensureCapabilitiesSync(supportedCapabilities: capabilities)
        } catch {
            log("Failure ensuring device capabilities: \(error).")
        }
    }

    public func setLocalDeviceName(name: String) {
        fxaQueue.async {
            do {
                try self.account.setDeviceDisplayNameSync(name)
            } catch {
                log("Failure changing the local device name: \(error).")
            }
            self.refreshState()
        }
    }

    public func pollForEvents() {
        fxaQueue.async {
            do {
                let events = try self.account.pollDeviceCommandsSync()
                self.processEvents(events)
            } catch {
                log("Failure polling device events: \(error).")
            }
        }
    }

    internal func processEvents(_ events: [DeviceEvent]) {
        eventObserver?.onEvents(events: events)
    }

    public func sendEventToDevice(targetDeviceId: String, e: DeviceEventOutgoing) {
        fxaQueue.async {
            do {
                switch e {
                case let .sendTab(title, url): do {
                    try self.account.sendSingleTabSync(targetId: targetDeviceId, title: title, url: url)
                }
                }
            } catch {
                log("Error sending event to another device: \(error).")
            }
        }
    }

    public func setDevicePushSubscription(sub: DevicePushSubscription) {
        // No need to wrap in async, this operation doesn't do any IO or heavy processing.
        do {
            try account.setDevicePushSubscriptionSync(endpoint: sub.endpoint, publicKey: sub.publicKey, authKey: sub.authKey)
        } catch {
            log("Failure setting push subscription: \(error).")
        }
    }

    public func processRawIncomingDeviceEvent(pushPayload: String) {
        fxaQueue.async {
            do {
                let events = try self.account.handlePushMessageSync(payload: pushPayload)
                self.processEvents(events)
            } catch {
                log("Failure processing push event: \(error).")
            }
        }
    }

    public func registerDeviceObserver(observer: DeviceConstellationObserver) {
        self.observer = observer
    }

    internal func registerDeviceEventsObserver(observer: DeviceEventsObserver) {
        eventObserver = observer
    }
}

public enum DeviceEventOutgoing {
    case sendTab(title: String, url: String)
}
