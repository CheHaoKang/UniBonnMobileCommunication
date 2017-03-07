#-*-coding:utf-8-*-
import urllib
import ast
import re
import collections
import subprocess
import json
import time
import sys
import copy

__author__ = 'Che-Hao Kang'

def processTOPOLOGY(file, routerNo):
    global jsonInfoAll

    try:
        file = open(file, 'r')
        content = file.read()
        jsonInfo = json.loads(content)
        jsonInfoAll[routerNo].append(jsonInfo)

        file.close()
    except:
        print (sys.exc_info())

def processMeasurementHTTPSingle():
    global folderPath
    file = open(folderPath + "/measurement_HTTP.txt", 'r')
    content = file.read()

    global httpDict
    timestampDict = {}

    # use regular expression to extract the data we want
    re_measurementHTTP = '([0-9]+)\s+Bytes:\s+([0-9]+)\s+Time:\s+([0-9\.]+)'
    reobj = re.compile(re_measurementHTTP, re.IGNORECASE)
    m = reobj.finditer(content)
    for i in m:
        byteSpentTime = []

        if i.group(1) != "":
            timestamp = float(i.group(1))            
            if timestamp in timestampDict.keys(): # if timestamp is the same, continue
                continue
            timestampDict[timestamp] = 1
        if i.group(2) != "":
            byteSpentTime.append(float(i.group(2))) # get transferred bytes
        if i.group(3) != "":
            byteSpentTime.append(float(i.group(3))) # get used time

        httpDict[long(timestamp)] = byteSpentTime
    file.close()


