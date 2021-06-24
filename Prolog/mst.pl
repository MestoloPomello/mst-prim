%%%% -*- Mode: Prolog -*-

%%%% mst.pl

%%%% Libreria CSV per la lettura/scrittura
:- use_module(library(csv)).

%%%% Predicati dinamici
:- dynamic graph/1.
:- dynamic vertex/2.
:- dynamic arc/4.
:- dynamic heap/2.
:- dynamic heap_entry/4.
:- dynamic vertex_key/3.
:- dynamic vertex_previous/3.

%%%% new_graph/1

new_graph(G) :- graph(G), !.
new_graph(G) :- assert(graph(G)), !.


%%%% delete_graph/1

delete_graph(G) :-
    retractall(vertex(G, _)),
    retractall(arc(G, _, _, _)),
    retractall(vertex_key(G, _, _)),
    retractall(vertex_previous(G, _, _)),
    retract(graph(G)).


%%%% new_vertex/2

new_vertex(G, V) :- vertex(G, V), !.
new_vertex(G, V) :- assert(vertex(G, V)), !.


%%%% graph_vertices/2

graph_vertices(G, Vs) :- findall(V, vertex(G, V), Vs).


%%%% list_vertices/1

list_vertices(G) :- listing(vertex(G, _)).


%%%% new_arc/4

new_arc(G, U, V) :- new_arc(G, U, V, 1), !.
new_arc(_, U, U, _) :- !.
new_arc(G, U, V, W2) :-
    arc(G, U, V, _),
    retract(arc(G, U, V, _)),
    new_arc(G, U, V, W2), !.

new_arc(G, U, V, W2) :-
    arc(G, V, U, _),
    retract(arc(G, V, U, _)),
    new_arc(G, U, V, W2), !.

new_arc(G, U, V, Weight) :-
    Weight >= 0,
    assert(arc(G, U, V, Weight)), !.

%%%% graph_arcs/2

graph_arcs(G, Es) :-
    findall(arc(G, U, V, Weight), arc(G, U, V, Weight), Es).


%%%% vertex_neighbors/3

vertex_neighbors(G, V, Ns) :-
    vertex(G, V),
    findall(arc(G, V, U, Weight), arc(G, U, V, Weight), Xs),
    findall(arc(G, V, U, Weight), arc(G, V, U, Weight), Ys),
    append(Xs, Ys, Ns).


%%%% adjs/3

adjs(G, V, Vs) :-
    vertex(G, V),
    findall(vertex(G, U1), arc(G, U1, V, Weight), Xs),
    findall(vertex(G, U2), arc(G, V, U2, Weight), Ys),
    append(Xs, Ys, Vs).

%%%% list_arcs/1

list_arcs(G) :- graph(G), listing(arc(G, _, _, _)).


%%%% list_graph/1

list_graph(G) :- graph(G), listing(vertex(G, _)), list_arcs(G).


%%%% read_graph/2

