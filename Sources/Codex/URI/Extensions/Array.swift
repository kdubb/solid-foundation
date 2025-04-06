//
//  Array.swift
//  Codex
//
//  Created by Kevin Wooten on 2/25/25.
//

private extension Array where Element == String {

  func standardizedPath() -> [String] {
    var components: [String] = []
    for component in self {
      switch component {
      case ".":
        break
      case "..":
        components = components.dropLast()
      default:
        components.append(component)
      }
    }
    return components
  }

  func commonPrefix(with other: [String]) -> [String] {
    let pathStandardized = standardizedPath()
    let otherStandardized = other.standardizedPath()

    var commonPrefixCount = 0
    while commonPrefixCount < Swift.min(pathStandardized.count, otherStandardized.count),
      self[commonPrefixCount] == other[commonPrefixCount]
    {
      commonPrefixCount += 1
    }

    // Number of directories to go up from base to reach the common prefix
    let upLevels = pathStandardized.count - commonPrefixCount
    let upPaths = Array(repeating: "..", count: upLevels)

    // Remaining path from self beyond the common prefix
    let remainingPath = pathStandardized[commonPrefixCount...].map { String($0) }

    // Construct the relative path
    let relPathComponents = upPaths + remainingPath

    return relPathComponents.standardizedPath()
  }

}
