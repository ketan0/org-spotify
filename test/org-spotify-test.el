;;; org-spotify-tests.el --- Unit tests for Org-Spotify -*- lexical-binding: t; -*-

;; Copyright © 2020 Ketan Agrawal

;; Author: Ketan Agrawal <http://www.github.com/ketan0>
;; Maintainer: Ketan Agrawal <ketanjayagrawal@gmail.com>
;; Created: September 29, 2020
;; Modified: September 29, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/ketan0/org-spotify
;; Package-Requires: ((buttercup) (org-ml "4.0"))
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

;; This file is part of Org-Spotify.

;;; Library Requires
(require 'org-spotify)
(require 'org-ml)
(require 'buttercup)
;;; Code:

(message "Running tests on Emacs %s" emacs-version)
(defconst org-spotify-test--spotify-id-regex (rx line-start (= 22 alphanumeric) line-end))

(describe "org-spotify-push-playlist-at-point"
  (it "creates and/or updates the org-mode Spotify playlist at point."
    (with-temp-buffer
      (->> (org-ml-build-headline :level 1 :title '("Underwater"))
           (org-ml-set-children
            (list (org-ml-build-headline :level 2 :title '("[[spotify:album:4Carzsnpd6yvuHZ49I0oz8][\"Awaken, My Love!\"]]"))
                  (org-ml-build-headline :level 2 :title '("[[spotify:album:53VKICyqCf91sVkTdFrzKX][Titanic Rising]]"))))
           (org-ml-to-string)
           (insert))
      (org-mode)
      (goto-char (point-min))
      (expect (org-spotify-push-playlist-at-point) :to-be t)
      (let* ((playlist-subtree (org-ml-parse-this-subtree))
             (playlist-id (org-ml-headline-get-node-property "PLAYLIST_ID")))
        (expect playlist-id :to-match org-spotify-test--spotify-id-regex)))))

;;; org-spotify-test.el ends here