read_graph(G, FileName) :-
    csv_read_file(FileName, Righe, [separator(0'\t)]),
    new_graph(G),
    gestione_righe(G, Righe).

gestione_righe(_G, []) :- !.
gestione_righe(G, [X | Xs]) :-
    arg(1, X, U),
    arg(2, X, V),
    arg(3, X, W),
    new_vertex(G, U),
    new_vertex(G, V),
    new_arc(G, U, V, W),
    gestione_righe(G, Xs), !.


%%%% write_graph/2

write_graph(G, FileName) :- write_graph(G, FileName, graph), !.
write_graph(G, FileName, 'graph') :-
    graph_arcs(G, Es),
    estrai_grafo(Es, Fs),
    csv_write_file(FileName, Fs, [separator(0'\t)]), !.
write_graph(G, FileName, 'edges') :-
    estrai_grafo(G, Fs),
    csv_write_file(FileName, Fs, [separator(0'\t)]), !.

estrai_grafo([], []) :- !.
estrai_grafo([X | Xs], [row(U, V, W) | Ys]) :-
    arg(2, X, U),
    arg(3, X, V),
    arg(4, X, W),
    estrai_grafo(Xs, Ys), !.


%%%% new_heap/1

new_heap(H) :- heap(H, _), !.
new_heap(H) :- assert(heap(H, 0)), !.


%%%% delete_heap/1

delete_heap(H) :-
    retractall(heap_entry(H, _, _, _)),
    retract(heap(H, _)).


%%%% heap_has_size/2

heap_has_size(H, S) :- heap(H, S).


%%%% heap_empty/1

heap_empty(H) :- heap(H, 0).


%%%% heap_not_empty/1

heap_not_empty(H) :- heap(H, S), S > 0.


%%%% heap_new_size/3

heap_new_size(H, NS) :-
    heap(H, S),
    retract(heap(H, S)),
    assert(heap(H, NS)).


%%%% heap_head/3

heap_head(H, K, V) :-  heap_entry(H, 1, K, V).


%%%% heap_insert/3

heap_insert(H, K, V) :-
    heap(H, 0),
    heap_new_size(H, 1),
    assert(heap_entry(H, 1, K, V)), !.

heap_insert(H, K, V) :-
    heap(H, S),
    S1 is S + 1,
    P2 is floor(S1 / 2),
    heap_entry(H, P2, K2, _),
    K >= K2,
    heap_new_size(H, S1),
    assert(heap_entry(H, S1, K, V)), !.

heap_insert(H, K, V) :-
    heap(H, S),
    S1 is S + 1,
    heap_new_size(H, S1),
    assert(heap_entry(H, S1, K, V)),
    heapify(H, S1), !.


heapify(_, 1) :- !.
heapify(H, S) :-
    P is floor(S / 2),
    heap_entry(H, S, K, _),
    heap_entry(H, P, K2, _),
    K >= K2, !.

heapify(H, S) :-
    P is floor(S / 2),
    heap_entry(H, S, K, V),
    heap_entry(H, P, K2, V2),
    K < K2,
    retract(heap_entry(H, S, K, V)),
    retract(heap_entry(H, P, K2, V2)),
    assert(heap_entry(H, S, K2, V2)),
    assert(heap_entry(H, P, K, V)),
    heapify(H, P), !.


%%%% heap_extract/3

heap_extract(H, K, V) :-
    heap(H, 1),
    heap_new_size(H, 0),
    retract(heap_entry(H, _, K, V)), !.

heap_extract(H, K, V) :-
    heap(H, S),
    S1 is S - 1,
    heap_new_size(H, S1),
    retract(heap_entry(H, 1, K, V)),
    adjust_pos(H, S),
    heapify_all(H, S1), !.


adjust_pos(_, 0) :- !.
adjust_pos(_, 1) :- !.
adjust_pos(H, S) :-
    S1 is S - 1,
    retract(heap_entry(H, S, K, V)),
    assert(heap_entry(H, S1, K, V)),
    adjust_pos(H, S1), !.


heapify_all(_, 0) :- !.
heapify_all(_, 1) :- !.
heapify_all(H, S) :-
    S1 is S - 1,
    heapify(H, S),
    heapify_all(H, S1), !.


%%%% modify_key/4

modify_key(H, NewKey, OldKey, V) :-
    retract(heap_entry(H, P, OldKey, V)),
    assert(heap_entry(H, P, NewKey, V)),
    heap(H, S),
    heapify_all(H, S).


%%%% list_heap(H)

list_heap(H) :- listing(heap_entry(H, _, _, _)).


%%%% set_vertex_key/3

set_vertex_key(G, V, K) :-
    vertex(G, V),
    vertex_key(G, V, _),
    retract(vertex_key(G, V, _)),
    assert(vertex_key(G, V, K)), !.
set_vertex_key(G, V, K) :-
    vertex(G, V),
    assert(vertex_key(G, V, K)), !.


%%%% set_vertex_previous/3

set_vertex_previous(G, V, U) :-
    retractall(vertex_previous(G, V, _)),
    assert(vertex_previous(G, V, U)), !.
set_vertex_previous(G, V, U) :-
    assert(vertex_previous(G, V, U)), !.


%%%% mst_prim/2

mst_prim(G, Source) :-
    new_heap(G),
    graph_vertices(G, Vs),
    init_vertex_keys(G, Vs),
    set_vertex_key(G, Source, 0),
    heap_insert(G, 0, Source),
    heap(G, S),
    iterate_vertices(G, S, []).


iterate_vertices(_, 0, _) :- !.
iterate_vertices(G, _, Vs) :-
    heap_extract(G, _, V),
    vertex_neighbors(G, V, Ns),
    iterate_neighbors(G, V, Ns, Vs),
    heap_has_size(G, S),
    iterate_vertices(G, S, [V | Vs]), !.


iterate_neighbors(_, _, [], _) :- !.
iterate_neighbors(G, V, [arc(G, V, U, _) | Ns], Vs) :-
    is_vertex_added(U, Vs),
    iterate_neighbors(G, V, Ns, Vs), !.

iterate_neighbors(G, V, [arc(G, V, U, W) | Ns], Vs) :-
    vertex_key(G, U, 'inf'),
    set_vertex_key(G, U, W),
    set_vertex_previous(G, U, V),
    modify_key(G, W, _, U),
    iterate_neighbors(G, V, Ns, Vs), !.

iterate_neighbors(G, V, [arc(G, V, U, W) | Ns], Vs) :-
    vertex_key(G, U, Key),
    W < Key,
    set_vertex_key(G, U, W),
    set_vertex_previous(G, U, V),
    modify_key(G, W, _, U),
    iterate_neighbors(G, V, Ns, Vs), !.

iterate_neighbors(G, V, [_ | Ns], Vs) :-
    iterate_neighbors(G, V, Ns, Vs), !.


init_vertex_keys(_, []) :- !.
init_vertex_keys(G, [V | Vs]) :-
    set_vertex_key(G, V, 'inf'),
    heap_insert(G, 'inf', V),
    init_vertex_keys(G, Vs).

is_vertex_added(V, [V | _]) :- !.
is_vertex_added(U, [_ | Vs]) :-
    is_vertex_added(U, Vs), !.



%%%% mst_get/3

mst_get(G, Source, PreorderTree) :-
    create_tree(G, Source, [], PreorderTree).

create_tree(G, V, Xs, Cs) :-
    vertex_previous(G, _, V),
    findall(vertex_previous(G, U, V), vertex_previous(G, U, V), Ps),
    find_min_weight(G, V, Ps, MinW, MinU),
    retract(vertex_previous(G, MinU, V)),
    append(Xs, [arc(G, V, MinU, MinW)], Es),
    create_tree(G, MinU, Es, As),
    create_tree(G, V, As, Cs), !.

create_tree(_, _, Xs, Xs) :- !.


find_min_weight(G, V, [vertex_previous(G, Next, V) | Ps], MinW, MinU) :-
    vertex_key(G, Next, W),
    find_min_weight(G, V, Ps, W, MinW, Next, MinU), !.

find_min_weight(_, _, [], MinW, MinW, MinU, MinU) :- !.
find_min_weight(G, V, [vertex_previous(G, Next, V) | Ps],
                MinWIn, MinWOut, _, MinUOut) :-
    vertex_key(G, Next, W),
    W < MinWIn,
    find_min_weight(G, V, Ps, W, MinWOut, Next, MinUOut), !.

find_min_weight(G, V, [vertex_previous(G, Next, V) | Ps],
                MinWIn, MinWOut, MinUIn, MinUOut) :-
    vertex_key(G, Next, W),
    W > MinWIn,
    find_min_weight(G, V, Ps, MinWIn, MinWOut, MinUIn, MinUOut), !.

find_min_weight(G, V, [vertex_previous(G, Next, V) | Ps],
                MinWIn, MinWOut, MinUIn, MinUOut) :-
    vertex_key(G, Next, W),
    W = MinWIn,
    Next @< MinUIn,
    find_min_weight(G, V, Ps, MinWIn, MinWOut, Next, MinUOut), !.

find_min_weight(G, V, [vertex_previous(G, Next, V) | Ps],
                MinWIn, MinWOut, MinUIn, MinUOut) :-
    vertex_key(G, Next, W),
    W = MinWIn,
    Next @> MinUIn,
    find_min_weight(G, V, Ps, MinWIn, MinWOut, MinUIn, MinUOut), !.

%%%%  end of file -- mst.pl
