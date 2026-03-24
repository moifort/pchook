// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AnalyzeBookCoverMutation: GraphQLMutation {
    static let operationName: String = "AnalyzeBookCover"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AnalyzeBookCover($imageBase64: String!, $ocrText: String) { analyzeBookCover(imageBase64: $imageBase64, ocrText: $ocrText) { __typename previewId title authors publisher publishedDate pageCount genre synopsis isbn language format series seriesLabel seriesNumber translator estimatedPrice duration narrators awards { __typename name year } publicRatings { __typename source score maxScore voterCount url } } }"#
      ))

    public var imageBase64: String
    public var ocrText: GraphQLNullable<String>

    public init(
      imageBase64: String,
      ocrText: GraphQLNullable<String>
    ) {
      self.imageBase64 = imageBase64
      self.ocrText = ocrText
    }

    public var __variables: Variables? { [
      "imageBase64": imageBase64,
      "ocrText": ocrText
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("analyzeBookCover", AnalyzeBookCover?.self, arguments: [
          "imageBase64": .variable("imageBase64"),
          "ocrText": .variable("ocrText")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AnalyzeBookCoverMutation.Data.self
      ] }

      /// Scanner une couverture de livre pour extraire les métadonnées
      var analyzeBookCover: AnalyzeBookCover? { __data["analyzeBookCover"] }

      /// AnalyzeBookCover
      ///
      /// Parent Type: `BookPreview`
      struct AnalyzeBookCover: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.BookPreview }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("previewId", String?.self),
          .field("title", String?.self),
          .field("authors", [String]?.self),
          .field("publisher", String?.self),
          .field("publishedDate", String?.self),
          .field("pageCount", Int?.self),
          .field("genre", String?.self),
          .field("synopsis", String?.self),
          .field("isbn", String?.self),
          .field("language", String?.self),
          .field("format", String?.self),
          .field("series", String?.self),
          .field("seriesLabel", String?.self),
          .field("seriesNumber", Double?.self),
          .field("translator", String?.self),
          .field("estimatedPrice", Double?.self),
          .field("duration", String?.self),
          .field("narrators", [String]?.self),
          .field("awards", [Award]?.self),
          .field("publicRatings", [PublicRating]?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AnalyzeBookCoverMutation.Data.AnalyzeBookCover.self
        ] }

        /// Identifiant du preview
        var previewId: String? { __data["previewId"] }
        /// Titre extrait
        var title: String? { __data["title"] }
        /// Auteurs extraits
        var authors: [String]? { __data["authors"] }
        /// Éditeur
        var publisher: String? { __data["publisher"] }
        /// Date de publication
        var publishedDate: String? { __data["publishedDate"] }
        /// Nombre de pages
        var pageCount: Int? { __data["pageCount"] }
        /// Genre
        var genre: String? { __data["genre"] }
        /// Synopsis
        var synopsis: String? { __data["synopsis"] }
        /// ISBN
        var isbn: String? { __data["isbn"] }
        /// Langue
        var language: String? { __data["language"] }
        /// Format
        var format: String? { __data["format"] }
        /// Série
        var series: String? { __data["series"] }
        /// Label série
        var seriesLabel: String? { __data["seriesLabel"] }
        /// Position série
        var seriesNumber: Double? { __data["seriesNumber"] }
        /// Traducteur
        var translator: String? { __data["translator"] }
        /// Prix estimé
        var estimatedPrice: Double? { __data["estimatedPrice"] }
        /// Durée (audio)
        var duration: String? { __data["duration"] }
        /// Narrateurs
        var narrators: [String]? { __data["narrators"] }
        /// Prix littéraires
        var awards: [Award]? { __data["awards"] }
        /// Notes communautaires
        var publicRatings: [PublicRating]? { __data["publicRatings"] }

        /// AnalyzeBookCover.Award
        ///
        /// Parent Type: `Award`
        struct Award: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Award }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String?.self),
            .field("year", Int?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AnalyzeBookCoverMutation.Data.AnalyzeBookCover.Award.self
          ] }

          /// Nom du prix
          var name: String? { __data["name"] }
          /// Année d'obtention
          var year: Int? { __data["year"] }
        }

        /// AnalyzeBookCover.PublicRating
        ///
        /// Parent Type: `PublicRating`
        struct PublicRating: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.PublicRating }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("source", String?.self),
            .field("score", Double?.self),
            .field("maxScore", Double?.self),
            .field("voterCount", Int?.self),
            .field("url", String?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AnalyzeBookCoverMutation.Data.AnalyzeBookCover.PublicRating.self
          ] }

          /// Nom de la plateforme (ex: Hardcover, Goodreads)
          var source: String? { __data["source"] }
          /// Note obtenue
          var score: Double? { __data["score"] }
          /// Note maximale possible
          var maxScore: Double? { __data["maxScore"] }
          /// Nombre de votants
          var voterCount: Int? { __data["voterCount"] }
          /// Lien vers la page du livre sur la plateforme
          var url: String? { __data["url"] }
        }
      }
    }
  }

}