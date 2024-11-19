* 1. DEFINE the SETS
  
 SETS
 src  water supply sources /res "diversion from reservoir", pum "pump from river"/
 lev  source size /lev0 "none", lev1 "small", lev2 "big"/
 t    time in seasons /s1*s2/;
   
   
* 2. DEFINE the variables
VARIABLES
 I(src,lev) binary decision to build or do prject from source src (1=yes 0=no)
 X(src,t)   volume of water provided by source src in time t (ac-ft per season)
 REL(t)     Reservoir release to river in time t (ac-ft per season)
 STOR(t)    Reservoir storage volume in time t (ac-ft)
 AREA       Area irrigated (ac)
 TBEN       Total net benefits that are revenus minus capital and operating costs ($);
   
BINARY VARIABLES I;

* Non-negativity constraints
POSITIVE VARIABLES X, REL, STOR;
   
   
* 3. DEFINE input data
  TABLE CapCost(src,lev) capital cost ($ to build)
            lev1  lev2
     res    6000  10000
     pum    8000        ;
*leaving out r0 keeps the default entry of zero
  
PARAMETER OpCost(src) operating cost ($ per ac-ft)
       /res    0,
       pum    20/ ;
  
TABLE MaxCapacity(src,lev) Maximum capacity of source when built (ac-ft per season)
           lev1  lev2
     res    300   700;
  
*Define the maximum capacity programatically for the pump (covert from daily to seasonal)
* card(t) counts the number of elements in set t

MaxCapacity("pum","lev1") = 2.2*365/card(t);
   
PARAMETERS
RiverInflow(t) River inflow in time t (ac-ft)/s1 600, s2 200/
Demand(t) Irrigation demand in time t (ac-ft per acre)/s1 1.0, s2 3.0/
InitStor Initial reservoir storage (fraction of full capacity) /0.5/
BaseFlow River baseflow below the reservoir (ac-ft) /2/
Revenue  Revenue from irrigation ($ per year per acre) /300/;
  
*Convert daily baseflow to seasonal baseflow
BaseFlow = BaseFlow*365/card(t);
   
   
* 4. COMBINE variables and data in equations
EQUATIONS
NetBen          Revenues minus capital and operating costs ($) and objective function value
AreaToSupply(t) Area to supply with deliveries (ac)
PumpCapacity(t) Pumping within capacity in each time step (ac-ft per season)
ResCapacity(t)  Reservoir storage within capacity in each time step (ac-ft)
MutExclus(src)  Can only implement one project size (#)
RivMassBal(t)   River mass balance downstream of reservoir in each timestep (ac-ft)
ResMassBal(t)   Reservoir mass balance in each time step (ac-ft);
   
   
NetBen..                 TBEN =E= Revenue*AREA - SUM(src,SUM(lev,CapCost(src,lev)*I(src,lev)) + SUM(t,OpCost(src)*X(src,t)));
AreaToSupply(t)..        AREA =L= SUM(src,X(src,t))/Demand(t);
PumpCapacity(t)..        X("pum",t) =L= sum(lev,MaxCapacity("pum",lev)*I("pum",lev));
ResCapacity(t)..         STOR(t) =L= sum(lev,MaxCapacity("res",lev)*I("res",lev));
RivMassBal(t)..          X("pum",t) =L= REL(t) + BaseFlow;
MutExclus(src)..         sum(lev,I(src,lev)) =L= 1;
   
*Reservoir mass balance
*In first time step, previous storage is the initial storage (a fraction of the capacity).
*In subsequent time steps, prevous storage is the prior storage variable (t-1).
*Differentiate the cases using the $ operator $(ord(t) eq 1) => first time step
*                                             $(ord(t) gt 1) => subsequent time steps
ResMassBal(t)..   STOR(t) =E= RiverInflow(t) - REL(t) - X("res",t) +
*                    Initial storage = fraction of reservoir capacity to include for equation for first time step
InitStor*sum(lev,MaxCapacity("res",lev)*I("res",lev))$(ord(t) eq 1)  +
*                    Prior storage to include for equations for subsequent time steps (t-1)
STOR(t-1)$(ord(t) gt 1);
   
* 5. DEFINE the MODEL from the EQUATIONS
MODEL ResDesign /ALL/;
   
* 6. Solve the Model as an LP (relaxed IP)
SOLVE ResDesign USING MIP Maximizing TBEN;
  
DISPLAY X.L, I.L, TBEN.L;
   
* Dump all input data and results to a GAMS gdx file
Execute_Unload "Ex7-1.gdx";
* Dump the gdx file to an Excel workbook
 Execute "gdx2xls Ex7-1.gdx"
