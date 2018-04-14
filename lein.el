(require 'tools-common)

(defun lein-in-project (f)
  (let ((default-directory (tools-common-find-containing-directory-upwards "project.clj")))
    (if default-directory
      (funcall f default-directory)
      (error "Not inside a Leiningen project!"))))

(defun lein-command (cmd)
  (lein-in-project (lambda (d) (compile (concat "lein " cmd)))))

(defun lein-build ()
  (interactive)
  (lein-command "do clean, test, install"))

(defun lein-tree ()
  (interactive)
  (lein-command "deps :tree"))

(defun lein-ancient ()
  (interactive)
  (lein-command "ancient"))

(defun lein-ancient-plugins ()
  (interactive)
  (lein-command "ancient :plugins"))

(defun lein-eastwood ()
  (interactive)
  (lein-command "eastwood"))

(defun lein-eastwood-unused-ns ()
  (interactive)
  (lein-command "eastwood '{:linters [:unused-namespaces]}'"))

(defun lein-kibit ()
  (interactive)
  (lein-command "kibit"))

(defun lein-yagni ()
  (interactive)
  (lein-command "yagni"))

(defvar lein-grep-history nil)
(defun lein-grep (term)
  (interactive
   (list
    (let* ((default-term (car lein-grep-history))
           (prompt (if (s-blank? default-term)
                     "Search for: "
                     (concat "Search string (default \"" default-term "\"): ")))
           (input (read-from-minibuffer prompt nil nil nil 'lein-grep-history)))
      (if (s-blank? input) default-term input))))
  (lein-in-project
   (lambda (d)
     (grep (concat "grep --color --exclude=\*.{js,map,json} --exclude-dir=.git --exclude-dir=target -nriH -e \"" term "\" " d)))))
