extension Collection {
    /// Returns true iff all elements in this collection are
    /// equal after applying the given transformation.
    ///
    /// If this collection is empty, returns `true`.
    ///
    /// - Complexity: O(`count`)
    func allEqual<T : Equatable>(by transform: (Element) -> T) -> Bool {
        guard let first = first else { return true }
        // Transform the first value only once.
        let transformedFirst = transform(first)
        for element in dropFirst() where transformedFirst != transform(element) {
            return false
        }
        return true
    }
    
    /// Returns true iff any element in this collection
    /// satisfies the given predicate.
    ///
    /// If this collection is empty, returns `false`.
    ///
    /// - Complexity: O(`count`)
    func anySatisfy(_ predicate: (Element) -> Bool) -> Bool {
        for element in self where predicate(element) {
            return true
        }
        return false
    }
    
    /// Returns the maximum element in this collection
    /// by comparing the given property.
    ///
    /// If this collection is empty, returns `nil`.
    ///
    /// - Parameter property: A closure that returns
    /// the compared property of each element.
    ///
    /// - Complexity: O(`count`)
    func max<T : Comparable>(by property: (Element) -> T) -> Element? {
        // Check if this collection is empty.
        guard let first = first else { return nil }
        var maxElement = first
        var maxProperty = property(first)
        // Update the above values if there exists
        // an element whose property is greater
        // than `maxProperty`.
        for element in dropFirst() {
            let property = property(element)
            if property > maxProperty {
                maxElement = element
                maxProperty = property
            }
        }
        return maxElement
    }
}
