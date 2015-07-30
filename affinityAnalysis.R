# R code to do some affinity analysis on ClickStream data

# import libraries
library(arules, warn.conflicts=FALSE)
library(arulesViz, warn.conflicts=FALSE)
library(Rgraphviz, warn.conflicts=FALSE)

#------------------------------- function space ------------------------------#


###:: Do basic APRIORI analysis ::###
aprioriAnalysis <- function(fname){
   # read the transaction file in, then do the rules
   trans <- read.transactions(fname, format="basket", sep=",")
   supp <- c(0.01, 0.05, 0.10)
   conf <- c(0.30, 0.50, 0.70)
   for(S in supp){
      for(C in conf){
         rules <- apriori(trans, parameter=list(support=S, confidence=C, minlen=2))
         rules <- sort(rules, by="confidence")
         pname <- paste("itemFrequencyApriori", toString(S), toString(C), ".png", sep="")
         cat("Saving rules to ",pname)
         png(filename=pname, width=800, height=800)
         itemFrequencyPlot(trans, support=S, ylim=c(0,1))
         dev.off()
      }
   }
}

###:: Do basic ECLAT analysis ::###
eclatAnalysis <- function(fname){
   trans <- read.transactions(fname, format="basket", sep=",")
   supp <- c(0.01, 0.05, 0.10)
   conf <- c(0.30, 0.50, 0.70)
   for(S in supp){
      cat(" ==> Using supp=",S,"\n")
      rules <- eclat(trans, parameter=list(support=S, minlen=2, maxlen=12))
      rules <- sort(rules, by="support")
      pname <- paste("itemFrequencyEclat", toString(S), toString(C), ".png", sep="")
      plot(rules, method="paracoord", measure="lift",
           control=list(main="Parallel Coordinate plot", reorder=T))
      dev.off()
   }
}

###:: Do FP-growth analysis ::###
fpgrowth <- function(fname, transactions, parameters=list(support=0.60, confidence=0.80)){
   # get the frequent itemsets (outsources work to dude's code)
   freqItems <- getFrequentItems(fname, transactions, parameters$support*100,
                                 parameters$confidence*100)

   # get the rules from the frequent items
   rules <- ruleInduction(freqItems, transactions=transactions, confidence=parameters$confidence)

   return(rules)

}

###:: get the tree ::###
getFrequentItems <- function(fname, transactions, support, confidence){
   ofile = "fpgrowth-out.dat"
   # call the fpgrowth function
   cat("calling fpgrowth code....\n")
   fcall <- paste("/home/jdwood/debs/fpgrowth/fpgrowth/src/fpgrowth -s",
                  support, " -c", confidence, " -m1 -v" " ', fname, " ", ofile, sep = "")
   cat(fcall,"\n")
   system(fcall)
   cat("...done\n\n")

   # import the data back into R
   columnNumber <- max(count.fields(ofile))
   itemsets <- read.table(ofile, fill=T, col.names=1:columnNumber, colClasses="factor")

   # mark those to be removed and remove the empty cells
   toRemove <- apply(itemsets, 1, function(x) length(which(x != "")) > 1)
   itemsets <- apply(itemsets, 1, function(x) x[x != ""]);

   # format for processing
   itemsets <- as(itemsets, "itemMatrix")
   itemsets <- recode(itemsets, itemLabels(transactions))
   itemsets <- new("itemsets", items=itemsets)

   return(itemsets)
}

###:: invert the rules ::###
ruleInversion <- function(rule){
   return(new("rules", lhs=rhs(rule), rhs=lhs(rule)))
}

###:: call the rules set based on input file ::###
runFPGrowth <- function(fname){
   trans <- read.transactions(fname, format="basket", sep=",")
   rules <- fpgrowth(fname, trans, parameters=list(support=0.02, confidence=0.6, measures=F))
   rules <- sort(rules, by="support")
#~    x11()
#~    plot(rules, method='graph', control=list(type='itemsets', engine='graphviz', cex=1.6))
#~    Sys.sleep(15)

   subrules <- sort(rules, by='support')[4:18]
   inspect(subrules)
#~    x11()
#~    plot(subrules, method='graph', control=list(type='itemsets', engine='graphviz', cex=1.6))
#~    Sys.sleep(15)
}
#-------------------------------  end functions  ------------------------------#



fname <- "TransactionData.csv"
runFPGrowth(fname)
