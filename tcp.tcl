#step1

set ns [new Simulator]

 

#step2

set tf [open tcp.tr w]

$ns trace-all $tf

set nf [open tcp.nam w]

$ns namtrace-all $nf

$ns color 1 Blue

$ns color 2 Red

 

#step3

for {set i 0} {$i < 4} {incr i} {

set n$i [$ns node]

}

 

#step4

$ns duplex-link $n0 $n2 2Mb 10ms DropTail

$ns duplex-link $n1 $n2 2Mb 10ms DropTail

$ns duplex-link $n3 $n2 1.2Mb 20ms DropTail

 

#step5-Attach transport layer agent and application

$ns duplex-link-op $n0 $n2 orient right-down

$ns duplex-link-op $n1 $n2 orient right-up

$ns duplex-link-op $n3 $n2 orient left

$ns duplex-link-op $n2 $n3 queuePos 0.5

set tcp0 [new Agent/TCP]

$ns attach-agent $n0 $tcp0

$tcp0 set class_ 1

 

set ftp [new Application/FTP]

$ftp attach-agent $tcp0

 

set sink [new Agent/TCPSink]

$ns attach-agent $n3 $sink

$ns connect $tcp0 $sink

 

set udp1 [new Agent/UDP]

$udp1 set class_ 2

$ns attach-agent $n1 $udp1

 

set cbr1 [new Application/Traffic/CBR]

$cbr1 attach-agent $udp1

 

#packetSize_ bytes

#interval_ seconds

$cbr1 set packetSize_ 1000

$cbr1 set rate_ 1Mb

#$cbr1 set interval_ 0.005

 

set null [new Agent/Null]

$ns attach-agent $n3 $null

$ns connect $udp1 $null

 

#procedure - to log the cwmd (TCP sender congestion window size at

#every instant of time in a text file,then plot manually a bar graph

set outfile [open tcp.txt w] ; 
#text file to x and y values

proc plotWindow {tcpSource outfile} {

global ns

set now [$ns now]
set cwnd [$tcpSource set cwnd_ ]

puts $outfile "$now $cwnd"

$ns at [expr $now+0.1] "plotWindow $tcpSource $outfile"

}

 

#step6

$ns at 0.1 "$cbr1 start"

$ns at 1.0 "$ftp start"

$ns at 1.0 "plotWindow $tcp0 $outfile"

$ns at 20.0 "$ftp stop"

$ns at 20.5 "$cbr1 stop"

$ns at 20.6 "finish"

 

#step7

proc finish {} {

global ns nf tf

$ns flush-trace

close $tf

close $nf

exec nam tcp.nam &

exit 0

}

 

$ns run





