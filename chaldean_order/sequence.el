;; Chaldean planet order + modular arithmetic sequences
;; ... musings based on https://www.renaissanceastrology.com/3rdplanetaryorder.html

(defvar planets  (vector 'mars 'sun 'venus 'mercury 'moon 'saturn 'jupiter))
(defun +mod7 (x y) (mod (+ x y) 7))
(defun nseq (start adder)
  (let ((result nil))
    (dotimes (_ 8 (reverse result))
      (setq result (cons start result))
      (setq start (+mod7 start adder)))))
(defun pseq (start adder)
  (mapcar #'(lambda (n) (aref planets n))
       (nseq (mod start 7) adder)))

(pseq -15 -3) ;; (jupiter mercury mars moon sun saturn venus jupiter)
(pseq -10 -2) ;; (moon venus mars saturn mercury sun jupiter moon)
(pseq  -5 -1) ;; (venus sun mars jupiter saturn moon mercury venus)
(pseq   0  0) ;; (mars mars mars mars mars mars mars mars)
(pseq   5  1) ;; (saturn jupiter mars sun venus mercury moon saturn)
(pseq  10  2) ;; (mercury saturn mars venus moon jupiter sun mercury)
(pseq  15  3) ;; (sun moon mars mercury jupiter venus saturn sun)
