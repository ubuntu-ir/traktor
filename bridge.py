#!/usr/bin/env python3
import requests, json, random

number_of_output_bridge = 3
url = "http://maders.ir/bridges/bridges.json"

respone = requests.get(url)
temp_bridge = respone.json()['bridge']

bridge = []

for i in range(number_of_output_bridge):
    index = random.randint(0, (len(temp_bridge) -1)) 
    bridge.append(temp_bridge[index])
    temp_bridge.pop(index)

for i in range(len(bridge)):
    print(bridge[i])	
