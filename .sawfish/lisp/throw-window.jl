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

  (defun x-coord (pair) (car pair))
  (defun y-coord (pair) (cdr pair))

  (defun stops-for (coord far-edge)
    (let* ((windows (managed-windows))
           (pairs (mapcar
                   (lambda (w)
                     (let ((offset (coord (window-position w)))
                           (size (coord (window-frame-dimensions w))))
                       (list offset (+ offset size))))
                   windows)))
      (sort (filter (lambda (x) (<= x far-edge))
                    (uniquify-list (cons far-edge (apply append pairs))))
            #'<)))

  (defun horiz-stops (max-x) (stops-for #'x-coord max-x))
  (defun vert-stops (max-y) (stops-for #'y-coord max-y))
  
  (defun next-stop (stops current)
    (if stops
        (if (> (car stops) current)
            (car stops)
            (next-stop (cdr stops) current))))
  
  (defun previous-stop (stops current)
    (cond ((not (cadr stops)) (car stops))
          ((>= (cadr stops) current) (car stops))
          (t (previous-stop (cdr stops) current))))
  
  (defun previous-stop-for (fn point)
    (let* ((value (fn point))
           (stops (stops-for fn value)))
      (previous-stop stops value)))

  (defun find-far-edge (co-ord property-index)
    (- (co-ord (current-head-dimensions))
       2
       (reduce + 0 
               (mapcar (lambda (w)
                         (let ((p (get-x-property w '_NET_WM_STRUT_PARTIAL))
                               (p1 (get-x-property w '_NET_WM_STRUT)))
                           (if (or p p1)
                               (aref (caddr (or p p1)) 3) 
                               0))) 
                       (managed-windows)))))
  
  (defun find-bottom-edge () (find-far-edge y-coord 3))
  (defun find-right-edge () (find-far-edge x-coord 1))

  (defun do-move (w x y)
    (let* ((mousexy (query-pointer))
           (frame-offset (window-frame-offset w))
           (windowxy (window-position w))
           (offset (cons (+ (car frame-offset) (- (car mousexy) (car windowxy)))
                         (+ (cdr frame-offset) (- (cdr mousexy) (cdr windowxy))))))
      (move-window-to w x y)
      (warp-cursor-to-window w (car offset) (cdr offset))
      (raise-window w)))
  
  (defun throw-window-right (window)
    (let* ((dim (window-frame-dimensions window))
           (xy (window-position window))
           (edge (- (find-right-edge) (x-coord dim)))
           (stop (next-stop (stops-for #'x-coord edge) (x-coord xy))))
      (do-move window stop (cdr xy))))

  (defun throw-window-down (window)
    (let* ((dim (window-frame-dimensions window))
           (xy (window-position window))
           (edge (- (find-bottom-edge) (y-coord dim)))
           (stop (next-stop (stops-for #'y-coord edge) (y-coord xy))))
      (do-move window (car xy) stop)))

  (defun throw-window-left (window)
    (let* ((xy (window-position window))
           (new-x (previous-stop-for #'x-coord xy)))
      (do-move window new-x (cdr xy))))

  (defun throw-window-up (window)
    (let* ((xy (window-position window))
           (new-y (previous-stop-for #'y-coord xy)))
      (do-move window (car xy) new-y)))
  
  (define-command 'throw-focused-window-right throw-window-right  #:spec "%f")
  (define-command 'throw-focused-window-left throw-window-left  #:spec "%f")
  (define-command 'throw-focused-window-top throw-window-up  #:spec "%f")
  (define-command 'throw-focused-window-bottom throw-window-down #:spec "%f")
)
