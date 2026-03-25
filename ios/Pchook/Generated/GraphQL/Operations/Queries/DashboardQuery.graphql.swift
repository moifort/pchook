// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PchookGraphQL {
  class DashboardQuery: GraphQLQuery {
    static let operationName: String = "Dashboard"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Dashboard { dashboard { __typename bookCount { __typename total toRead read } favorites { __typename id title authors genre rating estimatedPrice } recentBooks { __typename id title authors genre createdAt } recentAwards { __typename bookTitle authors awardName awardYear } } }"#
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
          .field("recentAwards", [RecentAward].self),
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
        /// Recent literary awards
        var recentAwards: [RecentAward] { __data["recentAwards"] }

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
            .field("rating", PchookGraphQL.Note.self),
            .field("estimatedPrice", PchookGraphQL.Eur?.self),
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
          /// Rating (0-10)
          var rating: PchookGraphQL.Note { __data["rating"] }
          /// Estimated price in euros
          var estimatedPrice: PchookGraphQL.Eur? { __data["estimatedPrice"] }
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
            .field("createdAt", PchookGraphQL.DateTime.self),
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
          /// Date added
          var createdAt: PchookGraphQL.DateTime { __data["createdAt"] }
        }

        /// Dashboard.RecentAward
        ///
        /// Parent Type: `RecentAward`
        struct RecentAward: PchookGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { PchookGraphQL.Objects.RecentAward }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("bookTitle", String.self),
            .field("authors", [PchookGraphQL.PersonName].self),
            .field("awardName", String.self),
            .field("awardYear", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DashboardQuery.Data.Dashboard.RecentAward.self
          ] }

          /// Book title
          var bookTitle: String { __data["bookTitle"] }
          /// Authors
          var authors: [PchookGraphQL.PersonName] { __data["authors"] }
          /// Award name
          var awardName: String { __data["awardName"] }
          /// Award year
          var awardYear: Int { __data["awardYear"] }
        }
      }
    }
  }

}