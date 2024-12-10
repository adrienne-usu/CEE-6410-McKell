$onText
Adrienne McKell    (12/2024)
adriennemckell@gmail.com

Developed for my semester project for CEE 6410 at Utah State University

This model optimizes fish habitat restoration by deciding which sites to modify 
(either by dam removal or adding fish passage) while staying within a budget constraint.
The goal is to maximize the total connected length of restored habitat along the Bear River.

See Final Report in repository for further details and background
$offText

* DEFINE the SETS
sets

i set for sites (inlcudes the project endcap sites A and E)
    /A "rainbow",B "soda",C "grace",D "oneida",E "cutler"/
    
r reaches between sites
    /AB, BC, CD, DE/
    
j choices of connectivity options
    /c1, c2, c3 ,c4, c5, c6, c7/
    
f  decision options for each site (remove dam or add fish passage)
    /remove, passage/;
    
Alias (i,k)
*Alias allow comparing or linking the same set elements

* DEFINE input data
Parameters
    Cost(i,f) Cost of removing dam or adding fish passage at each site ($)
        /B.remove 1000,     B.passage 500
        C.remove  2000,     C.passage 1000
        D.remove  3000,     D.passage 1500/
        
* A and E are left out because they are the endcaps of the reach
* and not being evaluated for connectivity. Additionally, these prices are dummy data. 
* To get more accurate prices an analysis of each site would have to be done
        

    Length(r) Length of each reach between sites (miles)
        /AB 40,
        BC  6,
        CD  50,
        DE  70/
* these lengths are best estimates of river miles using Google Earth Pro
        

    Budget total available budget /250/;
* this budget is dummy data to match the prices above.

* DEFINE tables with connectivity data  
Table connectivity(j,r) which choice (j) restore connectivity on specific reaches (r)(1= yes 0=no)
    AB  BC  CD  DE
c1  1   1
c2  1   1   1
c3  1   1   1   1
c4      1   1   
c5      1   1   1
c6          1   1
c7  1   1   1   1
;

Table conex(j,i) which sites (i) are modified (either removed or passage) for each choice(j)
    B   C   D   
c1  1
c2  1   1
c3  1   1   1
c4      1
c5      1   1
c6          1
c7  1       1

;

* DEFINE the variables
variables
Ltotal          Total connected length of restored habitat: objective to be maximized (miles)
totalcost       Total cost of the selected modification ($)
;

Binary Variables
B(i,f)          Decision to remove dam or add fish passage at site i
X(j)            Decision to choose connectivity option j
ModifySite(i)   Indicates if a site i is modified (either removal or passage)
;


Equations
Objective           Maximize the total connected length of restored habitat
CostConstraint      Ensure the total cost of the modifications does not exceed the budget
LinkChoice(j)       Ensure the choice of connectivity option is consistent with site modifications
SingleChoice        Ensure only one connectivity choice is selected
PassageExclusive(i) For each site only one type of modification (removal or passage) can be chosen
ActionAtSite(i)     ModifySite(i) is 1 if there is a modification (removal or passage) at site i
    
;

Objective..
            Ltotal =e= sum((j,r), connectivity(j,r)*Length(r)*X(j));

CostConstraint..
             sum((i,f), Cost(i, f) * B(i, f)) =l= Budget;
LinkChoice(j)..
            sum(i, (conex(j,i) * ModifySite(i))) =G= sum(i, conex(j,i)) * X(j);

SingleChoice..
            sum(j,X(j)) =e= 1;
    
PassageExclusive(i)..
            sum(f, B(i, f)) =l= 1;
            
ActionAtSite(i) ..
            ModifySite(i) =L= sum(f, B(i,f));

*DEFINE the MODEL from the EQUATIONS   
Model FishPassage /all/;

* 6. Solve the Model as an LP (relaxed IP)
Solve FishPassage using mip maximizing Ltotal;
Display Ltotal.l, X.l, B.l;

* Dump all input data and results to a GAMS gdx file
Execute_Unload "SemesterProject.gdx";
