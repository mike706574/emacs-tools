(require 'tools-common)

(defun mvn-in-project (f)
  (let ((default-directory (tools-common-find-containing-directory-upwards "pom.xml")))
    (if default-directory
      (funcall f default-directory)
      (error "Not inside a Maven project!"))))

(defun mvn-command (cmd)
  (mvn-in-project (lambda (d) (compile (concat "mvn " cmd)))))

(defun mvn-build ()
  (interactive)
  (mvn-command "clean install"))

(defun mvn-dependency-updates ()
  (interactive)
  (mvn-command "versions:display-dependency-updates"))

(defun mvn-plugin-updates ()
  (interactive)
  (mvn-command "versions:display-plugin-updates"))

(defun mvn-property-updates ()
  (interactive)
  (mvn-command "versions:display-properties-updates"))

(defun mvn-tree ()
  (interactive)
  (mvn-command "dependency:tree"))

(defun mvn-tree-verbose ()
  (interactive)
  (mvn-command "dependency:tree -Dverbose=true"))

(defun mvn-all-tests ()
  (interactive)
  (mvn-command "test"))

(defun mvn-suite ()
  (interactive)
  (let ((test-name (file-name-base (buffer-file-name))))
    (mvn-command (concat "-Dtest=" test-name " test"))))

(defun mvn-compile ()
  (interactive)
  (mvn-command "compile"))

(defvar mvn-test-history nil)
(defun mvn-test (test)
  (interactive
   (list
    (let* ((default-term (thing-at-point 'symbol))
           (prompt (if (s-blank? default-term)
                     "Run test: "
                     (concat "Run test (default \"" default-term "\"): ")))
           (input (read-from-minibuffer prompt nil nil nil 'mvn-test-history)))
      (if (s-blank? input) default-term input))))
  (mvn-in-project
   (lambda (d)
     (let ((test-name (file-name-base (buffer-file-name))))
       (compile (concat "mvn -Dtest=" test-name "#" test " test"))))))

(defvar mvn-grep-history nil)
(defun mvn-grep (term)
  (interactive
   (list
    (let* ((default-term (car mvn-grep-history))
           (prompt (if (s-blank? default-term)
                     "Search for: "
                     (concat "Search string (default \"" default-term "\"): ")))
           (input (read-from-minibuffer prompt nil nil nil 'mvn-grep-history)))
      (if (s-blank? input) default-term input))))
  (mvn-in-project
   (lambda (d)
     (grep (concat "grep --color --exclude-dir=.git --exclude-dir=target --exclude-dir=node_modules -nriH -e \"" term "\" " d)))))

(defvar mvn-java-grep-history nil)
(defun mvn-java-grep (term)
  (interactive
   (list
    (let* ((default-term (car mvn-java-grep-history))
           (prompt (if (s-blank? default-term)
                     "Search for: "
                     (concat "Search string (default \"" default-term "\"): ")))
           (input (read-from-minibuffer prompt nil nil nil 'mvn-java-grep-history)))
      (if (s-blank? input) default-term input))))
  (mvn-in-project
   (lambda (d)
     (grep (concat "grep --color --exclude-dir=.git --exclude-dir=target --exclude-dir=node_modules --include=*.java -nriH -e \"" term "\" " d)))))
