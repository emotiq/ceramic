;;; simpler version of Ceramic hello-world without
;;;  lucerne, clack, lack, cl-annot or any of that nonsense.
;;;  Just pure Hunchentoot.

(in-package :cl-user)

#|
How to use this:
Basic instructions are here: http://ceramic.github.io/docs/tutorial.html
(ql:quickload :ceramic)
(ceramic:setup)
[manually uncompress ~/.ceramic/electron.zip and move Electron.app into
~/.ceramic/electron/Electron.app. If there was an Electron.app already there,
trash it.
[above step needed because automatic extraction process does not properly deal
with symlinks inside the Electron.app]
Then run 
(ceramic.setup::prepare-release (ceramic.file::release-directory) :operating-system ceramic.os::*operating-system*)
[above step needed because -- again -- automatic extraction doesn't work and the
prepare-release process has to happen after extraction.]

(ceramic:start)
[load this file]
(run)

To stop, do
(ceramic:stop)
(hunchentoot:stop ceramic-hello-world::*server*)

IF YOU WANT TO CREATE A SELF-CONTAINED BUNDLE, THEN ALSO DO

(ceramic:bundle :ceramic-hello-world)

|#

(ql:quickload :ceramic)
(ql:quickload :cl-who)
(ql:quickload :hunchentoot)

(defpackage ceramic-hello-world
  (:use :cl)
  (:export :run :cl-who))
(in-package :ceramic-hello-world)

(defmacro with-html (&body body)
  `(cl-who:with-html-output-to-string (*standard-output* nil :prologue t)
     ,@body))

(defvar *port* 8000)
(defvar *server* nil)
(defun start-hunch (&key (port *port*))
  (hunchentoot:start (setf *server* (make-instance 'hunchentoot::easy-acceptor
                                      :port port
                                      :access-log-destination nil
                                      :error-template-directory nil
                                      :persistent-connections-p t
                                      ))))

; following isn't working. we're just getting the default Hunchentoot page.
(hunchentoot:define-easy-handler (hello :uri "/")
    ()
  (with-html
    (:html
     (:head (:title "Hunchentoot \"easy\" handler example"))
     (:body
      (:h2 
       " \"Easy\" handler example")
      (:p )
      ))))

(defun run ()
  (let ((window (ceramic:make-window :url (format nil "http://localhost:~D/" *port*))))
    (ceramic:show window)
    (start-hunch :port *port*)))

(ceramic:define-entry-point :ceramic-hello-world ()
  (run))

; (run)