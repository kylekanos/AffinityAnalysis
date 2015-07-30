# AffinityAnalysis
R code to do some affinity analysis on ClickStream data. Requires a three packages (`arules`, `arulesViz`, `Rgraphviz`) which are not found in base R package; I don't use `require` because I've already installed them.

Usage
---
In R terminal, `source` the file and then use the provided functions on the transaction data set. This data set must be in the `basket` format, where each transaction contains comma-separated values of items, e.g.,

    bread, fruit, milk
    fruit, milk
    
It also requires Christian Borgelt's [`fpgrowth` code](http://www.borgelt.net//fpgrowth.html) to be installed on the computer.
