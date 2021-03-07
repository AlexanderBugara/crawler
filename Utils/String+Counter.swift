import Foundation

extension String
{
    /**
     Counts the occurrences of a given substring by calling Strings `range(of:options:range:locale:)` method multiple times.

     - Parameter substring : The string to search for, optional for convenience

     - Parameter options : String compare-options to use while counting

     - Parameter locale : Locale to use while counting

     - Returns : The number of occurrences of the substring in this String
     */
    public func count(
        occurrencesOf substring: String?,
        options: String.CompareOptions = [],
        locale: Locale? = nil) -> Int
    {
        guard let substring = substring, !substring.isEmpty else { return 0 }

        var count = 0

        let searchRange = startIndex..<endIndex

        var searchStartIndex = searchRange.lowerBound
        let searchEndIndex = searchRange.upperBound

        while let rangeFound = range(of: substring, options: options, range: searchStartIndex..<searchEndIndex, locale: locale) {
            count += 1
            searchStartIndex = rangeFound.upperBound
        }

        return count
    }
}
