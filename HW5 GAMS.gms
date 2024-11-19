$ontext
CEE 6410 - Water Resources Systems Analysis


THE PROBLEM:

A reservoir is designed to provide hydropower and water for irrigation.    Data are as fol-lows:

Hydroppower and Irrigation Data
Month   Inflow Units    Hydropower Benefits ($/unit)    Irrigation Benefits ($/unit)
1          2            1.6                             1.0
2          2            1.7                             1.2
3          3            1.8                             1.9
4          4            1.9                             2.0
5          3            2.0                             2.2
6          2            2.0                             2.2


THE SOLUTION:
Uses General Algebraic Modeling System to Solve this Linear Program

Adrienne McKell
adrienne.mckell@usu.edu
$offtext

SETS
   t months /1*6/          
   ;

PARAMETERS
   inflow(t)         Inflow units per month
   hp_benefit(t)     Hydropower benefit per unit of water
   irr_benefit(t)    Irrigation benefit per unit of water
   turbine_capacity  Maximum water release through turbines (units per month) /4/
   initial_storage   Initial reservoir storage (units) /5/
   reservoir_capacity Maximum reservoir storage (units) /9/
   ;


TABLE Data(t,*)   Data for each month 
   inflow  hp_benefit  irr_benefit
1   2       1.6         1.0
2   2       1.7         1.2
3   3       1.8         1.9
4   4       1.9         2.0
5   3       2.0         2.2
6   2       2.0         2.2
;

inflow(t) = Data(t,'inflow');
hp_benefit(t) = Data(t,'hp_benefit');
irr_benefit(t) = Data(t,'irr_benefit');

* POSITIVE VARIABLES to enforce non-negativity
POSITIVE VARIABLES
   storage(t)        * Reservoir storage at end of month t (units)
   release_hp(t)     * Water release through hydropower turbines (units)
   release_irr(t)    * Water release for irrigation (units)
   spill(t)          * Water released through spillway
   ;
   
VARIABLES
   objective         * Total economic benefits (dollars)
   ;          

* EQUATIONS
EQUATIONS
   objective_function       Objective to maximize economic benefits
   mass_balance_1           Water balance for first month
   mass_balance(t)          Water balance for subsequent months
   storage_limit(t)         Reservoir storage limit
   turbine_capacity_limit(t) Hydropower turbine release limit
   end_storage_constraint   Ensure ending storage is greater or equal to initial
   river_flow_constraint(t) River flow requirement (at least 1 unit of water left in river)
   ;

* OBJECTIVE FUNCTION
objective_function ..
   objective =E= SUM(t, hp_benefit(t)*release_hp(t) + irr_benefit(t)*release_irr(t));

* MASS BALANCE: Storage at time t=1
mass_balance_1 ..
   storage('1') =E= initial_storage + inflow('1') - release_hp('1') - spill('1');

* MASS BALANCE: Storage for t > 1
mass_balance(t)$(ord(t) > 1) ..
   storage(t) =E= storage(t-1) + inflow(t) - release_hp(t) - spill(t);

* STORAGE LIMIT: Reservoir cannot exceed its capacity
storage_limit(t)..
   storage(t) =L= reservoir_capacity;

* TURBINE CAPACITY LIMIT: Water release through turbines limited to 4 units/month
turbine_capacity_limit(t)..
   release_hp(t) =L= turbine_capacity;

* RIVER FLOW CONSTRAINT: At least 1 unit of water must remain in the river
river_flow_constraint(t) ..
   spill(t)+ release_hp(t)-release_irr(t) =G= 1;

* END STORAGE CONSTRAINT: Ensure ending storage is at least as large as initial storage
end_storage_constraint ..
   storage('6') =G= initial_storage;

* SOLVE
MODEL ReservoirOperation /ALL/;
ReservoirOperation.optfile = 1;
SOLVE ReservoirOperation USING LP MAXIMIZING objective;

