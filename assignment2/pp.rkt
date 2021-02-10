#lang racket

;; make an executable version of this like so:
;; raco exe pp.rkt

(for ([line (in-port read)] #:break (equal? line 'Compilation))
  (pretty-print line (current-output-port) 1))
