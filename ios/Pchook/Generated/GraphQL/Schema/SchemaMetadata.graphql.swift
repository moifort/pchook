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
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "Award": return PchookGraphQL.Objects.Award
      case "Book": return PchookGraphQL.Objects.Book
      case "BookListItem": return PchookGraphQL.Objects.BookListItem
      case "Mutation": return PchookGraphQL.Objects.Mutation
      case "PublicRating": return PchookGraphQL.Objects.PublicRating
      case "Query": return PchookGraphQL.Objects.Query
      case "Review": return PchookGraphQL.Objects.Review
      case "SeriesBookEntry": return PchookGraphQL.Objects.SeriesBookEntry
      case "SeriesInfo": return PchookGraphQL.Objects.SeriesInfo
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}