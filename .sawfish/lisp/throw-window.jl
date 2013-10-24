(define-structure throw-window
    (export throw-window-right
            throw-window-left
            throw-window-up
            throw-window-down)
  (open rep sawfish.wm)

  (defun reduce (fn initial list)
    (fn initial 
        (if (cdr list)
          (reduce fn (car list) (cdr list)) 
          (car list))))

  (defun horiz-stops (max-x)
    (let* ((windows (managed-windows))
           (pairs (mapcar (lambda (w)
                            (let ((x (car (window-position w)))
                                  (w (car (window-frame-dimensions w))))
                              (list x (+ x w))))
                          windows)))
      (sort (filter (lambda (x) (<= x max-x))
                    (uniquify-list (cons max-x (apply append pairs))))
            #'<)))
  
  (defun vert-stops ()
    (let* ((windows (managed-windows))
           (far-edge (find-bottom-edge))
           (pairs (mapcar (lambda (w)
                            (let ((y (cdr (window-position w)))
                                  (h (cdr (window-frame-dimensions w))))
                              (list y (+ y h))))
                          windows)))
      (sort (filter (lambda (y) (< y far-edge))
                    (uniquify-list (apply append pairs)) #'<))))
  
  (defun next-stop (stops current)
    (if stops
        (if (> (car stops) current)
            (car stops)
            (next-stop (cdr stops) current))))
  
  (defun previous-stop (stops current)
    (cond ((not (cadr stops)) (car stops))
          ((>= (cadr stops) current) (car stops))
          (t (previous-stop (cdr stops) current))))
  
  (defun find-bottom-edge ()
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
  (defun find-right-edge ()
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
  
  (defun do-move (w x y)
    (let* ((mousexy (query-pointer))
           (windowxy (window-position w))
           (offset (cons (- (car mousexy) (car windowxy))
                         (- (cdr mousexy) (cdr windowxy)))))
      (move-window-to w x y)
      (warp-cursor-to-window w (car offset) (cdr offset))))
  
  (defun throw-window-right (window)
    (let* ((dim (window-frame-dimensions window))
           (xy (window-position window))
           (edge (- (find-right-edge) (car dim)))
           (stop (next-stop (horiz-stops edge) (car xy))))
      (do-move window stop (cdr xy))))
  
  (defun throw-window-left (window)
    (let* ((xy (window-position window))
           (edge (find-right-edge))
           (stop (previous-stop (horiz-stops edge) (car xy))))
      (do-move window stop (cdr xy))))
  
  (defun throw-window-up (window)
    (let ((xy (window-position window)))
      (do-move window (car xy) 0)))
  
  (defun throw-window-down (window)
    (let ((dim (window-frame-dimensions window))
          (xy (window-position window)))
      (do-move window (car xy) (- (find-bottom-edge) (cdr dim)))))
  )

(define-command 'throw-focused-window-right throw-window-right  #:spec "%f")
(define-command 'throw-focused-window-left throw-window-left  #:spec "%f")
(define-command 'throw-focused-window-top throw-window-up  #:spec "%f")
(define-command 'throw-focused-window-bottom throw-window-down #:spec "%f")

