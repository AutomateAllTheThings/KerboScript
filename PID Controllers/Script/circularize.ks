// Set FINAL to your desired circular orbit.
declare parameter FINAL,asp,staging.

stage.
set thrust to 0.
lock throttle to thrust.
lock steering to up + R(0,0,180).

set m to mass.
set Qmax to .5*1.2*(100.9^2).
set Cd to .20075*.008.
set D to (mass*9.81)/Qmax.

clearscreen.
sas on.
print "T-minus 5". wait 1.
print "4". wait 1.
print "3". wait 1.
print "2". wait 1.
print "1". wait 1.
print "Launch".
set thrust to 1.
stage.
set staging to staging-1.
if stage:solidfuel > 0 {
	set BoosterStage to 1.
	}.
if stage:solidfuel < 1 {
	set BoosterStage to 0.
	}.
print "BoosterStage " + BoosterStage.
print "Asparagus " +asp.
wait 1.
clearscreen.
set p0 to 1.223125.
set e to 2.71828.
set q to 0.
print "Vertical Ascent" at (0,0).
print "Q-Max" at (0,1).
print "Dynamic Pressure" at (0,2).
set GM to 3.5316*(10^12).
until q > Qmax*.5 {
	set thrust to .9.
	set H to altitude/(-5000).
	set p to p0*(e^H).
	set r to altitude+600000.
	set g to GM/(r^2).
	set Qmax to g/Cd.
	set q to .5*p*(verticalspeed^2).
	print Qmax at (20,1).
	print q at (20,2).
	}.
// Throttle is reduced to maintain a constant terminal velocity.
clearscreen.
print "Throttle down to reduce drag losses" at (0,0).
print "Throttle" at (0,1).
print "Q-Max" at (0,2).
print "Dynamic Pressure" at (0,3).
print "Aerodynimc Eff. " at (0,4).
set x to .5.
until altitude > 25000 {
	set H to altitude/(-5000).
	set I to altitude/(10000).
	set delta to (e^I)*(-1).
	set p to p0*(e^H).
	set r to altitude+600000.
	set g to GM/(r^2).
	set Qmax to g/Cd.
	set vsurf to velocity:surface.
	set Vsx to vsurf:x.
	set Vsy to vsurf:y.
	set Vsz to vsurf:z.
	set Vs2 to (Vsx^2)+(Vsy^2)+(Vsz^2).	
	set q to .5*p*(vs2).
	set err to .002.
	set error to 1-err*(q-Qmax).
	set Drag to ((Qmax*Cd*mass)/maxthrust).
	set Weight to (mass*g)/maxthrust.
	set tThrust to (Drag+ Weight)*error.
	lock steering to up + R(0,delta,180).
	if tThrust > .85 {
		set thrust to .85.
		}
	if tThrust < .85 {
		set thrust to tThrust.
		}.
	if altitude > 10000 AND x < 1 {
		sas off.
		print "Begin gravity turn" at (0,7).
		set x to x+1.
		}.
	print thrust*100+"%" at (20,1).	
	print Qmax at (20,2).
	print q at (20,3).
	print (100*(q/Qmax)) at (20,4).
	if stage:solidfuel = 0 AND BoosterStage = 1{
		stage.
		set staging to staging-1.
		set BoosterStage to 0.
		}.
	set FUEL to 3600+2880*2*(asp-1).
	if stage:liquidfuel < FUEL AND asp > 0 {
		stage.
		set staging to staging-1.
		set asp to asp - 1.
		}.
	if stage:liquidfuel = 0 AND staging > 1 {
		stage.
		set staging to staging-1.
		wait 1.
		}.
	}.
// After 25,000m the effects of drag are minimal so thrust is set to 100%.
// Burn to desired circular orbit altitude.

