$ontext
CEE 6410 - Water Resources Systems Analysis
Problem 2.3 from Bishop Et Al Text (https://digitalcommons.usu.edu/ecstatic_all/76/)

THE PROBLEM:

An irrigated farm can be planted in two crops:  hay and grains.  Data are as fol-lows:

Seasonal Resource
Inputs or Profit        Crops        Resource
Availability
                    Hay                  Grain                 RHS
Water (June)        2 ac-ft/plant         1 ac-ft/plant        14,000 ac-ft
Water (July)        1 ac-ft/plant         2 ac-ft/plant        18,000 ac-ft
Water (Aug)         1 ac-ft/plant         1 ac-ft/plant         6,000 ac-ft
Land                1 acre/plant          1 acre/plant         10,000 acre
Profit/plant        $100                  $120

                Determine the optimal planting for the two crops.

THE SOLUTION:
Uses General Algebraic Modeling System to Solve this Linear Program

Adrienne McKell
adrienne.mckell@usu.edu
$offtext

* 1. DEFINE the SETS
SETS plnt crops growing /Hay, Grain/
     res resources /WaterJune, WaterJuly, WaterAug, Land/;

* 2. DEFINE input data
PARAMETERS
   c(plnt) Objective function coefficients ($ per plant)
         /Hay 100,
         Grain 120/
   b(res) Right hand constraint values (per resource)
          /WaterJune 14000,
           WaterJuly 18000
           WaterAug 6000
           Land  10000 /;

TABLE A(plnt,res) Left hand side constraint coefficients
                WaterJune    WaterJuly     WaterAug    Land
 Hay            2            1             1           1
 Grain          1            2             0           1;

* 3. DEFINE the variables
VARIABLES X(plnt) plants planted (Number)
          VPROFIT  total profit ($)
          Y(res)  value of resources used (units specific to variable)
          VREDCOST total reduced cost ($);


* Non-negativity constraints
POSITIVE VARIABLES X,Y;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT_PRIMAL Total profit ($) and objective function value
   RES_CONS_PRIMAL(res) Resource constraints
   REDCOST_DUAL Reduced Cost ($) associated with using resources
   RES_CONS_DUAL(plnt) Profit levels ;

*Primal Equations
PROFIT_PRIMAL..                 VPROFIT =E= SUM(plnt,c(plnt)*X(plnt));
RES_CONS_PRIMAL(res) ..    SUM(plnt,A(plnt,res)*X(plnt)) =L= b(res);

*Dual Equations
REDCOST_DUAL..                 VREDCOST =E= SUM(res,b(res)*Y(res));
RES_CONS_DUAL(plnt)..          sum(res,A(plnt,res)*Y(res)) =G= c(plnt);

* 5. DEFINE the MODELS
*PRIMAL model
MODEL PLANT_PRIMAL /PROFIT_PRIMAL, RES_CONS_PRIMAL/;
*Set the options file to print out range of basis information
PLANT_PRIMAL.optfile = 1;

*DUAL model
MODEL PLANT_DUAL /REDCOST_DUAL, RES_CONS_DUAL/;

* 6. SOLVE the MODELS
* Solve the PLANTING PRIMAL model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to maximize VPROFIT
SOLVE PLANT_PRIMAL USING LP MAXIMIZING VPROFIT;

* Solve the PLANTING DUAL model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to maximize VPROFIT
SOLVE PLANT_DUAL USING LP MINIMIZING VREDCOST;
*Order does not matter!

* 6. CLick File menu => RUN (F9) or Solve icon and examine solution report in .LST file

* 7 . Dump all data and results to GAMS proprietary file storage .gdx and to Excel
Execute_Unload "HW 6 HayGrain.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls HW6HayGrain.gdx"
* To open the GDX file in the GAMS IDE, select File => Open.
* In the Open window, set Filetype to .gdx and select the file.