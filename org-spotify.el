;;; org-spotify.el --- integrate spotify into org-mode -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Ketan Agrawal
;;
;; Author: Ketan Agrawal <http://github/ketanagrawal>
;; Maintainer: Ketan Agrawal <agrawalk@stanford.edu>
;; Created: September 29, 2020
;; Modified: September 29, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/ketanagrawal/org-spotify
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Org-mode spotify stuff
;;  Currently only supports OS X.
;;
;;; Code:
;;; Library Requires
(require 'dash)
(require 'org-ml)

;;; Customizable variables
(defgroup org-spotify nil
  "Play spotify songs through org mode interfaces."
  :group 'org
  :prefix "org-spotify-"
  :link '(url-link :tag "Github" "https://github.com/ketan0/org-spotify"))

;; Functions
(defun org-spotify-play-href (href)
  "Plays HREF on Spotify, using the Alfred Spotify Mini Player."
  (shell-command (format "osascript -e 'tell application id \"%s\" to run trigger \"play\" in workflow \"%s\" with argument \"%s\"'"
                         "com.runningwithcrayons.Alfred"
                         "com.vdesabou.spotify.mini.player"
                         href)))

(defun org-spotify-play-pause ()
  (shell-command (format "osascript -e 'tell application \"%s\" to %s'"
                         "Spotify"
                         "playpause")))

(defun org-spotify-set-file-href ()
  (interactive)
  (let ((href (read-string "Enter Spotify [track/artist/album/playlist] HREF: ")))
    (unless (org-spotify-get-file-href)
      (org-ml-update-section-at* (point-min)
        (org-ml-set-children
         (append (list (org-ml-build-keyword "SPOTIFY_HREF" href))
                 (org-ml-get-children it))
         it)))))

(defun org-spotify-get-file-href ()
  (-some->> (org-collect-keywords '("SPOTIFY_HREF"))
    (car)
    (cadr)))

(defun org-spotify--maybe-play-file-href ()
  "Hook on `find-file-hook' to potentially play music.
Plays if in an `org-mode' file that specifies a spotify href."
  ;; TODO: compatibility if org-collect-keywords doesn't exist
  (when (eq major-mode 'org-mode)
    (-some->> (org-spotify-get-file-href)
      (org-spotify-play-href))))

(define-minor-mode org-spotify-mode
  "Test."
  :lighter " Org-spotify"
  :keymap (let ((map (make-sparse-keymap)))
            map)
  :group 'org-spotify
  (if org-spotify-mode
      (add-hook 'find-file-hook 'org-spotify--maybe-play-file-href)
    (remove-hook 'find-file-hook 'org-spotify--maybe-play-file-href)))

(provide 'org-spotify)
;;; org-spotify.el ends here
