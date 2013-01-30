(provide 'throw-window)

(defun reduce (fn initial list)
  (fn initial 
      (if (cdr list)
          (reduce fn (car list) (cdr list)) 
          (car list))))

(defun throw-window-find-bottom-edge ()
  (- (cdr (current-head-dimensions))
     2
     (reduce + 0 
             (mapcar (lambda (w)
                       (let ((p (get-x-property w '_NET_WM_STRUT_PARTIAL))
                             (p1 (get-x-property w '_NET_WM_STRUT)))
                         (if (or p p1)
                             (aref (caddr (or p p1)) 3) 
                             0))) 
                     (managed-windows)))))

;;; XXX OAOO please
(defun throw-window-find-right-edge ()
  (- (car (current-head-dimensions))
     2
     (reduce + 0 
             (mapcar (lambda (w)
                       (let ((p (get-x-property w '_NET_WM_STRUT_PARTIAL))
                             (p1 (get-x-property w '_NET_WM_STRUT)))
                         (if (or p p1)
                             (aref (caddr (or p p1)) 1) 
                             0))) 
                     (managed-windows)))))

(defun throw-window-do-move (w x y)
  (let* ((mousexy (query-pointer))
         (windowxy (window-position w))
         (offset (cons (- (car mousexy) (car windowxy))
                       (- (cdr mousexy) (cdr windowxy)))))
    (move-window-to w x y)
    (warp-cursor-to-window w (car offset) (cdr offset))))

(defun throw-window-right (window)
  (let ((dim (window-frame-dimensions window))
        (xy (window-position window)))
    (throw-window-do-move window 
			  (- (throw-window-find-right-edge) (car dim))
                          (cdr xy))))

(defun throw-window-left (window)
  (let ((xy (window-position window)))
    (throw-window-do-move window 0 (cdr xy))))

(defun throw-window-top (window)
  (let ((xy (window-position window)))
    (throw-window-do-move window (car xy) 0)))

(defun throw-window-bottom (window)
  (let ((dim (window-frame-dimensions window))
        (xy (window-position window)))
    (throw-window-do-move window 
                          (car xy)
                          (- (throw-window-find-bottom-edge) (cdr dim)))))


(define-command 'throw-focused-window-right throw-window-right  #:spec "%f")
(define-command 'throw-focused-window-left throw-window-left  #:spec "%f")
(define-command 'throw-focused-window-top throw-window-top  #:spec "%f")
(define-command 'throw-focused-window-bottom throw-window-bottom  #:spec "%f")

