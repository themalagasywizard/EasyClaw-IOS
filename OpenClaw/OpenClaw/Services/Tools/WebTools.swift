//
//  WebTools.swift
//  OpenClaw
//

import Foundation

// MARK: - Web Search Tool

struct WebSearchTool: Tool {
    let name = "web_search"
    let description = "Search the web using Brave Search. Returns titles, URLs, and snippets for relevant results."
    
    var parameters: [String: Any] {
        buildParameters(
            properties: [
                "query": stringProperty(description: "Search query string"),
                "count": numberProperty(description: "Number of results (1-10, default: 5)")
            ],
            required: ["query"]
        )
    }
    
    func execute(arguments: [String: Any]) async throws -> String {
        guard let query = arguments["query"] as? String else {
            throw ToolError.invalidArguments("Missing 'query' parameter")
        }
        
        let count = arguments["count"] as? Int ?? 5
        
        guard let apiKey = KeychainService.shared.retrieve(for: .braveSearch) else {
            return "⚠️ Brave Search API key not configured. Add it in Settings."
        }
        
        // Build Brave Search API request
        var components = URLComponents(string: "https://api.search.brave.com/res/v1/web/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "\(min(count, 10))")
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ToolError.executionFailed("Brave Search API returned error")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let web = json["web"] as? [String: Any],
              let results = web["results"] as? [[String: Any]] else {
            throw ToolError.executionFailed("Invalid response from Brave Search")
        }
        
        if results.isEmpty {
            return "No search results found for '\(query)'"
        }
        
        var output = "Search results for '\(query)':\n\n"
        
        for (index, result) in results.enumerated() {
            let title = result["title"] as? String ?? "No title"
            let url = result["url"] as? String ?? ""
            let description = result["description"] as? String ?? ""
            
            output += "\(index + 1). **\(title)**\n"
            output += "   \(url)\n"
            if !description.isEmpty {
                output += "   \(description)\n"
            }
            output += "\n"
        }
        
        return output
    }
}

// MARK: - Web Fetch Tool

struct WebFetchTool: Tool {
    let name = "web_fetch"
    let description = "Fetch and extract readable content from a URL. Converts HTML to clean text/markdown."
    
    var parameters: [String: Any] {
        buildParameters(
            properties: [
                "url": stringProperty(description: "HTTP or HTTPS URL to fetch"),
                "maxChars": numberProperty(description: "Maximum characters to return (default: 8000)")
            ],
            required: ["url"]
        )
    }
    
    func execute(arguments: [String: Any]) async throws -> String {
        guard let urlString = arguments["url"] as? String,
              let url = URL(string: urlString) else {
            throw ToolError.invalidArguments("Invalid URL")
        }
        
        // Security: Only allow http/https
        guard ["http", "https"].contains(url.scheme?.lowercased()) else {
            throw ToolError.invalidArguments("Only HTTP/HTTPS URLs are supported")
        }
        
        let maxChars = arguments["maxChars"] as? Int ?? 8000
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", 
                        forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ToolError.executionFailed("Failed to fetch URL (HTTP error)")
        }
        
        // Try to decode as UTF-8
        guard let html = String(data: data, encoding: .utf8) else {
            throw ToolError.executionFailed("Unable to decode page content")
        }
        
        // Extract readable content (very basic implementation)
        let cleaned = extractReadableContent(from: html)
        let truncated = String(cleaned.prefix(maxChars))
        
        if truncated.count < cleaned.count {
            return truncated + "\n\n... (truncated)"
        }
        
        return truncated
    }
    
    // MARK: - Helper
    
    private func extractReadableContent(from html: String) -> String {
        // Remove scripts and styles
        var text = html
        text = text.replacingOccurrences(of: "<script[^>]*>.*?</script>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style[^>]*>.*?</style>", with: "", options: .regularExpression)
        
        // Remove HTML tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        // Decode HTML entities
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        
        // Clean up whitespace
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return text
    }
}
