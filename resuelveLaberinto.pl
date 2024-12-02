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

%% Casos base (pasillos)
cruzar(pasillo(X,Posicion), Palancas, Seguro) :- 
    obtenerValorPalanca(X, Palancas, Valor),
    decidirSeguro(Posicion, Valor, Seguro).

%% Casos con juntas
cruzar(junta(SubMapa1,SubMapa2), Palancas, seguro) :-
    cruzar(SubMapa1, Palancas, seguro),
    cruzar(SubMapa2, Palancas, seguro).

cruzar(junta(SubMapa1,SubMapa2), Palancas, trampa) :-
    (
        cruzar(SubMapa1, Palancas, trampa)
    ;   
        cruzar(SubMapa2, Palancas, trampa)
    ).

%% Casos con bifurcaciones (TODO)

% Funciones auxiliares
%% Obtiene el valor de la palanca correspondiente al caracter X
obtenerValorPalanca(X, [(X, Valor)|_], Valor).
obtenerValorPalanca(X, [_|T], Valor) :- obtenerValorPalanca(X, T, Valor). 

%% Decide si un pasillo es seguro dada la orientacion de su caracter, y el valor de la palanca
decidirSeguro(regular, arriba, seguro).
decidirSeguro(regular, abajo, trampa).
decidirSeguro(de_cabeza, abajo, seguro).
decidirSeguro(de_cabeza, arriba, trampa).