
## Time series algorithm 
 
The time series algorithm was written in [R](https://www.r-project.org/) and uses the [prama](https://cran.r-project.org/web/packages/pracma/index.html) package for initial peak and pit detection.  The time series algorithm uses a combination of statistical heuristics, an input threshold value, and control well activity statistics in order to remove random noise, categorize well activity and produce summary statistics.  Well activity is categorized into one of four types, Inactive; the cells did not produce enough of a response to be considered for further analysis, Type 1 (figure 1); normal activity, Type 2 (figure 2); extended downstroke, or Type 3 (figure 2); high frequency.  The algorithm produces a PDF of all cell activity with highlighted peaks as well as useful summary statistics such as ADP90, ADP10, number of ectopic peaks, peak rise time, frequency, spacing and more.  

Type 1  
![Type 1](./spec/readmeResources/Type1.png "Type 1 (normal)")  

Type 2  
![Type 2](./spec/readmeResources/Type2.png "Type 2 (extended downstroke)")  
 
Type 3
![Type 3](./spec/readmeResources/Type3.png "Type 3 (high frequency)")
