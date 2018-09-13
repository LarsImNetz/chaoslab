# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit desktop gnome2-utils python-single-r1

ELECTRON_SLOT="2.0"
MY_PV=${PV/_/-}
RSRC_DIR="out/${PN}-${MY_PV}-amd64/resources"

DESCRIPTION="A hackable text editor for the 21st Century"
HOMEPAGE="https://atom.io"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}
	>net-libs/nodejs-6.0
"
RDEPEND="${DEPEND}
	>=dev-util/ctags-5.8
	~dev-util/electron-bin-2.0.5:${ELECTRON_SLOT}
	media-fonts/inconsolata
	!app-editors/atom-bin
	!sys-apps/apmd
"

NODE_MODULES_PATH="usr/libexec/atom/resources/app.asar.unpacked/node_modules"
QA_PRESTRIPPED="
	${NODE_MODULES_PATH}/dugite/git/bin/git
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-credential-cache
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-credential-cache--daemon
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-credential-store
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-daemon
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-fast-import
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-http-backend
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-http-fetch
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-http-push
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-imap-send
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-lfs
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-remote-http
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-sh-i18n--envsubst
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-shell
	${NODE_MODULES_PATH}/dugite/git/libexec/git-core/git-show-index
	${NODE_MODULES_PATH}/keytar/build/Release/keytar.node
	${NODE_MODULES_PATH}/tree-sitter-bash/build/Release/tree_sitter_bash_binding.node
	${NODE_MODULES_PATH}/tree-sitter-ruby/build/Release/tree_sitter_ruby_binding.node
	${NODE_MODULES_PATH/.asar.unpacked//apm}/keytar/build/Release/keytar.node
"

PATCHES=(
	"${FILESDIR}/${PN}-apm-path.patch"
	"${FILESDIR}/${PN}-fix-app-restart.patch"
	"${FILESDIR}/${PN}-fix-config-watcher-r1.patch"
	"${FILESDIR}/${PN}-unbundle-electron.patch"
)

S="${WORKDIR}/${PN}-${MY_PV}"

pkg_setup() {
	# shellcheck disable=SC2086
	if has network-sandbox $FEATURES; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi

	python-single-r1_pkg_setup
	npm config set python "${PYTHON}" || die
}

src_prepare() {
	local suffix
	suffix="$(get_install_suffix)"
	default

	# Make bootstrap process more verbose
	sed -i 's|node script/bootstrap|node script/bootstrap --no-quiet|g' \
		./script/build || die

	# Fix path for "View License" in Help menu
	sed -i "s|path.join(process.resourcesPath, 'LICENSE.md')|'/usr/share/licenses/atom/LICENSE.md'|g" \
		./src/main-process/atom-application.js || die

	sed -i \
		-e "s|{{ATOM_PATH}}|${EROOT}/opt/electron-bin-${ELECTRON_SLOT}/electron|g" \
		-e "s|{{ATOM_RESOURCE_PATH}}|${EROOT}/usr/libexec/atom/resources/app.asar|g" \
		-e "s|{{ATOM_PREFIX}}|${EROOT}|g" \
		./atom.sh || die

	sed -i \
		-e "s|{{ATOM_PREFIX}}|${EROOT}|g" \
		-e "s|{{ATOM_SUFFIX}}|${suffix}|g" \
		./src/config-schema.js || die
}

src_compile() {
	NO_UPDATE_NOTIFIER="" ./script/build --verbose || die "Failed to compile"
}

src_install() {
	# Clean up
	local ctags_d="app.asar.unpacked/node_modules/symbols-view/vendor"
	local find_exp="-or -name"
	local find_name=()

	pushd "${RSRC_DIR}" > /dev/null || die
	# shellcheck disable=SC2206
	for match in "AUTHORS*" "CHANGE*" "CONTRIBUT*" "README*" \
		".travis.yml" ".eslint*" ".wercker.yml" ".npmignore" \
		"*.md" "*.markdown" "*.bat" "*.cmd" ".mailmap" \
		".npmignore" "Makefile"; do
		find_name+=( ${find_exp} "${match}" )
	done

	# Remove various development and/or inappropriate files and
	# useless docs of dependend packages
	find ./app \
		\( -type d -name examples \) -or \( -type f \( \
			-iname "LICEN?E*" \
			"${find_name[@]}" \
		\) \) -exec rm -rf "{}" \;

	# Make sure python-interceptor.sh use python2.*
	sed -i "s|python|${PYTHON}|g" ./app/apm/bin/python-interceptor.sh || die

	# Remove non-Linux vendored ctags binaries
	rm ./${ctags_d}/ctags-{darwin,win32.exe} || die
	# Replace vendored ctags with a symlink to system ctags
	rm ./${ctags_d}/ctags-linux || die
	ln -s "${EROOT}/usr/bin/ctags" ./${ctags_d}/ctags-linux || die

	# Remove redundant atom.png
	rm -r ./app.asar.unpacked/resources || die
	popd > /dev/null || die

	insinto /usr/libexec/atom
	doins -r "${RSRC_DIR}"
	doins "${RSRC_DIR/resources/snapshot_blob.bin}"

	# Install icons and desktop entry
	local size
	for size in 16 24 32 48 64 128 256 512; do
		newicon -s ${size} "resources/app-icons/stable/png/${size}.png" atom.png
	done
	# shellcheck disable=SC1117
	make_desktop_entry atom Atom atom \
		"GNOME;GTK;Utility;TextEditor;Development;" \
		"MimeType=text/plain;\nStartupNotify=true\nStartupWMClass=Atom"
	sed -e "/^Exec/s/$/ %F/" -i "${ED}"/usr/share/applications/*.desktop || die

	# Fix permissions
	fperms +x /usr/libexec/atom/resources/app/atom.sh
	fperms +x /usr/libexec/atom/resources/app/apm/bin/apm
	fperms +x /usr/libexec/atom/resources/app/apm/bin/node
	fperms +x /usr/libexec/atom/resources/app/apm/bin/python-interceptor.sh
	fperms +x /usr/libexec/atom/resources/app/apm/node_modules/npm/bin/node-gyp-bin/node-gyp
	# Symlink to /usr/bin
	dosym ../libexec/atom/resources/app/atom.sh /usr/bin/atom
	dosym ../libexec/atom/resources/app/apm/bin/apm /usr/bin/apm
	# Symlink LICENSE.md to work with "View License" in Help menu
	dosym ../../../libexec/atom/resources/LICENSE.md /usr/share/licenses/atom/LICENSE.md
}

# Return the installation suffix appropriate for the slot
get_install_suffix() {
	local slot=${SLOT%%/*}
	local suffix

	if [[ "${slot}" == "0" ]]; then
		suffix=""
	else
		suffix="-${slot}"
	fi

	echo "${suffix}"
}

pkg_postinst() {
	# Update mimedb for the new .desktop file
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
