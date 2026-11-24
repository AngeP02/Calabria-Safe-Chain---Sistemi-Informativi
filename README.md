# Sistemi Informativi — Progetti

Questo repository raccoglie i due progetti realizzati per il corso di **Sistemi Informativi**.

## Progetti

| Progetto | Descrizione breve |
|---|---|
| [CalabriaSafeChain](#1-calabriasafechain) | Piattaforma DLT per la tracciabilità agroalimentare calabrese |
| [Smart Contract Spedizioni](#2-smart-contract-spedizioni) | Smart contract per la gestione delle spedizioni da magazzino a rivenditore |


## 1. CalabriaSafeChain

#### Descrizione

CalabriaSafeChain è un sistema informativo progettato per garantire l'autenticità e la tracciabilità dei prodotti agroalimentari calabresi certificati DOP e IGP. Il problema di partenza è concreto: i sistemi di certificazione tradizionali — registri cartacei, database centralizzati, QR Code — sono vulnerabili a manipolazioni e contraffazioni. Un QR Code può essere fotocopiato su mille bottiglie false; un database centralizzato può essere alterato da chi lo gestisce.

La risposta è un'architettura ibrida che combina:

- una **blockchain permissioned** (Hyperledger Fabric) per l'immutabilità e la tracciabilità
- **tag NFC antimanomissione** per legare fisicamente il prodotto alla sua identità digitale
- **sensori IoT** per monitorare le condizioni di trasporto (temperatura, umidità) in tempo reale
- **smart contract** per automatizzare controlli e certificazioni senza intervento umano

#### Attori coinvolti

La filiera coinvolge sette ruoli principali, ognuno con il proprio sottosistema dedicato:

| Attore | Ruolo nella piattaforma |
|---|---|
| **Imprenditore Agricolo** | Registra l'origine della materia prima e le pratiche di coltivazione |
| **Trasformatore Primario** | Certifica il processo di trasformazione e genera i tag NFC sulle confezioni |
| **Trasportatore** | Avvia la spedizione, monitora IoT durante il viaggio, gestisce gli alert |
| **Rivenditore** | Verifica l'autenticità dei prodotti ricevuti prima della messa a scaffale |
| **Consumatore** | Scansiona il tag NFC per vedere la storia completa del prodotto |
| **Consorzio di Tutela** | Monitora i volumi produttivi, tutela il marchio, interviene su anomalie |
| **Intermediario** | Gestisce la piattaforma, le identità digitali e i nodi blockchain |

#### Flusso principale

1. L'agricoltore registra il lotto di raccolta sulla piattaforma
2. Il trasformatore primario calcola il bilancio di massa (materia prima → prodotto finito), genera gli identificativi univoci e scrive i tag NFC su ogni confezione
3. Durante il trasporto, i sensori IoT trasmettono dati in continuo; se qualcosa supera le soglie di sicurezza, lo smart contract registra l'allarme sulla blockchain in automatico
4. Il rivenditore, alla ricezione della merce, scansiona i tag NFC a campione e verifica l'autenticità su blockchain
5. Il consumatore scansiona il tag con il proprio smartphone e visualizza la storia completa del prodotto — origine, trasformazione, trasporto, certificazioni

#### Architettura

L'architettura segue il paradigma a **microservizi**, con un sottosistema separato per ogni attore. I dati pesanti (log IoT, certificati) vengono salvati in database off-chain, mentre sulla blockchain viene registrato solo l'hash di validazione. Questo bilancia sicurezza e performance.

**Stack tecnologico:**

| Layer | Tecnologia |
|---|---|
| Backend | Spring Boot |
| Frontend / Dashboard | React |
| App mobile (consumatore, trasportatore) | Flutter (cross-platform Android/iOS) |
| Blockchain | Hyperledger Fabric (permissioned) |
| Database relazionali | PostgreSQL |
| Database NoSQL (log, sensori, feedback) | MongoDB (o equivalente) |
| Comunicazione IoT | MQTT |
| Containerizzazione | Docker + Kubernetes |
| Versioning | Git |
| Sicurezza API | HTTPS/TLS + API Gateway |

#### Project Plan

Il progetto è strutturato su un orizzonte di **6 anni** (gennaio 2027 – dicembre 2032):

- **Fase 1 — Sviluppo (Anno 0, 2027):** realizzazione dell'intera infrastruttura — blockchain, database off-chain, API, smart contract, sottosistemi dei singoli attori, integrazione IoT/NFC, testing e deployment. Team: 1 PM, 1 Software Architect, 5 Full Stack Developer, 8 Junior Developer. Impegno totale stimato: ~17.500 ore/persona (~10 anni/persona).
- **Fase 2 — Esercizio e manutenzione (Anni 1–5, 2028–2032):** commercializzazione dei kit NFC, supporto tecnico, manutenzione evolutiva, aggiornamento degli smart contract alle normative DOP/IGP, espansione verso la GDO internazionale.

#### Analisi SWOT (sintesi)

**Punti di forza:** legame fisico/digitale non clonabile, certificazione dinamica via IoT, controlli automatizzati tramite smart contract, immutabilità dei dati, coinvolgimento istituzionale (ARSAC, Consorzi).

**Punti di debolezza:** costo iniziale dei tag NFC e dei sensori IoT più elevato rispetto ai QR Code, latenza intrinseca della blockchain, dipendenza dall'Intermediario, divario digitale tra gli operatori.

**Opportunità:** fondi europei per la digitalizzazione agroalimentare, interesse della GDO internazionale (Carrefour, etc.), valorizzazione del Made in Calabria, dati di consumo vendibili ai produttori.

**Minacce:** concorrenza di IBM Food Trust, resistenza culturale alla trasparenza, obsolescenza tecnologica dell'hardware NFC.

## 2. Smart Contract Spedizioni

#### Descrizione

Uno smart contract scritto in **Solidity** che gestisce il processo di spedizione di prodotti finiti da un magazzino a un rivenditore autorizzato. Garantisce tracciabilità e immutabilità delle informazioni su blockchain, con una gestione strutturata dei permessi e dei vincoli logistici.

#### Ruoli e permessi

| Ruolo | Permessi |
|---|---|
| **Owner** | Deploy, apertura/chiusura del contratto, creazione magazzini |
| **Spedizioniere** | Creazione spedizioni, invio ordini ai magazzini |

La gestione dei ruoli usa le librerie OpenZeppelin: `Ownable` per l'Owner, `AccessControl` con `keccak256` per il ruolo Spedizioniere. Più indirizzi possono avere lo stesso ruolo.

#### Strutture dati principali

**`Spedizione`** — nome prodotto, ID, peso, quantità, numero di tracking (univoco globale), vettore, tipologia carico (`FRAGILE` / `PERICOLOSO` / `NORMALE`), stato (spedito / non spedito).

**`Magazzino`** — ID stringa, locazione fisica, capienza massima, flag per accettazione prodotti pericolosi.

Lo storage usa il pattern **CRU(D)** con doppia struttura: un `mapping` per l'accesso diretto per ID e un `array` di supporto per l'enumerazione. Il campo `index` in ogni struct collega le due strutture.
