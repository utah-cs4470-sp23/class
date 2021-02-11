#lang racket
(for ([line (in-port read)] #:break (equal? line 'Compilation))
  (pretty-print line (current-output-port) 1))
