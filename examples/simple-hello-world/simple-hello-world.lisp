;;; simpler version of Ceramic hello-world without
;;;  lucerne, clack, lack, cl-annot or any of that nonsense.
;;;  Just pure Hunchentoot.

;;; NOTE: Ceramic/Electron caches its output at ~/Library/Application Support/Ceramic/Electron.
;;;       You might need to blow away those files if you make changes here.

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


[load this file]
(run)

To stop, do
(ceramic:stop)
(hunchentoot:stop ceramic-hello-world::*server*)

IF YOU WANT TO CREATE A SELF-CONTAINED BUNDLE, THEN ALSO DO

; following still uses cl-annot, because jonathan needs it and we need json capability.
; cl-annot causes a reader macro conflict with #P

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

(hunchentoot:define-easy-handler (hello :uri "/")
    ()
  (with-html
    (:html
     (:head (:title "Ceramic example"))
     (:body
      (:h2 
       "Hello Ceramic!")
      (:p )
      ))))

(defun run ()
  (ceramic:start)
  (start-hunch :port *port*)
  (let ((window (ceramic:make-window :url (format nil "http://localhost:~D/" *port*))))
    (ceramic:show window)
    ))

(ceramic:define-entry-point :ceramic-hello-world ()
  (run))

; (run)