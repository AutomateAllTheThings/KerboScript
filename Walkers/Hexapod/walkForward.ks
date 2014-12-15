DECLARE PARAMETER steps. // Allows us to run walkForward(numberOfSteps).

SET movementTiming1 TO 0.2.
SET movementTiming2 TO 0.2.

UNTIL steps = 0 {

	IF SHIP:ELECTRICCHARGE > 50 {
		TOGGLE AG1.
		WAIT movementTiming2.
		TOGGLE AG1.

		TOGGLE AG4.
		WAIT movementTiming1.
		TOGGLE AG4.
		
		TOGGLE AG2.
		WAIT movementTiming2.
		TOGGLE AG2.

		TOGGLE AG3.
		WAIT movementTiming1.
		TOGGLE AG3.
		
		SET steps TO steps - 1.
	} ELSE {
		SET steps TO 0.	
	}
}.