DECLARE PARAMETER orbitAlt.

// LAUNCH BODY

SET launchBody TO "Kerbin".

// LAUNCH
SET countdown TO 3.
SET stabilityEnhancers TO TRUE.

// ASCENT

SET orbitAlt TO 100000.
SET ascHeading TO 90. // 90 Degrees is WEST

// GRAVITY Turn

SET gravityTurnStartAlt TO 1000.
SET gravityTurnStartPitch TO 0.

SET gravityTurnEndAlt TO 41000.
SET gravityTurnEndPitch TO 90.

set maxq to 1500.

// --------------------------------------- //
// ----- OPERATIONAL CODE BELOW HERE ----- //
// --------------------------------------- //

// DERIVED VALUES

if launchBody = "Kerbin" {
    set gravitationalConstant to 3.5316000*10^12.  // gravitational parameter, mu = G mass
    set bodyRadius to 600000.           // radius of body [m]
    set sphereOfInfluence to 84159286.        // sphere of influence [m]
    set atmosphericDensitySeaLevel to 1.2230948554874. // atmospheric density at msl [kg/m^3]
    set atmosphereScaleHeight to 5000.             // scale height (atmosphere) [m]
    set atmosphereHeight to 69077.            // atmospheric height [m]
    set lowOrbitAlt to 80000.          // low orbit altitude [m]
}

SET surfaceGravity TO gravitationalConstant / bodyRadius^2.

LOCK accelerationVector TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce TO accelerationVector:MAG / surfaceGravity.

LOCK weight TO SHIP:MASS * surfaceGravity.
LOCK thrust TO MAXTHRUST.
LOCK thrustToWeightRatio TO thrust / weight.

LOCK totalFuel TO SHIP:SOLIDFUEL + SHIP:LIQUIDFUEL.
LOCK totalStageFuel TO STAGE:SOLIDFUEL + STAGE:LIQUIDFUEL.
LOCK surfaceVelocityMagnitude to velocity:surface:mag.
LOCK atmospheres to -altitude/atmosphereScaleHeight.
LOCK atmosphericDensity to atmosphericDensitySeaLevel * CONSTANT():E^atmospheres.

LOCK radarAlt to alt:radar.

// COUNTDOWN SEQUENCE
PRINT "Counting Commencing:".
UNTIL countdown = 0 {
    PRINT "..." + countdown. 
    SET countdown TO countdown - 1.
    WAIT 1.
}.
PRINT "Ignition.".
LOCK THROTTLE to 1. // Maximum throttle
STAGE. // Ignition Stage

WAIT 0.5. // Small delay between ignition and stability enhancers

// STABILITY ENHANCERS

IF stabilityEnhancers {
	PRINT "Waiting for adequate thrust".
	UNTIL thrustToWeightRatio > 1.0 {
		PRINT "Thrust to weight ratio is: " + thrustToWeightRatio.
		WAIT 0.5.
	}.
	WHEN thrustToWeightRatio > 1.0 THEN {
		PRINT "Thrust is adequate. Releasing stability enhancers.".
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

when radarAlt > gravityTurnStartAlt then {
    print "T+" + round(missiontime) + " Beginning gravity turn.". 
}	

// control speed and attitude
lock throttle to tset.
set pitch to 90-gravityTurnStartPitch.
until altitude > atmosphereHeight or apoapsis > lowOrbitAlt {
    // control attitude
    if radarAlt > gravityTurnStartAlt and radarAlt < gravityTurnEndAlt {
        set arr to (radarAlt - gravityTurnStartAlt) / (gravityTurnEndAlt - gravityTurnStartAlt).
        set pda to (cos(arr * 180) + 1) / 2.
        set pitch to gravityTurnEndPitch * ( pda - 1 ).
        lock steering to up + R(0, pitch, -180).
        print "pitch: " + round(90+pitch) + "  " at (20,33).
    }
	
    if radarAlt > gravityTurnEndAlt {
        lock steering to up + R(0, pitch, -180).
    }
	
    // dynamic pressure q
    set q to 0.5 * atmosphericDensity * surfaceVelocityMagnitude^2.
    print "q: " + round(q)  + "  " at (20,34).
	
    // calculate target velocity
    set vl to maxq*0.9.
    set vh to maxq*1.1.
    if q < vl { set tset to 1. }
    if q > vl and q < vh { set tset to (vh-q)/(vh-vl). }
    if q > vh { set tset to 0. }
    print "alt:radar: " + round(radarAlt) + "  " at (0,33). 
    print "throttle: " + round(tset,2) + "   " at (0,34).
    print "apoapis: " + round(apoapsis/1000) at (0,35).
    print "periapis: " + round(periapsis/1000) at (20,35).
    wait 0.1.
}
set tset to 0.
print "                   " at (0,33).
print "                   " at (20,33).
print "                   " at (20,34).
if altitude < atmosphereHeight {
    print "T+" + round(missiontime) + " Waiting to leave atmosphere".
    lock steering to up + R(0, pitch, 0).       // roll for orbital orientation
    // thrust to compensate atmospheric drag losses
    until altitude > atmosphereHeight {
        // calculate target velocity
        if apoapsis >= orbitAlt { set tset to 0. }
        if apoapsis < orbitAlt { set tset to (orbitAlt-apoapsis)/(orbitAlt*0.01). }
        print "throttle: " + round(tset,2) + "    " at (0,34).
        print "apoapis: " + round(apoapsis/1000,2) at (0,35).
        print "periapis: " + round(periapsis/1000,2) at (20,35).
        wait 0.1.
    }
}
print "                                        " at (0,33).
print "                                        " at (0,34).
print "                                        " at (0,35).
lock throttle to 0.

// CIRCULARIZATION NODE

// create apoapsis maneuver node
print "T+" + round(missiontime) + " Circularizing orbit".
print "T+" + round(missiontime) + " Apoapsis: " + round(apoapsis/1000) + "km".
print "T+" + round(missiontime) + " Periapsis: " + round(periapsis/1000) + "km -> " + round(orbitAlt/1000) + "km".

// present orbit properties
set orbitVelocity to velocity:orbit:mag.  // actual velocity
set radius to bodyRadius + altitude.         // actual distance to body
set apoapsisRadius to bodyRadius + apoapsis.        // radius in apoapsis
set apoapsisVelocity to sqrt( orbitVelocity^2 + 2*gravitationalConstant*(1/apoapsisRadius - 1/radius) ). // velocity in apoapsis
set axis1 to (periapsis + 2*bodyRadius + apoapsis)/2. // semi major axis present orbit
// future orbit properties
set axis2 to (orbitAlt + 2*bodyRadius + apoapsis)/2. // semi major axis target orbit
set periapsisVelocity to sqrt( orbitVelocity^2 + (gravitationalConstant * (2/apoapsisRadius - 2/radius + 1/axis1 - 1/axis2 ) ) ).
// setup node 
set deltav to periapsisVelocity - apoapsisVelocity.
print "T+" + round(missiontime) + " Apoapsis burn: " + round(apoapsisVelocity) + ", dv:" + round(deltav) + " -> " + round(periapsisVelocity) + "m/s".
set newNode to node(time:seconds + eta:apoapsis, 0, 0, deltav).
add newNode.
print "T+" + round(missiontime) + " Node created.".

// CIRCULARIZATION

run exeNode.

// End of Script
WAIT UNTIL FALSE.