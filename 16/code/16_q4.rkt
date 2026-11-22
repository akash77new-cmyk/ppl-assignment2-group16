#lang racket/base

;; ===========================================================================
;; CS F301 Principles of Programming Languages - Assignment 2
;; S2: Conditionally Insert into a Nested List
;; Group 16
;;
;; (insert-if-short x lst n) inserts x at the front of every list whose
;; ORIGINAL length is less than n, at every level of nesting.
;;
;; Allowed built-ins only: length, append, map, reverse, member and friends
;; are forbidden, so my-length, my-reverse and my-map are written here.
;;
;; Run:  racket 16_q4.rkt     (defines only; the grader adds the calls)
;; ===========================================================================

;; ---------------------------------------------------------------------------
;; S2.b - list helpers
;;
;; Both are tail recursive through a named let, so they run in constant stack
;; space.  The hidden tests use lists of 10,000 elements, which a non-tail
;; recursive my-map would walk one stack frame at a time.
;; ---------------------------------------------------------------------------

;; (my-length l) -> the number of top-level elements of l.
(define (my-length l)
  (let loop ((rest l) (count 0))
    (if (null? rest)
        count
        (loop (cdr rest) (+ count 1)))))

;; (my-reverse l) -> l with its top-level elements in the opposite order.
(define (my-reverse l)
  (let loop ((rest l) (acc '()))
    (if (null? rest)
        acc
        (loop (cdr rest) (cons (car rest) acc)))))

;; (my-map f l) -> the list of (f e) for each top-level element e of l,
;; in the original order.  Built back-to-front with an accumulator, then
;; reversed, so the recursion stays tail recursive.
(define (my-map f l)
  (let loop ((rest l) (acc '()))
    (if (null? rest)
        (my-reverse acc)
        (loop (cdr rest) (cons (f (car rest)) acc)))))

;; ---------------------------------------------------------------------------
;; S2.c - the higher-order inserter
;;
;; (make-inserter x len-ok?) returns a function of one list.
;;
;; walk is applied to every item in the structure:
;;   - an empty list has length 0, so it becomes (x) when (len-ok? 0);
;;   - a non-empty list is measured FIRST, on the original list, then its
;;     elements are walked, and only then is x added if the original length
;;     satisfied len-ok?.  Measuring before walking is what makes the rule
;;     "length of the original list" hold at every level;
;;   - anything else is an atom and is returned unchanged.
;; ---------------------------------------------------------------------------

(define (make-inserter x len-ok?)
  (letrec ((walk
            (lambda (item)
              (cond
                ;; empty list: length 0
                ((null? item)
                 (if (len-ok? 0) (list x) '()))
                ;; non-empty list: measure the original, then recurse
                ((pair? item)
                 (let ((original-length (my-length item)))
                   (let ((walked (my-map walk item)))
                     (if (len-ok? original-length)
                         (cons x walked)
                         walked))))
                ;; atom
                (else item)))))
    walk))

;; ---------------------------------------------------------------------------
;; S2.b / S2.c - insert-if-short
;;
;; Single definition, expressed through make-inserter, with the predicate
;; "shorter than n".  The top-level list is treated like every other list.
;; ---------------------------------------------------------------------------

(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; ---------------------------------------------------------------------------
;; S2.a - read x, lst and n from standard input, in that order, and print
;; the result followed by a newline.  No prompt, no other output.
;; ---------------------------------------------------------------------------

(define (print-insert-result)
  (let* ((x   (read))
         (lst (read))
         (n   (read)))
    (display (insert-if-short x lst n))
    (newline)))
