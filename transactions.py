# takes cleaned ClickStreamData.csv file and turns it into a transaction file
from datetime import datetime as DT
import re

fi = open("ClickStreamData.csv", "r")
fo = open("TransactionData.csv", "w")
FMT = "%d-%m-%Y %H:%M"

header = ["BOOK", "MOVIE", "VGAME", "ELEC", "COMP", "H&G", "HANDBG", "CLOTH", "SHOE", "OUTDRS", "CARS", "TOOL", "ACCES", "GROC", "UNKNWN"]

# dictionary for each user's visit
userProd = {"BOOK" : 0, "MOVIE" : 0, "VGAME" : 0, "ELEC" : 0, "COMP" : 0, "H&G" : 0, "HANDBG" : 0, "CLOTH" : 0,
            "SHOE" : 0, "OUTDRS" : 0, "CARS" : 0, "TOOL" : 0, "ACCES" : 0, "GROC" : 0, "UNKNWN" : 0}
zeroProd = userProd
#~ print(userProd)

# set the header
#~ headLine = "UserID," + ",".join(str(x) for x in header)
#~ fo.write(headLine + "\n")

# read header line
null = fi.readline()
multicount = 0
maxitems = 0

#~ for item in header:
	#~ fo.write(item + "\n")


# write the transaction on the line
def writeTransaction(uid, prod):
	global fo
	global header
	global multicount
	global maxitems
	p = ""
	for item in header:
		if prod[item] > 0:
			p = p + item + ","
		#~ p = p + str(prod[item]) + ","
	if p.count(',') > 1:
		fo.write(p[:-1] + "\n")
	multicount += p.count(',') > 1
	if p.count(',') > maxitems:
		maxitems = p.count(',')
	

# zero-out the user product
def resetUserProduct(product):
	newproduct = {}
	for key, value in product.iteritems():
		newproduct[key] = 0
	return newproduct


firstLine = fi.readline()
lastTime, product, lastUser = firstLine.split(",")
userProd[product] = 1

#for i in range(0,10):
for line in fi:
	#~ line = fi.readline()
	time, product, user = line.split(",")
	# if the users are different, then we need to write the transaction to file
	#  and reset everything, then cycle to the next line
	if lastUser != user:
		lastTime = time
		#~ if sum(userProd.itervalues()) > 1:  # only write to file if more than 1 visit
		writeTransaction(lastUser, userProd)
		userProd = resetUserProduct(userProd)
		userProd[product] += 1
		lastUser = user
		continue
	# check the time difference between last transactions, if the minutes are:
	#  less than 15, then it's still the same transaction
	#  more than 15, then it's a new transaction & we need to
	#  write the transaction
	dT = abs(DT.strptime(lastTime,FMT) - DT.strptime(time,FMT))
	if dT.total_seconds()/60 <= 15:
		userProd[product] += 1
	else:
		#~ if sum(userProd.itervalues()) > 1:
		writeTransaction(user, userProd)
		userProd = resetUserProduct(userProd)
		userProd[product] += 1
	lastTime = time
		
print("Total multiple item visits: %d\nLeading to %f percent of visits\n" % (multicount, 100*multicount/23030.0))
print("Highest number of items in one visit: %d" % maxitems)
