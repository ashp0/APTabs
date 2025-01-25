//
//  AXTabStyler.swift
//  APTabs
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import Cocoa

public protocol AXTabStyler: AnyObject {
    func createsButton(isSelected: Bool, animated: Bool) -> AXTabButton
    func layoutTabView(_ tabView: AXTabView)
    var tabButtonSpacing: CGFloat { get }
    var contentInsets: NSEdgeInsets { get }
    var tabDistribution: NSStackView.Distribution { get }
    var maxTabWidth: CGFloat? { get }
}
