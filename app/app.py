from http.server import HTTPServer, BaseHTTPRequestHandler as Base
import logging # for logging
import os  # for getting the environment variables

LOG_LEVEL=os.getenv("LOG_LEVEL","INFO")


logging.basicConfig(
	level=getattr(logging, LOG_LEVEL),
	format="%(asctime)s - %(message)s")


PORT=int(os.getenv("PORT","8080"))


class Handler(Base):
	def do_GET(self):
		logging.info(f"Request recieved: {self.path}")

		if self.path == "/health":
			self.send_response(200)
			self.end_headers()
			self.wfile.write(b"OK")
		else:
			self.send_response(404)
			self.end_headers()
			self.wfile.write(b"Not Found")



server=HTTPServer(("0.0.0.0",PORT), Handler)
logging.info(f"Infra Demo service started on port {PORT}")

server.serve_forever()


