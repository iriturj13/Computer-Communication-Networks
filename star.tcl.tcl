#STAR TOPOLOGY

##STAR TOPOLOGY 
#Step 1: Create an object of Simulator class
set ns [new Simulator]

#Step 2: Create two files 
#->File 1: Trace file(Log File)
#->File 2: NAM file(Network Animator)
set tf [open star.tr w]
$ns trace-all $tf

set nf [open star.nam w]
$ns namtrace-all $nf

#Add color to traffic flow
$ns color 1 Blue
$ns color 2 Red
#Create network topology
#Step 3: Create nodes using 'for' loop
set num 4
for {set i 0} {$i < $num} {incr i} {
set n($i) [$ns node]
}

#Step 4: Create links
# $ns -> simple-link ; duplex-link
#(Note: Mb=Megabit && MB=MegaByte)
$ns duplex-link $n(0) $n(2) 1Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 1Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 1Mb 10ms SFQ #SFQ - Stochastic fair Queuing Mechanism
#Drop Tail = Queueing Policy -
#op-orient position 
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns duplex-link-op $n(2) $n(3) orient right

$ns duplex-link-op $n(2) $n(3) queuePos 0.5
#Step 5: N0 - sender generate traffic 
 #Application Layer - Traffic model
 #N1 - Reciever 
 #Traffic Model - configuration model
 #Layer 4 configuration
set udp0 [new Agent/UDP]
$udp0 set class_ 1 
$ns attach-agent $n(0) $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500 ; # Packet Size - 500 bytes
$cbr0 set interval  0.005 ; # Packet interval every 2ms generate
$cbr0 attach-agent $udp0

set null [new Agent/Null]
$ns attach-agent $n(3) $null 

set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n(1) $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500 ; # Packet Size - 500 bytes
$cbr1 set interval  0.005 ; # Packet interval every 2ms generate
$cbr1 attach-agent $udp1 ; # Stack Application Layer on top of Transport

$ns connect $udp0 $null
$ns connect $udp1 $null
#Step 6: Finish Procedure
 #schedule your run
$ns at 0.5 "$cbr0 start"
$ns at 1.5 "$cbr1 start"
$ns at 4.5 "$cbr0 stop" 
$ns at 4.5 "$cbr1 stop" 
$ns at 5.0 "finish"
#Finish Procedure
proc finish {} {
global ns nf tf 
$ns flush-trace
close $nf
close $tf
exec nam star.nam &
exit 0
}
$ns run



