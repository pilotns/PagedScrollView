//
//  PagedScrollView.swift
//  PagedScrollView
//
//  Created by pilotns on 08.05.2023.
//

import SwiftUI

struct PagedScrollView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            _UIScrollViewWrapper(content: content)
                .environment(\.parentSize, geometry.size)
        }
    }
}

private struct _UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    let content: () -> Content
    
    init(content: @escaping () -> Content) {
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> PagedViewController {
        let controller = PagedViewController()
        let hostingController = controller.hostingController
        
        hostingController.rootView = AnyView(self.content())
        let contentSize = controller.hostingController.sizeThatFits(
            in: context.environment.parentSize
        )
        
        hostingController.view.frame.size = contentSize
        controller.scrollView.addSubview(hostingController.view)
        
        makeConstraints(
            of: hostingController.view,
            to: controller.scrollView
        )
        
        return controller
    }
    
    func updateUIViewController(_ controller: PagedViewController, context: Context) {
        let hostingController = controller.hostingController

        hostingController.rootView = AnyView(self.content())
        let contentSize = controller.hostingController.sizeThatFits(
            in: context.environment.parentSize
        )
        
        hostingController.view.frame.size = contentSize
    }
}

extension _UIScrollViewWrapper {
    func makeConstraints(of child: UIView, to parent: UIScrollView) {
        parent.translatesAutoresizingMaskIntoConstraints = false
        child.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            child.safeAreaLayoutGuide.topAnchor.constraint(equalTo: parent.contentLayoutGuide.topAnchor),
            child.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: parent.contentLayoutGuide.bottomAnchor),
            child.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: parent.contentLayoutGuide.trailingAnchor),
            child.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: parent.contentLayoutGuide.leadingAnchor),
            child.safeAreaLayoutGuide.widthAnchor.constraint(equalTo: parent.frameLayoutGuide.widthAnchor)
        ])
    }
}

extension _UIScrollViewWrapper {
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
                scrollView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                scrollView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
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
