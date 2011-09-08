# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils games

MY_PN="${PN/-/_}"

DESCRIPTION="Amnesia: The Dark Descent is a first person survival horror. A game about immersion, discovery and living through a nightmare."
HOMEPAGE="http://www.amnesiagame.com"
SRC_URI="${MY_PN}_${PV}.sh"

RESTRICT="fetch strip"
LICENSE="Frictional_Games-EULA"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bundled-libs doc linguas_de linguas_en linguas_es linguas_fr linguas_it linguas_ru"

COMMON_RDEPEND="x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXdmcp
	x11-libs/libXext
	virtual/glu
	virtual/opengl"

BUNDLED_RDEPEND="media-libs/freealut
	=media-libs/glew-1.5*
	media-libs/jpeg:62
	media-libs/libogg
	media-libs/libpng:1.2
	media-libs/libtheora
	media-libs/libvorbis
	media-libs/openal
	media-libs/sdl-image
	media-libs/sdl-ttf
	=x11-libs/fltk-1.1*"
	
DEPEND=""
RDEPEND="${COMMON_RDEPEND}
	!bundled-libs? ( ${BUNDLED_RDEPEND} )"
	
S="${WORKDIR}/Amnesia"

pkg_nofetch() {
    elog "Please purchase ${MY_PN} from ${HOMEPAGE} to play."
    elog "Then place the ${SRC_URI} file into ${DISTDIR} and retry."
}

src_unpack() {
	unpack_makeself || die "unpack_makeself failed"
	mv ./subarch ./subarch.tar.lzma || die "moving ./subarch failed"
	unpack ./subarch.tar.lzma || die "unpacking ./subarch.tar.lzma failed"
	
	mv ./instarchive_all ./instarchive_all.tar.lzma || die "moving ./instarchive_all failed"
	unpack ./instarchive_all.tar.lzma || die "unpacking ./instarchive_all.tar.lzma failed"
	
	if use amd64 ; then
		mv ./instarchive_all_x86_64 ./instarchive_all_x86_64.tar.lzma || die "moving ./instarchive_all_x86_64 failed"
		unpack ./instarchive_all_x86_64.tar.lzma || die "unpacking ./instarchive_all_x86_64.tar.lzma failed"
	elif use x86 ; then
		mv ./instarchive_all_x86 ./instarchive_all_x86.tar.lzma || die "moving ./instarchive_all_x86 failed"
		unpack ./instarchive_all_x86.tar.lzma || die "unpacking ./instarchive_all_x86.tar.lzma failed"
	fi
}

