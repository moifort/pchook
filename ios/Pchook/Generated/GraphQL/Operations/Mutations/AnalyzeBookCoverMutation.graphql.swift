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
        .field("analyzeBookCover", AnalyzeBookCover.self, arguments: [
          "imageBase64": .variable("imageBase64"),
          "ocrText": .variable("ocrText")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AnalyzeBookCoverMutation.Data.self
      ] }

      /// Scan a book cover to extract metadata
      var analyzeBookCover: AnalyzeBookCover { __data["analyzeBookCover"] }

      /// AnalyzeBookCover
      ///
      /// Parent Type: `BookPreview`
      struct AnalyzeBookCover: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.BookPreview }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("previewId", String.self),
          .field("title", String.self),
          .field("authors", [String].self),
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
          .field("awards", [Award].self),
          .field("publicRatings", [PublicRating].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AnalyzeBookCoverMutation.Data.AnalyzeBookCover.self
        ] }

        /// Preview identifier
        var previewId: String { __data["previewId"] }
        /// Extracted title
        var title: String { __data["title"] }
        /// Extracted authors
        var authors: [String] { __data["authors"] }
        /// Publisher
        var publisher: String? { __data["publisher"] }
        /// Publication date
        var publishedDate: String? { __data["publishedDate"] }
        /// Page count
        var pageCount: Int? { __data["pageCount"] }
        /// Genre
        var genre: String? { __data["genre"] }
        /// Synopsis
        var synopsis: String? { __data["synopsis"] }
        /// ISBN
        var isbn: String? { __data["isbn"] }
        /// Language
        var language: String? { __data["language"] }
        /// Format
        var format: String? { __data["format"] }
        /// Series
        var series: String? { __data["series"] }
        /// Series label
        var seriesLabel: String? { __data["seriesLabel"] }
        /// Series position
        var seriesNumber: Double? { __data["seriesNumber"] }
        /// Translator
        var translator: String? { __data["translator"] }
        /// Estimated price
        var estimatedPrice: Double? { __data["estimatedPrice"] }
        /// Duration (audio)
        var duration: String? { __data["duration"] }
        /// Narrators
        var narrators: [String]? { __data["narrators"] }
        /// Literary awards
        var awards: [Award] { __data["awards"] }
        /// Community ratings
        var publicRatings: [PublicRating] { __data["publicRatings"] }

        /// AnalyzeBookCover.Award
        ///
        /// Parent Type: `Award`
        struct Award: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Award }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("year", Int?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AnalyzeBookCoverMutation.Data.AnalyzeBookCover.Award.self
          ] }

          /// Award name
          var name: String { __data["name"] }
          /// Year awarded
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
            .field("source", String.self),
            .field("score", Double.self),
            .field("maxScore", Double.self),
            .field("voterCount", Int.self),
            .field("url", String.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AnalyzeBookCoverMutation.Data.AnalyzeBookCover.PublicRating.self
          ] }

          /// Platform name (e.g. Hardcover, Goodreads)
          var source: String { __data["source"] }
          /// Score received
          var score: Double { __data["score"] }
          /// Maximum possible score
          var maxScore: Double { __data["maxScore"] }
          /// Number of voters
          var voterCount: Int { __data["voterCount"] }
          /// Link to the book page on the platform
          var url: String { __data["url"] }
        }
      }
    }
  }

}