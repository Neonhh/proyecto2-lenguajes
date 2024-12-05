%%% DONT TOUCH
% Verifica si las palancas son válidas (sin contradicciones)
esValidaPalanca([]).
esValidaPalanca([(X, Pos1)|T]) :-
    \+ (member((X, Pos2), T), Pos1 \= Pos2),
    esValidaPalanca(T).

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
    mapaPalancas(SubMapa1, Letras1),
    mapaPalancas(SubMapa2, Letras2),
    append(Letras1, Letras2, Letras).

% Genera todas las combinaciones posibles de palancas para un conjunto de letras
generarCombinaciones([], []).
generarCombinaciones([X|T], [(X, arriba)|Rest]) :-
    generarCombinaciones(T, Rest).
generarCombinaciones([X|T], [(X, abajo)|Rest]) :-
    generarCombinaciones(T, Rest).

% Caso base: Pasillo seguro
cruzar(pasillo(X, regular), Palancas, seguro) :-
    member((X, arriba), Palancas).
cruzar(pasillo(X, de_cabeza), Palancas, seguro) :-
    member((X, abajo), Palancas).

% Caso base: Pasillo trampa
cruzar(pasillo(X, regular), Palancas, trampa) :-
    \+ member((X, arriba), Palancas).
cruzar(pasillo(X, de_cabeza), Palancas, trampa) :-
    \+ member((X, abajo), Palancas).

% Caso recursivo: Junta segura
cruzar(junta(SubMapa1, SubMapa2), Palancas, seguro) :-
    generarPalancas(junta(SubMapa1, SubMapa2), Palancas),
    esValidaPalanca(Palancas),
    cruzar(SubMapa1, Palancas, seguro),
    cruzar(SubMapa2, Palancas, seguro).

% Caso recursivo: Junta trampa
cruzar(junta(SubMapa1, SubMapa2), Palancas, trampa) :-
    generarPalancas(junta(SubMapa1, SubMapa2), Palancas),
    esValidaPalanca(Palancas),
    (cruzar(SubMapa1, Palancas, trampa); cruzar(SubMapa2, Palancas, trampa)).

% Caso recursivo: Bifurcación segura
cruzar(bifurcacion(SubMapa1, SubMapa2), Palancas, seguro) :-
    generarPalancas(bifurcacion(SubMapa1, SubMapa2), Palancas),
    esValidaPalanca(Palancas),
    (cruzar(SubMapa1, Palancas, seguro); cruzar(SubMapa2, Palancas, seguro)).

% Caso recursivo: Bifurcación trampa
cruzar(bifurcacion(SubMapa1, SubMapa2), Palancas, trampa) :-
    generarPalancas(bifurcacion(SubMapa1, SubMapa2), Palancas),
    esValidaPalanca(Palancas),
    cruzar(SubMapa1, Palancas, trampa),
    cruzar(SubMapa2, Palancas, trampa).
