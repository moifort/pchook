// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class BookDetailQuery: GraphQLQuery {
    static let operationName: String = "BookDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BookDetail($id: ID!) { book(id: $id) { __typename id title authors publisher publishedDate pageCount genre synopsis isbn language format translator estimatedPrice duration narrators personalNotes status readDate awards { __typename name year } publicRatings { __typename source score maxScore voterCount url } importSource externalUrl createdAt updatedAt coverImageUrl review { __typename bookId rating readDate reviewNotes createdAt } series { __typename name label position books { __typename id title label position } } } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("book", Book?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BookDetailQuery.Data.self
      ] }

      /// Book detail by ID
      var book: Book? { __data["book"] }

      /// Book
      ///
      /// Parent Type: `Book`
      struct Book: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Book }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PchookGraphQL.ID.self),
          .field("title", String.self),
          .field("authors", [String].self),
          .field("publisher", String?.self),
          .field("publishedDate", PchookGraphQL.DateTime?.self),
          .field("pageCount", Int?.self),
          .field("genre", String?.self),
          .field("synopsis", String?.self),
          .field("isbn", String?.self),
          .field("language", String?.self),
          .field("format", GraphQLEnum<PchookGraphQL.BookFormat>?.self),
          .field("translator", String?.self),
          .field("estimatedPrice", Double?.self),
          .field("duration", String?.self),
          .field("narrators", [String].self),
          .field("personalNotes", String?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>.self),
          .field("readDate", PchookGraphQL.DateTime?.self),
          .field("awards", [Award].self),
          .field("publicRatings", [PublicRating].self),
          .field("importSource", GraphQLEnum<PchookGraphQL.ImportSource>?.self),
          .field("externalUrl", String?.self),
          .field("createdAt", PchookGraphQL.DateTime.self),
          .field("updatedAt", PchookGraphQL.DateTime.self),
          .field("coverImageUrl", String?.self),
          .field("review", Review?.self),
          .field("series", Series?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BookDetailQuery.Data.Book.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.ID { __data["id"] }
        /// Book title
        var title: String { __data["title"] }
        /// Book authors
        var authors: [String] { __data["authors"] }
        /// Publisher
        var publisher: String? { __data["publisher"] }
        /// Publication date
        var publishedDate: PchookGraphQL.DateTime? { __data["publishedDate"] }
        /// Page count
        var pageCount: Int? { __data["pageCount"] }
        /// Literary genre (e.g. Romance, Sci-Fi, Thriller)
        var genre: String? { __data["genre"] }
        /// Book synopsis
        var synopsis: String? { __data["synopsis"] }
        /// ISBN number
        var isbn: String? { __data["isbn"] }
        /// Book language (e.g. fr, en)
        var language: String? { __data["language"] }
        /// Book format
        var format: GraphQLEnum<PchookGraphQL.BookFormat>? { __data["format"] }
        /// Translator
        var translator: String? { __data["translator"] }
        /// Estimated price in euros
        var estimatedPrice: Double? { __data["estimatedPrice"] }
        /// Duration (audiobook)
        var duration: String? { __data["duration"] }
        /// Narrators (audiobook)
        var narrators: [String] { __data["narrators"] }
        /// Personal notes
        var personalNotes: String? { __data["personalNotes"] }
        /// Reading status
        var status: GraphQLEnum<PchookGraphQL.BookStatus> { __data["status"] }
        /// Read date
        var readDate: PchookGraphQL.DateTime? { __data["readDate"] }
        /// Literary awards
        var awards: [Award] { __data["awards"] }
        /// Community ratings
        var publicRatings: [PublicRating] { __data["publicRatings"] }
        /// Import source
        var importSource: GraphQLEnum<PchookGraphQL.ImportSource>? { __data["importSource"] }
        /// External URL (Audible, etc.)
        var externalUrl: String? { __data["externalUrl"] }
        /// Date added to library
        var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }
        /// Last modified date
        var updatedAt: PchookGraphQL.DateTime { __data["updatedAt"] }
        /// Cover image URL
        var coverImageUrl: String? { __data["coverImageUrl"] }
        /// Personal review and rating
        var review: Review? { __data["review"] }
        /// Series information
        var series: Series? { __data["series"] }

        /// Book.Award
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
            BookDetailQuery.Data.Book.Award.self
          ] }

          /// Award name
          var name: String { __data["name"] }
          /// Year awarded
          var year: Int? { __data["year"] }
        }

        /// Book.PublicRating
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
            BookDetailQuery.Data.Book.PublicRating.self
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

        /// Book.Review
        ///
        /// Parent Type: `Review`
        struct Review: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Review }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("bookId", PchookGraphQL.ID.self),
            .field("rating", Int.self),
            .field("readDate", PchookGraphQL.DateTime?.self),
            .field("reviewNotes", String?.self),
            .field("createdAt", PchookGraphQL.DateTime.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.Review.self
          ] }

          /// Associated book ID
          var bookId: PchookGraphQL.ID { __data["bookId"] }
          /// Personal rating (0-10)
          var rating: Int { __data["rating"] }
          /// Read date
          var readDate: PchookGraphQL.DateTime? { __data["readDate"] }
          /// Reading notes
          var reviewNotes: String? { __data["reviewNotes"] }
          /// Creation date
          var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }
        }

        /// Book.Series
        ///
        /// Parent Type: `SeriesInfo`
        struct Series: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesInfo }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("label", String.self),
            .field("position", Int.self),
            .field("books", [Book].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.Series.self
          ] }

          /// Series name
          var name: String { __data["name"] }
          /// Book label in series
          var label: String { __data["label"] }
          /// Book position in series
          var position: Int { __data["position"] }
          /// All books in the series (same language)
          var books: [Book] { __data["books"] }

          /// Book.Series.Book
          ///
          /// Parent Type: `SeriesBookEntry`
          struct Book: PchookGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesBookEntry }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", PchookGraphQL.ID.self),
              .field("title", String.self),
              .field("label", String.self),
              .field("position", Int.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              BookDetailQuery.Data.Book.Series.Book.self
            ] }

            /// Book ID
            var id: PchookGraphQL.ID { __data["id"] }
            /// Book title
            var title: String { __data["title"] }
            /// Label in series (e.g. Volume 3)
            var label: String { __data["label"] }
            /// Position in series
            var position: Int { __data["position"] }
          }
        }
      }
    }
  }

}