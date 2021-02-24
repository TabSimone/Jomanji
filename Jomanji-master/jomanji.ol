include "console.iol"
include "interfaces.iol"
include "runtime.iol"
include "config.iol"
include "file.iol" 



outputPort monitorPort {
    Location: Monitor_location 
    Protocol: sodep
    Interfaces: PrintInterface
}

outputPort serverPort {
    Location: Server_location
    Protocol: sodep
    Interfaces: ServerInterface
}

outputPort jomanjiPort {
    Protocol: sodep
    Interfaces: JomanjiInterface
}

outputPort   CriptoOutputPort {
    Interfaces: CriptoInterface
}

embedded {
  Java:
    "cripto.cripto" in CriptoOutputPort
}

init {
    registerForInput@Console()()
}


define _creazioneGruppo {
    println@Console("------------------------")();
    loopgruppo=true
    
    while(loopgruppo) {    
        print@Console("Come vuoi chiamare il gruppo? ")()  ;
        undef(gruppo)
        in( nomeGruppo );
        if( nomeGruppo!= "exit" ){
            ControlloNomeGruppoEsistente@serverPort(nomeGruppo)(response);     

            if(response==true){
                println@Console( "nome gruppo non disponibile!" )()
            } else{
                with ( gruppo ){
                    .nome = nomeGruppo              
                } 

                InserisciGruppo@serverPort(gruppo)
                println@Console("Creato il gruppo "+ nomeGruppo)()
                Stampa@monitorPort("Creato nuovo gruppo \""+nomeGruppo+"\"");
                NumeroGruppi@serverPort()(num)
                loopgruppo=false
            }
        } else {
            loopgruppo = false
        }
    }   
}

define _stampaListaUtenti {
    println@Console("------------------------")();
    NumeroUtenti@serverPort()(response);
    if (response > 1) {
        println@Console("Ci sono "+response+" utenti")()
    } else {
        println@Console("C'e' un solo utente")()
    }
    println@Console("------------------------")();
    for(i=0,i<response,i++){
        PrendiNomeUtente@serverPort(i)(utente);
        println@Console(utente)()                            
    }  
}

define _stampaListaGruppi {   
    println@Console("------------------------")(); 
    NumeroGruppi@serverPort()(num);
    if (num > 1) {
        println@Console("ci sono "+num+" gruppi")();
        println@Console("------------------------")()
    } else {
        println@Console("C'e' un solo gruppo")()
    }     
    for(i=0,i<num,i++){
        PrendiNomeGruppo@serverPort(i)(gruppo);
        println@Console(gruppo)()                          
    }
}

