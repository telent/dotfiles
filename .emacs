
;; ***********************************************************************
;; Miscellaneous

(require 'cl)				; civilisation
(global-unset-key "\C-z") 		; while i wean myself from ILISP
(setq wq "You're not using vi!")	; sigh.  Whose idea was it to have
					; ESC : as eval-expression, then?
(setq load-path
      (list* ; "~/src/cl-net/slime/" "~/src/cl-net/slime/contrib/" 
	     "~/emacs-lisp" "~/emacs-lisp/egg"  "~/src/gnus-5.10.6/lisp/"
	     load-path))

(require 'package)
(add-to-list 'package-archives 
	     '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)

(setq Info-default-directory-list
      (cons (expand-file-name "~/emacs-lisp/gnus/texi/")
	    Info-default-directory-list))

(put 'eval-expression 'disabled nil)
(set-variable (quote next-line-add-newlines) nil)
(display-time)
(and (fboundp 'display-battery) (display-battery))
(load "jka-compr")

(setq strip-trailing-whitespace-modes ())

(defun auto-strip-trailing-whitespace (&optional arg interactive)
  (and (member major-mode strip-trailing-whitespace-modes)
       (delete-trailing-whitespace)))

(add-hook 'before-save-hook 'auto-strip-trailing-whitespace)

(font-lock-mode 1)
(setq tramp-default-method "ssh")

;; ***********************************************************************
;; VC stuff

;; the \ stops RCSification of .emacs from expanding these keywords on
;; checkout ...
(setq vc-header-alist '((SCCS "%W%") (RCS "$Header\$") (CVS "$Header\$")))


;; ***********************************************************************
;; Key bindings

(define-key global-map [f9] 'next-error)
(define-key global-map [f10] 'goto-line)
;(define-key global-map [f11] 
;  '(lambda () (interactive nil)
;    (let ((s (shell-command-to-string "echo `date +%s` + 2208988800 | bc ")))
;      (find-file (format "/ssh:telent@ww.telent.net:doc/telent/htdocs/diary/dat;a/%s.html";
;			 (subseq s 0 (1- (length s)))))
;      (setf sgml-parent-document '("HEADER.inc" "HTML" "BODY" "BODY" ())))))

(define-key global-map [f12] 'compile)

(define-key global-map "\C-c\C-id" 
  '(lambda () (interactive nil)   (insert (current-time-string))))
(define-key global-map "\C-c\C-if"
  '(lambda () (interactive nil)   (insert (buffer-file-name))))
(define-key global-map "\C-c\C-sf" 
  '(lambda () (interactive nil) (message (buffer-file-name))))

(define-key global-map [home] 'beginning-of-line)

;; This *should* work sensibly.  On the console, backspace produces DEL, delete 
;; produces ESC [ 3 ~ and is mapped to [delete] by term/lk201.el
;; In X, I'll have backspace produce Backspace and delete produce Delete, and 
;; everything should be both hunky and dory

;; There is a reason that this uses global-set-key.  We want it to work in
;; the minbuffer too, and define-key global-map apparently doesn't

(global-set-key [delete] 'delete-char)


;; ***********************************************************************
;; comint

(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)

;; ***********************************************************************
;; html

;; html-mode is immensely irritating, to be frank

(setq auto-mode-alist (cons '("\\.html\\'" . sgml-mode) auto-mode-alist))
(setq sgml-indent-step 0)
(setq sgml-indent-data nil)

(setq auto-mode-alist (cons '("\\.scss\\'" . css-mode) auto-mode-alist))

;; ***********************************************************************
;; Text mode

(add-hook 'text-mode-hook
	  '(lambda () (auto-fill-mode 1)))


;; ***********************************************************************
;; Ruby

(add-hook 'ruby-mode-hook
	  '(lambda () 
	     (define-key ruby-mode-map [?\s-.] 'ruby-send-definition-and-go)))

(pushnew 'ruby-mode strip-trailing-whitespace-modes)
(pushnew 'feature-mode strip-trailing-whitespace-modes)


;; ***********************************************************************
;; Scheme and lisp modes


(setq slime-multiprocessing t)

(setq lisp-indent-function 'common-lisp-indent-function)

(setq scheme-program-name "guile")

(setq common-lisp-hyperspec-root "file:///usr/share/doc/hyperspec/")
(setq common-lisp-hyperspec-symbol-table "/usr/share/doc/hyperspec/Data/Map_Sym.txt")

(eval-after-load 'clojure-mode
  '(define-clojure-indent
     (describe 'defun)
     (testing 'defun)
     (given 'defun)
     (using 'defun)
     (with 'defun)
     (it 'defun)
     (do-it 'defun)))

(pushnew 'clojure-mode strip-trailing-whitespace-modes)
(add-hook 'lisp-mode-hook '(lambda () (setq indent-tabs-mode nil)))

;; ***********************************************************************
;; (C|C++) Modes

(add-hook 'c-mode-common-hook
	  '(lambda () 
	     (c-set-offset 'block-open '-)
	     (c-set-offset 'substatement-open '0)
	     (c-toggle-auto-state -1)
	     (c-toggle-hungry-state -1)
	     (setq c-basic-offset 4)))

(add-hook 'java-mode-hook (lambda () (setq c-basic-offset 4)))
(setq c-basic-offset 4)

;; ***********************************************************************
;; Caml mode

(setq auto-mode-alist (cons '("\\.ml[iylp]?" . caml-mode) auto-mode-alist))
(autoload 'caml-mode "caml" "Major mode for editing Caml code." t)
(autoload 'run-caml "inf-caml" "Run an inferior Caml process." t)
(autoload 'camldebug "camldebug" "Run the Caml debugger." t)
(add-hook 'caml-mode-hook '(lambda () (setq indent-tabs-mode nil)))


;; ***********************************************************************
;; Faces

(set-cursor-color "BlueViolet")
(add-hook 'emacs-lisp-mode-hook 'turn-on-font-lock)
(add-hook 'java-mode-hook 'turn-on-font-lock)

(setq browse-url-netscape-program "firefox")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 90 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-file-name-transforms (quote (("\\`/[^/]*:\\(.+/\\)*\\(.*\\)" "/home/dan/.emacs.d/auto-save-files/\\2"))))
 '(browse-url-browser-function (quote browse-url-netscape))
 '(canlock-password "c504963db2bafd718ff487d9217561e4d030710f")
 '(case-fold-search t)
 '(clojure-swank-command "lein2 jack-in %s")
 '(current-language-environment "ASCII")
 '(display-time-mode t)
 '(global-font-lock-mode t nil (font-lock))
 '(gnus-visible-headers (quote ("^From:" "^Newsgroups:" "^Subject:" "^Date:" "^Followup-To:" "^Reply-To:" "^Organization:" "^Summary:" "^Keywords:" "^To:" "^[BGF]?Cc:" "^Mail-Copies-To:" "^Apparently-To:" "^Approved:")))
 '(hyperspec-root-url "file://localhost/usr/local/doc/HyperSpec/")
 '(hyperspec-symbol-table "/usr/local/doc/HyperSpec/Data/Symbol-Table.text")
 '(mail-user-agent (quote message-user-agent))
 '(message-user-organization "Telent Netowrks - network solutions for poor typists")
 '(mm-automatic-display (quote ("text/plain" "text/enriched" "text/richtext" "te xt/x-vcard" "image/.*" "message/delivery-status" "multipart/.*" "message/rfc822" "text/x-patch" "application/pgp-signature" "application/emacs-lisp")))
 '(pgg-passphrase-cache-expiry 300)
 '(pgg-query-keyserver t)
 '(ps-lpr-command "lp")
 '(send-mail-function (quote mailclient-send-it))
 '(shell-prompt-pattern "^[^#$%>
]*[#$%>;] *")
 '(slime-conservative-indentation nil)
 '(smiley-regexp-alist nil)
 '(uce-mail-reader (quote gnus)))


;;; ange-ftp passive mode
(add-hook `ange-ftp-process-startup-hook
	  (lambda () (let ((result (cdr (ange-ftp-raw-send-cmd
					 proc "passive"
					 "Setting passive mode..." nil))))
		       (if (string-match "\?\|refused" result)
			   (ange-ftp-error
			    host user (concat "Passive mode failed: "
					      result))))))
(tool-bar-mode 0)
(scroll-bar-mode -1)
(blink-cursor-mode 0)

(put 'downcase-region 'disabled nil)

