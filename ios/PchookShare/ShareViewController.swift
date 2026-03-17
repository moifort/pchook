import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = item.attachments, !attachments.isEmpty
        else {
            close()
            return
        }

        let description = item.attributedContentText?.string
        let attachmentTypes = attachments.compactMap(\.registeredTypeIdentifiers.first)

        print("[PchookShare] Description: \(description ?? "nil")")
        print("[PchookShare] Attachment types: \(attachmentTypes)")

        if let urlProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, _ in
                guard let url = item as? URL else {
                    Task { @MainActor in self?.close() }
                    return
                }
                print("[PchookShare] URL: \(url)")
                self?.loadRawText(from: attachments) { rawText in
                    print("[PchookShare] Raw text: \(rawText ?? "nil")")
                    Task { @MainActor in
                        self?.showShareView(
                            url: url,
                            description: description,
                            rawText: rawText,
                            attachmentTypes: attachmentTypes
                        )
                    }
                }
            }
        } else if let textProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) {
            textProvider.loadItem(forTypeIdentifier: UTType.text.identifier) { [weak self] item, _ in
                guard let text = item as? String, let url = URL(string: text) else {
                    Task { @MainActor in self?.close() }
                    return
                }
                print("[PchookShare] URL (from text): \(url)")
                Task { @MainActor in
                    self?.showShareView(
                        url: url,
                        description: description,
                        rawText: text,
                        attachmentTypes: attachmentTypes
                    )
                }
            }
        } else {
            close()
        }
    }

    private func loadRawText(from attachments: [NSItemProvider], completion: @escaping (String?) -> Void) {
        guard let textProvider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.text.identifier) }) else {
            completion(nil)
            return
        }
        textProvider.loadItem(forTypeIdentifier: UTType.text.identifier) { item, _ in
            completion(item as? String)
        }
    }

    @MainActor
    private func showShareView(url: URL, description: String?, rawText: String?, attachmentTypes: [String]) {
        let viewModel = ShareViewModel(
            url: url,
            description: description,
            rawText: rawText,
            attachmentTypes: attachmentTypes
        ) { [weak self] in
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
