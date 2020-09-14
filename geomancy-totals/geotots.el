;;  -*- lexical-binding: t; -*-
;; count the number of unique geomantic shield values


(require 'subr-x) ;; for hash-table-values

(defvar *nephews* (make-hash-table))
(defvar *each-nephew* (make-hash-table))
(defvar *left-witness* (make-hash-table))
(defvar *right-witness* (make-hash-table))
(defvar *witnesses* (make-hash-table))
(defvar *judge* (make-hash-table))
 
(defvar *fig-names*
  (let ((fn (make-hash-table)))
    (mapc #'(lambda (pair)
	      (puthash (car pair) (cdr pair) fn))
	  '((15 . "Via")
	    (14 . "Cauda Draconis")
	    (13 . "Puer")
	    (12 . "Fortuna Minor")
	    (11 . "Puella")
	    (10 . "Amissio")
	    (9  . "Carcer")
	    (8  . "Laetitia")
	    (7  . "Caput Draconis")
	    (6  . "Conjunctio")
	    (5  . "Acquisitio")
	    (4  . "Rubeus")
	    (3  . "Fortuna Major")
	    (2  . "Albus")
	    (1  . "Tristitia")
	    (0  . "Populus")))
    fn))

     
(defun add-figures (f1 f2) (logxor f1 f2))

(defun line-of (fig ln)
  (logand #x01
	  (ash fig (- (- 4 ln)))))

(defun make-fig (ln1 ln2 ln3 ln4)
  (logior (ash ln1 3)
	  (ash ln2 2)
	  (ash ln3 1)
	  ln4))

(defun generate-sisters (&rest moms)
  (list
   (apply #'make-fig (mapcar #'(lambda (f) (line-of f 1)) moms))
   (apply #'make-fig (mapcar #'(lambda (f) (line-of f 2)) moms))
   (apply #'make-fig (mapcar #'(lambda (f) (line-of f 3)) moms))
   (apply #'make-fig (mapcar #'(lambda (f) (line-of f 4)) moms))))

(defmacro inctbl (k tb)
  `(puthash ,k (1+ (gethash ,k ,tb 0)) ,tb))
(defun generate-shield (mom1 mom2 mom3 mom4)
  (let* ((sis (generate-sisters mom1 mom2 mom3 mom4))
	 (n1  (add-figures mom1 mom2))
	 (n2  (add-figures mom3 mom4))
	 (n3  (add-figures (car sis) (cadr sis)))
	 (n4  (add-figures (caddr sis) (cadddr sis)))
	 (ns  (logior (lsh n4 24)
		      (lsh n3 16)
		      (lsh n2 8)
		      n1)))
    (inctbl n1 *each-nephew*)
    (inctbl n2 *each-nephew*)
    (inctbl n3 *each-nephew*)
    (inctbl n4 *each-nephew*)
    (inctbl ns *nephews*)
    (let* ((lw (add-figures n3 n4))
	   (rw (add-figures n1 n2))
	   (ws (logior (lsh lw 8)
		       rw))
	   (j  (add-figures lw rw)))
      (inctbl ws *witnesses*)
      (if  (or (eql lw 0)
		(eql lw 7)
		(eql lw 12)
		(eql lw 14))
	  (inctbl rw *right-witness*)
	  (inctbl lw *left-witness*))
      (inctbl j *judge*))))

(progn
  (mapc #'clrhash (list
		   *nephews*
		   *each-nephew*
		   *left-witness*
		   *right-witness*
		   *witnesses*
		   *judge*))
  (dotimes (m1 16)
    (dotimes (m2 16)
      (dotimes (m3 16)
	(dotimes (m4 16)
	  (generate-shield m1 m2 m3 m4))))))

(defun pr-hash (hash)
  (print (hash-table-count hash))
  (print (hash-table-values hash))
  (print (hash-table-keys hash))
  t)

(pr-hash *left-witness*)
(pr-hash *right-witness*)

;; So for the idea of setting the sign of the 1st house by:
;;  - the left witness, unless it's Populus, Fortuna Minor,
;;        Cauda Draconis, Caput Draconis,
;;  - or... the right witness if it is one of the restricted ones
;; there are 16k which go to the right-witness...
(/ 16384.0 65536.0) ;; => 0.25

;; of those... 4k are still not good...
(/ 4096.0 65536.0) ;; 0.0625

;; so... what to do in those cases?
