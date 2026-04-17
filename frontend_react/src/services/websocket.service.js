import SockJS from 'sockjs-client';
import { Client } from '@stomp/stompjs';

let stompClient = null;

const WS_URL = import.meta.env.VITE_WS_URL || '/ws/chat';

export const websocketService = {
    connect: (onMessageReceived) => {
        if (stompClient?.active) return;

        const client = new Client({
            webSocketFactory: () => new SockJS(WS_URL),
            reconnectDelay: 5000,
            debug: () => { },
            beforeConnect: () => {
                const token = localStorage.getItem('token');
                client.connectHeaders = token ? { Authorization: `Bearer ${token}` } : {};
            },
            onConnect: () => {
                let user = null;
                try {
                    user = JSON.parse(localStorage.getItem('user') || 'null');
                } catch (_e) {
                    user = null;
                }

                if (user?.id) {
                    stompClient.subscribe(`/queue/messages-${user.id}`, (message) => {
                        if (onMessageReceived) {
                            onMessageReceived(JSON.parse(message.body));
                        }
                    });
                }
            },
            onStompError: (frame) => {
                console.error('WebSocket STOMP Error:', frame?.headers?.message || frame);
            },
            onWebSocketError: (event) => {
                console.error('WebSocket Error:', event);
            },
        });

        stompClient = client;
        client.activate();
    },

    sendMessage: (message) => {
        if (stompClient && stompClient.connected) {
            stompClient.publish({
                destination: '/app/chat.send',
                body: JSON.stringify(message),
            });
            return true;
        }
        return false;
    },

    disconnect: () => {
        if (stompClient?.active) {
            const client = stompClient;
            stompClient = null;
            client.deactivate();
            return;
        }
        stompClient = null;
        console.log("Disconnected from WebSocket");
    }
};
