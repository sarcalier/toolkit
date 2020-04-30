import re

###########
#func
###########

def Get_DicFromLog (logfile):
    lineformat = re.compile(r"""(?P<ipaddress>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - - \[(?P<dateandtime>\d{2}\/[a-z]{3}\/\d{4}:\d{2}:\d{2}:\d{2} (\+|\-)\d{4})\] ((\"(GET|POST) )(?P<url>.+)(http\/1\.1")) (?P<statuscode>\d{3}) (?P<bytessent>\d+)""", re.IGNORECASE)

    DictOfBS = {}

    for l in logfile.readlines():
        data = re.search(lineformat, l)
        if data:
            datadict = data.groupdict()
            ip = datadict["ipaddress"]
            bytessent = int(datadict["bytessent"])
            
            #catching up the empty key
            try:
                DictOfBS[ip]
            except:      
                DictOfBS.update({ip : bytessent})
            
            DictOfBS.update({ip : (DictOfBS[ip] + bytessent)})
    return  DictOfBS

#############
#vars
#############
i = 0
PrintLimnit = 10

#############
#main
#############
if __name__ == '__main__':
    logfile = open("access.log")
    dictBS = Get_DicFromLog(logfile)
    print(dictBS)

    #sorted output time
    for key, value in sorted(dictBS.items(), key=lambda item: item[1], reverse=True):
        i = i + 1
        print("%s: %s" % (key, value))
        if i==PrintLimnit:
            break

    logfile.close()