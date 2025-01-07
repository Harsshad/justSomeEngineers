const ws = new WebSocket("ws://127.0.0.1:8000/ws/chat");

ws.onopen = () => {
    console.log("WebSocket connected");
    ws.send(JSON.stringify({ query: "Hello, ChatBot!" }));
};

ws.onmessage = (event) => {
    console.log("Message from server:", event.data);
};

ws.onerror = (error) => {
    console.error("WebSocket error:", error);
};

ws.onclose = () => {
    console.log("WebSocket closed");
};
