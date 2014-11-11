/*
*
* Author: Antonio 
*/

//definition of input values
mtype = {present, absent};
//state definition
mtype = {RED, GREEN, PENDING, YELLOW};

//state machine variables
mtype state = RED;
mtype sigR = present, sigG = absent, sigY=absent;
byte count = 0;
mtype x = absent;

//communication channel
chan input = [0] of {mtype};

/*
* Non-deterministic environment
*/
active proctype Environment() {
    do
        ::if
            :: input ! present;
            :: input ! absent;

        fi;

    od;
}

/*
* Cruise control state machine
*/
active proctype trafficLight() {
    do
        :: atomic { input ? x ->
            if 
                :: (state == RED) && (count<60) -> 
                  count = count + 1; state = RED;
                :: (state == RED) && (count>=60) -> 
                    state = GREEN; sigG = present; sigY = absent; sigR = absent; count = 0;
                :: (state == GREEN) && (count<60) && (x == absent)-> 
                  count = count + 1; state = GREEN;
                :: (state == GREEN) && (count>=60) && (x == present) -> 
                    state = YELLOW; sigG = absent; sigY = present; sigR = absent;  count = 0;
               :: (state == GREEN) && (count<60) && (x == present)-> 
                    state = PENDING; count = count + 1;
                :: (state == PENDING) && (count<60) -> 
                  count = count + 1; state = PENDING;
                :: (state == PENDING) && (count>=60) -> 
                    state = YELLOW; sigG = absent; sigY = present; sigR = absent; ; count = 0;
		:: (state == YELLOW) && (count<5) -> 
                  count = count + 1; state = YELLOW;
                :: (state == YELLOW) && (count>=5) -> 
                    state = RED; sigG = absent; sigY = absent; sigR = present; count = 0;
	       :: else -> skip;
            fi;
        }
    od;
          
}
