package org.example.codeeditorspring.entities;

import org.java_websocket.WebSocket;

import java.util.ArrayList;
import java.util.List;

public class Session {
    private List<WebSocket> connections; // Use a list to hold multiple WebSocket connections
    private String path;

    public Session(WebSocket initialConnection, String path) {
        this.connections = new ArrayList<>();
        this.connections.add(initialConnection);
        this.path = path;
    }

    public void addConnection(WebSocket conn) {
        connections.add(conn);
    }

    public List<WebSocket> getConnections() {
        return connections;
    }

    public String getPath() {
        return path;
    }
}
