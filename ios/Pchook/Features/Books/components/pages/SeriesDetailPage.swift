import SwiftUI

struct SeriesDetailPage: View {
    let seriesId: String
    var refreshTrigger: Int = 0
    var onSelectBook: (String) -> Void = { _ in }
    var onUpdated: () -> Void = {}

    @State private var detail: SeriesDetailData?
    @State private var error: String?
    @State private var isEditing = false
    @State private var showRateSeriesSheet = false

    var body: some View {
        Group {
            if let detail {
                if isEditing {
                    SeriesEditForm(
                        initialName: detail.name,
                        seriesRating: detail.rating,
                        onSave: { newName in
                            try await GraphQLBooksAPI.renameSeries(id: seriesId, name: newName)
                            self.detail = try await GraphQLBooksAPI.getSeriesDetail(id: seriesId)
                            isEditing = false
                            onUpdated()
                        },
                        onCancel: { isEditing = false },
                        onRateSeries: { showRateSeriesSheet = true }
                    )
                } else {
                    SeriesDetailContent(
                        name: detail.name,
                        rating: detail.rating,
                        createdAt: detail.createdAt,
                        volumes: detail.volumes.map {
                            .init(
                                id: $0.id, title: $0.title, label: $0.label,
                                position: $0.position, language: $0.language, rating: $0.rating
                            )
                        },
                        onSelectBook: onSelectBook,
                        onRateSeries: { showRateSeriesSheet = true }
                    )
                    .refreshable { await loadDetail() }
                }
            } else if let error {
                ContentUnavailableView(
                    "Erreur", systemImage: "exclamationmark.triangle",
                    description: Text(error))
            } else {
                ProgressView("Chargement...")
            }
        }
        .navigationTitle(isEditing ? "Modifier la série" : "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if !isEditing, detail != nil {
                ToolbarItemGroup {
                    Menu {
                        Button("Modifier", systemImage: "pencil") {
                            isEditing = true
                        }
                        Button("Noter la série", systemImage: "star") {
                            showRateSeriesSheet = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .task { await loadDetail() }
        .onChange(of: refreshTrigger) { Task { await loadDetail() } }
        .sheet(isPresented: $showRateSeriesSheet) {
            if let detail {
                RateSeriesSheet(
                    seriesId: detail.id,
                    seriesName: detail.name,
                    initialRating: detail.rating
                ) {
                    showRateSeriesSheet = false
                    await loadDetail()
                    onUpdated()
                }
            }
        }
    }

    private func loadDetail() async {
        error = nil
        do {
            detail = try await GraphQLBooksAPI.getSeriesDetail(id: seriesId)
        } catch {
            self.error = reportError(error)
        }
    }
}
