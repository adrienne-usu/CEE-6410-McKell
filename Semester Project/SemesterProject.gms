$onText
Adrienne McKell    (12/2024)
adriennemckell@gmail.com

Developed for CEE 6410 at Utah State University

$offText

sets

i set for sites
    /A "rainbow",B "soda",C "grace",D "oneida",E "cutler"/
    
r set for between sites
    /AB, BC, CD, DE/
    
j set for choices 
    /c1, c2, c3 ,c4, c5, c6/
    
f  set for decision
    /remove, passage/;
    
Alias (i,k) 
    
Parameters
    Cost(i,f) Cost of removing dam or adding fish passage at each site
        /A.remove 9999999, A.passage 250
        B.remove 1000,     B.passage 500
        C.remove 2000,     C.passage 1000
        D.remove 3000,     D.passage 1500
        E.remove 99999999, E.passage 99999999/
        
    Length(r) Length of each reach between sites
        /AB 10,
        BC  20,
        CD  30,
        DE  40/
    
        
    Budget total available budget /1000/;
        
Table connectivity(j,r) what choices correspond to each reach
    AB  BC  CD  DE
c1  1   1
c2  1   1   1
c3  1   1   1   1
c4      1   1   
c5      1   1   1
c6          1   1
;

Table conex(j,i) which site is removed or has passage added for each choice
    A   B   C   D   E
c1      1
c2      1   1
c3      1   1   1
c4          1
c5          1   1
c6              1

;
variables
linkexist(j,i)
Ltotal
totalcost
;

Binary Variables

B(i,f)    Which passage was chosen
X(j)    Which decisions is chosen
;


Equations
Objective
CostConstraint
MExclusive
PassageExclusive(i)
ReachConnect(j)
;

Objective..
            Ltotal =e= sum((j,r), connectivity(j,r)*Length(r)*X(j));

CostConstraint..
            totalcost = sum((i,f), sum(j,conex(j,i)* Cost(i, f) * B(i, f))) =l= Budget;

ReachConnect(j).. 
            X(j) =l= sum((i), B(i, "remove") + B(i, "passage"));

MExclusive..
            sum(j,X(j)) =l= 1;
    
PassageExclusive(i)..
            sum(f, B(i, f)) =l= 1;    
    


    
Model FishPassage /all/;
Solve FishPassage using mip maximizing Ltotal;

Display Ltotal.l, X.l, B.l;
