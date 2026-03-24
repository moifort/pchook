// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PchookGraphQL {
  /// External community rating
  struct PublicRatingInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      maxScore: Double,
      score: Double,
      source: String,
      url: String,
      voterCount: Int
    ) {
      __data = InputDict([
        "maxScore": maxScore,
        "score": score,
        "source": source,
        "url": url,
        "voterCount": voterCount
      ])
    }

    /// Maximum possible score
    var maxScore: Double {
      get { __data["maxScore"] }
      set { __data["maxScore"] = newValue }
    }

    /// Score received
    var score: Double {
      get { __data["score"] }
      set { __data["score"] = newValue }
    }

    /// Platform name
    var source: String {
      get { __data["source"] }
      set { __data["source"] = newValue }
    }

    /// URL of the book page
    var url: String {
      get { __data["url"] }
      set { __data["url"] = newValue }
    }

    /// Number of voters
    var voterCount: Int {
      get { __data["voterCount"] }
      set { __data["voterCount"] = newValue }
    }
  }

}