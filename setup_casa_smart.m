% --- setup_casa_smart.m ---
% Script di configurazione per Casa Smart Distribuita (Digital Twin)
% Include: Fisica 2 Masse, Controllo Probabilistico, Meteo, Gestore Carichi
clc;

%% 1. PARAMETRI DI SIMULAZIONE
dt = 0.1;             % Passo di simulazione fisso
T_giorni = 3;         % Numero di giorni da simulare
T_sim = T_giorni * 86400; % Durata totale in secondi

% Nota: T_ext e il Sole vengono caricati da 'fetch_meteo.m'.
% Assicurati di aver eseguito fetch_meteo.m PRIMA di questo script.

%% 2. PARAMETRI FISICI STANZE (Modello 2 Masse: Aria + Muri)
% Capacità Termica (J/K) e Resistenze (K/W)
% R più BASSA = Meno isolamento (il calore esce subito, es. vetro)
% R più ALTA  = Più isolamento (effetto thermos, es. muri spessi)

% SALOTTO (Dispersivo)
% Grande volume d'aria, ma grandi vetrate che disperdono molto.
C_aria_Salotto = 250000;  
C_muri_Salotto = 60000000; 
R_ext_Salotto  = 0.25;    % MOLTO BASSA: Le vetrate fanno uscire il calore rapidamente.

% CUCINA (Standard)
% Finestra media, isolamento standard.
C_aria_Cucina  = 150000;
C_muri_Cucina  = 35000000;
R_ext_Cucina   = 0.40;    % MEDIA: Disperde il giusto.

% CORRIDOIO (Spifferi)
% Zona centrale, porte spesso aperte, meno isolata.
C_aria_Corr    = 100000;
C_muri_Corr    = 25000000;
R_ext_Corr     = 0.15;    % BASSA: Si raffredda facilmente (evita blocco a 19°C).

% BAGNO (Protetto)
% Superficie verso l'esterno piccola (finestrina). Disperde meno Watt totali.
C_aria_Bagno   = 60000;
C_muri_Bagno   = 15000000;
R_ext_Bagno    = 0.60;    % ALTA: Essendo piccolo, "tiene" meglio la temperatura.

% CAMERA (Confortevole)
% Stanza pensata per dormire, ben isolata, tapparella spesso giù.
C_aria_Camera  = 120000;
C_muri_Camera  = 30000000;
R_ext_Camera   = 0.50;    % MEDIO-ALTA: Buona inerzia termica per la notte.

% SCAMBIO TERMICO INTERNO
R_int = 2.0; % Resistenza muri divisori/porte tra stanze
R_ia  = 0.1; % Resistenza scambio rapido Aria <-> Muri interni
%% 3. GESTIONE ENERGETICA (Smart Grid & Consenso)
% Limite massimo del contatore per tutta la casa
P_Grid_Max = 3000; % Watt (3 kW)

% Potenze Massime
P_max = 1200; % Potenza standard (Salotto, Cucina, Camera, Corridoio)
P_max_Cool = -1200;
P_max_Bagno = 400; 

% Fix per errore "P_max_Stanza undefined" (assegno il default)
P_max_Stanza = P_max; 

%% 4. PARAMETRI DI CONTROLLO (Cervello Distribuito)
% Target di Temperatura
T_Comfort = 21; % Quando c'è presenza
% T_Eco rimosso come richiesto (gestito dagli Switch locali in Simulink)
T_Notte   = 15; % Deep Eco

% PID Tuning
Kp = 100; 
Ki = 0.005; 
Kd = 6000;  
N  = 100;   

% Logiche
Deadband = 0.5; 

% Finestra Automatica
Coeff_Finestra = 100;           
Soglia_Apertura_Finestra = 23.5; 
Soglia_Accensione_AC     = 24.5; 

% Optimal Start (Velocità di riscaldamento stimata °C/s)
Velocita_Cucina  = 0.015; 
Velocita_Salotto = 0.007;
Velocita_Bagno   = 0.020; 
Velocita_Camera  = 0.010;
Velocita_Corridoio = 0.010;

% Orari Target (Secondi dalla mezzanotte)
Ora_Target_Giorno = 7 * 3600;  % 07:00
Ora_Target_Sera   = 18 * 3600; % 18:00
Ora_Target_Notte  = 22 * 3600; % 22:00

%% 5. PARAMETRI SENSORI E DISTURBI
Rumore_Sensore = 0.05; 

% Potenza Disturbi Interni (Watt)
P_Cucina_Fornelli = 1500;
P_Bagno_Doccia    = 800;
P_Salotto_Persone = 450;
P_Camera_Persone  = 160;
% MODIFICA QUI: Ridotto il calore generato in corridoio
P_Corridoio_Pass  = 20; % Era 100 -> Ora 20W (Solo passaggio momentaneo)

%% 6. APPORTI SOLARI (Gain per Simulink)
% Gain per convertire W/m^2 (Meteo) in Watt Termici nella stanza
Gain_Sole_Salotto   = 1.0;  
Gain_Sole_Cucina    = 0.6;  
Gain_Sole_Camera    = 0.6;  
Gain_Sole_Bagno     = 0.2;  
Gain_Sole_Corridoio = 0.0;  

%% 7. INIZIALIZZAZIONE (Fix Errori Integrator)
% Se fetch_meteo non è stato lanciato, usa un valore di default
if exist('T_start_real', 'var')
    disp(['Temperatura iniziale presa dal meteo: ' num2str(T_start_real) '°C']);
else
    T_start_real = 20; 
    disp('Attenzione: fetch_meteo non eseguito. Uso T_start = 20°C default.');
end

disp('--------------------------------------------------');
disp('SETUP CASA SMART COMPLETATO.');
disp(['Durata simulazione: ' num2str(T_giorni) ' giorni (' num2str(T_sim) ' s)']);
disp('--------------------------------------------------');