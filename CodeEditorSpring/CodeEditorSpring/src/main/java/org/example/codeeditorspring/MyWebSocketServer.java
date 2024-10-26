package org.example.codeeditorspring;

import lombok.extern.slf4j.Slf4j;
import org.example.codeeditorspring.entities.Session;
import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.InetSocketAddress;
import java.util.*;

@Slf4j
public class MyWebSocketServer extends WebSocketServer {
    private final static Map<String, Session> sessionMap = new HashMap<>();
    private static final Logger log = LoggerFactory.getLogger(MyWebSocketServer.class);

    public MyWebSocketServer(InetSocketAddress address) {
        super(address);
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        System.out.println("New connection: " + conn.getRemoteSocketAddress());
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        System.out.println("Closed connection: " + conn.getRemoteSocketAddress());
        sessionMap.values().forEach(session -> session.getConnections().remove(conn));
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        System.out.println("Received message: " + message);
        String[] parts = message.split(":", 3);
        String action = parts[0];
        String sessionId = parts.length > 1 ? parts[1] : "";
        String content = parts.length > 2 ? parts[2] : "";

        switch (action) {
            case "create":
                createSession(sessionId, conn);
                break;
            case "join":
                joinSession(sessionId, conn);
                break;
            case "message":
                sendMessageToSession(sessionId, conn, content);
                break;
            default:
                conn.send("Unknown action: " + action);
                break;
        }
    }

    private void createSession(String sessionId, WebSocket conn) {
        synchronized (sessionMap) {
            if (!sessionMap.containsKey(sessionId)) {
                String[] params = sessionId.split(",");
                String id = params[0];
                String path = params[1];

                Session session = new Session(conn, path);
                sessionMap.put(id, session);
                conn.send("Session created: " + sessionId);
                System.out.println("Session created: " + sessionId);
            } else {
                sessionMap.get(sessionId).addConnection(conn); // Add to existing session
                conn.send("Joined existing session: " + sessionId);
            }
        }
    }

    private void joinSession(String sessionId, WebSocket conn) {
        synchronized (sessionMap) {
            Session session = sessionMap.get(sessionId);
            if (session != null) {
                session.addConnection(conn);
                conn.send("Joined session: " + sessionId + ", Path: " + session.getPath());
                System.out.println("Client joined session: " + sessionId);
            } else {
                conn.send("Session not found: " + sessionId);
            }
        }
    }

    private void sendMessageToSession(String sessionId, WebSocket sender, String content) {
        synchronized (sessionMap) {
            Session session = sessionMap.get(sessionId);
            if (session != null) {
                String fullMessage = "message:" + sessionId + ":" + content;
                for (WebSocket webSocket : session.getConnections()) {
                    if (webSocket != sender && webSocket.isOpen()) {
                        webSocket.send(fullMessage);
                        System.out.println("Sent message to client in session " + sessionId + ": " + fullMessage);
                    }
                }
            } else {
                sender.send("Session not found: " + sessionId);
            }
        }
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        log.error(ex.getMessage());
    }

    @Override
    public void onStart() {
        System.out.println("Server started successfully.");
    }

    public static void main(String[] args) {
        InetSocketAddress address = new InetSocketAddress("localhost", 8085);
        MyWebSocketServer server = new MyWebSocketServer(address);
        server.start();
        System.out.println("Server started on port 8080");
    }
}
