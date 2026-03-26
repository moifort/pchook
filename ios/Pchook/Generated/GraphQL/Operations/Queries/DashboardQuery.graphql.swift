// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class DashboardQuery: GraphQLQuery {
    static let operationName: String = "Dashboard"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Dashboard { dashboard { __typename bookCount { __typename total toRead read totalAudioMinutes } favorites { __typename id title authors genre language } recentBooks { __typename id title authors genre language } recommendedBooks { __typename id title authors genre language recommendedBy } favoriteSeries { __typename id name volumeCount authors language firstBookId } } }"#
      ))

    public init() {}

    struct Data: PchookGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("dashboard", Dashboard.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DashboardQuery.Data.self
      ] }

      /// Dashboard with reading statistics
      var dashboard: Dashboard { __data["dashboard"] }

      /// Dashboard
      ///
      /// Parent Type: `DashboardView`
      struct Dashboard: PchookGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.DashboardView }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("bookCount", BookCount.self),
          .field("favorites", [Favorite].self),
          .field("recentBooks", [RecentBook].self),
          .field("recommendedBooks", [RecommendedBook].self),
          .field("favoriteSeries", [FavoriteSeries].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          DashboardQuery.Data.Dashboard.self
        ] }

        /// Book count
        var bookCount: BookCount { __data["bookCount"] }
        /// Favorite books
        var favorites: [Favorite] { __data["favorites"] }
        /// Recently added books
        var recentBooks: [RecentBook] { __data["recentBooks"] }
        /// Books recommended by others
        var recommendedBooks: [RecommendedBook] { __data["recommendedBooks"] }
        /// Favorite series
        var favoriteSeries: [FavoriteSeries] { __data["favoriteSeries"] }

        /// Dashboard.BookCount
        ///
        /// Parent Type: `BookCount`
        struct BookCount: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.BookCount }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("total", Int.self),
            .field("toRead", Int.self),
            .field("read", Int.self),
            .field("totalAudioMinutes", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DashboardQuery.Data.Dashboard.BookCount.self
          ] }

          /// Total number of books
          var total: Int { __data["total"] }
          /// Books to read
          var toRead: Int { __data["toRead"] }
          /// Books read
          var read: Int { __data["read"] }
          /// Total audiobook duration in minutes
          var totalAudioMinutes: Int { __data["totalAudioMinutes"] }
        }

        /// Dashboard.Favorite
        ///
        /// Parent Type: `FavoriteBook`
        struct Favorite: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.FavoriteBook }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.BookId.self),
            .field("title", String.self),
            .field("authors", [PchookGraphQL.PersonName].self),
            .field("genre", PchookGraphQL.Genre?.self),
            .field("language", GraphQLEnum<PchookGraphQL.Language>?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DashboardQuery.Data.Dashboard.Favorite.self
          ] }

          /// Book ID
          var id: PchookGraphQL.BookId { __data["id"] }
          /// Title
          var title: String { __data["title"] }
          /// Authors
          var authors: [PchookGraphQL.PersonName] { __data["authors"] }
          /// Genre
          var genre: PchookGraphQL.Genre? { __data["genre"] }
          /// Language
          var language: GraphQLEnum<PchookGraphQL.Language>? { __data["language"] }
        }

        /// Dashboard.RecentBook
        ///
        /// Parent Type: `RecentBook`
        struct RecentBook: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.RecentBook }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.BookId.self),
            .field("title", String.self),
            .field("authors", [PchookGraphQL.PersonName].self),
            .field("genre", PchookGraphQL.Genre?.self),
            .field("language", GraphQLEnum<PchookGraphQL.Language>?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DashboardQuery.Data.Dashboard.RecentBook.self
          ] }

          /// Book ID
          var id: PchookGraphQL.BookId { __data["id"] }
          /// Title
          var title: String { __data["title"] }
          /// Authors
          var authors: [PchookGraphQL.PersonName] { __data["authors"] }
          /// Genre
          var genre: PchookGraphQL.Genre? { __data["genre"] }
          /// Language
          var language: GraphQLEnum<PchookGraphQL.Language>? { __data["language"] }
        }

        /// Dashboard.RecommendedBook
        ///
        /// Parent Type: `RecommendedBook`
        struct RecommendedBook: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.RecommendedBook }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.BookId.self),
            .field("title", String.self),
            .field("authors", [PchookGraphQL.PersonName].self),
            .field("genre", PchookGraphQL.Genre?.self),
            .field("language", GraphQLEnum<PchookGraphQL.Language>?.self),
            .field("recommendedBy", PchookGraphQL.PersonName.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DashboardQuery.Data.Dashboard.RecommendedBook.self
          ] }

          /// Book ID
          var id: PchookGraphQL.BookId { __data["id"] }
          /// Title
          var title: String { __data["title"] }
          /// Authors
          var authors: [PchookGraphQL.PersonName] { __data["authors"] }
          /// Genre
          var genre: PchookGraphQL.Genre? { __data["genre"] }
          /// Language
          var language: GraphQLEnum<PchookGraphQL.Language>? { __data["language"] }
          /// Name of recommender
          var recommendedBy: PchookGraphQL.PersonName { __data["recommendedBy"] }
        }

        /// Dashboard.FavoriteSeries
        ///
        /// Parent Type: `FavoriteSeries`
        struct FavoriteSeries: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.FavoriteSeries }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", PchookGraphQL.ID.self),
            .field("name", String.self),
            .field("volumeCount", Int.self),
            .field("authors", [PchookGraphQL.PersonName].self),
            .field("language", GraphQLEnum<PchookGraphQL.Language>?.self),
            .field("firstBookId", PchookGraphQL.BookId?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DashboardQuery.Data.Dashboard.FavoriteSeries.self
          ] }

          /// Series ID
          var id: PchookGraphQL.ID { __data["id"] }
          /// Series name
          var name: String { __data["name"] }
          /// Number of volumes
          var volumeCount: Int { __data["volumeCount"] }
          /// Authors
          var authors: [PchookGraphQL.PersonName] { __data["authors"] }
          /// Language
          var language: GraphQLEnum<PchookGraphQL.Language>? { __data["language"] }
          /// First volume book ID for navigation
          var firstBookId: PchookGraphQL.BookId? { __data["firstBookId"] }
        }
      }
    }
  }

}