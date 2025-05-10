//
//  CompositeSchemaLocator.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 2/9/25.
//

public struct CompositeSchemaLocator: SchemaLocator {

  public static func from(locators: [SchemaLocator]) -> Self {
    if locators.count == 1, let composite = locators[0] as? Self {
      return composite
    }
    let locators = locators.flatMap {
      if let composite = $0 as? Self {
        return composite.locators
      }
      return [$0]
    }
    return Self(locators: locators)
  }

  public var locators: [SchemaLocator]

  private init(locators: [SchemaLocator]) {
    self.locators = locators.sorted { $0.priority < $1.priority }
  }

  public func with(locator: SchemaLocator) -> Self {
    Self(locators: locators + [locator])
  }

  public func locate(schemaId id: URI, options: Schema.Options) throws -> Schema? {
    for locator in locators {
      if let schema = try locator.locate(schemaId: id, options: options) {
        return schema
      }
    }
    return nil
  }

}

private extension SchemaLocator {

  var priority: Int {
    switch self {
    case is LocalSchemaContainer:
      -1
    case is LocalDirectorySchemaContainer:
      1
    default:
      0
    }
  }

}
