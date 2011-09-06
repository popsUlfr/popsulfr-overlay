# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit games

MY_PN="${PN/m/M}"
MY_ICON="${MY_PN}.png"

DESCRIPTION="Point-and-Click Adventure Game by the makers of web games Samorost and Samorost 2."
HOMEPAGE="http://machinarium.net/"
LICENSE="AdobeFlash-10"
SRC_URI="${MY_PN}_full_en.tar.gz"

SLOT="0"

KEYWORDS="~amd64 ~x86"

IUSE="icon"

RESTRICT="strip fetch"

#Dependencies taken from www-plugins/adobe-flash
NATIVE_DEPS="x11-libs/gtk+:2
	media-libs/fontconfig
	dev-libs/nss
	net-misc/curl
	>=sys-libs/glibc-2.4"

EMUL_DEPS=">=app-emulation/emul-linux-x86-gtklibs-20100409-r1
	app-emulation/emul-linux-x86-soundlibs"

DEPEND=""
RDEPEND="x86? ( ${NATIVE_DEPS} )
	amd64? ( ${EMUL_DEPS} )"
			
S="${WORKDIR}/${MY_PN}"

pkg_nofetch() {
    elog "Please purchase ${MY_PN} from ${HOMEPAGE} to play."
    elog "Then place the ${SRC_URI} file into ${DISTDIR} and retry."
}

pkg_setup() {
	if use icon && [[ ! -f "${FILESDIR}/${MY_ICON}" ]] ; then
		elog "You enabled the icon use flag."
		elog "Put your icon into ${FILESDIR} and name it ${MY_ICON}."
		elog "A nice one can be found here:"
		elog 'http://darkhavans.deviantart.com/art/Machinarium-Dock-Icon-141463511'
		die "No icon provided."
	fi
	games_pkg_setup
}

src_install() {
	local gamedir="${GAMES_PREFIX_OPT}/${MY_PN}"
	insinto "${gamedir}"
	exeinto "${gamedir}"
	doins -r 00 01 10 11 || die "doins failed"
	doexe "${MY_PN}" || die "doexe failed"
	if use icon ; then
		doicon "${FILESDIR}/${MY_ICON}" || die "doicon failed"
	fi
	games_make_wrapper "${MY_PN}" "./${MY_PN}" "${gamedir}"
	make_desktop_entry "${MY_PN}" "${MY_PN}" "${MY_PN}"
	
	prepgamesdirs
}
