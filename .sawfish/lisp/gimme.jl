;; gimme.jl -- fast window access keyboard accelerators -*- lisp -*-
;; $Id: gimme.jl,v 1.1 2002/04/15 08:38:57 ssb Exp $
;;
;; Copyright (C) 2000, 2001, 2002 Stig Sæther Bakken <stig@php.net>
;;
;; This file is not part of sawfish.
;;
;; Gimme is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; gimme is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with gimme; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;
;; Changelog:
;;
;; 2009-01-17 Teika Kazura
;;   * (require 'sawfish.wm.commands.x-cycle) is added.
;;   * Null command string bug fixed.
;; 2009-01-24 Teika Kazura
;;   * Fixed focusing and warping part, by deleting obsolete variables.
;;   * Fixed usage intruction; added 'load'
;;   * More require's.
;;   * Encoding: iso-8859-1 -> UTF-8
;;
;; How to use:
;;
;; 1. Save this file as ~/.sawfish/gimme.jl
;;
;; 2. Add the following to ~/.sawfishrc:
;;    (require 'gimme) or (load "~/.sawfish/gimme")
;;
;; 3. Customize your bindings to use some of the gimme functions, for
;;    example:
;;
;;      M-S-e gimme-exact-class "Emacs" "emacs"
;;
;;    When you hit meta+shift+e, sawfish will focus to the first found
;;    Emacs window, switching workspaces if necessary, or run "emacs"
;;    in the background if not found.
;;
;; Configure sawfish with the programs you use every day, disconnect
;; your mouse and see how long you can do without it.
;;
(provide 'gimme)

(require 'sawfish.wm.windows)
(require 'sawfish.wm.workspace)
(require 'sawfish.wm.commands.x-cycle)
(require 'sawfish.wm.focus)
(require 'sawfish.wm.state.shading)

;; customization options

(defgroup gimme "Gimme" :group focus)

(defcustom gimme-ignore-iconified-windows t
  "Ignore windows that are iconified."
  :group (focus gimme)
  :type boolean)

;; code

(define (ssb-find-windows-by what query info-func match-func)
  "Returns a list of windows whose class or name matches QUERY."
  (filter (lambda (win)
	    (and
	     (or (not (window-get win 'iconified))
		 (not gimme-ignore-iconified-windows))
	     (match-func query (info-func win))))
	  (managed-windows)))

(define (ssb-select-window-by what name)
  "Finds a single window based on name or class.  If several matching
windows exist, a single one is selected: if the currently focused
window matches, the next window is selected (wrapping if necessary),
if not the first matching window is selected. WHAT can be one of
`class', `exact-class', `name' or `exact-name'."
  (let* ((info-func
	  (if (or (eq what 'class) (eq what 'exact-class))
	      (lambda (w) (aref (get-x-text-property w 'WM_CLASS) 1))
	    window-name))
	 (match-func
	  (if (or (eq what 'exact-class) (eq what 'exact-name))
	      string=
	    string-match))
	 (current (info-func (input-focus)))
	 (windows (ssb-find-windows-by 'what name info-func match-func))
	 (loopwins windows))
    (catch 'selected
      (when (null windows)
	(throw 'selected nil))
      (when (string-match name current)
	(while loopwins
	  (when (and (eq (car loopwins) (input-focus))
		     (cdr loopwins))
	    (throw 'selected (car (cdr loopwins))))
	  (set 'loopwins (cdr loopwins))))
      (throw 'selected (car windows)))))

(define (ssb-goto-window win)
  (when (not (window-get win 'sticky))
    (select-workspace (nearest-workspace-with-window win current-workspace)))
  (when (window-get win 'iconified)
    (show-window win))
  (when cycle-raise-windows
    (raise-window win))
  (warp-pointer-if-necessary win)
  (when (window-get win 'shaded)
    (unshade-window win))
  (when (window-really-wants-input-p win)
    (set-input-focus win)))

(define (gimme what name #!optional command)
  (let*
      ((win (if (eq what 'window)
		name (ssb-select-window-by what name))))
    (if win
	(ssb-goto-window win)
      (if (and command
	       (not (equal command "")))
	  (system (concat command " &"))))))

(define (gimme-name name #!optional command)
  "Focus on a window with NAME as part of its name/title, or start PROGRAM.
If focus is already on a matching window, cycle to the next"
  (gimme 'name name command))

(define-command 'gimme-name gimme-name
  #:spec "sWindow name:\nsCommand:"
  #:type `(and (labelled ,(_ "Window name:") string)
	       (labelled ,(_ "Command:") string)))

(define (gimme-class class #!optional command)
  "Focus on a window with CLASS as part of its class, or start PROGRAM.
If focus is already on a matching window, cycle to the next"
  (gimme 'class class command))

(define-command 'gimme-class gimme-class
  #:spec "sWindow class:\nsCommand:"
  #:type `(and (labelled ,(_ "Window class:") string)
	       (labelled ,(_ "Command:") string)))

(define (gimme-exact-name name #!optional command)
  "Focus on a window with NAME as its exact name/title, or start PROGRAM.
If focus is already on a matching window, cycle to the next"
  (gimme 'exact-name name command))

(define-command 'gimme-exact-name gimme-exact-name
  #:spec "sWindow name:\nsCommand:"
  #:type `(and (labelled ,(_ "Window name:") string)
	       (labelled ,(_ "Command:") string)))

(define (gimme-exact-class class #!optional command)
  "Focus on a window with CLASS as its exact class, or start PROGRAM.
If focus is already on a matching window, cycle to the next"
  (gimme 'class class command))

(define-command 'gimme-exact-class gimme-exact-class
  #:spec "sWindow class:\nsCommand:"
  #:type `(and (labelled ,(_ "Window class:") string)
	       (labelled ,(_ "Command:") string)))

