;;  -*- lexical-binding: t; -*-

;; This is here just to help me remember how to use `calc-*` functions.

(defun count-business-days (da db)
  "Subtract db from da.. dates in the form `<yyyy-mm-dd`. Uses calc."
  (calcFunc-bsub (calc-eval da 'raw)
		 (calc-eval db 'raw)))
