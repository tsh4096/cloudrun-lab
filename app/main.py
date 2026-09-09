import os
from http.server import BaseHTTPRequestHandler, HTTPServer

# Cloud Run gibt den Port ueber die Umgebungsvariable PORT vor.
# 8080 ist nur der Rueckfallwert fuer den Start auf dem eigenen Rechner.
PORT = int(os.environ.get("PORT", "8080"))

# Beliebiger eigener Wert, ueber den du spaeter das Deployment
# wiedererkennst. Kommt ebenfalls aus der Umgebung, nicht aus dem Code.
RELEASE = os.environ.get("RELEASE", "lokal")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"hello from {RELEASE}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()