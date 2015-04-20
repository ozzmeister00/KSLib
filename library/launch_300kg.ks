// My First Launcher

//the following are all vectors, mainly for use in the roll, pitch, and angle of attack calculations
lock rightrotation to ship:facing*r(0,90,0).
lock right to rightrotation:vector. //right and left are directly along wings
lock left to (-1)*right.
lock up to ship:up:vector. //up and down are skyward and groundward
lock down to (-1)*up.
lock fore to ship:facing:vector. //fore and aft point to the nose and tail
lock aft to (-1)*fore.
lock righthor to vcrs(up,fore). //right and left horizons
lock lefthor to (-1)*righthor.
lock forehor to vcrs(righthor,up). //forward and backward horizons
lock afthor to (-1)*forehor.
lock top to vcrs(fore,right). //above the cockpit, through the floor
lock bottom to (-1)*top.

//the following are all angles, useful for control programs
lock absaoa to vang(fore,srfprograde:vector). //absolute angle of attack
lock aoa to vang(top,srfprograde:vector)-90. //pitch component of angle of attack
lock sideslip to vang(right,srfprograde:vector)-90. //yaw component of aoa
lock rollangle to vang(right,righthor)*((90-vang(top,righthor))/abs(90-vang(top,righthor))). //roll angle, 0 at level flight
lock pitchangle to vang(fore,forehor)*((90-vang(fore,up))/abs(90-vang(fore,up))). //pitch angle, 0 at level flight
lock glideslope to vang(srfprograde:vector,forehor)*((90-vang(srfprograde:vector,up))/abs(90-vang(srfprograde:vector,up))).
//
//

SET TARGET_ALTITUDE TO 100000.
SET SPACE_START_ALT TO 70000.
SET CLIMB_ATT TO 20.
SET thrott TO 0.
LOCK THROTTLE TO thrott.
SET countdown to 10.
PRINT "Counting down:".
UNTIL countdown = 0 {
	PRINT "..." + countdown.
	SET countdown TO countdown - 1.
	WAIT 1.
}.

PRINT "Launch!".
SET thrott TO 1.0.   // 1.0 is the max, 0.0 is idle.
LOCK STEERING TO HEADING(90,90).
STAGE.

WAIT UNTIL ALTITUDE > 250.
LOCK STEERING TO HEADING(90,85).
WAIT UNTIL ALTITUDE > 2000.

LOCK STEERING TO SRFPROGRADE.

WAIT UNTIL STAGE:SOLIDFUEL < 0.001.
WAIT 0.1.
STAGE.
WAIT 1.
STAGE.

WHEN ALTITUDE > 30000 THEN {
	LOCK STEERING TO HEADING(90,CLIMB_ATT).
}.

WAIT UNTIL STAGE:LIQUIDFUEL < 0.001.
PRINT "Increasing Apoapsis to 100km.".
WAIT 0.1.
STAGE.
WAIT 1.
STAGE.

WAIT UNTIL ALTITUDE > 70000.
STAGE.
LOCK STEERING TO LOOKDIRUP(HEADING(90,CLIMB_ATT/2):VECTOR,SUN:POSITION).
LOCK THROTTLE TO 0.0.
WAIT 3.
LOCK THROTTLE TO thrott.

//WAIT UNTIL APOAPSIS >= 100000.
// Begin PID throttle control to until Altitude > 70km
SET Kp TO 0.01.
LOCK dtThrott TO Kp * (TARGET_ALTITUDE - APOAPSIS).

UNTIL ALTITUDE > SPACE_START_ALT AND APOAPSIS >= TARGET_ALTITUDE - 10 {
	PRINT "thrott = " + ROUND(thrott,2) + " / dtThrott = " + ROUND(dtThrott,2) + " / APO = " + ROUND(APOAPSIS,2) AT(0,0).
	SET thrott TO dtThrott.
	IF thrott > 1 {
		SET thrott TO 1.0.
	} ELSE IF thrott < 0 {
		SET thrott TO 0.0.
	}.
	WAIT 0.0001.
}.
SET thrott TO 0.0.
LOCK STEERING TO LOOKDIRUP(HEADING(90,0):VECTOR,SUN:POSITION).

// Circularisation manouvre.
WAIT UNTIL VERTICALSPEED < 5.
LOCK THROTTLE TO 1.0.

WAIT UNTIL PERIAPSIS > 99900.
LOCK THROTTLE TO 0.0.

SHUTDOWN. // save power.

//WAIT 2. // give throttle time to adjust.
//UNTIL SHIP:MAXTHRUST > 0 {
//    WAIT 0.5. // pause half a second between stage attempts.
//    PRINT "Stage activated.".
//    STAGE. // same as hitting the spacebar.
//}.
//WAIT UNTIL SHIP:ALTITUDE > 70000. // pause here until ship is high up.
//
// NOTE that it is vital to not just let the script end right away
// here.  Once a kOS script just ends, it releases all the controls
// back to manual piloting so that you can fly the ship by hand again.
// If the pogram just ended here, then that would cause the throttle
// to turn back off again right away and nothing would happen.