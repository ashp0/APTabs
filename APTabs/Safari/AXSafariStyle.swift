//
//  AXSafariStyle.swift
//  APTabs
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import AppKit

//public final class SafariTabStyle: AXTabStyler {
//    public func createsButton(isSelected: Bool, animated: Bool) -> AXTabButton {
//
//        let button = SafariTabButton()
//        button.isSelected = isSelected
//
//        return button
//    }
//
//    public func layoutTabView(_ tabView: AXTabView) {
//        tabView.stackView.spacing = 0
//        tabView.layer?.cornerRadius = 8
//    }
//
//    public let tabButtonSpacing: CGFloat = 0
//    public let contentInsets = NSEdgeInsets(
//        top: 4, left: 4, bottom: 4, right: 4)
//    public let tabDistribution: NSStackView.Distribution = .fillEqually
//    public var maxTabWidth: CGFloat? { nil }
//}
//
//public final class SafariTabButton: AXTabButton {
//    public override init(frame: NSRect) {
//        super.init(frame: frame)
//        configureStyle()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func configureStyle() {
//        layer?.cornerRadius = 0
//        self.heightAnchor.constraint(equalToConstant: 28).isActive = true
//        updateAppearance()
//    }
//
//    public override var isSelected: Bool {
//        didSet { updateAppearance() }
//    }
//
//    private func updateAppearance() {
//        layer?.borderWidth = isSelected ? 1 : 0
//        layer?.borderColor = NSColor.systemGray.cgColor
//        layer?.backgroundColor =
//            (isSelected ? NSColor.systemGray.withAlphaComponent(0.15) : .clear)
//            .cgColor
//    }
//}
