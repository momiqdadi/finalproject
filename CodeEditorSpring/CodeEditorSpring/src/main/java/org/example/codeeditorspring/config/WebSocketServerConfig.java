package org.example.codeeditorspring.config;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.extern.slf4j.Slf4j;
import org.example.codeeditorspring.MyWebSocketServer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.net.InetSocketAddress;

@Component
@Slf4j
public class WebSocketServerConfig {
    private static final Logger log = LoggerFactory.getLogger(WebSocketServerConfig.class);
    private MyWebSocketServer webSocketServer;

    @Value("${websocket.port}")
    private int websocketPort;

    @PostConstruct
    public void init() {
        InetSocketAddress address = new InetSocketAddress("0.0.0.0", websocketPort);
        webSocketServer = new MyWebSocketServer(address);
        webSocketServer.start();
        log.info("WebSocket server started on port: {}", websocketPort);
    }

    @PreDestroy
    public void cleanup() {
        if (webSocketServer != null) {
            try {
                webSocketServer.stop();
                log.info("WebSocket server stopped successfully");
            } catch (InterruptedException e) {
                log.error("Error stopping WebSocket server", e);
                Thread.currentThread().interrupt();
            }
        }
    }
}