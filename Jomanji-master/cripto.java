package cripto;

import jolie.runtime.*;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;
import static org.apache.commons.codec.binary.Base64.decodeBase64;
import static org.apache.commons.codec.binary.Base64.encodeBase64;
import org.apache.commons.codec.digest.DigestUtils;

public class cripto extends JavaService {

    /*
    metodo che applica la funzione sha256 alla stringa di testo + nome dell'utente che invia il messaggio 
    */
    public Value Digest(Value request) {

        String messaggio = request.getFirstChild("message").strValue();
        String token = request.getFirstChild("token").strValue();
        String plaintext = messaggio.concat(token);
        String cipherTextSHA = DigestUtils.sha256Hex(plaintext);
        Value response = Value.create();
        response.getFirstChild("stringaCriptata").setValue(cipherTextSHA);
        return response;
    }

    /*
    metodo che verifica se la firma digita inserita è effettivamente inserita dall'utente che si certifica come tale 
    */
    public Value VerificaFirmaDigitale(Value request) {

        String stringaCriptata = request.getFirstChild("stringaCriptata").strValue();
        String messaggio = request.getFirstChild("message").strValue();
        String token = request.getFirstChild("token").strValue();
        String plainText = messaggio.concat(token);

        String cipherTextSHA = DigestUtils.sha256Hex(plainText);
        Value response = Value.create();

        if (stringaCriptata.contentEquals(cipherTextSHA)) {
            //response.getFirstChild("esito").setValue("Firma digitale confermata");
            response.getFirstChild("esito").setValue("( Verified )");
        } else {
            response.getFirstChild("esito").setValue("( NOT Verified )");
        }
        return response;
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private static final String ASYM_ALGORITHM = "RSA";
    private static final Integer ASYM_KEY_SIZE = 1024;

    public Value generateAsymmetricKey() /*throws NoSuchAlgorithmException*/ {
        try {
            KeyPairGenerator generator = KeyPairGenerator.getInstance(ASYM_ALGORITHM);
            generator.initialize(ASYM_KEY_SIZE);
            KeyPair coppiaChiavi = generator.generateKeyPair();
            Value response = Value.create();
            response.getFirstChild("pubblica").setValue(Base64.getEncoder().encodeToString(coppiaChiavi.getPublic().getEncoded()));
            response.getFirstChild("privata").setValue(Base64.getEncoder().encodeToString(coppiaChiavi.getPrivate().getEncoded()));
            return response;
        } catch (NoSuchAlgorithmException ex) {
            Logger.getLogger(cripto.class.getName()).log(Level.SEVERE, null, ex);
        }
        Value response = Value.create();
        response.getFirstChild("pubblica").setValue("");
        response.getFirstChild("privata").setValue("");
        return response;
    }

    //---------------------------------------------------------------------
    // Criptazione/Decriptazione asimmetrica
    //--------------------------------------------------------------------
    public static Value encryptAsimmetrico(Value request) {
        try {
            String plainText = request.getFirstChild("plainText").strValue();
            byte[] byteChiavePubblica = Base64.getDecoder().decode(request.getFirstChild("chiavePubblica").strValue());
            PublicKey key = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(byteChiavePubblica));
            Cipher cipher = Cipher.getInstance(key.getAlgorithm());
            cipher.init(Cipher.ENCRYPT_MODE, key);
            byte[] ciphertext = cipher.doFinal(plainText.getBytes());
            Value response = Value.create();
            String messaggioCriptato=new String(encodeBase64(ciphertext));
            response.getFirstChild("messaggioCriptato").setValue(messaggioCriptato);
            return response;
            
        } catch (NoSuchAlgorithmException | InvalidKeySpecException | NoSuchPaddingException | InvalidKeyException | IllegalBlockSizeException | BadPaddingException ex) {
            Logger.getLogger(cripto.class.getName()).log(Level.SEVERE, null, ex);
        }
        Value response = Value.create();
        response.getFirstChild("messaggioCriptato").setValue("ce un errore");
        return response;
    }

