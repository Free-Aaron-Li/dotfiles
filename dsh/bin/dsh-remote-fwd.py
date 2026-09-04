#!/usr/bin/env python3
"""dsh-remote-fwd: 把 easytier 虚拟 IP 的 3080 转发到本机 127.0.0.1:3080（DSH web 只监听回环）。
用法: python3 dsh-remote-fwd.py [bind_ip] [listen_port] [target_port]
"""
import socket, threading, sys, os

BIND_IP = sys.argv[1] if len(sys.argv) > 1 else "10.10.10.22"
LISTEN_PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 3080
TARGET_PORT = int(sys.argv[3]) if len(sys.argv) > 3 else 3080
TARGET_HOST = "127.0.0.1"

def pipe(src, dst):
    try:
        while True:
            data = src.recv(65536)
            if not data:
                break
            dst.sendall(data)
    except OSError:
        pass
    finally:
        for s in (src, dst):
            try: s.shutdown(socket.SHUT_RDWR)
            except OSError: pass
            try: s.close()
            except OSError: pass

def handle(client):
    try:
        upstream = socket.create_connection((TARGET_HOST, TARGET_PORT), timeout=10)
    except OSError:
        client.close(); return
    threading.Thread(target=pipe, args=(client, upstream), daemon=True).start()
    threading.Thread(target=pipe, args=(upstream, client), daemon=True).start()

def main():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((BIND_IP, LISTEN_PORT))
    srv.listen(64)
    print(f"dsh-remote-fwd: {BIND_IP}:{LISTEN_PORT} -> 127.0.0.1:{TARGET_PORT} (pid {os.getpid()})", flush=True)
    while True:
        c, _ = srv.accept()
        threading.Thread(target=handle, args=(c,), daemon=True).start()

if __name__ == "__main__":
    main()
