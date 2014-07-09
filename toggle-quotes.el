;;; toggle-quotes.el --- Toggle between single and double quoted string

;; Copyright (C) 2014 Jim Tian

;; Author: Jim Tian <tianjin.sc@gmail.com>
;; Version: 0.1.0

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; `toggle-quotes' toggles the single-quoted string at point to
;; double-quoted one, and vice versa.
;;
;;; Code:

(defun toggle-quotes ()
  "Toggle between single quotes and double quotes."
  (interactive)
  (when (tq/string-at-point-p)
    (let ((str (tq/string-at-point))
          (p (point)))
      (goto-char (tq/string-start-position))
      (kill-sexp)
      (insert (tq/process str major-mode))
      (goto-char p))))

(defun tq/string-at-point-p ()
  "Return nil unless point is inside a string."
  (nth 3 (syntax-ppss)))

(defun tq/string-start-position ()
  "Return the start position of the string at point."
  (nth 8 (syntax-ppss)))

(defun tq/string-positions ()
  "Return the start and end position of the string at point."
  (let ((beg (tq/string-start-position)))
    (save-excursion
      (goto-char beg)
      (forward-sexp 1)
      (cons beg (point)))))

(defun tq/string-at-point ()
  "Return string at point."
  (let* ((pos (tq/string-positions))
         (beg (car pos))
         (end (cdr pos)))
    (buffer-substring-no-properties beg end)))

(defun tq/process (string mode)
  "Process STRING in the context of MODE."
  (with-temp-buffer
    (funcall mode)
    (insert string)
    (let* ((old-quote (string (char-after (point-min))))
	   (new-quote (tq/other-quote old-quote)))
      (tq/remove-quote old-quote)
      (tq/insert-quote new-quote)
      (buffer-substring-no-properties (point-min) (point-max)))))

(defun tq/other-quote (quote)
  "Return the opposite quote of QUOTE."
  (if (string= quote "'") "\"" "'"))

(defun tq/remove-quote (quote)
  "Remove and unescape the old QUOTE."
  (goto-char (point-min))
  (delete-char (length quote))
  (goto-char (point-max))
  (delete-char (- (length quote)))
  (tq/unescape quote))

(defun tq/insert-quote (quote)
  "Insert and escape the new QUOTE."
  (goto-char (point-min))
  (insert quote)
  (goto-char (point-max))
  (insert quote)
  (tq/escape))

(defun tq/unescape (quote)
  "Unescape QUOTE in current buffer."
  (goto-char (point-min))
  (while (search-forward (concat "\\" quote) nil t)
    (replace-match "")
    (insert quote)))

(defun tq/escape ()
  "Escape the new quote in current buffer."
  (goto-char (point-min))
  (forward-sexp)
  (unless (eq (point) (point-max))
    (backward-char)
    (insert "\\")
    (tq/escape)))

(provide 'toggle-quotes)
;;; toggle-quotes.el ends here
