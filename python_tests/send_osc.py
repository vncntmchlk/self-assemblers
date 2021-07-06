from pythonosc.udp_client import SimpleUDPClient

ip = "192.168.178.28"
port = 9000

client = SimpleUDPClient(ip, port)  # Create client

client.send_message("/some/address", 123)   # Send float message
client.send_message("/some/address", [1, 2., "hello"])  # Send message with int, float and string