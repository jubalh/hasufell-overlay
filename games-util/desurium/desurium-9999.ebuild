# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

WX_GTK_VER="2.9"

inherit cmake-utils eutils git-2 gnome2-utils wxwidgets toolchain-funcs games

# tools versions
BREAKPAD_ARC="breakpad-850.tar.gz"
CEF_ARC="cef-291.tar.gz"
WX_ARC="wxWidgets-2.9.3.tar.bz2"

DESCRIPTION="Free software version of Desura game client"
HOMEPAGE="https://github.com/lodle/Desurium"
SRC_URI="mirror://github/lodle/Desurium/${BREAKPAD_ARC}
	mirror://github/lodle/Desurium/${CEF_ARC}
	bundled-wxgtk? ( ftp://ftp.wxwidgets.org/pub/2.9.3/${WX_ARC} )"

EGIT_REPO_URI="git://github.com/lodle/Desurium.git"
EGIT_NOUNPACK="true"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+32bit +bundled-wxgtk debug tools"

COMMON_DEPEND="
	app-arch/bzip2
	dev-db/sqlite
	>=dev-libs/boost-1.47:=
	dev-libs/expat
	dev-libs/openssl:0
	|| ( <dev-libs/tinyxml-2.6.2-r2[-stl]
	    >=dev-libs/tinyxml-2.6.2-r2
	)
	dev-lang/v8:=
	|| (
		net-misc/curl[adns]
		net-misc/curl[ares]
	)
	virtual/jpeg
	media-libs/libpng:0
	media-libs/tiff
	net-misc/curl
	>=sys-devel/gcc-4.6
	sys-libs/zlib
	x11-libs/gtk+:2
	x11-libs/libnotify
	x11-libs/libXt
	!bundled-wxgtk? (
		~x11-libs/wxGTK-2.9.3.1:${WX_GTK_VER}[X]
	)
	amd64? ( 32bit? (
		sys-devel/gcc[multilib]
	) )"
RDEPEND="${COMMON_DEPEND}
	=media-libs/desurium-cef-9999*
	x11-misc/xdg-user-dirs
	x11-misc/xdg-utils"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if [[ $(tc-getCC) =~ gcc ]]; then
			if [[ $(gcc-major-version) == 4 && $(gcc-minor-version) -lt 6 || $(gcc-major-version) -lt 4 ]] ; then
				eerror "You need at least sys-devel/gcc-4.6.0"
				die "You need at least sys-devel/gcc-4.6.0"
			fi
		fi
	fi
}

src_unpack() {
	git-2_src_unpack
}

src_configure() {
	# -DWITH_ARES=FALSE will use system curl, because we force curl[ares] to have ares support
	local mycmakeargs=(
		-DWITH_ARES=FALSE
		-DFORCE_SYS_DEPS=TRUE
		-DBUILD_CEF=FALSE
		-BUILD_ONLY_CEF=FALSE
		$(cmake-utils_use debug DEBUG)
		$(cmake-utils_use 32bit 32BIT_SUPPORT)
		$(cmake-utils_use tools BUILD_TOOLS)
		-DWITH_FLASH=FALSE
		-DCMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-DBREAKPAD_URL="file://${DISTDIR}/${BREAKPAD_ARC}"
		-DCEF_URL="file://${DISTDIR}/${CEF_ARC}"
		-DBINDIR="${GAMES_BINDIR}"
		-DDATADIR="${GAMES_DATADIR}"
		-DRUNTIME_LIBDIR="$(games_get_libdir)"
		-DDESKTOPDIR="/usr/share/applications"
		$(use bundled-wxgtk && echo -DWXWIDGET_URL="file://${DISTDIR}/${WX_ARC}")
		$(cmake-utils_use bundled-wxgtk FORCE_BUNDLED_WXGTK)
	)
	cmake-utils_src_configure
}

src_compile() {
	# even autotools does not respect AR properly sometimes
	cmake-utils_src_compile AR=$(tc-getAR)
}

src_install() {
	cmake-utils_src_install

	newicon -s scalable "${S}/src/branding_${PN}/sources/desubot.svg" "${PN}.svg"
	make_desktop_entry "desura" "Desurium"

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
