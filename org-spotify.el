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

(defun org-spotify-play (href)
  "Plays HREF on Spotify, using the Alfred Spotify Mini Player."
  (shell-command (format "osascript -e 'tell application id \"%s\" to run trigger \"play\" in workflow \"%s\" with argument \"%s\"'"
                         "com.runningwithcrayons.Alfred"
                         "com.vdesabou.spotify.mini.player"
                         href)))

(defvar sample-href "spotify:artist:4r63FhuTkUYltbVAg5TQnk")
(org-spotify-play sample-href)

;;
;; (url-retrieve-synchronously )

(provide 'org-spotify)
;;; org-spotify.el ends here
