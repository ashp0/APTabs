//
//  AXChromeStyle.swift
//  APTabs
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import AppKit
import Cocoa

public final class ChromeTabStyle: AXTabStyler {
    public func createsButton(isSelected: Bool) -> AXTabButton {

        let button = ChromeTabButton()
        button.isSelected = isSelected

        return button
    }

    public func layoutTabView(_ tabView: AXTabView) {
        tabView.stackView.spacing = 1
        tabView.stackView.edgeInsets = contentInsets
    }

    public let tabButtonSpacing: CGFloat = 1
    public let contentInsets = NSEdgeInsets(
        top: 4, left: 0, bottom: 0, right: 0)
    public let tabDistribution: NSStackView.Distribution = .gravityAreas
    public var maxTabWidth: CGFloat? { 200 }
}

public final class ChromeTabButton: AXTabButton {
    private var borderLayer: CAShapeLayer?

    public override init(frame: NSRect) {
        super.init(frame: frame)
        configureStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureStyle() {
        wantsLayer = true
        self.heightAnchor.constraint(equalToConstant: 36).isActive = true

        updateAppearance()
    }

    public override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    private func updateAppearance() {
        // Update the background color based on the selection state
        layer?.backgroundColor =
            (isSelected ? NSColor.controlBackgroundColor : NSColor.clear)
            .cgColor

        // Handle the border layer
        if isSelected {
            if borderLayer == nil {
                borderLayer = CAShapeLayer()
                borderLayer?.strokeColor = NSColor.controlAccentColor.cgColor
                borderLayer?.fillColor = NSColor.clear.cgColor
                borderLayer?.lineWidth = 1.0
                layer?.addSublayer(borderLayer!)
            }
            updateBorderPath()
        } else {
            borderLayer?.removeFromSuperlayer()
            borderLayer = nil
        }
    }

    private func updateBorderPath() {
        guard let borderLayer = borderLayer else { return }
        let path = CGMutablePath()
        let bounds = self.bounds

        // Start at the bottom-left corner
        path.move(to: CGPoint(x: 0, y: bounds.height))

        // Bottom left
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        // Top
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        
        // Bottom right
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))

        borderLayer.path = path
    }

    public override func layout() {
        super.layout()
        // Ensure the border path is updated when the layout changes
        updateBorderPath()
    }

    public override var isFlipped: Bool {
        return true
    }
}
