OMNIGRAM EXPLORER
version 1.1

This directory contains the Processing (.pde) source files for
Omnigram Explorer.  

The contents of the sub-directories is as follows:

data
- contains example data sets and XML loader files

doc
- contains user and technical documentation

tools
- contains miscellaneous extra tools associated with Omnigram Explorer
(see below) 


TOOLS
-----
The contents of the tools directory is as follows:

omnigram.m (MATLAB file)
- This is a tool for preparing data files and automatically generating
  an XML loader file for your data. It takes the name of a .csv file as 
  an input and interactively allows the user to select which variables
  to include, select which of these are output variables ('leaf') and
  which are discrete. The program then calculates the necessary
  attributes, prunes the .csv file to the required variables and writes
  the XML loader file. The only requirement is that the first row of the
  .csv file contains the variable names. See comments at top of file for
  further usage information.  


LICENSE
-------
Omnigram Explorer is distributed under the GNU GPL (v2). See the
LICENSE file in the top-level directory for further information. 


AUTHORS
-------
Omnigram Explorer was developed by Tim Taylor, Alan Dorin and Kevin
Korb at the Faculty of Information Technology, Monash University. For
further details, see http://www.tim-taylor.com/omnigram 
