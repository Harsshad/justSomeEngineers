from config import Settings
from tavily import TavilyClient
import trafilatura as tf
settings = Settings()
tavily_client = TavilyClient(api_key=settings.TAVILY_API_KEY)

class SearchService:
    def web_search(self, query: str):
        try:
            results = []
            response = tavily_client.search(query, max_results=5)
            if not response or not isinstance(response, dict):
                print("Search service returned no response or invalid format")
                return []
            
            search_results = response.get("results", [])
            for result in search_results:
                downloaded = tf.fetch_url(result.get("url"))
                if not downloaded:
                    print(f"Failed to download content from URL: {result.get('url')}")
                    continue
                content = tf.extract(downloaded, include_comments=False)
                results.append({
                    "title": result.get("title", ""),
                    "url": result.get("url"),
                    "content": content
                })
            return results
        except Exception as e:
            print(f"Error in web_search: {e}")
            return []
        