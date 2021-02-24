include "console.iol"
include "string_utils.iol"
include "interfaces.iol"
include "config.iol"

// porta parla ccon servere e client - socket uguale
inputPort monitorPort {
	Location: Monitor_location 
	Protocol: sodep
	Interfaces: PrintInterface
}

execution{concurrent}
init{
	global.i=1
}

main{
    //stampo tutti gli eventi nel terminale del monitor
	[Stampa(stringa)]{
		synchronized(Token){
		    println@Console(global.i + ". " + stringa )();
		    global.i++
		}
	}
}