main { 
    // Menù iniziale
    Stampa@monitorPort("Avviato un nuovo terminale Jomanji")

    //menu1 è per il menu principale
    menu1 = true;
	while( menu1 ){
        println@Console("------------------------")();
		println@Console( "Benvenuto nel Menu' di Jomanji," )();
        println@Console("cosa vuoi fare? ")();
        println@Console("------------------------")();
        println@Console( "1 - Crea utente e accedi" )();
        println@Console( "2 - Exit" )();
        println@Console("------------------------")();
		in( risposta1 )             

        if (risposta1 == 2) {
            println@Console("------------------------")();
            println@Console("Uscita in corso")();
            println@Console("------------------------")();
            menu1 = false  
                        
        }

        //Accesso 
        if (risposta1 == 1) {
            
            menu2 = true;
	        while( menu2 ){

                println@Console( "Inserisci un nickname: " )();
                println@Console("- exit per uscire -")();
                in( request );
                ControlloNomeEsistente@serverPort(request)(response); 
                
                if(response==true){
                    println@Console( "Nome gia' presente!" )()

                } else{ 
                    mioNome=request;     
                    socketchek=false;                  

                    if(!is_defined(global.portCount)){
                        prendiPorta@serverPort()(porta)
                        global.portCount=porta 
                    }                                        
                    
                    numeroSocket=int(User_location_start)+int(global.portCount); 
                    socketCompleta="socket://localhost:"+string (numeroSocket);

                    with( emb ) {
                        .filepath = "-C LOCATION=\"" + socketCompleta + "\" user.ol";
                        .type = "Jolie"
                    };
                    loadEmbeddedService@Runtime(emb)()

                    generateAsymmetricKey@CriptoOutputPort()(chiavi)      

                    //qui inviamo la chiave privata al rispettivo usare tramite la socket
                    jomanjiPort.location = socketCompleta
                    inviaChiavePrivata@jomanjiPort(chiavi.privata)
                    miaChiavePrivata=chiavi.privata
                    undef (jomanjiPort.location)                    

                    undef(emb)
                    Stampa@monitorPort("Creato nuovo utente \""+request+"\"");

                    global.portCount++;
                    inviaPorta@serverPort(global.portCount)
                    
                    undef(utente)
                    with ( utente ){
                        .nome = request;
                        .socket = socketCompleta;
                        .numero = numeroSocket  ;
                        .chiavePubblica = chiavi.pubblica        
                    } 
                    InserisciUtente@serverPort(utente)    
                    menu2=false
                }                  
            }

            //Menù 2 
            menu3 = true;
            while( menu3 ){
                println@Console( "-----------------------" )();
                println@Console( "Ciao "+ mioNome +"!" )();
                println@Console( "1 - Invia messaggio privato" )();
                println@Console( "2 - Invia messaggio in un gruppo" )();
                println@Console( "3 - Crea gruppo" )();
                println@Console( "4 - Lista utenti" )();
                println@Console( "5 - Lista gruppi" )();
                println@Console("- exit per uscire -")();

                //volendo qui possiamo anche aggiungere la possibilità di leggere le chat delle chat passate
                in( risposta3 )
                if( risposta3 != "exit" ){

                    if (risposta3 == 1) { 
                        controlloNome2=true
                        NumeroUtenti@serverPort()(num)

                        if (num < 2) {
                            println@Console("Non ci sono altri utenti ")()
                        } else {

                            //parte per creare le chat e inviare messaggi privati
                            while(controlloNome2 == true) {
                                undef(num);
                                println@Console("------------------------")();
                                println@Console("A chi vuoi inviare il messaggio: ? ")();
                                println@Console(" - exit per uscire -")();
                                println@Console("------------------------")();
                                NumeroUtenti@serverPort()(response);  
                                for(i=0,i<response,i++){
                                    PrendiNomeUtente@serverPort(i)(NomeRitornato);
                                    if(NomeRitornato != mioNome){
                                        println@Console(NomeRitornato)()                        
                                    }
                                }
                                println@Console("------------------------")();

                                in( nomeDestinatario );

                                if(nomeDestinatario!="exit"){
                                    println@Console("------------------------")();
                                    undef(response)
                                    ControlloNomeEsistente@serverPort(nomeDestinatario)(response);                    
                                    if(response==false){
                                        println@Console( "Utente non esistente" )()

                                    } else {                                        
                                        undef(message);
                                        undef(add_req);
                                        with( add_req ) {
                                            .mioNome = mioNome;
                                            .nomeDestinatario = nomeDestinatario
                                        };
                                        
                                        addChatSingola@serverPort( add_req )( add_res );
                                        undef(add_req) 
                                        token = add_res.token;
                                        
                                        aggiornaStato@serverPort(  { .token = token, .tipo="chat" }  );
                                        Stampa@monitorPort("Creata nuova chat tra " + mioNome + " e " + nomeDestinatario);
                                        println@Console( "Chat con "+ nomeDestinatario + " iniziata" )();
                                        
                                        prendiChiavePubblicaDestinatario@serverPort(nomeDestinatario)(chiavePubblicaDestinatario)
                                        while( message != "exit" ) {
                                            in( message )   

                                            if(message != "exit"){ 
                                                with( add_req ) {
                                                    .chiavePubblica = chiavePubblicaDestinatario;
                                                    .plainText = message
                                                };  
                                                //qui crittiamo i messaggi inviati
                                                encryptAsimmetrico@CriptoOutputPort(add_req)(response)
                                                sendMessage@serverPort( { .token = token, .message=response.messaggioCriptato} )()
                                            }
                                        }
                                        resetStato@serverPort(  { .token = token, .tipo="chat" }  );
                                        controlloNome2=false
                                    }
                                    undef( response)

                                } else{
                                    controlloNome2=false
                                }
                            }
                        }  
                    }
                    
                    else if(risposta3 == 2){
                        controlloNome2=true
                        NumeroGruppi@serverPort()(num2)

                        if (num2 < 1) {
                            println@Console("Nessun gruppo creato ")()
                        } else {
                            //parte per creare le chat e inviare messaggi privati
                            while(controlloNome2 == true) {
                                undef(num2);
                                println@Console("------------------------")();
                                println@Console("In quale gruppo vuoi scrivere: ? ")();
                                println@Console(" - exit per uscire -")();
                                println@Console("------------------------")();
                                NumeroGruppi@serverPort()(response);  

                                for(i=0,i<response,i++){
                                    PrendiNomeGruppo@serverPort(i)(NomeRitornato);
                                    println@Console(NomeRitornato)()                                                                                                                                   
                                }

                                println@Console("------------------------")();
                                in( nomeGruppo );

                                if(nomeGruppo!="exit"){
                                    println@Console("------------------------")();
                                    ControlloNomeGruppoEsistente@serverPort(nomeGruppo)(response);
                                                        
                                    if(response==false){
                                        println@Console( "Gruppo non esistente" )()

                                    } else {
                                        undef(message);
                                        undef(add_req);
                                        with( add_req ) {
                                            .mioNome = mioNome;
                                            .nomeGruppo = nomeGruppo
                                        };
                                        addGruppo@serverPort( add_req )( add_res ); 
                                        undef(add_req)                                       
                                        token = add_res.token;  

                                        aggiornaStato@serverPort(  { .token = token, .tipo="gruppi" }  );
                                        println@Console( "Chat nel gruppo "+ nomeGruppo + " iniziata" )();
                                        while( message != "exit" ) {
                                            in( message )
                                            if(message != "exit"){
                                                with( req ) {
                                                    .token = token;
                                                    .message = message
                                                }; 

                                                //Cryptiamo il messaggio
                                                Digest@CriptoOutputPort (req)(res) //sha 
                                                stringaCrittataPerFirma=res.stringaCriptata
                                                undef(req) 

                                                with( req ) {
                                                    .chiavePrivata = miaChiavePrivata;
                                                    .plainText = message                                                   
                                                };

                                                encryptAsimmetricoGruppi@CriptoOutputPort(req)(res)
                                                
                                                undef(req)
                                                with( req) {
                                                    .token = token;
                                                    .stringaCriptata= stringaCrittataPerFirma;
                                                    .cipherText=res.messaggioCriptato;
                                                    .nomeMittente=mioNome
                                                }; 
                                                sendMessageInGroup@serverPort(req)()
                                                undef (req)
                                            }                                        
                                        }

                                        resetStato@serverPort(  { .token = token, .tipo="gruppi" }  );
                                        controlloNome2=false
                                    }
                            
                                } else{
                                    controlloNome2=false
                                }
                            }
                        }
                    }
                    else if(risposta3 == 3){
                        _creazioneGruppo
                    }
                    else if(risposta3 == 4){
                        _stampaListaUtenti
                    }
                    else if(risposta3 == 5){
                        _stampaListaGruppi                            
                    }

                } else {
                    println@Console("------------------------")();
                    println@Console("Disconnessione in corso")();
                    Stampa@monitorPort("Utente " + mioNome + " disconnesso");
                    menu3 = false
                    menu1= false
                }
            } 
        }        
    }    
}