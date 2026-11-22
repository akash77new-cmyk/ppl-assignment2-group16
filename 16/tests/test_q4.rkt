;; ===========================================================================
;; Tests for S2 (16_q4.rkt) - Group 16
;;
;; As with S1, the grader appends its calls to the solution file, so this file
;; is written as the block of calls to append.  run_tests.sh concatenates
;; ../code/16_q4.rkt with this file and compares against expected_q4.txt.
;;
;;     cd tests && ./run_tests.sh
;;
;; print-insert-result reads from standard input, so it is exercised
;; separately by run_tests.sh rather than here.
;;
;; This file deliberately has no #lang line: it is appended, never run alone.
;; ===========================================================================

;; --- the four examples from the assignment ---
(display (insert-if-short 42 '((1 2) (3 4 5) (6) ()) 3))             (newline)
(display (insert-if-short 0 '(((1) 2) (3) ((4 5 6) ())) 3))          (newline)
(display (insert-if-short 7 '() 3))                                  (newline)
(display (insert-if-short 7 '() 0))                                  (newline)

;; --- boundary on n ---
;; length 3 list with n = 3: 3 < 3 is false, so nothing is inserted
(display (insert-if-short 'x '(1 2 3) 3))                            (newline)
;; same list with n = 4: 3 < 4, so x goes in front
(display (insert-if-short 'x '(1 2 3) 4))                            (newline)

;; --- n = 0 inserts nowhere, not even into empty lists ---
(display (insert-if-short 'x '(() (()) 1) 0))                        (newline)

;; --- the length is the ORIGINAL length, measured before insertion ---
;; inner () becomes (x) (length 1), but the outer list is measured as 1,
;; not 2, so with n = 2 the outer list still qualifies
(display (insert-if-short 'x '(()) 2))                               (newline)

;; --- atoms are left alone, symbols and numbers mix freely ---
(display (insert-if-short 'q '(a (b) 1 (2 3)) 3))                    (newline)

;; --- deep nesting ---
(display (insert-if-short 'd '((((())))) 2))                         (newline)

;; --- helpers required by S2.b are present and correct ---
(display (my-length '()))                                            (newline)
(display (my-length '(1 2 3 4 5)))                                   (newline)
(display (my-map (lambda (v) (* v 2)) '(1 2 3)))                     (newline)
(display (my-map (lambda (v) v) '()))                                (newline)

;; --- make-inserter is a genuine higher-order function (S2.c) ---
;; driving it with a different predicate must work: lists longer than 2
(define long-only (make-inserter 'L (lambda (len) (> len 2))))
(display (long-only '((1 2 3) (4) (5 6 7 8))))                       (newline)

;; and with a predicate that accepts exactly length 1
(define one-only (make-inserter 'O (lambda (len) (= len 1))))
(display (one-only '((1) (2 3) ((4)))))                              (newline)
