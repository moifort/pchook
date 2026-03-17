import SwiftUI
import UIKit
import UniformTypeIdentifiers

@objc(ShareViewController)
class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = item.attachments, !attachments.isEmpty
        else {
            close()
            return
        }

        // Essayer d'abord les URLs
        if let urlProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, _ in
                guard let url = item as? URL else {
                    Task { @MainActor in self?.close() }
                    return
                }

                Task { @MainActor in
                    self?.showShareView(url: url)
                }
            }
        }
        // Sinon, essayer le texte
        else if let textProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) {
            textProvider.loadItem(forTypeIdentifier: UTType.text.identifier) { [weak self] item, _ in
                guard let text = item as? String, let url = URL(string: text) else {
                    Task { @MainActor in self?.close() }
                    return
                }

                Task { @MainActor in
                    self?.showShareView(url: url)
                }
            }
        }
        else {
            close()
        }
    }

    @MainActor
    private func showShareView(url: URL) {
        let viewModel = ShareViewModel(url: url) { [weak self] in
            self?.close()
        }

        let shareView = ShareView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: shareView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
