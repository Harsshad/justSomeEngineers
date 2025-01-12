#google gemini service
import google.generativeai as genai
from config import Settings

settings = Settings()

class LLMService:
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel("gemini-2.0-flash-exp")
    
    def generate_response(self, query: str, search_results: list[dict] = None):
        """
        Enhanced to check for CodeFusion-specific queries.
        """
        if "codefusion" in query.lower():  # Detect CodeFusion-specific queries
            return self.generate_codefusion_response(query)

        # Use the existing TAVILY search results if provided
        context_text = "\n\n".join([
            f"Source {i+1} ({result['url']}):\n{result['content']}"
            for i, result in enumerate(search_results or [])
        ])
        
        full_prompt = f"""
        Context from web search:
        {context_text}
        
        Query: {query}
        Please provide a comprehensive, detailed, well-cited accurate response using the above context. Think and reason deeply. Ensure it answers the query the user is asking. Do not use your knowledge until it is absolutely necessary.
        """
        
        response = self.model.generate_content(full_prompt, stream=True)
        for chunk in response:
            yield chunk.text

    def generate_codefusion_response(self, query: str):
        """
        Generates responses for CodeFusion-specific questions.
        """
        codefusion_info = """
        CodeFusion is an all-in-one developer collaboration platform with features like:
        1. Q&A Forums
            Overview: A dedicated space for developers to ask and answer technical questions, collaborate on solving problems, and share their expertise with the community.
            Features:
            Categorized forums for different programming languages, frameworks, tools, and development methodologies.
            Search functionality to quickly find relevant discussions and solutions.
            Upvoting and downvoting of answers to ensure the most accurate and helpful responses rise to the top.
            Use Case: A developer facing an issue with Flutter state management can post a detailed question and receive targeted answers from the community.
        2. Mentorship
            Overview: A personalized mentorship platform where developers can connect with experienced professionals for career guidance, technical problem-solving, or learning a new technology.
            Features:
            Mentor profiles with detailed expertise, availability, and contact methods.
            Scheduling tools to book 1:1 mentorship sessions.
            Real-time chat and video calls for interactive learning.
            Mentorship categories (e.g., career guidance, project assistance, code reviews).
            Use Case: A junior developer struggling with backend architecture can schedule a session with a mentor specializing in Node.js and databases.
        3. Resource Library
            Overview: A curated repository of learning materials, including tutorials, videos, e-books, and project templates.
            Features:
            Organized categories for frontend, backend, mobile development, cloud computing, and more.
            Filter options based on difficulty level (beginner, intermediate, expert).
            Bookmarking and downloading resources for offline access.
            User submissions and peer reviews to keep content fresh and relevant.
            Use Case: A user looking to learn React can explore the library for beginner-friendly tutorials and a project template to start building.
        4. Job Recommendations
            Overview: A job board tailored specifically for developers, leveraging user skills, interests, and location preferences to recommend relevant opportunities.
            Features:
            Detailed job postings with company profiles, job descriptions, and application links.
            Notifications for new job postings in relevant categories.
            Tools to create and upload developer-friendly resumes and portfolios.
            Integration with LinkedIn and Indeed for profile synchronization.
            Use Case: A frontend developer searching for remote opportunities in React.js can receive personalized job recommendations from top tech companies.

        Let me know if you want more details about any module!
        """
        full_prompt = f"""
        The user asked about CodeFusion.
        Query: {query}
        Use the following details about CodeFusion to respond comprehensively:
        {codefusion_info}
        """
        response = self.model.generate_content(full_prompt, stream=True)
        for chunk in response:
            yield chunk.text
