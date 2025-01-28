//
//  ViewController.swift
//  APTabs
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import Cocoa

class ViewController: NSViewController, AXTabViewDelegate {
    // MARK: - UI Components
    private let axTabView = AXTabView()
    private let contentTabView = NSTabView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialTab()
    }

    // MARK: - Setup
    private func setupUI() {
        // Configure AXTabView
        axTabView.styler = ChromeTabStyle()  // or SafariTabStyle()
        axTabView.delegate = self

        // Configure content tab view
        contentTabView.tabViewBorderType = .none
        contentTabView.tabViewType = .noTabsNoBorder

        // Add to view hierarchy
        view.addSubview(axTabView)
        view.addSubview(contentTabView)

//        let tab1 = NSTabViewItem(identifier: "Tab 1")
//        tab1.label = "Tab 1"
//        tab1.view = NSView()
//
//        let tab2 = NSTabViewItem(identifier: "Tab 2")
//        tab2.label = "Tab 2"
//        axTabView.tabs = [tab1, tab2]

        // Setup constraints
        setupConstraints()
    }

    private func setupConstraints() {
        axTabView.translatesAutoresizingMaskIntoConstraints = false
        contentTabView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // AXTabView constraints
            axTabView.topAnchor.constraint(equalTo: view.topAnchor),
            axTabView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 90),
            axTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            axTabView.heightAnchor.constraint(equalToConstant: 40),

            // Content TabView constraints
            contentTabView.topAnchor.constraint(
                equalTo: axTabView.bottomAnchor),
            contentTabView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            contentTabView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            contentTabView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupInitialTab() {
        let initialTab = NSTabViewItem(identifier: NSImage(named: NSImage.folderName))
        initialTab.label = "New Tab"
        initialTab.view = createTabContentView()
        //contentTabView.addTabViewItem(initialTab)
        
        
        axTabView.addNewTabItem(item: initialTab)
    }

    // MARK: - Tab Content Creation
    private func createTabContentView() -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = .white
        let label = NSTextField(labelWithString: "Tab Content \(UUID())")
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }

    // MARK: - AXTabViewDelegate
    func didSelectTab(at index: Int) {
//        guard index < contentTabView.numberOfTabViewItems else { return }
//        contentTabView.selectTabViewItem(at: index)
    }

    func didCloseTab(at index: Int) {
//        guard index < contentTabView.numberOfTabViewItems else { return }
//
//        contentTabView.removeTabViewItem(contentTabView.tabViewItems[index])
//
//        // Add new tab if last tab was closed
//        if contentTabView.numberOfTabViewItems == 0 {
//            setupInitialTab()
//        } else {
//            axTabView.reloadTabs()
//        }
    }

    var counter = 0
    func didAddNewTab() {
        let newTab = NSTabViewItem()
        newTab.label = "New Tab \(counter)"
        newTab.view = createTabContentView()
        axTabView.addNewTabItem(item: newTab)
        
        counter += 1
    }
}
