;;; publish.el --- Convenience functions for pushing files to a git repo  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Paul D. Nelson

;; Author: Paul D. Nelson <nelson.paul.david@gmail.com>
;; Version: 0.1
;; URL: https://github.com/ultronozm/publish.el
;; Package-Requires: ((emacs "29.1") (magit "3.0.0"))
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

;; Convenience functions for pushing files to a git repo.

;;; Code:

(require 'magit)
(require 'f)

(defcustom publish-repo-root "~/publish"
  "Root directory of the publish repo."
  :type 'directory
  :group 'publish)


(provide 'publish)
;;; publish.el ends here
