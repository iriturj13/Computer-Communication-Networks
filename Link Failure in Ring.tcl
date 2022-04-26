#TASK 2: Link failure with static routing
#Program:
set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail

set udp1 [new Agent/UDP]
$ns attach-agent $n0 $udp1

set null1 [new Agent/Null]
$ns attach-agent $n3 $null1

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1

$ns connect $udp1 $null1

proc finish {} {
global ns nf
$ns flush-trace
close $nf
exec nam out.nam
exit 0
}
$ns rtmodel-at 2.0 down $n1 $n2
$ns rtmodel-at 6.0 up $n1 $n2

$ns at 15.0 "finish"
$ns at 0.5 "$cbr1 start"
$ns at 14.5 "$cbr1 stop"
$ns run

