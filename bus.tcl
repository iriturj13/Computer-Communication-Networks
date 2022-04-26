set ns [new Simulator]

set tf [open bus.tr w]
$ns trace-all $tf

set nf [open bus.nam w]
$ns namtrace-all $nf

set opt(bw) 1Mb ; #BW of bus = 1mb
set opt(delay) 10ms ; #propogation delay
set opt(ll) LL ; #link layer (LL)
set opt(mac) Mac/802_3 ; #IEEE 802.3 MAC protocol - CSMA/CS
set opt(chan) Channel ;
set opt(ifq) Queue/DropTail ; #Network interface queue (Ifq)
set opt(fin) 20.0 ;

#argc - count of arguements
if {$argc !=2} {
puts "Usage : ns bus.tcl <number of nodes> <traffic sources>"
puts "Usage : ns bus.tcl 15 2"
exit
}

#lindex - list index - track of index values try to repeat the values at 0
set nn [lindex $argv 0]
set num [lindex $argv 1]

#create the nodes
for {set i 0} {$i<$nn} {incr i} {
set n($i) [$ns node]
lappend nodeList $n($i) ; #lappend - list append ; collection of objects
}
#$ns make-lan $nodeList 1Mb 10ms LL Queue/DropTail Mac/802_3 Channel
#switchin on the collision events
$ns make-lan -trace on $nodeList $opt(bw) $opt(delay) $opt(ll)
$opt(ifq) $opt(mac) $opt(chan)

set nodex [$ns node]
$ns duplex-link $nodex $n(0) 1Mb 10ms DropTail
$ns duplex-link-op $nodex $n(0) orient right

#step5
#depending on no. of traffic sources the user has given as input, we
#want to create as many application traffic sources eg cb1 cb2 attached
#to n1 n2 and destination is node 0
#cbr 1 2 packetSize_ 500 bytes and $cbr set rate_ 100kb
#schedule multiple traffic sources to transmit at the same time
#schedule all sources to start @ 0.5s and stop and 20sS

#Create UDP agent and attach it to node 0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n(0) $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set null [new Agent/Null]
$ns attach-agent $n(3) $null

set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n(1) $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

$ns connect $udp0 $null
$ns connect $udp1 $null

$ns at $opt(fin) "finish"
proc finish {} {
global ns nf tf
$ns flush-trace
close $nf
close $tf
exec nam bus.nam &
exit 0
}
#schedule events
$ns at 0.5 "$cbr0 start"
$ns at 1 "$cbr1 start"
$ns at 4.5 "$cbr0 stop"
$ns at 20.0 "$cbr1 stop"
$ns at 25.0 "finish"
$ns run
