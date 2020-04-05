; Emacs Configuration

(when (>= emacs-major-version 24)
  (require `package)
  (package-initialize)
  (add-to-list `package-archives
               `("melpa" . "http://melpa.milkbox.net/packages/") t)
  )

(load-theme 'solarized-dark t)

; Fonts
(set-face-attribute 'default nil
                    :family "Inconsolata"
                    :height 120
                    :weight 'normal
                    :width 'normal)

(when (functionp 'set-fontset-font)
  (set-fontset-font "fontset-default"
                    'unicode
                    (font-spec :family "DejaVu Sans Mono"
                               :width 'normal
                               :size 15.5
                               :weight 'normal)))

(when (window-system)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (menu-bar-mode -1))

(when (window-system)
  (require 'git-gutter-fringe))

(global-git-gutter-mode +1)

(setq-default indicate-buffer-boundaries 'left)
(setq-default indicate-empty-lines +1)

; Smart mode line
(sml/setup)
(setq sml/shorten-directory t)
(setq sml/shorten-modes t)
(nyan-mode +1)
(setq nyan-wavy-trail nil)
(setq nyan-animate-nyancat t)

; Display 24-hour time.
(setq display-time-24hr-format t)
(display-time-mode +1)

; Smoother scrolling behavior.
(setq redisplay-dont-pause t
      scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

; Mouse scrolling.
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

; Make unique buffer names.
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

; Prefer single frames.
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

; Empty scratch buffer when starting emacs.
(setq inhibit-startup-screen +1)
(setq initial-major-mode 'org-mode)
(setq initial-scratch-message nil)

(toggle-frame-maximized)

(defun my/->string (str)
  (cond
   ((stringp str) str)
   ((symbolp str) (symbol-name str))))

(defun my/->mode-hook (name)
  "Turn mode name into hook symbol"
  (intern (replace-regexp-in-string "\\(-mode\\)?\\(-hook\\)?$"
                                    "-mode-hook"
                                    (my/->string name))))

(defun my/->mode (name)
  "Turn mode name into mode symbol"
  (intern (replace-regexp-in-string "\\(-mode\\)?$"
                                    "-mode"
                                    (my/->string name))))

; Set up hooks and modes.
(defun my/set-modes (arg mode-list)
  (dolist (m mode-list)
    (if (fboundp (my/->mode m))
        (funcall (my/->mode m) arg)
      (message "No mode %s found" m))))

(defun my/turn-on (&rest mode-list)
  "Turn on the given (minor) modes."
  (my/set-modes +1 mode-list))

(defvar my/normal-base-modes
  (mapcar 'my/->mode '(text prog))
  "The list of modes that are considered base modes for
  programming and text editing. In an ideal world, this should
  just be text-mode and prog-mode, however, some modes that
  should derive from prog-mode derive from fundamental-mode
  instead. They are added here.")

(defun my/normal-mode-hooks ()
  "Returns the mode-hooks for `my/normal-base-modes`"
  (mapcar 'my/->mode-hook my/normal-base-modes))

(setq-default indent-tabs-mode nil)

(defun my/clean-buffer-formatting ()
  "Indent and clean up the buffer"
  (interactive)
  (indent-region (point-min) (point-max))
  (whitespace-cleanup))

(global-set-key "\C-cn" 'my/clean-buffer-formatting)

;; by default,
;; highlight trailing whitespace
;; and show form-feed chars as horizontal rules

(defun my/general-formatting-hooks ()
  (setq show-trailing-whitespace 't)
  (my/turn-on 'form-feed))

(dolist (mode-hook (my/normal-mode-hooks))
  (add-hook mode-hook 'my/general-formatting-hooks))

; Text wrapping when editing text.
(defun my/text-formatting-hooks ()
  (my/turn-on 'auto-fill)) ; turn on automatic hard line wraps

(add-hook 'text-mode-hook
          'my/text-formatting-hooks)

; Compilation ANSI colors fix.
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(setq compilation-scroll-output t)

; Dired to existing dired buffer.
(setq dired-dwim-target t)

; Auto completion
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

; Pair-programming mode
(define-minor-mode my/pair-programming-mode
  "Toggle visualizations for pair programming.

Interactively with no argument, this command toggles the mode.  A
positive prefix argument enables the mode, any other prefix
argument disables it.  From Lisp, argument omitted or nil enables
the mode, `toggle' toggles the state.

This turns on hightlighting the current line, line numbers and
command-log-mode."
  ;; The initial value.
  nil
  ;; The indicator for the mode line.
  " Pairing"
  ;; The minor mode bindings.
  '()
  :group 'my/pairing
  (my/set-modes (if my/pair-programming-mode 1 -1)
                '(linum hl-line command-log)))

(define-global-minor-mode my/global-pair-programming-mode
  my/pair-programming-mode
  (lambda () (my/pair-programming-mode 1)))

(global-set-key "\C-c\M-p" 'my/global-pair-programming-mode)

; Indentation for C
(setq-default c-default-style "linux"
	      c-basic-offset 4
	      tab-width 4
	      indent-tabs-mode nil)

(add-hook 'c-mode-common-hook
          (lambda () (setq indent-tabs-mode t)))

; Magit
(global-set-key "\C-cg" 'magit-status)
(setq magit-default-tracking-name-function #'magit-default-tracking-name-branch-only)
(setq magit-last-seen-setup-instructions "1.4.0")

; Set up backup behaviour.
(setq backup-by-copying t
      backup-directory-alist
      auto-save-file-name-transforms
      version-control t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2)

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))

(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

; Cygwin executables.
(add-to-list 'exec-path "C:\\cygwin64\\bin")

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

