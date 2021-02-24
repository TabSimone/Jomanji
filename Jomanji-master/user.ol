include "console.iol"
include "interfaces.iol"
include "config.iol"
include "file.iol" 

execution{ concurrent }



inputPort jomanjiPort {
  Location: LOCATION       /* LOCATION viene assegnata dinamicamente */
  Protocol: sodep
  Interfaces: JomanjiInterface
}

outputPort monitorPort {
     Location: Monitor_location 
     Protocol: sodep
     Interfaces: PrintInterface
}

init {
    inviaChiavePrivata (chiavePrivata)
}

outputPort   CriptoOutputPort {
    Interfaces: CriptoInterface
}

embedded {
  Java:
    "cripto.cripto" in CriptoOutputPort
}

main {
    [setMessage( request )]{
    
    with( add_req ) {
        .chiavePrivata = chiavePrivata;
        .cipherText = request.message
    };

    decryptAsimmetrico@CriptoOutputPort(add_req)(response)

    f.filename = string ("Chat/"+request.chat_name+".txt")              
    stringaDaScrivere = request.username + "@" + request.chat_name + ": " + response.messaggio + "\n" 
    with( rq_w ) {
        .filename = f.filename;
        .content = stringaDaScrivere;
        .append = 1
    }    
    writeFile@File( rq_w )() 
    print@Console( request.username + "@" + request.chat_name + ":" )();
    println@Console( response.messaggio  )()
    Stampa@monitorPort(request.username + "@" + request.chat_name + ":" + request.message)   
    } 

    [setMessageGroup( request )]{
    
      print@Console( request.username + "@" + request.chat_name + ":" )();
      println@Console( request.message )()   
    }
}