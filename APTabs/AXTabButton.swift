//
//  AXTabButton.swift
//  APTabs
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import AppKit

public protocol AXTabButtonDelegate: AnyObject {
    func tabButtonClicked(_ button: AXTabButton)
    func closeTabButtonClicked(_ button: AXTabButton)
}

public class AXTabButton: NSControl {
    public weak var delegate: AXTabButtonDelegate?
    public var isSelected = false
    public var title: String = "" { didSet { titleLabel.stringValue = title } }
    public var icon: NSImage? { didSet { iconView.image = icon } }
    weak var tabItem: NSTabViewItem?

    private let titleLabel = NSTextField(labelWithString: "")
    private let iconView = NSImageView()
    private let closeButton = NSButton()
    
    var trackingArea: NSTrackingArea!
    private var dragStartPoint: NSPoint?

    public override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
        setupTracking()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        wantsLayer = true
        layer?.masksToBounds = true

        // Configure subviews
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.lineBreakMode = .byTruncatingTail

        iconView.imageScaling = .scaleProportionallyDown

        closeButton.image = NSImage(
            systemSymbolName: "xmark", accessibilityDescription: nil)
        closeButton.isBordered = false
        closeButton.target = self
        closeButton.alphaValue = 0.7
        closeButton.action = #selector(handleClose)

        // Add subviews
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(closeButton)

        // Layout constraints
        translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconView.trailingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: closeButton.leadingAnchor, constant: -6),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            closeButton.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -8),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    internal func setupTracking() {
        self.trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    public override func layout() {
        super.layout()
        
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        setupTracking()
    }

    public override func mouseEntered(with event: NSEvent) {
        if !isSelected {
            self.layer?.backgroundColor =
                NSColor.controlColor.withAlphaComponent(0.6).cgColor
        }
    }

    public override func mouseExited(with event: NSEvent) {
        if !isSelected {
            self.layer?.backgroundColor = .clear
        }
    }

    @objc private func handleClose() {
        delegate?.closeTabButtonClicked(self)
    }

    public override func mouseDown(with event: NSEvent) {
        dragStartPoint = convert(event.locationInWindow, from: nil)
        delegate?.tabButtonClicked(self)
    }
    
    public override func mouseDragged(with event: NSEvent) {
            guard let dragStartPoint = dragStartPoint else { return }
            let currentPoint = convert(event.locationInWindow, from: nil)
            let distance = hypot(currentPoint.x - dragStartPoint.x, currentPoint.y - dragStartPoint.y)
            
            if distance > 3 {
                let pasteboardItem = NSPasteboardItem()
                pasteboardItem.setString(String(self.tag), forType: .string)
                
                if self.tag == -1 {
                    print("NEGATIVE 1111111: \(self.title)")
                }
                
                let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
                draggingItem.setDraggingFrame(self.bounds, contents: self.snapshot())
                
                beginDraggingSession(with: [draggingItem], event: event, source: self)
                self.dragStartPoint = nil
            }
        }

        private func snapshot() -> NSImage {
            return NSImage(data: dataWithPDF(inside: bounds))!
        }
}

extension AXTabButton: NSDraggingSource {
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .move
    }

    public func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        self.isHidden = true
    }

    public func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        self.isHidden = false
    }
}
