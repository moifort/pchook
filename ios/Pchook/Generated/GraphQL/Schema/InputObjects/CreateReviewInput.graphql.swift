// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// Données pour créer une critique
  struct CreateReviewInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      rating: Int,
      readDate: GraphQLNullable<String> = nil,
      reviewNotes: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "rating": rating,
        "readDate": readDate,
        "reviewNotes": reviewNotes
      ])
    }

    /// Note personnelle (0-10)
    var rating: Int {
      get { __data["rating"] }
      set { __data["rating"] = newValue }
    }

    /// Date de lecture (ISO 8601)
    var readDate: GraphQLNullable<String> {
      get { __data["readDate"] }
      set { __data["readDate"] = newValue }
    }

    /// Notes de lecture
    var reviewNotes: GraphQLNullable<String> {
      get { __data["reviewNotes"] }
      set { __data["reviewNotes"] = newValue }
    }
  }

}