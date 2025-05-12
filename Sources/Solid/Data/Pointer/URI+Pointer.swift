//
//  URI+Pointer.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

import SolidURI

extension URI {

  /// Updates the fragment of this URI with the specified ``Pointer``.
  ///
  /// Creates a new URI by updating the fragment with the specified ``Pointer`` leaving
  /// the other components unchanged.
  ///
  /// - Parameter pointer: The pointer to be used as the fragment
  /// - Returns: A new URI with the fragment updated
  ///
  public func updating(fragmentPointer pointer: Pointer) -> URI {
    updating([.fragment(pointer.encoded)])
  }

  /// Updates the fragment of this URI with a ``Pointer`` built from tokens.
  ///
  /// Creates a new URI by updating the fragment with a ``Pointer`` built form the
  /// specified tokens, leaving the other components unchanged.
  ///
  /// - Parameter tokens: The reference tokens to use as the fragment
  /// - Returns: A new URI with the updated fragment
  ///
  public func updating(fragmentPointer tokens: Pointer.ReferenceToken...) -> URI {
    updating(fragmentPointer: Pointer(tokens: tokens))
  }

  /// Appends the specified ``Pointer`` to this URI's existing fragment.
  ///
  /// If this URI has a fragment, that is a valid ``Pointer``, this method appends the
  /// specified pointer to the existing fragment pointer.
  ///
  /// - Parameter pointer: The pointer to append.
  /// - Returns: A new URI with the appended fragment, or `nil` if there is no
  /// fragment or the existing fragment is not a valid ``Pointer``.
  ///
  public func appending(fragmentPointer pointer: Pointer) -> URI? {
    guard let fragment else {
      return updating(fragmentPointer: pointer)
    }
    guard let fragmentPointer = Pointer(encoded: fragment) else {
      return nil
    }
    return URI(
      scheme: scheme,
      authority: authority,
      path: path,
      query: query,
      fragment: (fragmentPointer / pointer).encoded
    )
  }

  /// Appends the specified ``Pointer`` to this URI's existing fragment.
  ///
  /// If this URI has a fragment, that is a valid ``Pointer``, this method appends the
  /// specified pointer to the existing fragment pointer.
  ///
  /// - Parameter tokens: The pointer to append.
  /// - Returns: A new URI with the appended fragment, or `nil` if there is no
  /// fragment or the existing fragment is not a valid ``Pointer``.
  ///
  public func appending(fragmentPointer tokens: Pointer.ReferenceToken...) -> URI? {
    appending(fragmentPointer: Pointer(tokens: tokens))
  }

}
