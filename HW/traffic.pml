/* Author: Antonio */

//definition of input values
mtype = {present, absent};
//state_traffic definition
mtype = {RED, GREEN, PENDING, YELLOW};
//state_ped definition
mtype = {NONE, WAITING, CROSSING};

//state machine variables
mtype state_traffic = RED;
mtype state_ped = CROSSING;
byte count = 0;
mtype x = absent;

//communication channels
chan ped = [0] of {mtype};
chan signals = [2] of {mtype, mtype, mtype};		// RGY

mtype r = present;
mtype g = absent;
mtype y = absent;


/* Non-deterministic pedestrian */
 proctype pedestrian() {
    do	
        :: atomic {signals ? r, g, y  ->
            if 
                :: (state_ped == NONE) -> state_ped = NONE; ped ! absent;
		:: (state_ped == NONE) -> state_ped = WAITING; ped ! present;
		:: (state_ped == WAITING) && (r == present) -> state_ped = CROSSING; ped ! absent;
		:: (state_ped == CROSSING) && (g == present) -> state_ped = NONE; ped ! absent;
	        :: else -> ped ! absent;
            fi;
        }
    od;
}

/* Traffic light state machine */
 proctype trafficLight() {
    do
        :: atomic {ped ? x -> 
            if 
                :: (state_traffic == RED) && (count<60) -> 
                  count = count + 1; state_traffic = RED; signals ! absent, absent, absent;
                :: (state_traffic == RED) && (count>=60) -> 
                    state_traffic = GREEN; signals ! absent, present, absent; count = 0;
                :: (state_traffic == GREEN) && (count<60) && (x == absent)-> 
                  count = count + 1; state_traffic = GREEN;signals ! absent, absent, absent;
                :: (state_traffic == GREEN) && (count>=60) && (x == present) -> 
                    state_traffic = YELLOW; signals ! absent, absent, present;  count = 0;
               	:: (state_traffic == GREEN) && (count<60) && (x == present)-> 
                    state_traffic = PENDING; count = count + 1;signals ! absent, absent, absent;
                :: (state_traffic == PENDING) && (count<60) -> 
                  count = count + 1; state_traffic = PENDING;signals ! absent, absent, absent;
                :: (state_traffic == PENDING) && (count>=60) -> 
                    state_traffic = YELLOW; signals ! absent, absent, present; count = 0;
		:: (state_traffic == YELLOW) && (count<5) -> 
                  count = count + 1; state_traffic = YELLOW; signals ! absent, absent, absent;
                :: (state_traffic == YELLOW) && (count>=5) -> 
                    state_traffic = RED; signals ! present, absent, absent; count = 0;
	       	:: else -> signals ! absent, absent, absent;
            fi;
        }

    od;

          
}

init {
	atomic{	

		if
			:: state_ped = NONE;
			:: state_ped = CROSSING;
		fi;
		run pedestrian();
		run trafficLight();
		ped ! absent;
	}
}

/* LTL Formulae */
ltl p1 { (state_ped == CROSSING) -> (state_traffic == RED) }		// Pedestrian Crossing happens only if traffic light is red
ltl p2 { ((x == present) -> <>(state_ped == CROSSING)) } 		// Eventually the pedestrian gets to cross if he comes over :)