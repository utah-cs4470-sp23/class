#lang racket

;; make an executable version of this like so:
;; raco exe pp.rkt

(for ([line (in-port read)])
  (pretty-print line (current-output-port) 1))
