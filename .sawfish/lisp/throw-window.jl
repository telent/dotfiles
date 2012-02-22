(provide 'throw-window)

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
			  (- (car (current-head-dimensions)) (car dim))
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
			  (- (cdr (current-head-dimensions)) (cdr dim)))))


(define-command 'throw-focused-window-right throw-window-right  #:spec "%f")
(define-command 'throw-focused-window-left throw-window-left  #:spec "%f")
(define-command 'throw-focused-window-top throw-window-top  #:spec "%f")
(define-command 'throw-focused-window-bottom throw-window-bottom  #:spec "%f")

