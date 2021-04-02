#lang racket

;; Preprocess output to escape all backslashes
(define s (port->string (current-input-port)))
(define port (open-input-string (string-replace s "\\" "\\\\")))

(for ([val (in-port read port)] #:break (eq? val 'Compilation))
  (pretty-print val (current-output-port) 1))
