#### Universidad Simón Bolívar
#### Departamento de Computación y Tecnología de la Información
#### CI-3661 – Laboratorio de Lenguajes de Programación
#### Septiembre–Diciembre 2024
# Proyecto II: La Leyenda de Celda

### Estudiantes:
#### Sergio Carrillo - Carnet: 14-11315
#### Jesús Cuéllar - Carnet: 15-10345
#### Néstor Herrera - Carnet: 18-10796

## Descripción del Proyecto

En el script `main.pl` se encuentran los predicados y reglas de Prolog para `cruzar /3`, `siempre_seguro /1` y `leer /1`, segun lo solicitado en el proyecto. 

Para su ejecucion utilizando SWI-Prolog, primero ingresar al interpretador usando `swipl` en el terminal. Una vez en el interpretador, cargar los modulos usando `[main].`

En las pruebas realizadas se observo correctitud en los resultados al llamar `cruzar /3` instanciando los argumentos necesarios en la linea de comandos, asi como las llamadas a `siempre_seguro /1`. Las llamadas a `leer(Mapa)` correctamente unifican el contenido de un archivo con sintaxis correcta dentro de la variable `Mapa`

Algunas veces se podra observar en las llamadas de `cruzar /3` un false al final. Esto es debido a que se evaluan todas las combinaciones de estados posibles para las Palancas para unificar aquellas que son seguras (o trampas). Esto puede llevar a que se devuelva false cuando la ultima combinacion de palancas no se puede unificar. Podria corregirse por ejemplo con el uso de `findall /3`, para almacenar de antemano las combinaciones posibles, pero los resultados unificados antes de dar false son correctos y contienen explicitamente el valor de cada letra en el laberinto.

### Lectura de archivos de mapa

Para este fin, se puede utilizar el predicado `leer /1`. Por ejemplo, leer(Mapa) pedirá una ruta de archivo al usuario, usando la sintaxis característica de Prolog, que puede ser por ejemplo `mapa_1.` (sin olvidar el punto al final), luego de lo cual se asignará a la variable `Mapa` según el contenido del archivo mapa_1 (en este caso en el mismo repositorio que el script).

### Uso de `leer` junto con el resto de predicados

Para poder usar reglas como `cruzar /3`, tomando `Mapa` como el contenido de un archivo `mapa_1`, dentro del interprete swipl invocar `leer(Mapa), cruzar(Mapa, Palancas, Seguro)` donde `Palancas` o `Seguro` pueden estar instanciados o no.

### Ejemplos de uso

#### Predicado leer
Para contenido de mapa_1
```
junta(pasillo(a, regular),bifurcacion(pasillo(b, regular),pasillo(c, de_cabeza))).
```
En el cual imprime:

```
?- leer(Mapa).
Ingrese la ruta del archivo: mapa_1
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))).

```
Para contenido de mapa_2:
```
junta(pasillo(b, regular),pasillo(c, de_cabeza)).
```
En el cual imprime:
```
?- leer(Mapa).
Ingrese la ruta del archivo: mapa_2
Mapa = junta(pasillo(b, regular), pasillo(c, de_cabeza)).

```

Para contenido de mapa_3:
```
pasillo(b,regular).
```
En el cual imprime:
```
?- leer(Mapa).
Ingrese la ruta del archivo: mapa_3
Mapa = pasillo(b, regular).

```

Para ``` leer(Mapa), cruzar(Mapa, Palancas, Seguro) ``` con ```mapa_1 ```:
```
?- leer(Mapa), cruzar(Mapa, Palancas, Seguro).
Ingrese la ruta del archivo: mapa_1
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, arriba), (b, arriba), (c, arriba)],
Seguro = seguro ;
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, arriba), (b, arriba), (c, abajo)],
Seguro = seguro ;
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, arriba), (b, abajo), (c, arriba)],
Seguro = trampa ;
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, arriba), (b, abajo), (c, abajo)],
Seguro = seguro ;
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, abajo), (b, arriba), (c, arriba)],
Seguro = trampa ;
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, abajo), (b, arriba), (c, abajo)],
Seguro = trampa ;
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, abajo), (b, abajo), (c, arriba)],
Seguro = trampa ;
Mapa = junta(pasillo(a, regular), bifurcacion(pasillo(b, regular), pasillo(c, de_cabeza))),
Palancas = [(a, abajo), (b, abajo), (c, abajo)],
Seguro = trampa.
``` 