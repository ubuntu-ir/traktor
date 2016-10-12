#!/usr/bin/env python3
import requests, json, random, sys

url = "http://maders.ir/bridges/bridges.json"

response = requests.get(url)
temp_bridge = response.json()['bridge']

if len(sys.argv) == 2:
    if int(sys.argv[1]) <= len(temp_bridge):
        number_of_output_bridge = int(sys.argv[1])
    else:
        number_of_output_bridge = 3
else:
    number_of_output_bridge = 3

bridge = []

for i in range(number_of_output_bridge):
    index = random.randint(0, (len(temp_bridge) -1)) 
    bridge.append(temp_bridge[index])
    temp_bridge.pop(index)

for i in range(len(bridge)):
    print(bridge[i])	
