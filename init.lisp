;; -*- mode:lisp -*-

(in-package :lem-user)

;; (load-theme "emacs-light")

(define-key *global-keymap* "M-@" 'mark-sexp)
(define-key *global-keymap* "M-Escape" 'mark-sexp)
(define-key *global-keymap* "M-O" 'previous-window)
(define-key *global-keymap* "M-t" 'switch-to-last-focused-window)

(lem-lisp-syntax:set-indentation ":and" 'lem-lisp-syntax.indent::default-indent)
(lem-lisp-syntax:set-indentation ":or" 'lem-lisp-syntax.indent::default-indent)
(lem-lisp-syntax:set-indentation "with-mock-functions" (lem-lisp-syntax.indent:get-indentation "flet"))

(pushnew (cons ".rb$" 'lem-python-mode:python-mode) *auto-mode-alist* :test #'equal)
(pushnew (cons ".php$" 'lem-js-mode:js-mode) *auto-mode-alist* :test #'equal)

(add-hook lem-js-mode:*js-mode-hook*
          (lambda ()
            (setf (variable-value 'tab-width) 2)))

(pushnew (cons "\\.cpp$" 'lem-c-mode:c-mode) *auto-mode-alist* :test #'equal)
(pushnew (cons "\\.cc$" 'lem-c-mode:c-mode) *auto-mode-alist* :test #'equal)
(pushnew (cons "\\.hpp$" 'lem-c-mode:c-mode) *auto-mode-alist* :test #'equal)

(lem-lisp-syntax:set-indentation ":and" 'lem-lisp-syntax.indent::default-indent)
(lem-lisp-syntax:set-indentation ":or" 'lem-lisp-syntax.indent::default-indent)
(lem-lisp-syntax:set-indentation "with-mock-functions" (lem-lisp-syntax.indent:get-indentation "flet"))

(define-command previous-window () ()
  (other-window -1))

(define-command tri () ()
  (delete-other-windows)
  (let ((width (round (display-width) 3))
        (window (current-window)))
    (split-window-horizontally (current-window) width)
    (other-window 1)
    (split-window-horizontally (current-window) width)
    (setf (current-window) window)))

(define-command tetra () ()
  (delete-other-windows)
  (let ((width (round (display-width) 4))
        (window (current-window)))
    (split-window-horizontally (current-window) width)
    (other-window 1)
    (split-window-horizontally (current-window) width)
    (other-window 1)
    (split-window-horizontally (current-window) width)
    (setf (current-window) window)))

(pushnew (cons "\\.clj$" 'lem-lisp-mode:lisp-mode) *auto-mode-alist* :test #'equal)
(pushnew (cons "\\.cljs$" 'lem-lisp-mode:lisp-mode) *auto-mode-alist* :test #'equal)
(pushnew (cons "\\.cljc$" 'lem-lisp-mode:lisp-mode) *auto-mode-alist* :test #'equal)

(defun cl-user::pdebug (x)
  (with-open-file (out "~/lem-test.log"
                       :direction :output
                       :if-exists :append
                       :if-does-not-exist :create)
    (prin1 x out)
    (terpri out)
    x))

(define-command lisp-toggle-feature-highlight () ()
  (setf lem-lisp-mode::*enable-feature-highlight*
        (not lem-lisp-mode::*enable-feature-highlight*))
  (lem-lisp-mode:lisp-mode))

(define-key lem-lisp-mode:*lisp-mode-keymap* "C-c C-f" 'lisp-toggle-feature-highlight)

(defun root-directory-p (directory)
  (uiop:pathname-equal (uiop:pathname-parent-directory-pathname directory)
                       directory))

(defun find-git-root (directory)
  (labels ((recursive (directory)
             (dolist (pathname (uiop:subdirectories directory))
               (when (ppcre:scan "/\\.git/$" (namestring pathname))
                 (return-from recursive directory)))
             (unless (root-directory-p directory)
               (recursive (uiop:pathname-parent-directory-pathname directory)))))
    (recursive (uiop:pathname-directory-pathname directory))))

(defun escape-string (string)
  (with-output-to-string (out)
    (write-char #\' out)
    (loop :for c :across string
          :do (when (char= c #\')
                (write-char #\\ out))
              (write-char c out))
    (write-char #\' out)))

(defun prompt-for-search-string ()
  (prompt-for-string "Search In Project: "
                     :initial-value (lem::current-kill-ring)
                     :test-function (lambda (string)
                                      (< 0 (length string)))
                     :history-symbol 'prompt-for-search-string))

(define-command project-find (s) ((prompt-for-search-string))
  (alexandria:when-let (root (find-git-root (buffer-directory)))
    (lem.grep:grep (format nil "git grep -nH ~A" (escape-string s))
                   root)))

(define-key *global-keymap* "M-F" 'project-find)

;; (lem:set-attribute 'lem-ncurses::popup-border-color
;;                    :foreground "#888888"
;;                    :background nil
;;                    :reverse-p t)

;; (lem:set-attribute 'lem:modeline
;;                    :background "#666666"
;;                    :foreground "white")

;; (lem:set-attribute 'lem:modeline-inactive
;;                    :background "#444444"
;;                    :foreground "white")

;; (lem:set-attribute 'lem::modeline
;;                    :background "#E0E0E0" :foreground "black")

(define-command c-format () ()
  (filter-buffer (format nil "clang-format ~A" (buffer-filename (current-buffer)))))

(defmacro debug-print (string)
  `(%debug-print (sb-c:source-location) ,string))

(defun %debug-print (source-location message)
  (format t "~A:~A:~A~&"
          (sb-c:definition-source-location-toplevel-form-number source-location)
          (sb-c:definition-source-location-form-number source-location)
          message))

(define-key *global-keymap* "F12" 'test001)
(define-key *global-keymap* "F10" 'test002)

(define-command test001 () ()
  #+(or)
  (display-popup-message "hello"
                         :timeout 1
                         :gravity (make-instance 'lem.popup-window::gravity-topright))
  (prompt-for-string "test: "
                     :gravity :topright))

(define-command test002 () ()
  (log:info ">>>"
            (with-output-to-string (*standard-output*)
              (describe (current-window)))))
