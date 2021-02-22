#lang racket

; Read stdin as string > escape backslashes > parse as s-expressions > pretty print as
; string > remove backslash escapes
(for ([line (in-port read-line)] #:break (string-prefix? line "Compilation"))
     (define op (open-output-string))
     ; Use pretty-print for quote-depth functionality.
     ; Escape backslashes so read interprets them as literal backslashes.
     (pretty-print (read (open-input-string (string-replace line "\\" "\\\\"))) op 1)
     ; Remove the escapes from before.
     (display (string-replace (get-output-string op) "\\\\" "\\")))
