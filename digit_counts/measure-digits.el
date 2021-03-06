;;  -*- lexical-binding: t; -*-

(defun histo (n)
  "Compute the count of each digit in the given number."
  (let ((histo (make-hash-table)))
    (seq-doseq (chr (number-to-string n))
      (puthash chr (1+ (gethash chr histo 0)) histo))
    (mapcar #'(lambda (key)
		(list (char-to-string key)
		      (gethash key histo)))
	    (hash-table-keys histo))))

(defun histo-2 (n)
  "Compute the count of each digit in the given number. This time use
built-in seq-group-by function"
  (mapcar #'(lambda (bin)
	      (list (char-to-string (car bin))
		    (length (cdr bin))))
	  (seq-group-by #'identity (number-to-string n))))

;; to find numbers which have the same number of each digit...
;; (defun same-digits-p (x) (apply #'= (mapcan #'cdr (histo x))))
;; (cl-loop for x from 1 to 400 appending
;; 	 (cl-loop for y from 1 to 400
;; 		  when (same-digits-p (expt x y))
;; 		  collect (list x y (expt x y))))
