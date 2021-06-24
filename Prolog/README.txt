LP_E1P_2021_MST: Minimum Spanning Tree

Componenti del gruppo:
844936 Riva Riccardo
847015 Provasi Andrea
856224 Nava Stefano


mst.pl:
Lo scopo del programma è di implementare l'algoritmo di Prim per generare il
Minimum Spanning Tree, cioè l'albero che definisce il cammino minimo per
connettere tutti i vertici di un grafo non diretto a pesi non negativi.
Il programma è composto da tre parti principali:
- l'interfaccia per la manipolazione dei grafi, che ne permette la creazione,
la cancellazione, l'inserimento e modifica di vertici e archi (anche da file);
- la libreria per la gestione dei MinHeap, che ne permette la creazione,
cancellazione ed inserimento, modifica ed estrazione di una coppia chiave-valore,
il tutto mantenendo le proprietà del MinHeap binario (dove i due figli di un elemento
sono di valore maggiore dell'elemento stesso);
- l'algoritmo di Prim e la generazione del Preorder Tree dove, facendo uso delle due
interfacce sopra definite, verrà esaminato l'intero grafo e generata la soluzione del
problema MST.

-----

INTERFACCIA PROLOG PER LA MANIPOLAZIONE DEI GRAFI

new_graph(+G) : Il predicato è sempre vero. Se l'argomento G non è un grafo	viene
	inserito all'interno della base dati Prolog.
	
delete_graph(+G) : Il predicato è vero se l'argomento G è un grafo. Come effetto
	collaterale vengono rimossi dalla base dati Prolog tutti i vertici e gli archi
	relativi al grafo G, e successivamente viene rimosso anche lo stesso grafo G.
	Se è già stato eseguito l'algoritmo di Prim, rimuove anche le associazioni
	vertex_key/3 e vertex_previous/3 relative al grafo G.
	
new_vertex(+G, +V) : Il predicato è sempre vero. Se l'argomento V non è un vertice
	relativo al grafo G, come effetto collaterale viene inserito il vertice G, V
	all'interno della base dati Prolog.
	
graph_vertices(+G, -Vs) : Il predicato è vero quando Vs è una lista contenente tutti
	i vertici del grafo G.
	
list_vertices(+G) : Il predicato stampa sulla console una lista contenente tutti i
		vertici del grafo G.
		
new_arc(+G, +U, +V, +W) : Il predicato è vero quando il peso W è maggiore o uguale
	a zero. Come effetto collaterale aggiunge alla base dati Prolog l'arco che
	connette i vertici U e V, appartenenti al grafo G, di peso W. Se un arco che
	connette questi vertici è già presente ma di peso diverso, questo viene sostituito
	con l'ultimo inserito.
	
new_arc(+G, +U, +V) : Il predicato richiama new_arc/4 impostando di default il peso W
	al valore 1.
	
graph_arcs(+G, -Es) : Il predicato è vero quando Es è una lista contenente tutti gli
	archi del grafo G.
	
vertex_neighbors(+G, +V, -Ns) : Il predicato è vero quando V è un vertice del grafo G
		e Ns è una lista contenente tutti gli altri che portano al vertice N immediatamente
		raggiungibili da V.

adjs(+G, +V, -Vs) : Il predicato è vero quando V è un vertice del grafo G e Vs è una
	lista contenente i vertici ad esso adiacenti.
	
unione(+Xs, +Ys, -Es) : Il predicato è vero quando la lista Es è la concatenazione delle
	liste Xs e Ys, esclusi eventuali elementi duplicati.
	
list_arcs(+G) : Il predicato è vero quando G è un grafo. Come effetto collaterale stampa
	sulla console dell'interprete Prolog una lista degli archi del grafo G.
	
list_graph(+G) : Il predicato è vero quando G è un grafo. Come effetto collaterale stampa
	sulla console dell'interprete Prolog una lista dei vertici e degli archi del grafo G.
	
read_graph(+G, +FileName) : Il predicato legge un grafo G dal file csv situato al percorso
	FileName e lo inserisce nel database Prolog. Nel file, ogni riga deve contenere 3
	elementi separati da un carattere di tabulazione.
	
gestione_righe(+G, +Xs) : Il predicato esamina tutti gli archi della lista Xs, inserendo
	vertici, arco, e peso di ogni arco nella base dati Prolog.
	
write_graph(+G, +FileName, +Type) : Il predicato scrive nel file csv situato al percorso 
	FileName la lista di archi relativa al grafo. L'argomento G può essere di due diversi
	tipi, e la sua interpretazione dipende dal valore dell'argomento Type ('graph' o 'edges'):
	se Type è 'graph', allora G è un termine che identifica un grafo nella base dati Prolog
	e nel file saranno scritti gli archi del suddetto grafo, letti dalla base dati.
	se Type è 'edges', allora G è una lista di archi, che viene direttamente scritta nel file.
	
estrai_grafo(+Xs, -Ys) : Il predicato legge ricorsivamente gli archi dalla lista Xs, inserendoli
	nella lista Ys nel formato adatto alla scrittura su file (ovvero tralasciando il termine che
	identifica il grafo, presente invece nel formato 'arc' della base dati Prolog).
	
-----

LIBRERIA PER LA GESTIONE DEI MINHEAP IN PROLOG

new_heap(+H) : Il predicato è sempre vero. Come effetto collaterale l'heap H viene inserito
	all'interno della base dati Prolog (se non è già presente).
	
delete_heap(+H) : Il predicato è vero quando H è uno heap. Come effetto collaterale, rimuove
	lo heap H e le relative entries dalla base dati Prolog.

heap_has_size(+H, -S) : Il predicato è vero quando S è la dimensione corrente dello heap H.

heap_empty(+H) : Il predicato è vero quando lo heap H non contiene elementi.

heap_not_empty(+H) : Il predicato è vero quando lo heap H contiene almeno un elemento.

heap_new_size(+H, +NS) : Il predicato è vero quando H è uno heap. Come effetto collaterale,
	imposta il valore NS come nuova dimensione dello heap H.
	
heap_head(+H, -K, -V) : Il predicato è vero quando l'elemento dello heap H con chiave minima
	K è V.
	
heap_insert(+H, +K, +V) : Il predicato è vero quando H è uno heap. Come effetto collaterale
	inserisce l'elemento con chiave K e valore V nello heap H. Dopo l'inserimento, lo heap
	viene ristrutturato per mantenere la sua proprietà.
	
heapify(+H, +S) : Il predicato esegue ricorsivamente il confronto tra la chiave situata in
	posizione S e il padre (situato in posizione S/2) dell'elemento ad essa relativo. Se
	la suddetta chiave è minore di quella del padre, i due elementi vengono scambiati. Al
	termine del processo ricorsivo, lo heap sarà stato ristrutturato in modo da mantenere
	la sua proprietà.
	
heap_extract(+H, -K, -V) : Il predicato è vero quando K e V sono rispettivamente chiave e
	valore della testa dello heap H. Come effetto collaterale, la testa viene estratta
	dallo heap H, che sarà ristrutturato per mantenere la sua proprietà.
	
adjust_pos(+H, +S) : Il predicato decrementa il valore relativo alla posizione di ciascuna
	entry dopo la testa, in modo da mantenere una numerazione corretta anche dopo la rimozione
	della testa dello heap H.
	
heapify_all(+H, +S) : Dopo la rimozione della testa dello heap, viene richiamata la funzione
	heapify/2 per ogni elemento dello heap H in modo che venga mantenuta la sua proprietà.
	
modify_key(+H, +NewKey, +OldKey, +V) : Il predicato è vero quando la chiave OldKey (associata
	al valore V) è sostituita da NewKey. Dopo la modifica, lo heap H viene ristrutturato per
	mantenere la sua proprietà.
	
list_heap(+H) : Il predicato stampa sulla console dell'interprete Prolog lo stato interno
	dell'heap H (cioè tutte le entry ad esso relative).
	
-----

ALGORITMO DI PRIM E SOLUZIONE DEL PROBLEMA MST IN PROLOG

set_vertex_key(+G, +V, +K) : Il predicato è vero quando V è un vertice del grafo G. Come
	effetto collaterale, aggiunge alla base dati Prolog il predicato vertex_key(G, V, K)
	che contiene il peso minimo K dell'arco che connette V nel grafo G. Se esiste già un
	predicato per il vertice V, esso viene sostituito con l'ultimo inserito.
	
set_vertex_previous(+G, +V, +U) : Il predicato è vero quando V è un vertice del grafo G.
	Come effetto collaterale, aggiunge alla base dati Prolog il predicato vertex_previous(G, V, U)
	che contiene il vertice U dell'arco di peso minimo che connette V nel grafo G. Se
	esiste già un predicato per il vertice V, esso viene sostituito con l'ultimo.
	
mst_prim(+G, +Source) : Il predicato è vero quando G è un grafo. Come effetto collaterale,
	al suo termine la base dati Prolog ha al suo interno i predicati vertex_key/3 e
	vertex_previous/3 per ogni vertice V appartenente a G, rappresentanti la soluzione
	al problema MST. L'argomento Source indica il vertice di partenza per le iterazioni
	dell'algoritmo di Prim. 
	
init_vertex_keys(+G, +Vs) : Il predicato scorre ricorsivamente la lista Vs contenente
	i vertici del grafo G, inserendo nella base dati Prolog i predicati vertex_key/3
	per ogni vertice, e inserendo nello heap G le entry con chiave 'inf'.
	
iterate_vertices(+G, +S) : Il predicato estrae un vertice alla volta dallo heap G (finché
	esso non si svuota) e invoca il predicato vertex_neighbors/3 per avere la lista degli
	archi adiacenti al vertice in analisi. Dopodiché invoca, per ogni vertice, il predicato
	iterate_neighbors/3 per eseguire i confronti e le sostituzioni dell'algoritmo di Prim.
	
iterate_neighbors(+G, +V, +Ns) : Il predicato esamina ogni arco della lista Ns contenente
	gli archi adiacenti al vertice V del grafo G. Durante le iterazioni, se il peso dell'arco
	in questione è inferiore a quello memorizzato nel predicato vertex_key/3 relativo al vertice
	connesso al vertice V, viene eseguita la sostituzione di vertex_key/3, vertex_previous/3 e
	viene modificata la entry dello heap G relativa al suddetto vertice con i nuovi valori. 
	
is_vertex_added(+V, +Vs) : Il predicato scorre la lista Vs per verificare se il vertice V
	è già stato valutato durante le iterazioni dell'algoritmo di Prim. Se lo trova, il 
	predicato è vero. Altrimenti, finita la lista, restituirà false.
	
mst_get(+G, +Source, -PreorderTree) : Il predicato è vero quando l'argomento PreorderTree
	è la lista di archi (ordinati per peso, e per peso uguale in ordine lessicografico) che
	definiscono il cammino minimo per visitare tutti i vertici del grafo G. L'argomento Source
	è il vertice di partenza per la creazione del PreorderTree.
	
create_tree(+G, +V, +Xs, -Cs) : Il predicato scorre ogni predicato vertex_previous/3 (fino al
	loro esaurimento) inserendo nella lista Cs la concatenazione della lista Xs (argomento in
	input) e delle due liste derivanti dalle chiamate ricorsive per i vertici indicati nel
	predicato previous in questione. Al termine di tutte le chiamate, la lista Cs conterrà
	tutti gli archi facenti parte della soluzione al problema MST ordinati correttamente.
	
find_min_weight(+G, +V, +Ps, -MinW, -MinU) : Il predicato si occupa di trovare l'arco di peso
	minimo tra quelli identificati da vertex_key/3 e vertex_previous/3 relativi ad un vertice.
	Questa operazione serve a ordinare gli archi per peso crescente. Se si hanno due archi con
	medesimo peso, il vertice MinU e il peso MinW restituiti saranno quelli dell'arco in cui il
	vertice di destinazione precede, in ordine lessicografico, quello dell'arco minimo memorizzato
	finora. Alla fine delle iterazioni, verranno restituiti il vertice MinU e il peso MinW del 
	vertice connesso scelto in base alle suddette caratteristiche.
	

	






