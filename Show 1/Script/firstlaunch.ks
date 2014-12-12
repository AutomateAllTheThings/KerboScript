// CONFIGURATION

SET countdown TO 3.

// ASCENT STRATEGY

SET ascHeading TO 90.

SET ascTurnOneAlt TO 1000.
SET ascTurnOneAngle TO 85.

SET ascTurnTwoAlt TO 5000.
SET ascTurnTwoAngle TO 40.

SET ascTurnThreeAlt TO 10000.
SET ascTurnThreeAngle TO 20.

SET ascTurnFourAlt TO 25000.
SET ascTurnFourAngle TO 10.

SET ascTurnFiveAlt TO 90000.
SET ascTurnFiveAngle TO 5.

// COUNTDOWN SEQUENCE

PRINT "Counting Commencing:".

UNTIL countdown = 0 {
    PRINT "..." + countdown.
    SET countdown TO countdown - 1.
    WAIT 1.
}.

// IGNITION SEQUENCE

PRINT "Main throttle set to maximum.".

LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

PRINT "Ignition.".

STAGE.

WAIT UNTIL SHIP:

// Single-Fire Rules

WHEN STAGE:SOLIDFUEL < 0.001 THEN {
    PRINT "Solid Stage".
    STAGE.
}.

WHEN STAGE:LIQUIDFUEL < 0.001 THEN {
    PRINT "Liquid Stage".
    STAGE.
}.

WHEN ALT:APOAPSIS > 100000 THEN {
    LOCK THROTTLE TO 0.
}.

// Ascent Plan

WAIT UNTIL SHIP:ALTITUDE > ascTurnOneAlt.
LOCK STEERING TO HEADING(ascHeading,ascTurnOneAngle).

WAIT UNTIL SHIP:ALTITUDE > ascTurnTwoAlt.
LOCK STEERING TO HEADING(ascHeading,ascTurnTwoAngle).

WAIT UNTIL SHIP:ALTITUDE > ascTurnThreeAlt.
LOCK STEERING TO HEADING(ascHeading,ascTurnThreeAngle).

WAIT UNTIL SHIP:ALTITUDE > ascTurnFourAlt.
LOCK STEERING TO HEADING(ascHeading,ascTurnFourAngle).

WAIT UNTIL SHIP:ALTITUDE > ascTurnFiveAlt.
LOCK STEERING TO HEADING(ascHeading,ascTurnFiveAngle).
WAIT 2.
LOCK THROTTLE TO 1.0.

WAIT UNTIL ALT:PERIAPSIS > 90000.
LOCK THROTTLE TO 0.