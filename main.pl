% Pide al usuario una ruta de un archivo con la estructura de un laberinto, unificandolo en Mapa.
leer(Mapa) :-
    write('Ingrese la ruta del archivo: '),
    read_line_to_string(user_input, NombreArchivo), % Lee la ruta del archivo como string
    catch(
        (
            open(NombreArchivo, read, Stream), % Abre el archivo para lectura
            read_stream_to_codes(Stream, Codes), % Lee el contenido del archivo como códigos ASCII
            close(Stream), % Cierra el archivo
            string_codes(Str, Codes), % Convierte los códigos ASCII a string
            term_string(Mapa, Str) % Convierte el string en un término Prolog y lo unifica con Mapa
        ),
        error(syntax_error(_), _), % Manejo de errores de sintaxis
        (
            write('Error de sintaxis: asegúrese de que el contenido termine con un punto "."'), 
            nl, fail
        )
    ).


% Determina las configuraciones de palancas en el laberinto que generan un cruce de estado Seguro. 

cruzar(Mapa, Palancas, Seguro) :- 
        % Se generan las combinaciones de palancas validas para forzar a que Palancas se unifique
        % con listas donde aparezca la posicion de palanca para cada letra
        generarPalancas(Mapa, PalancasValidas),
        cruzar_casos(PalancasValidas, Mapa, Palancas, Seguro).
                                                % Se intento evitar que cruzar /3 imprimiera false al terminar de unificar palancas.
                                                % No funciona usar !, ya que puede esperarse mas de una respuesta.
                                                % No funciona usar asserta, a menos que se pueda evitar que Palancas
                                                % se unifique arbitrariamente con cualquier elemento que califique.
                                                % Con findall /3 se podria obtener una lista de todas las combinaciones validas,
                                                % pero las implementaciones hechas por nosotros no lograron resolver el problema.

%% Casos base (pasillos)
cruzar_casos(PalancasValidas, pasillo(X,Posicion), Palancas, Seguro) :- 
    Palancas = PalancasValidas,
    obtenerValorPalanca(X, Palancas, Valor),
    decidirSeguro(Posicion, Valor, Seguro), !.

%% Casos con juntas
cruzar_casos(PalancasValidas, junta(SubMapa1,SubMapa2), Palancas, seguro) :-
    (var(Palancas); Palancas = PalancasValidas),
    cruzar_casos(PalancasValidas, SubMapa1, Palancas, seguro),
    cruzar_casos(PalancasValidas, SubMapa2, Palancas, seguro), !.

cruzar_casos(PalancasValidas, junta(SubMapa1,SubMapa2), Palancas, trampa) :-
    (var(Palancas); Palancas = PalancasValidas),
    (
        cruzar_casos(PalancasValidas, SubMapa1, Palancas, trampa), !
    ;   
        cruzar_casos(PalancasValidas, SubMapa2, Palancas, trampa), !
    ).

%% Casos con bifurcaciones (DM)
cruzar_casos(PalancasValidas, bifurcacion(SubMapa1,SubMapa2), Palancas, seguro) :-
    (var(Palancas); Palancas = PalancasValidas),
    (
        cruzar_casos(PalancasValidas, SubMapa1,Palancas, seguro), !
    ;
        cruzar_casos(PalancasValidas, SubMapa2, Palancas, seguro), !
    ).

cruzar_casos(PalancasValidas, bifurcacion(SubMapa1,SubMapa2), Palancas, trampa) :-
    (var(Palancas); Palancas = PalancasValidas),
    cruzar_casos(PalancasValidas, SubMapa1, Palancas, trampa),
    cruzar_casos(PalancasValidas, SubMapa2, Palancas, trampa), !.

% Funciones auxiliares - cruzar
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
    union(Letras1, Letras2, Letras).
mapaPalancas(bifurcacion(SubMapa1, SubMapa2), Letras) :-
    mapaPalancas(junta(SubMapa1, SubMapa2), Letras).

% Genera todas las combinaciones posibles de palancas para un conjunto de letras
generarCombinaciones([], []).
generarCombinaciones([X|T], [(X, arriba)|Rest]) :-
    generarCombinaciones(T, Rest).
generarCombinaciones([X|T], [(X, abajo)|Rest]) :-
    generarCombinaciones(T, Rest).

%% siempre_seguro %%
siempre_seguro(Mapa) :- not(cruzar(Mapa,_,trampa)).
