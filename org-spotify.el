;;; org-spotify.el --- integrate spotify into org-mode -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Ketan Agrawal
;;
;; Author: Ketan Agrawal <http://www.github.com/ketan0>
;; Maintainer: Ketan Agrawal <ketanjayagrawal@gmail.com>
;; Created: September 29, 2020
;; Modified: September 29, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/ketan0/org-spotify
;; Package-Requires: ((emacs "26.1") (dash "2.17") (org-ml "4.0") (counsel-spotify "0.5") (ivy "0.13"))
;;
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
;;
;;; Commentary:
;;
;;  Org-mode spotify stuff
;;
;;; Library Requires
(require 'dash)
(require 'org-ml)
(require 'counsel-spotify)
(require 'ivy)

;;; Code:
;;; Customizable variables
(defgroup org-spotify nil
  "Play spotify songs through org mode interfaces."
  :group 'org
  :prefix "org-spotify-"
  :link '(url-link :tag "Github" "https://github.com/ketan0/org-spotify"))

(defcustom org-spotify-play-music-on-file-open nil
  "If true, org-spotify plays music upon opening an org file with a valid #+SPOTIFY_HREF keyword defined at the top."
  :type 'boolean
  :group 'org-spotify)

;; Functions
(defun org-spotify-play-href (href)
  "Plays HREF on Spotify, using counsel-spotify."
  (counsel-spotify-do-play counsel-spotify-current-backend
                           (counsel-spotify-playable :uri href)))

(defun org-spotify-insert-type (type)
  (counsel-spotify-verify-credentials)
  (-->
   (ivy-read (format "Search %s: " (symbol-name type))
             (counsel-spotify-search-by :type `(,type)) :dynamic-collection t)
   (counsel-spotify-unwrap-spotify-object it)

   (org-ml-build-link (uri it) (name it))
   (org-ml-to-string it)
   (insert it)))

(defun org-spotify-insert-artist ()
  "Interactively choose and insert an org-mode link to play an artist on Spotify."
  (interactive)
  (org-spotify-insert-type 'artist))

(defun org-spotify-insert-album ()
  "Interactively choose and insert an org-mode link to play an album on Spotify."
  (interactive)
  (org-spotify-insert-type 'album))

(defun org-spotify-insert-track ()
  "Interactively choose and insert an org-mode link to play a track on Spotify."
  (interactive)
  (org-spotify-insert-type 'track))

(defun org-spotify-insert-playlist ()
  "Interactively choose and insert an org-mode link to play a playlist on Spotify."
  (interactive)
  (org-spotify-insert-type 'playlist))

(defun org-spotify-insert ()
  "Interactively choose a media type (i.e. artist, album, track, or playlist,),
and choose and insert an org-mode link to something of that type on Spotify."
  (interactive)
  (->>
   (completing-read "What type of Spotify item: " '("artist" "album" "track" "playlist"))
   (intern)
   (org-spotify-insert-type)))

(defun org-spotify-follow (link)
  "Follows a spotify: LINK by playing that href on spotify."
  (org-spotify-play-href (concat "spotify:" link)))

(org-link-set-parameters "spotify"
                         :follow 'org-spotify-follow)

;; Experimental functionality below
(defun org-spotify-push-playlist-at-point ()
  (interactive)
  nil)

(defun org-spotify-set-file-href ()
  "Sets the current file's #+SPOTIFY_HREF keyword, if none exists."
  ;; TODO: handle the case where the keyword already exists
  ;; TODO: put the keyword in a nice place (not the beginning of the file)
  ;; TODO: use counsel spotify for completion here
  (interactive)
  (let ((href (read-string "Enter Spotify [track/artist/album/playlist] HREF: ")))
    (unless (org-spotify-get-file-href)
      (org-ml-update-section-at* (point-min)
        (org-ml-set-children
         (append (list (org-ml-build-keyword "SPOTIFY_HREF" href))
                 (org-ml-get-children it))
         it)))))

(defun org-spotify-get-file-href ()
  "Return the value of the #+SPOTIFY_HREF keyword if currently in an org file that has it.
Otherwise, return nil."
  ;; TODO: compatibility for older versions of org, where org-collect-keywords doesn't exist
  (-some->> (org-collect-keywords '("SPOTIFY_HREF"))
    (car)
    (cadr)))

(defun org-spotify--maybe-play-file-href ()
  "Hook on `find-file-hook' to potentially play music.
Plays if in an `org-mode' file that specifies a spotify href."
  (when (and org-spotify-play-music-on-file-open (eq major-mode 'org-mode))
    (-some->> (org-spotify-get-file-href)
      (org-spotify-play-href))))

(define-minor-mode org-spotify-mode
  "Minor mode for org-spotify.
Sets up `org-spotify--maybe-play-file-href' upon opening of a file."
  :lighter " Org-spotify"
  :keymap (let ((map (make-sparse-keymap)))
            map)
  :group 'org-spotify
  :require 'org-spotify
  :global t
  (if org-spotify-mode
      (add-hook 'find-file-hook 'org-spotify--maybe-play-file-href)
    (remove-hook 'find-file-hook 'org-spotify--maybe-play-file-href)))

(provide 'org-spotify)
;;; org-spotify.el ends here
