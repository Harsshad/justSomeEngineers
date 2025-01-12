import asyncio
from fastapi import FastAPI, WebSocket

from services.llm_service import LLMService
from services.sort_source_service import SortSourceService
from services.search_service import SearchService
from pydantic_models.chat_body import ChatBody

app = FastAPI()

search_service = SearchService()
sort_source_service = SortSourceService()
llm_service = LLMService()

# WebSocket chat endpoint
@app.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        await asyncio.sleep(0.1)
        data = await websocket.receive_json()
        query = data.get("query")

        if not query:
            await websocket.send_json({"type": "error", "data": "Query is missing"})
            return

        if "codefusion" in query.lower():  # Handle CodeFusion-specific queries
            for chunk in llm_service.generate_codefusion_response(query):
                await asyncio.sleep(0.1)
                await websocket.send_json({"type": "content", "data": chunk})
            return

        search_results = search_service.web_search(query)
        if not search_results:
            await websocket.send_json({"type": "error", "data": "No search results found"})
            return

        sorted_results = sort_source_service.sort_sources(query, search_results)
        await asyncio.sleep(0.1)
        if not sorted_results:
            await websocket.send_json({"type": "error", "data": "No relevant results found"})
            return

        await websocket.send_json({"type": "search_result", "data": sorted_results})
        for chunk in llm_service.generate_response(query, sorted_results):
            await asyncio.sleep(0.1)
            await websocket.send_json({"type": "content", "data": chunk})
    except Exception as e:
        print(f"Unexpected error occurred: {e}")
        await websocket.send_json({"type": "error", "data": "Unexpected error occurred"})
    finally:
        await websocket.close()

# Chat endpoint for POST requests
@app.post("/chat")
def chat_endpoint(body: ChatBody):
    """
    Handles both generic and CodeFusion-specific queries via POST.
    """
    if "codefusion" in body.query.lower():
        return {"response": list(llm_service.generate_codefusion_response(body.query))}
    
    search_results = search_service.web_search(body.query)
    sorted_results = sort_source_service.sort_sources(body.query, search_results)
    response = llm_service.generate_response(body.query, sorted_results)
    return {"response": list(response)}
