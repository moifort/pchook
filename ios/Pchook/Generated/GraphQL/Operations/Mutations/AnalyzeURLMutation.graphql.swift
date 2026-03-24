// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class AnalyzeURLMutation: GraphQLMutation {
    static let operationName: String = "AnalyzeURL"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AnalyzeURL($url: String!, $description: String, $rawText: String) { analyzeURL(url: $url, description: $description, rawText: $rawText) { __typename previewId title authors publisher genre isbn language awards { __typename name year } publicRatings { __typename source score maxScore voterCount url } } }"#
      ))

    public var url: String
    public var description: GraphQLNullable<String>
    public var rawText: GraphQLNullable<String>

    public init(
      url: String,
      description: GraphQLNullable<String>,
      rawText: GraphQLNullable<String>
    ) {
      self.url = url
      self.description = description
      self.rawText = rawText
    }

    public var __variables: Variables? { [
      "url": url,
      "description": description,
      "rawText": rawText
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("analyzeURL", AnalyzeURL.self, arguments: [
          "url": .variable("url"),
          "description": .variable("description"),
          "rawText": .variable("rawText")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AnalyzeURLMutation.Data.self
      ] }

      /// Import a book from a URL (Goodreads, Storygraph, etc.)
      var analyzeURL: AnalyzeURL { __data["analyzeURL"] }

      /// AnalyzeURL
      ///
      /// Parent Type: `BookPreview`
      struct AnalyzeURL: PchookGraphQL.SelectionSet {
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
          AnalyzeURLMutation.Data.AnalyzeURL.self
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

        /// AnalyzeURL.Award
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
            AnalyzeURLMutation.Data.AnalyzeURL.Award.self
          ] }

          /// Award name
          var name: String { __data["name"] }
          /// Year awarded
          var year: Int? { __data["year"] }
        }

        /// AnalyzeURL.PublicRating
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
            AnalyzeURLMutation.Data.AnalyzeURL.PublicRating.self
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