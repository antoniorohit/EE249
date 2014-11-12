
/* Author: Antonio */

//definition of input values
mtype = {present, absent};
//states
mtype = {A, B, C, D, E};

//state machine variables
mtype lastState = A;
mtype state = A;
mtype return_s = absent;
mtype assert_s = absent;
short timerCount = 2000;

chan inputs = [1] of {mtype, mtype};

/* Environment */
active proctype Environment() {
	 do
		::if
			:: inputs ! present, absent;
			:: inputs ! absent, present;
			:: inputs ! present, present;
			:: inputs ! absent, absent;
		fi;
	 od;
}

/* Inactive State */
 active proctype system_M() {
    do	
	 :: atomic {inputs ? assert_s, return_s ->
            if 
                :: (state == A) && (timerCount == 0) && (assert_s == absent) -> state = C;
		:: (state == A) && (timerCount != 0) && (assert_s == absent) -> state = B;
		:: (state == B) && (assert_s == absent)		   	   -> state = A;
		:: (state == C) && (assert_s == absent)		      	   -> state = C;
		:: (state == D) && (return_s == absent) 		   -> state = D; return_s = present;
		:: (state == D) && (timerCount != 0) && (return_s == absent) -> state = E;
		:: (state == E) && (return_s == absent)   	   	   -> state = D; timerCount = timerCount - 1; return_s = present;
	        :: (assert_s == present)		      			   -> lastState = state; state = D;
	        :: else -> skip;
            fi;
        }
	:: if
		:: (return_s == present) -> state = A; timerCount = 2000;
	   fi;
    od;
}


/* LTL Formulae */
ltl p1 { <>(state == C) }