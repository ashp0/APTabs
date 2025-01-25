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

    public var tabs: [NSTabViewItem] = []
    public var selectedTabIndex: Int = 0

    let stackView = NSStackView()
    private let addButton = NSButton()

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

        // Layout constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false

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

        updateStyle()
    }

    public func reloadTabs(animated: Bool = true) {
        // Remove existing buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Create new buttons
        tabs.enumerated().forEach { index, tabItem in
            let button = styler.createsButton(
                isSelected: index == selectedTabIndex, animated: animated)
            button.delegate = self
            button.tag = index
            button.title = tabItem.label
            button.icon = tabItem.identifier as? NSImage

            // Apply max width constraint if needed
            if let maxWidth = styler.maxTabWidth {
                button.widthAnchor.constraint(
                    lessThanOrEqualToConstant: maxWidth
                ).isActive = true
            }

            stackView.addArrangedSubview(button)
        }

        // Update stack view layout
        stackView.spacing = styler.tabButtonSpacing
        stackView.distribution = styler.tabDistribution
        stackView.edgeInsets = styler.contentInsets

        // Deselect other buttons
        stackView.arrangedSubviews.compactMap { $0 as? AXTabButton }.forEach {
            $0.isSelected = false
        }
    }

    @objc private func handleAddButton() {
        delegate?.didAddNewTab()
    }

    private func updateStyle() {
        styler.layoutTabView(self)
        reloadTabs(animated: false)
    }
}

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
        reloadTabs()
    }
}
