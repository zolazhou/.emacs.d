;;; module-org.el

(add-hook 'org-load-hook 'narf|org-init t)
(add-hook 'org-load-hook 'narf|org-keybinds t)
(add-hook 'org-mode-hook 'narf|org-hook)

(defvar org-directory (expand-file-name "~/Dropbox/docs/"))

(define-minor-mode evil-org-mode
  "Evil-mode bindings for org-mode."
  :init-value nil
  :lighter    " !"
  :keymap     (make-sparse-keymap) ; defines evil-org-mode-map
  :group      'evil-org)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun narf|org-hook ()
  (evil-org-mode +1)
  (org-indent-mode +1)
  (setq line-spacing 1)

  ;; Highlight plaintext links
  (highlight-regexp org-any-link-re 'org-link)

  ;; If saveplace places the point in a folded position, unfold it on load
  (when (outline-invisible-p)
    (ignore-errors
      (save-excursion
        (outline-previous-visible-heading 1)
        (org-show-subtree))))

  (defun narf|org-update ()
    (when (file-exists-p buffer-file-name)
      (org-update-statistics-cookies t)
      (org-align-all-tags)))

  (add-hook 'before-save-hook 'narf|org-update nil t)
  (add-hook 'evil-insert-state-exit-hook 'narf|org-update nil t))

(defun narf|org-init ()
  (setq-default
   org-agenda-files
   (f-entries org-directory (lambda (path) (string-suffix-p ".org" path)))

   ;; Appearance
   org-indent-mode-turns-on-hiding-stars t
   org-adapt-indentation nil
   org-blank-before-new-entry '((heading . nil) (plain-list-item . auto))
   org-bullets-bullet-list '("•" "◦" "•" "◦" "•" "◦")
   org-cycle-separator-lines 1
   org-ellipsis 'hs-face
   org-entities-user '(("flat" "\\flat" nil "" "" "266D" "♭")
                       ("sharp" "\\sharp" nil "" "" "266F" "♯"))
   org-fontify-done-headline t
   org-fontify-quote-and-verse-blocks t
   org-fontify-whole-heading-line t
   org-footnote-auto-label 'plain
   org-hide-emphasis-markers t
   org-hide-leading-stars nil
   org-image-actual-width nil
   org-indent-indentation-per-level 2
   org-pretty-entities t
   org-pretty-entities-include-sub-superscripts nil
   org-startup-folded t
   org-startup-indented nil
   org-startup-with-inline-images nil
   org-tags-column 70
   org-use-sub-superscripts '{}

   ;; Behavior
   org-catch-invisible-edits nil
   org-checkbox-hierarchical-statistics nil
   org-completion-use-ido nil ; Use helm for refiling
   org-confirm-elisp-link-function nil
   org-default-priority ?C
   org-hidden-keywords '(title)
   org-hierarchical-todo-statistics t
   org-log-done t
   org-loop-over-headlines-in-active-region t
   org-outline-path-complete-in-steps nil
   org-refile-use-outline-path t
   org-special-ctrl-a/e t

   ;; Sorting/refiling
   org-archive-location (concat org-directory "/Archived/%s::")
   org-refile-targets '((nil . (:maxlevel . 2))) ; display full path in refile completion

   ;; Agenda
   org-agenda-restore-windows-after-quit t
   org-agenda-skip-unavailable-files t
   org-agenda-window-setup 'other-window
   org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d)")
                       (sequence "IDEA(i)" "NEXT(n)" "ACTIVE(a)" "WAITING(w)" "LATER(l)" "|" "CANCELLED(c)"))

   ;; Babel
   org-confirm-babel-evaluate nil   ; you don't need my permission
   org-src-fontify-natively t       ; make code pretty
   org-src-preserve-indentation t
   org-src-tab-acts-natively t
   org-src-window-setup 'current-window

   ;; Latex
   org-format-latex-options (plist-put org-format-latex-options :scale 1.3)
   org-highlight-latex-and-related '(latex)
   org-latex-create-formula-image-program 'dvipng
   org-latex-image-default-width nil
   org-latex-preview-ltxpng-directory (concat narf-temp-dir "ltxpng/")
   org-latex-remove-logfiles nil
   org-startup-with-latex-preview nil
   ;; org-latex-packages-alist
   ;; '(("" "gauss" t)
   ;;   ("" "physics" t) TODO Install this)

   org-capture-templates
   '(("c" "Changelog" entry
      (file+headline (concat (narf/project-root) "CHANGELOG.org") "Unreleased")
      "* %?")

     ;; ("p" "Project Notes" entry
     ;;  (file+headline org-default-notes-file "Inbox")
     ;;  "* %u %?\n%i" :prepend t)

     ;; ("m" "Major-mode Notes" entry
     ;;  (file+headline org-default-notes-file "Inbox")
     ;;  "* %u %?\n%i" :prepend t)

     ("n" "Notes" entry
      (file+headline org-default-notes-file "Inbox")
      "* %u %?\n%i" :prepend t)

     ("v" "Vocab" entry
      (file+headline (concat org-directory "topics/vocab.org") "Unsorted")
      "** %i%?\n")))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t) (ruby . t) (sh . t) (js . t) (css . t)
     (plantuml . t) (emacs-lisp . t) (matlab . t)
     (latex . t) (calc . t) (lisp . t) (lilypond . t)
     (go . t) (http . t)
     (rust . t)))

  (let ((ext-regexp (regexp-opt '("GIF" "JPG" "JPEG" "SVG" "TIF" "TIFF" "BMP" "XPM"
                                  "gif" "jpg" "jpeg" "svg" "tif" "tiff" "bmp" "xpm"))))
    (setq iimage-mode-image-regex-alist
          `((,(concat "\\(`?file://\\|\\[\\[\\|<\\|`\\)?\\([-+./_0-9a-zA-Z]+\\."
                      ext-regexp "\\)\\(\\]\\]\\|>\\|'\\)?") . 2)
            (,(concat "<\\(http://.+\\." ext-regexp "\\)>") . 1))))

  ;; Don't open separate windows
  (add-to-list 'org-link-frame-setup '(file . find-file))

  ;; Reveal files in finder
  (setq org-file-apps '(("\\.org$" . emacs) (t . "open -R \"%s\"")))

  ;; Custom faces
  (defface org-list-bullet '((t ())) "Face for list bullets")
  (defvar narf-org-font-lock-keywords
    `(("^ *\\([-+]\\|[0-9]+[).]\\) "
       (1 'org-list-bullet))
      ("^ *\\(-----+\\)$"
       (1 'org-meta-line))))
  (font-lock-add-keywords 'org-mode narf-org-font-lock-keywords)

  ;; Enable encryption
  (require 'epa-file)
  (epa-file-enable)
  (require 'org-crypt)
  (org-crypt-use-before-save-magic)
  (setq org-tags-exclude-from-inheritance '("crypt")
        org-crypt-key user-mail-address
        epa-file-encrypt-to user-mail-address)

  ;; Don't track attachments
  (push (format "/%s.+$" (regexp-quote org-attach-directory)) recentf-exclude)
  ;; Don't clobber recentf with agenda files
  (defun org-is-agenda-file (filename)
    (find (file-truename filename) org-agenda-files :key 'file-truename
          :test 'equal))
  (pushnew 'org-is-agenda-file recentf-exclude)

  ;; Evil integration
  (progn
    (advice-add 'evil-force-normal-state :before 'org-remove-occur-highlights)
    ;; Add element delimiter text-objects so we can use evil-surround to
    ;; manipulate them.
    (define-text-object! "$" "\\$" "\\$")
    (define-text-object! "*" "\\*" "\\*")
    (define-text-object! "/" "/" "/")
    (define-text-object! "_" "_" "_")
    (define-text-object! "=" "=" "=")
    (define-text-object! "~" "~" "~")))

(defun narf|org-keybinds ()
  (define-key org-mode-map (kbd "RET") nil)
  (define-key org-mode-map (kbd "C-j") nil)
  (define-key org-mode-map (kbd "C-k") nil)
  (map! (:map org-mode-map
          :i [remap narf/inflate-space-maybe] 'org-self-insert-command
          :i "RET" 'org-return-indent)

        (:map evil-org-mode-map
          :ni "A-l" 'org-metaright
          :ni "A-h" 'org-metaleft
          :ni "A-k" 'org-metaup
          :ni "A-j" 'org-metadown
          ;; Expand tables (or shiftmeta move)
          :ni "A-L" 'narf/org-table-append-field-or-shift-right
          :ni "A-H" 'narf/org-table-prepend-field-or-shift-left
          :ni "A-K" 'narf/org-table-prepend-row-or-shift-up
          :ni "A-J" 'narf/org-table-append-row-or-shift-down

          :i  "C-L" 'narf/org-table-next-field
          :i  "C-H" 'narf/org-table-previous-field
          :i  "C-K" 'narf/org-table-previous-row
          :i  "C-J" 'narf/org-table-next-row

          :i  "C-e" 'org-end-of-line
          :i  "C-a" 'org-beginning-of-line

          :nv "j"   'evil-next-visual-line
          :nv "k"   'evil-previous-visual-line
          :v  "<S-tab>" 'narf/yas-insert-snippet

          :i  "M-a" (λ! (evil-visual-state) (org-mark-element))
          :n  "M-a" 'org-mark-element
          :v  "M-a" 'mark-whole-buffer

          :ni "<M-return>"   (λ! (narf/org-insert-item 'below))
          :ni "<S-M-return>" (λ! (narf/org-insert-item 'above))

          :i  "M-b" (λ! (narf/org-surround "*")) ; bold
          :i  "M-u" (λ! (narf/org-surround "_")) ; underline
          :i  "M-i" (λ! (narf/org-surround "/")) ; italics
          :i  "M-`" (λ! (narf/org-surround "+")) ; strikethrough

          :v  "M-b" "S*"
          :v  "M-u" "S_"
          :v  "M-i" "S/"
          :v  "M-`" "S+"

          (:leader
            :n ";"  'helm-org-in-buffer-headings
            :n "oa" 'narf/org-attachment-reveal)

          (:localleader
            :n  "/"  'org-sparse-tree
            :n  "?"  'org-tags-view

            :n  "n"  (λ! (if (buffer-narrowed-p) (widen) (org-narrow-to-subtree)))
            :n  "e"  'org-edit-special
            :n  "="  'org-align-all-tags
            :nv "l"  'org-insert-link
            :n  "L"  'org-store-link
            :n  "x"  'narf/org-remove-link
            ;; :n  "w"  'writing-mode
            :n  "v"  'variable-pitch-mode
            :n  "SPC" 'narf/org-toggle-checkbox
            :n  "RET" 'org-archive-subtree

            :n  "a"  'org-agenda
            :n  "A"  'narf:org-attachment-list

            :n  "d"  'org-time-stamp
            :n  "D"  'org-time-stamp-inactive
            :n  "i"  'narf/org-toggle-inline-images-at-point
            :n  "t"  (λ! (org-todo (if (org-entry-is-todo-p) 'none 'todo)))
            :n  "T"  'org-todo
            :n  "s"  'org-schedule
            :n  "r"  'org-refile
            :n  "R"  (λ! (org-metaleft) (org-archive-to-archive-sibling)) ; archive to parent sibling
            )

          ;; TODO Improve folding bindings
          :n  "za"  'org-cycle
          :n  "zA"  'org-shifttab
          :n  "zm"  (λ! (outline-hide-sublevels 1))
          :n  "zr"  'outline-show-all
          :n  "zo"  'outline-show-subtree
          :n  "zO"  'outline-show-all
          :n  "zc"  'outline-hide-subtree
          :n  "zC"  (λ! (outline-hide-sublevels 1))
          :n  "zd"  (lambda (&optional arg) (interactive "p") (outline-hide-sublevels (or arg 3)))

          :m  "]]"  (λ! (call-interactively 'org-forward-heading-same-level) (org-beginning-of-line))
          :m  "[["  (λ! (call-interactively 'org-backward-heading-same-level) (org-beginning-of-line))
          :m  "]l"  'org-next-link
          :m  "[l"  'org-previous-link

          :n  "RET" 'narf/org-dwim-at-point

          :m  "gh"  'outline-up-heading
          :m  "gj"  'org-forward-heading-same-level
          :m  "gk"  'org-backward-heading-same-level
          :m  "gl"  (λ! (call-interactively 'outline-next-visible-heading) (show-children))

          :n  "go"  'org-open-at-point
          :n  "gO"  (λ! (let ((org-link-frame-setup (append '((file . find-file-other-window)) org-link-frame-setup))
                              (org-file-apps '(("\\.org$" . emacs)
                                               (t . "open \"%s\""))))
                          (call-interactively 'org-open-at-point)))

          :n  "gQ"  'org-fill-paragraph
          :m  "$"   'org-end-of-line
          :m  "^"   'org-beginning-of-line
          :n  "<"   'org-metaleft
          :n  ">"   'org-metaright
          :v  "<"   (λ! (org-metaleft)  (evil-visual-restore))
          :v  ">"   (λ! (org-metaright) (evil-visual-restore))
          :n  "-"   'org-cycle-list-bullet
          :n  [tab] 'org-cycle)

        (:map org-src-mode-map
          :n  "<escape>" (λ! (message "Exited") (org-edit-src-exit)))

        (:after org-agenda
          (:map org-agenda-mode-map
            :e "<escape>" 'org-agenda-Quit
            :e "C-j" 'org-agenda-next-item
            :e "C-k" 'org-agenda-previous-item
            :e "C-n" 'org-agenda-next-item
            :e "C-p" 'org-agenda-previous-item))))

(provide 'module-org)
;;; module-org.el ends here