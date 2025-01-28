//
//  AXTabView.swift
//  APTabs
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import AppKit

public protocol AXTabViewDelegate: AnyObject {
    func didSelectTab(at index: Int)
    func didCloseTab(at index: Int)
    func didAddNewTab()
}

public final class AXTabView: NSView {
    public weak var delegate: AXTabViewDelegate?

    public var styler: AXTabStyler = ChromeTabStyle() {
        didSet { updateStyle() }
    }

    private var numberOfTabItems: Int = -1
    private var separatorLeadingConstraint: NSLayoutConstraint?

    /// Directly modifying this value is not recommended.
    private var tabs: [NSTabViewItem] = []

    public var selectedTabIndex: Int = 0

    let stackView = NSStackView()
    private let addButton = NSButton()

    private let separatorView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemBlue.cgColor
        view.isHidden = true
        return view
    }()

    public override init(frame: NSRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        registerForDraggedTypes([.string])

        // Configure stack view
        stackView.orientation = .horizontal
        stackView.alignment = .bottom

        // Configure add button
        addButton.image = NSImage(
            systemSymbolName: "plus", accessibilityDescription: nil)
        addButton.bezelStyle = .texturedRounded
        addButton.target = self
        addButton.action = #selector(handleAddButton)

        // Add subviews
        addSubview(stackView)
        addSubview(addButton)
        addSubview(separatorView)

        // Layout constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            addButton.leadingAnchor.constraint(
                equalTo: stackView.trailingAnchor, constant: 4),
            addButton.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -4),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        // Set up separator constraints
        separatorLeadingConstraint = separatorView.leadingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            separatorView.widthAnchor.constraint(equalToConstant: 2),
            separatorView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 4),
            separatorView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -4),
            separatorLeadingConstraint!
        ])

        updateStyle()
    }

    // Inserts a new tab
    public func addNewTabItem(item: NSTabViewItem) {
        self.tabs.append(item)
        numberOfTabItems += 1

        if numberOfTabItems > 0 {
            if let button = stackView.arrangedSubviews[selectedTabIndex]
                as? AXTabButton
            {
                button.isSelected = false
            }
        }

        selectedTabIndex += 1
        internal_stackViewAddButton(isSelected: true, item: item)
    }

    // Inserts a new tab
    public func removeTabItem(item: NSTabViewItem) {
        guard let index = tabs.firstIndex(of: item) else { return }

        // Remove the tab
        tabs.remove(at: index)
        numberOfTabItems -= 1

        // Update selected tab index
        if numberOfTabItems > 0 {
            if selectedTabIndex == index {
                selectedTabIndex = max(0, index - 1)
            } else if selectedTabIndex > index {
                selectedTabIndex -= 1
            }
        } else {
            selectedTabIndex = 0
        }

        // Notify delegate
        delegate?.didCloseTab(at: index)

        // Reload tabs
        reloadTabs()
    }

    public func reloadTabs(animated: Bool = true, customSelectedIndex: Int = -1) {
        // Remove existing buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Redraw buttons
        selectedTabIndex = -1
        numberOfTabItems = -1
        tabs.enumerated().forEach { index, tabItem in
            selectedTabIndex += 1
            numberOfTabItems += 1
            internal_stackViewAddButton(
                isSelected: false, item: tabItem)
        }
        
        if numberOfTabItems > 0 {
            if customSelectedIndex != -1 {
                selectedTabIndex = customSelectedIndex
            }
            (stackView.arrangedSubviews[selectedTabIndex] as? AXTabButton)?.isSelected = true
        }

        // Update stack view layout
        stackView.spacing = styler.tabButtonSpacing
        stackView.distribution = styler.tabDistribution
        stackView.edgeInsets = styler.contentInsets
    }

    @objc private func handleAddButton() {
        delegate?.didAddNewTab()
    }

    private func updateStyle() {
        styler.layoutTabView(self)
        reloadTabs(animated: false)
    }
}

