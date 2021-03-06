
#Step 1: Creating Simulator class
set ns [new Simulator]

#Step 2: tracefile and NAMfile

set tf [open star.tr w]
$ns trace-all $tf

set nf [open star.nam w]
$ns namtrace-all $nf

#Step 3: Create Nodes 

for {set i 0} { $i<4 } {incr i} {
set n$i [$ns node]
}

$ns color 1 Blue
$ns color 2 Red

#Step 4: Create Links
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Step 5: Agents
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0


set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n1 $udp1


set null [new Agent/Null]
$ns attach-agent $n3 $null


#Step 6: Set Application i.e packetSize_ ,Interval_
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1 
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005

$ns connect $udp0 $null
$ns connect $udp1 $null


#Step 7: Schedule everything
$ns at 0.5 "$cbr0 start"
$ns at 1.0 "$cbr1 start"
$ns at 4.5 "$cbr0 stop"
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"

#Step 8: write the finish procedure
proc finish {} {
global ns nf tf
$ns flush-trace

close $tf
close $nf
exec nam star.nam &
exit 0
}
$ns run



