;; $Id$
;;
;; tpl-mode.el
;;
;; Date: 11 March 2003
;;
;; Support: Eric Gebhart (saseag@unx.sas.com)
;;
;; Purpose: Provide font-lock and editing mode for a SAS tagset template.
;;
;; The mode needs to be associated with a file type... So do something like
;; this.
;;
;;(setq auto-mode-alist
;;      (append '(
;;                ("\\.tpl\\'" . tpl-mode)
;;               )))
;;
;; This mode does syntax highlighting and auto indention for tagset tpl
;; files.  It also has speedbar support which lists the tagsets and the
;; events that belong to them.
;;
;; The syntax highlighting adds a number of new fonts.  It's probably a bit
;; over the top but it gives maximum control over how things get highlighted.
;; 

(defvar tpl-mode-syntax-table nil
 "Syntax table used while in tpl mode")

(if tpl-mode-syntax-table
 ()         ; Do not change the table if it is already set up
 (setq tpl-mode-syntax-table (make-syntax-table))
 (modify-syntax-entry ?/  ". 14"   tpl-mode-syntax-table)
 (modify-syntax-entry ?*  ". 23"   tpl-mode-syntax-table)
  (modify-syntax-entry ?+  "."     tpl-mode-syntax-table)
  (modify-syntax-entry ?-  "."     tpl-mode-syntax-table)
  (modify-syntax-entry ?=  "."     tpl-mode-syntax-table)
  (modify-syntax-entry ?%  "."     tpl-mode-syntax-table)
  (modify-syntax-entry ?<  "."     tpl-mode-syntax-table)
  (modify-syntax-entry ?>  "."     tpl-mode-syntax-table)
  (modify-syntax-entry ?&  "."     tpl-mode-syntax-table)
  (modify-syntax-entry ?|  "."     tpl-mode-syntax-table)
  ;; quotes are treated as whitespace.  We'll handle font lock for
  ;; strings with our own rules.  Otherwise everything get's all 
  ;; messed up because quotes in tagsets are so frequent and badly
  ;; formed that whole sections of tagset code turns into a string.
  (modify-syntax-entry ?\"  " "     tpl-mode-syntax-table)
  (modify-syntax-entry ?\'  " "     tpl-mode-syntax-table)
  (modify-syntax-entry ?\;  " "     tpl-mode-syntax-table)
)

; lots of font faces for better control.
; Probably more colors than anyone really wants.

(make-face 'sas-tpl-obj-name-face)
(defvar sas-tpl-obj-name-face 'sas-tpl-obj-name-face)

(make-face 'sas-tpl-start-finish-face)
(defvar sas-tpl-start-finish-face 'sas-tpl-start-finish-face)

(make-face 'sas-tpl-put-face)
(defvar sas-tpl-put-face 'sas-tpl-put-face)

(make-face 'sas-tpl-triggered-event-face)
(defvar sas-tpl-triggered-event-face 'sas-tpl-triggered-event-face)

(make-face 'sas-tpl-if-face)
(defvar sas-tpl-if-face 'sas-tpl-if-face)

(make-face 'sas-tpl-trigger-face)
(defvar sas-tpl-trigger-face 'sas-tpl-trigger-face)

(make-face 'sas-tpl-event-name-face)
(defvar sas-tpl-event-name-face 'sas-tpl-event-name-face)

(make-face 'sas-tpl-expression-face)
(defvar sas-tpl-expression-face 'sas-tpl-expression-face)

(make-face 'sas-tpl-newline-face)
(defvar sas-tpl-newline-face 'sas-tpl-newline-face)

(make-face 'sas-tpl-stream-name-face)
(defvar sas-tpl-stream-name-face 'sas-tpl-stream-name-face)

(make-face 'sas-tpl-end-semi-face)
(defvar sas-tpl-end-semi-face 'sas-tpl-end-semi-face)

(make-face 'sas-tpl-dynvar-face)
(defvar sas-tpl-dynvar-face 'sas-tpl-dynvar-face)

(make-face 'sas-tpl-set-face)
(defvar sas-tpl-set-face 'sas-tpl-set-face)


(set-face-foreground 'sas-tpl-obj-name-face     "#00FFAA")
(set-face-foreground 'sas-tpl-start-finish-face "wheat")
(set-face-foreground 'sas-tpl-put-face "#EEFF00")
(set-face-foreground 'sas-tpl-trigger-face "#AACCAA")
(set-face-foreground 'sas-tpl-if-face "#FFCCEE")
(set-face-foreground 'sas-tpl-event-name-face "#CCAACC")
(set-face-foreground 'sas-tpl-expression-face "#CCCCCC")
(set-face-foreground 'sas-tpl-stream-name-face "#0000EE")
(set-face-foreground 'sas-tpl-newline-face "#dd0000")
(set-face-foreground 'sas-tpl-end-semi-face "#FFFF00")
(set-face-foreground 'sas-tpl-dynvar-face "#AAFFCC")
(set-face-foreground 'sas-tpl-set-face "#DDCCBB")

;; The order of these rules can make a big difference.  None of them
;; have the over-ride to make them take affect regardles of previous
;; rule matches.  So if a previous rule matches that is the one that
;; sticks.  Think of them as transparent overlays.  As long as the
;; numbered expression does not lay directly on top of a previous
;; match it will take affect even if other parts of it's regex do overlay.
;; The rules for functions and if's show this pretty well.
;; Forcing a match even over previous matches takes this form.  
;; Notice the t.
;;  ("^[ \t]*\\(open\\|block\\|unblock\\) " 
;;   (1 font-lock-reference-face t))
(defvar tpl-font-lock-keywords
 '(
   ;; define tagset|event foo.bar
  ("\\([Dd][Ee][Ff][Ii][Nn][Ee] *[a-zA-Z0-9_]*\\) *\\([a-zA-Z0-9_\.]*\\)" 
   (1 font-lock-keyword-face)
   (2 font-lock-function-name-face))
   ;; end;
  ("\\([Ee][Nn][Dd]\\);" 
   (1 font-lock-keyword-face))
   ;; Do | Done | else | continue | stop | Iterate | next
  ("^[ \t]*\\(do\\(ne\\)*\\|else\\|continue\\|stop\\|iterate\\|next\\).*;" 
   (1 font-lock-keyword-face))

  ("^[ \t]*\\(open\\|block\\|unblock\\) " 
   (1 font-lock-reference-face))
  ;; commands with no arguments
  ("^[ \t]*\\(close\\|break\\|flush\\)" 
   (1 font-lock-reference-face)
  )
  ;; set|unset $variable
  ("^[ \t]*\\(set\\|unset\\) *\\(\$*[a-zA-Z0-9_]*\\)"
   (1 sas-tpl-set-face)
   (2 font-lock-variable-name-face)
  )
  ; trigger event
  ("^[ \t]*\\(trigger\\) *\\([a-zA-Z0-9_]*\\)"
   (1 sas-tpl-trigger-face)
;   (2 sas-tpl-event-name-face)
   (2 font-lock-function-name-face)
  )
  ;; Memory variables.
  ("\\(\$[a-zA-Z0-9_]*\\)" 
   (1 font-lock-variable-name-face)
  )
  ;; Dynamic variables.
  ("\\(@[a-zA-Z0-9_]*\\)" 
   (1 sas-tpl-dynvar-face)
  )
  ;; stream variables
  ("\\(\$$[a-zA-Z0-9_]*\\)" 
   (1 sas-tpl-stream-name-face)
  )
  ; Newlines
  (" \\(nl\\|CR\\|cr\\|NL\\|lf\\|LF\\)[ ;/]" 
   (1 sas-tpl-newline-face)
  )
  ; All variations of put
  ("^[ \t]*\\(put\\(l\\|q\\|log\\|vars\\|stream\\)*\\) " 
   (1 sas-tpl-put-face)
  )
  ; start: and finish:
  ("^[ \t]*\\(start:\\|finish:\\)" 
   (1 sas-tpl-start-finish-face)
  )
  ; semi-colon at the end of the line.
  ("\\(;$\\)" 
   (1 sas-tpl-end-semi-face)
  )
  ; single quoted string
  ("\\(\'.*?\'\\)" (1 font-lock-string-face))
  ; double quoted string - only applies if it's not in a single quoted string.
  ("\\(\".*?\"\\)" (1 font-lock-string-face))
  ;; and, or, &, |, like
  ("\\( and \\| or \\|&\\|\|\\| like \\)" 
   (1 font-lock-constant-face)
  )
  ;; Functions foo(.....)
  ("\\([!\^]*[a-zA-Z_]*?\(\\)[-a-zA-Z0-9\+_,\"\'\$\@ ]*\\(\)\\)" 
   (1 font-lock-builtin-face)
   (2 font-lock-builtin-face)
   ;(1 sas-tpl-expression-face)
   ;(2 sas-tpl-expression-face)
  )
  ;; eval $foo expression;
  ("^[ \t]*\\(eval\\) *\\(\$*[a-zA-Z0-9_]*\\) \\(.*\\);$" 
   (1 font-lock-reference-face)
   (2 font-lock-variable-name-face)
   (3 sas-tpl-expression-face)
  )
  ;; /if expression
  (" *\\(\/\\)[ \n\t]*\\(if\\|breakif\\|when\\|where\\|while\\)* \\(.*\\)$" 
   (1 sas-tpl-if-face)
   (2 sas-tpl-if-face)
   (3 sas-tpl-expression-face)
  )
 "Template file highlighting"
 )
)

(defvar tpl-mode-abbrev-table nil
 "Abbrev table used in tpl mode")
(define-abbrev-table 'tpl-mode-abbrev-table ())

(defvar tpl-mode-map nil)  ; Create a mode-specific keymap.

(if tpl-mode-map
 ()         ; Do not change the keymap if it is already set up
 (setq tpl-mode-map (make-sparse-keymap))
 (define-key tpl-mode-map "\t"           'tab-to-tab-stop)
 (define-key tpl-mode-map [(control c) (control b)]  'compile)
 (define-key tpl-mode-map [(control c) (control n)]  'next-error)
 (define-key tpl-mode-map [(control c) (control p)]  'previous-error)
)

(defvar tpl-default-tab-width 4)  ; Tab width for tpl files.

; handle automatic indentention. 
(defun tpl-indent-line ()
  "Indent current line as WPDL code."
  (interactive)
  (beginning-of-line)

  ;; If the line we are looking at is empty, we need to look back one to see if it was 
  ;; end or finish that needs pulling out.
  (if (looking-at "^[ \t]*\n") 
     (save-excursion 
      (forward-line -1)
      (tpl-indent-line)))
  (if (bobp)
	  (indent-line-to 0)		   ; First line is always non-indented
	(let ((not-indented t) cur-indent)
	  (if (looking-at "^[ \t]*\\(end\\|done\\|else\\);") ; If the line we are looking at is the end of a block, then decrease the indentation
		  (progn
			(save-excursion
			  (forward-line -1)
			  (setq cur-indent (- (current-indentation) tpl-default-tab-width))
                          ;; Only have to do this because end, ends the finish or start block as well as the define block.
		          (while not-indented ; Iterate backwards until we find an indentation hint
			        (forward-line -1)
			        (if (looking-at "^[ \t]*\\(finish:\\|start:\\)") ; We need to come out one more.  
			          (progn
                                    (setq cur-indent (- (current-indentation) tpl-default-tab-width))
				    (setq not-indented nil)))
			        (if (looking-at "^[ \t]*define") ; Stop looking.
				    (setq not-indented nil))
			        (if (looking-at "^[ \t]*\\(do\\|else\\)") ; Stop looking.
				    (setq not-indented nil))
                                                            )
			(if (< cur-indent 0) ; We can't indent past the left margin
				(setq cur-indent 0))))
                 ; If the line we are looking at is the end of a block, then decrease the indentation
	        (if (looking-at "^[ \t]*\\(finish:\\)") 
		  (progn
			(save-excursion
		          (while not-indented ; Iterate backwards until we find an indentation hint
			        (forward-line -1)
			        (if (looking-at "^[ \t]*\\(start:\\|do\\|else\\)") ; We need to come out one.  
			          (progn
                                    (setq cur-indent (- (current-indentation) tpl-default-tab-width))
				    (setq not-indented nil)))
                                ; Stop looking. This is just the start of finish not the end of start.
			        (if (looking-at "^[ \t]*define") 
                                    ; Do the actual indenting
                                    (progn
                                      (setq cur-indent (+ (current-indentation) tpl-default-tab-width)) 
				      (setq not-indented nil))))
			(if (< cur-indent 0) ; We can't indent past the left margin
				(setq cur-indent 0))))
		(save-excursion
		  (while not-indented ; Iterate backwards until we find an indentation hint
			(forward-line -1)
                         ; This hint indicates that we need to indent at the level of the END_ token
			(if (looking-at "^[ \t]*\\(end\\|done\\);") 
				(progn
				  (setq cur-indent (current-indentation))
				  (setq not-indented nil))
                           ; ELSE: This hint indicates that we need to indent an extra level
			  (if (looking-at "^[ \t]*\\(define\\|start:\\|finish:\\|do\\|else\\)") 
				  (progn
                                        ; Do the actual indenting
					(setq cur-indent (+ (current-indentation) tpl-default-tab-width)) 
					(setq not-indented nil))
				(if (bobp)
					(setq not-indented nil))))))))
	  (if cur-indent
		  (indent-line-to cur-indent)
		(indent-line-to 0))))) ; If we didn't see an indentation hint, then allow no indentation

; None of this gives us speedbar support.  Don't ask me why...
; It's supposed to be this easy.  I guess I'll have to do it
; the hard way...
;
(require 'speedbar)

;; We want to put tagset names and event names in the speedbar.
;; Here's how we find them.
(defvar tpl-mode-imenu-generic-expression
  (`
   ((nil
     (, (concat
	 "^"				; beginning of line is required
	 "[ \t]*define[ \t]*tagset[ \t]*"
	 "\\("
         "[a-zA-Z0-9_]*"
         "\\."
         "[a-zA-Z0-9_]*"
         "\\)"		; this is the string we want to get
         "[ \t]*;$"
	 )) 1)
    (nil
     (, (concat
	 "^"				; beginning of line is required
	 "[ \t]*define[ \t]*"
         "event[ \t]*"
	 "\\([a-zA-Z0-9_]*\\).*" ; this is the string we want to get
	 )) 1)
    ))
  )

;; Imenu gives us a list of cons of tagset names and event names in the order
;; they were found.  We want to change that into lists of events by tagset.
;; When we click on a tagset name in the speedbar it gives us the sublist we
;; build here.  So if we don't find a tagset name then we just want to give back
;; the list we get...
;;
;; Build an association of tagsets and events.
;; (
;; (tagsets.foo . ((event1 . loc) (event2 . loc))
;; (tagsets.bar . ((bar_event1 . loc) (bar_event2 . loc))
;; )
;; If no tagset names then just return the list...
;; because we are being asked to expand a submenu of event names.
;; ((event1 . loc) (event2 .loc))

(defun tpl-mode-speedbar-tag-hierarchy (lst)
  (let ((newlst nil)(result nil)(tagset nil))
      (while lst
	(let ((e (car lst)))
	   (if (string-match "\\([a-zA-Z0-9_]*\\)\\.\\([a-zA-Z0-9_]*\\)" (car e))
             (if tagset
               (setq result (acons tagset (nreverse newlst) result)
                     newlst nil
                     ; put the tagset name in the list so we can click to it.
                     tagset (car e)

                     ; setcar returns the thing we just set the car to.  But we don't care...
                     ; This is so we'll have an entry that is clickable for the 
                     ; define tagset statement.
                     ; The name has to change or it'll match on the regex and 
                     ; we'll have never ending - repeating subdirs.
                     junk (setcar e (concat "Define " (match-string 2 (car e))))
                     newlst (cons e newlst))

                (setq tagset (car e)
                      junk (setcar e (concat "Define " (match-string 2 (car e))))
                      newlst (cons e newlst)))
	    (setq newlst
		  (cons e newlst)))
	(setq lst (cdr lst))))
        ; Handle the last one.  - newlst has a value, tagset might.
        (if tagset
          (setq result (nreverse (acons tagset (nreverse newlst) result)))
          ; if there is a result then we need to preserve what's there.
          (if result
            (setq result (cons (nreverse newlst) result))
            (setq result (nreverse newlst))))
      result))

  

;; For some reason gud doesn't like it when I turn
;; auto-indent globally.  So I'm just turning it on
;; specifically for this.

(defun tpl-mode-viper-hook ()
  (setq viper-auto-indent 't)
  )

(add-hook 'tpl-mode-hook 'tpl-mode-viper-hook)

(defun tpl-mode ()
  "Major mode for editing SAS template files.
Turning on tpl-mode run the hook `tpl-mode-hook'."
  (interactive)
  (kill-all-local-variables)
  (use-local-map tpl-mode-map)        ; This provides the local keymap
  (setq mode-name "Template")          ; This name goes into the modeline
  (setq major-mode 'tpl-mode)         ; Allow describe-node to find doc
  (setq local-abbrev-table tpl-mode-abbrev-table)
  (set-syntax-table tpl-mode-syntax-table)
  (setq font-lock-keywords tpl-font-lock-keywords)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(tpl-font-lock-keywords nil t))
  (turn-on-font-lock)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'tpl-indent-line)
  (run-hooks 'tpl-mode-hook)          ; Permit customization
  (setq imenu-generic-expression tpl-mode-imenu-generic-expression)
  (speedbar-add-supported-extension ".tpl")
  (setq speedbar-tag-hierarchy-method '(tpl-mode-speedbar-tag-hierarchy))
)

(provide 'tpl-mode)
