//
//  PagedScrollView.swift
//  PagedScrollView
//
//  Created by pilotns on 08.05.2023.
//

import SwiftUI

struct PagedScrollView<Content: View>: View {
    let axis: Axis
    let content: (CGSize) -> Content
    
    init(
        _ axis: Axis = .vertical,
        @ViewBuilder content: @escaping (CGSize) -> Content
    ) {
        self.axis = axis
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            _UIScrollViewWrapper(
                axis: axis,
                content: content(geometry.size)
            )
            .environment(\.parentSize, geometry.size)
        }
    }
}

private extension PagedScrollView {
    struct _UIScrollViewWrapper: UIViewControllerRepresentable {
        let axis: Axis
        let content: Content
        
        init(axis: Axis, content: Content) {
            self.axis = axis
            self.content = content
        }
        
        func makeUIViewController(context: Context) -> PagedViewController {
            let controller = PagedViewController()
            let scrollView = controller.scrollView
            let hostingController = controller.hostingController
            
            scrollView.addSubview(hostingController.view)
            
            makeConstraints(
                of: hostingController.view,
                to: scrollView
            )
            
            return controller
        }
        
        func updateUIViewController(_ controller: PagedViewController, context: Context) {
            controller.hostingController.rootView = AnyView(
                self.layout
            )
        }
        
        @ViewBuilder
        private var layout: some View {
            switch axis {
            case .horizontal:
                LazyHStack(spacing: 0) {
                    self.content
                }
                
            case .vertical:
                LazyVStack(spacing: 0) {
                    self.content
                }
            }
        }
    }
}

private extension PagedScrollView._UIScrollViewWrapper {
    func makeConstraints(of child: UIView, to parent: UIScrollView) {
        parent.translatesAutoresizingMaskIntoConstraints = false
        child.translatesAutoresizingMaskIntoConstraints = false
        
        let axisSpecificConstraint: NSLayoutConstraint
        
        switch axis {
        case .horizontal:
            axisSpecificConstraint = child.safeAreaLayoutGuide.heightAnchor
                .constraint(equalTo: parent.frameLayoutGuide.heightAnchor)
        case .vertical:
            axisSpecificConstraint = child.safeAreaLayoutGuide.widthAnchor
                .constraint(equalTo: parent.frameLayoutGuide.widthAnchor)
        }
        
        NSLayoutConstraint.activate([
            child.safeAreaLayoutGuide.topAnchor
                .constraint(equalTo: parent.contentLayoutGuide.topAnchor),
            child.safeAreaLayoutGuide.bottomAnchor
                .constraint(equalTo: parent.contentLayoutGuide.bottomAnchor),
            child.safeAreaLayoutGuide.trailingAnchor
                .constraint(equalTo: parent.contentLayoutGuide.trailingAnchor),
            child.safeAreaLayoutGuide.leadingAnchor
                .constraint(equalTo: parent.contentLayoutGuide.leadingAnchor),
            axisSpecificConstraint
        ])
    }
}

private extension PagedScrollView._UIScrollViewWrapper {
    class PagedViewController: UIViewController {
        lazy var scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            
            scrollView.isPagingEnabled = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.contentInsetAdjustmentBehavior = .never
            
            return scrollView
        }()
        
        let hostingController = UIHostingController(
            rootView: AnyView(EmptyView())
        )
        
        override func viewDidLoad() {
            super.viewDidLoad()
            prepareScrollView()
        }
        
        private func prepareScrollView() {
            self.view.addSubview(scrollView)
        
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
    }
}

private enum ParentContainerSizeKey: EnvironmentKey {
    static var defaultValue: CGSize = .zero
}

private extension EnvironmentValues {
    var parentSize: CGSize {
        get { self[ParentContainerSizeKey.self] }
        set { self[ParentContainerSizeKey.self]  = newValue }
    }
}
