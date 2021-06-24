LP_E1P_2021_MST: Minimum Spanning Tree

Componenti del gruppo:
844936 Riva Riccardo
847015 Provasi Andrea
856224 Nava Stefano

mst.LISP:
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

INTERFACCIA LISP PER LA MANIPOLAZIONE DEI GRAFI

(is-graph <graph-id>) : se l'argomento graph-id è un grafo, la funzione restituisce lo
	stesso argomento, altrimenti restituisce NIL.
 
(new-graph <graph-id>) : la funzione crea un grafo e lo inserisce nella hashtable *graphs*,
	restituendo il nome del grafo (cioè l'argomento graph-id).
	
(delete-graph <graph-id>) : la funzione restituisce sempre NIL. Se graph-id è un grafo
	esistente nella hashtable *graphs*, cancella tutti gli archi e i vertici facenti
	parte del grafo rispettivamente dalle hashtables *arcs* e *vertices*, e poi il grafo
	stesso dalla hashtable *graphs*. Se è già stato eseguito l'algoritmo di Prim, rimuove
	anche le associazioni nelle hashtables *vertex-keys* e *previous* relative a graph-id.
	
(new-vertex <graph-id> <vertex-id>) : se graph-id è un grafo esistente, la funzione inserisce
	il vertice vertex-id come tripla (vertex graph-id vertex-id) all'interno della hashtable 
	*vertices*,	restituendo la suddetta tripla. Altrimenti, restituisce NIL.
	
(is-vertex <vertex-id>) : la funzione verifica che esista l'argomento vertex-id non sia nullo.
	Se lo è, restituisce NIL, altrimenti restituisce True.
	
(graph-vertices <graph-id>) : la funzione restituisce NIL se graph-id non è un grafo esistente.
	Altrimenti restituisce una lista di tutti i vertici associati al grafo graph-id presenti
	all'interno della hashtable *vertices*. Se il grafo esiste ma non possiede vertici, sarà
	restituita una lista vuota.
	
(vertices-number <graph-id>) : la funzione restituisce NIL se graph-id non è un grafo. Se lo è,
	restituisce il numero di vertici appartenenti al grafo graph-id.
	
(new-arc <graph-id> <vertex-id1> <vertex-id2> <&optional weight>) : la funzione restituisce NIL
	se graph-id non è un grafo esistente o se vertex-id1 o vertex-id2 non sono vertici esistenti.
	Altrimenti inserisce la lista (arc graph-id vertex-id1 vertex-id2 weight) all'interno della
	hashtable *arcs*, e restituisce la suddetta lista. Se non viene specificato il parametro 
	opzionale weight, l'arco viene creato di default con peso 1.
	
(graph-arcs <graph-id>) : la funzione restituisce NIL se graph-id non è un grafo esistente,
	altrimenti restituisce una lista di tutti gli archi appartenenti al grafo graph-id.
	
(graph-vertex-neighbors <graph-id> <vertex-id>) : la funzione restituisce NIL se graph-id o
	vertex-id non corrispondono a un grafo e un vertice esistenti, altrimenti restituisce una
	lista di archi che connettono il vertice vertex-id ad un qualsiasi altro vertice.
	
(graph-vertex-adjacent <graph-id> <vertex-id>) : la funzione restituisce NIL se graph-id o
	vertex-id non corrispondono a un grafo e un vertice esistenti, altrimenti restituisce una
	lista di vertici adiacenti e connessi da un arco al vertice vertex-id.
	
(graph-print <graph-id>) : la funzione restituisce NIL se il grafo graph-id non esiste,
	altrimenti stampa a console una lista di vertici ed archi appartenenti a graph-id.
	
-----

LIBRERIA PER LA GESTIONE DEI MINHEAP IN LISP

(new-heap <heap-id> <&optional capacity>) : la funzione crea un nuovo heap con nome heap-id
	e dimensione capacity all'interno della hashtable *heaps*. Il valore restituito sarà la
	quadrupla heap-rep relativa allo heap appena creato. Se l'argomento capacity non viene
	specificato, lo heap sarà creato di default con dimensione 42.
	
(is-heap <heap-id>) : la funzione restituisce NIL se heap-id non corrisponde ad uno heap
	esistente, altrimenti restituisce lo heap-rep stesso.
	
(heap-id <heap-id>) : la funzione restituisce il nome dello heap, se questo esiste.

(heap-size <heap-id>) : la funzione restituisce la dimensione dello heap heap-id, se questo
	esiste. Altrimenti, restituisce NIL.
	
(heap-new-size <heap-id> <new-size>) : la funzione restituisce NIL se lo heap heap-id non
	esiste, altrimenti modifica la dimensione attuale dello heap in new-size, e restituisce
	il valore della nuova dimensione.
	
(heap-actual-heap <heap-id>) : la funzione restituisce NIL se lo heap heap-id non esiste, 
	altrimenti restituisce l'array degli elementi facenti parte dello heap heap-id.
	
(heap-delete <heap-id>) : la funzione restituisce NIL se lo heap heap-id non esiste,
	altrimenti cancella l'intera heap-rep dalla hashtable *heaps*, restituendo True.
	
(heap-empty <heap-id>) : la funzione restituisce True se lo heap heap-id è vuoto (cioè se
	non contiene alcun elemento), altrimenti restituisce NIL.
	
(heap-not-empty <heap-id>) : la funzione restituisce True se lo heap heap-id contiene 
	almeno un elemento, altrimenti restituisce NIL.
	
(heap-head <heap-id>) : la funzione restituisce NIL se lo heap heap-id non esiste o se
	esiste ma è vuoto, altrimenti restituisce la coppia (k v) testa dello heap.
	
(heap-insert <heap-id> <k> <v>) : la funzione inserisce all'interno dello heap heap-id una
	coppia chiave-valore con formato (k v). Dopo l'inserimento, lo heap viene ristrutturato
	per mantenere la sua proprietà. Se lo heap è giunto a capienza massima (cioè se la
	dimensione è uguale alla capienza), l'array dello heap viene esteso e l'elemento aggiunto.
	Viene restituito True.
	
(heapify <heap-id> <i>) : la funzione esegue ricorsivamente il confronto tra la chiave 
	situata in posizione i e il padre (situato in posizione i/2) dell'elemento ad essa 
	relativo. Se la suddetta chiave è minore di quella del padre, i due elementi vengono
	scambiati. Al termine del processo ricorsivo, lo heap sarà stato ristrutturato in 
	modo da mantenere la sua proprietà. Se l'inserimento non era riuscito, la funzione
	restituisce immediatamente NIL, altrimenti al termine dell'heapify ricorsivo
	restituisce True.
	
(heap-extract <heap-id>) : la funzione estrae la coppia (k v) in testa allo heap heap-id,
	restituendola al chiamante e rimuovendola dallo heap, che viene in seguito ristrutturato.
	Se invece lo heap heap-id non esiste, restituisce NIL.
	
(heapify-all <heap-id> <i>) : la funzione richiama la funzione heapify per tutti gli
	elementi dello heap, al fine di mantenere la struttura del MinHeap dopo l'estrazione
	della testa. La funzione restituisce True.
	
(heap-modify-key <heap-id> <new-key> <old-key> <V>) : la funzione restituisce NIL se lo
	heap heap-id non esiste, altrimenti cerca la heap-rep relativa alla coppia (old-key V)
	e ne modifica la chiave in new-key. Dopo l'operazione, lo heap viene ristrutturato e
	viene restituito True.
	
(find-key <heap-id> <new-key> <old-key> <v> <array> <i>) : la funzione scorre ricorsivamente
	gli elementi dell'array dello heap per trovare la coppia (old-key v) nella quale viene 
	sostituita old-key con new-key. Se la coppia viene trovata, la funzione restituirà al
	chiamante la posizione i di essa. Altrimenti, alla fine della ricerca restituirà NIL.
	
(heap-print <heap-id>) : la funzione stampa su console lo heap heap-id, se esiste.

-----

ALGORITMO DI PRIM E SOLUZIONE DEL PROBLEMA MST IN LISP

(mst-vertex-key <graph-id> <vertex-id>) : la funzione restituisce NIL se il grafo graph-id
	od il vertice vertex-id non esistono. Altrimenti restituisce il valore corrispondente
	al peso minimo dell'arco che connette vertex-id in graph-id.
	
(set-vertex-key <graph-id> <vertex-id> <weight>) : la funzione restituisce NIL se il grafo
	graph-id od il vertice vertex-id non esistono. Altrimenti imposta il valore weight come
	peso minimo dell'arco che connette vertex-id in graph-id, nella hashtable *vertex-keys*.
	In questo caso restituisce la coppia (vertex-id weight).
	
(mst-previous <graph-id> <V>) : la funzione restituisce NIL se il grafo graph-id od il
	vertice vertex-id non esistono. Altrimenti restituisce il vertice che precede V
	nell'arco di peso minimo che lo connette in graph-id.
	
(set-vertex-previous <graph-id> <vertex-id> <previous>) : la funzione restituisce NIL se il
	grafo graph-id od il vertice vertex-id non esistono. Altrimenti imposta il valore previous
	come vertice che precede vertex-id nell'arco di peso minimo che lo connette in graph-id.
	
(mst-prim <graph-id> <source>) : la funzione restituisce NIL. Al termine delle iterazioni
	dell'algoritmo di Prim, le hashtables *vertex-keys* e *previous* conterranno i pesi
	minimi ed i vertici che precedono ogni vertice di graph-id. L'argomento source indica
	il vertice di partenza.
	
(init-vertex-keys <graph-id>) : la funzione inizializza le associazioni nella hashtable
	*vertex-keys*  per ogni vertice al valore di default most-positive-double-float
	e inserisce ogni vertice nello heap graph-id con chiave most-positive-double-float.
	
(iterate-vertices <graph-id> <size> <added-list>) : la funzione itera ricorsivamente
	sulla lista di vertici appartenenti al grafo graph-id e, per ognuno, richiama la 
	funzione iterate-neighbors che itera sulla lista di archi che partono dal vertice
	in questione. L'argomento added-list è la lista dei vertici già presi in considerazione
	dall'algoritmo, e serve per evitare di prendere in considerazione due volte lo stesso
	arco per i vertici da esso collegati. La funzione restituisce NIL.
	
(iterate-neighbors <graph-id> <vertex-id> <neighbors-list> <added-list>) : la funzione
	itera ricorsivamente sulla lista neighbors-list di archi connessi al vertice vertex-id,
	evitando quelli che portano ai vertici contenuti in added-list, ovvero già considerati
	dall'algoritmo di Prim. Durante le sue iterazioni, le associazioni in *vertex-keys*
	e *previous* saranno più volte modificate, e al termine si avrà in esse la soluzione
	al problema MST. La funzione restituisce la lista di vertici già aggiunti.
	
(mst-get <graph-id> <source>) : la funzione genera e restituisce il Preorder Tree che
	rappresenta la soluzione al problema MST, ottenuta mediante l'algoritmo di Prim.
	L'argomento source è il vertice di partenza per l'algoritmo di Prim. Se graph-id 
	non è un grafo e source non è un vertice valido, restituisce NIL.
	
(create-tree <graph-id> <vertex-id> <preorder-mst>) : la funzione itera ricorsivamente
	per aggiungere al preorder-mst l'arco di peso minimo che connette vertex-id nel 
	grafo graph-id. Contiene due chiamate a sè stessa per far sì che vengano considerati
	entrambi i vertici dell'arco. Restituisce il preorder-mst risultato delle chiamate
	ricorsive.
	
(create-previous-list <graph-id> <vertex-id>) : la funzione scorre la hashtable	*previous*
	per generare e restituire una lista di vertici che hanno come previous il vertice 
	vertex-id. Se non ce ne sono, viene restituita una lista vuota.
	
(find-min-weight-arc <previous-list>) : la funzione chiama la funzione
	iterate-previous-list, ricevendo l'arco di peso minimo presente nella lista argomento
	previous-list. L'associazione tra i vertici di questo arco viene quindi rimossa dalla
	hashtable *previous* e l'arco in questione restituito al chiamante.
	
(iterate-previous-list <previous-list> <min> <min-arc> <i>) : la funzione itera ricorsivamente
	sulla lista previous-list per trovare l'arco min-arc con peso minimo min. Se il confronto
	viene effettuato tra due archi di pari peso, l'arco minimo sarà scelto in base all'ordine
	lessicografico dei vertici di arrivo. La funzione restituisce l'arco minimo min-arc.
 	
	