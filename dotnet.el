(require 'tools-common)

(defun dotnet-in-project (f)
  (let ((default-directory (tools-common-find-containing-directory-upwards "*.sln")))
    (if default-directory
      (funcall f default-directory)
      (error "Not inside a dotnet project!"))))

(defun dotnet-command ()
  (dotnet-in-project (lambda (d) (compile (concat "dotnet " cmd)))))

(defun dotnet-restore ()
  (interactive)
  (dotnet-command "restore"))

(defun dotnet-build ()
  (interactive)
  (dotnet-command "build"))

(defvar dotnet-grep-history nil)
(defun dotnet-grep (term)
  (interactive
   (list
    (let* ((default-term (car dotnet-grep-history))
           (prompt (if (s-blank? default-term)
                     "Search for: "
                     (concat "Search string (default \"" default-term "\"): ")))
           (input (read-from-minibuffer prompt nil nil nil 'dotnet-grep-history)))
      (if (s-blank? input) default-term input))))
  (dotnet-in-project
   (lambda (d)
     (grep (concat "grep --color --exclude=\*.{js,map,json} --exclude-dir=.git --exclude-dir=target -nriH -e \"" term "\" " d)))))
