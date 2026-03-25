// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class BookDetailQuery: GraphQLQuery {
    static let operationName: String = "BookDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BookDetail($id: BookId!) { book(id: $id) { __typename id title authors publisher publishedDate pageCount genre synopsis isbn language format translator estimatedPrice durationMinutes narrators personalNotes status readDate awards { __typename name year } publicRatings { __typename source score maxScore voterCount url } importSource externalUrl createdAt updatedAt coverImageUrl review { __typename bookId rating readDate reviewNotes createdAt } series { __typename id name volumes { __typename id title label position } } seriesVolume { __typename id title label position } } }"#
      ))

    public var id: BookId

    public init(id: BookId) {
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
          .field("id", PchookGraphQL.BookId.self),
          .field("title", PchookGraphQL.BookTitle.self),
          .field("authors", [PchookGraphQL.PersonName].self),
          .field("publisher", PchookGraphQL.Publisher?.self),
          .field("publishedDate", PchookGraphQL.DateTime?.self),
          .field("pageCount", PchookGraphQL.PageCount?.self),
          .field("genre", PchookGraphQL.Genre?.self),
          .field("synopsis", String?.self),
          .field("isbn", PchookGraphQL.ISBN?.self),
          .field("language", GraphQLEnum<PchookGraphQL.Language>?.self),
          .field("format", GraphQLEnum<PchookGraphQL.BookFormat>?.self),
          .field("translator", PchookGraphQL.PersonName?.self),
          .field("estimatedPrice", PchookGraphQL.Eur?.self),
          .field("durationMinutes", Int?.self),
          .field("narrators", [PchookGraphQL.PersonName].self),
          .field("personalNotes", String?.self),
          .field("status", GraphQLEnum<PchookGraphQL.BookStatus>.self),
          .field("readDate", PchookGraphQL.DateTime?.self),
          .field("awards", [Award].self),
          .field("publicRatings", [PublicRating].self),
          .field("importSource", GraphQLEnum<PchookGraphQL.ImportSource>?.self),
          .field("externalUrl", PchookGraphQL.Url?.self),
          .field("createdAt", PchookGraphQL.DateTime.self),
          .field("updatedAt", PchookGraphQL.DateTime.self),
          .field("coverImageUrl", PchookGraphQL.Url?.self),
          .field("review", Review?.self),
          .field("series", Series?.self),
          .field("seriesVolume", SeriesVolume?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BookDetailQuery.Data.Book.self
        ] }

        /// Unique identifier
        var id: PchookGraphQL.BookId { __data["id"] }
        /// Book title
        var title: PchookGraphQL.BookTitle { __data["title"] }
        /// Book authors
        var authors: [PchookGraphQL.PersonName] { __data["authors"] }
        /// Publisher (e.g. "Gallimard", "Folio"). Null if unknown
        var publisher: PchookGraphQL.Publisher? { __data["publisher"] }
        /// First publication date. Null if unknown
        var publishedDate: PchookGraphQL.DateTime? { __data["publishedDate"] }
        /// Number of pages. Null for audiobooks or if unknown
        var pageCount: PchookGraphQL.PageCount? { __data["pageCount"] }
        /// Literary genre, comma-separated if multiple (e.g. "LitRPG, Science Fantasy")
        var genre: PchookGraphQL.Genre? { __data["genre"] }
        /// Short summary of the book content (3-5 sentences)
        var synopsis: String? { __data["synopsis"] }
        /// ISBN-13 or ISBN-10 (e.g. "978-2-07-036822-8"). Null if not available
        var isbn: PchookGraphQL.ISBN? { __data["isbn"] }
        /// Book language as ISO 639-1 code. Null if unknown
        var language: GraphQLEnum<PchookGraphQL.Language>? { __data["language"] }
        /// Physical or digital format. Null if unknown
        var format: GraphQLEnum<PchookGraphQL.BookFormat>? { __data["format"] }
        /// Translator name, if the book is a translation. Null otherwise
        var translator: PchookGraphQL.PersonName? { __data["translator"] }
        /// Estimated retail price in euros. Null if unknown
        var estimatedPrice: PchookGraphQL.Eur? { __data["estimatedPrice"] }
        /// Duration in minutes for audiobooks (e.g. 510 for 8h30). Null for non-audio
        var durationMinutes: Int? { __data["durationMinutes"] }
        /// Audiobook narrators. Empty array for non-audio formats
        var narrators: [PchookGraphQL.PersonName] { __data["narrators"] }
        /// Free-form personal notes about the book
        var personalNotes: String? { __data["personalNotes"] }
        /// Reading status: TO_READ or READ
        var status: GraphQLEnum<PchookGraphQL.BookStatus> { __data["status"] }
        /// Date the book was finished reading. Null if not read yet
        var readDate: PchookGraphQL.DateTime? { __data["readDate"] }
        /// Literary awards received. Empty array if none
        var awards: [Award] { __data["awards"] }
        /// Community ratings from external platforms (Hardcover, Goodreads). Empty array if none
        var publicRatings: [PublicRating] { __data["publicRatings"] }
        /// How the book was added (scan, isbn, url, audible). Null if added manually
        var importSource: GraphQLEnum<PchookGraphQL.ImportSource>? { __data["importSource"] }
        /// Link to the book on the import source (e.g. Audible page). Null if none
        var externalUrl: PchookGraphQL.Url? { __data["externalUrl"] }
        /// Date the book was added to the library
        var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }
        /// Date of last modification
        var updatedAt: PchookGraphQL.DateTime { __data["updatedAt"] }
        /// Absolute URL to the cover image. Null if no cover
        var coverImageUrl: PchookGraphQL.Url? { __data["coverImageUrl"] }
        /// Personal review and rating
        var review: Review? { __data["review"] }
        /// Series this book belongs to
        var series: Series? { __data["series"] }
        /// This book's volume entry in its series (label and position)
        var seriesVolume: SeriesVolume? { __data["seriesVolume"] }

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

          /// Short award name (e.g. "Prix Hugo", "Prix Goncourt")
          var name: String { __data["name"] }
          /// Year awarded (e.g. 2023)
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
            .field("score", PchookGraphQL.Note.self),
            .field("maxScore", PchookGraphQL.Note.self),
            .field("voterCount", Int.self),
            .field("url", PchookGraphQL.Url.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.PublicRating.self
          ] }

          /// Platform name (e.g. Hardcover, Goodreads)
          var source: String { __data["source"] }
          /// Score received (0-10 scale, e.g. 8)
          var score: PchookGraphQL.Note { __data["score"] }
          /// Maximum possible score on this platform (e.g. 10)
          var maxScore: PchookGraphQL.Note { __data["maxScore"] }
          /// Number of voters who rated the book
          var voterCount: Int { __data["voterCount"] }
          /// Direct link to the book page on the platform
          var url: PchookGraphQL.Url { __data["url"] }
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
            .field("bookId", PchookGraphQL.BookId.self),
            .field("rating", PchookGraphQL.Note.self),
            .field("readDate", PchookGraphQL.DateTime?.self),
            .field("reviewNotes", String?.self),
            .field("createdAt", PchookGraphQL.DateTime.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.Review.self
          ] }

          /// Associated book ID
          var bookId: PchookGraphQL.BookId { __data["bookId"] }
          /// Personal rating (0-10)
          var rating: PchookGraphQL.Note { __data["rating"] }
          /// Read date
          var readDate: PchookGraphQL.DateTime? { __data["readDate"] }
          /// Reading notes
          var reviewNotes: String? { __data["reviewNotes"] }
          /// Creation date
          var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }
        }

        /// Book.Series
        ///
        /// Parent Type: `Series`
        struct Series: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Series }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.ID.self),
            .field("name", PchookGraphQL.SeriesName.self),
            .field("volumes", [Volume].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.Series.self
          ] }

          /// Unique identifier
          var id: PchookGraphQL.ID { __data["id"] }
          /// Series name (e.g. "Le Sorceleur", "Fondation")
          var name: PchookGraphQL.SeriesName { __data["name"] }
          /// All volumes in this series (filtered by language when accessed from a book)
          var volumes: [Volume] { __data["volumes"] }

          /// Book.Series.Volume
          ///
          /// Parent Type: `SeriesVolume`
          struct Volume: PchookGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesVolume }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", PchookGraphQL.ID.self),
              .field("title", String.self),
              .field("label", String.self),
              .field("position", Int.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              BookDetailQuery.Data.Book.Series.Volume.self
            ] }

            /// Book ID (can be used to fetch full Book details)
            var id: PchookGraphQL.ID { __data["id"] }
            /// Book title
            var title: String { __data["title"] }
            /// Display label in series (e.g. "1", "1.5", "Hors-série", "Préquelle")
            var label: String { __data["label"] }
            /// Sort position in series (e.g. 1, 2, 99 for hors-série)
            var position: Int { __data["position"] }
          }
        }

        /// Book.SeriesVolume
        ///
        /// Parent Type: `SeriesVolume`
        struct SeriesVolume: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesVolume }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.ID.self),
            .field("title", String.self),
            .field("label", String.self),
            .field("position", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookDetailQuery.Data.Book.SeriesVolume.self
          ] }

          /// Book ID (can be used to fetch full Book details)
          var id: PchookGraphQL.ID { __data["id"] }
          /// Book title
          var title: String { __data["title"] }
          /// Display label in series (e.g. "1", "1.5", "Hors-série", "Préquelle")
          var label: String { __data["label"] }
          /// Sort position in series (e.g. 1, 2, 99 for hors-série)
          var position: Int { __data["position"] }
        }
      }
    }
  }

}