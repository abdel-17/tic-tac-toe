extension Collection {
    /// Returns `true` if all elements in this collection
    /// are equal by comparing the values resulting from
    /// applying `transform` to each element.
    ///
    /// If this collection is empty, returns `true`.
    ///
    /// - Parameter transform: The closure to
    /// transform each element to its compared value.
    ///
    /// - Complexity: O(`count`)
    func allEqual<T : Equatable>(by transform: (Element) -> T) -> Bool {
        // Check if this collection is empty.
        guard let first = first else { return true }
        // Transform the first value only once.
        let transformedFirst = transform(first)
        // We drop the first element because as
        // comparing it to itself is redundant.
        for element in dropFirst() where transformedFirst != transform(element) {
            return false
        }
        return true
    }
    
    /// Returns `true` if any of this collection's
    /// elements satisfy the given predicate.
    ///
    /// If this collection is empty, returns `false`.
    func anySatisfy(_ predicate: (Element) -> Bool) -> Bool {
        for element in self where predicate(element) {
            return true
        }
        // Not a single element satisfied `predicate`.
        return false
    }
    
    /// Returns the maximum element in this collection
    /// by comparing the values resulting from applying
    /// `transform` to each element.
    ///
    /// If this collection is empty, returns `nil`.
    ///
    /// - Parameter transform: The closure to
    /// transform each element to its compared value.
    ///
    /// - Complexity: O(`count`)
    func max<T : Comparable>(by transform: (Element) -> T) -> Element? {
        // Check if this collection is empty.
        guard let first = first else { return nil }
        var max = (element: first, transformed: transform(first))
        // Update `max` if there exists an element whose
        // transformed value is greater. We drop the first
        // element as comparing it to itself is redundant.
        for element in dropFirst() {
            let transformed = transform(element)
            if transformed > max.transformed {
                max.element = element
                max.transformed = transformed
            }
        }
        return max.element
    }
}