    public static Value decryptAsimmetrico(Value request) {
        try {
            String ciphertext = request.getFirstChild("cipherText").strValue();
            byte[] byteChiavePrivata = Base64.getDecoder().decode(request.getFirstChild("chiavePrivata").strValue());
            PrivateKey key = KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(byteChiavePrivata));
            Cipher cipher = Cipher.getInstance(key.getAlgorithm());
            byte[] enc = decodeBase64(ciphertext);
            cipher.init(Cipher.DECRYPT_MODE, key);
            byte[] deciphertext = cipher.doFinal(enc);
            Value response = Value.create();
            String messaggioDecriptato= new String(deciphertext);
            response.getFirstChild("messaggio").setValue(messaggioDecriptato);
            return response;

        } catch (NoSuchAlgorithmException | InvalidKeySpecException | NoSuchPaddingException | InvalidKeyException | IllegalBlockSizeException | BadPaddingException ex) {
            Logger.getLogger(cripto.class.getName()).log(Level.SEVERE, null, ex);
        }
        Value response = Value.create();
        response.getFirstChild("messaggio").setValue("ce un errore");
        return response;
    }
    /*
    encript Asimmetrico per i gruppi 
    */
    /*
    Questo metodo agiste con un sestema speculare rispetto al metodo encrypt e decript delle chat singole 
    encrypt cripta con la chiave privata dell'utente 
    mentre decrypt decripta con la chiave pubblica dell'utente che invia il messaggio 
    */
    public static Value encryptAsimmetricoGruppi(Value request) {
        try {
            String plainText = request.getFirstChild("plainText").strValue();
            byte[] byteChiavePrivata = Base64.getDecoder().decode(request.getFirstChild("chiavePrivata").strValue());
            PrivateKey key = KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(byteChiavePrivata));
            Cipher cipher = Cipher.getInstance(key.getAlgorithm());
            cipher.init(Cipher.ENCRYPT_MODE, key);
            byte[] ciphertext = cipher.doFinal(plainText.getBytes());
            Value response = Value.create();
            String messaggioCriptato=new String(encodeBase64(ciphertext));
            response.getFirstChild("messaggioCriptato").setValue(messaggioCriptato);
            return response;
            
        } catch (NoSuchAlgorithmException | InvalidKeySpecException | NoSuchPaddingException | InvalidKeyException | IllegalBlockSizeException | BadPaddingException ex) {
            Logger.getLogger(cripto.class.getName()).log(Level.SEVERE, null, ex);
        }
        Value response = Value.create();
        response.getFirstChild("messaggioCriptato").setValue("ce un errore");
        return response;
    }

    public static Value decryptAsimmetricoGruppi(Value request) {
        try {
            String ciphertext = request.getFirstChild("cipherText").strValue();
            byte[] byteChiavePubblica = Base64.getDecoder().decode(request.getFirstChild("chiavePubblica").strValue());
            PublicKey key = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(byteChiavePubblica));
            Cipher cipher = Cipher.getInstance(key.getAlgorithm());
            byte[] enc = decodeBase64(ciphertext);
            cipher.init(Cipher.DECRYPT_MODE, key);
            byte[] deciphertext = cipher.doFinal(enc);
            Value response = Value.create();
            String messaggioDecriptato= new String(deciphertext);
            response.getFirstChild("messaggio").setValue(messaggioDecriptato);
            return response;

        } catch (NoSuchAlgorithmException | InvalidKeySpecException | NoSuchPaddingException | InvalidKeyException | IllegalBlockSizeException | BadPaddingException ex) {
            Logger.getLogger(cripto.class.getName()).log(Level.SEVERE, null, ex);
        }
        Value response = Value.create();
        response.getFirstChild("messaggio").setValue("ce un errore");
        return response;
    }
    
    public static void main(String args[]) throws NoSuchAlgorithmException, InvalidKeySpecException, NoSuchPaddingException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException{
    
            KeyPairGenerator generator = KeyPairGenerator.getInstance(ASYM_ALGORITHM);
            generator.initialize(ASYM_KEY_SIZE);
            KeyPair coppiaChiavi = generator.generateKeyPair();
            String plainText = "testo da criptare";
            byte[] byteChiavePrivata = Base64.getDecoder().decode(Base64.getEncoder().encodeToString(coppiaChiavi.getPrivate().getEncoded()));
            PrivateKey key = KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(byteChiavePrivata));
            Cipher cipher = Cipher.getInstance(key.getAlgorithm());
            cipher.init(Cipher.ENCRYPT_MODE, key);
            byte[] ciphertext = cipher.doFinal(plainText.getBytes());
            
            String messaggioCriptato=new String(encodeBase64(ciphertext));
            
            System.out.println(messaggioCriptato);
            
            byte[] byteChiavePubblica = Base64.getDecoder().decode(Base64.getEncoder().encodeToString(coppiaChiavi.getPublic().getEncoded()));
            PublicKey key2 = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(byteChiavePubblica));
            Cipher cipher2 = Cipher.getInstance(key2.getAlgorithm());
            byte[] enc = decodeBase64(messaggioCriptato);
            cipher2.init(Cipher.DECRYPT_MODE, key2);
            byte[] deciphertext = cipher2.doFinal(enc);
            
            String messaggioDecriptato= new String(deciphertext);
            
            System.out.println(messaggioDecriptato);
    }
    
}
