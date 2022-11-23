;;; ob-d2.el --- org-babel support for d2 evaluation

;; Copyright (C) 2022 Duncan Mac-Vicar P.
;; Copyright (C) 2022 Alexei Nunez

;; Author: Duncan Mac-Vicar P. <duncan@mac-vicar.eu>
;; URL: https://github.com/dmacvicar/ob-d2
;; Keywords: lisp
;; Version: 0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating d2 diagrams. Based on ob-mermaid code.

;;; Requirements:

;; d2 | https://github.com/terrastruct/d2

;;; Code:
(require 'ob)
(require 'ob-eval)

(defvar org-babel-default-header-args:d2
  '((:results . "file") (:exports . "results"))
  "Default arguments for evaluatiing d2 source block.")

(defcustom ob-d2-cli-path nil
  "Path to d2 executable."
  :group 'org-babel
  :type 'string)

(defun org-babel-execute:d2 (body params)
  (let* ((out-file (or (cdr (assoc :file params))
                       (error "d2 requires a \":file\" header argument")))
	     (theme (cdr (assoc :theme params)))
	     (layout (cdr (assoc :layout params)))
         (temp-file (org-babel-temp-file "d2-"))
         (d2c (or ob-d2-cli-path
                  (executable-find "d2")
                  (error "`ob-d2-cli-path' is not set and d2 is not in `exec-path'")))
         (cmd (concat (shell-quote-argument (expand-file-name d2c))
		              (when theme
			            (concat " -t " theme))
   		              (when layout
			            (concat " -l " layout))
                      " " (org-babel-process-file-name temp-file)
                      " " (org-babel-process-file-name out-file))))
    (unless (file-executable-p d2c)
      ;; cannot happen with `executable-find', so we complain about
      ;; `ob-d2-cli-path'
      (error "Cannot find or execute %s, please check `ob-d2-cli-path'" d2c))
    (with-temp-file temp-file (insert body))
    (message "%s" cmd)
    (org-babel-eval cmd "")
    nil))

(provide 'ob-d2)


;;; ob-d2.el ends here
