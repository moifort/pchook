// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class SearchQuery: GraphQLQuery {
    static let operationName: String = "Search"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Search($query: String!, $limit: Int) { search(query: $query, limit: $limit) { __typename books { __typename id title authors language status coverImageUrl } series { __typename id name volumeCount rating languages } authors { __typename name bookCount firstBookId } } }"#
      ))

    public var query: String
    public var limit: GraphQLNullable<Int>

    public init(
      query: String,
      limit: GraphQLNullable<Int>
    ) {
      self.query = query
      self.limit = limit
    }

    public var __variables: Variables? { [
      "query": query,
      "limit": limit
    ] }

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("search", Search.self, arguments: [
          "query": .variable("query"),
          "limit": .variable("limit")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SearchQuery.Data.self
      ] }

      /// Search across books, series, and authors
      var search: Search { __data["search"] }

      /// Search
      ///
      /// Parent Type: `SearchResults`
      struct Search: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SearchResults }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("books", [Book].self),
          .field("series", [Series].self),
          .field("authors", [Author].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          SearchQuery.Data.Search.self
        ] }

        /// Matching books
        var books: [Book] { __data["books"] }
        /// Matching series
        var series: [Series] { __data["series"] }
        /// Matching authors
        var authors: [Author] { __data["authors"] }

        /// Search.Book
        ///
        /// Parent Type: `BookSearchResult`
        struct Book: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.BookSearchResult }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.ID.self),
            .field("title", String.self),
            .field("authors", [String].self),
            .field("language", String?.self),
            .field("status", String.self),
            .field("coverImageUrl", PchookGraphQL.Url?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            SearchQuery.Data.Search.Book.self
          ] }

          /// Book ID
          var id: PchookGraphQL.ID { __data["id"] }
          /// Book title
          var title: String { __data["title"] }
          /// Book authors
          var authors: [String] { __data["authors"] }
          /// Book language (ISO 639-1)
          var language: String? { __data["language"] }
          /// Reading status
          var status: String { __data["status"] }
          /// Cover image URL
          var coverImageUrl: PchookGraphQL.Url? { __data["coverImageUrl"] }
        }

        /// Search.Series
        ///
        /// Parent Type: `SeriesSearchResult`
        struct Series: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.SeriesSearchResult }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.ID.self),
            .field("name", PchookGraphQL.SeriesName.self),
            .field("volumeCount", Int.self),
            .field("rating", PchookGraphQL.Note?.self),
            .field("languages", [String].self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            SearchQuery.Data.Search.Series.self
          ] }

          /// Series ID
          var id: PchookGraphQL.ID { __data["id"] }
          /// Series name
          var name: PchookGraphQL.SeriesName { __data["name"] }
          /// Number of volumes in the series
          var volumeCount: Int { __data["volumeCount"] }
          /// Personal series rating
          var rating: PchookGraphQL.Note? { __data["rating"] }
          /// Languages of books in the series (ISO 639-1)
          var languages: [String] { __data["languages"] }
        }

        /// Search.Author
        ///
        /// Parent Type: `AuthorSearchResult`
        struct Author: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.AuthorSearchResult }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", PchookGraphQL.PersonName.self),
            .field("bookCount", Int.self),
            .field("firstBookId", PchookGraphQL.ID.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            SearchQuery.Data.Search.Author.self
          ] }

          /// Author name
          var name: PchookGraphQL.PersonName { __data["name"] }
          /// Number of books by this author
          var bookCount: Int { __data["bookCount"] }
          /// ID of the first book by this author
          var firstBookId: PchookGraphQL.ID { __data["firstBookId"] }
        }
      }
    }
  }

}