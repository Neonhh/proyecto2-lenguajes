% Pide al usuario una ruta de un archivo con la estructura de un laberinto, unificandolo en Mapa.
leer(Mapa) :- 
    write('Ingrese la ruta del archivo: '),
    nl,
    read(Ruta),  % Abre el archivo en la ruta y crea un Stream asociado
    
    % Atrapamos posibles errores en el contenido del archivo del Mapa
    catch(
        (
            open(Ruta, read, Stream),
            read(Stream, Mapa),
            close(Stream)
        ),
            error(syntax_error(_), _),
        (
            write('Error de sintaxis, asegurese de que el contenido del archivo termine en ".".'),
            nl, fail
        )
        ).


% Determina las configuraciones de palancas en el laberinto que generan un cruce de estado Seguro. 

cruzar(Mapa, Palancas, Seguro) :- 
    generarPalancas(Mapa, PalancasValidas),
    cruzar(PalancasValidas, Mapa, Palancas, Seguro).

%% Casos base (pasillos)
cruzar(PalancasValidas, pasillo(X,Posicion), Palancas, Seguro) :- 
    Palancas = PalancasValidas,
    obtenerValorPalanca(X, Palancas, Valor),
    decidirSeguro(Posicion, Valor, Seguro), !.

%% Casos con juntas
cruzar(PalancasValidas, junta(SubMapa1,SubMapa2), Palancas, seguro) :-
    (var(Palancas); Palancas = PalancasValidas),
    cruzar(PalancasValidas, SubMapa1, Palancas, seguro),
    cruzar(PalancasValidas, SubMapa2, Palancas, seguro), !.

cruzar(PalancasValidas, junta(SubMapa1,SubMapa2), Palancas, trampa) :-
    (var(Palancas); Palancas = PalancasValidas),
    (
        cruzar(PalancasValidas, SubMapa1, Palancas, trampa), !
    ;   
        cruzar(PalancasValidas, SubMapa2, Palancas, trampa), !
    ).

%% Casos con bifurcaciones (DM)
cruzar(PalancasValidas, bifurcacion(SubMapa1,SubMapa2), Palancas, seguro) :-
    (var(Palancas); Palancas = PalancasValidas),
    (
        cruzar(PalancasValidas, SubMapa1,Palancas, seguro), !
    ;
        cruzar(PalancasValidas, SubMapa2, Palancas, seguro), !
    ).

cruzar(PalancasValidas, bifurcacion(SubMapa1,SubMapa2), Palancas, trampa) :-
    (var(Palancas); Palancas = PalancasValidas),
    cruzar(PalancasValidas, SubMapa1, Palancas, trampa),
    cruzar(PalancasValidas, SubMapa2, Palancas, trampa), !.

% Funciones auxiliares
%% Obtiene el valor de la palanca correspondiente al caracter X
obtenerValorPalanca(X, [(X, Valor)|_], Valor) :- !.
obtenerValorPalanca(X, [_|T], Valor) :- obtenerValorPalanca(X, T, Valor). 

%% Decide si un pasillo es seguro dada la orientacion de su caracter, y el valor de la palanca
decidirSeguro(regular, arriba, seguro).
decidirSeguro(regular, abajo, trampa).
decidirSeguro(de_cabeza, abajo, seguro).
decidirSeguro(de_cabeza, arriba, trampa).

%% Genera las combinaciones posibles de palancas y valores a partir del Mapa
% Genera todas las combinaciones posibles de palancas para un mapa
generarPalancas(Mapa, Palancas) :-
    mapaPalancas(Mapa, Letras),
    generarCombinaciones(Letras, Palancas).

% Obtiene todas las letras de los pasillos de un mapa
mapaPalancas(pasillo(X, _), [X]).
mapaPalancas(junta(SubMapa1, SubMapa2), Letras) :-
    mapaPalancas(SubMapa1, Letras1),
    mapaPalancas(SubMapa2, Letras2),
    append(Letras1, Letras2, Letras).
mapaPalancas(bifurcacion(SubMapa1, SubMapa2), Letras) :-
    mapaPalancas(junta(SubMapa1, SubMapa2), Letras).

% Genera todas las combinaciones posibles de palancas para un conjunto de letras
generarCombinaciones([], []).
generarCombinaciones([X|T], [(X, arriba)|Rest]) :-
    generarCombinaciones(T, Rest).
generarCombinaciones([X|T], [(X, abajo)|Rest]) :-
    generarCombinaciones(T, Rest).