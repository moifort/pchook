// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AnalyzeISBNMutation: GraphQLMutation {
    static let operationName: String = "AnalyzeISBN"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AnalyzeISBN($isbn: ISBN!) { analyzeISBN(isbn: $isbn) { __typename previewId title authors publisher genre isbn language awards { __typename name year } publicRatings { __typename source score maxScore voterCount url } } }"#
      ))

    public var isbn: ISBN

    public init(isbn: ISBN) {
      self.isbn = isbn
    }

    public var __variables: Variables? { ["isbn": isbn] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("analyzeISBN", AnalyzeISBN?.self, arguments: ["isbn": .variable("isbn")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AnalyzeISBNMutation.Data.self
      ] }

      /// Scan an ISBN barcode. Returns null if the book already exists.
      var analyzeISBN: AnalyzeISBN? { __data["analyzeISBN"] }

      /// AnalyzeISBN
      ///
      /// Parent Type: `BookPreview`
      struct AnalyzeISBN: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.BookPreview }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("previewId", String.self),
          .field("title", String.self),
          .field("authors", [String].self),
          .field("publisher", String?.self),
          .field("genre", String?.self),
          .field("isbn", String?.self),
          .field("language", String?.self),
          .field("awards", [Award].self),
          .field("publicRatings", [PublicRating].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AnalyzeISBNMutation.Data.AnalyzeISBN.self
        ] }

        /// Preview identifier
        var previewId: String { __data["previewId"] }
        /// Extracted title
        var title: String { __data["title"] }
        /// Extracted authors
        var authors: [String] { __data["authors"] }
        /// Publisher
        var publisher: String? { __data["publisher"] }
        /// Genre
        var genre: String? { __data["genre"] }
        /// ISBN
        var isbn: String? { __data["isbn"] }
        /// Language
        var language: String? { __data["language"] }
        /// Literary awards
        var awards: [Award] { __data["awards"] }
        /// Community ratings
        var publicRatings: [PublicRating] { __data["publicRatings"] }

        /// AnalyzeISBN.Award
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
            AnalyzeISBNMutation.Data.AnalyzeISBN.Award.self
          ] }

          /// Short award name (e.g. "Prix Hugo", "Prix Goncourt")
          var name: String { __data["name"] }
          /// Year awarded (e.g. 2023)
          var year: Int? { __data["year"] }
        }

        /// AnalyzeISBN.PublicRating
        ///
        /// Parent Type: `PublicRating`
        struct PublicRating: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.PublicRating }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("source", String.self),
            .field("score", PchookGraphQL.RatingScore.self),
            .field("maxScore", PchookGraphQL.RatingScore.self),
            .field("voterCount", Int.self),
            .field("url", PchookGraphQL.Url.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AnalyzeISBNMutation.Data.AnalyzeISBN.PublicRating.self
          ] }

          /// Platform name (e.g. Hardcover, Goodreads)
          var source: String { __data["source"] }
          /// Score received (e.g. 3.75 out of 5)
          var score: PchookGraphQL.RatingScore { __data["score"] }
          /// Maximum possible score on this platform (e.g. 5, 10)
          var maxScore: PchookGraphQL.RatingScore { __data["maxScore"] }
          /// Number of voters who rated the book
          var voterCount: Int { __data["voterCount"] }
          /// Direct link to the book page on the platform
          var url: PchookGraphQL.Url { __data["url"] }
        }
      }
    }
  }

}