*==============================================================
*This code is for the anlaysis Trix2 - PS5
*The dataset is obtained from dropbox. 
*No output files are created 

*Date: 
*Author: Krishna Srinivasan 
*krishna.srinivasan@econ.uzh.ch
*==============================================================

***************************************************************
*                      Initialize 
***************************************************************
version 14
set more off
set matsize 800
// cd "C:/Users/"

***************************************************************
*                      Question 2
***************************************************************

use "https://www.dropbox.com/s/i7nszely7q7gk5s/mroz.dta?dl=1",clear

gen kidslt6_dum = kidslt6 >0 

*a) 
probit  inlf nwifeinc educ exper expersq age
estimates store pra1

probit  kidslt6_dum nwifeinc educ exper expersq age
estimates store pra2 

// esttab pra1 pra2 using "./tables/2a.tex", ///
// cells(b(star fmt(3)) se(fmt(3))) starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
// title(Paramater estimates from probit Question 2a \label{tab:2a}) ///
// alignment(@{}l*{8}{D{.}{.}{3}}@{}) booktabs replace


*b)
biprobit inlf  kidslt6_dum nwifeinc educ exper expersq age
estimates store prb

// esttab prb using "./tables/2b.tex", ///
// cells(b(star fmt(3)) se(fmt(3) par)) starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
// title(Paramater estimates from biprobit question 2b \label{tab:2b}) ///
// alignment(@{}l*{8}{D{.}{.}{3}}@{}) booktabs replace unstack

*c) t

biprobit (inlf kidslt6_dum nwifeinc educ exper expersq age) ///
 ( kidslt6_dum nwifeinc educ exper expersq age)
 estimates store prc

 
// esttab prc using "./tables/2c.tex", ///
// cells(b(star fmt(3)) se(fmt(3) par)) starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
// title(Paramater estimates from biprobit question 2c \label{tab:2c}) ///
// alignment(@{}l*{8}{D{.}{.}{3}}@{}) booktabs replace unstack

 
*d) 
biprobit (inlf  kidslt6_dum nwifeinc educ exper expersq age) ///
 ( kidslt6_dum nwifeinc educ exper expersq age)
 
 *f) 

//  forvalues i in -1(0.1)1 {
local athrho=1/2*ln((1+(-.5070269))/(1-(-.5070269)))
  constraint define 2 [athrho]_cons=`athrho'
 constraint define 1 _b[kidslt6]=0
 biprobit (inlf kidslt6_dum nwifeinc educ exper expersq age) ///
 (kidslt6_dum nwifeinc educ exper expersq age), constraint(2)
 
  
  
*g) 
 
biprobit (kidslt6_dum nwifeinc educ exper expersq age ) ///
(inlf kidslt6_dum nwifeinc educ exper expersq age)
//matrix list x 
matrix b = e(b)
matrix list b
matrix beta = b[1, 1..6] 
matrix gamma = b[1, 8..13] 
matrix list beta 
matrix list gamma

*Create a variable of ones to multiply with constant 
g ones = 1
 
mkmat nwifeinc educ exper expersq age ones, matrix(X)

matrix A = X*beta'
matrix B = X*gamma'

svmat A, names(A)
svmat B, names(B)

reg A1 B1
		 
local athrho = atanh(_b[B1])
display `athrho'

constraint 4 [athrho]_cons = `athrho'

biprobit (kidslt6_dum nwifeinc educ exper expersq age ) ///
(inlf kidslt6_dum nwifeinc educ exper expersq age), constraint(4)


