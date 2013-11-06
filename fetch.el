;;; fetch.el --- Fetch and unpack resources

;; Author: Christian 'crshd' Brassat <christian.brassat@gmail.com>
;; Version: 0.0.1
;; URL: https://github.com/crshd/fetch.el

;; COPYRIGHT (C) 2013, Christian Brassat
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; Redistributions of source code must retain the above copyright notice, this
;; list of conditions and the following disclaimer.
;;
;; Redistributions in binary form must reproduce the above copyright notice,
;; this list of conditions and the following disclaimer in the documentation
;; and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE. 

;; This file is NOT part of Emacs

;;; Commentary:

;; This package is a port of the Nettuts+ Fetch plugin for Sublime Text
;; (http://net.tutsplus.com/articles/news/introducing-nettuts-fetch/)
;;
;; This package allows you to quickly download and unpack external resources and
;; libraries to include in your project.
;;
;; To add entries to the lookup tables, append the fetch-package-alist like so:
;;
;; (add-to-list 'fetch-package-alist
;;              '("name" . "url") t)
;;
;; After the list is populated, you can fetch the resources using
;; M-x fetch-resource
;;
;; The temporary download directory can be adjusted by setting the
;; fetch-download-location variable.

(require 'url)

(defvar fetch-download-location "/tmp/emacs-fetch/"
  "Temporary location where the resource files are saved")

(setq fetch-package-alist
  '(("jquery"    . "http://code.jquery.com/jquery.min.js")
    ("normalize" . "https://raw.github.com/necolas/normalize.css/master/normalize.css")
    ("bootstrap" . "https://github.com/twbs/bootstrap/releases/download/v3.0.1/bootstrap-3.0.1-dist.zip")))

(defun download-resource (url)
  "Download the resource package from url"
  (make-directory fetch-download-location t)
  (let ((download-buffer (url-retrieve-synchronously url)))
    (save-excursion
      (set-buffer download-buffer)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (forward-char)
      (delete-region (point-min) (point))
      (write-file (concat fetch-download-location
                          (car (last (split-string url "/" t))))))))

(defun extract-resource (resource-file &optional location)
  "Extract the resource file"
  (setq file (concat fetch-download-location resource-file))
  (shell-command (if location
                     (concat "unzip " file " -d " location)
                   (concat "unzip " file))))

(defun move-resource (resource-file &optional location)
  "Copy a file to the proper location"
  (copy-file (concat fetch-download-location
                     resource-file)
             (or location
                 default-directory)))

(defun fetch-resource (name)
  "Download and extract the resource file"
  (interactive
   (list
    (minibuffer-with-setup-hook 'minibuffer-completion-help
      (completing-read "Resource to fetch: " fetch-package-alist))))
   (setq url (cdr (assoc name fetch-package-alist)))
   (setq filename (car (last (split-string url "/" t))))
   (download-resource url)
   (if (string= (car (last (split-string filename "\\." t))) "zip")
       (extract-resource filename)
     (move-resource filename)))

(provide 'fetch)

;;; fetch.el ends here
