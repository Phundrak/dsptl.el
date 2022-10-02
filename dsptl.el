;;; dsptl.el --- Dead Simple PlainText Links  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Lucien Cartier-Tilet

;; Author: Lucien Cartier-Tilet <lucien@phundrak.com>
;; Maintainer: Lucien Cartier-Tilet <lucien@phundrak.com>
;; URL: https://github.com/Phundrak/dsptl.el
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (f "0.20"))
;; Keywords: convenience text

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Dead Simple PlainText Links
;;

;;; Code:

(require 'f)
(require 'rx)

(defgroup dsptl ()
  "Dead Simple PlainText Links."
  :group 'text
  :prefix "dsptl-"
  :link '(url-link :tag "GitHub" "https://github.com/Phundrak/dsptl.el")
  :link '(url-link :tag "Gitea" "https://labs.phundrak.com/phundrak/dsptl.el"))

(defcustom dsptl-prefix "file"
  "Prefix used by DSPTL to indicate a link to another file."
  :group 'dsptl
  :type 'string
  :safe #'stringp)

(defun dsptl--list-links ()
  "List all links in the current active directory."
  (let ((files (seq-filter #'f-file-p (f-entries default-directory)))
        (case-fold-search t) ;; case insensitive
        (links nil))
    (dolist (file files links)
      (with-temp-buffer
        ;; FIXME: Don’t do this for binary files
        (insert-file-contents file)
        (while (re-search-forward (rx (literal dsptl-prefix)
                                      (+ space)
                                      (group-n 1 (seq (+ (not space)) alnum))
                                      (? punctuation))
                                  nil t nil)
          (let ((source (file-relative-name file))
                (target      (match-string-no-properties 1)))
            (when (file-regular-p target)
              (push `(,source . ,target) links))))))))

(defun dsptl-display-links-directory ()
  "Display all links found in the current directory."
  (interactive)
  (let ((links (dsptl--list-links)))
    (switch-to-buffer (format "*Links in %s*" default-directory))
    (setq tabulated-list-format [("Source File" 25 t)
                                 ("Target" 25 t)]
          tabulated-list-entries (mapcar (lambda (link)
                                           (list (cdr link) (vector (car link) (cdr link))))
                                         links))
    (tabulated-list-init-header)
    (tabulated-list-print t)
    (read-only-mode 1)))

(provide 'dsptl)
;;; dsptl.el ends here
