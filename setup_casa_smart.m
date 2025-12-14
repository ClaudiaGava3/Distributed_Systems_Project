% --- setup_casa_smart.m ---
% Script di configurazione per Casa Smart Distribuita (Digital Twin)
% Include: Fisica 2 Masse, Controllo Probabilistico, Meteo, Gestore Carichi
clear; clc;

%% 1. PARAMETRI DI SIMULAZIONE
dt = 0.1;             % Passo di simulazione fisso (Fondamentale per la logica discreta)
T_giorni = 3;         % Numero di giorni da simulare
T_sim = T_giorni * 86400; % Durata totale in secondi (259200 s)

% Nota: T_ext variabile viene caricata dallo script 'fetch_meteo.m'.
% Se non usi quel file, scommenta la riga sotto per un valore fisso di fallback:
% T_ext = 5; 

%% 2. PARAMETRI FISICI STANZE (Modello 2 Masse: Aria + Muri)
% Capacità Termica (J/K) e Resistenze (K/W)
% C_aria aumentata per simulare l'arredamento (massa interna)

% SALOTTO (Grande, vetrate, disperde molto)
C_aria_Salotto = 250000;  
C_muri_Salotto = 60000000; 
R_ext_Salotto  = 0.8;     

% CUCINA (Media)
C_aria_Cucina  = 150000;
C_muri_Cucina  = 35000000;
R_ext_Cucina   = 1.0;

% CORRIDOIO (Zona di passaggio, interno)
C_aria_Corr    = 100000;
C_muri_Corr    = 25000000;
R_ext_Corr     = 1.0;     % Abbassato da 5.0 per permettere dispersione termica

% BAGNO (Piccolo, umido)
C_aria_Bagno   = 60000;
C_muri_Bagno   = 15000000;
R_ext_Bagno    = 1.0;

% CAMERA (Media, ben isolata)
C_aria_Camera  = 120000;
C_muri_Camera  = 30000000;
R_ext_Camera   = 1.2;     

% SCAMBIO TERMICO INTERNO
R_int = 2.0; % Resistenza muri divisori/porte tra stanze
R_ia  = 0.1; % Resistenza scambio rapido Aria <-> Muri interni

%% 3. GESTIONE ENERGETICA (Smart Grid & Consenso)
% Limite massimo del contatore per tutta la casa
P_Grid_Max = 3000; % Watt (3 kW)

% Potenze Massime per i Fan-Coil delle singole stanze
% (Il Bagno ha meno potenza per evitare oscillazioni violente)
P_max = 1200; % Potenza standard (Salotto, Cucina, Camera, Corridoio)
P_max_Cool = -1200;

% Parametri specifici (usati se bypassi il P_max globale nella maschera)
P_max_Bagno = 400; 

%% 4. PARAMETRI DI CONTROLLO (Cervello Distribuito)
% Target di Temperatura
T_Comfort = 21; % Quando c'è presenza
T_Eco     = 17; % Quando è vuota (Giorno)
T_Notte   = 15; % Deep Eco (Notte fonda per stanze giorno)

% PID Tuning (Calibrato per inerzia alta)
Kp = 200; 
Ki = 0.005; % Integrale molto basso per evitare accumulo su tempi lunghi
Kd = 5000;  % Derivativo alto per frenare l'overshoot
N  = 100;   % Filtro derivativo

% Logiche di Isteresi e Risparmio
Deadband = 3.0; % Tolleranza ampia (es. scalda a 21, spegne a 24, riaccende a 21)

% Parametri Finestra Automatica (Raffrescamento Passivo)
Coeff_Finestra = 100;           % Watt dispersi per ogni grado di differenza T_int - T_ext
Soglia_Apertura_Finestra = 23.5; % Temperatura a cui si apre la finestra
Soglia_Accensione_AC     = 24.5; % Temperatura a cui parte l'AC (se finestra non basta)

% Optimal Start (Velocità di riscaldamento stimata °C/s)
% Usata per calcolare l'anticipo di accensione
Velocita_Cucina  = 0.015; 
Velocita_Salotto = 0.007;
Velocita_Bagno   = 0.020; % Molto veloce
Velocita_Camera  = 0.010;
Velocita_Corridoio = 0.010;

% Orari Target per Optimal Start (Secondi dalla mezzanotte)
Ora_Target_Giorno = 7 * 3600;  % 07:00 (Cucina, Bagno)
Ora_Target_Sera   = 18 * 3600; % 18:00 (Salotto, Corridoio)
Ora_Target_Notte  = 22 * 3600; % 22:00 (Camera)

%% 5. PARAMETRI SENSORI E DISTURBI
% Rumore Sensori (Per il cluster)
Rumore_Sensore = 0.05; % Basso per evitare instabilità del PID

% Potenza Disturbi Interni (Watt)
P_Cucina_Fornelli = 1500;
P_Bagno_Doccia    = 800;
P_Salotto_Persone = 450;
P_Camera_Persone  = 160;
P_Corridoio_Pass  = 100;

disp('--------------------------------------------------');
disp('SETUP CASA SMART COMPLETATO.');
disp(['Durata simulazione: ' num2str(T_giorni) ' giorni (' num2str(T_sim) ' s)']);
disp(['Limite Contatore:   ' num2str(P_Grid_Max) ' W']);
disp('--------------------------------------------------');