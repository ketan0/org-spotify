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

;;; Customizable variables
(defgroup org-spotify nil
  "Store org-mode notes in a Neo4j graph database."
  :group 'org
  :prefix "org-spotify-"
  :link '(url-link :tag "Github" "https://github.com/ketan0/org-spotify"))

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

(defvar sample-href "spotify:artist:4r63FhuTkUYltbVAg5TQnk")
(org-spotify-play-href sample-href)

(defun org-spotify--maybe-play-file-href ()
  ;; TODO: compatibility if org-collect-keywords doesn't exist
  (when (eq major-mode 'org-mode)
             (-some->> (org-collect-keywords '("SPOTIFY_HREF"))
                  (car)
                  (cadr)
                  (org-spotify-play-href)
                  )))

(define-minor-mode org-spotify-mode
  "Test."
  :lighter " Org-spotify"
  :keymap (let ((map (make-sparse-keymap)))
            map)
  :group 'org-spotify

  (if org-spotify-mode
      (add-hook 'find-file-hook 'org-spotify--maybe-play-file-href)
    (remove-hook 'find-file-hook 'org-spotify--maybe-play-file-href))

  )

;;
;; (url-retrieve-synchronously )

(provide 'org-spotify)
;;; org-spotify.el ends here
