DECLARE PARAMETER orbitInKm.

CLEARSCREEN.

// LAUNCH BODY

SET launchBody TO "Kerbin".

// LAUNCH
SET countdown TO 3.
SET stabilityEnhancers TO TRUE.
SET solidBoosterAssist TO FALSE.

// ASCENT

SET orbitAlt TO orbitInKm * 1000.
SET ascHeading TO 90. // 90 Degrees is WEST

// GRAVITY Turn

SET gravityTurnStartAlt TO 8000.
SET gravityTurnStartPitch TO 0.

SET gravityTurnEndAlt TO 80000.
SET gravityTurnEndPitch TO 90.

SET maxq TO 3000.

// ----------------------------- //
// ----- DYNAMIC VARIABLES ----- //
// ----------------------------- //

// DERIVED VALUES

IF launchBody = "Kerbin" {
    SET gravitationalConstant TO 3.5316000*10^12.  // gravitational parameter, mu = G mass
    SET bodyRadius TO 600000.           // radius of body [m]
    SET sphereOfInfluence TO 84159286.        // sphere of influence [m]
    SET atmosphericDensitySeaLevel TO 1.2230948554874. // atmospheric density at msl [kg/m^3]
    SET atmosphereScaleHeight TO 5000.             // scale height (atmosphere) [m]
    SET atmosphereHeight TO 69077.            // atmospheric height [m]
    SET lowOrbitAlt TO 80000.          // low orbit altitude [m]
}

SET surfaceGravity TO gravitationalConstant / bodyRadius^2.

LOCK weight TO SHIP:MASS * surfaceGravity.
LOCK thrust TO MAXTHRUST.
LOCK thrustToWeightRatio TO thrust / weight.

LOCK totalFuel TO SHIP:SOLIDFUEL + SHIP:LIQUIDFUEL.
LOCK totalStageFuel TO STAGE:SOLIDFUEL + STAGE:LIQUIDFUEL.

LOCK radarAlt TO alt:radar.

// --------------------------------------- //
// ----- OPERATIONAL CODE BELOW HERE ----- //
// --------------------------------------- //

// COUNTDOWN SEQUENCE
PRINT "Counting Commencing:".
UNTIL countdown = 0 {
    PRINT "..." + countdown. 
    SET countdown TO countdown - 1.
    WAIT 1.
}.
PRINT "Ignition.".
LOCK STEERING TO UP + R(0,0,-90).
LOCK THROTTLE TO 1. // Maximum THROTTLE
STAGE. // Ignition Stage

WAIT 0.5. // Small delay between ignition and stability enhancers

// STABILITY ENHANCERS

IF stabilityEnhancers {
	PRINT "Waiting for adequate thrust".
	WHEN thrustToWeightRatio > 1.0 THEN {
		PRINT "Thrust is adequate. Releasing stability enhancers.".
		STAGE.
	}.
}.

// STAGING RULES
IF solidBoosterAssist {
	WHEN STAGE:SOLIDFUEL < 0.001 THEN {
		PRINT "Solid boosters ejected.".
		STAGE.
	}.
}.

// STAGING RULES
WHEN totalStageFuel < 0.001 THEN {
	IF totalFuel > 0.001 {
		PRINT "STAGING".
		STAGE.
	}.
	PRESERVE.
}.

// PITCHOVER / GRAVITY TURN

WHEN radarAlt > gravityTurnStartAlt THEN {
    PRINT "T+" + ROUND(missiontime) + " Beginning gravity turn.". 
}.

