#lang racket/base

;; ===========================================================================
;; CS F301 Principles of Programming Languages - Assignment 2
;; S1: Binary Tree Traversals
;; Group 16
;;
;; A binary tree is either '() or a three-element list (value left right).
;;   (car t)   -> the value
;;   (cadr t)  -> the left subtree
;;   (caddr t) -> the right subtree
;;
;; Allowed built-ins only: no append, length, map, reverse, set!, vectors
;; or strings.  Every traversal is built with an accumulator so that the
;; result list is assembled by cons alone, never by append.
;;
;; Run:  racket 16_q3.rkt     (defines only; the grader adds the calls)
;; ===========================================================================

;; ---------------------------------------------------------------------------
;; Traversals
;;
;; Each helper takes the tree and an accumulator, and returns
;;     <the traversal of tree>  followed by  acc
;; Reading it that way makes the three definitions fall out directly from the
;; definition of each traversal order, and avoids append entirely: the list is
;; grown from the right-hand end backwards.
;; ---------------------------------------------------------------------------

;; (inorder tree acc) -> inorder values of tree, followed by acc
;; inorder = left subtree, node, right subtree
(define (inorder tree acc)
  (if (null? tree)
      acc
      (inorder (cadr tree)
               (cons (car tree)
                     (inorder (caddr tree) acc)))))

;; (preorder tree acc) -> preorder values of tree, followed by acc
;; preorder = node, left subtree, right subtree
(define (preorder tree acc)
  (if (null? tree)
      acc
      (cons (car tree)
            (preorder (cadr tree)
                      (preorder (caddr tree) acc)))))

;; (postorder tree acc) -> postorder values of tree, followed by acc
;; postorder = left subtree, right subtree, node
(define (postorder tree acc)
  (if (null? tree)
      acc
      (postorder (cadr tree)
                 (postorder (caddr tree)
                            (cons (car tree) acc)))))

;; ---------------------------------------------------------------------------
;; Shape measurements
;; ---------------------------------------------------------------------------

;; (height tree) -> 0 for the empty tree, otherwise 1 + the taller subtree.
;; A single node therefore has height 1.
(define (height tree)
  (if (null? tree)
      0
      (+ 1 (max (height (cadr tree))
                (height (caddr tree))))))

;; (leaf-count tree) -> the number of nodes whose two subtrees are both empty.
;; The empty tree has no leaves.
(define (leaf-count tree)
  (cond ((null? tree) 0)
        ((and (null? (cadr tree)) (null? (caddr tree))) 1)
        (else (+ (leaf-count (cadr tree))
                 (leaf-count (caddr tree))))))

;; ---------------------------------------------------------------------------
;; S1.a / S1.b / S1.c - printing
;; Every function ends its output with a newline.
;; ---------------------------------------------------------------------------

;; S1.a - one line: the inorder list.
(define (print-inorder tree)
  (display (inorder tree '()))
  (newline))

;; S1.b - three lines: inorder, then preorder, then postorder.
(define (print-all-traversals tree)
  (display (inorder tree '()))
  (newline)
  (display (preorder tree '()))
  (newline)
  (display (postorder tree '()))
  (newline))

;; S1.c - one line: the two-element list (height leaf-count).
(define (print-height-and-leaves tree)
  (display (list (height tree) (leaf-count tree)))
  (newline))
