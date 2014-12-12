// CONFIG

SET orbitAlt TO 100000.
SET altErrorMargin TO 10000.
SET gravTurnAlt TO 10000.
SET gravTurnPitch TO 30.
SET gravTurnHeading TO 90. // West
SET circPreDelay TO 15.

SET solidBoosterAssist TO TRUE.

SET countdown TO 3.

// IGNITION SEQUENCE

LOCK t TO ROUND(MISSIONTIME).
UNTIL countdown = 0 {
    PRINT "T-" + countdown.
	SET countdown TO countdown - 1.
	WAIT 1.
}.
PRINT "T: Ignition".
LOCK STEERING TO UP + R(0,0,-90).
LOCK THROTTLE TO 1. // 1 is max, 0 is idle.
STAGE. // Ignition Stage
WAIT 1.
// STAGE. // Remove stability enhancers

// STAGING RULES
IF solidBoosterAssist {
	WAIT UNTIL STAGE:SOLIDFUEL < 0.001.
	PRINT "T+" + t + ": Solid boosters ejected.".
	STAGE.
}.

LOCK totalFuel TO SHIP:SOLIDFUEL + SHIP:LIQUIDFUEL.
LOCK totalStageFuel TO STAGE:SOLIDFUEL + STAGE:LIQUIDFUEL.
WHEN totalStageFuel < 0.005 THEN {
	IF totalFuel > 0.005 {
		PRINT "T+" + t + ": Staging.".
		STAGE.
	}.
	PRESERVE.
}.

// GRAVITY TURN SEQUENCE
WAIT UNTIL SHIP:ALTITUDE > gravTurnAlt.
PRINT "T+" + t + ": Starting gravity turn".
LOCK STEERING TO HEADING(gravTurnHeading,(90-gravTurnPitch)). // 90 is west

WAIT UNTIL ALT:APOAPSIS > orbitAlt.
PRINT "T+" + t + ": Apoapsis is at 100k".
LOCK THROTTLE TO 0.

LOCK STEERING TO PROGRADE.
WAIT UNTIL ETA:APOAPSIS < circPreDelay.
PRINT "T+" + t + ": ETA to apoapsis is 15 seconds".
LOCK THROTTLE TO 1.

WAIT UNTIL ALT:PERIAPSIS > orbitAlt - altErrorMargin.
PRINT "T+" + t + ": Periapsis is at 90k".
LOCK THROTTLE TO 0.

// END OF PROGRAM
PRINT "PROGRAM WAITING FOR CTRL+C".
WAIT UNTIL FALSE. // Prevent the script from prematurely ending.