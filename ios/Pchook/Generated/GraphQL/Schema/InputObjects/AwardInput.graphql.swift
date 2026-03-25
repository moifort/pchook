// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Literary award
  struct AwardInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      name: String,
      year: GraphQLNullable<Int> = nil
    ) {
      __data = InputDict([
        "name": name,
        "year": year
      ])
    }

    /// Award name
    var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Year awarded
    var year: GraphQLNullable<Int> {
      get { __data["year"] }
      set { __data["year"] = newValue }
    }
  }

}