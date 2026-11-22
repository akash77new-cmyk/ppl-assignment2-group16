;; ===========================================================================
;; Tests for S1 (16_q3.rkt) - Group 16
;;
;; The grader appends its own calls to the end of the solution file, so this
;; test file is written as exactly that: the block of calls to append.
;; run_tests.sh concatenates ../code/16_q3.rkt with this file and compares the
;; output against expected_q3.txt.
;;
;;     cd tests && ./run_tests.sh
;;
;; This file deliberately has no #lang line: it is appended, never run alone.
;; ===========================================================================

;; --- the tree from the assignment ---
(define t1 '(4 (2 (1 () ()) (3 () ()))
               (6 (5 () ()) (7 () ()))))

;; --- right-leaning chain: height 3, a single leaf ---
(define t2 '(1 () (2 () (3 () ()))))

;; --- symbol values rather than numbers ---
(define t3 '(a (b () ()) (c () ())))

;; --- a single node: height 1, one leaf ---
(define t4 '(9 () ()))

;; --- left-leaning chain, the mirror of t2 ---
(define t5 '(1 (2 (3 () ()) ()) ()))

;; --- unbalanced: left subtree deeper than right ---
(define t6 '(1 (2 (4 (8 () ()) ()) (5 () ())) (3 () ())))

(display "-- t1 --") (newline)
(print-inorder t1)
(print-all-traversals t1)
(print-height-and-leaves t1)

(display "-- t2 --") (newline)
(print-all-traversals t2)
(print-height-and-leaves t2)

(display "-- t3 --") (newline)
(print-all-traversals t3)
(print-height-and-leaves t3)

(display "-- t4 single node --") (newline)
(print-inorder t4)
(print-height-and-leaves t4)

(display "-- t5 left chain --") (newline)
(print-all-traversals t5)
(print-height-and-leaves t5)

(display "-- t6 unbalanced --") (newline)
(print-all-traversals t6)
(print-height-and-leaves t6)

(display "-- empty tree --") (newline)
(print-inorder '())
(print-all-traversals '())
(print-height-and-leaves '())
