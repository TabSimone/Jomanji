interface PrintInterface {
	OneWay: 
		Stampa(string)
}
type AddUtente: void {
    .nome: string
	.socket: string
	.numero: int
	.chiavePubblica: string
}

type AddGruppo: void {
    .nome: string
}

type AddChatSingolaRequest: void {
    .mioNome: string
    .nomeDestinatario: string
}
type AddChatSingolaResponse: void {
    .token: string
}

type ChatSendMessageRequest: void {
    .token: string
    .message: string
}

type ChatSendMessageGroupRequest: void {
    .token: string
	.stringaCriptata: string
	.cipherText:string
	.nomeMittente: string
}

type AddGruppoRequest: void {
    .mioNome: string
    .nomeGruppo: string
}
type AddGruppoResponse: void {
    .token: string
}

type aggiornamento: void {
    .token: string
	.tipo: string
}


interface ServerInterface {	
	OneWay: 
		InserisciUtente(AddUtente),
		InserisciGruppo(AddGruppo),
		aggiornaStato(aggiornamento),
		resetStato(aggiornamento),
		inviaPorta(int)		
		
	RequestResponse: 		
		ControlloNomeEsistente(string)(bool),
		ControlloNomeGruppoEsistente(string)(bool),
		NumeroUtenti(void)(int),
		NumeroGruppi(void)(int),
		PrendiNomeUtente(int)(string),
		PrendiNomeGruppo(int)(string),
		addChatSingola( AddChatSingolaRequest )( AddChatSingolaResponse ),
		addGruppo( AddGruppoRequest )( AddGruppoResponse ),
		sendMessage( ChatSendMessageRequest )( void ) throws TokenNotValid,
		sendMessageInGroup( ChatSendMessageGroupRequest )( void ) throws TokenNotValid,
		prendiPorta(void)(int),
		prendiChiavePubblicaDestinatario(string)(string)
}

type SetMessageRequest: void {
    .message: string
    .chat_name: string
    .username: string
}

interface JomanjiInterface {
	OneWay:
		setMessage( SetMessageRequest ),
		setMessageGroup( SetMessageRequest ),
		inviaChiavePrivata (string)	
}


type DigestRequest: void {
    .token: string
    .message: string

}
type DigestResponse: void {
    .stringaCriptata: string
}

type VerificaFirmaDigitaleRequest: void {
    .token: string
    .message: string
	.stringaCriptata: string
}
type VerificaFirmaDigitaleResponse: void {
    .esito: string
}


type chiavi: void {
    .pubblica: string
	.privata: string
}

type encryptAsimmetricoRequest: void {
    .chiavePubblica: string
	.plainText: string
}
type encryptAsimmetricoResponse: void {
	.messaggioCriptato: string
}

type decryptAsimmetricoRequest: void {
    .chiavePrivata: string
	.cipherText: string
}
type decryptAsimmetricoResponse: void {
	.messaggio: string
}

type encryptAsimmetricoRequestGruppi: void {
    .chiavePrivata: string
	.plainText: string
}
type encryptAsimmetricoResponseGruppi: void {
	.messaggioCriptato: string
}

type decryptAsimmetricoRequestGruppi: void {
    .chiavePubblica: string
	.cipherText: string
}
type decryptAsimmetricoResponseGruppi: void {
	.messaggio: string
}

interface CriptoInterface {
	RequestResponse:
		Digest(DigestRequest)(DigestResponse),
		VerificaFirmaDigitale(VerificaFirmaDigitaleRequest)(VerificaFirmaDigitaleResponse),			
		generateAsymmetricKey(void)(chiavi),
		encryptAsimmetrico(encryptAsimmetricoRequest)(encryptAsimmetricoResponse),
		decryptAsimmetrico(decryptAsimmetricoRequest)(decryptAsimmetricoResponse),
		encryptAsimmetricoGruppi(encryptAsimmetricoRequestGruppi)(encryptAsimmetricoResponseGruppi),
		decryptAsimmetricoGruppi(decryptAsimmetricoRequestGruppi)(decryptAsimmetricoResponseGruppi)
}