// control speed and attitude
LOCK THROTTLE TO tset.
SET pitch TO 90-gravityTurnStartPitch.
UNTIL altitude > atmosphereHeight or apoapsis > lowOrbitAlt {
	SET surfaceVelocityMagnitude TO velocity:surface:mag.
	SET atmospheres TO -altitude/atmosphereScaleHeight.
	SET atmosphericDensity TO atmosphericDensitySeaLevel * CONSTANT():E^atmospheres.
    // control attitude
    IF radarAlt > gravityTurnStartAlt and radarAlt < gravityTurnEndAlt {
        SET arr TO (radarAlt - gravityTurnStartAlt) / (gravityTurnEndAlt - gravityTurnStartAlt).
        SET pda TO (cos(arr * 180) + 1) / 2.
        SET pitch TO gravityTurnEndPitch * ( pda - 1 ).
        LOCK STEERING TO up + R(0, pitch, -180).
        PRINT "pitch: " + ROUND(90+pitch) + "  " at (20,33).
    }
	
    IF radarAlt > gravityTurnEndAlt {
        LOCK STEERING TO up + R(0, pitch, -180).
    }
	
    // dynamic pressure q
    SET q TO 0.5 * atmosphericDensity * surfaceVelocityMagnitude^2.
    PRINT "q: " + ROUND(q)  + "  " at (20,34).
	
    // calculate target velocity
    SET vl TO maxq*0.9.
    SET vh TO maxq*1.1.
    IF q < vl { SET tset TO 1. }
    IF q > vl and q < vh { SET tset TO (vh-q)/(vh-vl). }
    IF q > vh { SET tset TO 0. }
    PRINT "alt:radar: " + ROUND(radarAlt) + "  " at (0,33). 
    PRINT "THROTTLE: " + ROUND(tset,2) + "   " at (0,34).
    PRINT "apoapis: " + ROUND(apoapsis/1000) at (0,35).
    PRINT "periapis: " + ROUND(periapsis/1000) at (20,35).
    wait 0.5.
}
SET tset TO 0.
PRINT "                   " at (0,33).
PRINT "                   " at (20,33).
PRINT "                   " at (20,34).
IF altitude < atmosphereHeight {
    PRINT "T+" + ROUND(missiontime) + " Waiting TO leave atmosphere".
    LOCK STEERING TO up + R(0, pitch, 0).       // roll for orbital orientation
    // thrust TO compensate atmospheric drag losses
    UNTIL altitude > atmosphereHeight {
        // calculate target velocity
        IF apoapsis >= orbitAlt { SET tset TO 0. }
        IF apoapsis < orbitAlt { SET tset TO (orbitAlt-apoapsis)/(orbitAlt*0.01). }
        PRINT "THROTTLE: " + ROUND(tset,2) + "    " at (0,34).
        PRINT "apoapis: " + ROUND(apoapsis/1000,2) at (0,35).
        PRINT "periapis: " + ROUND(periapsis/1000,2) at (20,35).
        wait 0.1.
    }
}
PRINT "                                        " at (0,33).
PRINT "                                        " at (0,34).
PRINT "                                        " at (0,35).
LOCK THROTTLE TO 0.

// CIRCULARIZATION NODE

// create apoapsis maneuver node
PRINT "T+" + ROUND(missiontime) + " Circularizing orbit".
PRINT "T+" + ROUND(missiontime) + " Apoapsis: " + ROUND(apoapsis/1000) + "km".
PRINT "T+" + ROUND(missiontime) + " Periapsis: " + ROUND(periapsis/1000) + "km -> " + ROUND(orbitAlt/1000) + "km".

// present orbit properties
SET orbitVelocity TO velocity:orbit:mag.  // actual velocity
SET radius TO bodyRadius + altitude.         // actual distance TO body
SET apoapsisRadius TO bodyRadius + apoapsis.        // radius in apoapsis
SET apoapsisVelocity TO sqrt( orbitVelocity^2 + 2*gravitationalConstant*(1/apoapsisRadius - 1/radius) ). // velocity in apoapsis
SET axis1 TO (periapsis + 2*bodyRadius + apoapsis)/2. // semi major axis present orbit
// future orbit properties
SET axis2 TO (orbitAlt + 2*bodyRadius + apoapsis)/2. // semi major axis target orbit
SET periapsisVelocity TO sqrt( orbitVelocity^2 + (gravitationalConstant * (2/apoapsisRadius - 2/radius + 1/axis1 - 1/axis2 ) ) ).
// setup node 
SET deltav TO periapsisVelocity - apoapsisVelocity.
PRINT "T+" + ROUND(missiontime) + " Apoapsis burn: " + ROUND(apoapsisVelocity) + ", dv:" + ROUND(deltav) + " -> " + ROUND(periapsisVelocity) + "m/s".
SET newNode TO node(time:seconds + eta:apoapsis, 0, 0, deltav).
add newNode.
PRINT "T+" + ROUND(missiontime) + " Node created.".

// CIRCULARIZATION

run exeNode.

// End of Script
WAIT UNTIL FALSE.