def processMeasurementPINGSingle():
    global folderPath
    # use awk to extract the data we want
    result = subprocess.Popen(['awk', 'NF==1{print $1} $2 ~ /packets/ {print $1 " " $4 " " $7} $1 ~ /round-trip/ {print $4}', folderPath + "/measurement_PING.txt"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    global pingInfoDict
    timestampList = []
    resultLines = result.stdout.readlines()

    # go through extracted data and put it into pingInfoDict
    i = 0
    lenResultLines = len(resultLines)
    while i < lenResultLines-2:
        if len(resultLines[i].split())==1 and len(resultLines[i].split('/'))==1:
            if len(resultLines[i + 1].split()) == 3:
                if len(resultLines[i+2].split('/'))==3:
                    timestamp = resultLines[i].rstrip()
                    timeStampSame = False
                    for tS in timestampList:
                        if tS == timestamp:
                            i += 3
                            timeStampSame = True
                            break

                    if timeStampSame == False:
                        timestampList.append(timestamp)
                        pingInfo = []
                        pingInfo.append(resultLines[i+1].rstrip())
                        pingInfo.append(resultLines[i+2].rstrip())
                        pingInfoDict[long(timestamp)] = pingInfo
                        i += 3
                else:
                    i += 1
            else:
                i += 1
        else:
            i += 1


def download():
    topologyUrls = []
    topologyUrls.append("http://gizmo-01.informatik.uni-bonn.de/status.json")
    topologyUrls.append("http://gizmo-02.informatik.uni-bonn.de/status.json")
    topologyUrls.append("http://gizmo-03.informatik.uni-bonn.de/status.json")
    topologyUrls.append("http://gizmo-04.informatik.uni-bonn.de/status.json")
    topologyUrls.append("http://gizmo-05.informatik.uni-bonn.de/status.json")
    topologyUrls.append("http://gizmo-06.informatik.uni-bonn.de/status.json")

    global jsonInfoAll

    downloadedFile = urllib.URLopener()
    httpUrl = "http://gizmo-01.informatik.uni-bonn.de/http.txt"
    pingUrl = "http://gizmo-01.informatik.uni-bonn.de/ping.txt"

    downloadCounter = 1
    global folderPath
    while downloadCounter <= 245:   # Every 30 seconds, we download once. So, this is for 2+ hours.
        for i in range(len(topologyUrls)):
            try:
                downloadedFile.retrieve(topologyUrls[i], folderPath + "/topology_" + str(i + 1) + "_status.json")
            except:
                print (sys.exc_info())
            processTOPOLOGY(folderPath + "/topology_" + str(i + 1) + "_status.json", i + 1)


        try:
            downloadedFile.retrieve(httpUrl, folderPath + "/measurement_HTTP.txt")
        except:
            print (sys.exc_info())


        try:
            downloadedFile.retrieve(pingUrl, folderPath + "/measurement_PING.txt")
        except:
            print (sys.exc_info())

        timeSum = 0.0

        tStart = time.time()
        processMeasurementHTTPSingle()
        tEnd = time.time()
        print ("Execution time for HTTP:", tEnd-tStart)

        timeSum += (tEnd-tStart)

        tStart = time.time()
        processMeasurementPINGSingle()
        tEnd = time.time()
        print ("Execution time for PING:", tEnd - tStart)

        timeSum += (tEnd - tStart)
        print ("timeSum:", timeSum, "\n")

        downloadCounter += 1
        if timeSum < 30:
            time.sleep(30 - timeSum)


def generateDataThroughputTime(startTime):
    global httpDict
    global timestampsHttp
    global folderPath

    bytesSent = 0
    timeUsed = 0
    with open(folderPath + "/httpMeasurementTable.txt", "w") as oF:
        oF.write("timestamp\tthroughput\tbytes\n")

        for time in timestampsHttp:
            if time > startTime: # only use data from startTime
                bytesSent += httpDict[time][0]
                timeUsed += httpDict[time][1]
                oF.write(str(time) + "\t" + str(int(float(bytesSent) / float(timeUsed))) + "\t" + str(float(bytesSent)) + "\n")  # bytes / seconds


def generateLossRTTTime(startTime):
    global pingInfoDict
    global timestampsPing
    global folderPath

    with open(folderPath + "/pingMeasurementTable.txt", "w") as oF:
        oF.write("timestamp\tpacketloss\tmin\tavg\tmax\n")

        for time in timestampsPing:
            if time > startTime: # only use data from startTime
                oF.write(str(time) + "\t" + str(pingInfoDict[time][0].split()[2].replace("%", "")) + "\t" + str(pingInfoDict[time][1].split('/')[0]) + "\t" + str(pingInfoDict[time][1].split('/')[1]) + "\t" + str(pingInfoDict[time][1].split('/')[2]) + "\n")


# [linkQuality, neighborLinkQuality, tcEdgeCost, number, timestamp]
def computeAvg(lastHopIP, destinationIP, linkQuality, neighborLinkQuality, tcEdgeCost):
    global linkCostDict
    return \
    float(linkCostDict[lastHopIP, destinationIP][0] * linkCostDict[lastHopIP, destinationIP][3] + linkQuality) / float(linkCostDict[lastHopIP, destinationIP][3] + 1), \
    float(linkCostDict[lastHopIP, destinationIP][1] * linkCostDict[lastHopIP, destinationIP][3] + neighborLinkQuality) / float(linkCostDict[lastHopIP, destinationIP][3] + 1), \
    float(linkCostDict[lastHopIP, destinationIP][2] * linkCostDict[lastHopIP, destinationIP][3] + tcEdgeCost) / float(linkCostDict[lastHopIP, destinationIP][3] + 1)


def findBestRouteRecur(topology, nowNode, cost, routeList):
    global routeAllDict

    if str(nowNode)=="10.0.0.6":
        routeList.append(nowNode)
        routeAllDict[cost] = routeList
        return

    for key in topology.keys():
        if str(key[0]) == str(nowNode):
            routeListBak = copy.copy(routeList)
            routeList.append(nowNode)

            topologyCopy = topology.copy()
            del topologyCopy[key]

            findBestRouteRecur(topologyCopy, key[1], cost+topology[key][2], routeList)
            routeList = copy.copy(routeListBak)


def findBestRoute(topology):
    for key in topology.keys():
        if str(key[0])=="10.0.0.1":
            routeList = []
            routeList.append("10.0.0.1")

            topologyCopy = topology.copy()
            del topologyCopy[key]

            findBestRouteRecur(topologyCopy, key[1], topology[key][2], routeList)


if __name__ == "__main__":
    folderPath = "Practical_2/"

    # List jsonInfoAll is to store every router's json files' content
    jsonInfoAll = []
    for i in range(1, 8):
        jsonInfoAll.append([])

    # Dictionary httpDict is to save HTTP throughput measurement
    httpDict = {}
    # Dictionary pingInfoDict is to save End-to-end delay and loss measurement
    pingInfoDict = {}

    # @@@+++++ turn on when downloading
    download()
    
    # put http measurement into a file for future use
    httpAllTxt = open(folderPath + '/measurement_HTTP_ALL.txt', 'w')
    httpAllTxt.write(str(httpDict))
    httpAllTxt.close()
    
    # put ping measurement into a file for future use
    pingAllTxt = open(folderPath + '/measurement_PING_ALL.txt', 'w')
    pingAllTxt.write(str(pingInfoDict))
    pingAllTxt.close()
    
    # Write all jsons to a file
    jsonAllTxt = open(folderPath + '/topologyJson_ALL.json', 'w')
    jsonAllTxt.write(json.dumps(jsonInfoAll))
    jsonAllTxt.close()
    
    # Separate jsons to different files (routers)
    file = open(folderPath + "/topologyJson_ALL.json", 'r')
    content = file.read()
    jsonInfoAll = json.loads(content)
    for i in range(1, 7):
        jsonTxt = open(folderPath + "/topologyJson_" + str(i) + "_ALL.json", 'w')
        jsonTxt.write(json.dumps(jsonInfoAll[i]))
        jsonTxt.close()
    # sys.exit(0)
    # @@@----- turn on when downloading


    # @@@+++++++ Process topology json - timestamps are in order
    timestampsJsonAll = []  # this list contains 6 lists to include timestamps of each router
    maximumNumJson = [0, -1] # the maximum number of how many timestamps in all routers => [1, 245] => means router 1 has the maximum of 245 timestamps
    
    for i in range(1, 8):
        timestampsJsonAll.append([])

    # Import jsons from separate files
    for i in range(1, 7):
        file = open(folderPath + "/topologyJson_" + str(i) + "_ALL.json", 'r')  # , encoding='UTF-8')
        content = file.read()
        jsonInfoAll[i] = json.loads(content)

        # append timestamps of one router
        for j in range(len(jsonInfoAll[i])):
            timestampsJsonAll[i].append(jsonInfoAll[i][j]['systemTime'])
        file.close()

        # Check if the number of json files is higher
        if len(timestampsJsonAll[i]) > maximumNumJson[1]:
            maximumNumJson[0] = i
            maximumNumJson[1] = len(timestampsJsonAll[i])

    # this list is to record the current timestamp of one router 
    nowJsonIndexAll = []
    for i in range(1, 8):
        nowJsonIndexAll.append(0)

    # this list is to store topology information
    linkCostDictList = []
    # go through all timestamps of the maximum
    for i in range(maximumNumJson[1]):
        linkCostDict = {}
        lenTopology = len(jsonInfoAll[maximumNumJson[0]][i]['topology'])
        for j in range(lenTopology):
            destinationIP = jsonInfoAll[maximumNumJson[0]][i]['topology'][j]['destinationIP']
            lastHopIP = jsonInfoAll[maximumNumJson[0]][i]['topology'][j]['lastHopIP']
            linkQuality = jsonInfoAll[maximumNumJson[0]][i]['topology'][j]['linkQuality']
            neighborLinkQuality = jsonInfoAll[maximumNumJson[0]][i]['topology'][j]['neighborLinkQuality']
            tcEdgeCost = jsonInfoAll[maximumNumJson[0]][i]['topology'][j]['tcEdgeCost']

            if not (lastHopIP, destinationIP) in linkCostDict.keys():
                linkCostDict[lastHopIP, destinationIP] = [linkQuality, neighborLinkQuality, tcEdgeCost, 1, jsonInfoAll[maximumNumJson[0]][i]['systemTime']]
            else:
                # [linkQuality, neighborLinkQuality, tcEdgeCost, number, timestamp]
                linkQuality, neighborLinkQuality, tcEdgeCost = computeAvg(lastHopIP, destinationIP, linkQuality, neighborLinkQuality, tcEdgeCost)
                linkCostDict[lastHopIP, destinationIP] = [linkQuality, neighborLinkQuality, tcEdgeCost, linkCostDict[lastHopIP, destinationIP][3] + 1, jsonInfoAll[maximumNumJson[0]][i]['systemTime']]

        # loop all routers to find the similar timestamp and then aggregate data for the same lastHopIP and destinationIP
        for routerNo in range(1, 7):
            if routerNo == maximumNumJson[0]:
                continue

            found = ''
            for index in range(nowJsonIndexAll[routerNo], len(timestampsJsonAll[routerNo])):
                if (timestampsJsonAll[routerNo][index] >= jsonInfoAll[maximumNumJson[0]][i]['systemTime']-5) and   \
                    (timestampsJsonAll[routerNo][index] <= jsonInfoAll[maximumNumJson[0]][i]['systemTime']+5):
                    found = index
                    nowJsonIndexAll[routerNo] = index + 1
                    break

            if found != '':
                lenTopo = len(jsonInfoAll[routerNo][found]['topology'])
                for indexTopo in range(lenTopo):
                    destinationIP = jsonInfoAll[routerNo][found]['topology'][indexTopo]['destinationIP']
                    lastHopIP = jsonInfoAll[routerNo][found]['topology'][indexTopo]['lastHopIP']
                    linkQua = jsonInfoAll[routerNo][found]['topology'][indexTopo]['linkQuality']
                    neighborLinkQua = jsonInfoAll[routerNo][found]['topology'][indexTopo]['neighborLinkQuality']
                    tcEdgeCo = jsonInfoAll[routerNo][found]['topology'][indexTopo]['tcEdgeCost']

                    if not (lastHopIP, destinationIP) in linkCostDict.keys():
                        linkCostDict[lastHopIP, destinationIP] = [linkQua, neighborLinkQua, tcEdgeCo, 1, jsonInfoAll[maximumNumJson[0]][i]['systemTime']]
                    else:
                        # [linkQua, neighborLinkQua, tcEdgeCo, number, timestamp]
                        linkQua, neighborLinkQua, tcEdgeCo = computeAvg(lastHopIP, destinationIP, linkQua, neighborLinkQua, tcEdgeCo)
                        linkCostDict[lastHopIP, destinationIP] = [linkQua, neighborLinkQua, tcEdgeCo, linkCostDict[lastHopIP, destinationIP][3] + 1, jsonInfoAll[maximumNumJson[0]][i]['systemTime']]
        ### END --- for routerNo in range(1, 7):
        linkCostDictList.append(linkCostDict)
    ### END ------------- for i in range(maximumNumJson[1]):

    counter = 0
    linkFrom = []
    linkTo = []
    # >>>>>>>>> Generate linkCostTable when links disappear or show up
    for item in linkCostDictList:
        counter += 1

        if not linkFrom:
            linkChange = True
        else:
            linkChange = False
            for index in range(len(linkFrom)): # check existing links disappear or not
                linkDisappear = True
                for key in item.keys(): # (u'10.0.0.2', u'10.0.0.1'): [1.0, 1.0, 1024.0, 6, 1466541400]
                    if str(linkFrom[index])==str(key[0]) and str(linkTo[index])==str(key[1]):
                        linkDisappear = False
                        break

                if linkDisappear:
                    linkChange = True
                    break

            if not linkChange:
                for key in item.keys(): # check new links show up or not
                    linkDisappear = True
                    for index in range(len(linkFrom)):
                        if str(linkFrom[index])==str(key[0]) and str(linkTo[index])==str(key[1]):
                            linkDisappear = False
                            break

                    if linkDisappear:
                        linkChange = True
                        break

        if linkChange:
            with open(folderPath + "/linkCostTable_" + str(counter) + ".txt", "w") as oF:
                oF.write("From\t\tTo\t\t\tLinkQuality\t\tNeighborLinkQuality\t\ttcEdgeCost\t\tTimestamp\n")
                linkFrom = []
                linkTo = []

                for key in item.keys():
                    linkFrom.append(key[0])
                    linkTo.append(key[1])

                    oF.write(str(key[0]) + "\t" + str(key[1]) + "\t" + str(item[key][0]) + "\t" + str(item[key][1]) + "\t" + \
                             str(item[key][2]) + "\t" + str(item[key][4]) + "\n")

            # generate a file which contains the best route information
            routeAllDict = {}
            # findBestRoute will call findBestRouteRecur to find out the best route
            findBestRoute(item)
            with open(folderPath + "/linkBestRoute_" + str(counter) + ".txt", "w") as oF:
                oF.write("From\tTo\tCost\n")
                for key in sorted(routeAllDict):
                    for index in range(len(routeAllDict[key])-1):
                        oF.write(str(routeAllDict[key][index]) + "\t" + str(routeAllDict[key][index+1]) + "\t" + str(key) + "\t" + "\n")
                    break
    #<<<<<<<<< Generate linkCostTable when links disappear or show up


    #>>>>>>>>> Examine costs change significantly or not
    counter = 0
    # previousItem is compared with the current item
    previousItem = {}
    for item in linkCostDictList:
        counter += 1

        if counter==1:
            previousItem = item
            continue

        linkCostChange = False
        for key in previousItem.keys():
            if key in item:
                # if the LQ*NLQ is 0.4 higher or lower than the previous one, we mark it
                if (abs(previousItem[key][0]*previousItem[key][1] - item[key][0]*item[key][1])) > 0.4:
                    linkCostChange = True
                    previousItem = item
                    break

        if linkCostChange:
            with open(folderPath + "/linkCostTable_" + str(counter) + ".txt", "w") as oF:
                oF.write("From\t\tTo\t\t\tLinkQuality\t\tNeighborLinkQuality\t\ttcEdgeCost\t\tTimestamp\n")

                for key in item.keys():
                    oF.write(str(key[0]) + "\t" + str(key[1]) + "\t" + str(item[key][0]) + "\t" + str(item[key][1]) + "\t" + \
                             str(item[key][2]) + "\t" + str(item[key][4]) + "\n")

            routeAllDict = {}
            findBestRoute(item)
            with open(folderPath + "/linkBestRoute_" + str(counter) + ".txt", "w") as oF:
                oF.write("From\tTo\tCost\n")
                for key in sorted(routeAllDict):
                    for index in range(len(routeAllDict[key])-1):
                        oF.write(str(routeAllDict[key][index]) + "\t" + str(routeAllDict[key][index+1]) + "\t" + str(key) + "\n")
                    break
    #<<<<<<<<< Examine costs change significantly or not
    # @@@--------- Process topology json


    # @@@++++++++ Process http://gizmo-01.informatik.uni-bonn.de/http.txt
    httpDict = {}
    httpAllTxt = open(folderPath + '/measurement_HTTP_ALL.txt', 'r')
    content = httpAllTxt.read()
    httpAllTxt.close()
    httpDict = ast.literal_eval(content)

    timestampsHttp = []
    for time in sorted(httpDict):
        timestampsHttp.append(time)
    # only use data from timestamp 1466541400
    generateDataThroughputTime(1466541400)
    # @@@-------- processMeasurementHTTP()


    # @@@+++++++++ Process http://gizmo-01.informatik.uni-bonn.de/ping.txt
    pingInfoDict = {}
    pingAllTxt = open(folderPath + '/measurement_PING_ALL.txt', 'r')
    pingInfoDict = ast.literal_eval(pingAllTxt.read())
    pingAllTxt.close()

    timestampsPing = []
    for time in sorted(pingInfoDict):
        timestampsPing.append(time)
    # only use data from timestamp 1466541400
    generateLossRTTTime(1466541400)
    # @@@--------------processMeasurementPING()