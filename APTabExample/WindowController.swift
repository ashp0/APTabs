//
//  WindowController.swift
//  APTabs
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import AppKit

// MARK: - AXWindow
class AXWindow: NSWindow, NSWindowDelegate {
    internal var trafficLightButtons: [NSButton]!

    init() {
        super.init(
            contentRect: .init(
                origin: .zero, size: .init(width: 500, height: 400)),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
        )

        self.delegate = self
        self.titlebarAppearsTransparent = true
        configureTrafficLights()
    }

    func windowDidResize(_ notification: Notification) {
        trafficLightsPosition()
    }

    // MARK: - Traffic Lights
    func configureTrafficLights() {
        self.trafficLightButtons = [
            self.standardWindowButton(.closeButton)!,
            self.standardWindowButton(.miniaturizeButton)!,
            self.standardWindowButton(.zoomButton)!,
        ]

        trafficLightsPosition()
    }

    func trafficLightsPosition() {
        guard let trafficLightButtons else { return }
        // Update positioning
        for (index, button) in trafficLightButtons.enumerated() {
            button.frame.origin = NSPoint(
                x: 18.0 + CGFloat(index) * 20.0, y: -0.9)

            button.alphaValue = 1
        }
    }
}