src_prepare() {
	if use amd64 ; then
		mv "./Launcher.bin64" "./Launcher.bin" || die "moving Launcher.bin64 failed"
	fi
	
	if use bundled-libs ; then
		mv ./libs*/all/* ./libs*/ || die "moving bundled libs failed"
		rm -r ./libs*/all || die "removing folder failed"
	else
		mv ./libs*/libIL.so.1 ./ || die "moving devIL library failed"
		rm -r ./libs*/* || die "removing libs folder failed"
		mv ./libIL.so.1 ./libs*/ || die "moving devIL library back failed"
	fi
	
	#remove remaining stuff
	rm ./AmnesiaPDF.png ./checklibs*.sh || die "removing remaining stuff failed"
	
	local system_lang="${LANG%%_*}"
	if [[ "${system_lang}" == "C" ]] ; then
		system_lang="en"
	fi
	local linguas_array=(${LINGUAS// / })
	local use_lang_array=()
	local not_use_lang_array=()
	for use_flag in ${IUSE// / } ; do
		if [[ "${use_flag%%_*}" == "linguas" ]] ; then
			if use "${use_flag}" ; then
				use_lang_array=(${use_lang_array[@]} ${use_flag##linguas_})
			else
				not_use_lang_array=(${not_use_lang_array[@]} ${use_flag##linguas_})
			fi
		fi
	done
	
	#remove useless lingua files
	if [[ "${#not_use_lang_array[@]}" > "0" ]] ; then
		for lang in ${not_use_lang_array[@]} ; do
			case "${lang}" in
				"de") rm -r ./config/base_german.lang ./config/lang_main/german.lang ./config/lang_ptest/german.lang ./EULA_de.rtf ./Manual_de.pdf || die "removing german language files failed";;
				"es") rm -r ./config/lang_main/spanish.lang ./config/lang_ptest/spanish.lang ./config/base_spanish.lang ./EULA_es.rtf ./Manual_es.pdf || die "removing spanish language files failed";;
				"fr") rm -r ./config/lang_main/french.lang ./config/lang_ptest/french.lang ./config/base_french.lang ./EULA_fr.rtf ./Manual_fr.pdf || die "removing french language files failed";;
				"it") rm -r ./config/base_italian.lang ./config/lang_main/italian.lang ./config/lang_ptest/italian.lang ./EULA_it.rtf ./Manual_it.pdf || die "removing italian language files failed";;
				"ru") rm -r ./config/lang_main/russian.lang ./config/lang_ptest/russian.lang ./config/base_russian.lang ./lang/rus || die "removing russian language files failed";;
				"en") if [[ "${#use_lang_array[@]}" > "0" ]] ; then
						rm -r ./config/lang_main/english.lang ./config/lang_ptest/english.lang ./config/base_english.lang ./EULA_en.rtf ./Manual_en.pdf || die "removing english language files failed"
					fi;;
			esac
		done
	fi
	
	#here we set the default language in the default configuration file according to system language or linguas order otherwise we leave it at english
	if [[ "${#use_lang_array[@]}" > "0" ]] ; then
		local chosen_lang=""
		#let's see if there's a used linguas available that matches with the system locale
		for lang in ${use_lang_array[@]} ; do
			if [[ "${lang}" == "${system_lang}" ]] ; then
				chosen_lang="${lang}"
				break
			fi
		done
		#if not let's look at the LINGUAS variable order
		if [[ -z "${chosen_lang}" ]] ; then
			for preferred_lang in ${linguas_array[@]} ; do
				for lang in ${use_lang_array[@]} ; do
					if [[ "${preferred_lang}" == "${lang}" ]] ; then
						chosen_lang="${lang}"
						break 2
					fi
				done
			done
		fi
		#if all else fails take the first used lingua
		if [[ -z "${chosen_lang}" ]] ; then
			chosen_lang="${use_lang_array[0]}"
		fi
		#do the fun stuff by editing the configuration files
		if [[ "${chosen_lang}" != "en" ]] ; then
			case "${chosen_lang}" in
				"de") sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_german\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"german\.lang\"|" -i ./config/main_init.cfg ;
						sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_german\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"german\.lang\"|" -i ./config/ptest_main_init.cfg ;;
				"es") sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_spanish\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"spanish\.lang\"|" -i ./config/main_init.cfg ;
						sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_spanish\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"spanish\.lang\"|" -i ./config/ptest_main_init.cfg ;;
				"fr") sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_french\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"french\.lang\"|" -i ./config/main_init.cfg ;
						sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_french\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"french\.lang\"|" -i ./config/ptest_main_init.cfg ;;
				"it") sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_italian\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"italian\.lang\"|" -i ./config/main_init.cfg ;
						sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_italian\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"italian\.lang\"|" -i ./config/ptest_main_init.cfg ;;
				"ru") sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_russian\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"russian\.lang\"|" -i ./config/main_init.cfg ;
						sed -e "s|DefaultBaseLanguage *=.*$|DefaultBaseLanguage=\"base_russian\.lang\"|" -e "s|DefaultGameLanguage *=.*$|DefaultGameLanguage=\"russian\.lang\"|" -i ./config/ptest_main_init.cfg ;;
			esac
		fi
	fi
}

src_install() {
	local gamedir="${GAMES_PREFIX_OPT}/${PN}"
	exeinto "${gamedir}"
	dodir "${gamedir}"
	doexe ./Launcher.bin ./Amnesia.bin* || die "doexe failed"
	rm ./Launcher.bin ./Amnesia.bin* || die "removing binaries failed"
	doicon ./Amnesia.png || die "doicon failed"
	rm ./Amnesia.png || die "removing icon failed"
	if use doc ; then
		dodoc ./Manual_*.pdf ./EULA_*.rtf || die "dodoc failed"
	fi
	rm ./Manual_*.pdf ./EULA_*.rtf || die "removing docs failed"
	#there may be hidden gems?
	dodoc ./*.pdf ./*.rtf
	rm -f ./*.pdf ./*.rtf
	mv -f ./* "${D}/${gamedir}" || die "moving game files failed"
	games_make_wrapper "${PN}" "./Launcher.bin" "${gamedir}"
	make_desktop_entry "${PN}" "Amnesia: The Dark Descent" "Amnesia"
	prepgamesdirs
}

pkg_postinst() {
	ewarn ""
	ewarn "Amnesia: The Dark Descent needs video drivers"
	ewarn "that provide a complete GLSL 1.20 implementation."
	ewarn ""
	ewarn "Please visit \"http://www.frictionalgames.com/forum/thread-3760.html\""
	ewarn "for more infos."
	ewarn ""
	ewarn "--------------------------------------------------------------------"
	ewarn ""
	ewarn "If you was playing version 1.0 you might experience some oddities"
	ewarn "due to save game differences between 1.0 and 1.0.1."
	ewarn ""
}
