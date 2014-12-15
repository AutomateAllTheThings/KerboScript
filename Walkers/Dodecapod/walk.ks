run walkerParts.

DECLARE PARAMETER steps.
DECLARE PARAMETER direction.

// CONFIG

SET shoulderDelay TO 0.3.
SET kneeDelay TO 0.1.

SET strideLength TO 15.
SET strideHeight TO 15.
SET strideHeightMinimum TO 25.

IF direction <> "forward" AND direction <> "backward" {
    SET direction TO "forward".
}.

run setStride.

run reset.

// ALIGNMENT

// run startWalk.

// WALKING

UNTIL steps = 0 {
	
	IF direction = "forward" {
		run step1.
		run step2.
		run step3.
		run step4.
	} else {
		run step1.
		run step4.
		run step3.
		run step2.
	}.
	PRINT "Steps left: " + steps.
	SET steps TO steps - 1.
}.

run reset.

// RESET ALIGNMENT