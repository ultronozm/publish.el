;;; publish.el --- Convenience functions for pushing files to a git repo  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Paul D. Nelson

;; Author: Paul D. Nelson <nelson.paul.david@gmail.com>
;; Version: 0.1
;; URL: https://github.com/ultronozm/publish.el
;; Package-Requires: ((emacs "29.1") (magit "3.0.0") (f "0.20.0"))
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Convenience functions for pushing files to a git repo.  I use this
;; to publish files in a private git repo to a public repo linked to a
;; web server.
;;
;; To use, set `publish-repo-root' to the root directory of the git
;; repo you want to publish to.  Then, use `publish-file' to publish
;; the current buffer, or `publish-dired-files' to publish marked
;; files in a Dired buffer.
;;
;; Customize `publish-disallowed-unstaged-file-predicate' to disallow
;; publishing if there are unstaged files in the publish repo that
;; match a certain predicate.
;;
;; My use-package declaration:
;;
;; (defun file-is-tex-or-bib (file)
;;   (or (string-suffix-p ".tex" file)
;;       (string-suffix-p ".bib" file)))
;;
;; (use-package publish
;;   :elpaca (:host github :repo "ultronozm/publish.el")
;;   :custom
;;   (publish-repo-root "~/math")
;;   (publish-disallowed-unstaged-file-predicate #'file-is-tex-or-bib))

;;; Code:

(require 'magit)
(require 'f)

(defcustom publish-repo-root "~/publish"
  "Root directory of the publish repo.
This should be the location of a valid git repository."
  :type 'directory
  :group 'publish)

(defcustom publish-disallowed-unstaged-file-predicate nil
  "Predicate to determine if file is disallowed from being unstaged."
  :type 'function
  :group 'publish)

(defun publish--disallowed-unstaged-files-p ()
  "Check if there are disallowed unstaged files."
  (when publish-disallowed-unstaged-file-predicate
    (with-temp-buffer
      (magit-git-insert "diff" "--name-only")
      (goto-char (point-min))
      (let ((unstaged-files (split-string (buffer-string) "\n" t)))
        (cl-some publish-disallowed-unstaged-file-predicate
                 unstaged-files)))))

(defun publish--core (files msg repo)
  "Copy and commit FILES to REPO with commit message MSG."
  ;; check if there are disallowed unstaged changes
  (with-temp-buffer
    (cd repo)
    (cond
     ((publish--disallowed-unstaged-files-p)
      (message "Abort: There are disallowed unstaged changes in the repository."))
     ((magit-anything-staged-p)
      (message "Abort: There are staged changes in the repository."))
     (t
      (dolist (file files)
        (let* ((filename (file-name-nondirectory file))
               (dest-file (concat (file-name-as-directory repo) filename)))
          (copy-file file dest-file t)
          (magit-stage-file filename)))
      (magit-commit-create (list "-m" msg))
      (call-interactively 'magit-push-current-to-upstream)))))

;;;###autoload
(defun publish-file ()
  "Copy and commit FILE to the publish repo.
Interactively read the filename, defaulting to that of the
current buffer."
  (interactive)
  (let* ((default-file (buffer-file-name))
         (file (read-file-name "File: " default-file))
         (filename (file-name-nondirectory file))
         (update-p (file-exists-p (concat (file-name-as-directory publish-repo-root)
                                          filename)))
         (default-msg (concat (if update-p "Update" "Add") " " filename))
         (msg (read-string "Commit message: " default-msg)))
    (publish--core (list file) msg publish-repo-root)))

;;;###autoload
(defun publish-dired-files ()
  "Copy and commit marked files in Dired to the publish repo."
  (interactive
   (let* ((files (dired-get-marked-files))
          (default-msg "Add/update files")
          (msg (read-string "Commit message: " default-msg)))
     (publish--core files msg publish-repo-root))))

(provide 'publish)
;;; publish.el ends here
