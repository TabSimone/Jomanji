
include "console.iol"
include "interfaces.iol"
include "time.iol"
include "runtime.iol"
include "config.iol"
include "file.iol" 

outputPort monitorPort {
    Location: Monitor_location 
    Protocol: sodep
    Interfaces: PrintInterface
}

outputPort jomanjiPort {
    Protocol: sodep
    Interfaces: JomanjiInterface
}

inputPort serverPort {
    Location: Server_location
    Protocol: sodep
    Interfaces: ServerInterface
}

outputPort   CriptoOutputPort {
    Interfaces: CriptoInterface
}

embedded {
  Java:
    "cripto.cripto" in CriptoOutputPort
}




execution{concurrent}

init{   
        Stampa@monitorPort("Server Collegato");   
        deleteDir@File( "Chat" )( ) ;
        deleteDir@File( "Gruppi" )( );
        global.porta=1;
        global.conta=0
}

main {    
    [ControlloNomeEsistente(request)(response){      
        cont2=0;
        numeroNomi=0;
        undef(response)        
        for(i=0, i<#global.utenti ,i++){
            if (global.utenti[i].nome == request){
                cont2++
            }            
        }
        if(cont2==0){
            response=false
        }
        else{
            response=true
        }
    }]
    
    [ControlloNomeGruppoEsistente(request)(response){
        cont=0;        
        for(i=0, i<#global.gruppi ,i++){
            if (global.gruppi[i].nome == request){
                cont++
            }            
        }
        if(cont==0){
            response=false
        }
        else{
            response=true
        }
    }]

    [InserisciUtente(utente)]{
        tmp=#global.utenti;
        global.utenti[tmp].nome = utente.nome;
        global.utenti[tmp].socket = utente.socket;
        global.utenti[tmp].numero = utente.numero;
        global.utenti[tmp].chiavePubblica = utente.chiavePubblica
    }

    [InserisciGruppo(gruppo)]{  
        tmp=#global.gruppi;        
        global.gruppi[tmp].nome = gruppo.nome      
    }

    [aggiornaStato(request)]{  
        nome = global.tokens.( request.token ).username;
        if(request.tipo=="chat"){
            conversazione = global.tokens.( request.token ).NomeChat
        }

        else if(request.tipo=="gruppi"){
            conversazione = global.tokens.( request.token ).nomeGruppo
        }
        for(i=0,i<#global.utenti,i++)
        {
            if(global.utenti[i].nome==nome ){
                global.utenti[i].stato=conversazione
            }
        }
    }

    [resetStato(request)]{  
        nome = global.tokens.( request.token ).username;
        for(i=0,i<#global.utenti,i++)
        {
            if(global.utenti[i].nome==nome ){
                global.utenti[i].stato=""
            }
        }
    }

    [inviaPorta(request)]{  
        global.porta=request 
    }

    [prendiPorta()(response){  
        response=global.porta
    }]

    [NumeroUtenti()(response){          
        response=#global.utenti
    }]
    
    [NumeroGruppi()(response){          
        response=#global.gruppi
    }]

    [PrendiNomeUtente(indice)(utente){                     
        utente=global.utenti[indice].nome
    }]

    [PrendiNomeGruppo(indice)(gruppo){                     
        gruppo=global.gruppi[indice].nome
    }]

    [prendiChiavePubblicaDestinatario(nomeDestinatario)(chiavePubblicaDestinatario){                     
        for(i=0,i<#global.utenti,i++)
        {
            if(nomeDestinatario==global.utenti[i].nome)
            {
                chiavePubblicaDestinatario=global.utenti[i].chiavePubblica
            }
        }
    }]

    [addChatSingola(request)(response){
        for(i=0,i<#global.utenti,i++){
            if(global.utenti[i].nome == request.mioNome){
                PrimoNumero = global.utenti[i].numero
                PrimoNome=global.utenti[i].nome
            }
            if(global.utenti[i].nome == request.nomeDestinatario){
                SecondoNumero = global.utenti[i].numero
                SecondoNome=global.utenti[i].nome
            }
        }
        //creiamo il nome delle chat
        if(PrimoNumero > SecondoNumero){
             tmp=PrimoNumero;
             tmp2=PrimoNome
             PrimoNumero=SecondoNumero;
             PrimoNome=SecondoNome
             SecondoNumero=tmp
             SecondoNome=tmp2
        }

        NomeChat=string( PrimoNome+"_"+SecondoNome );
        if ( !is_defined( global.chat.( NomeChat ) ) ) {
            global.chat.( NomeChat ) = true
        };

        isDirectory@File( "Chat" )( response )
        if(response==false) {
            mkdir@File("Chat")()
        }

        NomeFileEsteso= string ("./Chat/"+NomeChat+".txt");
        exists@File( NomeFileEsteso )( response );        
        if(response==false){
            with( file ) {
                .filename = NomeFileEsteso;
                .content = ""
            }
            writeFile@File( file )()
        }      

        //controlliamo se era già stato creato un token precedentemente oppure no
        if ( !is_defined( global.chat.( NomeChat ).users.( request.mioNome ) )) {
            for(i=0,i<#global.utenti,i++){
                if(global.utenti[i].nome == request.mioNome){
                    location=global.utenti[i].socket
                }
            }
            global.chat.( NomeChat ).users.( request.mioNome ).location = location;
            token = new;
            global.chat.( NomeChat ).users.( request.mioNome ).token = token;
            global.tokens.( token ).NomeChat = NomeChat;
            global.tokens.( token ).username = request.mioNome                
        };       
        undef (response) 
        response.token = global.chat.( NomeChat ).users.( request.mioNome ).token
        undef (request)
    }]

    [addGruppo (request)(response){
        if ( !is_defined( global.gruppi.( request.nomeGruppo ) ) ) {
            global.gruppi.( request.nomeGruppo ) = true
        };

        isDirectory@File( "Gruppi" )( response )
        if(response==false) {
            mkdir@File("Gruppi")()
        }

        NomeFileEsteso= string ("./Gruppi/"+request.nomeGruppo+".txt");
        exists@File( NomeFileEsteso )( response );

        if(response==false){
            with( file ) {
                .filename = NomeFileEsteso;
                .content = ""
            }
            writeFile@File( file )()
        }       

        //controlliamo se era già stato creato un tocken precedentemente oppure no
        if ( !is_defined( global.gruppi.( request.nomeGruppo ).users.( request.mioNome ) )) {
            for(i=0,i<#global.utenti,i++){
                if(global.utenti[i].nome == request.mioNome){
                    location=global.utenti[i].socket
                }
            }
            global.gruppi.( request.nomeGruppo ).users.( request.mioNome ).location = location;
            token = new;
            global.gruppi.( request.nomeGruppo  ).users.( request.mioNome ).token = token;
            global.tokens.( token ).nomeGruppo = request.nomeGruppo;
            global.tokens.( token ).username = request.mioNome                
        };      
        undef (response)  
        response.token = global.gruppi.( request.nomeGruppo ).users.( request.mioNome ).token
        undef (request)
        
    }]

    



    [ sendMessage( request )( response ) {
        if ( is_defined( global.tokens.( request.token ) ) ) {
            NomeChat = global.tokens.( request.token ).NomeChat;
            
            //questo foreach gestisce l'invio dei messaggi nella chat privata quindi verra eseguito una sola volta 
            foreach( u : global.chat.( NomeChat ).users ) {
                jomanjiPort.location = global.chat.( NomeChat ).users.( u ).location;
                //serve per non automandarmi un messaggio
                if ( u != global.tokens.( request.token ).username ) {
                    for(i=0,i<#global.utenti,i++){
                        if(global.utenti[i].nome==u && global.utenti[i].stato == NomeChat){
                            aa=true                           
                        }
                    }
                    if(aa){                                
                        with( msg ) {
                            .message = request.message;
                            .chat_name = NomeChat;
                            .username = global.tokens.( request.token ).username
                        }; 
                        setMessage@jomanjiPort( msg )
                    }                    
                    undef(aa)
                } 
            }
        }  
        else {
            throw( TokenNotValid )
        }

    }]

    [ sendMessageInGroup( request )( response ) {        
        if ( is_defined( global.tokens.( request.token ) ) ) {
            nomeGruppo = global.tokens.( request.token ).nomeGruppo;  
            tmpcont=0
            foreach( u : global.gruppi.( nomeGruppo ).users ) {
                jomanjiPort.location = global.gruppi.( nomeGruppo ).users.( u ).location;
                if ( u != global.tokens.( request.token ).username) {
                    for(i=0,i<#global.utenti,i++){
                        if(global.utenti[i].nome== u && global.utenti[i].stato == nomeGruppo){
                            aa=true
                        }
                    }
                    //entro qui dentro quando c'è almeno un utente a cui inviare il messaggio
                    if(aa){ 
                        //qui mi rimedio la chiave pubblica del mittente 
                        for(i=0,i<#global.utenti,i++){
                            if(global.utenti[i].nome == request.nomeMittente){                    
                                chiavePubblicaMittente=global.utenti[i].chiavePubblica
                            }
                        } 
                        TestoCriptato = request.cipherText  //questa variabile ci servirà dopo   
                        with(req){
                            .chiavePubblica=chiavePubblicaMittente;
                            .cipherText=TestoCriptato
                        }
                        //qui decriptiamo il messaggio che il server deve inviare
                        decryptAsimmetricoGruppi@CriptoOutputPort(req)(res)
                        undef(req)
                        with(req){
                            .token=request.token;
                            .message=res.messaggio;
                            .stringaCriptata=request.stringaCriptata
                        }
                        //verifica della firma digitale del sender
                        VerificaFirmaDigitale@CriptoOutputPort(req)(res)
                        with( msg ) {
                            .message = req.message +" "+res.esito;
                            .chat_name = nomeGruppo;
                            .username = global.tokens.( request.token ).username                            
                        };         
                        undef (req);                             
                        setMessageGroup@jomanjiPort( msg );                       
                        tmpcont++   //questa variabile serve per evitare le stampe ripetute nel file 
                    }
                    undef (aa)
                }
            } 

            //parte per scrivere nei file
            if(tmpcont>0)
            {
                Stampa@monitorPort(msg.username + "@" + msg.chat_name + ":" + TestoCriptato);    
                f.filename = string ("Gruppi/"+msg.chat_name+".txt")
                stringaDaScrivere = msg.username + "@" + msg.chat_name + ": " + msg.message + "\n" 
                with( rq_w ) {
                    .filename = f.filename;
                    .content = stringaDaScrivere;
                    .append = 1
                }
                writeFile@File( rq_w )()      
            }   
        }
        else {
            throw( TokenNotValid )
        }     
    }]
}