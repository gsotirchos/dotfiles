#!/usr/bin/env bash
# shellcheck disable=SC2155
set -euo pipefail

# Installs TeX Live from the upstream installer into the user's home directory,
# so that `tlmgr' manages packages without root on both macOS and Linux.  The
# packaged distributions are deliberately not used: Debian's `tlmgr' refuses
# `update --self' and defers to apt, and MacTeX/basictex install system-wide.
# https://tug.org/texlive/quickinstall.html

main() {
    local dotfiles="$(
        builtin cd "$(
            realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
        )" > /dev/null && pwd
    )"
    local bright='\033[1m'
    local reset='\033[0m'

    header() { echo -e "\n${bright}- ${1}${reset}"; }
    warn() { echo -e "${bright}Warning: ${1}${reset}" >&2; }
    die() { echo -e "${bright}Error: ${1}${reset}" >&2; exit 1; }

    local texlive_dir="${HOME}/.texlive"
    local current_dir="${texlive_dir}/current"
    local installer_url="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"

    # NOTE: dvisvgm renders the Org mode LaTeX fragment previews
    local packages=(
        latexmk
        dvisvgm
        babel-greek
        greek-fontenc
        cbfonts
        collection-fontsrecommended
        subfiles
        appendix
        siunitx
        cancel
        extarrows
        mleftright
        bbm
        bbm-macros
        mathtools
        csquotes
        ebgaramond
        courierten
        fontaxes
        titlesec
        xcolor
        xhfill
        xcharter
        xstring
        sttools
        threeparttable
        wrapfig
        multirow
        ncctools
        algorithms
        algorithmicx
        algorithm2e
        svg
        todonotes
        catchfile
        transparent
        adjustbox
        relsize
        makecell
        comment
        trimspaces
        collectbox
        soul
        ulem
        newtx
        kastrup
        placeins
        ifoddpage
        doublestroke
        enumitem
    )

    # --- validate -------------------------------------------------------
    for cmd in curl tar perl realpath; do
        if ! command -v "${cmd}" &> /dev/null; then
            die "\`${cmd}' is required but could not be found"
        fi
    done

    # --- install --------------------------------------------------------
    if [[ -d "${current_dir}" ]]; then
        header "Reusing the TeX Live installation in ${current_dir}"
    else
        header "Downloading the TeX Live installer"
        # Not `local': the EXIT trap runs after main has returned.
        workdir="$(mktemp -d)"
        trap 'rm -rf "${workdir}"' EXIT
        curl -fsSL "${installer_url}" | tar -xz -C "${workdir}"

        local installer=("${workdir}"/install-tl-*/install-tl)
        if [[ ! -x "${installer[0]}" ]]; then
            die "no \`install-tl' in the downloaded archive"
        fi

        local year="$("${installer[0]}" --version \
            | sed -n 's/^TeX Live.* version \([0-9]\{4\}\).*/\1/p')"
        if [[ -z "${year}" ]]; then
            die "could not determine the TeX Live release year"
        fi

        # TEXMFVAR, TEXMFCONFIG and TEXMFHOME would otherwise default to
        # ~/.texlive${year} and ~/texmf; pin them under ${texlive_dir} so the
        # only thing TeX Live leaves in $HOME is that one directory.
        header "Installing TeX Live ${year} into ${texlive_dir}/${year}"
        "${installer[0]}" \
            -no-interaction \
            -scheme basic \
            -texdir "${texlive_dir}/${year}" \
            -texuserdir "${texlive_dir}/${year}-user" \
            -texmfhome "${texlive_dir}/texmf" \
            -no-doc-install \
            -no-src-install

        ln -sfn "${year}" "${current_dir}"
    fi

    # `tlmgr path add' symlinks into /usr/local/bin and needs root; the shell
    # startup files put ~/.texlive/current/bin/* on $PATH instead (extra_paths/).
    local bindir=("${current_dir}"/bin/*)
    if [[ ! -x "${bindir[0]}/tlmgr" ]]; then
        die "no \`tlmgr' under ${current_dir}/bin"
    fi
    export PATH="${bindir[0]}:${PATH}"

    # --- packages -------------------------------------------------------
    header "Updating tlmgr and the installed packages"
    tlmgr update --self --all

    header "Installing LaTeX packages"
    if ! tlmgr install "${packages[@]}"; then
        warn "some packages failed to install; see the check below"
    fi

    # --- verify ---------------------------------------------------------
    header "Checking the Org mode preview toolchain"
    local missing=()
    for cmd in latex dvisvgm; do
        if ! command -v "${cmd}" &> /dev/null; then
            missing+=("${cmd}")
        fi
    done

    # Org puts these in every preview preamble regardless of our own header
    # (see `org-latex-default-packages-alist'); scheme-basic ships all but ulem.
    local preamble="${dotfiles}/etc/math_commands.tex"
    local style
    while read -r style; do
        if ! kpsewhich "${style}.sty" &> /dev/null; then
            missing+=("${style}.sty")
        fi
    done < <(
        {
            printf '%s\n' amsmath amssymb graphicx ulem inputenc fontenc
            grep -oE '\\usepackage(\[[^]]*\])?\{[^}]*\}' "${preamble}" \
                | sed 's/.*{//; s/}//' \
                | tr ',' '\n'
        } | sort -u
    )

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "missing: ${missing[*]}"
    else
        echo "Every style Org and ${preamble##*/} need resolves."
    fi

    # dvisvgm loads libgs at run time for PostScript specials; TeX Live does
    # not ship it, and installing it needs a package manager (sudo on Linux),
    # so only point at the command rather than running it from here.
    if ! command -v gs &> /dev/null; then
        local ghostscript_hint="sudo apt install ghostscript"
        if [[ "$(uname -s)" == "Darwin" ]]; then
            ghostscript_hint="brew install ghostscript"
        fi
        warn "ghostscript is missing, dvisvgm needs it for PostScript specials."
        echo "  Install it with: ${ghostscript_hint}" >&2
    fi

    header "Start a new login shell to pick up ${current_dir}/bin on \$PATH"
}

main "$@"
unset main
