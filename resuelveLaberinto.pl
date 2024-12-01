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
cruzar(Mapa, Palancas, Seguro) :- var(Mapa),
    leer(Mapa),
    cruzar(Mapa, Palancas, Seguro).

%% Casos base (pasillos)
cruzar(pasillo(X,regular), Palancas, seguro) :- 
    obtenerPalanca(X, Palancas, Palanca),
    Palanca = (X, Valor),
    Valor = arriba, !.

cruzar(pasillo(X,regular), Palancas, trampa) :-
    not(cruzar(pasillo(X,regular), Palancas, seguro)).

cruzar(pasillo(X, de_cabeza), Palancas, seguro) :-
    obtenerPalanca(X, Palancas, Palanca),
    Palanca = (X, Valor),
    Valor = abajo, !.

cruzar(pasillo(X, de_cabeza), Palancas, trampa) :-
    not(cruzar(pasillo(X, de_cabeza), Palancas, seguro)).

%% Casos con juntas
cruzar(junta(SubMapa1,SubMapa2), Palancas, seguro) :-
    cruzar(SubMapa1, Palancas, seguro),
    cruzar(SubMapa2, Palancas, seguro), !.

cruzar(junta(subMapa1,subMapa2), Palancas, trampa) :-
    not(cruzar(junta(subMapa1,subMapa2), Palancas, seguro)).

%% Casos con bifurcaciones

% Funciones auxiliares
% Obtiene la palanca correspondiente al caracter X
obtenerPalanca(X, [(X, Valor)|_], (X, Valor)) :- !.
obtenerPalanca(X, [_|T], Palanca) :- obtenerPalanca(X, T, Palanca). 
