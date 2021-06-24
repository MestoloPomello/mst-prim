;;;; -*- Mode: Lisp -*-

;;; Hash tables
(defparameter *vertices* (make-hash-table :test #'equal))
(defparameter *arcs* (make-hash-table :test #'equal))
(defparameter *graphs* (make-hash-table :test #'equal))
(defparameter *visited* (make-hash-table :test #'equal))
(defparameter *heaps* (make-hash-table :test #'equal))
(defparameter *vertex-keys* (make-hash-table :test #'equal))
(defparameter *previous* (make-hash-table :test #'equal))

;;; is-graph
(defun is-graph (graph-id)
  (gethash graph-id *graphs*))

;;; new-graph
(defun new-graph (graph-id)
  (or (gethash graph-id *graphs*)
      (setf (gethash graph-id *graphs*) graph-id)))

;;; delete-graph
(defun delete-graph (graph-id)
  (if (is-graph graph-id)
      (if (or
           (maphash #'
                    (lambda (key val)
                      (if (equal (second val) graph-id)
                          (remhash key *arcs*)))
                    *arcs*)
           (maphash #'
                    (lambda (key val)
                      (if (equal (second key) graph-id)
                          (remhash val *vertices*)))
                    *vertices*)
           (maphash #'
                    (lambda (key val)
                      (if (equal (first key) graph-id)
                          (remhash key *vertex-keys*)))
                    *vertex-keys*)
           (maphash #'
                    (lambda (key val)
                      (if (equal (first key) graph-id)
                          (remhash key *previous*)))
                    *previous*)
           (remhash graph-id *graphs*))
          NIL
        NIL)
    NIL))


;;; new-vertex
(defun new-vertex (graph-id vertex-id)
  (if (is-graph graph-id)
      (setf (gethash (list 'vertex graph-id vertex-id)
                     *vertices*)
            (list 'vertex graph-id vertex-id))))

;;; is-vertex
(defun is-vertex (vertex-id)
  (if (null vertex-id) NIL T))

;;; graph-vertices
(defun graph-vertices (graph-id)
  (if (is-graph graph-id)
      (let ((vertex-rep-list ()))
        (maphash #'
                 (lambda (key val)
                   (and
                    (equal (second key) graph-id)
                    (push val vertex-rep-list)))
                 *vertices*) 
        vertex-rep-list)
    NIL))

;;; vertices-number
(defun vertices-number (graph-id)
  (if (is-graph graph-id)
      (list-length (graph-vertices graph-id))
    NIL))

;;; new-arc
(defun new-arc (graph-id vertex-id1 vertex-id2 &optional (weight 1)) 
  (if (or (null vertex-id1)
          (null vertex-id2))
      NIL 
  (if (and (is-graph graph-id)
           (>= weight 0))
      (if (and (atom vertex-id1)
               (atom vertex-id2))
          (if (string< vertex-id1 vertex-id2)
              (setf (gethash (list 'arc graph-id vertex-id1
                                   vertex-id2) *arcs*) 
                    (list 'arc graph-id vertex-id1 vertex-id2 weight)) 
            (setf (gethash (list 'arc graph-id vertex-id2 vertex-id1)
                           *arcs*) 
                  (list 'arc graph-id vertex-id2 vertex-id1 weight))) 
    NIL) NIL)))

;;; graph-arcs
(defun graph-arcs (graph-id)
  (if (is-graph graph-id)
      (let ((arc-rep-list ()))
        (maphash #'
                 (lambda (key val)
                   (and
                    (equal (second key) graph-id)
                    (push val arc-rep-list)))
                 *arcs*) arc-rep-list)
    NIL))

;;; graph-vertex-neighbors
(defun graph-vertex-neighbors (graph-id vertex-id)
  (if (is-graph graph-id)
      (if (is-vertex vertex-id)
          (let ((arc-rep-list ()))
            (maphash #'
                    (lambda (key val)
                      (and 
                       (equal (second key) graph-id)
                       (or
                        (if (equal (third val) vertex-id)       
                            (push val arc-rep-list) NIL)
                        (if (equal (fourth val) vertex-id)
                            (push (list 'arc graph-id vertex-id 
                                        (third val) (fifth val))
                                  arc-rep-list) 
                          NIL))))
                    *arcs*)
            arc-rep-list)
        NIL)
    NIL))

;;; graph-vertex-adjacent
(defun graph-vertex-adjacent (graph-id vertex-id)
  (if (is-graph graph-id)
      (if (is-vertex vertex-id)
          (let ((vertex-rep-list ()))
            (maphash #'
                    (lambda (key val)
                      (if (equal (second key) graph-id)
                          (or
                           (if (equal (third val) vertex-id)
                               (push (list 'vertex graph-id (fourth
                                                             val))  
                                     vertex-rep-list) NIL)
                           (if (equal (fourth val) vertex-id) 
                               (push (list 'vertex graph-id (third
                                                             val)) 
                                     vertex-rep-list) NIL))))
                    *arcs*)
            vertex-rep-list)
        NIL) NIL))

;;; graph-print
(defun graph-print (graph-id)
  (if (is-graph graph-id)
      (let ((print-output ()))
        (maphash #'
                 (lambda (key val)
                   (if (equal (second key) graph-id)
                       (push (list val) print-output)))
                 *arcs*)
        (maphash #'
                 (lambda (key val)
                   (if (equal (second key) graph-id)
                       (push (list val) print-output)))
                 *vertices*)
        print-output)
    NIL))


;;; new-heap
(defun new-heap (heap-id &optional (capacity 42))
  (or (gethash heap-id *heaps*)
      (setf (gethash heap-id *heaps*)
            (list 'heap heap-id 0 
                  (make-array capacity :fill-pointer 0
                              :adjustable t)))))

;;; is-heap
(defun is-heap (heap-id)
  (gethash heap-id *heaps*))

;;; heap-id
(defun heap-id (heap-id)
  (if (is-heap heap-id)
      (second (gethash heap-id *heaps*))
    nil))

;;; heap-size
(defun heap-size (heap-id)
  (if (is-heap heap-id)
      (third (gethash heap-id *heaps*))
    nil))

;;; heap-new-size
(defun heap-new-size (heap-id new-size)
  (if (is-heap heap-id)
      (or (setf (gethash heap-id *heaps*)
            (list 'heap heap-id new-size (fourth (gethash heap-id
                                                          *heaps*))))
          new-size)
    nil))

;;; heap-actual-heap
(defun heap-actual-heap (heap-id)
  (if (is-heap heap-id)
      (fourth (gethash heap-id *heaps*))
    nil))

;;; heap-delete
(defun heap-delete (heap-id)
  (if (is-heap heap-id)
      (remhash heap-id *heaps*)
    nil))

;;; heap-empty
(defun heap-empty (heap-id)
  (if (is-heap heap-id)
      (if (equal (heap-size heap-id) 0) T nil) nil))

;;; heap-not-empty
(defun heap-not-empty (heap-id)
  (if (heap-empty heap-id) nil T))

;;; heap-head
(defun heap-head (heap-id)
  (if (and (is-heap heap-id)
           (heap-not-empty heap-id))           
      (aref (heap-actual-heap heap-id) 0) NIL))

;;; heap-insert
(defun heap-insert (heap-id k v)
  (if (is-heap heap-id)
      (and
       (heapify heap-id 
                (vector-push-extend
                 (list k v)
                 (heap-actual-heap heap-id)
                 (array-dimension 
                  (heap-actual-heap heap-id) 0))) 
       (heap-new-size heap-id (+ (heap-size heap-id) 1)) T)
    nil))

(defun heapify (heap-id i)
  (if (null i) nil
    (if (equal i 0) t
      (if (< (first (aref (fourth (gethash heap-id *heaps*)) i)) 
             (first (aref (fourth (gethash heap-id *heaps*)) (floor i
                                                                    2)))) 
          (let ((temp (aref (fourth (gethash heap-id *heaps*)) (floor
                                                                i 2)))) 
            (setf (aref (fourth (gethash heap-id *heaps*)) (floor i
                                                                  2)) 
                  (aref (fourth (gethash heap-id *heaps*)) i))
            (setf (aref (fourth (gethash heap-id *heaps*)) i) temp) 
            (heapify heap-id (floor i 2)))
      t))))  


;;; heap-extract
(defun heap-extract (heap-id)
  (if (is-heap heap-id)
      (if (equal (heap-size heap-id) 0) nil
        (let ((head (aref (fourth (gethash heap-id *heaps*)) 0)))
          (progn
            (setf (aref (heap-actual-heap heap-id) 0)
                  (aref (heap-actual-heap heap-id)
                        (- (heap-size heap-id) 1)))
            (vector-pop (heap-actual-heap heap-id))
            (heap-new-size heap-id (- (heap-size heap-id) 1))
            (if (equal (heap-size heap-id) 0) t
              (heapify-all heap-id (- (heap-size heap-id) 1)))
            head))) nil))


(defun heapify-all (heap-id i)
  (if (equal i 0) t
    (and (heapify heap-id i)
         (heapify-all heap-id (- i 1)))))
          

;;; heap-modify-key
(defun heap-modify-key (heap-id new-key old-key V)
  (if (is-heap heap-id)
      (let ((array (heap-actual-heap heap-id)))
        (let ((key-pos (find-key heap-id new-key old-key V
                                 array (- (array-dimension array 0) 1))))
          (if (equal key-pos nil) nil
            (heapify heap-id key-pos))))
    NIL))
    
(defun find-key (heap-id new-key old-key v array i)
  (if (equal i -1) nil
    (if (and (equal (first (aref array i)) old-key)
             (equal (second (aref array i)) v))
          (and (setf (aref array i) (list new-key v)) i)
        (find-key heap-id new-key old-key v array (- i 1)))))

;;; heap-print
(defun heap-print (heap-id)
  (is-heap heap-id))


;;; mst-vertex-key
(defun mst-vertex-key (graph-id vertex-id)
  (if (and 
       (is-graph graph-id)
       (is-vertex vertex-id))
      (let ((key (gethash (list graph-id vertex-id) *vertex-keys*)))
        key)
    NIL))

;;; set-vertex-key
(defun set-vertex-key (graph-id vertex-id weight)
  (if (and
       (is-graph graph-id)
       (is-vertex vertex-id))
      (or (setf (gethash (list graph-id vertex-id) *vertex-keys*) weight)
          (list vertex-id weight))
    NIL))

;;; mst-previous
(defun mst-previous (graph-id V)
  (if (and
       (is-graph graph-id)
       (is-vertex V))
      (let ((prev (gethash (list graph-id V) *previous*)))
        prev)
    NIL))

;;; set-vertex-previous
(defun set-vertex-previous (graph-id vertex-id previous)
  (if (and
       (is-graph graph-id)
       (is-vertex vertex-id)
       (is-vertex previous))
      (or (setf (gethash (list graph-id vertex-id) *previous*) previous)
          (list vertex-id previous))
    NIL))

;;; mst-prim
(defun mst-prim (graph-id source) 
  (let ((added-list ()))
       (new-heap graph-id (vertices-number graph-id))
       (init-vertex-keys graph-id)
       (set-vertex-key graph-id source 0)
       (heap-modify-key graph-id 0
                        most-positive-double-float source)
       (iterate-vertices graph-id (heap-size graph-id) added-list)))

(defun init-vertex-keys (graph-id)
  (mapcar #'
          (lambda (vertex)
            (and (heap-insert graph-id most-positive-double-float
                             (third vertex))
                 (set-vertex-key graph-id (third vertex)
                                 most-positive-double-float)))
          (graph-vertices graph-id)))

(defun iterate-vertices (graph-id size added-list)
  (if (equal size 0) nil
    (let* ((vertex-id (second (heap-extract graph-id)))
          (new-list (iterate-neighbors graph-id vertex-id
                                       (graph-vertex-neighbors
                                        graph-id vertex-id) 
                                       added-list)))
      (iterate-vertices graph-id
                        (heap-size graph-id)
                        new-list))))

(defun iterate-neighbors (graph-id vertex-id neighbors-list added-list)
  (and
   (mapcar #'
           (lambda (neighbor)
             (if (member (fourth neighbor) added-list) t
               (if (< (fifth neighbor)
                      (mst-vertex-key graph-id
                                      (fourth neighbor)))
                   (and 
                    (heap-modify-key graph-id (fifth neighbor)
                                     (mst-vertex-key graph-id
                                                     (fourth neighbor))
                                     (fourth neighbor)) 
                    (set-vertex-key graph-id
                                    (fourth neighbor)
                                    (fifth neighbor))
                    (set-vertex-previous graph-id
                                         (fourth neighbor)
                                             vertex-id))
                 t)))
           neighbors-list)
   (append added-list (list vertex-id))))


;;; mst-get
(defun mst-get (graph-id source)
  (if (and (is-graph graph-id)
           (is-vertex source))
      (let ((preorder-mst ()))
        (create-tree graph-id source preorder-mst))
    NIL))

(defun create-tree (graph-id vertex-id preorder-mst)
  (let ((previous-list (create-previous-list
                        graph-id vertex-id))) 
    (if (equal (list-length previous-list) 0) preorder-mst
      (let ((min-arc (find-min-weight-arc previous-list)))
			(create-tree graph-id
                                     vertex-id
                                     (create-tree graph-id
                                                  (fourth min-arc)
                                                  (append preorder-mst
                                                          (list min-arc))))))))

(defun create-previous-list (graph-id vertex-id)
  (let ((previous-list ()))
    (maphash #'
             (lambda (key val) 
               (if (and
                    (equal val vertex-id)
                    (equal (first key) graph-id))
                   (and (setf previous-list 
                              (append 
                               previous-list 
                               (list (list 'arc 
                                           graph-id
                                           vertex-id 
                                           (second key)
                                           (mst-vertex-key graph-id
                                                           (second key)))))))
                 NIL))
             *previous*)
    previous-list))

(defun find-min-weight-arc (previous-list)
  (if (equal (list-length previous-list) 0)
      ()
    (let ((min-arc
           (iterate-previous-list previous-list
                                  most-positive-double-float
                                  (first previous-list)
                                  (- (list-length previous-list) 1))))
      (remhash (list (second min-arc) (fourth min-arc)) *previous*)
      min-arc)))

(defun iterate-previous-list (previous-list min min-arc i)
  (if (equal i -1)
      min-arc
    (let ((arc (nth i previous-list)))
      (if (< (fifth arc) min)
          (iterate-previous-list previous-list
                                 (fifth arc)
                                 arc
                                 (- i 1))
        (if (= (fifth arc) min)
            (if (string< (fourth arc) (fourth min-arc))
                (iterate-previous-list previous-list
                                       (fifth arc)
                                       arc
                                       (- i 1))
              NIL)
          (iterate-previous-list previous-list
                                 min
                               min-arc
                               (- i 1)))))))
							   
;;;; end of file -- mst.lisp