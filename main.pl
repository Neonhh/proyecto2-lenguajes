% Predicado para verificar la configuracion de estados en una lista
configuracion([]).
configuracion([(_, Estado)|Resto]) :-
    configuracion(Resto),
    (Estado = arriba ; Estado = abajo).

% Predicado principal para validar el mapa y las palancas
validarMapa(Mapa, Palancas) :-
    collectPasillos(Mapa, LetrasSinRepetir),
    validarPalancas(LetrasSinRepetir, Palancas).

% Recolecta las letras de los pasillos en el mapa sin duplicados
collectPasillos(pasillo(X, _), [X]).
collectPasillos(junta(SubMapa1, SubMapa2), Letras) :-
    collectPasillos(SubMapa1, Letras1),
    collectPasillos(SubMapa2, Letras2),
    append(Letras1, Letras2, Letras).
collectPasillos(bifurcacion(SubMapa1, SubMapa2), Letras) :-
    collectPasillos(SubMapa1, Letras1),
    collectPasillos(SubMapa2, Letras2),
    append(Letras1, Letras2, Letras).

% Valida que las palancas correspondan exactamente a los pasillos recolectados
validarPalancas([], []).
validarPalancas([X|Letras], [(X, _)|Palancas]) :-
    validarPalancas(Letras, Palancas).

% Seguro o Trampa de los pasillos
esSeguro(regular, arriba).
esSeguro(de_cabeza, abajo).

noEsSeguro(regular, abajo).
noEsSeguro(de_cabeza, arriba).

% Predicado principal para cruzar un mapa de pasillos
cruzar(Mapa, Palancas, seguro) :-
    validarMapa(Mapa, Palancas),
    configuracion(Palancas),
    evaluarMapa(Mapa, Palancas, seguro).

cruzar(Mapa, Palancas, trampa) :-
    validarMapa(Mapa, Palancas),
    configuracion(Palancas),
    % Si no es seguro, debe ser trampa.
    not(cruzar(Mapa, Palancas, seguro)).


% Caso base para evaluar el pasillo en el mapa
evaluarMapa(pasillo(X, Modo), Palancas, seguro) :-
    esSeguro(Modo, Estado),
    member((X, Estado), Palancas).

evaluarMapa(pasillo(X, Modo), Palancas, trampa) :-
    noEsSeguro(Modo, Estado),
    member((X, Estado), Palancas).


% Manejo de juntas
evaluarMapa(junta(SubMapa1, SubMapa2), Palancas, seguro) :-
    % Recolectar todas las configuraciones de palancas para los submapas y eliminar duplicados
    % mini parche: (sin esto genera configuraciones iguales)
    setof(Configuracion, (evaluarMapa(SubMapa1, Palancas, seguro), 
                          evaluarMapa(SubMapa2, Palancas, seguro),
                          Configuracion = (SubMapa1, SubMapa2)), _).


evaluarMapa(junta(_, _), Palancas, trampa) :-
    not(evaluarMapa(junta(_, _), Palancas, seguro)).

% Manejo de bifurcaciones
evaluarMapa(bifurcacion(SubMapa1, SubMapa2), Palancas, seguro) :-
    evaluarMapa(SubMapa1, Palancas, seguro);
    evaluarMapa(SubMapa2, Palancas, seguro).

evaluarMapa(bifurcacion(_, _), Palancas, trampa) :-
    not(evaluarMapa(bifurcacion(_, _), Palancas, seguro)).

% Ambospredicados son siempre falsos:
siempre_seguro(pasillo(_, _)) :- false.
siempre_seguro(junta(_, _)) :- false.

% Una bifurcacion es siempre segura si al menos uno de los submapas es siempre seguro
siempre_seguro(bifurcacion(SubMapa1, SubMapa2)) :-
    ( (SubMapa1 = pasillo(X, Modo1), SubMapa2 = pasillo(X, Modo2), Modo1 \= Modo2);
      evalBifurcacion(SubMapa1, SubMapa2)
    ).

% Evalua las combinaciones de bifurcaciones y juntas
evalBifurcacion(bifurcacion(_, _), bifurcacion(_, _)).
evalBifurcacion(bifurcacion(_, _), junta(_, _)).
evalBifurcacion(junta(_, _), bifurcacion(_, _)).


