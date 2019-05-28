from flask import Flask
import PiTraffic
import time

SouthRed = PiTraffic.Traffic("SOUTH", "RED")
SouthYellow = PiTraffic.Traffic("SOUTH", "YELLOW")
SouthGreen = PiTraffic.Traffic("SOUTH", "GREEN")


EastRed = PiTraffic.Traffic("EAST", "RED")
EastYellow = PiTraffic.Traffic("EAST", "YELLOW")
EastGreen = PiTraffic.Traffic("EAST", "GREEN")

NorthRed = PiTraffic.Traffic("NORTH", "RED")
NorthYellow = PiTraffic.Traffic("NORTH", "YELLOW")
NorthGreen = PiTraffic.Traffic("NORTH", "GREEN")


WestRed = PiTraffic.Traffic("WEST", "RED")
WestYellow = PiTraffic.Traffic("WEST", "YELLOW")
WestGreen = PiTraffic.Traffic("WEST", "GREEN")

Buzz = PiTraffic.Buzzer()

app = Flask(__name__)

@app.route("/traffic/kubewatch-webhook",methods=['GET', 'POST'])
def home():
    Buzz.on();
    time.sleep(0.2)
    Buzz.off();
    return "Still watching!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)

