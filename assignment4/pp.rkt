#lang racket

;; Read stdin as string > escape backslashes > parse as s-expressions > pretty print as
;; string > remove backslash escapes
(for ([line (in-port read-line)] #:break (string-prefix? line "Compilation"))
     (define op (open-output-string))
     (define val (read (open-input-string (string-replace line "\\" "\\\\"))))
     (unless (eof-object? val)
       ;; Use pretty-print for quote-depth functionality.
       ;; Escape backslashes so read interprets them as literal backslashes.
       (pretty-print val op 1)
       ;; Remove the escapes from before.
       (display (string-replace (get-output-string op) "\\\\" "\\"))))
