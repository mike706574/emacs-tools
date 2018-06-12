(require 'tools-common)

(defun dot-in-project (f)
  (let ((default-directory (tools-common-find-containing-directory-upwards ".*.csproj")))
    (if default-directory
      (funcall f default-directory)
      (error "Not inside a dotnet project!"))))

(defun dot-command (cmd)
  (dot-in-project (lambda (d) (compile (concat "dotnet " cmd)))))

(defun dot-restore ()
  (interactive)
  (dot-command "restore"))

(defun dot-build ()
  (interactive)
  (dot-command "build"))

(defun dot-suite ()
  (interactive)
  (let ((test-name (file-name-base (buffer-file-name))))
    (dot-command (concat "test --filter \"FullyQualifiedName~" test-name ".\""))))

(defvar dot-grep-history nil)
(defun dot-grep (term)
  (interactive
   (list
    (let* ((default-term (car dot-grep-history))
           (prompt (if (s-blank? default-term)
                     "Search for: "
                     (concat "Search string (default \"" default-term "\"): ")))
           (input (read-from-minibuffer prompt nil nil nil 'dot-grep-history)))
      (if (s-blank? input) default-term input))))
  (dot-in-project
   (lambda (d)
     (grep (concat "grep --color --exclude=\*.{js,map,json,dll,xml} --exclude-dir=.git --exclude-dir=bin -nriH -e \"" term "\" " d)))))

(defvar dot-test-history nil)
(defun dot-test (test)
  (interactive
   (list
    (let* ((default-term (thing-at-point 'symbol))
           (prompt (if (s-blank? default-term)
                     "Run test: "
                     (concat "Run test (default \"" default-term "\"): ")))
           (input (read-from-minibuffer prompt nil nil nil 'mvn-test-history)))
      (if (s-blank? input) default-term input))))
  (dot-in-project
   (lambda (d)
     (let ((test-name (file-name-base (buffer-file-name))))
       (compile (concat "dotnet test --filter \"FullyQualifiedName~"  test-name "." test "\""))))))
