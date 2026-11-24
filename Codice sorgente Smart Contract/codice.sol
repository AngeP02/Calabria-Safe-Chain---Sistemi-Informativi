// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract SpedizioneMagazzino is Ownable, AccessControl{

    bytes32 public constant SPEDIZIONIERE_ROLE = keccak256("SPEDIZIONIERE_ROLE");

    bool contrattoChiuso;   // True = SmartContract chiuso, False = SmartContract aperto
    uint public contatoreOrdiniSpediti;
    enum tipologiaCarico {FRAGILE, PERICOLOSO, NORMALE}

    struct Spedizione {
        string nomeProdotto;
        uint ID;
        uint peso;
        uint quantita;
        tipologiaCarico tipoCarico;
        uint numeroTracking;
        string vettoreSpedizione;   
        bool spedito; // True = ordine Spedito, False = ordine non Spedito     
        uint index;
    }

    struct Magazzino{
        string ID;
        string locazione;
        uint capienza;
        bool prodottiPericolosi; // True = accetta prodotti pericolosi, False = non accetta prodotti pericolosi 
        bool esiste;
        uint index;
    }

    mapping(uint => Spedizione) public spedizioni;
    mapping(string => Magazzino) public magazzini;
    mapping(uint => bool) public trackingEsistenti;



    Spedizione[] listaSpedizioni;
    Magazzino[] listaMagazzini;
   
    modifier onlySpedizioniere(){
        require(hasRole(SPEDIZIONIERE_ROLE, msg.sender), "Solo lo spedizioniere puo accedere");
        _;
    }

    modifier onlyContrattoAperto(){
        require(contrattoChiuso == false, "Il contratto e chiuso");
        _;
    }


    constructor(address indirizzoSpedizioniere, address owner) Ownable(owner){
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(SPEDIZIONIERE_ROLE, indirizzoSpedizioniere);
        contrattoChiuso = false;
    }

    function chiudiContratto () external onlyOwner onlyContrattoAperto{
        contrattoChiuso = true;
    }

    function apriContratto() external onlyOwner{
        require(contrattoChiuso == true, "Contratto gia aperto");
        contrattoChiuso = false;
    }

    function createNuovaSpedizione(
        string calldata nomeProdotto,
        uint ID,
        uint peso,
        uint quantita,
        tipologiaCarico tipoCarico,
        uint numeroTracking,
        string calldata vettoreSpedizione
    ) external onlyContrattoAperto onlySpedizioniere{
        
        // CHECK
        require(bytes(nomeProdotto).length > 0, "Nome non valido");
        require(peso > 0, "Peso non valido");
        require(quantita > 0, "Quantita non valida");
        require(numeroTracking > 0, "Numero di tracking non valido");
        require(bytes(vettoreSpedizione).length > 0, "Vettore non valido");
        require(ID > 0, "ID non valido");
        require(spedizioni[ID].ID == 0, "Spedizione gia esistente");
        require(trackingEsistenti[numeroTracking] == false, "Numero di tracking gia assegnato ad altro ordine");


        // EFFECTS
        uint nuovoIndex = listaSpedizioni.length;

        trackingEsistenti[numeroTracking] = true;

        Spedizione memory spedizione = Spedizione({
            nomeProdotto: nomeProdotto,
            ID: ID,
            peso: peso,
            quantita: quantita,
            tipoCarico: tipoCarico,
            numeroTracking: numeroTracking,
            vettoreSpedizione: vettoreSpedizione,
            spedito: false,
            index: nuovoIndex

        });

        listaSpedizioni.push(spedizione);
        spedizioni[ID] = spedizione;

        //INTERACTION
        emit spedizioneCreata(ID, nomeProdotto, block.timestamp);
    }



    function createNuovoMagazzino(
        string calldata ID,
        string calldata locazione,
        uint capienza,
        bool prodottiPericolosi
        ) external onlyOwner onlyContrattoAperto{
        
            //CHECK
            require(bytes(ID).length > 0, "ID non valido");
            require(bytes(locazione).length > 0, "Locazione non valida");
            require(capienza > 0, "Capienza non valida");
            
            require(magazzini[ID].esiste == false, "Magazzino gia esistente");

            // EFFECTS
            uint nuovoIndex = listaMagazzini.length;

            Magazzino memory nuovoMagazzino = Magazzino({
                ID: ID,
                locazione: locazione,
                capienza: capienza,
                prodottiPericolosi: prodottiPericolosi,
                esiste: true,
                index: nuovoIndex
            });

            listaMagazzini.push(nuovoMagazzino);
            magazzini[ID] = nuovoMagazzino;

            // INTERACTION
            emit magazzinoCreato(ID, locazione, block.timestamp);
    }

    function readSpedizione (uint idSpedizione) public onlyContrattoAperto view returns (
        string memory nomeProdotto,
        uint peso,
        uint quantita,
        tipologiaCarico tipoCarico,
        uint numeroTracking,
        string memory vettoreSpedizione,
        bool spedito
    ){
        require(spedizioni[idSpedizione].ID != 0, "Spedizione non trovata");

        Spedizione memory spedizione = spedizioni[idSpedizione];
        return(
            spedizione.nomeProdotto,
            spedizione.peso,
            spedizione.quantita,
            spedizione.tipoCarico,
            spedizione.numeroTracking,
            spedizione.vettoreSpedizione,
            spedizione.spedito
        );
        
    }

    function readMagazzino(string calldata idMagazzino) public onlyContrattoAperto view returns ( 
        string memory locazione,
        uint capienza,
        bool prodottiPericolosi
    ){
        require(magazzini[idMagazzino].esiste == true, "Magazzino non trovato");
        Magazzino memory magazzino = magazzini[idMagazzino];
        return(
            magazzino.locazione,
            magazzino.capienza,
            magazzino.prodottiPericolosi
        );
    }

    function numMagazzini() public onlyContrattoAperto view returns (uint){
        return listaMagazzini.length;
    }

    function numOrdiniRegistrati() public onlyContrattoAperto view returns (uint){
        return listaSpedizioni.length;
    }

    function numOrdiniSpediti() public onlyContrattoAperto view returns (uint){
        return contatoreOrdiniSpediti;
    }

    function getSpedizioneDaIndex(uint index) public view onlyContrattoAperto returns (Spedizione memory) {
        require(index < listaSpedizioni.length, "Indice fuori intervallo");
        return listaSpedizioni[index];
    }

    function getMagazzinoDaIndex(uint index) public view onlyContrattoAperto returns (Magazzino memory) {
        require(index < listaMagazzini.length, "Indice fuori intervallo");
        return listaMagazzini[index];
    }


    function spedisciOrdine(
        uint idSpedizione, 
        string calldata idMagazzino
        ) external onlyContrattoAperto onlySpedizioniere{
            // CHECK
            
            require(spedizioni[idSpedizione].ID != 0, "Spedizione non trovata");
            require(magazzini[idMagazzino].esiste == true, "ID magazzino non valido");

            Spedizione storage spedizione = spedizioni[idSpedizione];
            Magazzino storage magazzino = magazzini[idMagazzino];

            require(spedizione.spedito == false, "Ordine gia spedito");

            if (spedizione.tipoCarico == tipologiaCarico.PERICOLOSO){
                require(magazzino.prodottiPericolosi == true, "Magazzino non abilitato per prodotti pericolosi");
            }
            require(magazzino.capienza >= spedizione.quantita, "Spazio in magazzino insufficiente");

            // EFFECTS
            spedizione.spedito = true;
            listaSpedizioni[spedizione.index].spedito = true;
            magazzino.capienza -= spedizione.quantita;
            contatoreOrdiniSpediti ++;

            // INTERACTION
            emit prodottoSpedito(idSpedizione, idMagazzino, block.timestamp);

    }

    event spedizioneCreata (uint indexed ID, string nomeProdotto, uint timestamp);
    event magazzinoCreato(string indexed ID, string locazione, uint timestamp);
    event prodottoSpedito(uint indexed IDOrdine, string indexed IDMagazzino, uint timestamp);
}