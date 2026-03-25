// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol PchookGraphQL_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == PchookGraphQL.SchemaMetadata {}

protocol PchookGraphQL_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == PchookGraphQL.SchemaMetadata {}

protocol PchookGraphQL_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == PchookGraphQL.SchemaMetadata {}

protocol PchookGraphQL_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == PchookGraphQL.SchemaMetadata {}

extension PchookGraphQL {
  typealias SelectionSet = PchookGraphQL_SelectionSet

  typealias InlineFragment = PchookGraphQL_InlineFragment

  typealias MutableSelectionSet = PchookGraphQL_MutableSelectionSet

  typealias MutableInlineFragment = PchookGraphQL_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    nonisolated(unsafe) static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "Audible": return PchookGraphQL.Objects.Audible
      case "AudibleImport": return PchookGraphQL.Objects.AudibleImport
      case "AudibleItem": return PchookGraphQL.Objects.AudibleItem
      case "AudibleSeriesInfo": return PchookGraphQL.Objects.AudibleSeriesInfo
      case "AudibleSync": return PchookGraphQL.Objects.AudibleSync
      case "AuthCookie": return PchookGraphQL.Objects.AuthCookie
      case "AuthStartResponse": return PchookGraphQL.Objects.AuthStartResponse
      case "Award": return PchookGraphQL.Objects.Award
      case "Book": return PchookGraphQL.Objects.Book
      case "BookCount": return PchookGraphQL.Objects.BookCount
      case "BookPreview": return PchookGraphQL.Objects.BookPreview
      case "ConfirmBookResult": return PchookGraphQL.Objects.ConfirmBookResult
      case "DashboardView": return PchookGraphQL.Objects.DashboardView
      case "FavoriteBook": return PchookGraphQL.Objects.FavoriteBook
      case "Mutation": return PchookGraphQL.Objects.Mutation
      case "PublicRating": return PchookGraphQL.Objects.PublicRating
      case "Query": return PchookGraphQL.Objects.Query
      case "RecentAward": return PchookGraphQL.Objects.RecentAward
      case "RecentBook": return PchookGraphQL.Objects.RecentBook
      case "Review": return PchookGraphQL.Objects.Review
      case "SeriesInfo": return PchookGraphQL.Objects.SeriesInfo
      case "SeriesVolume": return PchookGraphQL.Objects.SeriesVolume
      case "Task": return PchookGraphQL.Objects.Task
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}