clearscreen.
print "Burn to " + FINAL*.001 + "Km Apogee".
set thrust to .85.
set x to 0.
until apoapsis > FINAL AND altitude > 70000 {
	if delta > (-90) {
		set I to altitude/(10000).
		set delta to (e^I)*(-1).
		if delta < (-90) {
			set delta to (-90).
			}.
		}.
		lock steering to up + R(0,delta,180).
	if apoapsis > .9*FINAL AND x = 0{
		set thrust to (10*mass)/maxthrust.
		set x to 1.
		}.
	if apoapsis >.99*FINAL AND x = 1 {
		set thrust to mass/maxthrust.
		}.
	if apoapsis > FINAL {
		set thrust to 0.
		}.
	if stage:liquidfuel = 0 {
		stage.
		}.
	}.
set thrust to 0.
clearscreen.

//Calculate circular velocity at apoapsis altitude
set x to 1.
set GM to 3.5316*(10^12).
set r to apoapsis+600000.
set vcir to (GM/r)^.5.
set v to 0.
set per to periapsis+600000.
set a to (r+per)/2.
set e to (r-per)/(r+per).
set h to (GM*a*(1-(e^2)))^.5.
set Va to h/r.
set ar to (Va^2)/r.
set g to GM/(r)^2.
set W to mass*(g-ar).
set theta to arcsin(W/maxthrust).

// Warp!
print "Warp to Apogee".
print theta.
set warp to 4.
wait until eta:apoapsis < 1000.
set warp to 3.
wait until eta:apoapsis < 50.
set warp to 0.
lock steering to heading 90 by theta.
clearscreen.

// Waiting on apoapsis arrival.
print "Vertical Speed" at (0,1).
until verticalspeed < 0 {
	print verticalspeed at (20,1).
	print "T-minus " + eta:apoapsis + " to Apoapsis" at (0,0).
	}.
clearscreen.

// Burn to circularize, theta is used to maintain the apogee infront of the craft
print "Burn to Circularize Orbit" at (0,0).
print "Vertical Speed" at (0,1).
print "Orbital Speed" at (0,2).
print "Vcir" at (0,3).
print vcir at (20,3).
print "Theta" at (0,4).
print theta at (20,4).
set y to .5.
set Vo to 0.
set z to 0.
set x to 1.
until vcir-Vo < .001 {
	set thrust to x.
	set vorbit to velocity:orbit.
	set Vox to vorbit:x.
	set Voy to vorbit:y.
	set Voz to vorbit:z.
	set Vo to ((Vox^2)+(Voy^2)+(Voz^2))^.5.
	set ar to (Vo^2)/r.
	set W to mass*(g-ar).
	
	if y = .5 {
		set err to .75.
		set error to 1-(err*verticalspeed).
		set theta to arcsin(W/maxthrust).
		set theta to theta*error.
		}.
	if stage:liquidfuel = 0 AND z < 1{
		stage.
		set z to 1.5.
		}.
	if (Vcir-Vo) < 100  AND y < 1{
		set err to 2.5.
		set A to 10.
		set y to y+1.
		}.
	if (Vcir-Vo) < 10 AND y < 2{
		set err to 5.
		set A to 1.
		set y to y+1.
		}.
	if (Vcir-Vo) < 1 AND y < 3{
		set err to 8.
		set A to .1.
		set y to y+1.
		}.
	if y > 1 {
		set error to 1-(err*verticalspeed).
		set C to mass*A.
		set B to ((W^2)+(C^2))^.5.
		set x to B/maxthrust.
		if x > 1 {
			set x to 1.
			}.
		set theta to arctan(W/C).
		set theta to theta*error.
		}.
	print verticalspeed at (20,1).
	print Vo at (20,2).
	print theta at (20,4).
	}.
lock throttle to 0.
clearscreen.
// DONE!

set e to (apoapsis-periapsis)/(apoapsis+periapsis).
print "Eccentricity" at (0,0). print e at (20,0).
set avg to (apoapsis+periapsis)/2-FINAL.
set error to avg/FINAL*100.
print "Error " + error + "%" at (0,1).
print "Craft is now in Parking Orbit. Begin Phase I" at (0,3).
wait 5.
if stage:liquidfuel > 0 AND stage:liquidfuel < 1000 {
	stage.
	wait 1.
	stage.
	}