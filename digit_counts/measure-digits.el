;;  -*- lexical-binding: t; -*-

(defun histo (n)
  "Compute the count of each digit in the given number."
  (let ((histo (make-hash-table)))
    (seq-doseq (chr (number-to-string n))
      (puthash chr (1+ (gethash chr histo 0)) histo))
    (dolist (key (hash-table-keys histo))
      (princ (format "%s: %d\n" (char-to-string key) (gethash key histo))))))