// MARK: - Private Functions
extension AXTabView {
    @inline(__always)
    private func internal_stackViewAddButton(
        isSelected: Bool = true, item: NSTabViewItem
    ) {
        let button = styler.createsButton(isSelected: isSelected)
        button.delegate = self
        button.tag = selectedTabIndex
        button.title = item.label
        button.icon = item.identifier as? NSImage
        button.tabItem = item

        // Apply max width constraint if needed
        if let maxWidth = styler.maxTabWidth {
            button.widthAnchor.constraint(
                lessThanOrEqualToConstant: maxWidth
            ).isActive = true
        }

        stackView.addArrangedSubview(button)
    }
}

// MARK: - Tab Button Delegate
extension AXTabView: AXTabButtonDelegate {
    public func tabButtonClicked(_ button: AXTabButton) {
        //   guard let contentView = contentView else { return }
        let index = button.tag

        // Update content view selection
        //  contentView.selectTabViewItem(at: index)

        // Update button states
        stackView.arrangedSubviews.compactMap { $0 as? AXTabButton }.forEach {
            $0.isSelected = $0.tag == index
        }

        delegate?.didSelectTab(at: index)
    }

    public func closeTabButtonClicked(_ button: AXTabButton) {
        //        guard let contentView = contentView else { return }
        let index = button.tag

        // Remove from content view
        //        contentView.removeTabViewItem(contentView.tabViewItems[index])

        // Notify delegate and reload
        delegate?.didCloseTab(at: index)
    }
}

extension AXTabView {
    public override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return updateSeparatorPosition(sender)
    }

    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        separatorView.isHidden = true
        guard
            let pasteboardItem = sender.draggingPasteboard.pasteboardItems?.first,
            let indexString = pasteboardItem.string(forType: .string),
            let sourceIndex = Int(indexString)
        else { return false }
        
        let location = sender.draggingLocation
        let localLocation = convert(location, from: nil)
        let targetIndex = insertionIndexForDrag(at: localLocation)
        
        var adjustedTarget = targetIndex
        if sourceIndex < adjustedTarget {
            adjustedTarget -= 1
        }
        
        let tab = tabs.remove(at: sourceIndex)
        tabs.insert(tab, at: adjustedTarget)
        
        // Update selected index
        if selectedTabIndex == sourceIndex {
            selectedTabIndex = adjustedTarget
        } else {
            if selectedTabIndex > sourceIndex && selectedTabIndex <= adjustedTarget {
                selectedTabIndex -= 1
            } else if selectedTabIndex < sourceIndex && selectedTabIndex >= adjustedTarget {
                selectedTabIndex += 1
            }
        }
  
        reloadTabs(customSelectedIndex: selectedTabIndex)
        return true
    }
    
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        separatorView.isHidden = false
        return updateSeparatorPosition(sender)
    }
    
    public override func draggingExited(_ sender: NSDraggingInfo?) {
        separatorView.isHidden = true
    }

    private func updateSeparatorPosition(_ sender: NSDraggingInfo) -> NSDragOperation {
        let location = convert(sender.draggingLocation, from: nil)
        let stackViewFrameInSelf = stackView.convert(stackView.bounds, to: self)
        
        // Clamp the cursor's x to the stackView's bounds
        let clampedX = min(max(location.x, stackViewFrameInSelf.minX), stackViewFrameInSelf.maxX)
        
        // Update separator position to clamped cursor x
        separatorLeadingConstraint?.constant = clampedX
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0 // Update immediately without animation
            self.layoutSubtreeIfNeeded()
        }
        
        return .move
    }

    private func insertionIndexForDrag(at point: NSPoint) -> Int {
        let stackPoint = stackView.convert(point, from: self)
        var currentX: CGFloat = 0
        
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            let viewWidth = view.frame.width
            let nextSpacing = (index < stackView.arrangedSubviews.count - 1) ? stackView.spacing : 0
            
            // Check if cursor is within the current tab's bounds (including spacing)
            if stackPoint.x < currentX + viewWidth + nextSpacing {
                return index
            }
            
            currentX += viewWidth + stackView.spacing
        }
        
        return stackView.arrangedSubviews.count
    }
}
