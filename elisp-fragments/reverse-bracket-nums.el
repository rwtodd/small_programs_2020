
(defun reverse-bracketed-nums ()
  "Find the next '{1 2 3}' and replace it with '0x321'"
  (interactive)
  (re-search-forward "{\\([0-9A ]*\\)}")
  (replace-match (concat "0x" (reverse (delete ?\s (match-string 1))))))
