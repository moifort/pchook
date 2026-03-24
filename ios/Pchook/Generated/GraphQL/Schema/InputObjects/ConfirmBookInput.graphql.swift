// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Données pour confirmer et créer un livre depuis un scan
  struct ConfirmBookInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      authors: GraphQLNullable<[String]> = nil,
      estimatedPrice: GraphQLNullable<Double> = nil,
      format: GraphQLNullable<String> = nil,
      genre: GraphQLNullable<String> = nil,
      language: GraphQLNullable<String> = nil,
      pageCount: GraphQLNullable<Int> = nil,
      previewId: String,
      publisher: GraphQLNullable<String> = nil,
      replaceBookId: GraphQLNullable<String> = nil,
      series: GraphQLNullable<String> = nil,
      seriesLabel: GraphQLNullable<String> = nil,
      seriesNumber: GraphQLNullable<Double> = nil,
      status: String,
      synopsis: GraphQLNullable<String> = nil,
      title: GraphQLNullable<String> = nil,
      translator: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "authors": authors,
        "estimatedPrice": estimatedPrice,
        "format": format,
        "genre": genre,
        "language": language,
        "pageCount": pageCount,
        "previewId": previewId,
        "publisher": publisher,
        "replaceBookId": replaceBookId,
        "series": series,
        "seriesLabel": seriesLabel,
        "seriesNumber": seriesNumber,
        "status": status,
        "synopsis": synopsis,
        "title": title,
        "translator": translator
      ])
    }

    /// Auteurs (override)
    var authors: GraphQLNullable<[String]> {
      get { __data["authors"] }
      set { __data["authors"] = newValue }
    }

    /// Prix (override)
    var estimatedPrice: GraphQLNullable<Double> {
      get { __data["estimatedPrice"] }
      set { __data["estimatedPrice"] = newValue }
    }

    /// Format (override)
    var format: GraphQLNullable<String> {
      get { __data["format"] }
      set { __data["format"] = newValue }
    }

    /// Genre (override)
    var genre: GraphQLNullable<String> {
      get { __data["genre"] }
      set { __data["genre"] = newValue }
    }

    /// Langue (override)
    var language: GraphQLNullable<String> {
      get { __data["language"] }
      set { __data["language"] = newValue }
    }

    /// Pages (override)
    var pageCount: GraphQLNullable<Int> {
      get { __data["pageCount"] }
      set { __data["pageCount"] = newValue }
    }

    /// Identifiant du preview
    var previewId: String {
      get { __data["previewId"] }
      set { __data["previewId"] = newValue }
    }

    /// Éditeur (override)
    var publisher: GraphQLNullable<String> {
      get { __data["publisher"] }
      set { __data["publisher"] = newValue }
    }

    /// ID du livre à remplacer (mise à jour)
    var replaceBookId: GraphQLNullable<String> {
      get { __data["replaceBookId"] }
      set { __data["replaceBookId"] = newValue }
    }

    /// Série (override)
    var series: GraphQLNullable<String> {
      get { __data["series"] }
      set { __data["series"] = newValue }
    }

    /// Label série (override)
    var seriesLabel: GraphQLNullable<String> {
      get { __data["seriesLabel"] }
      set { __data["seriesLabel"] = newValue }
    }

    /// Position série (override)
    var seriesNumber: GraphQLNullable<Double> {
      get { __data["seriesNumber"] }
      set { __data["seriesNumber"] = newValue }
    }

    /// Statut initial (to-read ou read)
    var status: String {
      get { __data["status"] }
      set { __data["status"] = newValue }
    }

    /// Synopsis (override)
    var synopsis: GraphQLNullable<String> {
      get { __data["synopsis"] }
      set { __data["synopsis"] = newValue }
    }

    /// Titre (override)
    var title: GraphQLNullable<String> {
      get { __data["title"] }
      set { __data["title"] = newValue }
    }

    /// Traducteur (override)
    var translator: GraphQLNullable<String> {
      get { __data["translator"] }
      set { __data["translator"] = newValue }
    }
  }

}