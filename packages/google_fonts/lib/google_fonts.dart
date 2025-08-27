// GENERATED CODE - DO NOT EDIT

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'src/google_fonts_base.dart';
import 'src/google_fonts_parts/part_a.dart';
import 'src/google_fonts_parts/part_b.dart';
import 'src/google_fonts_parts/part_c.dart';
import 'src/google_fonts_parts/part_d.dart';
import 'src/google_fonts_parts/part_e.dart';
import 'src/google_fonts_parts/part_f.dart';
import 'src/google_fonts_parts/part_g.dart';
import 'src/google_fonts_parts/part_h.dart';
import 'src/google_fonts_parts/part_i.dart';
import 'src/google_fonts_parts/part_j.dart';
import 'src/google_fonts_parts/part_k.dart';
import 'src/google_fonts_parts/part_l.dart';
import 'src/google_fonts_parts/part_m.dart';
import 'src/google_fonts_parts/part_n.dart';
import 'src/google_fonts_parts/part_o.dart';
import 'src/google_fonts_parts/part_p.dart';
import 'src/google_fonts_parts/part_q.dart';
import 'src/google_fonts_parts/part_r.dart';
import 'src/google_fonts_parts/part_s.dart';
import 'src/google_fonts_parts/part_t.dart';
import 'src/google_fonts_parts/part_u.dart';
import 'src/google_fonts_parts/part_v.dart';
import 'src/google_fonts_parts/part_w.dart';
import 'src/google_fonts_parts/part_x.dart';
import 'src/google_fonts_parts/part_y.dart';
import 'src/google_fonts_parts/part_z.dart';

/// A collection of properties used to specify custom behavior of the
/// GoogleFonts library.
class _Config {
  /// Whether or not the GoogleFonts library can make requests to
  /// [fonts.google.com](https://fonts.google.com/) to retrieve font files.
  var allowRuntimeFetching = true;
}

/// Provides configuration, and static methods to obtain [TextStyle]s and [TextTheme]s.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=8Vzv2CdbEY0}
///
/// Obtain a map of available fonts with [asMap]. Retrieve a font by family name
/// with [getFont]. Retrieve a text theme by its font family name [getTextTheme].
///
/// Check out the [README](https://github.com/material-foundation/flutter-packages/blob/main/packages/google_fonts/README.md) for more info.
class GoogleFonts {
  /// Configuration for the [GoogleFonts] library.
  ///
  /// Use this to define custom behavior of the GoogleFonts library in your app.
  /// For example, if you do not want the GoogleFonts library to make any HTTP
  /// requests for fonts, add the following snippet to your app's `main` method.
  ///
  /// ```dart
  /// GoogleFonts.config.allowRuntimeFetching = false;
  /// ```
  static final config = _Config();

  /// Returns a [Future] which resolves when requested fonts have finished
  /// loading and are ready to be rendered on screen.
  ///
  /// Usage:
  /// ```dart
  /// GoogleFonts.lato();
  /// GoogleFonts.pacificoTextTheme();
  /// await GoogleFonts.pendingFonts(); // <-- waits until Lato and Pacifico files have loaded.
  /// ```
  ///
  /// To keep things tidy, on can also pass in requested fonts as a list
  /// to [pendingFonts].
  ///
  /// ```dart
  /// await GoogleFonts.pendingFonts([
  ///   GoogleFonts.lato(),
  ///   GoogleFonts.pacificoTextTheme()
  /// ]);
  /// ```
  ///
  /// To avoid visual font swaps that occur when a font is loading,
  /// consider using [FutureBuilder]. Note: This future cannot be created in
  /// [build], as described in [FutureBuilder]'s documentation.
  ///
  /// ```dart
  /// late Future googleFontsPending;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   googleFontsPending = GoogleFonts.pendingFonts([
  ///     ...
  ///   ]);
  /// }
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return FutureBuilder(
  ///     future: googleFontsPending,
  ///     builder: (context, snapshot) {
  ///       if (snapshot.connectionState != ConnectionState.done) {
  ///         return const SizedBox();
  ///       }
  ///       ...
  ///     }
  ///   );
  /// }
  /// ```
  static Future<List<void>> pendingFonts([List<dynamic>? _]) =>
      Future.wait(pendingFontFutures);

  /// Get a map of all available fonts.
  ///
  /// Returns a map where the key is the name of the font family and the value
  /// is the corresponding [GoogleFonts] method.
  static Map<
      String,
      TextStyle Function({
        TextStyle? textStyle,
        Color? color,
        Color? backgroundColor,
        double? fontSize,
        FontWeight? fontWeight,
        FontStyle? fontStyle,
        double? letterSpacing,
        double? wordSpacing,
        TextBaseline? textBaseline,
        double? height,
        Locale? locale,
        Paint? foreground,
        Paint? background,
        List<ui.Shadow>? shadows,
        List<ui.FontFeature>? fontFeatures,
        TextDecoration? decoration,
        Color? decorationColor,
        TextDecorationStyle? decorationStyle,
        double? decorationThickness,
      })> asMap() => const {
        'ABeeZee': PartA.aBeeZee,
        'ADLaM Display': PartA.aDLaMDisplay,
        'AR One Sans': PartA.arOneSans,
        'Abel': PartA.abel,
        'Abhaya Libre': PartA.abhayaLibre,
        'Aboreto': PartA.aboreto,
        'Abril Fatface': PartA.abrilFatface,
        'Abyssinica SIL': PartA.abyssinicaSil,
        'Aclonica': PartA.aclonica,
        'Acme': PartA.acme,
        'Actor': PartA.actor,
        'Adamina': PartA.adamina,
        'Advent Pro': PartA.adventPro,
        'Afacad': PartA.afacad,
        'Agbalumo': PartA.agbalumo,
        'Agdasima': PartA.agdasima,
        'Aguafina Script': PartA.aguafinaScript,
        'Akatab': PartA.akatab,
        'Akaya Kanadaka': PartA.akayaKanadaka,
        'Akaya Telivigala': PartA.akayaTelivigala,
        'Akronim': PartA.akronim,
        'Akshar': PartA.akshar,
        'Aladin': PartA.aladin,
        'Alata': PartA.alata,
        'Alatsi': PartA.alatsi,
        'Albert Sans': PartA.albertSans,
        'Aldrich': PartA.aldrich,
        'Alef': PartA.alef,
        'Alegreya': PartA.alegreya,
        'Alegreya SC': PartA.alegreyaSc,
        'Alegreya Sans': PartA.alegreyaSans,
        'Alegreya Sans SC': PartA.alegreyaSansSc,
        'Aleo': PartA.aleo,
        'Alex Brush': PartA.alexBrush,
        'Alexandria': PartA.alexandria,
        'Alfa Slab One': PartA.alfaSlabOne,
        'Alice': PartA.alice,
        'Alike': PartA.alike,
        'Alike Angular': PartA.alikeAngular,
        'Alkalami': PartA.alkalami,
        'Alkatra': PartA.alkatra,
        'Allan': PartA.allan,
        'Allerta': PartA.allerta,
        'Allerta Stencil': PartA.allertaStencil,
        'Allison': PartA.allison,
        'Allura': PartA.allura,
        'Almarai': PartA.almarai,
        'Almendra': PartA.almendra,
        'Almendra Display': PartA.almendraDisplay,
        'Almendra SC': PartA.almendraSc,
        'Alumni Sans': PartA.alumniSans,
        'Alumni Sans Collegiate One': PartA.alumniSansCollegiateOne,
        'Alumni Sans Inline One': PartA.alumniSansInlineOne,
        'Alumni Sans Pinstripe': PartA.alumniSansPinstripe,
        'Amarante': PartA.amarante,
        'Amaranth': PartA.amaranth,
        'Amatic SC': PartA.amaticSc,
        'Amethysta': PartA.amethysta,
        'Amiko': PartA.amiko,
        'Amiri': PartA.amiri,
        'Amiri Quran': PartA.amiriQuran,
        'Amita': PartA.amita,
        'Anaheim': PartA.anaheim,
        'Andada Pro': PartA.andadaPro,
        'Andika': PartA.andika,
        'Anek Bangla': PartA.anekBangla,
        'Anek Devanagari': PartA.anekDevanagari,
        'Anek Gujarati': PartA.anekGujarati,
        'Anek Gurmukhi': PartA.anekGurmukhi,
        'Anek Kannada': PartA.anekKannada,
        'Anek Latin': PartA.anekLatin,
        'Anek Malayalam': PartA.anekMalayalam,
        'Anek Odia': PartA.anekOdia,
        'Anek Tamil': PartA.anekTamil,
        'Anek Telugu': PartA.anekTelugu,
        'Angkor': PartA.angkor,
        'Annapurna SIL': PartA.annapurnaSil,
        'Annie Use Your Telescope': PartA.annieUseYourTelescope,
        'Anonymous Pro': PartA.anonymousPro,
        'Anta': PartA.anta,
        'Antic': PartA.antic,
        'Antic Didone': PartA.anticDidone,
        'Antic Slab': PartA.anticSlab,
        'Anton': PartA.anton,
        'Anton SC': PartA.antonSc,
        'Antonio': PartA.antonio,
        'Anuphan': PartA.anuphan,
        'Anybody': PartA.anybody,
        'Aoboshi One': PartA.aoboshiOne,
        'Arapey': PartA.arapey,
        'Arbutus': PartA.arbutus,
        'Arbutus Slab': PartA.arbutusSlab,
        'Architects Daughter': PartA.architectsDaughter,
        'Archivo': PartA.archivo,
        'Archivo Black': PartA.archivoBlack,
        'Archivo Narrow': PartA.archivoNarrow,
        'Are You Serious': PartA.areYouSerious,
        'Aref Ruqaa': PartA.arefRuqaa,
        'Aref Ruqaa Ink': PartA.arefRuqaaInk,
        'Arima': PartA.arima,
        'Arimo': PartA.arimo,
        'Arizonia': PartA.arizonia,
        'Armata': PartA.armata,
        'Arsenal': PartA.arsenal,
        'Arsenal SC': PartA.arsenalSc,
        'Artifika': PartA.artifika,
        'Arvo': PartA.arvo,
        'Arya': PartA.arya,
        'Asap': PartA.asap,
        'Asap Condensed': PartA.asapCondensed,
        'Asar': PartA.asar,
        'Asset': PartA.asset,
        'Assistant': PartA.assistant,
        'Astloch': PartA.astloch,
        'Asul': PartA.asul,
        'Athiti': PartA.athiti,
        'Atkinson Hyperlegible': PartA.atkinsonHyperlegible,
        'Atma': PartA.atma,
        'Atomic Age': PartA.atomicAge,
        'Aubrey': PartA.aubrey,
        'Audiowide': PartA.audiowide,
        'Autour One': PartA.autourOne,
        'Average': PartA.average,
        'Average Sans': PartA.averageSans,
        'Averia Gruesa Libre': PartA.averiaGruesaLibre,
        'Averia Libre': PartA.averiaLibre,
        'Averia Sans Libre': PartA.averiaSansLibre,
        'Averia Serif Libre': PartA.averiaSerifLibre,
        'Azeret Mono': PartA.azeretMono,
        'B612': PartB.b612,
        'B612 Mono': PartB.b612Mono,
        'BIZ UDGothic': PartB.bizUDGothic,
        'BIZ UDMincho': PartB.bizUDMincho,
        'BIZ UDPGothic': PartB.bizUDPGothic,
        'BIZ UDPMincho': PartB.bizUDPMincho,
        'Babylonica': PartB.babylonica,
        'Bacasime Antique': PartB.bacasimeAntique,
        'Bad Script': PartB.badScript,
        'Bagel Fat One': PartB.bagelFatOne,
        'Bahiana': PartB.bahiana,
        'Bahianita': PartB.bahianita,
        'Bai Jamjuree': PartB.baiJamjuree,
        'Bakbak One': PartB.bakbakOne,
        'Ballet': PartB.ballet,
        'Baloo 2': PartB.baloo2,
        'Baloo Bhai 2': PartB.balooBhai2,
        'Baloo Bhaijaan 2': PartB.balooBhaijaan2,
        'Baloo Bhaina 2': PartB.balooBhaina2,
        'Baloo Chettan 2': PartB.balooChettan2,
        'Baloo Da 2': PartB.balooDa2,
        'Baloo Paaji 2': PartB.balooPaaji2,
        'Baloo Tamma 2': PartB.balooTamma2,
        'Baloo Tammudu 2': PartB.balooTammudu2,
        'Baloo Thambi 2': PartB.balooThambi2,
        'Balsamiq Sans': PartB.balsamiqSans,
        'Balthazar': PartB.balthazar,
        'Bangers': PartB.bangers,
        'Barlow': PartB.barlow,
        'Barlow Condensed': PartB.barlowCondensed,
        'Barlow Semi Condensed': PartB.barlowSemiCondensed,
        'Barriecito': PartB.barriecito,
        'Barrio': PartB.barrio,
        'Basic': PartB.basic,
        'Baskervville': PartB.baskervville,
        'Baskervville SC': PartB.baskervvilleSc,
        'Battambang': PartB.battambang,
        'Baumans': PartB.baumans,
        'Bayon': PartB.bayon,
        'Be Vietnam Pro': PartB.beVietnamPro,
        'Beau Rivage': PartB.beauRivage,
        'Bebas Neue': PartB.bebasNeue,
        'Beiruti': PartB.beiruti,
        'Belanosima': PartB.belanosima,
        'Belgrano': PartB.belgrano,
        'Bellefair': PartB.bellefair,
        'Belleza': PartB.belleza,
        'Bellota': PartB.bellota,
        'Bellota Text': PartB.bellotaText,
        'BenchNine': PartB.benchNine,
        'Benne': PartB.benne,
        'Bentham': PartB.bentham,
        'Berkshire Swash': PartB.berkshireSwash,
        'Besley': PartB.besley,
        'Beth Ellen': PartB.bethEllen,
        'Bevan': PartB.bevan,
        'BhuTuka Expanded One': PartB.bhuTukaExpandedOne,
        'Big Shoulders Display': PartB.bigShouldersDisplay,
        'Big Shoulders Inline Display': PartB.bigShouldersInlineDisplay,
        'Big Shoulders Inline Text': PartB.bigShouldersInlineText,
        'Big Shoulders Stencil Display': PartB.bigShouldersStencilDisplay,
        'Big Shoulders Stencil Text': PartB.bigShouldersStencilText,
        'Big Shoulders Text': PartB.bigShouldersText,
        'Bigelow Rules': PartB.bigelowRules,
        'Bigshot One': PartB.bigshotOne,
        'Bilbo': PartB.bilbo,
        'Bilbo Swash Caps': PartB.bilboSwashCaps,
        'BioRhyme': PartB.bioRhyme,
        'BioRhyme Expanded': PartB.bioRhymeExpanded,
        'Birthstone': PartB.birthstone,
        'Birthstone Bounce': PartB.birthstoneBounce,
        'Biryani': PartB.biryani,
        'Bitter': PartB.bitter,
        'Black And White Picture': PartB.blackAndWhitePicture,
        'Black Han Sans': PartB.blackHanSans,
        'Black Ops One': PartB.blackOpsOne,
        'Blaka': PartB.blaka,
        'Blaka Hollow': PartB.blakaHollow,
        'Blaka Ink': PartB.blakaInk,
        'Blinker': PartB.blinker,
        'Bodoni Moda': PartB.bodoniModa,
        'Bodoni Moda SC': PartB.bodoniModaSc,
        'Bokor': PartB.bokor,
        'Bona Nova': PartB.bonaNova,
        'Bona Nova SC': PartB.bonaNovaSc,
        'Bonbon': PartB.bonbon,
        'Bonheur Royale': PartB.bonheurRoyale,
        'Boogaloo': PartB.boogaloo,
        'Borel': PartB.borel,
        'Bowlby One': PartB.bowlbyOne,
        'Bowlby One SC': PartB.bowlbyOneSc,
        'Braah One': PartB.braahOne,
        'Brawler': PartB.brawler,
        'Bree Serif': PartB.breeSerif,
        'Bricolage Grotesque': PartB.bricolageGrotesque,
        'Bruno Ace': PartB.brunoAce,
        'Bruno Ace SC': PartB.brunoAceSc,
        'Brygada 1918': PartB.brygada1918,
        'Bubblegum Sans': PartB.bubblegumSans,
        'Bubbler One': PartB.bubblerOne,
        'Buda': PartB.buda,
        'Buenard': PartB.buenard,
        'Bungee': PartB.bungee,
        'Bungee Hairline': PartB.bungeeHairline,
        'Bungee Inline': PartB.bungeeInline,
        'Bungee Outline': PartB.bungeeOutline,
        'Bungee Shade': PartB.bungeeShade,
        'Bungee Spice': PartB.bungeeSpice,
        'Butcherman': PartB.butcherman,
        'Butterfly Kids': PartB.butterflyKids,
        'Cabin': PartC.cabin,
        'Cabin Condensed': PartC.cabinCondensed,
        'Cabin Sketch': PartC.cabinSketch,
        'Cactus Classical Serif': PartC.cactusClassicalSerif,
        'Caesar Dressing': PartC.caesarDressing,
        'Cagliostro': PartC.cagliostro,
        'Cairo': PartC.cairo,
        'Cairo Play': PartC.cairoPlay,
        'Caladea': PartC.caladea,
        'Calistoga': PartC.calistoga,
        'Calligraffitti': PartC.calligraffitti,
        'Cambay': PartC.cambay,
        'Cambo': PartC.cambo,
        'Candal': PartC.candal,
        'Cantarell': PartC.cantarell,
        'Cantata One': PartC.cantataOne,
        'Cantora One': PartC.cantoraOne,
        'Caprasimo': PartC.caprasimo,
        'Capriola': PartC.capriola,
        'Caramel': PartC.caramel,
        'Carattere': PartC.carattere,
        'Cardo': PartC.cardo,
        'Carlito': PartC.carlito,
        'Carme': PartC.carme,
        'Carrois Gothic': PartC.carroisGothic,
        'Carrois Gothic SC': PartC.carroisGothicSc,
        'Carter One': PartC.carterOne,
        'Castoro': PartC.castoro,
        'Castoro Titling': PartC.castoroTitling,
        'Catamaran': PartC.catamaran,
        'Caudex': PartC.caudex,
        'Caveat': PartC.caveat,
        'Caveat Brush': PartC.caveatBrush,
        'Cedarville Cursive': PartC.cedarvilleCursive,
        'Ceviche One': PartC.cevicheOne,
        'Chakra Petch': PartC.chakraPetch,
        'Changa': PartC.changa,
        'Changa One': PartC.changaOne,
        'Chango': PartC.chango,
        'Charis SIL': PartC.charisSil,
        'Charm': PartC.charm,
        'Charmonman': PartC.charmonman,
        'Chathura': PartC.chathura,
        'Chau Philomene One': PartC.chauPhilomeneOne,
        'Chela One': PartC.chelaOne,
        'Chelsea Market': PartC.chelseaMarket,
        'Chenla': PartC.chenla,
        'Cherish': PartC.cherish,
        'Cherry Bomb One': PartC.cherryBombOne,
        'Cherry Cream Soda': PartC.cherryCreamSoda,
        'Cherry Swash': PartC.cherrySwash,
        'Chewy': PartC.chewy,
        'Chicle': PartC.chicle,
        'Chilanka': PartC.chilanka,
        'Chivo': PartC.chivo,
        'Chivo Mono': PartC.chivoMono,
        'Chocolate Classical Sans': PartC.chocolateClassicalSans,
        'Chokokutai': PartC.chokokutai,
        'Chonburi': PartC.chonburi,
        'Cinzel': PartC.cinzel,
        'Cinzel Decorative': PartC.cinzelDecorative,
        'Clicker Script': PartC.clickerScript,
        'Climate Crisis': PartC.climateCrisis,
        'Coda': PartC.coda,
        'Codystar': PartC.codystar,
        'Coiny': PartC.coiny,
        'Combo': PartC.combo,
        'Comfortaa': PartC.comfortaa,
        'Comforter': PartC.comforter,
        'Comforter Brush': PartC.comforterBrush,
        'Comic Neue': PartC.comicNeue,
        'Coming Soon': PartC.comingSoon,
        'Comme': PartC.comme,
        'Commissioner': PartC.commissioner,
        'Concert One': PartC.concertOne,
        'Condiment': PartC.condiment,
        'Content': PartC.content,
        'Contrail One': PartC.contrailOne,
        'Convergence': PartC.convergence,
        'Cookie': PartC.cookie,
        'Copse': PartC.copse,
        'Corben': PartC.corben,
        'Corinthia': PartC.corinthia,
        'Cormorant': PartC.cormorant,
        'Cormorant Garamond': PartC.cormorantGaramond,
        'Cormorant Infant': PartC.cormorantInfant,
        'Cormorant SC': PartC.cormorantSc,
        'Cormorant Unicase': PartC.cormorantUnicase,
        'Cormorant Upright': PartC.cormorantUpright,
        'Courgette': PartC.courgette,
        'Courier Prime': PartC.courierPrime,
        'Cousine': PartC.cousine,
        'Coustard': PartC.coustard,
        'Covered By Your Grace': PartC.coveredByYourGrace,
        'Crafty Girls': PartC.craftyGirls,
        'Creepster': PartC.creepster,
        'Crete Round': PartC.creteRound,
        'Crimson Pro': PartC.crimsonPro,
        'Crimson Text': PartC.crimsonText,
        'Croissant One': PartC.croissantOne,
        'Crushed': PartC.crushed,
        'Cuprum': PartC.cuprum,
        'Cute Font': PartC.cuteFont,
        'Cutive': PartC.cutive,
        'Cutive Mono': PartC.cutiveMono,
        'DM Mono': PartD.dmMono,
        'DM Sans': PartD.dmSans,
        'DM Serif Display': PartD.dmSerifDisplay,
        'DM Serif Text': PartD.dmSerifText,
        'Dai Banna SIL': PartD.daiBannaSil,
        'Damion': PartD.damion,
        'Dancing Script': PartD.dancingScript,
        'Danfo': PartD.danfo,
        'Dangrek': PartD.dangrek,
        'Darker Grotesque': PartD.darkerGrotesque,
        'Darumadrop One': PartD.darumadropOne,
        'David Libre': PartD.davidLibre,
        'Dawning of a New Day': PartD.dawningOfANewDay,
        'Days One': PartD.daysOne,
        'Dekko': PartD.dekko,
        'Dela Gothic One': PartD.delaGothicOne,
        'Delicious Handrawn': PartD.deliciousHandrawn,
        'Delius': PartD.delius,
        'Delius Swash Caps': PartD.deliusSwashCaps,
        'Delius Unicase': PartD.deliusUnicase,
        'Della Respira': PartD.dellaRespira,
        'Denk One': PartD.denkOne,
        'Devonshire': PartD.devonshire,
        'Dhurjati': PartD.dhurjati,
        'Didact Gothic': PartD.didactGothic,
        'Diphylleia': PartD.diphylleia,
        'Diplomata': PartD.diplomata,
        'Diplomata SC': PartD.diplomataSc,
        'Do Hyeon': PartD.doHyeon,
        'Dokdo': PartD.dokdo,
        'Domine': PartD.domine,
        'Donegal One': PartD.donegalOne,
        'Dongle': PartD.dongle,
        'Doppio One': PartD.doppioOne,
        'Dorsa': PartD.dorsa,
        'Dosis': PartD.dosis,
        'DotGothic16': PartD.dotGothic16,
        'Dr Sugiyama': PartD.drSugiyama,
        'Duru Sans': PartD.duruSans,
        'DynaPuff': PartD.dynaPuff,
        'Dynalight': PartD.dynalight,
        'EB Garamond': PartE.ebGaramond,
        'Eagle Lake': PartE.eagleLake,
        'East Sea Dokdo': PartE.eastSeaDokdo,
        'Eater': PartE.eater,
        'Economica': PartE.economica,
        'Eczar': PartE.eczar,
        'Edu AU VIC WA NT Hand': PartE.eduAuVicWaNtHand,
        'Edu NSW ACT Foundation': PartE.eduNswActFoundation,
        'Edu QLD Beginner': PartE.eduQldBeginner,
        'Edu SA Beginner': PartE.eduSaBeginner,
        'Edu TAS Beginner': PartE.eduTasBeginner,
        'Edu VIC WA NT Beginner': PartE.eduVicWaNtBeginner,
        'El Messiri': PartE.elMessiri,
        'Electrolize': PartE.electrolize,
        'Elsie': PartE.elsie,
        'Elsie Swash Caps': PartE.elsieSwashCaps,
        'Emblema One': PartE.emblemaOne,
        'Emilys Candy': PartE.emilysCandy,
        'Encode Sans': PartE.encodeSans,
        'Encode Sans Condensed': PartE.encodeSansCondensed,
        'Encode Sans Expanded': PartE.encodeSansExpanded,
        'Encode Sans SC': PartE.encodeSansSc,
        'Encode Sans Semi Condensed': PartE.encodeSansSemiCondensed,
        'Encode Sans Semi Expanded': PartE.encodeSansSemiExpanded,
        'Engagement': PartE.engagement,
        'Englebert': PartE.englebert,
        'Enriqueta': PartE.enriqueta,
        'Ephesis': PartE.ephesis,
        'Epilogue': PartE.epilogue,
        'Erica One': PartE.ericaOne,
        'Esteban': PartE.esteban,
        'Estonia': PartE.estonia,
        'Euphoria Script': PartE.euphoriaScript,
        'Ewert': PartE.ewert,
        'Exo': PartE.exo,
        'Exo 2': PartE.exo2,
        'Expletus Sans': PartE.expletusSans,
        'Explora': PartE.explora,
        'Fahkwang': PartF.fahkwang,
        'Familjen Grotesk': PartF.familjenGrotesk,
        'Fanwood Text': PartF.fanwoodText,
        'Farro': PartF.farro,
        'Farsan': PartF.farsan,
        'Fascinate': PartF.fascinate,
        'Fascinate Inline': PartF.fascinateInline,
        'Faster One': PartF.fasterOne,
        'Fasthand': PartF.fasthand,
        'Fauna One': PartF.faunaOne,
        'Faustina': PartF.faustina,
        'Federant': PartF.federant,
        'Federo': PartF.federo,
        'Felipa': PartF.felipa,
        'Fenix': PartF.fenix,
        'Festive': PartF.festive,
        'Figtree': PartF.figtree,
        'Finger Paint': PartF.fingerPaint,
        'Finlandica': PartF.finlandica,
        'Fira Code': PartF.firaCode,
        'Fira Mono': PartF.firaMono,
        'Fira Sans': PartF.firaSans,
        'Fira Sans Condensed': PartF.firaSansCondensed,
        'Fira Sans Extra Condensed': PartF.firaSansExtraCondensed,
        'Fjalla One': PartF.fjallaOne,
        'Fjord One': PartF.fjordOne,
        'Flamenco': PartF.flamenco,
        'Flavors': PartF.flavors,
        'Fleur De Leah': PartF.fleurDeLeah,
        'Flow Block': PartF.flowBlock,
        'Flow Circular': PartF.flowCircular,
        'Flow Rounded': PartF.flowRounded,
        'Foldit': PartF.foldit,
        'Fondamento': PartF.fondamento,
        'Fontdiner Swanky': PartF.fontdinerSwanky,
        'Forum': PartF.forum,
        'Fragment Mono': PartF.fragmentMono,
        'Francois One': PartF.francoisOne,
        'Frank Ruhl Libre': PartF.frankRuhlLibre,
        'Fraunces': PartF.fraunces,
        'Freckle Face': PartF.freckleFace,
        'Fredericka the Great': PartF.frederickaTheGreat,
        'Fredoka': PartF.fredoka,
        'Freehand': PartF.freehand,
        'Freeman': PartF.freeman,
        'Fresca': PartF.fresca,
        'Frijole': PartF.frijole,
        'Fruktur': PartF.fruktur,
        'Fugaz One': PartF.fugazOne,
        'Fuggles': PartF.fuggles,
        'Fustat': PartF.fustat,
        'Fuzzy Bubbles': PartF.fuzzyBubbles,
        'GFS Didot': PartG.gfsDidot,
        'GFS Neohellenic': PartG.gfsNeohellenic,
        'Ga Maamli': PartG.gaMaamli,
        'Gabarito': PartG.gabarito,
        'Gabriela': PartG.gabriela,
        'Gaegu': PartG.gaegu,
        'Gafata': PartG.gafata,
        'Gajraj One': PartG.gajrajOne,
        'Galada': PartG.galada,
        'Galdeano': PartG.galdeano,
        'Galindo': PartG.galindo,
        'Gamja Flower': PartG.gamjaFlower,
        'Gantari': PartG.gantari,
        'Gasoek One': PartG.gasoekOne,
        'Gayathri': PartG.gayathri,
        'Gelasio': PartG.gelasio,
        'Gemunu Libre': PartG.gemunuLibre,
        'Genos': PartG.genos,
        'Gentium Book Plus': PartG.gentiumBookPlus,
        'Gentium Plus': PartG.gentiumPlus,
        'Geo': PartG.geo,
        'Geologica': PartG.geologica,
        'Georama': PartG.georama,
        'Geostar': PartG.geostar,
        'Geostar Fill': PartG.geostarFill,
        'Germania One': PartG.germaniaOne,
        'Gideon Roman': PartG.gideonRoman,
        'Gidugu': PartG.gidugu,
        'Gilda Display': PartG.gildaDisplay,
        'Girassol': PartG.girassol,
        'Give You Glory': PartG.giveYouGlory,
        'Glass Antiqua': PartG.glassAntiqua,
        'Glegoo': PartG.glegoo,
        'Gloock': PartG.gloock,
        'Gloria Hallelujah': PartG.gloriaHallelujah,
        'Glory': PartG.glory,
        'Gluten': PartG.gluten,
        'Goblin One': PartG.goblinOne,
        'Gochi Hand': PartG.gochiHand,
        'Goldman': PartG.goldman,
        'Golos Text': PartG.golosText,
        'Gorditas': PartG.gorditas,
        'Gothic A1': PartG.gothicA1,
        'Gotu': PartG.gotu,
        'Goudy Bookletter 1911': PartG.goudyBookletter1911,
        'Gowun Batang': PartG.gowunBatang,
        'Gowun Dodum': PartG.gowunDodum,
        'Graduate': PartG.graduate,
        'Grand Hotel': PartG.grandHotel,
        'Grandiflora One': PartG.grandifloraOne,
        'Grandstander': PartG.grandstander,
        'Grape Nuts': PartG.grapeNuts,
        'Gravitas One': PartG.gravitasOne,
        'Great Vibes': PartG.greatVibes,
        'Grechen Fuemen': PartG.grechenFuemen,
        'Grenze': PartG.grenze,
        'Grenze Gotisch': PartG.grenzeGotisch,
        'Grey Qo': PartG.greyQo,
        'Griffy': PartG.griffy,
        'Gruppo': PartG.gruppo,
        'Gudea': PartG.gudea,
        'Gugi': PartG.gugi,
        'Gulzar': PartG.gulzar,
        'Gupter': PartG.gupter,
        'Gurajada': PartG.gurajada,
        'Gwendolyn': PartG.gwendolyn,
        'Habibi': PartH.habibi,
        'Hachi Maru Pop': PartH.hachiMaruPop,
        'Hahmlet': PartH.hahmlet,
        'Halant': PartH.halant,
        'Hammersmith One': PartH.hammersmithOne,
        'Hanalei': PartH.hanalei,
        'Hanalei Fill': PartH.hanaleiFill,
        'Handjet': PartH.handjet,
        'Handlee': PartH.handlee,
        'Hanken Grotesk': PartH.hankenGrotesk,
        'Hanuman': PartH.hanuman,
        'Happy Monkey': PartH.happyMonkey,
        'Harmattan': PartH.harmattan,
        'Headland One': PartH.headlandOne,
        'Hedvig Letters Sans': PartH.hedvigLettersSans,
        'Hedvig Letters Serif': PartH.hedvigLettersSerif,
        'Heebo': PartH.heebo,
        'Henny Penny': PartH.hennyPenny,
        'Hepta Slab': PartH.heptaSlab,
        'Herr Von Muellerhoff': PartH.herrVonMuellerhoff,
        'Hi Melody': PartH.hiMelody,
        'Hina Mincho': PartH.hinaMincho,
        'Hind': PartH.hind,
        'Hind Guntur': PartH.hindGuntur,
        'Hind Madurai': PartH.hindMadurai,
        'Hind Siliguri': PartH.hindSiliguri,
        'Hind Vadodara': PartH.hindVadodara,
        'Holtwood One SC': PartH.holtwoodOneSc,
        'Homemade Apple': PartH.homemadeApple,
        'Homenaje': PartH.homenaje,
        'Honk': PartH.honk,
        'Hubballi': PartH.hubballi,
        'Hurricane': PartH.hurricane,
        'IBM Plex Mono': PartI.ibmPlexMono,
        'IBM Plex Sans': PartI.ibmPlexSans,
        'IBM Plex Sans Arabic': PartI.ibmPlexSansArabic,
        'IBM Plex Sans Condensed': PartI.ibmPlexSansCondensed,
        'IBM Plex Sans Devanagari': PartI.ibmPlexSansDevanagari,
        'IBM Plex Sans Hebrew': PartI.ibmPlexSansHebrew,
        'IBM Plex Sans JP': PartI.ibmPlexSansJp,
        'IBM Plex Sans KR': PartI.ibmPlexSansKr,
        'IBM Plex Sans Thai': PartI.ibmPlexSansThai,
        'IBM Plex Sans Thai Looped': PartI.ibmPlexSansThaiLooped,
        'IBM Plex Serif': PartI.ibmPlexSerif,
        'IM Fell DW Pica': PartI.imFellDwPica,
        'IM Fell DW Pica SC': PartI.imFellDwPicaSc,
        'IM Fell Double Pica': PartI.imFellDoublePica,
        'IM Fell Double Pica SC': PartI.imFellDoublePicaSc,
        'IM Fell English': PartI.imFellEnglish,
        'IM Fell English SC': PartI.imFellEnglishSc,
        'IM Fell French Canon': PartI.imFellFrenchCanon,
        'IM Fell French Canon SC': PartI.imFellFrenchCanonSc,
        'IM Fell Great Primer': PartI.imFellGreatPrimer,
        'IM Fell Great Primer SC': PartI.imFellGreatPrimerSc,
        'Ibarra Real Nova': PartI.ibarraRealNova,
        'Iceberg': PartI.iceberg,
        'Iceland': PartI.iceland,
        'Imbue': PartI.imbue,
        'Imperial Script': PartI.imperialScript,
        'Imprima': PartI.imprima,
        'Inclusive Sans': PartI.inclusiveSans,
        'Inconsolata': PartI.inconsolata,
        'Inder': PartI.inder,
        'Indie Flower': PartI.indieFlower,
        'Ingrid Darling': PartI.ingridDarling,
        'Inika': PartI.inika,
        'Inknut Antiqua': PartI.inknutAntiqua,
        'Inria Sans': PartI.inriaSans,
        'Inria Serif': PartI.inriaSerif,
        'Inspiration': PartI.inspiration,
        'Instrument Sans': PartI.instrumentSans,
        'Instrument Serif': PartI.instrumentSerif,
        'Inter': PartI.inter,
        'Inter Tight': PartI.interTight,
        'Irish Grover': PartI.irishGrover,
        'Island Moments': PartI.islandMoments,
        'Istok Web': PartI.istokWeb,
        'Italiana': PartI.italiana,
        'Italianno': PartI.italianno,
        'Itim': PartI.itim,
        'Jacquard 12': PartJ.jacquard12,
        'Jacquard 12 Charted': PartJ.jacquard12Charted,
        'Jacquard 24': PartJ.jacquard24,
        'Jacquard 24 Charted': PartJ.jacquard24Charted,
        'Jacquarda Bastarda 9': PartJ.jacquardaBastarda9,
        'Jacquarda Bastarda 9 Charted': PartJ.jacquardaBastarda9Charted,
        'Jacques Francois': PartJ.jacquesFrancois,
        'Jacques Francois Shadow': PartJ.jacquesFrancoisShadow,
        'Jaini': PartJ.jaini,
        'Jaini Purva': PartJ.jainiPurva,
        'Jaldi': PartJ.jaldi,
        'Jaro': PartJ.jaro,
        'Jersey 10': PartJ.jersey10,
        'Jersey 10 Charted': PartJ.jersey10Charted,
        'Jersey 15': PartJ.jersey15,
        'Jersey 15 Charted': PartJ.jersey15Charted,
        'Jersey 20': PartJ.jersey20,
        'Jersey 20 Charted': PartJ.jersey20Charted,
        'Jersey 25': PartJ.jersey25,
        'Jersey 25 Charted': PartJ.jersey25Charted,
        'JetBrains Mono': PartJ.jetBrainsMono,
        'Jim Nightshade': PartJ.jimNightshade,
        'Joan': PartJ.joan,
        'Jockey One': PartJ.jockeyOne,
        'Jolly Lodger': PartJ.jollyLodger,
        'Jomhuria': PartJ.jomhuria,
        'Jomolhari': PartJ.jomolhari,
        'Josefin Sans': PartJ.josefinSans,
        'Josefin Slab': PartJ.josefinSlab,
        'Jost': PartJ.jost,
        'Joti One': PartJ.jotiOne,
        'Jua': PartJ.jua,
        'Judson': PartJ.judson,
        'Julee': PartJ.julee,
        'Julius Sans One': PartJ.juliusSansOne,
        'Junge': PartJ.junge,
        'Jura': PartJ.jura,
        'Just Another Hand': PartJ.justAnotherHand,
        'Just Me Again Down Here': PartJ.justMeAgainDownHere,
        'K2D': PartK.k2d,
        'Kablammo': PartK.kablammo,
        'Kadwa': PartK.kadwa,
        'Kaisei Decol': PartK.kaiseiDecol,
        'Kaisei HarunoUmi': PartK.kaiseiHarunoUmi,
        'Kaisei Opti': PartK.kaiseiOpti,
        'Kaisei Tokumin': PartK.kaiseiTokumin,
        'Kalam': PartK.kalam,
        'Kalnia': PartK.kalnia,
        'Kalnia Glaze': PartK.kalniaGlaze,
        'Kameron': PartK.kameron,
        'Kanit': PartK.kanit,
        'Kantumruy Pro': PartK.kantumruyPro,
        'Karantina': PartK.karantina,
        'Karla': PartK.karla,
        'Karma': PartK.karma,
        'Katibeh': PartK.katibeh,
        'Kaushan Script': PartK.kaushanScript,
        'Kavivanar': PartK.kavivanar,
        'Kavoon': PartK.kavoon,
        'Kay Pho Du': PartK.kayPhoDu,
        'Kdam Thmor Pro': PartK.kdamThmorPro,
        'Keania One': PartK.keaniaOne,
        'Kelly Slab': PartK.kellySlab,
        'Kenia': PartK.kenia,
        'Khand': PartK.khand,
        'Khmer': PartK.khmer,
        'Khula': PartK.khula,
        'Kings': PartK.kings,
        'Kirang Haerang': PartK.kirangHaerang,
        'Kite One': PartK.kiteOne,
        'Kiwi Maru': PartK.kiwiMaru,
        'Klee One': PartK.kleeOne,
        'Knewave': PartK.knewave,
        'KoHo': PartK.koHo,
        'Kodchasan': PartK.kodchasan,
        'Kode Mono': PartK.kodeMono,
        'Koh Santepheap': PartK.kohSantepheap,
        'Kolker Brush': PartK.kolkerBrush,
        'Konkhmer Sleokchher': PartK.konkhmerSleokchher,
        'Kosugi': PartK.kosugi,
        'Kosugi Maru': PartK.kosugiMaru,
        'Kotta One': PartK.kottaOne,
        'Koulen': PartK.koulen,
        'Kranky': PartK.kranky,
        'Kreon': PartK.kreon,
        'Kristi': PartK.kristi,
        'Krona One': PartK.kronaOne,
        'Krub': PartK.krub,
        'Kufam': PartK.kufam,
        'Kulim Park': PartK.kulimPark,
        'Kumar One': PartK.kumarOne,
        'Kumar One Outline': PartK.kumarOneOutline,
        'Kumbh Sans': PartK.kumbhSans,
        'Kurale': PartK.kurale,
        'LXGW WenKai Mono TC': PartL.lxgwWenKaiMonoTc,
        'LXGW WenKai TC': PartL.lxgwWenKaiTc,
        'La Belle Aurore': PartL.laBelleAurore,
        'Labrada': PartL.labrada,
        'Lacquer': PartL.lacquer,
        'Laila': PartL.laila,
        'Lakki Reddy': PartL.lakkiReddy,
        'Lalezar': PartL.lalezar,
        'Lancelot': PartL.lancelot,
        'Langar': PartL.langar,
        'Lateef': PartL.lateef,
        'Lato': PartL.lato,
        'Lavishly Yours': PartL.lavishlyYours,
        'League Gothic': PartL.leagueGothic,
        'League Script': PartL.leagueScript,
        'League Spartan': PartL.leagueSpartan,
        'Leckerli One': PartL.leckerliOne,
        'Ledger': PartL.ledger,
        'Lekton': PartL.lekton,
        'Lemon': PartL.lemon,
        'Lemonada': PartL.lemonada,
        'Lexend': PartL.lexend,
        'Lexend Deca': PartL.lexendDeca,
        'Lexend Exa': PartL.lexendExa,
        'Lexend Giga': PartL.lexendGiga,
        'Lexend Mega': PartL.lexendMega,
        'Lexend Peta': PartL.lexendPeta,
        'Lexend Tera': PartL.lexendTera,
        'Lexend Zetta': PartL.lexendZetta,
        'Libre Barcode 128': PartL.libreBarcode128,
        'Libre Barcode 128 Text': PartL.libreBarcode128Text,
        'Libre Barcode 39': PartL.libreBarcode39,
        'Libre Barcode 39 Extended': PartL.libreBarcode39Extended,
        'Libre Barcode 39 Extended Text': PartL.libreBarcode39ExtendedText,
        'Libre Barcode 39 Text': PartL.libreBarcode39Text,
        'Libre Barcode EAN13 Text': PartL.libreBarcodeEan13Text,
        'Libre Baskerville': PartL.libreBaskerville,
        'Libre Bodoni': PartL.libreBodoni,
        'Libre Caslon Display': PartL.libreCaslonDisplay,
        'Libre Caslon Text': PartL.libreCaslonText,
        'Libre Franklin': PartL.libreFranklin,
        'Licorice': PartL.licorice,
        'Life Savers': PartL.lifeSavers,
        'Lilita One': PartL.lilitaOne,
        'Lily Script One': PartL.lilyScriptOne,
        'Limelight': PartL.limelight,
        'Linden Hill': PartL.lindenHill,
        'Linefont': PartL.linefont,
        'Lisu Bosa': PartL.lisuBosa,
        'Literata': PartL.literata,
        'Liu Jian Mao Cao': PartL.liuJianMaoCao,
        'Livvic': PartL.livvic,
        'Lobster': PartL.lobster,
        'Lobster Two': PartL.lobsterTwo,
        'Londrina Outline': PartL.londrinaOutline,
        'Londrina Shadow': PartL.londrinaShadow,
        'Londrina Sketch': PartL.londrinaSketch,
        'Londrina Solid': PartL.londrinaSolid,
        'Long Cang': PartL.longCang,
        'Lora': PartL.lora,
        'Love Light': PartL.loveLight,
        'Love Ya Like A Sister': PartL.loveYaLikeASister,
        'Loved by the King': PartL.lovedByTheKing,
        'Lovers Quarrel': PartL.loversQuarrel,
        'Luckiest Guy': PartL.luckiestGuy,
        'Lugrasimo': PartL.lugrasimo,
        'Lumanosimo': PartL.lumanosimo,
        'Lunasima': PartL.lunasima,
        'Lusitana': PartL.lusitana,
        'Lustria': PartL.lustria,
        'Luxurious Roman': PartL.luxuriousRoman,
        'Luxurious Script': PartL.luxuriousScript,
        'M PLUS 1': PartM.mPlus1,
        'M PLUS 1 Code': PartM.mPlus1Code,
        'M PLUS 1p': PartM.mPlus1p,
        'M PLUS 2': PartM.mPlus2,
        'M PLUS Code Latin': PartM.mPlusCodeLatin,
        'M PLUS Rounded 1c': PartM.mPlusRounded1c,
        'Ma Shan Zheng': PartM.maShanZheng,
        'Macondo': PartM.macondo,
        'Macondo Swash Caps': PartM.macondoSwashCaps,
        'Mada': PartM.mada,
        'Madimi One': PartM.madimiOne,
        'Magra': PartM.magra,
        'Maiden Orange': PartM.maidenOrange,
        'Maitree': PartM.maitree,
        'Major Mono Display': PartM.majorMonoDisplay,
        'Mako': PartM.mako,
        'Mali': PartM.mali,
        'Mallanna': PartM.mallanna,
        'Maname': PartM.maname,
        'Mandali': PartM.mandali,
        'Manjari': PartM.manjari,
        'Manrope': PartM.manrope,
        'Mansalva': PartM.mansalva,
        'Manuale': PartM.manuale,
        'Marcellus': PartM.marcellus,
        'Marcellus SC': PartM.marcellusSc,
        'Marck Script': PartM.marckScript,
        'Margarine': PartM.margarine,
        'Marhey': PartM.marhey,
        'Markazi Text': PartM.markaziText,
        'Marko One': PartM.markoOne,
        'Marmelad': PartM.marmelad,
        'Martel': PartM.martel,
        'Martel Sans': PartM.martelSans,
        'Martian Mono': PartM.martianMono,
        'Marvel': PartM.marvel,
        'Mate': PartM.mate,
        'Mate SC': PartM.mateSc,
        'Maven Pro': PartM.mavenPro,
        'McLaren': PartM.mcLaren,
        'Mea Culpa': PartM.meaCulpa,
        'Meddon': PartM.meddon,
        'MedievalSharp': PartM.medievalSharp,
        'Medula One': PartM.medulaOne,
        'Meera Inimai': PartM.meeraInimai,
        'Megrim': PartM.megrim,
        'Meie Script': PartM.meieScript,
        'Meow Script': PartM.meowScript,
        'Merienda': PartM.merienda,
        'Merriweather': PartM.merriweather,
        'Merriweather Sans': PartM.merriweatherSans,
        'Metal': PartM.metal,
        'Metal Mania': PartM.metalMania,
        'Metamorphous': PartM.metamorphous,
        'Metrophobic': PartM.metrophobic,
        'Michroma': PartM.michroma,
        'Micro 5': PartM.micro5,
        'Micro 5 Charted': PartM.micro5Charted,
        'Milonga': PartM.milonga,
        'Miltonian': PartM.miltonian,
        'Miltonian Tattoo': PartM.miltonianTattoo,
        'Mina': PartM.mina,
        'Mingzat': PartM.mingzat,
        'Miniver': PartM.miniver,
        'Miriam Libre': PartM.miriamLibre,
        'Mirza': PartM.mirza,
        'Miss Fajardose': PartM.missFajardose,
        'Mitr': PartM.mitr,
        'Mochiy Pop One': PartM.mochiyPopOne,
        'Mochiy Pop P One': PartM.mochiyPopPOne,
        'Modak': PartM.modak,
        'Modern Antiqua': PartM.modernAntiqua,
        'Mogra': PartM.mogra,
        'Mohave': PartM.mohave,
        'Moirai One': PartM.moiraiOne,
        'Molengo': PartM.molengo,
        'Molle': PartM.molle,
        'Monda': PartM.monda,
        'Monofett': PartM.monofett,
        'Monomaniac One': PartM.monomaniacOne,
        'Monoton': PartM.monoton,
        'Monsieur La Doulaise': PartM.monsieurLaDoulaise,
        'Montaga': PartM.montaga,
        'Montagu Slab': PartM.montaguSlab,
        'MonteCarlo': PartM.monteCarlo,
        'Montez': PartM.montez,
        'Montserrat': PartM.montserrat,
        'Montserrat Alternates': PartM.montserratAlternates,
        'Montserrat Subrayada': PartM.montserratSubrayada,
        'Moo Lah Lah': PartM.mooLahLah,
        'Mooli': PartM.mooli,
        'Moon Dance': PartM.moonDance,
        'Moul': PartM.moul,
        'Moulpali': PartM.moulpali,
        'Mountains of Christmas': PartM.mountainsOfChristmas,
        'Mouse Memoirs': PartM.mouseMemoirs,
        'Mr Bedfort': PartM.mrBedfort,
        'Mr Dafoe': PartM.mrDafoe,
        'Mr De Haviland': PartM.mrDeHaviland,
        'Mrs Saint Delafield': PartM.mrsSaintDelafield,
        'Mrs Sheppards': PartM.mrsSheppards,
        'Ms Madi': PartM.msMadi,
        'Mukta': PartM.mukta,
        'Mukta Mahee': PartM.muktaMahee,
        'Mukta Malar': PartM.muktaMalar,
        'Mukta Vaani': PartM.muktaVaani,
        'Mulish': PartM.mulish,
        'Murecho': PartM.murecho,
        'MuseoModerno': PartM.museoModerno,
        'My Soul': PartM.mySoul,
        'Mynerve': PartM.mynerve,
        'Mystery Quest': PartM.mysteryQuest,
        'NTR': PartN.ntr,
        'Nabla': PartN.nabla,
        'Namdhinggo': PartN.namdhinggo,
        'Nanum Brush Script': PartN.nanumBrushScript,
        'Nanum Gothic': PartN.nanumGothic,
        'Nanum Gothic Coding': PartN.nanumGothicCoding,
        'Nanum Myeongjo': PartN.nanumMyeongjo,
        'Nanum Pen Script': PartN.nanumPenScript,
        'Narnoor': PartN.narnoor,
        'Neonderthaw': PartN.neonderthaw,
        'Nerko One': PartN.nerkoOne,
        'Neucha': PartN.neucha,
        'Neuton': PartN.neuton,
        'New Rocker': PartN.newRocker,
        'New Tegomin': PartN.newTegomin,
        'News Cycle': PartN.newsCycle,
        'Newsreader': PartN.newsreader,
        'Niconne': PartN.niconne,
        'Niramit': PartN.niramit,
        'Nixie One': PartN.nixieOne,
        'Nobile': PartN.nobile,
        'Nokora': PartN.nokora,
        'Norican': PartN.norican,
        'Nosifer': PartN.nosifer,
        'Notable': PartN.notable,
        'Nothing You Could Do': PartN.nothingYouCouldDo,
        'Noticia Text': PartN.noticiaText,
        'Noto Color Emoji': PartN.notoColorEmoji,
        'Noto Emoji': PartN.notoEmoji,
        'Noto Kufi Arabic': PartN.notoKufiArabic,
        'Noto Music': PartN.notoMusic,
        'Noto Naskh Arabic': PartN.notoNaskhArabic,
        'Noto Nastaliq Urdu': PartN.notoNastaliqUrdu,
        'Noto Rashi Hebrew': PartN.notoRashiHebrew,
        'Noto Sans': PartN.notoSans,
        'Noto Sans Adlam': PartN.notoSansAdlam,
        'Noto Sans Adlam Unjoined': PartN.notoSansAdlamUnjoined,
        'Noto Sans Anatolian Hieroglyphs': PartN.notoSansAnatolianHieroglyphs,
        'Noto Sans Arabic': PartN.notoSansArabic,
        'Noto Sans Armenian': PartN.notoSansArmenian,
        'Noto Sans Avestan': PartN.notoSansAvestan,
        'Noto Sans Balinese': PartN.notoSansBalinese,
        'Noto Sans Bamum': PartN.notoSansBamum,
        'Noto Sans Bassa Vah': PartN.notoSansBassaVah,
        'Noto Sans Batak': PartN.notoSansBatak,
        'Noto Sans Bengali': PartN.notoSansBengali,
        'Noto Sans Bhaiksuki': PartN.notoSansBhaiksuki,
        'Noto Sans Brahmi': PartN.notoSansBrahmi,
        'Noto Sans Buginese': PartN.notoSansBuginese,
        'Noto Sans Buhid': PartN.notoSansBuhid,
        'Noto Sans Canadian Aboriginal': PartN.notoSansCanadianAboriginal,
        'Noto Sans Carian': PartN.notoSansCarian,
        'Noto Sans Caucasian Albanian': PartN.notoSansCaucasianAlbanian,
        'Noto Sans Chakma': PartN.notoSansChakma,
        'Noto Sans Cham': PartN.notoSansCham,
        'Noto Sans Cherokee': PartN.notoSansCherokee,
        'Noto Sans Chorasmian': PartN.notoSansChorasmian,
        'Noto Sans Coptic': PartN.notoSansCoptic,
        'Noto Sans Cuneiform': PartN.notoSansCuneiform,
        'Noto Sans Cypriot': PartN.notoSansCypriot,
        'Noto Sans Cypro Minoan': PartN.notoSansCyproMinoan,
        'Noto Sans Deseret': PartN.notoSansDeseret,
        'Noto Sans Devanagari': PartN.notoSansDevanagari,
        'Noto Sans Display': PartN.notoSansDisplay,
        'Noto Sans Duployan': PartN.notoSansDuployan,
        'Noto Sans Egyptian Hieroglyphs': PartN.notoSansEgyptianHieroglyphs,
        'Noto Sans Elbasan': PartN.notoSansElbasan,
        'Noto Sans Elymaic': PartN.notoSansElymaic,
        'Noto Sans Ethiopic': PartN.notoSansEthiopic,
        'Noto Sans Georgian': PartN.notoSansGeorgian,
        'Noto Sans Glagolitic': PartN.notoSansGlagolitic,
        'Noto Sans Gothic': PartN.notoSansGothic,
        'Noto Sans Grantha': PartN.notoSansGrantha,
        'Noto Sans Gujarati': PartN.notoSansGujarati,
        'Noto Sans Gunjala Gondi': PartN.notoSansGunjalaGondi,
        'Noto Sans Gurmukhi': PartN.notoSansGurmukhi,
        'Noto Sans HK': PartN.notoSansHk,
        'Noto Sans Hanifi Rohingya': PartN.notoSansHanifiRohingya,
        'Noto Sans Hanunoo': PartN.notoSansHanunoo,
        'Noto Sans Hatran': PartN.notoSansHatran,
        'Noto Sans Hebrew': PartN.notoSansHebrew,
        'Noto Sans Imperial Aramaic': PartN.notoSansImperialAramaic,
        'Noto Sans Indic Siyaq Numbers': PartN.notoSansIndicSiyaqNumbers,
        'Noto Sans Inscriptional Pahlavi': PartN.notoSansInscriptionalPahlavi,
        'Noto Sans Inscriptional Parthian': PartN.notoSansInscriptionalParthian,
        'Noto Sans JP': PartN.notoSansJp,
        'Noto Sans Javanese': PartN.notoSansJavanese,
        'Noto Sans KR': PartN.notoSansKr,
        'Noto Sans Kaithi': PartN.notoSansKaithi,
        'Noto Sans Kannada': PartN.notoSansKannada,
        'Noto Sans Kawi': PartN.notoSansKawi,
        'Noto Sans Kayah Li': PartN.notoSansKayahLi,
        'Noto Sans Kharoshthi': PartN.notoSansKharoshthi,
        'Noto Sans Khmer': PartN.notoSansKhmer,
        'Noto Sans Khojki': PartN.notoSansKhojki,
        'Noto Sans Khudawadi': PartN.notoSansKhudawadi,
        'Noto Sans Lao': PartN.notoSansLao,
        'Noto Sans Lao Looped': PartN.notoSansLaoLooped,
        'Noto Sans Lepcha': PartN.notoSansLepcha,
        'Noto Sans Limbu': PartN.notoSansLimbu,
        'Noto Sans Linear A': PartN.notoSansLinearA,
        'Noto Sans Linear B': PartN.notoSansLinearB,
        'Noto Sans Lisu': PartN.notoSansLisu,
        'Noto Sans Lycian': PartN.notoSansLycian,
        'Noto Sans Lydian': PartN.notoSansLydian,
        'Noto Sans Mahajani': PartN.notoSansMahajani,
        'Noto Sans Malayalam': PartN.notoSansMalayalam,
        'Noto Sans Mandaic': PartN.notoSansMandaic,
        'Noto Sans Manichaean': PartN.notoSansManichaean,
        'Noto Sans Marchen': PartN.notoSansMarchen,
        'Noto Sans Masaram Gondi': PartN.notoSansMasaramGondi,
        'Noto Sans Math': PartN.notoSansMath,
        'Noto Sans Mayan Numerals': PartN.notoSansMayanNumerals,
        'Noto Sans Medefaidrin': PartN.notoSansMedefaidrin,
        'Noto Sans Meetei Mayek': PartN.notoSansMeeteiMayek,
        'Noto Sans Mende Kikakui': PartN.notoSansMendeKikakui,
        'Noto Sans Meroitic': PartN.notoSansMeroitic,
        'Noto Sans Miao': PartN.notoSansMiao,
        'Noto Sans Modi': PartN.notoSansModi,
        'Noto Sans Mongolian': PartN.notoSansMongolian,
        'Noto Sans Mono': PartN.notoSansMono,
        'Noto Sans Mro': PartN.notoSansMro,
        'Noto Sans Multani': PartN.notoSansMultani,
        'Noto Sans Myanmar': PartN.notoSansMyanmar,
        'Noto Sans NKo': PartN.notoSansNKo,
        'Noto Sans NKo Unjoined': PartN.notoSansNKoUnjoined,
        'Noto Sans Nabataean': PartN.notoSansNabataean,
        'Noto Sans Nag Mundari': PartN.notoSansNagMundari,
        'Noto Sans Nandinagari': PartN.notoSansNandinagari,
        'Noto Sans New Tai Lue': PartN.notoSansNewTaiLue,
        'Noto Sans Newa': PartN.notoSansNewa,
        'Noto Sans Nushu': PartN.notoSansNushu,
        'Noto Sans Ogham': PartN.notoSansOgham,
        'Noto Sans Ol Chiki': PartN.notoSansOlChiki,
        'Noto Sans Old Hungarian': PartN.notoSansOldHungarian,
        'Noto Sans Old Italic': PartN.notoSansOldItalic,
        'Noto Sans Old North Arabian': PartN.notoSansOldNorthArabian,
        'Noto Sans Old Permic': PartN.notoSansOldPermic,
        'Noto Sans Old Persian': PartN.notoSansOldPersian,
        'Noto Sans Old Sogdian': PartN.notoSansOldSogdian,
        'Noto Sans Old South Arabian': PartN.notoSansOldSouthArabian,
        'Noto Sans Old Turkic': PartN.notoSansOldTurkic,
        'Noto Sans Oriya': PartN.notoSansOriya,
        'Noto Sans Osage': PartN.notoSansOsage,
        'Noto Sans Osmanya': PartN.notoSansOsmanya,
        'Noto Sans Pahawh Hmong': PartN.notoSansPahawhHmong,
        'Noto Sans Palmyrene': PartN.notoSansPalmyrene,
        'Noto Sans Pau Cin Hau': PartN.notoSansPauCinHau,
        'Noto Sans Phags Pa': PartN.notoSansPhagsPa,
        'Noto Sans Phoenician': PartN.notoSansPhoenician,
        'Noto Sans Psalter Pahlavi': PartN.notoSansPsalterPahlavi,
        'Noto Sans Rejang': PartN.notoSansRejang,
        'Noto Sans Runic': PartN.notoSansRunic,
        'Noto Sans SC': PartN.notoSansSc,
        'Noto Sans Samaritan': PartN.notoSansSamaritan,
        'Noto Sans Saurashtra': PartN.notoSansSaurashtra,
        'Noto Sans Sharada': PartN.notoSansSharada,
        'Noto Sans Shavian': PartN.notoSansShavian,
        'Noto Sans Siddham': PartN.notoSansSiddham,
        'Noto Sans SignWriting': PartN.notoSansSignWriting,
        'Noto Sans Sinhala': PartN.notoSansSinhala,
        'Noto Sans Sogdian': PartN.notoSansSogdian,
        'Noto Sans Sora Sompeng': PartN.notoSansSoraSompeng,
        'Noto Sans Soyombo': PartN.notoSansSoyombo,
        'Noto Sans Sundanese': PartN.notoSansSundanese,
        'Noto Sans Syloti Nagri': PartN.notoSansSylotiNagri,
        'Noto Sans Symbols': PartN.notoSansSymbols,
        'Noto Sans Symbols 2': PartN.notoSansSymbols2,
        'Noto Sans Syriac': PartN.notoSansSyriac,
        'Noto Sans Syriac Eastern': PartN.notoSansSyriacEastern,
        'Noto Sans TC': PartN.notoSansTc,
        'Noto Sans Tagalog': PartN.notoSansTagalog,
        'Noto Sans Tagbanwa': PartN.notoSansTagbanwa,
        'Noto Sans Tai Le': PartN.notoSansTaiLe,
        'Noto Sans Tai Tham': PartN.notoSansTaiTham,
        'Noto Sans Tai Viet': PartN.notoSansTaiViet,
        'Noto Sans Takri': PartN.notoSansTakri,
        'Noto Sans Tamil': PartN.notoSansTamil,
        'Noto Sans Tamil Supplement': PartN.notoSansTamilSupplement,
        'Noto Sans Tangsa': PartN.notoSansTangsa,
        'Noto Sans Telugu': PartN.notoSansTelugu,
        'Noto Sans Thaana': PartN.notoSansThaana,
        'Noto Sans Thai': PartN.notoSansThai,
        'Noto Sans Thai Looped': PartN.notoSansThaiLooped,
        'Noto Sans Tifinagh': PartN.notoSansTifinagh,
        'Noto Sans Tirhuta': PartN.notoSansTirhuta,
        'Noto Sans Ugaritic': PartN.notoSansUgaritic,
        'Noto Sans Vai': PartN.notoSansVai,
        'Noto Sans Vithkuqi': PartN.notoSansVithkuqi,
        'Noto Sans Wancho': PartN.notoSansWancho,
        'Noto Sans Warang Citi': PartN.notoSansWarangCiti,
        'Noto Sans Yi': PartN.notoSansYi,
        'Noto Sans Zanabazar Square': PartN.notoSansZanabazarSquare,
        'Noto Serif': PartN.notoSerif,
        'Noto Serif Ahom': PartN.notoSerifAhom,
        'Noto Serif Armenian': PartN.notoSerifArmenian,
        'Noto Serif Balinese': PartN.notoSerifBalinese,
        'Noto Serif Bengali': PartN.notoSerifBengali,
        'Noto Serif Devanagari': PartN.notoSerifDevanagari,
        'Noto Serif Display': PartN.notoSerifDisplay,
        'Noto Serif Dogra': PartN.notoSerifDogra,
        'Noto Serif Ethiopic': PartN.notoSerifEthiopic,
        'Noto Serif Georgian': PartN.notoSerifGeorgian,
        'Noto Serif Grantha': PartN.notoSerifGrantha,
        'Noto Serif Gujarati': PartN.notoSerifGujarati,
        'Noto Serif Gurmukhi': PartN.notoSerifGurmukhi,
        'Noto Serif HK': PartN.notoSerifHk,
        'Noto Serif Hebrew': PartN.notoSerifHebrew,
        'Noto Serif JP': PartN.notoSerifJp,
        'Noto Serif KR': PartN.notoSerifKr,
        'Noto Serif Kannada': PartN.notoSerifKannada,
        'Noto Serif Khitan Small Script': PartN.notoSerifKhitanSmallScript,
        'Noto Serif Khmer': PartN.notoSerifKhmer,
        'Noto Serif Khojki': PartN.notoSerifKhojki,
        'Noto Serif Lao': PartN.notoSerifLao,
        'Noto Serif Makasar': PartN.notoSerifMakasar,
        'Noto Serif Malayalam': PartN.notoSerifMalayalam,
        'Noto Serif Myanmar': PartN.notoSerifMyanmar,
        'Noto Serif NP Hmong': PartN.notoSerifNpHmong,
        'Noto Serif Old Uyghur': PartN.notoSerifOldUyghur,
        'Noto Serif Oriya': PartN.notoSerifOriya,
        'Noto Serif Ottoman Siyaq': PartN.notoSerifOttomanSiyaq,
        'Noto Serif SC': PartN.notoSerifSc,
        'Noto Serif Sinhala': PartN.notoSerifSinhala,
        'Noto Serif TC': PartN.notoSerifTc,
        'Noto Serif Tamil': PartN.notoSerifTamil,
        'Noto Serif Tangut': PartN.notoSerifTangut,
        'Noto Serif Telugu': PartN.notoSerifTelugu,
        'Noto Serif Thai': PartN.notoSerifThai,
        'Noto Serif Tibetan': PartN.notoSerifTibetan,
        'Noto Serif Toto': PartN.notoSerifToto,
        'Noto Serif Vithkuqi': PartN.notoSerifVithkuqi,
        'Noto Serif Yezidi': PartN.notoSerifYezidi,
        'Noto Traditional Nushu': PartN.notoTraditionalNushu,
        'Noto Znamenny Musical Notation': PartN.notoZnamennyMusicalNotation,
        'Nova Cut': PartN.novaCut,
        'Nova Flat': PartN.novaFlat,
        'Nova Mono': PartN.novaMono,
        'Nova Oval': PartN.novaOval,
        'Nova Round': PartN.novaRound,
        'Nova Script': PartN.novaScript,
        'Nova Slim': PartN.novaSlim,
        'Nova Square': PartN.novaSquare,
        'Numans': PartN.numans,
        'Nunito': PartN.nunito,
        'Nunito Sans': PartN.nunitoSans,
        'Nuosu SIL': PartN.nuosuSil,
        'Odibee Sans': PartO.odibeeSans,
        'Odor Mean Chey': PartO.odorMeanChey,
        'Offside': PartO.offside,
        'Oi': PartO.oi,
        'Ojuju': PartO.ojuju,
        'Old Standard TT': PartO.oldStandardTt,
        'Oldenburg': PartO.oldenburg,
        'Ole': PartO.ole,
        'Oleo Script': PartO.oleoScript,
        'Oleo Script Swash Caps': PartO.oleoScriptSwashCaps,
        'Onest': PartO.onest,
        'Oooh Baby': PartO.ooohBaby,
        'Open Sans': PartO.openSans,
        'Open Sans Condensed': PartO.openSansCondensed,
        'Oranienbaum': PartO.oranienbaum,
        'Orbit': PartO.orbit,
        'Orbitron': PartO.orbitron,
        'Oregano': PartO.oregano,
        'Orelega One': PartO.orelegaOne,
        'Orienta': PartO.orienta,
        'Original Surfer': PartO.originalSurfer,
        'Oswald': PartO.oswald,
        'Outfit': PartO.outfit,
        'Over the Rainbow': PartO.overTheRainbow,
        'Overlock': PartO.overlock,
        'Overlock SC': PartO.overlockSc,
        'Overpass': PartO.overpass,
        'Overpass Mono': PartO.overpassMono,
        'Ovo': PartO.ovo,
        'Oxanium': PartO.oxanium,
        'Oxygen': PartO.oxygen,
        'Oxygen Mono': PartO.oxygenMono,
        'PT Mono': PartP.ptMono,
        'PT Sans': PartP.ptSans,
        'PT Sans Caption': PartP.ptSansCaption,
        'PT Sans Narrow': PartP.ptSansNarrow,
        'PT Serif': PartP.ptSerif,
        'PT Serif Caption': PartP.ptSerifCaption,
        'Pacifico': PartP.pacifico,
        'Padauk': PartP.padauk,
        'Padyakke Expanded One': PartP.padyakkeExpandedOne,
        'Palanquin': PartP.palanquin,
        'Palanquin Dark': PartP.palanquinDark,
        'Palette Mosaic': PartP.paletteMosaic,
        'Pangolin': PartP.pangolin,
        'Paprika': PartP.paprika,
        'Parisienne': PartP.parisienne,
        'Passero One': PartP.passeroOne,
        'Passion One': PartP.passionOne,
        'Passions Conflict': PartP.passionsConflict,
        'Pathway Extreme': PartP.pathwayExtreme,
        'Pathway Gothic One': PartP.pathwayGothicOne,
        'Patrick Hand': PartP.patrickHand,
        'Patrick Hand SC': PartP.patrickHandSc,
        'Pattaya': PartP.pattaya,
        'Patua One': PartP.patuaOne,
        'Pavanam': PartP.pavanam,
        'Paytone One': PartP.paytoneOne,
        'Peddana': PartP.peddana,
        'Peralta': PartP.peralta,
        'Permanent Marker': PartP.permanentMarker,
        'Petemoss': PartP.petemoss,
        'Petit Formal Script': PartP.petitFormalScript,
        'Petrona': PartP.petrona,
        'Philosopher': PartP.philosopher,
        'Phudu': PartP.phudu,
        'Piazzolla': PartP.piazzolla,
        'Piedra': PartP.piedra,
        'Pinyon Script': PartP.pinyonScript,
        'Pirata One': PartP.pirataOne,
        'Pixelify Sans': PartP.pixelifySans,
        'Plaster': PartP.plaster,
        'Platypi': PartP.platypi,
        'Play': PartP.play,
        'Playball': PartP.playball,
        'Playfair': PartP.playfair,
        'Playfair Display': PartP.playfairDisplay,
        'Playfair Display SC': PartP.playfairDisplaySc,
        'Playpen Sans': PartP.playpenSans,
        'Playwrite AR': PartP.playwriteAr,
        'Playwrite AT': PartP.playwriteAt,
        'Playwrite AU NSW': PartP.playwriteAuNsw,
        'Playwrite AU QLD': PartP.playwriteAuQld,
        'Playwrite AU SA': PartP.playwriteAuSa,
        'Playwrite AU TAS': PartP.playwriteAuTas,
        'Playwrite AU VIC': PartP.playwriteAuVic,
        'Playwrite BE VLG': PartP.playwriteBeVlg,
        'Playwrite BE WAL': PartP.playwriteBeWal,
        'Playwrite BR': PartP.playwriteBr,
        'Playwrite CA': PartP.playwriteCa,
        'Playwrite CL': PartP.playwriteCl,
        'Playwrite CO': PartP.playwriteCo,
        'Playwrite CU': PartP.playwriteCu,
        'Playwrite CZ': PartP.playwriteCz,
        'Playwrite DE Grund': PartP.playwriteDeGrund,
        'Playwrite DE LA': PartP.playwriteDeLa,
        'Playwrite DE SAS': PartP.playwriteDeSas,
        'Playwrite DE VA': PartP.playwriteDeVa,
        'Playwrite DK Loopet': PartP.playwriteDkLoopet,
        'Playwrite DK Uloopet': PartP.playwriteDkUloopet,
        'Playwrite ES': PartP.playwriteEs,
        'Playwrite ES Deco': PartP.playwriteEsDeco,
        'Playwrite FR Moderne': PartP.playwriteFrModerne,
        'Playwrite FR Trad': PartP.playwriteFrTrad,
        'Playwrite GB J': PartP.playwriteGbJ,
        'Playwrite GB S': PartP.playwriteGbS,
        'Playwrite HR': PartP.playwriteHr,
        'Playwrite HR Lijeva': PartP.playwriteHrLijeva,
        'Playwrite HU': PartP.playwriteHu,
        'Playwrite ID': PartP.playwriteId,
        'Playwrite IE': PartP.playwriteIe,
        'Playwrite IN': PartP.playwriteIn,
        'Playwrite IS': PartP.playwriteIs,
        'Playwrite IT Moderna': PartP.playwriteItModerna,
        'Playwrite IT Trad': PartP.playwriteItTrad,
        'Playwrite MX': PartP.playwriteMx,
        'Playwrite NG Modern': PartP.playwriteNgModern,
        'Playwrite NL': PartP.playwriteNl,
        'Playwrite NO': PartP.playwriteNo,
        'Playwrite NZ': PartP.playwriteNz,
        'Playwrite PE': PartP.playwritePe,
        'Playwrite PL': PartP.playwritePl,
        'Playwrite PT': PartP.playwritePt,
        'Playwrite RO': PartP.playwriteRo,
        'Playwrite SK': PartP.playwriteSk,
        'Playwrite TZ': PartP.playwriteTz,
        'Playwrite US Modern': PartP.playwriteUsModern,
        'Playwrite US Trad': PartP.playwriteUsTrad,
        'Playwrite VN': PartP.playwriteVn,
        'Playwrite ZA': PartP.playwriteZa,
        'Plus Jakarta Sans': PartP.plusJakartaSans,
        'Podkova': PartP.podkova,
        'Poetsen One': PartP.poetsenOne,
        'Poiret One': PartP.poiretOne,
        'Poller One': PartP.pollerOne,
        'Poltawski Nowy': PartP.poltawskiNowy,
        'Poly': PartP.poly,
        'Pompiere': PartP.pompiere,
        'Pontano Sans': PartP.pontanoSans,
        'Poor Story': PartP.poorStory,
        'Poppins': PartP.poppins,
        'Port Lligat Sans': PartP.portLligatSans,
        'Port Lligat Slab': PartP.portLligatSlab,
        'Potta One': PartP.pottaOne,
        'Pragati Narrow': PartP.pragatiNarrow,
        'Praise': PartP.praise,
        'Prata': PartP.prata,
        'Preahvihear': PartP.preahvihear,
        'Press Start 2P': PartP.pressStart2p,
        'Pridi': PartP.pridi,
        'Princess Sofia': PartP.princessSofia,
        'Prociono': PartP.prociono,
        'Prompt': PartP.prompt,
        'Prosto One': PartP.prostoOne,
        'Protest Guerrilla': PartP.protestGuerrilla,
        'Protest Revolution': PartP.protestRevolution,
        'Protest Riot': PartP.protestRiot,
        'Protest Strike': PartP.protestStrike,
        'Proza Libre': PartP.prozaLibre,
        'Public Sans': PartP.publicSans,
        'Puppies Play': PartP.puppiesPlay,
        'Puritan': PartP.puritan,
        'Purple Purse': PartP.purplePurse,
        'Qahiri': PartQ.qahiri,
        'Quando': PartQ.quando,
        'Quantico': PartQ.quantico,
        'Quattrocento': PartQ.quattrocento,
        'Quattrocento Sans': PartQ.quattrocentoSans,
        'Questrial': PartQ.questrial,
        'Quicksand': PartQ.quicksand,
        'Quintessential': PartQ.quintessential,
        'Qwigley': PartQ.qwigley,
        'Qwitcher Grypen': PartQ.qwitcherGrypen,
        'REM': PartR.rem,
        'Racing Sans One': PartR.racingSansOne,
        'Radio Canada': PartR.radioCanada,
        'Radio Canada Big': PartR.radioCanadaBig,
        'Radley': PartR.radley,
        'Rajdhani': PartR.rajdhani,
        'Rakkas': PartR.rakkas,
        'Raleway': PartR.raleway,
        'Raleway Dots': PartR.ralewayDots,
        'Ramabhadra': PartR.ramabhadra,
        'Ramaraja': PartR.ramaraja,
        'Rambla': PartR.rambla,
        'Rammetto One': PartR.rammettoOne,
        'Rampart One': PartR.rampartOne,
        'Ranchers': PartR.ranchers,
        'Rancho': PartR.rancho,
        'Ranga': PartR.ranga,
        'Rasa': PartR.rasa,
        'Rationale': PartR.rationale,
        'Ravi Prakash': PartR.raviPrakash,
        'Readex Pro': PartR.readexPro,
        'Recursive': PartR.recursive,
        'Red Hat Display': PartR.redHatDisplay,
        'Red Hat Mono': PartR.redHatMono,
        'Red Hat Text': PartR.redHatText,
        'Red Rose': PartR.redRose,
        'Redacted': PartR.redacted,
        'Redacted Script': PartR.redactedScript,
        'Reddit Mono': PartR.redditMono,
        'Reddit Sans': PartR.redditSans,
        'Reddit Sans Condensed': PartR.redditSansCondensed,
        'Redressed': PartR.redressed,
        'Reem Kufi': PartR.reemKufi,
        'Reem Kufi Fun': PartR.reemKufiFun,
        'Reem Kufi Ink': PartR.reemKufiInk,
        'Reenie Beanie': PartR.reenieBeanie,
        'Reggae One': PartR.reggaeOne,
        'Rethink Sans': PartR.rethinkSans,
        'Revalia': PartR.revalia,
        'Rhodium Libre': PartR.rhodiumLibre,
        'Ribeye': PartR.ribeye,
        'Ribeye Marrow': PartR.ribeyeMarrow,
        'Righteous': PartR.righteous,
        'Risque': PartR.risque,
        'Road Rage': PartR.roadRage,
        'Roboto': PartR.roboto,
        'Roboto Condensed': PartR.robotoCondensed,
        'Roboto Flex': PartR.robotoFlex,
        'Roboto Mono': PartR.robotoMono,
        'Roboto Serif': PartR.robotoSerif,
        'Roboto Slab': PartR.robotoSlab,
        'Rochester': PartR.rochester,
        'Rock 3D': PartR.rock3d,
        'Rock Salt': PartR.rockSalt,
        'RocknRoll One': PartR.rocknRollOne,
        'Rokkitt': PartR.rokkitt,
        'Romanesco': PartR.romanesco,
        'Ropa Sans': PartR.ropaSans,
        'Rosario': PartR.rosario,
        'Rosarivo': PartR.rosarivo,
        'Rouge Script': PartR.rougeScript,
        'Rowdies': PartR.rowdies,
        'Rozha One': PartR.rozhaOne,
        'Rubik': PartR.rubik,
        'Rubik 80s Fade': PartR.rubik80sFade,
        'Rubik Beastly': PartR.rubikBeastly,
        'Rubik Broken Fax': PartR.rubikBrokenFax,
        'Rubik Bubbles': PartR.rubikBubbles,
        'Rubik Burned': PartR.rubikBurned,
        'Rubik Dirt': PartR.rubikDirt,
        'Rubik Distressed': PartR.rubikDistressed,
        'Rubik Doodle Shadow': PartR.rubikDoodleShadow,
        'Rubik Doodle Triangles': PartR.rubikDoodleTriangles,
        'Rubik Gemstones': PartR.rubikGemstones,
        'Rubik Glitch': PartR.rubikGlitch,
        'Rubik Glitch Pop': PartR.rubikGlitchPop,
        'Rubik Iso': PartR.rubikIso,
        'Rubik Lines': PartR.rubikLines,
        'Rubik Maps': PartR.rubikMaps,
        'Rubik Marker Hatch': PartR.rubikMarkerHatch,
        'Rubik Maze': PartR.rubikMaze,
        'Rubik Microbe': PartR.rubikMicrobe,
        'Rubik Mono One': PartR.rubikMonoOne,
        'Rubik Moonrocks': PartR.rubikMoonrocks,
        'Rubik Pixels': PartR.rubikPixels,
        'Rubik Puddles': PartR.rubikPuddles,
        'Rubik Scribble': PartR.rubikScribble,
        'Rubik Spray Paint': PartR.rubikSprayPaint,
        'Rubik Storm': PartR.rubikStorm,
        'Rubik Vinyl': PartR.rubikVinyl,
        'Rubik Wet Paint': PartR.rubikWetPaint,
        'Ruda': PartR.ruda,
        'Rufina': PartR.rufina,
        'Ruge Boogie': PartR.rugeBoogie,
        'Ruluko': PartR.ruluko,
        'Rum Raisin': PartR.rumRaisin,
        'Ruslan Display': PartR.ruslanDisplay,
        'Russo One': PartR.russoOne,
        'Ruthie': PartR.ruthie,
        'Ruwudu': PartR.ruwudu,
        'Rye': PartR.rye,
        'STIX Two Text': PartS.stixTwoText,
        'Sacramento': PartS.sacramento,
        'Sahitya': PartS.sahitya,
        'Sail': PartS.sail,
        'Saira': PartS.saira,
        'Saira Condensed': PartS.sairaCondensed,
        'Saira Extra Condensed': PartS.sairaExtraCondensed,
        'Saira Semi Condensed': PartS.sairaSemiCondensed,
        'Saira Stencil One': PartS.sairaStencilOne,
        'Salsa': PartS.salsa,
        'Sanchez': PartS.sanchez,
        'Sancreek': PartS.sancreek,
        'Sansita': PartS.sansita,
        'Sansita Swashed': PartS.sansitaSwashed,
        'Sarabun': PartS.sarabun,
        'Sarala': PartS.sarala,
        'Sarina': PartS.sarina,
        'Sarpanch': PartS.sarpanch,
        'Sassy Frass': PartS.sassyFrass,
        'Satisfy': PartS.satisfy,
        'Sawarabi Gothic': PartS.sawarabiGothic,
        'Sawarabi Mincho': PartS.sawarabiMincho,
        'Scada': PartS.scada,
        'Scheherazade New': PartS.scheherazadeNew,
        'Schibsted Grotesk': PartS.schibstedGrotesk,
        'Schoolbell': PartS.schoolbell,
        'Scope One': PartS.scopeOne,
        'Seaweed Script': PartS.seaweedScript,
        'Secular One': PartS.secularOne,
        'Sedan': PartS.sedan,
        'Sedan SC': PartS.sedanSc,
        'Sedgwick Ave': PartS.sedgwickAve,
        'Sedgwick Ave Display': PartS.sedgwickAveDisplay,
        'Sen': PartS.sen,
        'Send Flowers': PartS.sendFlowers,
        'Sevillana': PartS.sevillana,
        'Seymour One': PartS.seymourOne,
        'Shadows Into Light': PartS.shadowsIntoLight,
        'Shadows Into Light Two': PartS.shadowsIntoLightTwo,
        'Shalimar': PartS.shalimar,
        'Shantell Sans': PartS.shantellSans,
        'Shanti': PartS.shanti,
        'Share': PartS.share,
        'Share Tech': PartS.shareTech,
        'Share Tech Mono': PartS.shareTechMono,
        'Shippori Antique': PartS.shipporiAntique,
        'Shippori Antique B1': PartS.shipporiAntiqueB1,
        'Shippori Mincho': PartS.shipporiMincho,
        'Shippori Mincho B1': PartS.shipporiMinchoB1,
        'Shizuru': PartS.shizuru,
        'Shojumaru': PartS.shojumaru,
        'Short Stack': PartS.shortStack,
        'Shrikhand': PartS.shrikhand,
        'Siemreap': PartS.siemreap,
        'Sigmar': PartS.sigmar,
        'Sigmar One': PartS.sigmarOne,
        'Signika': PartS.signika,
        'Signika Negative': PartS.signikaNegative,
        'Silkscreen': PartS.silkscreen,
        'Simonetta': PartS.simonetta,
        'Single Day': PartS.singleDay,
        'Sintony': PartS.sintony,
        'Sirin Stencil': PartS.sirinStencil,
        'Six Caps': PartS.sixCaps,
        'Sixtyfour': PartS.sixtyfour,
        'Skranji': PartS.skranji,
        'Slabo 13px': PartS.slabo13px,
        'Slabo 27px': PartS.slabo27px,
        'Slackey': PartS.slackey,
        'Slackside One': PartS.slacksideOne,
        'Smokum': PartS.smokum,
        'Smooch': PartS.smooch,
        'Smooch Sans': PartS.smoochSans,
        'Smythe': PartS.smythe,
        'Sniglet': PartS.sniglet,
        'Snippet': PartS.snippet,
        'Snowburst One': PartS.snowburstOne,
        'Sofadi One': PartS.sofadiOne,
        'Sofia': PartS.sofia,
        'Sofia Sans': PartS.sofiaSans,
        'Sofia Sans Condensed': PartS.sofiaSansCondensed,
        'Sofia Sans Extra Condensed': PartS.sofiaSansExtraCondensed,
        'Sofia Sans Semi Condensed': PartS.sofiaSansSemiCondensed,
        'Solitreo': PartS.solitreo,
        'Solway': PartS.solway,
        'Sometype Mono': PartS.sometypeMono,
        'Song Myung': PartS.songMyung,
        'Sono': PartS.sono,
        'Sonsie One': PartS.sonsieOne,
        'Sora': PartS.sora,
        'Sorts Mill Goudy': PartS.sortsMillGoudy,
        'Source Code Pro': PartS.sourceCodePro,
        'Source Sans 3': PartS.sourceSans3,
        'Source Serif 4': PartS.sourceSerif4,
        'Space Grotesk': PartS.spaceGrotesk,
        'Space Mono': PartS.spaceMono,
        'Special Elite': PartS.specialElite,
        'Spectral': PartS.spectral,
        'Spectral SC': PartS.spectralSc,
        'Spicy Rice': PartS.spicyRice,
        'Spinnaker': PartS.spinnaker,
        'Spirax': PartS.spirax,
        'Splash': PartS.splash,
        'Spline Sans': PartS.splineSans,
        'Spline Sans Mono': PartS.splineSansMono,
        'Squada One': PartS.squadaOne,
        'Square Peg': PartS.squarePeg,
        'Sree Krushnadevaraya': PartS.sreeKrushnadevaraya,
        'Sriracha': PartS.sriracha,
        'Srisakdi': PartS.srisakdi,
        'Staatliches': PartS.staatliches,
        'Stalemate': PartS.stalemate,
        'Stalinist One': PartS.stalinistOne,
        'Stardos Stencil': PartS.stardosStencil,
        'Stick': PartS.stick,
        'Stick No Bills': PartS.stickNoBills,
        'Stint Ultra Condensed': PartS.stintUltraCondensed,
        'Stint Ultra Expanded': PartS.stintUltraExpanded,
        'Stoke': PartS.stoke,
        'Strait': PartS.strait,
        'Style Script': PartS.styleScript,
        'Stylish': PartS.stylish,
        'Sue Ellen Francisco': PartS.sueEllenFrancisco,
        'Suez One': PartS.suezOne,
        'Sulphur Point': PartS.sulphurPoint,
        'Sumana': PartS.sumana,
        'Sunflower': PartS.sunflower,
        'Sunshiney': PartS.sunshiney,
        'Supermercado One': PartS.supermercadoOne,
        'Sura': PartS.sura,
        'Suranna': PartS.suranna,
        'Suravaram': PartS.suravaram,
        'Suwannaphum': PartS.suwannaphum,
        'Swanky and Moo Moo': PartS.swankyAndMooMoo,
        'Syncopate': PartS.syncopate,
        'Syne': PartS.syne,
        'Syne Mono': PartS.syneMono,
        'Syne Tactile': PartS.syneTactile,
        'Tac One': PartT.tacOne,
        'Tai Heritage Pro': PartT.taiHeritagePro,
        'Tajawal': PartT.tajawal,
        'Tangerine': PartT.tangerine,
        'Tapestry': PartT.tapestry,
        'Taprom': PartT.taprom,
        'Tauri': PartT.tauri,
        'Taviraj': PartT.taviraj,
        'Teachers': PartT.teachers,
        'Teko': PartT.teko,
        'Tektur': PartT.tektur,
        'Telex': PartT.telex,
        'Tenali Ramakrishna': PartT.tenaliRamakrishna,
        'Tenor Sans': PartT.tenorSans,
        'Text Me One': PartT.textMeOne,
        'Texturina': PartT.texturina,
        'Thasadith': PartT.thasadith,
        'The Girl Next Door': PartT.theGirlNextDoor,
        'The Nautigal': PartT.theNautigal,
        'Tienne': PartT.tienne,
        'Tillana': PartT.tillana,
        'Tilt Neon': PartT.tiltNeon,
        'Tilt Prism': PartT.tiltPrism,
        'Tilt Warp': PartT.tiltWarp,
        'Timmana': PartT.timmana,
        'Tinos': PartT.tinos,
        'Tiny5': PartT.tiny5,
        'Tiro Bangla': PartT.tiroBangla,
        'Tiro Devanagari Hindi': PartT.tiroDevanagariHindi,
        'Tiro Devanagari Marathi': PartT.tiroDevanagariMarathi,
        'Tiro Devanagari Sanskrit': PartT.tiroDevanagariSanskrit,
        'Tiro Gurmukhi': PartT.tiroGurmukhi,
        'Tiro Kannada': PartT.tiroKannada,
        'Tiro Tamil': PartT.tiroTamil,
        'Tiro Telugu': PartT.tiroTelugu,
        'Titan One': PartT.titanOne,
        'Titillium Web': PartT.titilliumWeb,
        'Tomorrow': PartT.tomorrow,
        'Tourney': PartT.tourney,
        'Trade Winds': PartT.tradeWinds,
        'Train One': PartT.trainOne,
        'Trirong': PartT.trirong,
        'Trispace': PartT.trispace,
        'Trocchi': PartT.trocchi,
        'Trochut': PartT.trochut,
        'Truculenta': PartT.truculenta,
        'Trykker': PartT.trykker,
        'Tsukimi Rounded': PartT.tsukimiRounded,
        'Tulpen One': PartT.tulpenOne,
        'Turret Road': PartT.turretRoad,
        'Twinkle Star': PartT.twinkleStar,
        'Ubuntu': PartU.ubuntu,
        'Ubuntu Condensed': PartU.ubuntuCondensed,
        'Ubuntu Mono': PartU.ubuntuMono,
        'Ubuntu Sans': PartU.ubuntuSans,
        'Ubuntu Sans Mono': PartU.ubuntuSansMono,
        'Uchen': PartU.uchen,
        'Ultra': PartU.ultra,
        'Unbounded': PartU.unbounded,
        'Uncial Antiqua': PartU.uncialAntiqua,
        'Underdog': PartU.underdog,
        'Unica One': PartU.unicaOne,
        'UnifrakturCook': PartU.unifrakturCook,
        'UnifrakturMaguntia': PartU.unifrakturMaguntia,
        'Unkempt': PartU.unkempt,
        'Unlock': PartU.unlock,
        'Unna': PartU.unna,
        'Updock': PartU.updock,
        'Urbanist': PartU.urbanist,
        'VT323': PartV.vt323,
        'Vampiro One': PartV.vampiroOne,
        'Varela': PartV.varela,
        'Varela Round': PartV.varelaRound,
        'Varta': PartV.varta,
        'Vast Shadow': PartV.vastShadow,
        'Vazirmatn': PartV.vazirmatn,
        'Vesper Libre': PartV.vesperLibre,
        'Viaoda Libre': PartV.viaodaLibre,
        'Vibes': PartV.vibes,
        'Vibur': PartV.vibur,
        'Victor Mono': PartV.victorMono,
        'Vidaloka': PartV.vidaloka,
        'Viga': PartV.viga,
        'Vina Sans': PartV.vinaSans,
        'Voces': PartV.voces,
        'Volkhov': PartV.volkhov,
        'Vollkorn': PartV.vollkorn,
        'Vollkorn SC': PartV.vollkornSc,
        'Voltaire': PartV.voltaire,
        'Vujahday Script': PartV.vujahdayScript,
        'Waiting for the Sunrise': PartW.waitingForTheSunrise,
        'Wallpoet': PartW.wallpoet,
        'Walter Turncoat': PartW.walterTurncoat,
        'Warnes': PartW.warnes,
        'Water Brush': PartW.waterBrush,
        'Waterfall': PartW.waterfall,
        'Wavefont': PartW.wavefont,
        'Wellfleet': PartW.wellfleet,
        'Wendy One': PartW.wendyOne,
        'Whisper': PartW.whisper,
        'WindSong': PartW.windSong,
        'Wire One': PartW.wireOne,
        'Wittgenstein': PartW.wittgenstein,
        'Wix Madefor Display': PartW.wixMadeforDisplay,
        'Wix Madefor Text': PartW.wixMadeforText,
        'Work Sans': PartW.workSans,
        'Workbench': PartW.workbench,
        'Xanh Mono': PartX.xanhMono,
        'Yaldevi': PartY.yaldevi,
        'Yanone Kaffeesatz': PartY.yanoneKaffeesatz,
        'Yantramanav': PartY.yantramanav,
        'Yarndings 12': PartY.yarndings12,
        'Yarndings 12 Charted': PartY.yarndings12Charted,
        'Yarndings 20': PartY.yarndings20,
        'Yarndings 20 Charted': PartY.yarndings20Charted,
        'Yatra One': PartY.yatraOne,
        'Yellowtail': PartY.yellowtail,
        'Yeon Sung': PartY.yeonSung,
        'Yeseva One': PartY.yesevaOne,
        'Yesteryear': PartY.yesteryear,
        'Yomogi': PartY.yomogi,
        'Young Serif': PartY.youngSerif,
        'Yrsa': PartY.yrsa,
        'Ysabeau': PartY.ysabeau,
        'Ysabeau Infant': PartY.ysabeauInfant,
        'Ysabeau Office': PartY.ysabeauOffice,
        'Ysabeau SC': PartY.ysabeauSc,
        'Yuji Boku': PartY.yujiBoku,
        'Yuji Hentaigana Akari': PartY.yujiHentaiganaAkari,
        'Yuji Hentaigana Akebono': PartY.yujiHentaiganaAkebono,
        'Yuji Mai': PartY.yujiMai,
        'Yuji Syuku': PartY.yujiSyuku,
        'Yusei Magic': PartY.yuseiMagic,
        'ZCOOL KuaiLe': PartZ.zcoolKuaiLe,
        'ZCOOL QingKe HuangYou': PartZ.zcoolQingKeHuangYou,
        'ZCOOL XiaoWei': PartZ.zcoolXiaoWei,
        'Zain': PartZ.zain,
        'Zen Antique': PartZ.zenAntique,
        'Zen Antique Soft': PartZ.zenAntiqueSoft,
        'Zen Dots': PartZ.zenDots,
        'Zen Kaku Gothic Antique': PartZ.zenKakuGothicAntique,
        'Zen Kaku Gothic New': PartZ.zenKakuGothicNew,
        'Zen Kurenaido': PartZ.zenKurenaido,
        'Zen Loop': PartZ.zenLoop,
        'Zen Maru Gothic': PartZ.zenMaruGothic,
        'Zen Old Mincho': PartZ.zenOldMincho,
        'Zen Tokyo Zoo': PartZ.zenTokyoZoo,
        'Zeyada': PartZ.zeyada,
        'Zhi Mang Xing': PartZ.zhiMangXing,
        'Zilla Slab': PartZ.zillaSlab,
        'Zilla Slab Highlight': PartZ.zillaSlabHighlight,
      };

  /// Get a map of all available fonts and their associated text themes.
  ///
  /// Returns a map where the key is the name of the font family and the value
  /// is the corresponding [GoogleFonts] `TextTheme` method.
  static Map<String, TextTheme Function([TextTheme?])> _asMapOfTextThemes() =>
      const {
        'ABeeZee': PartA.aBeeZeeTextTheme,
        'ADLaM Display': PartA.aDLaMDisplayTextTheme,
        'AR One Sans': PartA.arOneSansTextTheme,
        'Abel': PartA.abelTextTheme,
        'Abhaya Libre': PartA.abhayaLibreTextTheme,
        'Aboreto': PartA.aboretoTextTheme,
        'Abril Fatface': PartA.abrilFatfaceTextTheme,
        'Abyssinica SIL': PartA.abyssinicaSilTextTheme,
        'Aclonica': PartA.aclonicaTextTheme,
        'Acme': PartA.acmeTextTheme,
        'Actor': PartA.actorTextTheme,
        'Adamina': PartA.adaminaTextTheme,
        'Advent Pro': PartA.adventProTextTheme,
        'Afacad': PartA.afacadTextTheme,
        'Agbalumo': PartA.agbalumoTextTheme,
        'Agdasima': PartA.agdasimaTextTheme,
        'Aguafina Script': PartA.aguafinaScriptTextTheme,
        'Akatab': PartA.akatabTextTheme,
        'Akaya Kanadaka': PartA.akayaKanadakaTextTheme,
        'Akaya Telivigala': PartA.akayaTelivigalaTextTheme,
        'Akronim': PartA.akronimTextTheme,
        'Akshar': PartA.aksharTextTheme,
        'Aladin': PartA.aladinTextTheme,
        'Alata': PartA.alataTextTheme,
        'Alatsi': PartA.alatsiTextTheme,
        'Albert Sans': PartA.albertSansTextTheme,
        'Aldrich': PartA.aldrichTextTheme,
        'Alef': PartA.alefTextTheme,
        'Alegreya': PartA.alegreyaTextTheme,
        'Alegreya SC': PartA.alegreyaScTextTheme,
        'Alegreya Sans': PartA.alegreyaSansTextTheme,
        'Alegreya Sans SC': PartA.alegreyaSansScTextTheme,
        'Aleo': PartA.aleoTextTheme,
        'Alex Brush': PartA.alexBrushTextTheme,
        'Alexandria': PartA.alexandriaTextTheme,
        'Alfa Slab One': PartA.alfaSlabOneTextTheme,
        'Alice': PartA.aliceTextTheme,
        'Alike': PartA.alikeTextTheme,
        'Alike Angular': PartA.alikeAngularTextTheme,
        'Alkalami': PartA.alkalamiTextTheme,
        'Alkatra': PartA.alkatraTextTheme,
        'Allan': PartA.allanTextTheme,
        'Allerta': PartA.allertaTextTheme,
        'Allerta Stencil': PartA.allertaStencilTextTheme,
        'Allison': PartA.allisonTextTheme,
        'Allura': PartA.alluraTextTheme,
        'Almarai': PartA.almaraiTextTheme,
        'Almendra': PartA.almendraTextTheme,
        'Almendra Display': PartA.almendraDisplayTextTheme,
        'Almendra SC': PartA.almendraScTextTheme,
        'Alumni Sans': PartA.alumniSansTextTheme,
        'Alumni Sans Collegiate One': PartA.alumniSansCollegiateOneTextTheme,
        'Alumni Sans Inline One': PartA.alumniSansInlineOneTextTheme,
        'Alumni Sans Pinstripe': PartA.alumniSansPinstripeTextTheme,
        'Amarante': PartA.amaranteTextTheme,
        'Amaranth': PartA.amaranthTextTheme,
        'Amatic SC': PartA.amaticScTextTheme,
        'Amethysta': PartA.amethystaTextTheme,
        'Amiko': PartA.amikoTextTheme,
        'Amiri': PartA.amiriTextTheme,
        'Amiri Quran': PartA.amiriQuranTextTheme,
        'Amita': PartA.amitaTextTheme,
        'Anaheim': PartA.anaheimTextTheme,
        'Andada Pro': PartA.andadaProTextTheme,
        'Andika': PartA.andikaTextTheme,
        'Anek Bangla': PartA.anekBanglaTextTheme,
        'Anek Devanagari': PartA.anekDevanagariTextTheme,
        'Anek Gujarati': PartA.anekGujaratiTextTheme,
        'Anek Gurmukhi': PartA.anekGurmukhiTextTheme,
        'Anek Kannada': PartA.anekKannadaTextTheme,
        'Anek Latin': PartA.anekLatinTextTheme,
        'Anek Malayalam': PartA.anekMalayalamTextTheme,
        'Anek Odia': PartA.anekOdiaTextTheme,
        'Anek Tamil': PartA.anekTamilTextTheme,
        'Anek Telugu': PartA.anekTeluguTextTheme,
        'Angkor': PartA.angkorTextTheme,
        'Annapurna SIL': PartA.annapurnaSilTextTheme,
        'Annie Use Your Telescope': PartA.annieUseYourTelescopeTextTheme,
        'Anonymous Pro': PartA.anonymousProTextTheme,
        'Anta': PartA.antaTextTheme,
        'Antic': PartA.anticTextTheme,
        'Antic Didone': PartA.anticDidoneTextTheme,
        'Antic Slab': PartA.anticSlabTextTheme,
        'Anton': PartA.antonTextTheme,
        'Anton SC': PartA.antonScTextTheme,
        'Antonio': PartA.antonioTextTheme,
        'Anuphan': PartA.anuphanTextTheme,
        'Anybody': PartA.anybodyTextTheme,
        'Aoboshi One': PartA.aoboshiOneTextTheme,
        'Arapey': PartA.arapeyTextTheme,
        'Arbutus': PartA.arbutusTextTheme,
        'Arbutus Slab': PartA.arbutusSlabTextTheme,
        'Architects Daughter': PartA.architectsDaughterTextTheme,
        'Archivo': PartA.archivoTextTheme,
        'Archivo Black': PartA.archivoBlackTextTheme,
        'Archivo Narrow': PartA.archivoNarrowTextTheme,
        'Are You Serious': PartA.areYouSeriousTextTheme,
        'Aref Ruqaa': PartA.arefRuqaaTextTheme,
        'Aref Ruqaa Ink': PartA.arefRuqaaInkTextTheme,
        'Arima': PartA.arimaTextTheme,
        'Arimo': PartA.arimoTextTheme,
        'Arizonia': PartA.arizoniaTextTheme,
        'Armata': PartA.armataTextTheme,
        'Arsenal': PartA.arsenalTextTheme,
        'Arsenal SC': PartA.arsenalScTextTheme,
        'Artifika': PartA.artifikaTextTheme,
        'Arvo': PartA.arvoTextTheme,
        'Arya': PartA.aryaTextTheme,
        'Asap': PartA.asapTextTheme,
        'Asap Condensed': PartA.asapCondensedTextTheme,
        'Asar': PartA.asarTextTheme,
        'Asset': PartA.assetTextTheme,
        'Assistant': PartA.assistantTextTheme,
        'Astloch': PartA.astlochTextTheme,
        'Asul': PartA.asulTextTheme,
        'Athiti': PartA.athitiTextTheme,
        'Atkinson Hyperlegible': PartA.atkinsonHyperlegibleTextTheme,
        'Atma': PartA.atmaTextTheme,
        'Atomic Age': PartA.atomicAgeTextTheme,
        'Aubrey': PartA.aubreyTextTheme,
        'Audiowide': PartA.audiowideTextTheme,
        'Autour One': PartA.autourOneTextTheme,
        'Average': PartA.averageTextTheme,
        'Average Sans': PartA.averageSansTextTheme,
        'Averia Gruesa Libre': PartA.averiaGruesaLibreTextTheme,
        'Averia Libre': PartA.averiaLibreTextTheme,
        'Averia Sans Libre': PartA.averiaSansLibreTextTheme,
        'Averia Serif Libre': PartA.averiaSerifLibreTextTheme,
        'Azeret Mono': PartA.azeretMonoTextTheme,
        'B612': PartB.b612TextTheme,
        'B612 Mono': PartB.b612MonoTextTheme,
        'BIZ UDGothic': PartB.bizUDGothicTextTheme,
        'BIZ UDMincho': PartB.bizUDMinchoTextTheme,
        'BIZ UDPGothic': PartB.bizUDPGothicTextTheme,
        'BIZ UDPMincho': PartB.bizUDPMinchoTextTheme,
        'Babylonica': PartB.babylonicaTextTheme,
        'Bacasime Antique': PartB.bacasimeAntiqueTextTheme,
        'Bad Script': PartB.badScriptTextTheme,
        'Bagel Fat One': PartB.bagelFatOneTextTheme,
        'Bahiana': PartB.bahianaTextTheme,
        'Bahianita': PartB.bahianitaTextTheme,
        'Bai Jamjuree': PartB.baiJamjureeTextTheme,
        'Bakbak One': PartB.bakbakOneTextTheme,
        'Ballet': PartB.balletTextTheme,
        'Baloo 2': PartB.baloo2TextTheme,
        'Baloo Bhai 2': PartB.balooBhai2TextTheme,
        'Baloo Bhaijaan 2': PartB.balooBhaijaan2TextTheme,
        'Baloo Bhaina 2': PartB.balooBhaina2TextTheme,
        'Baloo Chettan 2': PartB.balooChettan2TextTheme,
        'Baloo Da 2': PartB.balooDa2TextTheme,
        'Baloo Paaji 2': PartB.balooPaaji2TextTheme,
        'Baloo Tamma 2': PartB.balooTamma2TextTheme,
        'Baloo Tammudu 2': PartB.balooTammudu2TextTheme,
        'Baloo Thambi 2': PartB.balooThambi2TextTheme,
        'Balsamiq Sans': PartB.balsamiqSansTextTheme,
        'Balthazar': PartB.balthazarTextTheme,
        'Bangers': PartB.bangersTextTheme,
        'Barlow': PartB.barlowTextTheme,
        'Barlow Condensed': PartB.barlowCondensedTextTheme,
        'Barlow Semi Condensed': PartB.barlowSemiCondensedTextTheme,
        'Barriecito': PartB.barriecitoTextTheme,
        'Barrio': PartB.barrioTextTheme,
        'Basic': PartB.basicTextTheme,
        'Baskervville': PartB.baskervvilleTextTheme,
        'Baskervville SC': PartB.baskervvilleScTextTheme,
        'Battambang': PartB.battambangTextTheme,
        'Baumans': PartB.baumansTextTheme,
        'Bayon': PartB.bayonTextTheme,
        'Be Vietnam Pro': PartB.beVietnamProTextTheme,
        'Beau Rivage': PartB.beauRivageTextTheme,
        'Bebas Neue': PartB.bebasNeueTextTheme,
        'Beiruti': PartB.beirutiTextTheme,
        'Belanosima': PartB.belanosimaTextTheme,
        'Belgrano': PartB.belgranoTextTheme,
        'Bellefair': PartB.bellefairTextTheme,
        'Belleza': PartB.bellezaTextTheme,
        'Bellota': PartB.bellotaTextTheme,
        'Bellota Text': PartB.bellotaTextTextTheme,
        'BenchNine': PartB.benchNineTextTheme,
        'Benne': PartB.benneTextTheme,
        'Bentham': PartB.benthamTextTheme,
        'Berkshire Swash': PartB.berkshireSwashTextTheme,
        'Besley': PartB.besleyTextTheme,
        'Beth Ellen': PartB.bethEllenTextTheme,
        'Bevan': PartB.bevanTextTheme,
        'BhuTuka Expanded One': PartB.bhuTukaExpandedOneTextTheme,
        'Big Shoulders Display': PartB.bigShouldersDisplayTextTheme,
        'Big Shoulders Inline Display':
            PartB.bigShouldersInlineDisplayTextTheme,
        'Big Shoulders Inline Text': PartB.bigShouldersInlineTextTextTheme,
        'Big Shoulders Stencil Display':
            PartB.bigShouldersStencilDisplayTextTheme,
        'Big Shoulders Stencil Text': PartB.bigShouldersStencilTextTextTheme,
        'Big Shoulders Text': PartB.bigShouldersTextTextTheme,
        'Bigelow Rules': PartB.bigelowRulesTextTheme,
        'Bigshot One': PartB.bigshotOneTextTheme,
        'Bilbo': PartB.bilboTextTheme,
        'Bilbo Swash Caps': PartB.bilboSwashCapsTextTheme,
        'BioRhyme': PartB.bioRhymeTextTheme,
        'BioRhyme Expanded': PartB.bioRhymeExpandedTextTheme,
        'Birthstone': PartB.birthstoneTextTheme,
        'Birthstone Bounce': PartB.birthstoneBounceTextTheme,
        'Biryani': PartB.biryaniTextTheme,
        'Bitter': PartB.bitterTextTheme,
        'Black And White Picture': PartB.blackAndWhitePictureTextTheme,
        'Black Han Sans': PartB.blackHanSansTextTheme,
        'Black Ops One': PartB.blackOpsOneTextTheme,
        'Blaka': PartB.blakaTextTheme,
        'Blaka Hollow': PartB.blakaHollowTextTheme,
        'Blaka Ink': PartB.blakaInkTextTheme,
        'Blinker': PartB.blinkerTextTheme,
        'Bodoni Moda': PartB.bodoniModaTextTheme,
        'Bodoni Moda SC': PartB.bodoniModaScTextTheme,
        'Bokor': PartB.bokorTextTheme,
        'Bona Nova': PartB.bonaNovaTextTheme,
        'Bona Nova SC': PartB.bonaNovaScTextTheme,
        'Bonbon': PartB.bonbonTextTheme,
        'Bonheur Royale': PartB.bonheurRoyaleTextTheme,
        'Boogaloo': PartB.boogalooTextTheme,
        'Borel': PartB.borelTextTheme,
        'Bowlby One': PartB.bowlbyOneTextTheme,
        'Bowlby One SC': PartB.bowlbyOneScTextTheme,
        'Braah One': PartB.braahOneTextTheme,
        'Brawler': PartB.brawlerTextTheme,
        'Bree Serif': PartB.breeSerifTextTheme,
        'Bricolage Grotesque': PartB.bricolageGrotesqueTextTheme,
        'Bruno Ace': PartB.brunoAceTextTheme,
        'Bruno Ace SC': PartB.brunoAceScTextTheme,
        'Brygada 1918': PartB.brygada1918TextTheme,
        'Bubblegum Sans': PartB.bubblegumSansTextTheme,
        'Bubbler One': PartB.bubblerOneTextTheme,
        'Buda': PartB.budaTextTheme,
        'Buenard': PartB.buenardTextTheme,
        'Bungee': PartB.bungeeTextTheme,
        'Bungee Hairline': PartB.bungeeHairlineTextTheme,
        'Bungee Inline': PartB.bungeeInlineTextTheme,
        'Bungee Outline': PartB.bungeeOutlineTextTheme,
        'Bungee Shade': PartB.bungeeShadeTextTheme,
        'Bungee Spice': PartB.bungeeSpiceTextTheme,
        'Butcherman': PartB.butchermanTextTheme,
        'Butterfly Kids': PartB.butterflyKidsTextTheme,
        'Cabin': PartC.cabinTextTheme,
        'Cabin Condensed': PartC.cabinCondensedTextTheme,
        'Cabin Sketch': PartC.cabinSketchTextTheme,
        'Cactus Classical Serif': PartC.cactusClassicalSerifTextTheme,
        'Caesar Dressing': PartC.caesarDressingTextTheme,
        'Cagliostro': PartC.cagliostroTextTheme,
        'Cairo': PartC.cairoTextTheme,
        'Cairo Play': PartC.cairoPlayTextTheme,
        'Caladea': PartC.caladeaTextTheme,
        'Calistoga': PartC.calistogaTextTheme,
        'Calligraffitti': PartC.calligraffittiTextTheme,
        'Cambay': PartC.cambayTextTheme,
        'Cambo': PartC.camboTextTheme,
        'Candal': PartC.candalTextTheme,
        'Cantarell': PartC.cantarellTextTheme,
        'Cantata One': PartC.cantataOneTextTheme,
        'Cantora One': PartC.cantoraOneTextTheme,
        'Caprasimo': PartC.caprasimoTextTheme,
        'Capriola': PartC.capriolaTextTheme,
        'Caramel': PartC.caramelTextTheme,
        'Carattere': PartC.carattereTextTheme,
        'Cardo': PartC.cardoTextTheme,
        'Carlito': PartC.carlitoTextTheme,
        'Carme': PartC.carmeTextTheme,
        'Carrois Gothic': PartC.carroisGothicTextTheme,
        'Carrois Gothic SC': PartC.carroisGothicScTextTheme,
        'Carter One': PartC.carterOneTextTheme,
        'Castoro': PartC.castoroTextTheme,
        'Castoro Titling': PartC.castoroTitlingTextTheme,
        'Catamaran': PartC.catamaranTextTheme,
        'Caudex': PartC.caudexTextTheme,
        'Caveat': PartC.caveatTextTheme,
        'Caveat Brush': PartC.caveatBrushTextTheme,
        'Cedarville Cursive': PartC.cedarvilleCursiveTextTheme,
        'Ceviche One': PartC.cevicheOneTextTheme,
        'Chakra Petch': PartC.chakraPetchTextTheme,
        'Changa': PartC.changaTextTheme,
        'Changa One': PartC.changaOneTextTheme,
        'Chango': PartC.changoTextTheme,
        'Charis SIL': PartC.charisSilTextTheme,
        'Charm': PartC.charmTextTheme,
        'Charmonman': PartC.charmonmanTextTheme,
        'Chathura': PartC.chathuraTextTheme,
        'Chau Philomene One': PartC.chauPhilomeneOneTextTheme,
        'Chela One': PartC.chelaOneTextTheme,
        'Chelsea Market': PartC.chelseaMarketTextTheme,
        'Chenla': PartC.chenlaTextTheme,
        'Cherish': PartC.cherishTextTheme,
        'Cherry Bomb One': PartC.cherryBombOneTextTheme,
        'Cherry Cream Soda': PartC.cherryCreamSodaTextTheme,
        'Cherry Swash': PartC.cherrySwashTextTheme,
        'Chewy': PartC.chewyTextTheme,
        'Chicle': PartC.chicleTextTheme,
        'Chilanka': PartC.chilankaTextTheme,
        'Chivo': PartC.chivoTextTheme,
        'Chivo Mono': PartC.chivoMonoTextTheme,
        'Chocolate Classical Sans': PartC.chocolateClassicalSansTextTheme,
        'Chokokutai': PartC.chokokutaiTextTheme,
        'Chonburi': PartC.chonburiTextTheme,
        'Cinzel': PartC.cinzelTextTheme,
        'Cinzel Decorative': PartC.cinzelDecorativeTextTheme,
        'Clicker Script': PartC.clickerScriptTextTheme,
        'Climate Crisis': PartC.climateCrisisTextTheme,
        'Coda': PartC.codaTextTheme,
        'Codystar': PartC.codystarTextTheme,
        'Coiny': PartC.coinyTextTheme,
        'Combo': PartC.comboTextTheme,
        'Comfortaa': PartC.comfortaaTextTheme,
        'Comforter': PartC.comforterTextTheme,
        'Comforter Brush': PartC.comforterBrushTextTheme,
        'Comic Neue': PartC.comicNeueTextTheme,
        'Coming Soon': PartC.comingSoonTextTheme,
        'Comme': PartC.commeTextTheme,
        'Commissioner': PartC.commissionerTextTheme,
        'Concert One': PartC.concertOneTextTheme,
        'Condiment': PartC.condimentTextTheme,
        'Content': PartC.contentTextTheme,
        'Contrail One': PartC.contrailOneTextTheme,
        'Convergence': PartC.convergenceTextTheme,
        'Cookie': PartC.cookieTextTheme,
        'Copse': PartC.copseTextTheme,
        'Corben': PartC.corbenTextTheme,
        'Corinthia': PartC.corinthiaTextTheme,
        'Cormorant': PartC.cormorantTextTheme,
        'Cormorant Garamond': PartC.cormorantGaramondTextTheme,
        'Cormorant Infant': PartC.cormorantInfantTextTheme,
        'Cormorant SC': PartC.cormorantScTextTheme,
        'Cormorant Unicase': PartC.cormorantUnicaseTextTheme,
        'Cormorant Upright': PartC.cormorantUprightTextTheme,
        'Courgette': PartC.courgetteTextTheme,
        'Courier Prime': PartC.courierPrimeTextTheme,
        'Cousine': PartC.cousineTextTheme,
        'Coustard': PartC.coustardTextTheme,
        'Covered By Your Grace': PartC.coveredByYourGraceTextTheme,
        'Crafty Girls': PartC.craftyGirlsTextTheme,
        'Creepster': PartC.creepsterTextTheme,
        'Crete Round': PartC.creteRoundTextTheme,
        'Crimson Pro': PartC.crimsonProTextTheme,
        'Crimson Text': PartC.crimsonTextTextTheme,
        'Croissant One': PartC.croissantOneTextTheme,
        'Crushed': PartC.crushedTextTheme,
        'Cuprum': PartC.cuprumTextTheme,
        'Cute Font': PartC.cuteFontTextTheme,
        'Cutive': PartC.cutiveTextTheme,
        'Cutive Mono': PartC.cutiveMonoTextTheme,
        'DM Mono': PartD.dmMonoTextTheme,
        'DM Sans': PartD.dmSansTextTheme,
        'DM Serif Display': PartD.dmSerifDisplayTextTheme,
        'DM Serif Text': PartD.dmSerifTextTextTheme,
        'Dai Banna SIL': PartD.daiBannaSilTextTheme,
        'Damion': PartD.damionTextTheme,
        'Dancing Script': PartD.dancingScriptTextTheme,
        'Danfo': PartD.danfoTextTheme,
        'Dangrek': PartD.dangrekTextTheme,
        'Darker Grotesque': PartD.darkerGrotesqueTextTheme,
        'Darumadrop One': PartD.darumadropOneTextTheme,
        'David Libre': PartD.davidLibreTextTheme,
        'Dawning of a New Day': PartD.dawningOfANewDayTextTheme,
        'Days One': PartD.daysOneTextTheme,
        'Dekko': PartD.dekkoTextTheme,
        'Dela Gothic One': PartD.delaGothicOneTextTheme,
        'Delicious Handrawn': PartD.deliciousHandrawnTextTheme,
        'Delius': PartD.deliusTextTheme,
        'Delius Swash Caps': PartD.deliusSwashCapsTextTheme,
        'Delius Unicase': PartD.deliusUnicaseTextTheme,
        'Della Respira': PartD.dellaRespiraTextTheme,
        'Denk One': PartD.denkOneTextTheme,
        'Devonshire': PartD.devonshireTextTheme,
        'Dhurjati': PartD.dhurjatiTextTheme,
        'Didact Gothic': PartD.didactGothicTextTheme,
        'Diphylleia': PartD.diphylleiaTextTheme,
        'Diplomata': PartD.diplomataTextTheme,
        'Diplomata SC': PartD.diplomataScTextTheme,
        'Do Hyeon': PartD.doHyeonTextTheme,
        'Dokdo': PartD.dokdoTextTheme,
        'Domine': PartD.domineTextTheme,
        'Donegal One': PartD.donegalOneTextTheme,
        'Dongle': PartD.dongleTextTheme,
        'Doppio One': PartD.doppioOneTextTheme,
        'Dorsa': PartD.dorsaTextTheme,
        'Dosis': PartD.dosisTextTheme,
        'DotGothic16': PartD.dotGothic16TextTheme,
        'Dr Sugiyama': PartD.drSugiyamaTextTheme,
        'Duru Sans': PartD.duruSansTextTheme,
        'DynaPuff': PartD.dynaPuffTextTheme,
        'Dynalight': PartD.dynalightTextTheme,
        'EB Garamond': PartE.ebGaramondTextTheme,
        'Eagle Lake': PartE.eagleLakeTextTheme,
        'East Sea Dokdo': PartE.eastSeaDokdoTextTheme,
        'Eater': PartE.eaterTextTheme,
        'Economica': PartE.economicaTextTheme,
        'Eczar': PartE.eczarTextTheme,
        'Edu AU VIC WA NT Hand': PartE.eduAuVicWaNtHandTextTheme,
        'Edu NSW ACT Foundation': PartE.eduNswActFoundationTextTheme,
        'Edu QLD Beginner': PartE.eduQldBeginnerTextTheme,
        'Edu SA Beginner': PartE.eduSaBeginnerTextTheme,
        'Edu TAS Beginner': PartE.eduTasBeginnerTextTheme,
        'Edu VIC WA NT Beginner': PartE.eduVicWaNtBeginnerTextTheme,
        'El Messiri': PartE.elMessiriTextTheme,
        'Electrolize': PartE.electrolizeTextTheme,
        'Elsie': PartE.elsieTextTheme,
        'Elsie Swash Caps': PartE.elsieSwashCapsTextTheme,
        'Emblema One': PartE.emblemaOneTextTheme,
        'Emilys Candy': PartE.emilysCandyTextTheme,
        'Encode Sans': PartE.encodeSansTextTheme,
        'Encode Sans Condensed': PartE.encodeSansCondensedTextTheme,
        'Encode Sans Expanded': PartE.encodeSansExpandedTextTheme,
        'Encode Sans SC': PartE.encodeSansScTextTheme,
        'Encode Sans Semi Condensed': PartE.encodeSansSemiCondensedTextTheme,
        'Encode Sans Semi Expanded': PartE.encodeSansSemiExpandedTextTheme,
        'Engagement': PartE.engagementTextTheme,
        'Englebert': PartE.englebertTextTheme,
        'Enriqueta': PartE.enriquetaTextTheme,
        'Ephesis': PartE.ephesisTextTheme,
        'Epilogue': PartE.epilogueTextTheme,
        'Erica One': PartE.ericaOneTextTheme,
        'Esteban': PartE.estebanTextTheme,
        'Estonia': PartE.estoniaTextTheme,
        'Euphoria Script': PartE.euphoriaScriptTextTheme,
        'Ewert': PartE.ewertTextTheme,
        'Exo': PartE.exoTextTheme,
        'Exo 2': PartE.exo2TextTheme,
        'Expletus Sans': PartE.expletusSansTextTheme,
        'Explora': PartE.exploraTextTheme,
        'Fahkwang': PartF.fahkwangTextTheme,
        'Familjen Grotesk': PartF.familjenGroteskTextTheme,
        'Fanwood Text': PartF.fanwoodTextTextTheme,
        'Farro': PartF.farroTextTheme,
        'Farsan': PartF.farsanTextTheme,
        'Fascinate': PartF.fascinateTextTheme,
        'Fascinate Inline': PartF.fascinateInlineTextTheme,
        'Faster One': PartF.fasterOneTextTheme,
        'Fasthand': PartF.fasthandTextTheme,
        'Fauna One': PartF.faunaOneTextTheme,
        'Faustina': PartF.faustinaTextTheme,
        'Federant': PartF.federantTextTheme,
        'Federo': PartF.federoTextTheme,
        'Felipa': PartF.felipaTextTheme,
        'Fenix': PartF.fenixTextTheme,
        'Festive': PartF.festiveTextTheme,
        'Figtree': PartF.figtreeTextTheme,
        'Finger Paint': PartF.fingerPaintTextTheme,
        'Finlandica': PartF.finlandicaTextTheme,
        'Fira Code': PartF.firaCodeTextTheme,
        'Fira Mono': PartF.firaMonoTextTheme,
        'Fira Sans': PartF.firaSansTextTheme,
        'Fira Sans Condensed': PartF.firaSansCondensedTextTheme,
        'Fira Sans Extra Condensed': PartF.firaSansExtraCondensedTextTheme,
        'Fjalla One': PartF.fjallaOneTextTheme,
        'Fjord One': PartF.fjordOneTextTheme,
        'Flamenco': PartF.flamencoTextTheme,
        'Flavors': PartF.flavorsTextTheme,
        'Fleur De Leah': PartF.fleurDeLeahTextTheme,
        'Flow Block': PartF.flowBlockTextTheme,
        'Flow Circular': PartF.flowCircularTextTheme,
        'Flow Rounded': PartF.flowRoundedTextTheme,
        'Foldit': PartF.folditTextTheme,
        'Fondamento': PartF.fondamentoTextTheme,
        'Fontdiner Swanky': PartF.fontdinerSwankyTextTheme,
        'Forum': PartF.forumTextTheme,
        'Fragment Mono': PartF.fragmentMonoTextTheme,
        'Francois One': PartF.francoisOneTextTheme,
        'Frank Ruhl Libre': PartF.frankRuhlLibreTextTheme,
        'Fraunces': PartF.frauncesTextTheme,
        'Freckle Face': PartF.freckleFaceTextTheme,
        'Fredericka the Great': PartF.frederickaTheGreatTextTheme,
        'Fredoka': PartF.fredokaTextTheme,
        'Freehand': PartF.freehandTextTheme,
        'Freeman': PartF.freemanTextTheme,
        'Fresca': PartF.frescaTextTheme,
        'Frijole': PartF.frijoleTextTheme,
        'Fruktur': PartF.frukturTextTheme,
        'Fugaz One': PartF.fugazOneTextTheme,
        'Fuggles': PartF.fugglesTextTheme,
        'Fustat': PartF.fustatTextTheme,
        'Fuzzy Bubbles': PartF.fuzzyBubblesTextTheme,
        'GFS Didot': PartG.gfsDidotTextTheme,
        'GFS Neohellenic': PartG.gfsNeohellenicTextTheme,
        'Ga Maamli': PartG.gaMaamliTextTheme,
        'Gabarito': PartG.gabaritoTextTheme,
        'Gabriela': PartG.gabrielaTextTheme,
        'Gaegu': PartG.gaeguTextTheme,
        'Gafata': PartG.gafataTextTheme,
        'Gajraj One': PartG.gajrajOneTextTheme,
        'Galada': PartG.galadaTextTheme,
        'Galdeano': PartG.galdeanoTextTheme,
        'Galindo': PartG.galindoTextTheme,
        'Gamja Flower': PartG.gamjaFlowerTextTheme,
        'Gantari': PartG.gantariTextTheme,
        'Gasoek One': PartG.gasoekOneTextTheme,
        'Gayathri': PartG.gayathriTextTheme,
        'Gelasio': PartG.gelasioTextTheme,
        'Gemunu Libre': PartG.gemunuLibreTextTheme,
        'Genos': PartG.genosTextTheme,
        'Gentium Book Plus': PartG.gentiumBookPlusTextTheme,
        'Gentium Plus': PartG.gentiumPlusTextTheme,
        'Geo': PartG.geoTextTheme,
        'Geologica': PartG.geologicaTextTheme,
        'Georama': PartG.georamaTextTheme,
        'Geostar': PartG.geostarTextTheme,
        'Geostar Fill': PartG.geostarFillTextTheme,
        'Germania One': PartG.germaniaOneTextTheme,
        'Gideon Roman': PartG.gideonRomanTextTheme,
        'Gidugu': PartG.giduguTextTheme,
        'Gilda Display': PartG.gildaDisplayTextTheme,
        'Girassol': PartG.girassolTextTheme,
        'Give You Glory': PartG.giveYouGloryTextTheme,
        'Glass Antiqua': PartG.glassAntiquaTextTheme,
        'Glegoo': PartG.glegooTextTheme,
        'Gloock': PartG.gloockTextTheme,
        'Gloria Hallelujah': PartG.gloriaHallelujahTextTheme,
        'Glory': PartG.gloryTextTheme,
        'Gluten': PartG.glutenTextTheme,
        'Goblin One': PartG.goblinOneTextTheme,
        'Gochi Hand': PartG.gochiHandTextTheme,
        'Goldman': PartG.goldmanTextTheme,
        'Golos Text': PartG.golosTextTextTheme,
        'Gorditas': PartG.gorditasTextTheme,
        'Gothic A1': PartG.gothicA1TextTheme,
        'Gotu': PartG.gotuTextTheme,
        'Goudy Bookletter 1911': PartG.goudyBookletter1911TextTheme,
        'Gowun Batang': PartG.gowunBatangTextTheme,
        'Gowun Dodum': PartG.gowunDodumTextTheme,
        'Graduate': PartG.graduateTextTheme,
        'Grand Hotel': PartG.grandHotelTextTheme,
        'Grandiflora One': PartG.grandifloraOneTextTheme,
        'Grandstander': PartG.grandstanderTextTheme,
        'Grape Nuts': PartG.grapeNutsTextTheme,
        'Gravitas One': PartG.gravitasOneTextTheme,
        'Great Vibes': PartG.greatVibesTextTheme,
        'Grechen Fuemen': PartG.grechenFuemenTextTheme,
        'Grenze': PartG.grenzeTextTheme,
        'Grenze Gotisch': PartG.grenzeGotischTextTheme,
        'Grey Qo': PartG.greyQoTextTheme,
        'Griffy': PartG.griffyTextTheme,
        'Gruppo': PartG.gruppoTextTheme,
        'Gudea': PartG.gudeaTextTheme,
        'Gugi': PartG.gugiTextTheme,
        'Gulzar': PartG.gulzarTextTheme,
        'Gupter': PartG.gupterTextTheme,
        'Gurajada': PartG.gurajadaTextTheme,
        'Gwendolyn': PartG.gwendolynTextTheme,
        'Habibi': PartH.habibiTextTheme,
        'Hachi Maru Pop': PartH.hachiMaruPopTextTheme,
        'Hahmlet': PartH.hahmletTextTheme,
        'Halant': PartH.halantTextTheme,
        'Hammersmith One': PartH.hammersmithOneTextTheme,
        'Hanalei': PartH.hanaleiTextTheme,
        'Hanalei Fill': PartH.hanaleiFillTextTheme,
        'Handjet': PartH.handjetTextTheme,
        'Handlee': PartH.handleeTextTheme,
        'Hanken Grotesk': PartH.hankenGroteskTextTheme,
        'Hanuman': PartH.hanumanTextTheme,
        'Happy Monkey': PartH.happyMonkeyTextTheme,
        'Harmattan': PartH.harmattanTextTheme,
        'Headland One': PartH.headlandOneTextTheme,
        'Hedvig Letters Sans': PartH.hedvigLettersSansTextTheme,
        'Hedvig Letters Serif': PartH.hedvigLettersSerifTextTheme,
        'Heebo': PartH.heeboTextTheme,
        'Henny Penny': PartH.hennyPennyTextTheme,
        'Hepta Slab': PartH.heptaSlabTextTheme,
        'Herr Von Muellerhoff': PartH.herrVonMuellerhoffTextTheme,
        'Hi Melody': PartH.hiMelodyTextTheme,
        'Hina Mincho': PartH.hinaMinchoTextTheme,
        'Hind': PartH.hindTextTheme,
        'Hind Guntur': PartH.hindGunturTextTheme,
        'Hind Madurai': PartH.hindMaduraiTextTheme,
        'Hind Siliguri': PartH.hindSiliguriTextTheme,
        'Hind Vadodara': PartH.hindVadodaraTextTheme,
        'Holtwood One SC': PartH.holtwoodOneScTextTheme,
        'Homemade Apple': PartH.homemadeAppleTextTheme,
        'Homenaje': PartH.homenajeTextTheme,
        'Honk': PartH.honkTextTheme,
        'Hubballi': PartH.hubballiTextTheme,
        'Hurricane': PartH.hurricaneTextTheme,
        'IBM Plex Mono': PartI.ibmPlexMonoTextTheme,
        'IBM Plex Sans': PartI.ibmPlexSansTextTheme,
        'IBM Plex Sans Arabic': PartI.ibmPlexSansArabicTextTheme,
        'IBM Plex Sans Condensed': PartI.ibmPlexSansCondensedTextTheme,
        'IBM Plex Sans Devanagari': PartI.ibmPlexSansDevanagariTextTheme,
        'IBM Plex Sans Hebrew': PartI.ibmPlexSansHebrewTextTheme,
        'IBM Plex Sans JP': PartI.ibmPlexSansJpTextTheme,
        'IBM Plex Sans KR': PartI.ibmPlexSansKrTextTheme,
        'IBM Plex Sans Thai': PartI.ibmPlexSansThaiTextTheme,
        'IBM Plex Sans Thai Looped': PartI.ibmPlexSansThaiLoopedTextTheme,
        'IBM Plex Serif': PartI.ibmPlexSerifTextTheme,
        'IM Fell DW Pica': PartI.imFellDwPicaTextTheme,
        'IM Fell DW Pica SC': PartI.imFellDwPicaScTextTheme,
        'IM Fell Double Pica': PartI.imFellDoublePicaTextTheme,
        'IM Fell Double Pica SC': PartI.imFellDoublePicaScTextTheme,
        'IM Fell English': PartI.imFellEnglishTextTheme,
        'IM Fell English SC': PartI.imFellEnglishScTextTheme,
        'IM Fell French Canon': PartI.imFellFrenchCanonTextTheme,
        'IM Fell French Canon SC': PartI.imFellFrenchCanonScTextTheme,
        'IM Fell Great Primer': PartI.imFellGreatPrimerTextTheme,
        'IM Fell Great Primer SC': PartI.imFellGreatPrimerScTextTheme,
        'Ibarra Real Nova': PartI.ibarraRealNovaTextTheme,
        'Iceberg': PartI.icebergTextTheme,
        'Iceland': PartI.icelandTextTheme,
        'Imbue': PartI.imbueTextTheme,
        'Imperial Script': PartI.imperialScriptTextTheme,
        'Imprima': PartI.imprimaTextTheme,
        'Inclusive Sans': PartI.inclusiveSansTextTheme,
        'Inconsolata': PartI.inconsolataTextTheme,
        'Inder': PartI.inderTextTheme,
        'Indie Flower': PartI.indieFlowerTextTheme,
        'Ingrid Darling': PartI.ingridDarlingTextTheme,
        'Inika': PartI.inikaTextTheme,
        'Inknut Antiqua': PartI.inknutAntiquaTextTheme,
        'Inria Sans': PartI.inriaSansTextTheme,
        'Inria Serif': PartI.inriaSerifTextTheme,
        'Inspiration': PartI.inspirationTextTheme,
        'Instrument Sans': PartI.instrumentSansTextTheme,
        'Instrument Serif': PartI.instrumentSerifTextTheme,
        'Inter': PartI.interTextTheme,
        'Inter Tight': PartI.interTightTextTheme,
        'Irish Grover': PartI.irishGroverTextTheme,
        'Island Moments': PartI.islandMomentsTextTheme,
        'Istok Web': PartI.istokWebTextTheme,
        'Italiana': PartI.italianaTextTheme,
        'Italianno': PartI.italiannoTextTheme,
        'Itim': PartI.itimTextTheme,
        'Jacquard 12': PartJ.jacquard12TextTheme,
        'Jacquard 12 Charted': PartJ.jacquard12ChartedTextTheme,
        'Jacquard 24': PartJ.jacquard24TextTheme,
        'Jacquard 24 Charted': PartJ.jacquard24ChartedTextTheme,
        'Jacquarda Bastarda 9': PartJ.jacquardaBastarda9TextTheme,
        'Jacquarda Bastarda 9 Charted':
            PartJ.jacquardaBastarda9ChartedTextTheme,
        'Jacques Francois': PartJ.jacquesFrancoisTextTheme,
        'Jacques Francois Shadow': PartJ.jacquesFrancoisShadowTextTheme,
        'Jaini': PartJ.jainiTextTheme,
        'Jaini Purva': PartJ.jainiPurvaTextTheme,
        'Jaldi': PartJ.jaldiTextTheme,
        'Jaro': PartJ.jaroTextTheme,
        'Jersey 10': PartJ.jersey10TextTheme,
        'Jersey 10 Charted': PartJ.jersey10ChartedTextTheme,
        'Jersey 15': PartJ.jersey15TextTheme,
        'Jersey 15 Charted': PartJ.jersey15ChartedTextTheme,
        'Jersey 20': PartJ.jersey20TextTheme,
        'Jersey 20 Charted': PartJ.jersey20ChartedTextTheme,
        'Jersey 25': PartJ.jersey25TextTheme,
        'Jersey 25 Charted': PartJ.jersey25ChartedTextTheme,
        'JetBrains Mono': PartJ.jetBrainsMonoTextTheme,
        'Jim Nightshade': PartJ.jimNightshadeTextTheme,
        'Joan': PartJ.joanTextTheme,
        'Jockey One': PartJ.jockeyOneTextTheme,
        'Jolly Lodger': PartJ.jollyLodgerTextTheme,
        'Jomhuria': PartJ.jomhuriaTextTheme,
        'Jomolhari': PartJ.jomolhariTextTheme,
        'Josefin Sans': PartJ.josefinSansTextTheme,
        'Josefin Slab': PartJ.josefinSlabTextTheme,
        'Jost': PartJ.jostTextTheme,
        'Joti One': PartJ.jotiOneTextTheme,
        'Jua': PartJ.juaTextTheme,
        'Judson': PartJ.judsonTextTheme,
        'Julee': PartJ.juleeTextTheme,
        'Julius Sans One': PartJ.juliusSansOneTextTheme,
        'Junge': PartJ.jungeTextTheme,
        'Jura': PartJ.juraTextTheme,
        'Just Another Hand': PartJ.justAnotherHandTextTheme,
        'Just Me Again Down Here': PartJ.justMeAgainDownHereTextTheme,
        'K2D': PartK.k2dTextTheme,
        'Kablammo': PartK.kablammoTextTheme,
        'Kadwa': PartK.kadwaTextTheme,
        'Kaisei Decol': PartK.kaiseiDecolTextTheme,
        'Kaisei HarunoUmi': PartK.kaiseiHarunoUmiTextTheme,
        'Kaisei Opti': PartK.kaiseiOptiTextTheme,
        'Kaisei Tokumin': PartK.kaiseiTokuminTextTheme,
        'Kalam': PartK.kalamTextTheme,
        'Kalnia': PartK.kalniaTextTheme,
        'Kalnia Glaze': PartK.kalniaGlazeTextTheme,
        'Kameron': PartK.kameronTextTheme,
        'Kanit': PartK.kanitTextTheme,
        'Kantumruy Pro': PartK.kantumruyProTextTheme,
        'Karantina': PartK.karantinaTextTheme,
        'Karla': PartK.karlaTextTheme,
        'Karma': PartK.karmaTextTheme,
        'Katibeh': PartK.katibehTextTheme,
        'Kaushan Script': PartK.kaushanScriptTextTheme,
        'Kavivanar': PartK.kavivanarTextTheme,
        'Kavoon': PartK.kavoonTextTheme,
        'Kay Pho Du': PartK.kayPhoDuTextTheme,
        'Kdam Thmor Pro': PartK.kdamThmorProTextTheme,
        'Keania One': PartK.keaniaOneTextTheme,
        'Kelly Slab': PartK.kellySlabTextTheme,
        'Kenia': PartK.keniaTextTheme,
        'Khand': PartK.khandTextTheme,
        'Khmer': PartK.khmerTextTheme,
        'Khula': PartK.khulaTextTheme,
        'Kings': PartK.kingsTextTheme,
        'Kirang Haerang': PartK.kirangHaerangTextTheme,
        'Kite One': PartK.kiteOneTextTheme,
        'Kiwi Maru': PartK.kiwiMaruTextTheme,
        'Klee One': PartK.kleeOneTextTheme,
        'Knewave': PartK.knewaveTextTheme,
        'KoHo': PartK.koHoTextTheme,
        'Kodchasan': PartK.kodchasanTextTheme,
        'Kode Mono': PartK.kodeMonoTextTheme,
        'Koh Santepheap': PartK.kohSantepheapTextTheme,
        'Kolker Brush': PartK.kolkerBrushTextTheme,
        'Konkhmer Sleokchher': PartK.konkhmerSleokchherTextTheme,
        'Kosugi': PartK.kosugiTextTheme,
        'Kosugi Maru': PartK.kosugiMaruTextTheme,
        'Kotta One': PartK.kottaOneTextTheme,
        'Koulen': PartK.koulenTextTheme,
        'Kranky': PartK.krankyTextTheme,
        'Kreon': PartK.kreonTextTheme,
        'Kristi': PartK.kristiTextTheme,
        'Krona One': PartK.kronaOneTextTheme,
        'Krub': PartK.krubTextTheme,
        'Kufam': PartK.kufamTextTheme,
        'Kulim Park': PartK.kulimParkTextTheme,
        'Kumar One': PartK.kumarOneTextTheme,
        'Kumar One Outline': PartK.kumarOneOutlineTextTheme,
        'Kumbh Sans': PartK.kumbhSansTextTheme,
        'Kurale': PartK.kuraleTextTheme,
        'LXGW WenKai Mono TC': PartL.lxgwWenKaiMonoTcTextTheme,
        'LXGW WenKai TC': PartL.lxgwWenKaiTcTextTheme,
        'La Belle Aurore': PartL.laBelleAuroreTextTheme,
        'Labrada': PartL.labradaTextTheme,
        'Lacquer': PartL.lacquerTextTheme,
        'Laila': PartL.lailaTextTheme,
        'Lakki Reddy': PartL.lakkiReddyTextTheme,
        'Lalezar': PartL.lalezarTextTheme,
        'Lancelot': PartL.lancelotTextTheme,
        'Langar': PartL.langarTextTheme,
        'Lateef': PartL.lateefTextTheme,
        'Lato': PartL.latoTextTheme,
        'Lavishly Yours': PartL.lavishlyYoursTextTheme,
        'League Gothic': PartL.leagueGothicTextTheme,
        'League Script': PartL.leagueScriptTextTheme,
        'League Spartan': PartL.leagueSpartanTextTheme,
        'Leckerli One': PartL.leckerliOneTextTheme,
        'Ledger': PartL.ledgerTextTheme,
        'Lekton': PartL.lektonTextTheme,
        'Lemon': PartL.lemonTextTheme,
        'Lemonada': PartL.lemonadaTextTheme,
        'Lexend': PartL.lexendTextTheme,
        'Lexend Deca': PartL.lexendDecaTextTheme,
        'Lexend Exa': PartL.lexendExaTextTheme,
        'Lexend Giga': PartL.lexendGigaTextTheme,
        'Lexend Mega': PartL.lexendMegaTextTheme,
        'Lexend Peta': PartL.lexendPetaTextTheme,
        'Lexend Tera': PartL.lexendTeraTextTheme,
        'Lexend Zetta': PartL.lexendZettaTextTheme,
        'Libre Barcode 128': PartL.libreBarcode128TextTheme,
        'Libre Barcode 128 Text': PartL.libreBarcode128TextTextTheme,
        'Libre Barcode 39': PartL.libreBarcode39TextTheme,
        'Libre Barcode 39 Extended': PartL.libreBarcode39ExtendedTextTheme,
        'Libre Barcode 39 Extended Text':
            PartL.libreBarcode39ExtendedTextTextTheme,
        'Libre Barcode 39 Text': PartL.libreBarcode39TextTextTheme,
        'Libre Barcode EAN13 Text': PartL.libreBarcodeEan13TextTextTheme,
        'Libre Baskerville': PartL.libreBaskervilleTextTheme,
        'Libre Bodoni': PartL.libreBodoniTextTheme,
        'Libre Caslon Display': PartL.libreCaslonDisplayTextTheme,
        'Libre Caslon Text': PartL.libreCaslonTextTextTheme,
        'Libre Franklin': PartL.libreFranklinTextTheme,
        'Licorice': PartL.licoriceTextTheme,
        'Life Savers': PartL.lifeSaversTextTheme,
        'Lilita One': PartL.lilitaOneTextTheme,
        'Lily Script One': PartL.lilyScriptOneTextTheme,
        'Limelight': PartL.limelightTextTheme,
        'Linden Hill': PartL.lindenHillTextTheme,
        'Linefont': PartL.linefontTextTheme,
        'Lisu Bosa': PartL.lisuBosaTextTheme,
        'Literata': PartL.literataTextTheme,
        'Liu Jian Mao Cao': PartL.liuJianMaoCaoTextTheme,
        'Livvic': PartL.livvicTextTheme,
        'Lobster': PartL.lobsterTextTheme,
        'Lobster Two': PartL.lobsterTwoTextTheme,
        'Londrina Outline': PartL.londrinaOutlineTextTheme,
        'Londrina Shadow': PartL.londrinaShadowTextTheme,
        'Londrina Sketch': PartL.londrinaSketchTextTheme,
        'Londrina Solid': PartL.londrinaSolidTextTheme,
        'Long Cang': PartL.longCangTextTheme,
        'Lora': PartL.loraTextTheme,
        'Love Light': PartL.loveLightTextTheme,
        'Love Ya Like A Sister': PartL.loveYaLikeASisterTextTheme,
        'Loved by the King': PartL.lovedByTheKingTextTheme,
        'Lovers Quarrel': PartL.loversQuarrelTextTheme,
        'Luckiest Guy': PartL.luckiestGuyTextTheme,
        'Lugrasimo': PartL.lugrasimoTextTheme,
        'Lumanosimo': PartL.lumanosimoTextTheme,
        'Lunasima': PartL.lunasimaTextTheme,
        'Lusitana': PartL.lusitanaTextTheme,
        'Lustria': PartL.lustriaTextTheme,
        'Luxurious Roman': PartL.luxuriousRomanTextTheme,
        'Luxurious Script': PartL.luxuriousScriptTextTheme,
        'M PLUS 1': PartM.mPlus1TextTheme,
        'M PLUS 1 Code': PartM.mPlus1CodeTextTheme,
        'M PLUS 1p': PartM.mPlus1pTextTheme,
        'M PLUS 2': PartM.mPlus2TextTheme,
        'M PLUS Code Latin': PartM.mPlusCodeLatinTextTheme,
        'M PLUS Rounded 1c': PartM.mPlusRounded1cTextTheme,
        'Ma Shan Zheng': PartM.maShanZhengTextTheme,
        'Macondo': PartM.macondoTextTheme,
        'Macondo Swash Caps': PartM.macondoSwashCapsTextTheme,
        'Mada': PartM.madaTextTheme,
        'Madimi One': PartM.madimiOneTextTheme,
        'Magra': PartM.magraTextTheme,
        'Maiden Orange': PartM.maidenOrangeTextTheme,
        'Maitree': PartM.maitreeTextTheme,
        'Major Mono Display': PartM.majorMonoDisplayTextTheme,
        'Mako': PartM.makoTextTheme,
        'Mali': PartM.maliTextTheme,
        'Mallanna': PartM.mallannaTextTheme,
        'Maname': PartM.manameTextTheme,
        'Mandali': PartM.mandaliTextTheme,
        'Manjari': PartM.manjariTextTheme,
        'Manrope': PartM.manropeTextTheme,
        'Mansalva': PartM.mansalvaTextTheme,
        'Manuale': PartM.manualeTextTheme,
        'Marcellus': PartM.marcellusTextTheme,
        'Marcellus SC': PartM.marcellusScTextTheme,
        'Marck Script': PartM.marckScriptTextTheme,
        'Margarine': PartM.margarineTextTheme,
        'Marhey': PartM.marheyTextTheme,
        'Markazi Text': PartM.markaziTextTextTheme,
        'Marko One': PartM.markoOneTextTheme,
        'Marmelad': PartM.marmeladTextTheme,
        'Martel': PartM.martelTextTheme,
        'Martel Sans': PartM.martelSansTextTheme,
        'Martian Mono': PartM.martianMonoTextTheme,
        'Marvel': PartM.marvelTextTheme,
        'Mate': PartM.mateTextTheme,
        'Mate SC': PartM.mateScTextTheme,
        'Maven Pro': PartM.mavenProTextTheme,
        'McLaren': PartM.mcLarenTextTheme,
        'Mea Culpa': PartM.meaCulpaTextTheme,
        'Meddon': PartM.meddonTextTheme,
        'MedievalSharp': PartM.medievalSharpTextTheme,
        'Medula One': PartM.medulaOneTextTheme,
        'Meera Inimai': PartM.meeraInimaiTextTheme,
        'Megrim': PartM.megrimTextTheme,
        'Meie Script': PartM.meieScriptTextTheme,
        'Meow Script': PartM.meowScriptTextTheme,
        'Merienda': PartM.meriendaTextTheme,
        'Merriweather': PartM.merriweatherTextTheme,
        'Merriweather Sans': PartM.merriweatherSansTextTheme,
        'Metal': PartM.metalTextTheme,
        'Metal Mania': PartM.metalManiaTextTheme,
        'Metamorphous': PartM.metamorphousTextTheme,
        'Metrophobic': PartM.metrophobicTextTheme,
        'Michroma': PartM.michromaTextTheme,
        'Micro 5': PartM.micro5TextTheme,
        'Micro 5 Charted': PartM.micro5ChartedTextTheme,
        'Milonga': PartM.milongaTextTheme,
        'Miltonian': PartM.miltonianTextTheme,
        'Miltonian Tattoo': PartM.miltonianTattooTextTheme,
        'Mina': PartM.minaTextTheme,
        'Mingzat': PartM.mingzatTextTheme,
        'Miniver': PartM.miniverTextTheme,
        'Miriam Libre': PartM.miriamLibreTextTheme,
        'Mirza': PartM.mirzaTextTheme,
        'Miss Fajardose': PartM.missFajardoseTextTheme,
        'Mitr': PartM.mitrTextTheme,
        'Mochiy Pop One': PartM.mochiyPopOneTextTheme,
        'Mochiy Pop P One': PartM.mochiyPopPOneTextTheme,
        'Modak': PartM.modakTextTheme,
        'Modern Antiqua': PartM.modernAntiquaTextTheme,
        'Mogra': PartM.mograTextTheme,
        'Mohave': PartM.mohaveTextTheme,
        'Moirai One': PartM.moiraiOneTextTheme,
        'Molengo': PartM.molengoTextTheme,
        'Molle': PartM.molleTextTheme,
        'Monda': PartM.mondaTextTheme,
        'Monofett': PartM.monofettTextTheme,
        'Monomaniac One': PartM.monomaniacOneTextTheme,
        'Monoton': PartM.monotonTextTheme,
        'Monsieur La Doulaise': PartM.monsieurLaDoulaiseTextTheme,
        'Montaga': PartM.montagaTextTheme,
        'Montagu Slab': PartM.montaguSlabTextTheme,
        'MonteCarlo': PartM.monteCarloTextTheme,
        'Montez': PartM.montezTextTheme,
        'Montserrat': PartM.montserratTextTheme,
        'Montserrat Alternates': PartM.montserratAlternatesTextTheme,
        'Montserrat Subrayada': PartM.montserratSubrayadaTextTheme,
        'Moo Lah Lah': PartM.mooLahLahTextTheme,
        'Mooli': PartM.mooliTextTheme,
        'Moon Dance': PartM.moonDanceTextTheme,
        'Moul': PartM.moulTextTheme,
        'Moulpali': PartM.moulpaliTextTheme,
        'Mountains of Christmas': PartM.mountainsOfChristmasTextTheme,
        'Mouse Memoirs': PartM.mouseMemoirsTextTheme,
        'Mr Bedfort': PartM.mrBedfortTextTheme,
        'Mr Dafoe': PartM.mrDafoeTextTheme,
        'Mr De Haviland': PartM.mrDeHavilandTextTheme,
        'Mrs Saint Delafield': PartM.mrsSaintDelafieldTextTheme,
        'Mrs Sheppards': PartM.mrsSheppardsTextTheme,
        'Ms Madi': PartM.msMadiTextTheme,
        'Mukta': PartM.muktaTextTheme,
        'Mukta Mahee': PartM.muktaMaheeTextTheme,
        'Mukta Malar': PartM.muktaMalarTextTheme,
        'Mukta Vaani': PartM.muktaVaaniTextTheme,
        'Mulish': PartM.mulishTextTheme,
        'Murecho': PartM.murechoTextTheme,
        'MuseoModerno': PartM.museoModernoTextTheme,
        'My Soul': PartM.mySoulTextTheme,
        'Mynerve': PartM.mynerveTextTheme,
        'Mystery Quest': PartM.mysteryQuestTextTheme,
        'NTR': PartN.ntrTextTheme,
        'Nabla': PartN.nablaTextTheme,
        'Namdhinggo': PartN.namdhinggoTextTheme,
        'Nanum Brush Script': PartN.nanumBrushScriptTextTheme,
        'Nanum Gothic': PartN.nanumGothicTextTheme,
        'Nanum Gothic Coding': PartN.nanumGothicCodingTextTheme,
        'Nanum Myeongjo': PartN.nanumMyeongjoTextTheme,
        'Nanum Pen Script': PartN.nanumPenScriptTextTheme,
        'Narnoor': PartN.narnoorTextTheme,
        'Neonderthaw': PartN.neonderthawTextTheme,
        'Nerko One': PartN.nerkoOneTextTheme,
        'Neucha': PartN.neuchaTextTheme,
        'Neuton': PartN.neutonTextTheme,
        'New Rocker': PartN.newRockerTextTheme,
        'New Tegomin': PartN.newTegominTextTheme,
        'News Cycle': PartN.newsCycleTextTheme,
        'Newsreader': PartN.newsreaderTextTheme,
        'Niconne': PartN.niconneTextTheme,
        'Niramit': PartN.niramitTextTheme,
        'Nixie One': PartN.nixieOneTextTheme,
        'Nobile': PartN.nobileTextTheme,
        'Nokora': PartN.nokoraTextTheme,
        'Norican': PartN.noricanTextTheme,
        'Nosifer': PartN.nosiferTextTheme,
        'Notable': PartN.notableTextTheme,
        'Nothing You Could Do': PartN.nothingYouCouldDoTextTheme,
        'Noticia Text': PartN.noticiaTextTextTheme,
        'Noto Color Emoji': PartN.notoColorEmojiTextTheme,
        'Noto Emoji': PartN.notoEmojiTextTheme,
        'Noto Kufi Arabic': PartN.notoKufiArabicTextTheme,
        'Noto Music': PartN.notoMusicTextTheme,
        'Noto Naskh Arabic': PartN.notoNaskhArabicTextTheme,
        'Noto Nastaliq Urdu': PartN.notoNastaliqUrduTextTheme,
        'Noto Rashi Hebrew': PartN.notoRashiHebrewTextTheme,
        'Noto Sans': PartN.notoSansTextTheme,
        'Noto Sans Adlam': PartN.notoSansAdlamTextTheme,
        'Noto Sans Adlam Unjoined': PartN.notoSansAdlamUnjoinedTextTheme,
        'Noto Sans Anatolian Hieroglyphs':
            PartN.notoSansAnatolianHieroglyphsTextTheme,
        'Noto Sans Arabic': PartN.notoSansArabicTextTheme,
        'Noto Sans Armenian': PartN.notoSansArmenianTextTheme,
        'Noto Sans Avestan': PartN.notoSansAvestanTextTheme,
        'Noto Sans Balinese': PartN.notoSansBalineseTextTheme,
        'Noto Sans Bamum': PartN.notoSansBamumTextTheme,
        'Noto Sans Bassa Vah': PartN.notoSansBassaVahTextTheme,
        'Noto Sans Batak': PartN.notoSansBatakTextTheme,
        'Noto Sans Bengali': PartN.notoSansBengaliTextTheme,
        'Noto Sans Bhaiksuki': PartN.notoSansBhaiksukiTextTheme,
        'Noto Sans Brahmi': PartN.notoSansBrahmiTextTheme,
        'Noto Sans Buginese': PartN.notoSansBugineseTextTheme,
        'Noto Sans Buhid': PartN.notoSansBuhidTextTheme,
        'Noto Sans Canadian Aboriginal':
            PartN.notoSansCanadianAboriginalTextTheme,
        'Noto Sans Carian': PartN.notoSansCarianTextTheme,
        'Noto Sans Caucasian Albanian':
            PartN.notoSansCaucasianAlbanianTextTheme,
        'Noto Sans Chakma': PartN.notoSansChakmaTextTheme,
        'Noto Sans Cham': PartN.notoSansChamTextTheme,
        'Noto Sans Cherokee': PartN.notoSansCherokeeTextTheme,
        'Noto Sans Chorasmian': PartN.notoSansChorasmianTextTheme,
        'Noto Sans Coptic': PartN.notoSansCopticTextTheme,
        'Noto Sans Cuneiform': PartN.notoSansCuneiformTextTheme,
        'Noto Sans Cypriot': PartN.notoSansCypriotTextTheme,
        'Noto Sans Cypro Minoan': PartN.notoSansCyproMinoanTextTheme,
        'Noto Sans Deseret': PartN.notoSansDeseretTextTheme,
        'Noto Sans Devanagari': PartN.notoSansDevanagariTextTheme,
        'Noto Sans Display': PartN.notoSansDisplayTextTheme,
        'Noto Sans Duployan': PartN.notoSansDuployanTextTheme,
        'Noto Sans Egyptian Hieroglyphs':
            PartN.notoSansEgyptianHieroglyphsTextTheme,
        'Noto Sans Elbasan': PartN.notoSansElbasanTextTheme,
        'Noto Sans Elymaic': PartN.notoSansElymaicTextTheme,
        'Noto Sans Ethiopic': PartN.notoSansEthiopicTextTheme,
        'Noto Sans Georgian': PartN.notoSansGeorgianTextTheme,
        'Noto Sans Glagolitic': PartN.notoSansGlagoliticTextTheme,
        'Noto Sans Gothic': PartN.notoSansGothicTextTheme,
        'Noto Sans Grantha': PartN.notoSansGranthaTextTheme,
        'Noto Sans Gujarati': PartN.notoSansGujaratiTextTheme,
        'Noto Sans Gunjala Gondi': PartN.notoSansGunjalaGondiTextTheme,
        'Noto Sans Gurmukhi': PartN.notoSansGurmukhiTextTheme,
        'Noto Sans HK': PartN.notoSansHkTextTheme,
        'Noto Sans Hanifi Rohingya': PartN.notoSansHanifiRohingyaTextTheme,
        'Noto Sans Hanunoo': PartN.notoSansHanunooTextTheme,
        'Noto Sans Hatran': PartN.notoSansHatranTextTheme,
        'Noto Sans Hebrew': PartN.notoSansHebrewTextTheme,
        'Noto Sans Imperial Aramaic': PartN.notoSansImperialAramaicTextTheme,
        'Noto Sans Indic Siyaq Numbers':
            PartN.notoSansIndicSiyaqNumbersTextTheme,
        'Noto Sans Inscriptional Pahlavi':
            PartN.notoSansInscriptionalPahlaviTextTheme,
        'Noto Sans Inscriptional Parthian':
            PartN.notoSansInscriptionalParthianTextTheme,
        'Noto Sans JP': PartN.notoSansJpTextTheme,
        'Noto Sans Javanese': PartN.notoSansJavaneseTextTheme,
        'Noto Sans KR': PartN.notoSansKrTextTheme,
        'Noto Sans Kaithi': PartN.notoSansKaithiTextTheme,
        'Noto Sans Kannada': PartN.notoSansKannadaTextTheme,
        'Noto Sans Kawi': PartN.notoSansKawiTextTheme,
        'Noto Sans Kayah Li': PartN.notoSansKayahLiTextTheme,
        'Noto Sans Kharoshthi': PartN.notoSansKharoshthiTextTheme,
        'Noto Sans Khmer': PartN.notoSansKhmerTextTheme,
        'Noto Sans Khojki': PartN.notoSansKhojkiTextTheme,
        'Noto Sans Khudawadi': PartN.notoSansKhudawadiTextTheme,
        'Noto Sans Lao': PartN.notoSansLaoTextTheme,
        'Noto Sans Lao Looped': PartN.notoSansLaoLoopedTextTheme,
        'Noto Sans Lepcha': PartN.notoSansLepchaTextTheme,
        'Noto Sans Limbu': PartN.notoSansLimbuTextTheme,
        'Noto Sans Linear A': PartN.notoSansLinearATextTheme,
        'Noto Sans Linear B': PartN.notoSansLinearBTextTheme,
        'Noto Sans Lisu': PartN.notoSansLisuTextTheme,
        'Noto Sans Lycian': PartN.notoSansLycianTextTheme,
        'Noto Sans Lydian': PartN.notoSansLydianTextTheme,
        'Noto Sans Mahajani': PartN.notoSansMahajaniTextTheme,
        'Noto Sans Malayalam': PartN.notoSansMalayalamTextTheme,
        'Noto Sans Mandaic': PartN.notoSansMandaicTextTheme,
        'Noto Sans Manichaean': PartN.notoSansManichaeanTextTheme,
        'Noto Sans Marchen': PartN.notoSansMarchenTextTheme,
        'Noto Sans Masaram Gondi': PartN.notoSansMasaramGondiTextTheme,
        'Noto Sans Math': PartN.notoSansMathTextTheme,
        'Noto Sans Mayan Numerals': PartN.notoSansMayanNumeralsTextTheme,
        'Noto Sans Medefaidrin': PartN.notoSansMedefaidrinTextTheme,
        'Noto Sans Meetei Mayek': PartN.notoSansMeeteiMayekTextTheme,
        'Noto Sans Mende Kikakui': PartN.notoSansMendeKikakuiTextTheme,
        'Noto Sans Meroitic': PartN.notoSansMeroiticTextTheme,
        'Noto Sans Miao': PartN.notoSansMiaoTextTheme,
        'Noto Sans Modi': PartN.notoSansModiTextTheme,
        'Noto Sans Mongolian': PartN.notoSansMongolianTextTheme,
        'Noto Sans Mono': PartN.notoSansMonoTextTheme,
        'Noto Sans Mro': PartN.notoSansMroTextTheme,
        'Noto Sans Multani': PartN.notoSansMultaniTextTheme,
        'Noto Sans Myanmar': PartN.notoSansMyanmarTextTheme,
        'Noto Sans NKo': PartN.notoSansNKoTextTheme,
        'Noto Sans NKo Unjoined': PartN.notoSansNKoUnjoinedTextTheme,
        'Noto Sans Nabataean': PartN.notoSansNabataeanTextTheme,
        'Noto Sans Nag Mundari': PartN.notoSansNagMundariTextTheme,
        'Noto Sans Nandinagari': PartN.notoSansNandinagariTextTheme,
        'Noto Sans New Tai Lue': PartN.notoSansNewTaiLueTextTheme,
        'Noto Sans Newa': PartN.notoSansNewaTextTheme,
        'Noto Sans Nushu': PartN.notoSansNushuTextTheme,
        'Noto Sans Ogham': PartN.notoSansOghamTextTheme,
        'Noto Sans Ol Chiki': PartN.notoSansOlChikiTextTheme,
        'Noto Sans Old Hungarian': PartN.notoSansOldHungarianTextTheme,
        'Noto Sans Old Italic': PartN.notoSansOldItalicTextTheme,
        'Noto Sans Old North Arabian': PartN.notoSansOldNorthArabianTextTheme,
        'Noto Sans Old Permic': PartN.notoSansOldPermicTextTheme,
        'Noto Sans Old Persian': PartN.notoSansOldPersianTextTheme,
        'Noto Sans Old Sogdian': PartN.notoSansOldSogdianTextTheme,
        'Noto Sans Old South Arabian': PartN.notoSansOldSouthArabianTextTheme,
        'Noto Sans Old Turkic': PartN.notoSansOldTurkicTextTheme,
        'Noto Sans Oriya': PartN.notoSansOriyaTextTheme,
        'Noto Sans Osage': PartN.notoSansOsageTextTheme,
        'Noto Sans Osmanya': PartN.notoSansOsmanyaTextTheme,
        'Noto Sans Pahawh Hmong': PartN.notoSansPahawhHmongTextTheme,
        'Noto Sans Palmyrene': PartN.notoSansPalmyreneTextTheme,
        'Noto Sans Pau Cin Hau': PartN.notoSansPauCinHauTextTheme,
        'Noto Sans Phags Pa': PartN.notoSansPhagsPaTextTheme,
        'Noto Sans Phoenician': PartN.notoSansPhoenicianTextTheme,
        'Noto Sans Psalter Pahlavi': PartN.notoSansPsalterPahlaviTextTheme,
        'Noto Sans Rejang': PartN.notoSansRejangTextTheme,
        'Noto Sans Runic': PartN.notoSansRunicTextTheme,
        'Noto Sans SC': PartN.notoSansScTextTheme,
        'Noto Sans Samaritan': PartN.notoSansSamaritanTextTheme,
        'Noto Sans Saurashtra': PartN.notoSansSaurashtraTextTheme,
        'Noto Sans Sharada': PartN.notoSansSharadaTextTheme,
        'Noto Sans Shavian': PartN.notoSansShavianTextTheme,
        'Noto Sans Siddham': PartN.notoSansSiddhamTextTheme,
        'Noto Sans SignWriting': PartN.notoSansSignWritingTextTheme,
        'Noto Sans Sinhala': PartN.notoSansSinhalaTextTheme,
        'Noto Sans Sogdian': PartN.notoSansSogdianTextTheme,
        'Noto Sans Sora Sompeng': PartN.notoSansSoraSompengTextTheme,
        'Noto Sans Soyombo': PartN.notoSansSoyomboTextTheme,
        'Noto Sans Sundanese': PartN.notoSansSundaneseTextTheme,
        'Noto Sans Syloti Nagri': PartN.notoSansSylotiNagriTextTheme,
        'Noto Sans Symbols': PartN.notoSansSymbolsTextTheme,
        'Noto Sans Symbols 2': PartN.notoSansSymbols2TextTheme,
        'Noto Sans Syriac': PartN.notoSansSyriacTextTheme,
        'Noto Sans Syriac Eastern': PartN.notoSansSyriacEasternTextTheme,
        'Noto Sans TC': PartN.notoSansTcTextTheme,
        'Noto Sans Tagalog': PartN.notoSansTagalogTextTheme,
        'Noto Sans Tagbanwa': PartN.notoSansTagbanwaTextTheme,
        'Noto Sans Tai Le': PartN.notoSansTaiLeTextTheme,
        'Noto Sans Tai Tham': PartN.notoSansTaiThamTextTheme,
        'Noto Sans Tai Viet': PartN.notoSansTaiVietTextTheme,
        'Noto Sans Takri': PartN.notoSansTakriTextTheme,
        'Noto Sans Tamil': PartN.notoSansTamilTextTheme,
        'Noto Sans Tamil Supplement': PartN.notoSansTamilSupplementTextTheme,
        'Noto Sans Tangsa': PartN.notoSansTangsaTextTheme,
        'Noto Sans Telugu': PartN.notoSansTeluguTextTheme,
        'Noto Sans Thaana': PartN.notoSansThaanaTextTheme,
        'Noto Sans Thai': PartN.notoSansThaiTextTheme,
        'Noto Sans Thai Looped': PartN.notoSansThaiLoopedTextTheme,
        'Noto Sans Tifinagh': PartN.notoSansTifinaghTextTheme,
        'Noto Sans Tirhuta': PartN.notoSansTirhutaTextTheme,
        'Noto Sans Ugaritic': PartN.notoSansUgariticTextTheme,
        'Noto Sans Vai': PartN.notoSansVaiTextTheme,
        'Noto Sans Vithkuqi': PartN.notoSansVithkuqiTextTheme,
        'Noto Sans Wancho': PartN.notoSansWanchoTextTheme,
        'Noto Sans Warang Citi': PartN.notoSansWarangCitiTextTheme,
        'Noto Sans Yi': PartN.notoSansYiTextTheme,
        'Noto Sans Zanabazar Square': PartN.notoSansZanabazarSquareTextTheme,
        'Noto Serif': PartN.notoSerifTextTheme,
        'Noto Serif Ahom': PartN.notoSerifAhomTextTheme,
        'Noto Serif Armenian': PartN.notoSerifArmenianTextTheme,
        'Noto Serif Balinese': PartN.notoSerifBalineseTextTheme,
        'Noto Serif Bengali': PartN.notoSerifBengaliTextTheme,
        'Noto Serif Devanagari': PartN.notoSerifDevanagariTextTheme,
        'Noto Serif Display': PartN.notoSerifDisplayTextTheme,
        'Noto Serif Dogra': PartN.notoSerifDograTextTheme,
        'Noto Serif Ethiopic': PartN.notoSerifEthiopicTextTheme,
        'Noto Serif Georgian': PartN.notoSerifGeorgianTextTheme,
        'Noto Serif Grantha': PartN.notoSerifGranthaTextTheme,
        'Noto Serif Gujarati': PartN.notoSerifGujaratiTextTheme,
        'Noto Serif Gurmukhi': PartN.notoSerifGurmukhiTextTheme,
        'Noto Serif HK': PartN.notoSerifHkTextTheme,
        'Noto Serif Hebrew': PartN.notoSerifHebrewTextTheme,
        'Noto Serif JP': PartN.notoSerifJpTextTheme,
        'Noto Serif KR': PartN.notoSerifKrTextTheme,
        'Noto Serif Kannada': PartN.notoSerifKannadaTextTheme,
        'Noto Serif Khitan Small Script':
            PartN.notoSerifKhitanSmallScriptTextTheme,
        'Noto Serif Khmer': PartN.notoSerifKhmerTextTheme,
        'Noto Serif Khojki': PartN.notoSerifKhojkiTextTheme,
        'Noto Serif Lao': PartN.notoSerifLaoTextTheme,
        'Noto Serif Makasar': PartN.notoSerifMakasarTextTheme,
        'Noto Serif Malayalam': PartN.notoSerifMalayalamTextTheme,
        'Noto Serif Myanmar': PartN.notoSerifMyanmarTextTheme,
        'Noto Serif NP Hmong': PartN.notoSerifNpHmongTextTheme,
        'Noto Serif Old Uyghur': PartN.notoSerifOldUyghurTextTheme,
        'Noto Serif Oriya': PartN.notoSerifOriyaTextTheme,
        'Noto Serif Ottoman Siyaq': PartN.notoSerifOttomanSiyaqTextTheme,
        'Noto Serif SC': PartN.notoSerifScTextTheme,
        'Noto Serif Sinhala': PartN.notoSerifSinhalaTextTheme,
        'Noto Serif TC': PartN.notoSerifTcTextTheme,
        'Noto Serif Tamil': PartN.notoSerifTamilTextTheme,
        'Noto Serif Tangut': PartN.notoSerifTangutTextTheme,
        'Noto Serif Telugu': PartN.notoSerifTeluguTextTheme,
        'Noto Serif Thai': PartN.notoSerifThaiTextTheme,
        'Noto Serif Tibetan': PartN.notoSerifTibetanTextTheme,
        'Noto Serif Toto': PartN.notoSerifTotoTextTheme,
        'Noto Serif Vithkuqi': PartN.notoSerifVithkuqiTextTheme,
        'Noto Serif Yezidi': PartN.notoSerifYezidiTextTheme,
        'Noto Traditional Nushu': PartN.notoTraditionalNushuTextTheme,
        'Noto Znamenny Musical Notation':
            PartN.notoZnamennyMusicalNotationTextTheme,
        'Nova Cut': PartN.novaCutTextTheme,
        'Nova Flat': PartN.novaFlatTextTheme,
        'Nova Mono': PartN.novaMonoTextTheme,
        'Nova Oval': PartN.novaOvalTextTheme,
        'Nova Round': PartN.novaRoundTextTheme,
        'Nova Script': PartN.novaScriptTextTheme,
        'Nova Slim': PartN.novaSlimTextTheme,
        'Nova Square': PartN.novaSquareTextTheme,
        'Numans': PartN.numansTextTheme,
        'Nunito': PartN.nunitoTextTheme,
        'Nunito Sans': PartN.nunitoSansTextTheme,
        'Nuosu SIL': PartN.nuosuSilTextTheme,
        'Odibee Sans': PartO.odibeeSansTextTheme,
        'Odor Mean Chey': PartO.odorMeanCheyTextTheme,
        'Offside': PartO.offsideTextTheme,
        'Oi': PartO.oiTextTheme,
        'Ojuju': PartO.ojujuTextTheme,
        'Old Standard TT': PartO.oldStandardTtTextTheme,
        'Oldenburg': PartO.oldenburgTextTheme,
        'Ole': PartO.oleTextTheme,
        'Oleo Script': PartO.oleoScriptTextTheme,
        'Oleo Script Swash Caps': PartO.oleoScriptSwashCapsTextTheme,
        'Onest': PartO.onestTextTheme,
        'Oooh Baby': PartO.ooohBabyTextTheme,
        'Open Sans': PartO.openSansTextTheme,
        'Open Sans Condensed': PartO.openSansCondensedTextTheme,
        'Oranienbaum': PartO.oranienbaumTextTheme,
        'Orbit': PartO.orbitTextTheme,
        'Orbitron': PartO.orbitronTextTheme,
        'Oregano': PartO.oreganoTextTheme,
        'Orelega One': PartO.orelegaOneTextTheme,
        'Orienta': PartO.orientaTextTheme,
        'Original Surfer': PartO.originalSurferTextTheme,
        'Oswald': PartO.oswaldTextTheme,
        'Outfit': PartO.outfitTextTheme,
        'Over the Rainbow': PartO.overTheRainbowTextTheme,
        'Overlock': PartO.overlockTextTheme,
        'Overlock SC': PartO.overlockScTextTheme,
        'Overpass': PartO.overpassTextTheme,
        'Overpass Mono': PartO.overpassMonoTextTheme,
        'Ovo': PartO.ovoTextTheme,
        'Oxanium': PartO.oxaniumTextTheme,
        'Oxygen': PartO.oxygenTextTheme,
        'Oxygen Mono': PartO.oxygenMonoTextTheme,
        'PT Mono': PartP.ptMonoTextTheme,
        'PT Sans': PartP.ptSansTextTheme,
        'PT Sans Caption': PartP.ptSansCaptionTextTheme,
        'PT Sans Narrow': PartP.ptSansNarrowTextTheme,
        'PT Serif': PartP.ptSerifTextTheme,
        'PT Serif Caption': PartP.ptSerifCaptionTextTheme,
        'Pacifico': PartP.pacificoTextTheme,
        'Padauk': PartP.padaukTextTheme,
        'Padyakke Expanded One': PartP.padyakkeExpandedOneTextTheme,
        'Palanquin': PartP.palanquinTextTheme,
        'Palanquin Dark': PartP.palanquinDarkTextTheme,
        'Palette Mosaic': PartP.paletteMosaicTextTheme,
        'Pangolin': PartP.pangolinTextTheme,
        'Paprika': PartP.paprikaTextTheme,
        'Parisienne': PartP.parisienneTextTheme,
        'Passero One': PartP.passeroOneTextTheme,
        'Passion One': PartP.passionOneTextTheme,
        'Passions Conflict': PartP.passionsConflictTextTheme,
        'Pathway Extreme': PartP.pathwayExtremeTextTheme,
        'Pathway Gothic One': PartP.pathwayGothicOneTextTheme,
        'Patrick Hand': PartP.patrickHandTextTheme,
        'Patrick Hand SC': PartP.patrickHandScTextTheme,
        'Pattaya': PartP.pattayaTextTheme,
        'Patua One': PartP.patuaOneTextTheme,
        'Pavanam': PartP.pavanamTextTheme,
        'Paytone One': PartP.paytoneOneTextTheme,
        'Peddana': PartP.peddanaTextTheme,
        'Peralta': PartP.peraltaTextTheme,
        'Permanent Marker': PartP.permanentMarkerTextTheme,
        'Petemoss': PartP.petemossTextTheme,
        'Petit Formal Script': PartP.petitFormalScriptTextTheme,
        'Petrona': PartP.petronaTextTheme,
        'Philosopher': PartP.philosopherTextTheme,
        'Phudu': PartP.phuduTextTheme,
        'Piazzolla': PartP.piazzollaTextTheme,
        'Piedra': PartP.piedraTextTheme,
        'Pinyon Script': PartP.pinyonScriptTextTheme,
        'Pirata One': PartP.pirataOneTextTheme,
        'Pixelify Sans': PartP.pixelifySansTextTheme,
        'Plaster': PartP.plasterTextTheme,
        'Platypi': PartP.platypiTextTheme,
        'Play': PartP.playTextTheme,
        'Playball': PartP.playballTextTheme,
        'Playfair': PartP.playfairTextTheme,
        'Playfair Display': PartP.playfairDisplayTextTheme,
        'Playfair Display SC': PartP.playfairDisplayScTextTheme,
        'Playpen Sans': PartP.playpenSansTextTheme,
        'Playwrite AR': PartP.playwriteArTextTheme,
        'Playwrite AT': PartP.playwriteAtTextTheme,
        'Playwrite AU NSW': PartP.playwriteAuNswTextTheme,
        'Playwrite AU QLD': PartP.playwriteAuQldTextTheme,
        'Playwrite AU SA': PartP.playwriteAuSaTextTheme,
        'Playwrite AU TAS': PartP.playwriteAuTasTextTheme,
        'Playwrite AU VIC': PartP.playwriteAuVicTextTheme,
        'Playwrite BE VLG': PartP.playwriteBeVlgTextTheme,
        'Playwrite BE WAL': PartP.playwriteBeWalTextTheme,
        'Playwrite BR': PartP.playwriteBrTextTheme,
        'Playwrite CA': PartP.playwriteCaTextTheme,
        'Playwrite CL': PartP.playwriteClTextTheme,
        'Playwrite CO': PartP.playwriteCoTextTheme,
        'Playwrite CU': PartP.playwriteCuTextTheme,
        'Playwrite CZ': PartP.playwriteCzTextTheme,
        'Playwrite DE Grund': PartP.playwriteDeGrundTextTheme,
        'Playwrite DE LA': PartP.playwriteDeLaTextTheme,
        'Playwrite DE SAS': PartP.playwriteDeSasTextTheme,
        'Playwrite DE VA': PartP.playwriteDeVaTextTheme,
        'Playwrite DK Loopet': PartP.playwriteDkLoopetTextTheme,
        'Playwrite DK Uloopet': PartP.playwriteDkUloopetTextTheme,
        'Playwrite ES': PartP.playwriteEsTextTheme,
        'Playwrite ES Deco': PartP.playwriteEsDecoTextTheme,
        'Playwrite FR Moderne': PartP.playwriteFrModerneTextTheme,
        'Playwrite FR Trad': PartP.playwriteFrTradTextTheme,
        'Playwrite GB J': PartP.playwriteGbJTextTheme,
        'Playwrite GB S': PartP.playwriteGbSTextTheme,
        'Playwrite HR': PartP.playwriteHrTextTheme,
        'Playwrite HR Lijeva': PartP.playwriteHrLijevaTextTheme,
        'Playwrite HU': PartP.playwriteHuTextTheme,
        'Playwrite ID': PartP.playwriteIdTextTheme,
        'Playwrite IE': PartP.playwriteIeTextTheme,
        'Playwrite IN': PartP.playwriteInTextTheme,
        'Playwrite IS': PartP.playwriteIsTextTheme,
        'Playwrite IT Moderna': PartP.playwriteItModernaTextTheme,
        'Playwrite IT Trad': PartP.playwriteItTradTextTheme,
        'Playwrite MX': PartP.playwriteMxTextTheme,
        'Playwrite NG Modern': PartP.playwriteNgModernTextTheme,
        'Playwrite NL': PartP.playwriteNlTextTheme,
        'Playwrite NO': PartP.playwriteNoTextTheme,
        'Playwrite NZ': PartP.playwriteNzTextTheme,
        'Playwrite PE': PartP.playwritePeTextTheme,
        'Playwrite PL': PartP.playwritePlTextTheme,
        'Playwrite PT': PartP.playwritePtTextTheme,
        'Playwrite RO': PartP.playwriteRoTextTheme,
        'Playwrite SK': PartP.playwriteSkTextTheme,
        'Playwrite TZ': PartP.playwriteTzTextTheme,
        'Playwrite US Modern': PartP.playwriteUsModernTextTheme,
        'Playwrite US Trad': PartP.playwriteUsTradTextTheme,
        'Playwrite VN': PartP.playwriteVnTextTheme,
        'Playwrite ZA': PartP.playwriteZaTextTheme,
        'Plus Jakarta Sans': PartP.plusJakartaSansTextTheme,
        'Podkova': PartP.podkovaTextTheme,
        'Poetsen One': PartP.poetsenOneTextTheme,
        'Poiret One': PartP.poiretOneTextTheme,
        'Poller One': PartP.pollerOneTextTheme,
        'Poltawski Nowy': PartP.poltawskiNowyTextTheme,
        'Poly': PartP.polyTextTheme,
        'Pompiere': PartP.pompiereTextTheme,
        'Pontano Sans': PartP.pontanoSansTextTheme,
        'Poor Story': PartP.poorStoryTextTheme,
        'Poppins': PartP.poppinsTextTheme,
        'Port Lligat Sans': PartP.portLligatSansTextTheme,
        'Port Lligat Slab': PartP.portLligatSlabTextTheme,
        'Potta One': PartP.pottaOneTextTheme,
        'Pragati Narrow': PartP.pragatiNarrowTextTheme,
        'Praise': PartP.praiseTextTheme,
        'Prata': PartP.prataTextTheme,
        'Preahvihear': PartP.preahvihearTextTheme,
        'Press Start 2P': PartP.pressStart2pTextTheme,
        'Pridi': PartP.pridiTextTheme,
        'Princess Sofia': PartP.princessSofiaTextTheme,
        'Prociono': PartP.procionoTextTheme,
        'Prompt': PartP.promptTextTheme,
        'Prosto One': PartP.prostoOneTextTheme,
        'Protest Guerrilla': PartP.protestGuerrillaTextTheme,
        'Protest Revolution': PartP.protestRevolutionTextTheme,
        'Protest Riot': PartP.protestRiotTextTheme,
        'Protest Strike': PartP.protestStrikeTextTheme,
        'Proza Libre': PartP.prozaLibreTextTheme,
        'Public Sans': PartP.publicSansTextTheme,
        'Puppies Play': PartP.puppiesPlayTextTheme,
        'Puritan': PartP.puritanTextTheme,
        'Purple Purse': PartP.purplePurseTextTheme,
        'Qahiri': PartQ.qahiriTextTheme,
        'Quando': PartQ.quandoTextTheme,
        'Quantico': PartQ.quanticoTextTheme,
        'Quattrocento': PartQ.quattrocentoTextTheme,
        'Quattrocento Sans': PartQ.quattrocentoSansTextTheme,
        'Questrial': PartQ.questrialTextTheme,
        'Quicksand': PartQ.quicksandTextTheme,
        'Quintessential': PartQ.quintessentialTextTheme,
        'Qwigley': PartQ.qwigleyTextTheme,
        'Qwitcher Grypen': PartQ.qwitcherGrypenTextTheme,
        'REM': PartR.remTextTheme,
        'Racing Sans One': PartR.racingSansOneTextTheme,
        'Radio Canada': PartR.radioCanadaTextTheme,
        'Radio Canada Big': PartR.radioCanadaBigTextTheme,
        'Radley': PartR.radleyTextTheme,
        'Rajdhani': PartR.rajdhaniTextTheme,
        'Rakkas': PartR.rakkasTextTheme,
        'Raleway': PartR.ralewayTextTheme,
        'Raleway Dots': PartR.ralewayDotsTextTheme,
        'Ramabhadra': PartR.ramabhadraTextTheme,
        'Ramaraja': PartR.ramarajaTextTheme,
        'Rambla': PartR.ramblaTextTheme,
        'Rammetto One': PartR.rammettoOneTextTheme,
        'Rampart One': PartR.rampartOneTextTheme,
        'Ranchers': PartR.ranchersTextTheme,
        'Rancho': PartR.ranchoTextTheme,
        'Ranga': PartR.rangaTextTheme,
        'Rasa': PartR.rasaTextTheme,
        'Rationale': PartR.rationaleTextTheme,
        'Ravi Prakash': PartR.raviPrakashTextTheme,
        'Readex Pro': PartR.readexProTextTheme,
        'Recursive': PartR.recursiveTextTheme,
        'Red Hat Display': PartR.redHatDisplayTextTheme,
        'Red Hat Mono': PartR.redHatMonoTextTheme,
        'Red Hat Text': PartR.redHatTextTextTheme,
        'Red Rose': PartR.redRoseTextTheme,
        'Redacted': PartR.redactedTextTheme,
        'Redacted Script': PartR.redactedScriptTextTheme,
        'Reddit Mono': PartR.redditMonoTextTheme,
        'Reddit Sans': PartR.redditSansTextTheme,
        'Reddit Sans Condensed': PartR.redditSansCondensedTextTheme,
        'Redressed': PartR.redressedTextTheme,
        'Reem Kufi': PartR.reemKufiTextTheme,
        'Reem Kufi Fun': PartR.reemKufiFunTextTheme,
        'Reem Kufi Ink': PartR.reemKufiInkTextTheme,
        'Reenie Beanie': PartR.reenieBeanieTextTheme,
        'Reggae One': PartR.reggaeOneTextTheme,
        'Rethink Sans': PartR.rethinkSansTextTheme,
        'Revalia': PartR.revaliaTextTheme,
        'Rhodium Libre': PartR.rhodiumLibreTextTheme,
        'Ribeye': PartR.ribeyeTextTheme,
        'Ribeye Marrow': PartR.ribeyeMarrowTextTheme,
        'Righteous': PartR.righteousTextTheme,
        'Risque': PartR.risqueTextTheme,
        'Road Rage': PartR.roadRageTextTheme,
        'Roboto': PartR.robotoTextTheme,
        'Roboto Condensed': PartR.robotoCondensedTextTheme,
        'Roboto Flex': PartR.robotoFlexTextTheme,
        'Roboto Mono': PartR.robotoMonoTextTheme,
        'Roboto Serif': PartR.robotoSerifTextTheme,
        'Roboto Slab': PartR.robotoSlabTextTheme,
        'Rochester': PartR.rochesterTextTheme,
        'Rock 3D': PartR.rock3dTextTheme,
        'Rock Salt': PartR.rockSaltTextTheme,
        'RocknRoll One': PartR.rocknRollOneTextTheme,
        'Rokkitt': PartR.rokkittTextTheme,
        'Romanesco': PartR.romanescoTextTheme,
        'Ropa Sans': PartR.ropaSansTextTheme,
        'Rosario': PartR.rosarioTextTheme,
        'Rosarivo': PartR.rosarivoTextTheme,
        'Rouge Script': PartR.rougeScriptTextTheme,
        'Rowdies': PartR.rowdiesTextTheme,
        'Rozha One': PartR.rozhaOneTextTheme,
        'Rubik': PartR.rubikTextTheme,
        'Rubik 80s Fade': PartR.rubik80sFadeTextTheme,
        'Rubik Beastly': PartR.rubikBeastlyTextTheme,
        'Rubik Broken Fax': PartR.rubikBrokenFaxTextTheme,
        'Rubik Bubbles': PartR.rubikBubblesTextTheme,
        'Rubik Burned': PartR.rubikBurnedTextTheme,
        'Rubik Dirt': PartR.rubikDirtTextTheme,
        'Rubik Distressed': PartR.rubikDistressedTextTheme,
        'Rubik Doodle Shadow': PartR.rubikDoodleShadowTextTheme,
        'Rubik Doodle Triangles': PartR.rubikDoodleTrianglesTextTheme,
        'Rubik Gemstones': PartR.rubikGemstonesTextTheme,
        'Rubik Glitch': PartR.rubikGlitchTextTheme,
        'Rubik Glitch Pop': PartR.rubikGlitchPopTextTheme,
        'Rubik Iso': PartR.rubikIsoTextTheme,
        'Rubik Lines': PartR.rubikLinesTextTheme,
        'Rubik Maps': PartR.rubikMapsTextTheme,
        'Rubik Marker Hatch': PartR.rubikMarkerHatchTextTheme,
        'Rubik Maze': PartR.rubikMazeTextTheme,
        'Rubik Microbe': PartR.rubikMicrobeTextTheme,
        'Rubik Mono One': PartR.rubikMonoOneTextTheme,
        'Rubik Moonrocks': PartR.rubikMoonrocksTextTheme,
        'Rubik Pixels': PartR.rubikPixelsTextTheme,
        'Rubik Puddles': PartR.rubikPuddlesTextTheme,
        'Rubik Scribble': PartR.rubikScribbleTextTheme,
        'Rubik Spray Paint': PartR.rubikSprayPaintTextTheme,
        'Rubik Storm': PartR.rubikStormTextTheme,
        'Rubik Vinyl': PartR.rubikVinylTextTheme,
        'Rubik Wet Paint': PartR.rubikWetPaintTextTheme,
        'Ruda': PartR.rudaTextTheme,
        'Rufina': PartR.rufinaTextTheme,
        'Ruge Boogie': PartR.rugeBoogieTextTheme,
        'Ruluko': PartR.rulukoTextTheme,
        'Rum Raisin': PartR.rumRaisinTextTheme,
        'Ruslan Display': PartR.ruslanDisplayTextTheme,
        'Russo One': PartR.russoOneTextTheme,
        'Ruthie': PartR.ruthieTextTheme,
        'Ruwudu': PartR.ruwuduTextTheme,
        'Rye': PartR.ryeTextTheme,
        'STIX Two Text': PartS.stixTwoTextTextTheme,
        'Sacramento': PartS.sacramentoTextTheme,
        'Sahitya': PartS.sahityaTextTheme,
        'Sail': PartS.sailTextTheme,
        'Saira': PartS.sairaTextTheme,
        'Saira Condensed': PartS.sairaCondensedTextTheme,
        'Saira Extra Condensed': PartS.sairaExtraCondensedTextTheme,
        'Saira Semi Condensed': PartS.sairaSemiCondensedTextTheme,
        'Saira Stencil One': PartS.sairaStencilOneTextTheme,
        'Salsa': PartS.salsaTextTheme,
        'Sanchez': PartS.sanchezTextTheme,
        'Sancreek': PartS.sancreekTextTheme,
        'Sansita': PartS.sansitaTextTheme,
        'Sansita Swashed': PartS.sansitaSwashedTextTheme,
        'Sarabun': PartS.sarabunTextTheme,
        'Sarala': PartS.saralaTextTheme,
        'Sarina': PartS.sarinaTextTheme,
        'Sarpanch': PartS.sarpanchTextTheme,
        'Sassy Frass': PartS.sassyFrassTextTheme,
        'Satisfy': PartS.satisfyTextTheme,
        'Sawarabi Gothic': PartS.sawarabiGothicTextTheme,
        'Sawarabi Mincho': PartS.sawarabiMinchoTextTheme,
        'Scada': PartS.scadaTextTheme,
        'Scheherazade New': PartS.scheherazadeNewTextTheme,
        'Schibsted Grotesk': PartS.schibstedGroteskTextTheme,
        'Schoolbell': PartS.schoolbellTextTheme,
        'Scope One': PartS.scopeOneTextTheme,
        'Seaweed Script': PartS.seaweedScriptTextTheme,
        'Secular One': PartS.secularOneTextTheme,
        'Sedan': PartS.sedanTextTheme,
        'Sedan SC': PartS.sedanScTextTheme,
        'Sedgwick Ave': PartS.sedgwickAveTextTheme,
        'Sedgwick Ave Display': PartS.sedgwickAveDisplayTextTheme,
        'Sen': PartS.senTextTheme,
        'Send Flowers': PartS.sendFlowersTextTheme,
        'Sevillana': PartS.sevillanaTextTheme,
        'Seymour One': PartS.seymourOneTextTheme,
        'Shadows Into Light': PartS.shadowsIntoLightTextTheme,
        'Shadows Into Light Two': PartS.shadowsIntoLightTwoTextTheme,
        'Shalimar': PartS.shalimarTextTheme,
        'Shantell Sans': PartS.shantellSansTextTheme,
        'Shanti': PartS.shantiTextTheme,
        'Share': PartS.shareTextTheme,
        'Share Tech': PartS.shareTechTextTheme,
        'Share Tech Mono': PartS.shareTechMonoTextTheme,
        'Shippori Antique': PartS.shipporiAntiqueTextTheme,
        'Shippori Antique B1': PartS.shipporiAntiqueB1TextTheme,
        'Shippori Mincho': PartS.shipporiMinchoTextTheme,
        'Shippori Mincho B1': PartS.shipporiMinchoB1TextTheme,
        'Shizuru': PartS.shizuruTextTheme,
        'Shojumaru': PartS.shojumaruTextTheme,
        'Short Stack': PartS.shortStackTextTheme,
        'Shrikhand': PartS.shrikhandTextTheme,
        'Siemreap': PartS.siemreapTextTheme,
        'Sigmar': PartS.sigmarTextTheme,
        'Sigmar One': PartS.sigmarOneTextTheme,
        'Signika': PartS.signikaTextTheme,
        'Signika Negative': PartS.signikaNegativeTextTheme,
        'Silkscreen': PartS.silkscreenTextTheme,
        'Simonetta': PartS.simonettaTextTheme,
        'Single Day': PartS.singleDayTextTheme,
        'Sintony': PartS.sintonyTextTheme,
        'Sirin Stencil': PartS.sirinStencilTextTheme,
        'Six Caps': PartS.sixCapsTextTheme,
        'Sixtyfour': PartS.sixtyfourTextTheme,
        'Skranji': PartS.skranjiTextTheme,
        'Slabo 13px': PartS.slabo13pxTextTheme,
        'Slabo 27px': PartS.slabo27pxTextTheme,
        'Slackey': PartS.slackeyTextTheme,
        'Slackside One': PartS.slacksideOneTextTheme,
        'Smokum': PartS.smokumTextTheme,
        'Smooch': PartS.smoochTextTheme,
        'Smooch Sans': PartS.smoochSansTextTheme,
        'Smythe': PartS.smytheTextTheme,
        'Sniglet': PartS.snigletTextTheme,
        'Snippet': PartS.snippetTextTheme,
        'Snowburst One': PartS.snowburstOneTextTheme,
        'Sofadi One': PartS.sofadiOneTextTheme,
        'Sofia': PartS.sofiaTextTheme,
        'Sofia Sans': PartS.sofiaSansTextTheme,
        'Sofia Sans Condensed': PartS.sofiaSansCondensedTextTheme,
        'Sofia Sans Extra Condensed': PartS.sofiaSansExtraCondensedTextTheme,
        'Sofia Sans Semi Condensed': PartS.sofiaSansSemiCondensedTextTheme,
        'Solitreo': PartS.solitreoTextTheme,
        'Solway': PartS.solwayTextTheme,
        'Sometype Mono': PartS.sometypeMonoTextTheme,
        'Song Myung': PartS.songMyungTextTheme,
        'Sono': PartS.sonoTextTheme,
        'Sonsie One': PartS.sonsieOneTextTheme,
        'Sora': PartS.soraTextTheme,
        'Sorts Mill Goudy': PartS.sortsMillGoudyTextTheme,
        'Source Code Pro': PartS.sourceCodeProTextTheme,
        'Source Sans 3': PartS.sourceSans3TextTheme,
        'Source Serif 4': PartS.sourceSerif4TextTheme,
        'Space Grotesk': PartS.spaceGroteskTextTheme,
        'Space Mono': PartS.spaceMonoTextTheme,
        'Special Elite': PartS.specialEliteTextTheme,
        'Spectral': PartS.spectralTextTheme,
        'Spectral SC': PartS.spectralScTextTheme,
        'Spicy Rice': PartS.spicyRiceTextTheme,
        'Spinnaker': PartS.spinnakerTextTheme,
        'Spirax': PartS.spiraxTextTheme,
        'Splash': PartS.splashTextTheme,
        'Spline Sans': PartS.splineSansTextTheme,
        'Spline Sans Mono': PartS.splineSansMonoTextTheme,
        'Squada One': PartS.squadaOneTextTheme,
        'Square Peg': PartS.squarePegTextTheme,
        'Sree Krushnadevaraya': PartS.sreeKrushnadevarayaTextTheme,
        'Sriracha': PartS.srirachaTextTheme,
        'Srisakdi': PartS.srisakdiTextTheme,
        'Staatliches': PartS.staatlichesTextTheme,
        'Stalemate': PartS.stalemateTextTheme,
        'Stalinist One': PartS.stalinistOneTextTheme,
        'Stardos Stencil': PartS.stardosStencilTextTheme,
        'Stick': PartS.stickTextTheme,
        'Stick No Bills': PartS.stickNoBillsTextTheme,
        'Stint Ultra Condensed': PartS.stintUltraCondensedTextTheme,
        'Stint Ultra Expanded': PartS.stintUltraExpandedTextTheme,
        'Stoke': PartS.stokeTextTheme,
        'Strait': PartS.straitTextTheme,
        'Style Script': PartS.styleScriptTextTheme,
        'Stylish': PartS.stylishTextTheme,
        'Sue Ellen Francisco': PartS.sueEllenFranciscoTextTheme,
        'Suez One': PartS.suezOneTextTheme,
        'Sulphur Point': PartS.sulphurPointTextTheme,
        'Sumana': PartS.sumanaTextTheme,
        'Sunflower': PartS.sunflowerTextTheme,
        'Sunshiney': PartS.sunshineyTextTheme,
        'Supermercado One': PartS.supermercadoOneTextTheme,
        'Sura': PartS.suraTextTheme,
        'Suranna': PartS.surannaTextTheme,
        'Suravaram': PartS.suravaramTextTheme,
        'Suwannaphum': PartS.suwannaphumTextTheme,
        'Swanky and Moo Moo': PartS.swankyAndMooMooTextTheme,
        'Syncopate': PartS.syncopateTextTheme,
        'Syne': PartS.syneTextTheme,
        'Syne Mono': PartS.syneMonoTextTheme,
        'Syne Tactile': PartS.syneTactileTextTheme,
        'Tac One': PartT.tacOneTextTheme,
        'Tai Heritage Pro': PartT.taiHeritageProTextTheme,
        'Tajawal': PartT.tajawalTextTheme,
        'Tangerine': PartT.tangerineTextTheme,
        'Tapestry': PartT.tapestryTextTheme,
        'Taprom': PartT.tapromTextTheme,
        'Tauri': PartT.tauriTextTheme,
        'Taviraj': PartT.tavirajTextTheme,
        'Teachers': PartT.teachersTextTheme,
        'Teko': PartT.tekoTextTheme,
        'Tektur': PartT.tekturTextTheme,
        'Telex': PartT.telexTextTheme,
        'Tenali Ramakrishna': PartT.tenaliRamakrishnaTextTheme,
        'Tenor Sans': PartT.tenorSansTextTheme,
        'Text Me One': PartT.textMeOneTextTheme,
        'Texturina': PartT.texturinaTextTheme,
        'Thasadith': PartT.thasadithTextTheme,
        'The Girl Next Door': PartT.theGirlNextDoorTextTheme,
        'The Nautigal': PartT.theNautigalTextTheme,
        'Tienne': PartT.tienneTextTheme,
        'Tillana': PartT.tillanaTextTheme,
        'Tilt Neon': PartT.tiltNeonTextTheme,
        'Tilt Prism': PartT.tiltPrismTextTheme,
        'Tilt Warp': PartT.tiltWarpTextTheme,
        'Timmana': PartT.timmanaTextTheme,
        'Tinos': PartT.tinosTextTheme,
        'Tiny5': PartT.tiny5TextTheme,
        'Tiro Bangla': PartT.tiroBanglaTextTheme,
        'Tiro Devanagari Hindi': PartT.tiroDevanagariHindiTextTheme,
        'Tiro Devanagari Marathi': PartT.tiroDevanagariMarathiTextTheme,
        'Tiro Devanagari Sanskrit': PartT.tiroDevanagariSanskritTextTheme,
        'Tiro Gurmukhi': PartT.tiroGurmukhiTextTheme,
        'Tiro Kannada': PartT.tiroKannadaTextTheme,
        'Tiro Tamil': PartT.tiroTamilTextTheme,
        'Tiro Telugu': PartT.tiroTeluguTextTheme,
        'Titan One': PartT.titanOneTextTheme,
        'Titillium Web': PartT.titilliumWebTextTheme,
        'Tomorrow': PartT.tomorrowTextTheme,
        'Tourney': PartT.tourneyTextTheme,
        'Trade Winds': PartT.tradeWindsTextTheme,
        'Train One': PartT.trainOneTextTheme,
        'Trirong': PartT.trirongTextTheme,
        'Trispace': PartT.trispaceTextTheme,
        'Trocchi': PartT.trocchiTextTheme,
        'Trochut': PartT.trochutTextTheme,
        'Truculenta': PartT.truculentaTextTheme,
        'Trykker': PartT.trykkerTextTheme,
        'Tsukimi Rounded': PartT.tsukimiRoundedTextTheme,
        'Tulpen One': PartT.tulpenOneTextTheme,
        'Turret Road': PartT.turretRoadTextTheme,
        'Twinkle Star': PartT.twinkleStarTextTheme,
        'Ubuntu': PartU.ubuntuTextTheme,
        'Ubuntu Condensed': PartU.ubuntuCondensedTextTheme,
        'Ubuntu Mono': PartU.ubuntuMonoTextTheme,
        'Ubuntu Sans': PartU.ubuntuSansTextTheme,
        'Ubuntu Sans Mono': PartU.ubuntuSansMonoTextTheme,
        'Uchen': PartU.uchenTextTheme,
        'Ultra': PartU.ultraTextTheme,
        'Unbounded': PartU.unboundedTextTheme,
        'Uncial Antiqua': PartU.uncialAntiquaTextTheme,
        'Underdog': PartU.underdogTextTheme,
        'Unica One': PartU.unicaOneTextTheme,
        'UnifrakturCook': PartU.unifrakturCookTextTheme,
        'UnifrakturMaguntia': PartU.unifrakturMaguntiaTextTheme,
        'Unkempt': PartU.unkemptTextTheme,
        'Unlock': PartU.unlockTextTheme,
        'Unna': PartU.unnaTextTheme,
        'Updock': PartU.updockTextTheme,
        'Urbanist': PartU.urbanistTextTheme,
        'VT323': PartV.vt323TextTheme,
        'Vampiro One': PartV.vampiroOneTextTheme,
        'Varela': PartV.varelaTextTheme,
        'Varela Round': PartV.varelaRoundTextTheme,
        'Varta': PartV.vartaTextTheme,
        'Vast Shadow': PartV.vastShadowTextTheme,
        'Vazirmatn': PartV.vazirmatnTextTheme,
        'Vesper Libre': PartV.vesperLibreTextTheme,
        'Viaoda Libre': PartV.viaodaLibreTextTheme,
        'Vibes': PartV.vibesTextTheme,
        'Vibur': PartV.viburTextTheme,
        'Victor Mono': PartV.victorMonoTextTheme,
        'Vidaloka': PartV.vidalokaTextTheme,
        'Viga': PartV.vigaTextTheme,
        'Vina Sans': PartV.vinaSansTextTheme,
        'Voces': PartV.vocesTextTheme,
        'Volkhov': PartV.volkhovTextTheme,
        'Vollkorn': PartV.vollkornTextTheme,
        'Vollkorn SC': PartV.vollkornScTextTheme,
        'Voltaire': PartV.voltaireTextTheme,
        'Vujahday Script': PartV.vujahdayScriptTextTheme,
        'Waiting for the Sunrise': PartW.waitingForTheSunriseTextTheme,
        'Wallpoet': PartW.wallpoetTextTheme,
        'Walter Turncoat': PartW.walterTurncoatTextTheme,
        'Warnes': PartW.warnesTextTheme,
        'Water Brush': PartW.waterBrushTextTheme,
        'Waterfall': PartW.waterfallTextTheme,
        'Wavefont': PartW.wavefontTextTheme,
        'Wellfleet': PartW.wellfleetTextTheme,
        'Wendy One': PartW.wendyOneTextTheme,
        'Whisper': PartW.whisperTextTheme,
        'WindSong': PartW.windSongTextTheme,
        'Wire One': PartW.wireOneTextTheme,
        'Wittgenstein': PartW.wittgensteinTextTheme,
        'Wix Madefor Display': PartW.wixMadeforDisplayTextTheme,
        'Wix Madefor Text': PartW.wixMadeforTextTextTheme,
        'Work Sans': PartW.workSansTextTheme,
        'Workbench': PartW.workbenchTextTheme,
        'Xanh Mono': PartX.xanhMonoTextTheme,
        'Yaldevi': PartY.yaldeviTextTheme,
        'Yanone Kaffeesatz': PartY.yanoneKaffeesatzTextTheme,
        'Yantramanav': PartY.yantramanavTextTheme,
        'Yarndings 12': PartY.yarndings12TextTheme,
        'Yarndings 12 Charted': PartY.yarndings12ChartedTextTheme,
        'Yarndings 20': PartY.yarndings20TextTheme,
        'Yarndings 20 Charted': PartY.yarndings20ChartedTextTheme,
        'Yatra One': PartY.yatraOneTextTheme,
        'Yellowtail': PartY.yellowtailTextTheme,
        'Yeon Sung': PartY.yeonSungTextTheme,
        'Yeseva One': PartY.yesevaOneTextTheme,
        'Yesteryear': PartY.yesteryearTextTheme,
        'Yomogi': PartY.yomogiTextTheme,
        'Young Serif': PartY.youngSerifTextTheme,
        'Yrsa': PartY.yrsaTextTheme,
        'Ysabeau': PartY.ysabeauTextTheme,
        'Ysabeau Infant': PartY.ysabeauInfantTextTheme,
        'Ysabeau Office': PartY.ysabeauOfficeTextTheme,
        'Ysabeau SC': PartY.ysabeauScTextTheme,
        'Yuji Boku': PartY.yujiBokuTextTheme,
        'Yuji Hentaigana Akari': PartY.yujiHentaiganaAkariTextTheme,
        'Yuji Hentaigana Akebono': PartY.yujiHentaiganaAkebonoTextTheme,
        'Yuji Mai': PartY.yujiMaiTextTheme,
        'Yuji Syuku': PartY.yujiSyukuTextTheme,
        'Yusei Magic': PartY.yuseiMagicTextTheme,
        'ZCOOL KuaiLe': PartZ.zcoolKuaiLeTextTheme,
        'ZCOOL QingKe HuangYou': PartZ.zcoolQingKeHuangYouTextTheme,
        'ZCOOL XiaoWei': PartZ.zcoolXiaoWeiTextTheme,
        'Zain': PartZ.zainTextTheme,
        'Zen Antique': PartZ.zenAntiqueTextTheme,
        'Zen Antique Soft': PartZ.zenAntiqueSoftTextTheme,
        'Zen Dots': PartZ.zenDotsTextTheme,
        'Zen Kaku Gothic Antique': PartZ.zenKakuGothicAntiqueTextTheme,
        'Zen Kaku Gothic New': PartZ.zenKakuGothicNewTextTheme,
        'Zen Kurenaido': PartZ.zenKurenaidoTextTheme,
        'Zen Loop': PartZ.zenLoopTextTheme,
        'Zen Maru Gothic': PartZ.zenMaruGothicTextTheme,
        'Zen Old Mincho': PartZ.zenOldMinchoTextTheme,
        'Zen Tokyo Zoo': PartZ.zenTokyoZooTextTheme,
        'Zeyada': PartZ.zeyadaTextTheme,
        'Zhi Mang Xing': PartZ.zhiMangXingTextTheme,
        'Zilla Slab': PartZ.zillaSlabTextTheme,
        'Zilla Slab Highlight': PartZ.zillaSlabHighlightTextTheme,
      };

  /// Retrieve a font by family name.
  ///
  /// Applies the given font family from Google Fonts to the given [textStyle]
  /// and returns the resulting [TextStyle].
  ///
  /// Note: [fontFamily] is case-sensitive.
  ///
  /// Parameter [fontFamily] must not be `null`. Throws if no font by name
  /// [fontFamily] exists.
  static TextStyle getFont(
    String fontFamily, {
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = GoogleFonts.asMap();
    if (!fonts.containsKey(fontFamily)) {
      throw Exception("No font family by name '$fontFamily' was found.");
    }
    return fonts[fontFamily]!(
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  /// Retrieve a text theme by its font family name.
  ///
  /// Applies the given font family from Google Fonts to the given [textTheme]
  /// and returns the resulting [textTheme].
  ///
  /// Note: [fontFamily] is case-sensitive.
  ///
  /// Parameter [fontFamily] must not be `null`. Throws if no font by name
  /// [fontFamily] exists.
  static TextTheme getTextTheme(String fontFamily, [TextTheme? textTheme]) {
    final fonts = _asMapOfTextThemes();
    if (!fonts.containsKey(fontFamily)) {
      throw Exception("No font family by name '$fontFamily' was found.");
    }
    return fonts[fontFamily]!(textTheme);
  }

  static const aBeeZee = PartA.aBeeZee;
  static const aBeeZeeTextTheme = PartA.aBeeZeeTextTheme;
  static const aDLaMDisplay = PartA.aDLaMDisplay;
  static const aDLaMDisplayTextTheme = PartA.aDLaMDisplayTextTheme;
  static const arOneSans = PartA.arOneSans;
  static const arOneSansTextTheme = PartA.arOneSansTextTheme;
  static const abel = PartA.abel;
  static const abelTextTheme = PartA.abelTextTheme;
  static const abhayaLibre = PartA.abhayaLibre;
  static const abhayaLibreTextTheme = PartA.abhayaLibreTextTheme;
  static const aboreto = PartA.aboreto;
  static const aboretoTextTheme = PartA.aboretoTextTheme;
  static const abrilFatface = PartA.abrilFatface;
  static const abrilFatfaceTextTheme = PartA.abrilFatfaceTextTheme;
  static const abyssinicaSil = PartA.abyssinicaSil;
  static const abyssinicaSilTextTheme = PartA.abyssinicaSilTextTheme;
  static const aclonica = PartA.aclonica;
  static const aclonicaTextTheme = PartA.aclonicaTextTheme;
  static const acme = PartA.acme;
  static const acmeTextTheme = PartA.acmeTextTheme;
  static const actor = PartA.actor;
  static const actorTextTheme = PartA.actorTextTheme;
  static const adamina = PartA.adamina;
  static const adaminaTextTheme = PartA.adaminaTextTheme;
  static const adventPro = PartA.adventPro;
  static const adventProTextTheme = PartA.adventProTextTheme;
  static const afacad = PartA.afacad;
  static const afacadTextTheme = PartA.afacadTextTheme;
  static const agbalumo = PartA.agbalumo;
  static const agbalumoTextTheme = PartA.agbalumoTextTheme;
  static const agdasima = PartA.agdasima;
  static const agdasimaTextTheme = PartA.agdasimaTextTheme;
  static const aguafinaScript = PartA.aguafinaScript;
  static const aguafinaScriptTextTheme = PartA.aguafinaScriptTextTheme;
  static const akatab = PartA.akatab;
  static const akatabTextTheme = PartA.akatabTextTheme;
  static const akayaKanadaka = PartA.akayaKanadaka;
  static const akayaKanadakaTextTheme = PartA.akayaKanadakaTextTheme;
  static const akayaTelivigala = PartA.akayaTelivigala;
  static const akayaTelivigalaTextTheme = PartA.akayaTelivigalaTextTheme;
  static const akronim = PartA.akronim;
  static const akronimTextTheme = PartA.akronimTextTheme;
  static const akshar = PartA.akshar;
  static const aksharTextTheme = PartA.aksharTextTheme;
  static const aladin = PartA.aladin;
  static const aladinTextTheme = PartA.aladinTextTheme;
  static const alata = PartA.alata;
  static const alataTextTheme = PartA.alataTextTheme;
  static const alatsi = PartA.alatsi;
  static const alatsiTextTheme = PartA.alatsiTextTheme;
  static const albertSans = PartA.albertSans;
  static const albertSansTextTheme = PartA.albertSansTextTheme;
  static const aldrich = PartA.aldrich;
  static const aldrichTextTheme = PartA.aldrichTextTheme;
  static const alef = PartA.alef;
  static const alefTextTheme = PartA.alefTextTheme;
  static const alegreya = PartA.alegreya;
  static const alegreyaTextTheme = PartA.alegreyaTextTheme;
  static const alegreyaSc = PartA.alegreyaSc;
  static const alegreyaScTextTheme = PartA.alegreyaScTextTheme;
  static const alegreyaSans = PartA.alegreyaSans;
  static const alegreyaSansTextTheme = PartA.alegreyaSansTextTheme;
  static const alegreyaSansSc = PartA.alegreyaSansSc;
  static const alegreyaSansScTextTheme = PartA.alegreyaSansScTextTheme;
  static const aleo = PartA.aleo;
  static const aleoTextTheme = PartA.aleoTextTheme;
  static const alexBrush = PartA.alexBrush;
  static const alexBrushTextTheme = PartA.alexBrushTextTheme;
  static const alexandria = PartA.alexandria;
  static const alexandriaTextTheme = PartA.alexandriaTextTheme;
  static const alfaSlabOne = PartA.alfaSlabOne;
  static const alfaSlabOneTextTheme = PartA.alfaSlabOneTextTheme;
  static const alice = PartA.alice;
  static const aliceTextTheme = PartA.aliceTextTheme;
  static const alike = PartA.alike;
  static const alikeTextTheme = PartA.alikeTextTheme;
  static const alikeAngular = PartA.alikeAngular;
  static const alikeAngularTextTheme = PartA.alikeAngularTextTheme;
  static const alkalami = PartA.alkalami;
  static const alkalamiTextTheme = PartA.alkalamiTextTheme;
  static const alkatra = PartA.alkatra;
  static const alkatraTextTheme = PartA.alkatraTextTheme;
  static const allan = PartA.allan;
  static const allanTextTheme = PartA.allanTextTheme;
  static const allerta = PartA.allerta;
  static const allertaTextTheme = PartA.allertaTextTheme;
  static const allertaStencil = PartA.allertaStencil;
  static const allertaStencilTextTheme = PartA.allertaStencilTextTheme;
  static const allison = PartA.allison;
  static const allisonTextTheme = PartA.allisonTextTheme;
  static const allura = PartA.allura;
  static const alluraTextTheme = PartA.alluraTextTheme;
  static const almarai = PartA.almarai;
  static const almaraiTextTheme = PartA.almaraiTextTheme;
  static const almendra = PartA.almendra;
  static const almendraTextTheme = PartA.almendraTextTheme;
  static const almendraDisplay = PartA.almendraDisplay;
  static const almendraDisplayTextTheme = PartA.almendraDisplayTextTheme;
  static const almendraSc = PartA.almendraSc;
  static const almendraScTextTheme = PartA.almendraScTextTheme;
  static const alumniSans = PartA.alumniSans;
  static const alumniSansTextTheme = PartA.alumniSansTextTheme;
  static const alumniSansCollegiateOne = PartA.alumniSansCollegiateOne;
  static const alumniSansCollegiateOneTextTheme =
      PartA.alumniSansCollegiateOneTextTheme;
  static const alumniSansInlineOne = PartA.alumniSansInlineOne;
  static const alumniSansInlineOneTextTheme =
      PartA.alumniSansInlineOneTextTheme;
  static const alumniSansPinstripe = PartA.alumniSansPinstripe;
  static const alumniSansPinstripeTextTheme =
      PartA.alumniSansPinstripeTextTheme;
  static const amarante = PartA.amarante;
  static const amaranteTextTheme = PartA.amaranteTextTheme;
  static const amaranth = PartA.amaranth;
  static const amaranthTextTheme = PartA.amaranthTextTheme;
  static const amaticSc = PartA.amaticSc;
  static const amaticScTextTheme = PartA.amaticScTextTheme;
  static const amethysta = PartA.amethysta;
  static const amethystaTextTheme = PartA.amethystaTextTheme;
  static const amiko = PartA.amiko;
  static const amikoTextTheme = PartA.amikoTextTheme;
  static const amiri = PartA.amiri;
  static const amiriTextTheme = PartA.amiriTextTheme;
  static const amiriQuran = PartA.amiriQuran;
  static const amiriQuranTextTheme = PartA.amiriQuranTextTheme;
  static const amita = PartA.amita;
  static const amitaTextTheme = PartA.amitaTextTheme;
  static const anaheim = PartA.anaheim;
  static const anaheimTextTheme = PartA.anaheimTextTheme;
  static const andadaPro = PartA.andadaPro;
  static const andadaProTextTheme = PartA.andadaProTextTheme;
  static const andika = PartA.andika;
  static const andikaTextTheme = PartA.andikaTextTheme;
  static const anekBangla = PartA.anekBangla;
  static const anekBanglaTextTheme = PartA.anekBanglaTextTheme;
  static const anekDevanagari = PartA.anekDevanagari;
  static const anekDevanagariTextTheme = PartA.anekDevanagariTextTheme;
  static const anekGujarati = PartA.anekGujarati;
  static const anekGujaratiTextTheme = PartA.anekGujaratiTextTheme;
  static const anekGurmukhi = PartA.anekGurmukhi;
  static const anekGurmukhiTextTheme = PartA.anekGurmukhiTextTheme;
  static const anekKannada = PartA.anekKannada;
  static const anekKannadaTextTheme = PartA.anekKannadaTextTheme;
  static const anekLatin = PartA.anekLatin;
  static const anekLatinTextTheme = PartA.anekLatinTextTheme;
  static const anekMalayalam = PartA.anekMalayalam;
  static const anekMalayalamTextTheme = PartA.anekMalayalamTextTheme;
  static const anekOdia = PartA.anekOdia;
  static const anekOdiaTextTheme = PartA.anekOdiaTextTheme;
  static const anekTamil = PartA.anekTamil;
  static const anekTamilTextTheme = PartA.anekTamilTextTheme;
  static const anekTelugu = PartA.anekTelugu;
  static const anekTeluguTextTheme = PartA.anekTeluguTextTheme;
  static const angkor = PartA.angkor;
  static const angkorTextTheme = PartA.angkorTextTheme;
  static const annapurnaSil = PartA.annapurnaSil;
  static const annapurnaSilTextTheme = PartA.annapurnaSilTextTheme;
  static const annieUseYourTelescope = PartA.annieUseYourTelescope;
  static const annieUseYourTelescopeTextTheme =
      PartA.annieUseYourTelescopeTextTheme;
  static const anonymousPro = PartA.anonymousPro;
  static const anonymousProTextTheme = PartA.anonymousProTextTheme;
  static const anta = PartA.anta;
  static const antaTextTheme = PartA.antaTextTheme;
  static const antic = PartA.antic;
  static const anticTextTheme = PartA.anticTextTheme;
  static const anticDidone = PartA.anticDidone;
  static const anticDidoneTextTheme = PartA.anticDidoneTextTheme;
  static const anticSlab = PartA.anticSlab;
  static const anticSlabTextTheme = PartA.anticSlabTextTheme;
  static const anton = PartA.anton;
  static const antonTextTheme = PartA.antonTextTheme;
  static const antonSc = PartA.antonSc;
  static const antonScTextTheme = PartA.antonScTextTheme;
  static const antonio = PartA.antonio;
  static const antonioTextTheme = PartA.antonioTextTheme;
  static const anuphan = PartA.anuphan;
  static const anuphanTextTheme = PartA.anuphanTextTheme;
  static const anybody = PartA.anybody;
  static const anybodyTextTheme = PartA.anybodyTextTheme;
  static const aoboshiOne = PartA.aoboshiOne;
  static const aoboshiOneTextTheme = PartA.aoboshiOneTextTheme;
  static const arapey = PartA.arapey;
  static const arapeyTextTheme = PartA.arapeyTextTheme;
  static const arbutus = PartA.arbutus;
  static const arbutusTextTheme = PartA.arbutusTextTheme;
  static const arbutusSlab = PartA.arbutusSlab;
  static const arbutusSlabTextTheme = PartA.arbutusSlabTextTheme;
  static const architectsDaughter = PartA.architectsDaughter;
  static const architectsDaughterTextTheme = PartA.architectsDaughterTextTheme;
  static const archivo = PartA.archivo;
  static const archivoTextTheme = PartA.archivoTextTheme;
  static const archivoBlack = PartA.archivoBlack;
  static const archivoBlackTextTheme = PartA.archivoBlackTextTheme;
  static const archivoNarrow = PartA.archivoNarrow;
  static const archivoNarrowTextTheme = PartA.archivoNarrowTextTheme;
  static const areYouSerious = PartA.areYouSerious;
  static const areYouSeriousTextTheme = PartA.areYouSeriousTextTheme;
  static const arefRuqaa = PartA.arefRuqaa;
  static const arefRuqaaTextTheme = PartA.arefRuqaaTextTheme;
  static const arefRuqaaInk = PartA.arefRuqaaInk;
  static const arefRuqaaInkTextTheme = PartA.arefRuqaaInkTextTheme;
  static const arima = PartA.arima;
  static const arimaTextTheme = PartA.arimaTextTheme;
  static const arimo = PartA.arimo;
  static const arimoTextTheme = PartA.arimoTextTheme;
  static const arizonia = PartA.arizonia;
  static const arizoniaTextTheme = PartA.arizoniaTextTheme;
  static const armata = PartA.armata;
  static const armataTextTheme = PartA.armataTextTheme;
  static const arsenal = PartA.arsenal;
  static const arsenalTextTheme = PartA.arsenalTextTheme;
  static const arsenalSc = PartA.arsenalSc;
  static const arsenalScTextTheme = PartA.arsenalScTextTheme;
  static const artifika = PartA.artifika;
  static const artifikaTextTheme = PartA.artifikaTextTheme;
  static const arvo = PartA.arvo;
  static const arvoTextTheme = PartA.arvoTextTheme;
  static const arya = PartA.arya;
  static const aryaTextTheme = PartA.aryaTextTheme;
  static const asap = PartA.asap;
  static const asapTextTheme = PartA.asapTextTheme;
  static const asapCondensed = PartA.asapCondensed;
  static const asapCondensedTextTheme = PartA.asapCondensedTextTheme;
  static const asar = PartA.asar;
  static const asarTextTheme = PartA.asarTextTheme;
  static const asset = PartA.asset;
  static const assetTextTheme = PartA.assetTextTheme;
  static const assistant = PartA.assistant;
  static const assistantTextTheme = PartA.assistantTextTheme;
  static const astloch = PartA.astloch;
  static const astlochTextTheme = PartA.astlochTextTheme;
  static const asul = PartA.asul;
  static const asulTextTheme = PartA.asulTextTheme;
  static const athiti = PartA.athiti;
  static const athitiTextTheme = PartA.athitiTextTheme;
  static const atkinsonHyperlegible = PartA.atkinsonHyperlegible;
  static const atkinsonHyperlegibleTextTheme =
      PartA.atkinsonHyperlegibleTextTheme;
  static const atma = PartA.atma;
  static const atmaTextTheme = PartA.atmaTextTheme;
  static const atomicAge = PartA.atomicAge;
  static const atomicAgeTextTheme = PartA.atomicAgeTextTheme;
  static const aubrey = PartA.aubrey;
  static const aubreyTextTheme = PartA.aubreyTextTheme;
  static const audiowide = PartA.audiowide;
  static const audiowideTextTheme = PartA.audiowideTextTheme;
  static const autourOne = PartA.autourOne;
  static const autourOneTextTheme = PartA.autourOneTextTheme;
  static const average = PartA.average;
  static const averageTextTheme = PartA.averageTextTheme;
  static const averageSans = PartA.averageSans;
  static const averageSansTextTheme = PartA.averageSansTextTheme;
  static const averiaGruesaLibre = PartA.averiaGruesaLibre;
  static const averiaGruesaLibreTextTheme = PartA.averiaGruesaLibreTextTheme;
  static const averiaLibre = PartA.averiaLibre;
  static const averiaLibreTextTheme = PartA.averiaLibreTextTheme;
  static const averiaSansLibre = PartA.averiaSansLibre;
  static const averiaSansLibreTextTheme = PartA.averiaSansLibreTextTheme;
  static const averiaSerifLibre = PartA.averiaSerifLibre;
  static const averiaSerifLibreTextTheme = PartA.averiaSerifLibreTextTheme;
  static const azeretMono = PartA.azeretMono;
  static const azeretMonoTextTheme = PartA.azeretMonoTextTheme;
  static const b612 = PartB.b612;
  static const b612TextTheme = PartB.b612TextTheme;
  static const b612Mono = PartB.b612Mono;
  static const b612MonoTextTheme = PartB.b612MonoTextTheme;
  static const bizUDGothic = PartB.bizUDGothic;
  static const bizUDGothicTextTheme = PartB.bizUDGothicTextTheme;
  static const bizUDMincho = PartB.bizUDMincho;
  static const bizUDMinchoTextTheme = PartB.bizUDMinchoTextTheme;
  static const bizUDPGothic = PartB.bizUDPGothic;
  static const bizUDPGothicTextTheme = PartB.bizUDPGothicTextTheme;
  static const bizUDPMincho = PartB.bizUDPMincho;
  static const bizUDPMinchoTextTheme = PartB.bizUDPMinchoTextTheme;
  static const babylonica = PartB.babylonica;
  static const babylonicaTextTheme = PartB.babylonicaTextTheme;
  static const bacasimeAntique = PartB.bacasimeAntique;
  static const bacasimeAntiqueTextTheme = PartB.bacasimeAntiqueTextTheme;
  static const badScript = PartB.badScript;
  static const badScriptTextTheme = PartB.badScriptTextTheme;
  static const bagelFatOne = PartB.bagelFatOne;
  static const bagelFatOneTextTheme = PartB.bagelFatOneTextTheme;
  static const bahiana = PartB.bahiana;
  static const bahianaTextTheme = PartB.bahianaTextTheme;
  static const bahianita = PartB.bahianita;
  static const bahianitaTextTheme = PartB.bahianitaTextTheme;
  static const baiJamjuree = PartB.baiJamjuree;
  static const baiJamjureeTextTheme = PartB.baiJamjureeTextTheme;
  static const bakbakOne = PartB.bakbakOne;
  static const bakbakOneTextTheme = PartB.bakbakOneTextTheme;
  static const ballet = PartB.ballet;
  static const balletTextTheme = PartB.balletTextTheme;
  static const baloo2 = PartB.baloo2;
  static const baloo2TextTheme = PartB.baloo2TextTheme;
  static const balooBhai2 = PartB.balooBhai2;
  static const balooBhai2TextTheme = PartB.balooBhai2TextTheme;
  static const balooBhaijaan2 = PartB.balooBhaijaan2;
  static const balooBhaijaan2TextTheme = PartB.balooBhaijaan2TextTheme;
  static const balooBhaina2 = PartB.balooBhaina2;
  static const balooBhaina2TextTheme = PartB.balooBhaina2TextTheme;
  static const balooChettan2 = PartB.balooChettan2;
  static const balooChettan2TextTheme = PartB.balooChettan2TextTheme;
  static const balooDa2 = PartB.balooDa2;
  static const balooDa2TextTheme = PartB.balooDa2TextTheme;
  static const balooPaaji2 = PartB.balooPaaji2;
  static const balooPaaji2TextTheme = PartB.balooPaaji2TextTheme;
  static const balooTamma2 = PartB.balooTamma2;
  static const balooTamma2TextTheme = PartB.balooTamma2TextTheme;
  static const balooTammudu2 = PartB.balooTammudu2;
  static const balooTammudu2TextTheme = PartB.balooTammudu2TextTheme;
  static const balooThambi2 = PartB.balooThambi2;
  static const balooThambi2TextTheme = PartB.balooThambi2TextTheme;
  static const balsamiqSans = PartB.balsamiqSans;
  static const balsamiqSansTextTheme = PartB.balsamiqSansTextTheme;
  static const balthazar = PartB.balthazar;
  static const balthazarTextTheme = PartB.balthazarTextTheme;
  static const bangers = PartB.bangers;
  static const bangersTextTheme = PartB.bangersTextTheme;
  static const barlow = PartB.barlow;
  static const barlowTextTheme = PartB.barlowTextTheme;
  static const barlowCondensed = PartB.barlowCondensed;
  static const barlowCondensedTextTheme = PartB.barlowCondensedTextTheme;
  static const barlowSemiCondensed = PartB.barlowSemiCondensed;
  static const barlowSemiCondensedTextTheme =
      PartB.barlowSemiCondensedTextTheme;
  static const barriecito = PartB.barriecito;
  static const barriecitoTextTheme = PartB.barriecitoTextTheme;
  static const barrio = PartB.barrio;
  static const barrioTextTheme = PartB.barrioTextTheme;
  static const basic = PartB.basic;
  static const basicTextTheme = PartB.basicTextTheme;
  static const baskervville = PartB.baskervville;
  static const baskervvilleTextTheme = PartB.baskervvilleTextTheme;
  static const baskervvilleSc = PartB.baskervvilleSc;
  static const baskervvilleScTextTheme = PartB.baskervvilleScTextTheme;
  static const battambang = PartB.battambang;
  static const battambangTextTheme = PartB.battambangTextTheme;
  static const baumans = PartB.baumans;
  static const baumansTextTheme = PartB.baumansTextTheme;
  static const bayon = PartB.bayon;
  static const bayonTextTheme = PartB.bayonTextTheme;
  static const beVietnamPro = PartB.beVietnamPro;
  static const beVietnamProTextTheme = PartB.beVietnamProTextTheme;
  static const beauRivage = PartB.beauRivage;
  static const beauRivageTextTheme = PartB.beauRivageTextTheme;
  static const bebasNeue = PartB.bebasNeue;
  static const bebasNeueTextTheme = PartB.bebasNeueTextTheme;
  static const beiruti = PartB.beiruti;
  static const beirutiTextTheme = PartB.beirutiTextTheme;
  static const belanosima = PartB.belanosima;
  static const belanosimaTextTheme = PartB.belanosimaTextTheme;
  static const belgrano = PartB.belgrano;
  static const belgranoTextTheme = PartB.belgranoTextTheme;
  static const bellefair = PartB.bellefair;
  static const bellefairTextTheme = PartB.bellefairTextTheme;
  static const belleza = PartB.belleza;
  static const bellezaTextTheme = PartB.bellezaTextTheme;
  static const bellota = PartB.bellota;
  static const bellotaTextTheme = PartB.bellotaTextTheme;
  static const bellotaText = PartB.bellotaText;
  static const bellotaTextTextTheme = PartB.bellotaTextTextTheme;
  static const benchNine = PartB.benchNine;
  static const benchNineTextTheme = PartB.benchNineTextTheme;
  static const benne = PartB.benne;
  static const benneTextTheme = PartB.benneTextTheme;
  static const bentham = PartB.bentham;
  static const benthamTextTheme = PartB.benthamTextTheme;
  static const berkshireSwash = PartB.berkshireSwash;
  static const berkshireSwashTextTheme = PartB.berkshireSwashTextTheme;
  static const besley = PartB.besley;
  static const besleyTextTheme = PartB.besleyTextTheme;
  static const bethEllen = PartB.bethEllen;
  static const bethEllenTextTheme = PartB.bethEllenTextTheme;
  static const bevan = PartB.bevan;
  static const bevanTextTheme = PartB.bevanTextTheme;
  static const bhuTukaExpandedOne = PartB.bhuTukaExpandedOne;
  static const bhuTukaExpandedOneTextTheme = PartB.bhuTukaExpandedOneTextTheme;
  static const bigShouldersDisplay = PartB.bigShouldersDisplay;
  static const bigShouldersDisplayTextTheme =
      PartB.bigShouldersDisplayTextTheme;
  static const bigShouldersInlineDisplay = PartB.bigShouldersInlineDisplay;
  static const bigShouldersInlineDisplayTextTheme =
      PartB.bigShouldersInlineDisplayTextTheme;
  static const bigShouldersInlineText = PartB.bigShouldersInlineText;
  static const bigShouldersInlineTextTextTheme =
      PartB.bigShouldersInlineTextTextTheme;
  static const bigShouldersStencilDisplay = PartB.bigShouldersStencilDisplay;
  static const bigShouldersStencilDisplayTextTheme =
      PartB.bigShouldersStencilDisplayTextTheme;
  static const bigShouldersStencilText = PartB.bigShouldersStencilText;
  static const bigShouldersStencilTextTextTheme =
      PartB.bigShouldersStencilTextTextTheme;
  static const bigShouldersText = PartB.bigShouldersText;
  static const bigShouldersTextTextTheme = PartB.bigShouldersTextTextTheme;
  static const bigelowRules = PartB.bigelowRules;
  static const bigelowRulesTextTheme = PartB.bigelowRulesTextTheme;
  static const bigshotOne = PartB.bigshotOne;
  static const bigshotOneTextTheme = PartB.bigshotOneTextTheme;
  static const bilbo = PartB.bilbo;
  static const bilboTextTheme = PartB.bilboTextTheme;
  static const bilboSwashCaps = PartB.bilboSwashCaps;
  static const bilboSwashCapsTextTheme = PartB.bilboSwashCapsTextTheme;
  static const bioRhyme = PartB.bioRhyme;
  static const bioRhymeTextTheme = PartB.bioRhymeTextTheme;
  static const bioRhymeExpanded = PartB.bioRhymeExpanded;
  static const bioRhymeExpandedTextTheme = PartB.bioRhymeExpandedTextTheme;
  static const birthstone = PartB.birthstone;
  static const birthstoneTextTheme = PartB.birthstoneTextTheme;
  static const birthstoneBounce = PartB.birthstoneBounce;
  static const birthstoneBounceTextTheme = PartB.birthstoneBounceTextTheme;
  static const biryani = PartB.biryani;
  static const biryaniTextTheme = PartB.biryaniTextTheme;
  static const bitter = PartB.bitter;
  static const bitterTextTheme = PartB.bitterTextTheme;
  static const blackAndWhitePicture = PartB.blackAndWhitePicture;
  static const blackAndWhitePictureTextTheme =
      PartB.blackAndWhitePictureTextTheme;
  static const blackHanSans = PartB.blackHanSans;
  static const blackHanSansTextTheme = PartB.blackHanSansTextTheme;
  static const blackOpsOne = PartB.blackOpsOne;
  static const blackOpsOneTextTheme = PartB.blackOpsOneTextTheme;
  static const blaka = PartB.blaka;
  static const blakaTextTheme = PartB.blakaTextTheme;
  static const blakaHollow = PartB.blakaHollow;
  static const blakaHollowTextTheme = PartB.blakaHollowTextTheme;
  static const blakaInk = PartB.blakaInk;
  static const blakaInkTextTheme = PartB.blakaInkTextTheme;
  static const blinker = PartB.blinker;
  static const blinkerTextTheme = PartB.blinkerTextTheme;
  static const bodoniModa = PartB.bodoniModa;
  static const bodoniModaTextTheme = PartB.bodoniModaTextTheme;
  static const bodoniModaSc = PartB.bodoniModaSc;
  static const bodoniModaScTextTheme = PartB.bodoniModaScTextTheme;
  static const bokor = PartB.bokor;
  static const bokorTextTheme = PartB.bokorTextTheme;
  static const bonaNova = PartB.bonaNova;
  static const bonaNovaTextTheme = PartB.bonaNovaTextTheme;
  static const bonaNovaSc = PartB.bonaNovaSc;
  static const bonaNovaScTextTheme = PartB.bonaNovaScTextTheme;
  static const bonbon = PartB.bonbon;
  static const bonbonTextTheme = PartB.bonbonTextTheme;
  static const bonheurRoyale = PartB.bonheurRoyale;
  static const bonheurRoyaleTextTheme = PartB.bonheurRoyaleTextTheme;
  static const boogaloo = PartB.boogaloo;
  static const boogalooTextTheme = PartB.boogalooTextTheme;
  static const borel = PartB.borel;
  static const borelTextTheme = PartB.borelTextTheme;
  static const bowlbyOne = PartB.bowlbyOne;
  static const bowlbyOneTextTheme = PartB.bowlbyOneTextTheme;
  static const bowlbyOneSc = PartB.bowlbyOneSc;
  static const bowlbyOneScTextTheme = PartB.bowlbyOneScTextTheme;
  static const braahOne = PartB.braahOne;
  static const braahOneTextTheme = PartB.braahOneTextTheme;
  static const brawler = PartB.brawler;
  static const brawlerTextTheme = PartB.brawlerTextTheme;
  static const breeSerif = PartB.breeSerif;
  static const breeSerifTextTheme = PartB.breeSerifTextTheme;
  static const bricolageGrotesque = PartB.bricolageGrotesque;
  static const bricolageGrotesqueTextTheme = PartB.bricolageGrotesqueTextTheme;
  static const brunoAce = PartB.brunoAce;
  static const brunoAceTextTheme = PartB.brunoAceTextTheme;
  static const brunoAceSc = PartB.brunoAceSc;
  static const brunoAceScTextTheme = PartB.brunoAceScTextTheme;
  static const brygada1918 = PartB.brygada1918;
  static const brygada1918TextTheme = PartB.brygada1918TextTheme;
  static const bubblegumSans = PartB.bubblegumSans;
  static const bubblegumSansTextTheme = PartB.bubblegumSansTextTheme;
  static const bubblerOne = PartB.bubblerOne;
  static const bubblerOneTextTheme = PartB.bubblerOneTextTheme;
  static const buda = PartB.buda;
  static const budaTextTheme = PartB.budaTextTheme;
  static const buenard = PartB.buenard;
  static const buenardTextTheme = PartB.buenardTextTheme;
  static const bungee = PartB.bungee;
  static const bungeeTextTheme = PartB.bungeeTextTheme;
  static const bungeeHairline = PartB.bungeeHairline;
  static const bungeeHairlineTextTheme = PartB.bungeeHairlineTextTheme;
  static const bungeeInline = PartB.bungeeInline;
  static const bungeeInlineTextTheme = PartB.bungeeInlineTextTheme;
  static const bungeeOutline = PartB.bungeeOutline;
  static const bungeeOutlineTextTheme = PartB.bungeeOutlineTextTheme;
  static const bungeeShade = PartB.bungeeShade;
  static const bungeeShadeTextTheme = PartB.bungeeShadeTextTheme;
  static const bungeeSpice = PartB.bungeeSpice;
  static const bungeeSpiceTextTheme = PartB.bungeeSpiceTextTheme;
  static const butcherman = PartB.butcherman;
  static const butchermanTextTheme = PartB.butchermanTextTheme;
  static const butterflyKids = PartB.butterflyKids;
  static const butterflyKidsTextTheme = PartB.butterflyKidsTextTheme;
  static const cabin = PartC.cabin;
  static const cabinTextTheme = PartC.cabinTextTheme;
  static const cabinCondensed = PartC.cabinCondensed;
  static const cabinCondensedTextTheme = PartC.cabinCondensedTextTheme;
  static const cabinSketch = PartC.cabinSketch;
  static const cabinSketchTextTheme = PartC.cabinSketchTextTheme;
  static const cactusClassicalSerif = PartC.cactusClassicalSerif;
  static const cactusClassicalSerifTextTheme =
      PartC.cactusClassicalSerifTextTheme;
  static const caesarDressing = PartC.caesarDressing;
  static const caesarDressingTextTheme = PartC.caesarDressingTextTheme;
  static const cagliostro = PartC.cagliostro;
  static const cagliostroTextTheme = PartC.cagliostroTextTheme;
  static const cairo = PartC.cairo;
  static const cairoTextTheme = PartC.cairoTextTheme;
  static const cairoPlay = PartC.cairoPlay;
  static const cairoPlayTextTheme = PartC.cairoPlayTextTheme;
  static const caladea = PartC.caladea;
  static const caladeaTextTheme = PartC.caladeaTextTheme;
  static const calistoga = PartC.calistoga;
  static const calistogaTextTheme = PartC.calistogaTextTheme;
  static const calligraffitti = PartC.calligraffitti;
  static const calligraffittiTextTheme = PartC.calligraffittiTextTheme;
  static const cambay = PartC.cambay;
  static const cambayTextTheme = PartC.cambayTextTheme;
  static const cambo = PartC.cambo;
  static const camboTextTheme = PartC.camboTextTheme;
  static const candal = PartC.candal;
  static const candalTextTheme = PartC.candalTextTheme;
  static const cantarell = PartC.cantarell;
  static const cantarellTextTheme = PartC.cantarellTextTheme;
  static const cantataOne = PartC.cantataOne;
  static const cantataOneTextTheme = PartC.cantataOneTextTheme;
  static const cantoraOne = PartC.cantoraOne;
  static const cantoraOneTextTheme = PartC.cantoraOneTextTheme;
  static const caprasimo = PartC.caprasimo;
  static const caprasimoTextTheme = PartC.caprasimoTextTheme;
  static const capriola = PartC.capriola;
  static const capriolaTextTheme = PartC.capriolaTextTheme;
  static const caramel = PartC.caramel;
  static const caramelTextTheme = PartC.caramelTextTheme;
  static const carattere = PartC.carattere;
  static const carattereTextTheme = PartC.carattereTextTheme;
  static const cardo = PartC.cardo;
  static const cardoTextTheme = PartC.cardoTextTheme;
  static const carlito = PartC.carlito;
  static const carlitoTextTheme = PartC.carlitoTextTheme;
  static const carme = PartC.carme;
  static const carmeTextTheme = PartC.carmeTextTheme;
  static const carroisGothic = PartC.carroisGothic;
  static const carroisGothicTextTheme = PartC.carroisGothicTextTheme;
  static const carroisGothicSc = PartC.carroisGothicSc;
  static const carroisGothicScTextTheme = PartC.carroisGothicScTextTheme;
  static const carterOne = PartC.carterOne;
  static const carterOneTextTheme = PartC.carterOneTextTheme;
  static const castoro = PartC.castoro;
  static const castoroTextTheme = PartC.castoroTextTheme;
  static const castoroTitling = PartC.castoroTitling;
  static const castoroTitlingTextTheme = PartC.castoroTitlingTextTheme;
  static const catamaran = PartC.catamaran;
  static const catamaranTextTheme = PartC.catamaranTextTheme;
  static const caudex = PartC.caudex;
  static const caudexTextTheme = PartC.caudexTextTheme;
  static const caveat = PartC.caveat;
  static const caveatTextTheme = PartC.caveatTextTheme;
  static const caveatBrush = PartC.caveatBrush;
  static const caveatBrushTextTheme = PartC.caveatBrushTextTheme;
  static const cedarvilleCursive = PartC.cedarvilleCursive;
  static const cedarvilleCursiveTextTheme = PartC.cedarvilleCursiveTextTheme;
  static const cevicheOne = PartC.cevicheOne;
  static const cevicheOneTextTheme = PartC.cevicheOneTextTheme;
  static const chakraPetch = PartC.chakraPetch;
  static const chakraPetchTextTheme = PartC.chakraPetchTextTheme;
  static const changa = PartC.changa;
  static const changaTextTheme = PartC.changaTextTheme;
  static const changaOne = PartC.changaOne;
  static const changaOneTextTheme = PartC.changaOneTextTheme;
  static const chango = PartC.chango;
  static const changoTextTheme = PartC.changoTextTheme;
  static const charisSil = PartC.charisSil;
  static const charisSilTextTheme = PartC.charisSilTextTheme;
  static const charm = PartC.charm;
  static const charmTextTheme = PartC.charmTextTheme;
  static const charmonman = PartC.charmonman;
  static const charmonmanTextTheme = PartC.charmonmanTextTheme;
  static const chathura = PartC.chathura;
  static const chathuraTextTheme = PartC.chathuraTextTheme;
  static const chauPhilomeneOne = PartC.chauPhilomeneOne;
  static const chauPhilomeneOneTextTheme = PartC.chauPhilomeneOneTextTheme;
  static const chelaOne = PartC.chelaOne;
  static const chelaOneTextTheme = PartC.chelaOneTextTheme;
  static const chelseaMarket = PartC.chelseaMarket;
  static const chelseaMarketTextTheme = PartC.chelseaMarketTextTheme;
  static const chenla = PartC.chenla;
  static const chenlaTextTheme = PartC.chenlaTextTheme;
  static const cherish = PartC.cherish;
  static const cherishTextTheme = PartC.cherishTextTheme;
  static const cherryBombOne = PartC.cherryBombOne;
  static const cherryBombOneTextTheme = PartC.cherryBombOneTextTheme;
  static const cherryCreamSoda = PartC.cherryCreamSoda;
  static const cherryCreamSodaTextTheme = PartC.cherryCreamSodaTextTheme;
  static const cherrySwash = PartC.cherrySwash;
  static const cherrySwashTextTheme = PartC.cherrySwashTextTheme;
  static const chewy = PartC.chewy;
  static const chewyTextTheme = PartC.chewyTextTheme;
  static const chicle = PartC.chicle;
  static const chicleTextTheme = PartC.chicleTextTheme;
  static const chilanka = PartC.chilanka;
  static const chilankaTextTheme = PartC.chilankaTextTheme;
  static const chivo = PartC.chivo;
  static const chivoTextTheme = PartC.chivoTextTheme;
  static const chivoMono = PartC.chivoMono;
  static const chivoMonoTextTheme = PartC.chivoMonoTextTheme;
  static const chocolateClassicalSans = PartC.chocolateClassicalSans;
  static const chocolateClassicalSansTextTheme =
      PartC.chocolateClassicalSansTextTheme;
  static const chokokutai = PartC.chokokutai;
  static const chokokutaiTextTheme = PartC.chokokutaiTextTheme;
  static const chonburi = PartC.chonburi;
  static const chonburiTextTheme = PartC.chonburiTextTheme;
  static const cinzel = PartC.cinzel;
  static const cinzelTextTheme = PartC.cinzelTextTheme;
  static const cinzelDecorative = PartC.cinzelDecorative;
  static const cinzelDecorativeTextTheme = PartC.cinzelDecorativeTextTheme;
  static const clickerScript = PartC.clickerScript;
  static const clickerScriptTextTheme = PartC.clickerScriptTextTheme;
  static const climateCrisis = PartC.climateCrisis;
  static const climateCrisisTextTheme = PartC.climateCrisisTextTheme;
  static const coda = PartC.coda;
  static const codaTextTheme = PartC.codaTextTheme;
  static const codystar = PartC.codystar;
  static const codystarTextTheme = PartC.codystarTextTheme;
  static const coiny = PartC.coiny;
  static const coinyTextTheme = PartC.coinyTextTheme;
  static const combo = PartC.combo;
  static const comboTextTheme = PartC.comboTextTheme;
  static const comfortaa = PartC.comfortaa;
  static const comfortaaTextTheme = PartC.comfortaaTextTheme;
  static const comforter = PartC.comforter;
  static const comforterTextTheme = PartC.comforterTextTheme;
  static const comforterBrush = PartC.comforterBrush;
  static const comforterBrushTextTheme = PartC.comforterBrushTextTheme;
  static const comicNeue = PartC.comicNeue;
  static const comicNeueTextTheme = PartC.comicNeueTextTheme;
  static const comingSoon = PartC.comingSoon;
  static const comingSoonTextTheme = PartC.comingSoonTextTheme;
  static const comme = PartC.comme;
  static const commeTextTheme = PartC.commeTextTheme;
  static const commissioner = PartC.commissioner;
  static const commissionerTextTheme = PartC.commissionerTextTheme;
  static const concertOne = PartC.concertOne;
  static const concertOneTextTheme = PartC.concertOneTextTheme;
  static const condiment = PartC.condiment;
  static const condimentTextTheme = PartC.condimentTextTheme;
  static const content = PartC.content;
  static const contentTextTheme = PartC.contentTextTheme;
  static const contrailOne = PartC.contrailOne;
  static const contrailOneTextTheme = PartC.contrailOneTextTheme;
  static const convergence = PartC.convergence;
  static const convergenceTextTheme = PartC.convergenceTextTheme;
  static const cookie = PartC.cookie;
  static const cookieTextTheme = PartC.cookieTextTheme;
  static const copse = PartC.copse;
  static const copseTextTheme = PartC.copseTextTheme;
  static const corben = PartC.corben;
  static const corbenTextTheme = PartC.corbenTextTheme;
  static const corinthia = PartC.corinthia;
  static const corinthiaTextTheme = PartC.corinthiaTextTheme;
  static const cormorant = PartC.cormorant;
  static const cormorantTextTheme = PartC.cormorantTextTheme;
  static const cormorantGaramond = PartC.cormorantGaramond;
  static const cormorantGaramondTextTheme = PartC.cormorantGaramondTextTheme;
  static const cormorantInfant = PartC.cormorantInfant;
  static const cormorantInfantTextTheme = PartC.cormorantInfantTextTheme;
  static const cormorantSc = PartC.cormorantSc;
  static const cormorantScTextTheme = PartC.cormorantScTextTheme;
  static const cormorantUnicase = PartC.cormorantUnicase;
  static const cormorantUnicaseTextTheme = PartC.cormorantUnicaseTextTheme;
  static const cormorantUpright = PartC.cormorantUpright;
  static const cormorantUprightTextTheme = PartC.cormorantUprightTextTheme;
  static const courgette = PartC.courgette;
  static const courgetteTextTheme = PartC.courgetteTextTheme;
  static const courierPrime = PartC.courierPrime;
  static const courierPrimeTextTheme = PartC.courierPrimeTextTheme;
  static const cousine = PartC.cousine;
  static const cousineTextTheme = PartC.cousineTextTheme;
  static const coustard = PartC.coustard;
  static const coustardTextTheme = PartC.coustardTextTheme;
  static const coveredByYourGrace = PartC.coveredByYourGrace;
  static const coveredByYourGraceTextTheme = PartC.coveredByYourGraceTextTheme;
  static const craftyGirls = PartC.craftyGirls;
  static const craftyGirlsTextTheme = PartC.craftyGirlsTextTheme;
  static const creepster = PartC.creepster;
  static const creepsterTextTheme = PartC.creepsterTextTheme;
  static const creteRound = PartC.creteRound;
  static const creteRoundTextTheme = PartC.creteRoundTextTheme;
  static const crimsonPro = PartC.crimsonPro;
  static const crimsonProTextTheme = PartC.crimsonProTextTheme;
  static const crimsonText = PartC.crimsonText;
  static const crimsonTextTextTheme = PartC.crimsonTextTextTheme;
  static const croissantOne = PartC.croissantOne;
  static const croissantOneTextTheme = PartC.croissantOneTextTheme;
  static const crushed = PartC.crushed;
  static const crushedTextTheme = PartC.crushedTextTheme;
  static const cuprum = PartC.cuprum;
  static const cuprumTextTheme = PartC.cuprumTextTheme;
  static const cuteFont = PartC.cuteFont;
  static const cuteFontTextTheme = PartC.cuteFontTextTheme;
  static const cutive = PartC.cutive;
  static const cutiveTextTheme = PartC.cutiveTextTheme;
  static const cutiveMono = PartC.cutiveMono;
  static const cutiveMonoTextTheme = PartC.cutiveMonoTextTheme;
  static const dmMono = PartD.dmMono;
  static const dmMonoTextTheme = PartD.dmMonoTextTheme;
  static const dmSans = PartD.dmSans;
  static const dmSansTextTheme = PartD.dmSansTextTheme;
  static const dmSerifDisplay = PartD.dmSerifDisplay;
  static const dmSerifDisplayTextTheme = PartD.dmSerifDisplayTextTheme;
  static const dmSerifText = PartD.dmSerifText;
  static const dmSerifTextTextTheme = PartD.dmSerifTextTextTheme;
  static const daiBannaSil = PartD.daiBannaSil;
  static const daiBannaSilTextTheme = PartD.daiBannaSilTextTheme;
  static const damion = PartD.damion;
  static const damionTextTheme = PartD.damionTextTheme;
  static const dancingScript = PartD.dancingScript;
  static const dancingScriptTextTheme = PartD.dancingScriptTextTheme;
  static const danfo = PartD.danfo;
  static const danfoTextTheme = PartD.danfoTextTheme;
  static const dangrek = PartD.dangrek;
  static const dangrekTextTheme = PartD.dangrekTextTheme;
  static const darkerGrotesque = PartD.darkerGrotesque;
  static const darkerGrotesqueTextTheme = PartD.darkerGrotesqueTextTheme;
  static const darumadropOne = PartD.darumadropOne;
  static const darumadropOneTextTheme = PartD.darumadropOneTextTheme;
  static const davidLibre = PartD.davidLibre;
  static const davidLibreTextTheme = PartD.davidLibreTextTheme;
  static const dawningOfANewDay = PartD.dawningOfANewDay;
  static const dawningOfANewDayTextTheme = PartD.dawningOfANewDayTextTheme;
  static const daysOne = PartD.daysOne;
  static const daysOneTextTheme = PartD.daysOneTextTheme;
  static const dekko = PartD.dekko;
  static const dekkoTextTheme = PartD.dekkoTextTheme;
  static const delaGothicOne = PartD.delaGothicOne;
  static const delaGothicOneTextTheme = PartD.delaGothicOneTextTheme;
  static const deliciousHandrawn = PartD.deliciousHandrawn;
  static const deliciousHandrawnTextTheme = PartD.deliciousHandrawnTextTheme;
  static const delius = PartD.delius;
  static const deliusTextTheme = PartD.deliusTextTheme;
  static const deliusSwashCaps = PartD.deliusSwashCaps;
  static const deliusSwashCapsTextTheme = PartD.deliusSwashCapsTextTheme;
  static const deliusUnicase = PartD.deliusUnicase;
  static const deliusUnicaseTextTheme = PartD.deliusUnicaseTextTheme;
  static const dellaRespira = PartD.dellaRespira;
  static const dellaRespiraTextTheme = PartD.dellaRespiraTextTheme;
  static const denkOne = PartD.denkOne;
  static const denkOneTextTheme = PartD.denkOneTextTheme;
  static const devonshire = PartD.devonshire;
  static const devonshireTextTheme = PartD.devonshireTextTheme;
  static const dhurjati = PartD.dhurjati;
  static const dhurjatiTextTheme = PartD.dhurjatiTextTheme;
  static const didactGothic = PartD.didactGothic;
  static const didactGothicTextTheme = PartD.didactGothicTextTheme;
  static const diphylleia = PartD.diphylleia;
  static const diphylleiaTextTheme = PartD.diphylleiaTextTheme;
  static const diplomata = PartD.diplomata;
  static const diplomataTextTheme = PartD.diplomataTextTheme;
  static const diplomataSc = PartD.diplomataSc;
  static const diplomataScTextTheme = PartD.diplomataScTextTheme;
  static const doHyeon = PartD.doHyeon;
  static const doHyeonTextTheme = PartD.doHyeonTextTheme;
  static const dokdo = PartD.dokdo;
  static const dokdoTextTheme = PartD.dokdoTextTheme;
  static const domine = PartD.domine;
  static const domineTextTheme = PartD.domineTextTheme;
  static const donegalOne = PartD.donegalOne;
  static const donegalOneTextTheme = PartD.donegalOneTextTheme;
  static const dongle = PartD.dongle;
  static const dongleTextTheme = PartD.dongleTextTheme;
  static const doppioOne = PartD.doppioOne;
  static const doppioOneTextTheme = PartD.doppioOneTextTheme;
  static const dorsa = PartD.dorsa;
  static const dorsaTextTheme = PartD.dorsaTextTheme;
  static const dosis = PartD.dosis;
  static const dosisTextTheme = PartD.dosisTextTheme;
  static const dotGothic16 = PartD.dotGothic16;
  static const dotGothic16TextTheme = PartD.dotGothic16TextTheme;
  static const drSugiyama = PartD.drSugiyama;
  static const drSugiyamaTextTheme = PartD.drSugiyamaTextTheme;
  static const duruSans = PartD.duruSans;
  static const duruSansTextTheme = PartD.duruSansTextTheme;
  static const dynaPuff = PartD.dynaPuff;
  static const dynaPuffTextTheme = PartD.dynaPuffTextTheme;
  static const dynalight = PartD.dynalight;
  static const dynalightTextTheme = PartD.dynalightTextTheme;
  static const ebGaramond = PartE.ebGaramond;
  static const ebGaramondTextTheme = PartE.ebGaramondTextTheme;
  static const eagleLake = PartE.eagleLake;
  static const eagleLakeTextTheme = PartE.eagleLakeTextTheme;
  static const eastSeaDokdo = PartE.eastSeaDokdo;
  static const eastSeaDokdoTextTheme = PartE.eastSeaDokdoTextTheme;
  static const eater = PartE.eater;
  static const eaterTextTheme = PartE.eaterTextTheme;
  static const economica = PartE.economica;
  static const economicaTextTheme = PartE.economicaTextTheme;
  static const eczar = PartE.eczar;
  static const eczarTextTheme = PartE.eczarTextTheme;
  static const eduAuVicWaNtHand = PartE.eduAuVicWaNtHand;
  static const eduAuVicWaNtHandTextTheme = PartE.eduAuVicWaNtHandTextTheme;
  static const eduNswActFoundation = PartE.eduNswActFoundation;
  static const eduNswActFoundationTextTheme =
      PartE.eduNswActFoundationTextTheme;
  static const eduQldBeginner = PartE.eduQldBeginner;
  static const eduQldBeginnerTextTheme = PartE.eduQldBeginnerTextTheme;
  static const eduSaBeginner = PartE.eduSaBeginner;
  static const eduSaBeginnerTextTheme = PartE.eduSaBeginnerTextTheme;
  static const eduTasBeginner = PartE.eduTasBeginner;
  static const eduTasBeginnerTextTheme = PartE.eduTasBeginnerTextTheme;
  static const eduVicWaNtBeginner = PartE.eduVicWaNtBeginner;
  static const eduVicWaNtBeginnerTextTheme = PartE.eduVicWaNtBeginnerTextTheme;
  static const elMessiri = PartE.elMessiri;
  static const elMessiriTextTheme = PartE.elMessiriTextTheme;
  static const electrolize = PartE.electrolize;
  static const electrolizeTextTheme = PartE.electrolizeTextTheme;
  static const elsie = PartE.elsie;
  static const elsieTextTheme = PartE.elsieTextTheme;
  static const elsieSwashCaps = PartE.elsieSwashCaps;
  static const elsieSwashCapsTextTheme = PartE.elsieSwashCapsTextTheme;
  static const emblemaOne = PartE.emblemaOne;
  static const emblemaOneTextTheme = PartE.emblemaOneTextTheme;
  static const emilysCandy = PartE.emilysCandy;
  static const emilysCandyTextTheme = PartE.emilysCandyTextTheme;
  static const encodeSans = PartE.encodeSans;
  static const encodeSansTextTheme = PartE.encodeSansTextTheme;
  static const encodeSansCondensed = PartE.encodeSansCondensed;
  static const encodeSansCondensedTextTheme =
      PartE.encodeSansCondensedTextTheme;
  static const encodeSansExpanded = PartE.encodeSansExpanded;
  static const encodeSansExpandedTextTheme = PartE.encodeSansExpandedTextTheme;
  static const encodeSansSc = PartE.encodeSansSc;
  static const encodeSansScTextTheme = PartE.encodeSansScTextTheme;
  static const encodeSansSemiCondensed = PartE.encodeSansSemiCondensed;
  static const encodeSansSemiCondensedTextTheme =
      PartE.encodeSansSemiCondensedTextTheme;
  static const encodeSansSemiExpanded = PartE.encodeSansSemiExpanded;
  static const encodeSansSemiExpandedTextTheme =
      PartE.encodeSansSemiExpandedTextTheme;
  static const engagement = PartE.engagement;
  static const engagementTextTheme = PartE.engagementTextTheme;
  static const englebert = PartE.englebert;
  static const englebertTextTheme = PartE.englebertTextTheme;
  static const enriqueta = PartE.enriqueta;
  static const enriquetaTextTheme = PartE.enriquetaTextTheme;
  static const ephesis = PartE.ephesis;
  static const ephesisTextTheme = PartE.ephesisTextTheme;
  static const epilogue = PartE.epilogue;
  static const epilogueTextTheme = PartE.epilogueTextTheme;
  static const ericaOne = PartE.ericaOne;
  static const ericaOneTextTheme = PartE.ericaOneTextTheme;
  static const esteban = PartE.esteban;
  static const estebanTextTheme = PartE.estebanTextTheme;
  static const estonia = PartE.estonia;
  static const estoniaTextTheme = PartE.estoniaTextTheme;
  static const euphoriaScript = PartE.euphoriaScript;
  static const euphoriaScriptTextTheme = PartE.euphoriaScriptTextTheme;
  static const ewert = PartE.ewert;
  static const ewertTextTheme = PartE.ewertTextTheme;
  static const exo = PartE.exo;
  static const exoTextTheme = PartE.exoTextTheme;
  static const exo2 = PartE.exo2;
  static const exo2TextTheme = PartE.exo2TextTheme;
  static const expletusSans = PartE.expletusSans;
  static const expletusSansTextTheme = PartE.expletusSansTextTheme;
  static const explora = PartE.explora;
  static const exploraTextTheme = PartE.exploraTextTheme;
  static const fahkwang = PartF.fahkwang;
  static const fahkwangTextTheme = PartF.fahkwangTextTheme;
  static const familjenGrotesk = PartF.familjenGrotesk;
  static const familjenGroteskTextTheme = PartF.familjenGroteskTextTheme;
  static const fanwoodText = PartF.fanwoodText;
  static const fanwoodTextTextTheme = PartF.fanwoodTextTextTheme;
  static const farro = PartF.farro;
  static const farroTextTheme = PartF.farroTextTheme;
  static const farsan = PartF.farsan;
  static const farsanTextTheme = PartF.farsanTextTheme;
  static const fascinate = PartF.fascinate;
  static const fascinateTextTheme = PartF.fascinateTextTheme;
  static const fascinateInline = PartF.fascinateInline;
  static const fascinateInlineTextTheme = PartF.fascinateInlineTextTheme;
  static const fasterOne = PartF.fasterOne;
  static const fasterOneTextTheme = PartF.fasterOneTextTheme;
  static const fasthand = PartF.fasthand;
  static const fasthandTextTheme = PartF.fasthandTextTheme;
  static const faunaOne = PartF.faunaOne;
  static const faunaOneTextTheme = PartF.faunaOneTextTheme;
  static const faustina = PartF.faustina;
  static const faustinaTextTheme = PartF.faustinaTextTheme;
  static const federant = PartF.federant;
  static const federantTextTheme = PartF.federantTextTheme;
  static const federo = PartF.federo;
  static const federoTextTheme = PartF.federoTextTheme;
  static const felipa = PartF.felipa;
  static const felipaTextTheme = PartF.felipaTextTheme;
  static const fenix = PartF.fenix;
  static const fenixTextTheme = PartF.fenixTextTheme;
  static const festive = PartF.festive;
  static const festiveTextTheme = PartF.festiveTextTheme;
  static const figtree = PartF.figtree;
  static const figtreeTextTheme = PartF.figtreeTextTheme;
  static const fingerPaint = PartF.fingerPaint;
  static const fingerPaintTextTheme = PartF.fingerPaintTextTheme;
  static const finlandica = PartF.finlandica;
  static const finlandicaTextTheme = PartF.finlandicaTextTheme;
  static const firaCode = PartF.firaCode;
  static const firaCodeTextTheme = PartF.firaCodeTextTheme;
  static const firaMono = PartF.firaMono;
  static const firaMonoTextTheme = PartF.firaMonoTextTheme;
  static const firaSans = PartF.firaSans;
  static const firaSansTextTheme = PartF.firaSansTextTheme;
  static const firaSansCondensed = PartF.firaSansCondensed;
  static const firaSansCondensedTextTheme = PartF.firaSansCondensedTextTheme;
  static const firaSansExtraCondensed = PartF.firaSansExtraCondensed;
  static const firaSansExtraCondensedTextTheme =
      PartF.firaSansExtraCondensedTextTheme;
  static const fjallaOne = PartF.fjallaOne;
  static const fjallaOneTextTheme = PartF.fjallaOneTextTheme;
  static const fjordOne = PartF.fjordOne;
  static const fjordOneTextTheme = PartF.fjordOneTextTheme;
  static const flamenco = PartF.flamenco;
  static const flamencoTextTheme = PartF.flamencoTextTheme;
  static const flavors = PartF.flavors;
  static const flavorsTextTheme = PartF.flavorsTextTheme;
  static const fleurDeLeah = PartF.fleurDeLeah;
  static const fleurDeLeahTextTheme = PartF.fleurDeLeahTextTheme;
  static const flowBlock = PartF.flowBlock;
  static const flowBlockTextTheme = PartF.flowBlockTextTheme;
  static const flowCircular = PartF.flowCircular;
  static const flowCircularTextTheme = PartF.flowCircularTextTheme;
  static const flowRounded = PartF.flowRounded;
  static const flowRoundedTextTheme = PartF.flowRoundedTextTheme;
  static const foldit = PartF.foldit;
  static const folditTextTheme = PartF.folditTextTheme;
  static const fondamento = PartF.fondamento;
  static const fondamentoTextTheme = PartF.fondamentoTextTheme;
  static const fontdinerSwanky = PartF.fontdinerSwanky;
  static const fontdinerSwankyTextTheme = PartF.fontdinerSwankyTextTheme;
  static const forum = PartF.forum;
  static const forumTextTheme = PartF.forumTextTheme;
  static const fragmentMono = PartF.fragmentMono;
  static const fragmentMonoTextTheme = PartF.fragmentMonoTextTheme;
  static const francoisOne = PartF.francoisOne;
  static const francoisOneTextTheme = PartF.francoisOneTextTheme;
  static const frankRuhlLibre = PartF.frankRuhlLibre;
  static const frankRuhlLibreTextTheme = PartF.frankRuhlLibreTextTheme;
  static const fraunces = PartF.fraunces;
  static const frauncesTextTheme = PartF.frauncesTextTheme;
  static const freckleFace = PartF.freckleFace;
  static const freckleFaceTextTheme = PartF.freckleFaceTextTheme;
  static const frederickaTheGreat = PartF.frederickaTheGreat;
  static const frederickaTheGreatTextTheme = PartF.frederickaTheGreatTextTheme;
  static const fredoka = PartF.fredoka;
  static const fredokaTextTheme = PartF.fredokaTextTheme;
  static const freehand = PartF.freehand;
  static const freehandTextTheme = PartF.freehandTextTheme;
  static const freeman = PartF.freeman;
  static const freemanTextTheme = PartF.freemanTextTheme;
  static const fresca = PartF.fresca;
  static const frescaTextTheme = PartF.frescaTextTheme;
  static const frijole = PartF.frijole;
  static const frijoleTextTheme = PartF.frijoleTextTheme;
  static const fruktur = PartF.fruktur;
  static const frukturTextTheme = PartF.frukturTextTheme;
  static const fugazOne = PartF.fugazOne;
  static const fugazOneTextTheme = PartF.fugazOneTextTheme;
  static const fuggles = PartF.fuggles;
  static const fugglesTextTheme = PartF.fugglesTextTheme;
  static const fustat = PartF.fustat;
  static const fustatTextTheme = PartF.fustatTextTheme;
  static const fuzzyBubbles = PartF.fuzzyBubbles;
  static const fuzzyBubblesTextTheme = PartF.fuzzyBubblesTextTheme;
  static const gfsDidot = PartG.gfsDidot;
  static const gfsDidotTextTheme = PartG.gfsDidotTextTheme;
  static const gfsNeohellenic = PartG.gfsNeohellenic;
  static const gfsNeohellenicTextTheme = PartG.gfsNeohellenicTextTheme;
  static const gaMaamli = PartG.gaMaamli;
  static const gaMaamliTextTheme = PartG.gaMaamliTextTheme;
  static const gabarito = PartG.gabarito;
  static const gabaritoTextTheme = PartG.gabaritoTextTheme;
  static const gabriela = PartG.gabriela;
  static const gabrielaTextTheme = PartG.gabrielaTextTheme;
  static const gaegu = PartG.gaegu;
  static const gaeguTextTheme = PartG.gaeguTextTheme;
  static const gafata = PartG.gafata;
  static const gafataTextTheme = PartG.gafataTextTheme;
  static const gajrajOne = PartG.gajrajOne;
  static const gajrajOneTextTheme = PartG.gajrajOneTextTheme;
  static const galada = PartG.galada;
  static const galadaTextTheme = PartG.galadaTextTheme;
  static const galdeano = PartG.galdeano;
  static const galdeanoTextTheme = PartG.galdeanoTextTheme;
  static const galindo = PartG.galindo;
  static const galindoTextTheme = PartG.galindoTextTheme;
  static const gamjaFlower = PartG.gamjaFlower;
  static const gamjaFlowerTextTheme = PartG.gamjaFlowerTextTheme;
  static const gantari = PartG.gantari;
  static const gantariTextTheme = PartG.gantariTextTheme;
  static const gasoekOne = PartG.gasoekOne;
  static const gasoekOneTextTheme = PartG.gasoekOneTextTheme;
  static const gayathri = PartG.gayathri;
  static const gayathriTextTheme = PartG.gayathriTextTheme;
  static const gelasio = PartG.gelasio;
  static const gelasioTextTheme = PartG.gelasioTextTheme;
  static const gemunuLibre = PartG.gemunuLibre;
  static const gemunuLibreTextTheme = PartG.gemunuLibreTextTheme;
  static const genos = PartG.genos;
  static const genosTextTheme = PartG.genosTextTheme;
  static const gentiumBookPlus = PartG.gentiumBookPlus;
  static const gentiumBookPlusTextTheme = PartG.gentiumBookPlusTextTheme;
  static const gentiumPlus = PartG.gentiumPlus;
  static const gentiumPlusTextTheme = PartG.gentiumPlusTextTheme;
  static const geo = PartG.geo;
  static const geoTextTheme = PartG.geoTextTheme;
  static const geologica = PartG.geologica;
  static const geologicaTextTheme = PartG.geologicaTextTheme;
  static const georama = PartG.georama;
  static const georamaTextTheme = PartG.georamaTextTheme;
  static const geostar = PartG.geostar;
  static const geostarTextTheme = PartG.geostarTextTheme;
  static const geostarFill = PartG.geostarFill;
  static const geostarFillTextTheme = PartG.geostarFillTextTheme;
  static const germaniaOne = PartG.germaniaOne;
  static const germaniaOneTextTheme = PartG.germaniaOneTextTheme;
  static const gideonRoman = PartG.gideonRoman;
  static const gideonRomanTextTheme = PartG.gideonRomanTextTheme;
  static const gidugu = PartG.gidugu;
  static const giduguTextTheme = PartG.giduguTextTheme;
  static const gildaDisplay = PartG.gildaDisplay;
  static const gildaDisplayTextTheme = PartG.gildaDisplayTextTheme;
  static const girassol = PartG.girassol;
  static const girassolTextTheme = PartG.girassolTextTheme;
  static const giveYouGlory = PartG.giveYouGlory;
  static const giveYouGloryTextTheme = PartG.giveYouGloryTextTheme;
  static const glassAntiqua = PartG.glassAntiqua;
  static const glassAntiquaTextTheme = PartG.glassAntiquaTextTheme;
  static const glegoo = PartG.glegoo;
  static const glegooTextTheme = PartG.glegooTextTheme;
  static const gloock = PartG.gloock;
  static const gloockTextTheme = PartG.gloockTextTheme;
  static const gloriaHallelujah = PartG.gloriaHallelujah;
  static const gloriaHallelujahTextTheme = PartG.gloriaHallelujahTextTheme;
  static const glory = PartG.glory;
  static const gloryTextTheme = PartG.gloryTextTheme;
  static const gluten = PartG.gluten;
  static const glutenTextTheme = PartG.glutenTextTheme;
  static const goblinOne = PartG.goblinOne;
  static const goblinOneTextTheme = PartG.goblinOneTextTheme;
  static const gochiHand = PartG.gochiHand;
  static const gochiHandTextTheme = PartG.gochiHandTextTheme;
  static const goldman = PartG.goldman;
  static const goldmanTextTheme = PartG.goldmanTextTheme;
  static const golosText = PartG.golosText;
  static const golosTextTextTheme = PartG.golosTextTextTheme;
  static const gorditas = PartG.gorditas;
  static const gorditasTextTheme = PartG.gorditasTextTheme;
  static const gothicA1 = PartG.gothicA1;
  static const gothicA1TextTheme = PartG.gothicA1TextTheme;
  static const gotu = PartG.gotu;
  static const gotuTextTheme = PartG.gotuTextTheme;
  static const goudyBookletter1911 = PartG.goudyBookletter1911;
  static const goudyBookletter1911TextTheme =
      PartG.goudyBookletter1911TextTheme;
  static const gowunBatang = PartG.gowunBatang;
  static const gowunBatangTextTheme = PartG.gowunBatangTextTheme;
  static const gowunDodum = PartG.gowunDodum;
  static const gowunDodumTextTheme = PartG.gowunDodumTextTheme;
  static const graduate = PartG.graduate;
  static const graduateTextTheme = PartG.graduateTextTheme;
  static const grandHotel = PartG.grandHotel;
  static const grandHotelTextTheme = PartG.grandHotelTextTheme;
  static const grandifloraOne = PartG.grandifloraOne;
  static const grandifloraOneTextTheme = PartG.grandifloraOneTextTheme;
  static const grandstander = PartG.grandstander;
  static const grandstanderTextTheme = PartG.grandstanderTextTheme;
  static const grapeNuts = PartG.grapeNuts;
  static const grapeNutsTextTheme = PartG.grapeNutsTextTheme;
  static const gravitasOne = PartG.gravitasOne;
  static const gravitasOneTextTheme = PartG.gravitasOneTextTheme;
  static const greatVibes = PartG.greatVibes;
  static const greatVibesTextTheme = PartG.greatVibesTextTheme;
  static const grechenFuemen = PartG.grechenFuemen;
  static const grechenFuemenTextTheme = PartG.grechenFuemenTextTheme;
  static const grenze = PartG.grenze;
  static const grenzeTextTheme = PartG.grenzeTextTheme;
  static const grenzeGotisch = PartG.grenzeGotisch;
  static const grenzeGotischTextTheme = PartG.grenzeGotischTextTheme;
  static const greyQo = PartG.greyQo;
  static const greyQoTextTheme = PartG.greyQoTextTheme;
  static const griffy = PartG.griffy;
  static const griffyTextTheme = PartG.griffyTextTheme;
  static const gruppo = PartG.gruppo;
  static const gruppoTextTheme = PartG.gruppoTextTheme;
  static const gudea = PartG.gudea;
  static const gudeaTextTheme = PartG.gudeaTextTheme;
  static const gugi = PartG.gugi;
  static const gugiTextTheme = PartG.gugiTextTheme;
  static const gulzar = PartG.gulzar;
  static const gulzarTextTheme = PartG.gulzarTextTheme;
  static const gupter = PartG.gupter;
  static const gupterTextTheme = PartG.gupterTextTheme;
  static const gurajada = PartG.gurajada;
  static const gurajadaTextTheme = PartG.gurajadaTextTheme;
  static const gwendolyn = PartG.gwendolyn;
  static const gwendolynTextTheme = PartG.gwendolynTextTheme;
  static const habibi = PartH.habibi;
  static const habibiTextTheme = PartH.habibiTextTheme;
  static const hachiMaruPop = PartH.hachiMaruPop;
  static const hachiMaruPopTextTheme = PartH.hachiMaruPopTextTheme;
  static const hahmlet = PartH.hahmlet;
  static const hahmletTextTheme = PartH.hahmletTextTheme;
  static const halant = PartH.halant;
  static const halantTextTheme = PartH.halantTextTheme;
  static const hammersmithOne = PartH.hammersmithOne;
  static const hammersmithOneTextTheme = PartH.hammersmithOneTextTheme;
  static const hanalei = PartH.hanalei;
  static const hanaleiTextTheme = PartH.hanaleiTextTheme;
  static const hanaleiFill = PartH.hanaleiFill;
  static const hanaleiFillTextTheme = PartH.hanaleiFillTextTheme;
  static const handjet = PartH.handjet;
  static const handjetTextTheme = PartH.handjetTextTheme;
  static const handlee = PartH.handlee;
  static const handleeTextTheme = PartH.handleeTextTheme;
  static const hankenGrotesk = PartH.hankenGrotesk;
  static const hankenGroteskTextTheme = PartH.hankenGroteskTextTheme;
  static const hanuman = PartH.hanuman;
  static const hanumanTextTheme = PartH.hanumanTextTheme;
  static const happyMonkey = PartH.happyMonkey;
  static const happyMonkeyTextTheme = PartH.happyMonkeyTextTheme;
  static const harmattan = PartH.harmattan;
  static const harmattanTextTheme = PartH.harmattanTextTheme;
  static const headlandOne = PartH.headlandOne;
  static const headlandOneTextTheme = PartH.headlandOneTextTheme;
  static const hedvigLettersSans = PartH.hedvigLettersSans;
  static const hedvigLettersSansTextTheme = PartH.hedvigLettersSansTextTheme;
  static const hedvigLettersSerif = PartH.hedvigLettersSerif;
  static const hedvigLettersSerifTextTheme = PartH.hedvigLettersSerifTextTheme;
  static const heebo = PartH.heebo;
  static const heeboTextTheme = PartH.heeboTextTheme;
  static const hennyPenny = PartH.hennyPenny;
  static const hennyPennyTextTheme = PartH.hennyPennyTextTheme;
  static const heptaSlab = PartH.heptaSlab;
  static const heptaSlabTextTheme = PartH.heptaSlabTextTheme;
  static const herrVonMuellerhoff = PartH.herrVonMuellerhoff;
  static const herrVonMuellerhoffTextTheme = PartH.herrVonMuellerhoffTextTheme;
  static const hiMelody = PartH.hiMelody;
  static const hiMelodyTextTheme = PartH.hiMelodyTextTheme;
  static const hinaMincho = PartH.hinaMincho;
  static const hinaMinchoTextTheme = PartH.hinaMinchoTextTheme;
  static const hind = PartH.hind;
  static const hindTextTheme = PartH.hindTextTheme;
  static const hindGuntur = PartH.hindGuntur;
  static const hindGunturTextTheme = PartH.hindGunturTextTheme;
  static const hindMadurai = PartH.hindMadurai;
  static const hindMaduraiTextTheme = PartH.hindMaduraiTextTheme;
  static const hindSiliguri = PartH.hindSiliguri;
  static const hindSiliguriTextTheme = PartH.hindSiliguriTextTheme;
  static const hindVadodara = PartH.hindVadodara;
  static const hindVadodaraTextTheme = PartH.hindVadodaraTextTheme;
  static const holtwoodOneSc = PartH.holtwoodOneSc;
  static const holtwoodOneScTextTheme = PartH.holtwoodOneScTextTheme;
  static const homemadeApple = PartH.homemadeApple;
  static const homemadeAppleTextTheme = PartH.homemadeAppleTextTheme;
  static const homenaje = PartH.homenaje;
  static const homenajeTextTheme = PartH.homenajeTextTheme;
  static const honk = PartH.honk;
  static const honkTextTheme = PartH.honkTextTheme;
  static const hubballi = PartH.hubballi;
  static const hubballiTextTheme = PartH.hubballiTextTheme;
  static const hurricane = PartH.hurricane;
  static const hurricaneTextTheme = PartH.hurricaneTextTheme;
  static const ibmPlexMono = PartI.ibmPlexMono;
  static const ibmPlexMonoTextTheme = PartI.ibmPlexMonoTextTheme;
  static const ibmPlexSans = PartI.ibmPlexSans;
  static const ibmPlexSansTextTheme = PartI.ibmPlexSansTextTheme;
  static const ibmPlexSansArabic = PartI.ibmPlexSansArabic;
  static const ibmPlexSansArabicTextTheme = PartI.ibmPlexSansArabicTextTheme;
  static const ibmPlexSansCondensed = PartI.ibmPlexSansCondensed;
  static const ibmPlexSansCondensedTextTheme =
      PartI.ibmPlexSansCondensedTextTheme;
  static const ibmPlexSansDevanagari = PartI.ibmPlexSansDevanagari;
  static const ibmPlexSansDevanagariTextTheme =
      PartI.ibmPlexSansDevanagariTextTheme;
  static const ibmPlexSansHebrew = PartI.ibmPlexSansHebrew;
  static const ibmPlexSansHebrewTextTheme = PartI.ibmPlexSansHebrewTextTheme;
  static const ibmPlexSansJp = PartI.ibmPlexSansJp;
  static const ibmPlexSansJpTextTheme = PartI.ibmPlexSansJpTextTheme;
  static const ibmPlexSansKr = PartI.ibmPlexSansKr;
  static const ibmPlexSansKrTextTheme = PartI.ibmPlexSansKrTextTheme;
  static const ibmPlexSansThai = PartI.ibmPlexSansThai;
  static const ibmPlexSansThaiTextTheme = PartI.ibmPlexSansThaiTextTheme;
  static const ibmPlexSansThaiLooped = PartI.ibmPlexSansThaiLooped;
  static const ibmPlexSansThaiLoopedTextTheme =
      PartI.ibmPlexSansThaiLoopedTextTheme;
  static const ibmPlexSerif = PartI.ibmPlexSerif;
  static const ibmPlexSerifTextTheme = PartI.ibmPlexSerifTextTheme;
  static const imFellDwPica = PartI.imFellDwPica;
  static const imFellDwPicaTextTheme = PartI.imFellDwPicaTextTheme;
  static const imFellDwPicaSc = PartI.imFellDwPicaSc;
  static const imFellDwPicaScTextTheme = PartI.imFellDwPicaScTextTheme;
  static const imFellDoublePica = PartI.imFellDoublePica;
  static const imFellDoublePicaTextTheme = PartI.imFellDoublePicaTextTheme;
  static const imFellDoublePicaSc = PartI.imFellDoublePicaSc;
  static const imFellDoublePicaScTextTheme = PartI.imFellDoublePicaScTextTheme;
  static const imFellEnglish = PartI.imFellEnglish;
  static const imFellEnglishTextTheme = PartI.imFellEnglishTextTheme;
  static const imFellEnglishSc = PartI.imFellEnglishSc;
  static const imFellEnglishScTextTheme = PartI.imFellEnglishScTextTheme;
  static const imFellFrenchCanon = PartI.imFellFrenchCanon;
  static const imFellFrenchCanonTextTheme = PartI.imFellFrenchCanonTextTheme;
  static const imFellFrenchCanonSc = PartI.imFellFrenchCanonSc;
  static const imFellFrenchCanonScTextTheme =
      PartI.imFellFrenchCanonScTextTheme;
  static const imFellGreatPrimer = PartI.imFellGreatPrimer;
  static const imFellGreatPrimerTextTheme = PartI.imFellGreatPrimerTextTheme;
  static const imFellGreatPrimerSc = PartI.imFellGreatPrimerSc;
  static const imFellGreatPrimerScTextTheme =
      PartI.imFellGreatPrimerScTextTheme;
  static const ibarraRealNova = PartI.ibarraRealNova;
  static const ibarraRealNovaTextTheme = PartI.ibarraRealNovaTextTheme;
  static const iceberg = PartI.iceberg;
  static const icebergTextTheme = PartI.icebergTextTheme;
  static const iceland = PartI.iceland;
  static const icelandTextTheme = PartI.icelandTextTheme;
  static const imbue = PartI.imbue;
  static const imbueTextTheme = PartI.imbueTextTheme;
  static const imperialScript = PartI.imperialScript;
  static const imperialScriptTextTheme = PartI.imperialScriptTextTheme;
  static const imprima = PartI.imprima;
  static const imprimaTextTheme = PartI.imprimaTextTheme;
  static const inclusiveSans = PartI.inclusiveSans;
  static const inclusiveSansTextTheme = PartI.inclusiveSansTextTheme;
  static const inconsolata = PartI.inconsolata;
  static const inconsolataTextTheme = PartI.inconsolataTextTheme;
  static const inder = PartI.inder;
  static const inderTextTheme = PartI.inderTextTheme;
  static const indieFlower = PartI.indieFlower;
  static const indieFlowerTextTheme = PartI.indieFlowerTextTheme;
  static const ingridDarling = PartI.ingridDarling;
  static const ingridDarlingTextTheme = PartI.ingridDarlingTextTheme;
  static const inika = PartI.inika;
  static const inikaTextTheme = PartI.inikaTextTheme;
  static const inknutAntiqua = PartI.inknutAntiqua;
  static const inknutAntiquaTextTheme = PartI.inknutAntiquaTextTheme;
  static const inriaSans = PartI.inriaSans;
  static const inriaSansTextTheme = PartI.inriaSansTextTheme;
  static const inriaSerif = PartI.inriaSerif;
  static const inriaSerifTextTheme = PartI.inriaSerifTextTheme;
  static const inspiration = PartI.inspiration;
  static const inspirationTextTheme = PartI.inspirationTextTheme;
  static const instrumentSans = PartI.instrumentSans;
  static const instrumentSansTextTheme = PartI.instrumentSansTextTheme;
  static const instrumentSerif = PartI.instrumentSerif;
  static const instrumentSerifTextTheme = PartI.instrumentSerifTextTheme;
  static const inter = PartI.inter;
  static const interTextTheme = PartI.interTextTheme;
  static const interTight = PartI.interTight;
  static const interTightTextTheme = PartI.interTightTextTheme;
  static const irishGrover = PartI.irishGrover;
  static const irishGroverTextTheme = PartI.irishGroverTextTheme;
  static const islandMoments = PartI.islandMoments;
  static const islandMomentsTextTheme = PartI.islandMomentsTextTheme;
  static const istokWeb = PartI.istokWeb;
  static const istokWebTextTheme = PartI.istokWebTextTheme;
  static const italiana = PartI.italiana;
  static const italianaTextTheme = PartI.italianaTextTheme;
  static const italianno = PartI.italianno;
  static const italiannoTextTheme = PartI.italiannoTextTheme;
  static const itim = PartI.itim;
  static const itimTextTheme = PartI.itimTextTheme;
  static const jacquard12 = PartJ.jacquard12;
  static const jacquard12TextTheme = PartJ.jacquard12TextTheme;
  static const jacquard12Charted = PartJ.jacquard12Charted;
  static const jacquard12ChartedTextTheme = PartJ.jacquard12ChartedTextTheme;
  static const jacquard24 = PartJ.jacquard24;
  static const jacquard24TextTheme = PartJ.jacquard24TextTheme;
  static const jacquard24Charted = PartJ.jacquard24Charted;
  static const jacquard24ChartedTextTheme = PartJ.jacquard24ChartedTextTheme;
  static const jacquardaBastarda9 = PartJ.jacquardaBastarda9;
  static const jacquardaBastarda9TextTheme = PartJ.jacquardaBastarda9TextTheme;
  static const jacquardaBastarda9Charted = PartJ.jacquardaBastarda9Charted;
  static const jacquardaBastarda9ChartedTextTheme =
      PartJ.jacquardaBastarda9ChartedTextTheme;
  static const jacquesFrancois = PartJ.jacquesFrancois;
  static const jacquesFrancoisTextTheme = PartJ.jacquesFrancoisTextTheme;
  static const jacquesFrancoisShadow = PartJ.jacquesFrancoisShadow;
  static const jacquesFrancoisShadowTextTheme =
      PartJ.jacquesFrancoisShadowTextTheme;
  static const jaini = PartJ.jaini;
  static const jainiTextTheme = PartJ.jainiTextTheme;
  static const jainiPurva = PartJ.jainiPurva;
  static const jainiPurvaTextTheme = PartJ.jainiPurvaTextTheme;
  static const jaldi = PartJ.jaldi;
  static const jaldiTextTheme = PartJ.jaldiTextTheme;
  static const jaro = PartJ.jaro;
  static const jaroTextTheme = PartJ.jaroTextTheme;
  static const jersey10 = PartJ.jersey10;
  static const jersey10TextTheme = PartJ.jersey10TextTheme;
  static const jersey10Charted = PartJ.jersey10Charted;
  static const jersey10ChartedTextTheme = PartJ.jersey10ChartedTextTheme;
  static const jersey15 = PartJ.jersey15;
  static const jersey15TextTheme = PartJ.jersey15TextTheme;
  static const jersey15Charted = PartJ.jersey15Charted;
  static const jersey15ChartedTextTheme = PartJ.jersey15ChartedTextTheme;
  static const jersey20 = PartJ.jersey20;
  static const jersey20TextTheme = PartJ.jersey20TextTheme;
  static const jersey20Charted = PartJ.jersey20Charted;
  static const jersey20ChartedTextTheme = PartJ.jersey20ChartedTextTheme;
  static const jersey25 = PartJ.jersey25;
  static const jersey25TextTheme = PartJ.jersey25TextTheme;
  static const jersey25Charted = PartJ.jersey25Charted;
  static const jersey25ChartedTextTheme = PartJ.jersey25ChartedTextTheme;
  static const jetBrainsMono = PartJ.jetBrainsMono;
  static const jetBrainsMonoTextTheme = PartJ.jetBrainsMonoTextTheme;
  static const jimNightshade = PartJ.jimNightshade;
  static const jimNightshadeTextTheme = PartJ.jimNightshadeTextTheme;
  static const joan = PartJ.joan;
  static const joanTextTheme = PartJ.joanTextTheme;
  static const jockeyOne = PartJ.jockeyOne;
  static const jockeyOneTextTheme = PartJ.jockeyOneTextTheme;
  static const jollyLodger = PartJ.jollyLodger;
  static const jollyLodgerTextTheme = PartJ.jollyLodgerTextTheme;
  static const jomhuria = PartJ.jomhuria;
  static const jomhuriaTextTheme = PartJ.jomhuriaTextTheme;
  static const jomolhari = PartJ.jomolhari;
  static const jomolhariTextTheme = PartJ.jomolhariTextTheme;
  static const josefinSans = PartJ.josefinSans;
  static const josefinSansTextTheme = PartJ.josefinSansTextTheme;
  static const josefinSlab = PartJ.josefinSlab;
  static const josefinSlabTextTheme = PartJ.josefinSlabTextTheme;
  static const jost = PartJ.jost;
  static const jostTextTheme = PartJ.jostTextTheme;
  static const jotiOne = PartJ.jotiOne;
  static const jotiOneTextTheme = PartJ.jotiOneTextTheme;
  static const jua = PartJ.jua;
  static const juaTextTheme = PartJ.juaTextTheme;
  static const judson = PartJ.judson;
  static const judsonTextTheme = PartJ.judsonTextTheme;
  static const julee = PartJ.julee;
  static const juleeTextTheme = PartJ.juleeTextTheme;
  static const juliusSansOne = PartJ.juliusSansOne;
  static const juliusSansOneTextTheme = PartJ.juliusSansOneTextTheme;
  static const junge = PartJ.junge;
  static const jungeTextTheme = PartJ.jungeTextTheme;
  static const jura = PartJ.jura;
  static const juraTextTheme = PartJ.juraTextTheme;
  static const justAnotherHand = PartJ.justAnotherHand;
  static const justAnotherHandTextTheme = PartJ.justAnotherHandTextTheme;
  static const justMeAgainDownHere = PartJ.justMeAgainDownHere;
  static const justMeAgainDownHereTextTheme =
      PartJ.justMeAgainDownHereTextTheme;
  static const k2d = PartK.k2d;
  static const k2dTextTheme = PartK.k2dTextTheme;
  static const kablammo = PartK.kablammo;
  static const kablammoTextTheme = PartK.kablammoTextTheme;
  static const kadwa = PartK.kadwa;
  static const kadwaTextTheme = PartK.kadwaTextTheme;
  static const kaiseiDecol = PartK.kaiseiDecol;
  static const kaiseiDecolTextTheme = PartK.kaiseiDecolTextTheme;
  static const kaiseiHarunoUmi = PartK.kaiseiHarunoUmi;
  static const kaiseiHarunoUmiTextTheme = PartK.kaiseiHarunoUmiTextTheme;
  static const kaiseiOpti = PartK.kaiseiOpti;
  static const kaiseiOptiTextTheme = PartK.kaiseiOptiTextTheme;
  static const kaiseiTokumin = PartK.kaiseiTokumin;
  static const kaiseiTokuminTextTheme = PartK.kaiseiTokuminTextTheme;
  static const kalam = PartK.kalam;
  static const kalamTextTheme = PartK.kalamTextTheme;
  static const kalnia = PartK.kalnia;
  static const kalniaTextTheme = PartK.kalniaTextTheme;
  static const kalniaGlaze = PartK.kalniaGlaze;
  static const kalniaGlazeTextTheme = PartK.kalniaGlazeTextTheme;
  static const kameron = PartK.kameron;
  static const kameronTextTheme = PartK.kameronTextTheme;
  static const kanit = PartK.kanit;
  static const kanitTextTheme = PartK.kanitTextTheme;
  static const kantumruyPro = PartK.kantumruyPro;
  static const kantumruyProTextTheme = PartK.kantumruyProTextTheme;
  static const karantina = PartK.karantina;
  static const karantinaTextTheme = PartK.karantinaTextTheme;
  static const karla = PartK.karla;
  static const karlaTextTheme = PartK.karlaTextTheme;
  static const karma = PartK.karma;
  static const karmaTextTheme = PartK.karmaTextTheme;
  static const katibeh = PartK.katibeh;
  static const katibehTextTheme = PartK.katibehTextTheme;
  static const kaushanScript = PartK.kaushanScript;
  static const kaushanScriptTextTheme = PartK.kaushanScriptTextTheme;
  static const kavivanar = PartK.kavivanar;
  static const kavivanarTextTheme = PartK.kavivanarTextTheme;
  static const kavoon = PartK.kavoon;
  static const kavoonTextTheme = PartK.kavoonTextTheme;
  static const kayPhoDu = PartK.kayPhoDu;
  static const kayPhoDuTextTheme = PartK.kayPhoDuTextTheme;
  static const kdamThmorPro = PartK.kdamThmorPro;
  static const kdamThmorProTextTheme = PartK.kdamThmorProTextTheme;
  static const keaniaOne = PartK.keaniaOne;
  static const keaniaOneTextTheme = PartK.keaniaOneTextTheme;
  static const kellySlab = PartK.kellySlab;
  static const kellySlabTextTheme = PartK.kellySlabTextTheme;
  static const kenia = PartK.kenia;
  static const keniaTextTheme = PartK.keniaTextTheme;
  static const khand = PartK.khand;
  static const khandTextTheme = PartK.khandTextTheme;
  static const khmer = PartK.khmer;
  static const khmerTextTheme = PartK.khmerTextTheme;
  static const khula = PartK.khula;
  static const khulaTextTheme = PartK.khulaTextTheme;
  static const kings = PartK.kings;
  static const kingsTextTheme = PartK.kingsTextTheme;
  static const kirangHaerang = PartK.kirangHaerang;
  static const kirangHaerangTextTheme = PartK.kirangHaerangTextTheme;
  static const kiteOne = PartK.kiteOne;
  static const kiteOneTextTheme = PartK.kiteOneTextTheme;
  static const kiwiMaru = PartK.kiwiMaru;
  static const kiwiMaruTextTheme = PartK.kiwiMaruTextTheme;
  static const kleeOne = PartK.kleeOne;
  static const kleeOneTextTheme = PartK.kleeOneTextTheme;
  static const knewave = PartK.knewave;
  static const knewaveTextTheme = PartK.knewaveTextTheme;
  static const koHo = PartK.koHo;
  static const koHoTextTheme = PartK.koHoTextTheme;
  static const kodchasan = PartK.kodchasan;
  static const kodchasanTextTheme = PartK.kodchasanTextTheme;
  static const kodeMono = PartK.kodeMono;
  static const kodeMonoTextTheme = PartK.kodeMonoTextTheme;
  static const kohSantepheap = PartK.kohSantepheap;
  static const kohSantepheapTextTheme = PartK.kohSantepheapTextTheme;
  static const kolkerBrush = PartK.kolkerBrush;
  static const kolkerBrushTextTheme = PartK.kolkerBrushTextTheme;
  static const konkhmerSleokchher = PartK.konkhmerSleokchher;
  static const konkhmerSleokchherTextTheme = PartK.konkhmerSleokchherTextTheme;
  static const kosugi = PartK.kosugi;
  static const kosugiTextTheme = PartK.kosugiTextTheme;
  static const kosugiMaru = PartK.kosugiMaru;
  static const kosugiMaruTextTheme = PartK.kosugiMaruTextTheme;
  static const kottaOne = PartK.kottaOne;
  static const kottaOneTextTheme = PartK.kottaOneTextTheme;
  static const koulen = PartK.koulen;
  static const koulenTextTheme = PartK.koulenTextTheme;
  static const kranky = PartK.kranky;
  static const krankyTextTheme = PartK.krankyTextTheme;
  static const kreon = PartK.kreon;
  static const kreonTextTheme = PartK.kreonTextTheme;
  static const kristi = PartK.kristi;
  static const kristiTextTheme = PartK.kristiTextTheme;
  static const kronaOne = PartK.kronaOne;
  static const kronaOneTextTheme = PartK.kronaOneTextTheme;
  static const krub = PartK.krub;
  static const krubTextTheme = PartK.krubTextTheme;
  static const kufam = PartK.kufam;
  static const kufamTextTheme = PartK.kufamTextTheme;
  static const kulimPark = PartK.kulimPark;
  static const kulimParkTextTheme = PartK.kulimParkTextTheme;
  static const kumarOne = PartK.kumarOne;
  static const kumarOneTextTheme = PartK.kumarOneTextTheme;
  static const kumarOneOutline = PartK.kumarOneOutline;
  static const kumarOneOutlineTextTheme = PartK.kumarOneOutlineTextTheme;
  static const kumbhSans = PartK.kumbhSans;
  static const kumbhSansTextTheme = PartK.kumbhSansTextTheme;
  static const kurale = PartK.kurale;
  static const kuraleTextTheme = PartK.kuraleTextTheme;
  static const lxgwWenKaiMonoTc = PartL.lxgwWenKaiMonoTc;
  static const lxgwWenKaiMonoTcTextTheme = PartL.lxgwWenKaiMonoTcTextTheme;
  static const lxgwWenKaiTc = PartL.lxgwWenKaiTc;
  static const lxgwWenKaiTcTextTheme = PartL.lxgwWenKaiTcTextTheme;
  static const laBelleAurore = PartL.laBelleAurore;
  static const laBelleAuroreTextTheme = PartL.laBelleAuroreTextTheme;
  static const labrada = PartL.labrada;
  static const labradaTextTheme = PartL.labradaTextTheme;
  static const lacquer = PartL.lacquer;
  static const lacquerTextTheme = PartL.lacquerTextTheme;
  static const laila = PartL.laila;
  static const lailaTextTheme = PartL.lailaTextTheme;
  static const lakkiReddy = PartL.lakkiReddy;
  static const lakkiReddyTextTheme = PartL.lakkiReddyTextTheme;
  static const lalezar = PartL.lalezar;
  static const lalezarTextTheme = PartL.lalezarTextTheme;
  static const lancelot = PartL.lancelot;
  static const lancelotTextTheme = PartL.lancelotTextTheme;
  static const langar = PartL.langar;
  static const langarTextTheme = PartL.langarTextTheme;
  static const lateef = PartL.lateef;
  static const lateefTextTheme = PartL.lateefTextTheme;
  static const lato = PartL.lato;
  static const latoTextTheme = PartL.latoTextTheme;
  static const lavishlyYours = PartL.lavishlyYours;
  static const lavishlyYoursTextTheme = PartL.lavishlyYoursTextTheme;
  static const leagueGothic = PartL.leagueGothic;
  static const leagueGothicTextTheme = PartL.leagueGothicTextTheme;
  static const leagueScript = PartL.leagueScript;
  static const leagueScriptTextTheme = PartL.leagueScriptTextTheme;
  static const leagueSpartan = PartL.leagueSpartan;
  static const leagueSpartanTextTheme = PartL.leagueSpartanTextTheme;
  static const leckerliOne = PartL.leckerliOne;
  static const leckerliOneTextTheme = PartL.leckerliOneTextTheme;
  static const ledger = PartL.ledger;
  static const ledgerTextTheme = PartL.ledgerTextTheme;
  static const lekton = PartL.lekton;
  static const lektonTextTheme = PartL.lektonTextTheme;
  static const lemon = PartL.lemon;
  static const lemonTextTheme = PartL.lemonTextTheme;
  static const lemonada = PartL.lemonada;
  static const lemonadaTextTheme = PartL.lemonadaTextTheme;
  static const lexend = PartL.lexend;
  static const lexendTextTheme = PartL.lexendTextTheme;
  static const lexendDeca = PartL.lexendDeca;
  static const lexendDecaTextTheme = PartL.lexendDecaTextTheme;
  static const lexendExa = PartL.lexendExa;
  static const lexendExaTextTheme = PartL.lexendExaTextTheme;
  static const lexendGiga = PartL.lexendGiga;
  static const lexendGigaTextTheme = PartL.lexendGigaTextTheme;
  static const lexendMega = PartL.lexendMega;
  static const lexendMegaTextTheme = PartL.lexendMegaTextTheme;
  static const lexendPeta = PartL.lexendPeta;
  static const lexendPetaTextTheme = PartL.lexendPetaTextTheme;
  static const lexendTera = PartL.lexendTera;
  static const lexendTeraTextTheme = PartL.lexendTeraTextTheme;
  static const lexendZetta = PartL.lexendZetta;
  static const lexendZettaTextTheme = PartL.lexendZettaTextTheme;
  static const libreBarcode128 = PartL.libreBarcode128;
  static const libreBarcode128TextTheme = PartL.libreBarcode128TextTheme;
  static const libreBarcode128Text = PartL.libreBarcode128Text;
  static const libreBarcode128TextTextTheme =
      PartL.libreBarcode128TextTextTheme;
  static const libreBarcode39 = PartL.libreBarcode39;
  static const libreBarcode39TextTheme = PartL.libreBarcode39TextTheme;
  static const libreBarcode39Extended = PartL.libreBarcode39Extended;
  static const libreBarcode39ExtendedTextTheme =
      PartL.libreBarcode39ExtendedTextTheme;
  static const libreBarcode39ExtendedText = PartL.libreBarcode39ExtendedText;
  static const libreBarcode39ExtendedTextTextTheme =
      PartL.libreBarcode39ExtendedTextTextTheme;
  static const libreBarcode39Text = PartL.libreBarcode39Text;
  static const libreBarcode39TextTextTheme = PartL.libreBarcode39TextTextTheme;
  static const libreBarcodeEan13Text = PartL.libreBarcodeEan13Text;
  static const libreBarcodeEan13TextTextTheme =
      PartL.libreBarcodeEan13TextTextTheme;
  static const libreBaskerville = PartL.libreBaskerville;
  static const libreBaskervilleTextTheme = PartL.libreBaskervilleTextTheme;
  static const libreBodoni = PartL.libreBodoni;
  static const libreBodoniTextTheme = PartL.libreBodoniTextTheme;
  static const libreCaslonDisplay = PartL.libreCaslonDisplay;
  static const libreCaslonDisplayTextTheme = PartL.libreCaslonDisplayTextTheme;
  static const libreCaslonText = PartL.libreCaslonText;
  static const libreCaslonTextTextTheme = PartL.libreCaslonTextTextTheme;
  static const libreFranklin = PartL.libreFranklin;
  static const libreFranklinTextTheme = PartL.libreFranklinTextTheme;
  static const licorice = PartL.licorice;
  static const licoriceTextTheme = PartL.licoriceTextTheme;
  static const lifeSavers = PartL.lifeSavers;
  static const lifeSaversTextTheme = PartL.lifeSaversTextTheme;
  static const lilitaOne = PartL.lilitaOne;
  static const lilitaOneTextTheme = PartL.lilitaOneTextTheme;
  static const lilyScriptOne = PartL.lilyScriptOne;
  static const lilyScriptOneTextTheme = PartL.lilyScriptOneTextTheme;
  static const limelight = PartL.limelight;
  static const limelightTextTheme = PartL.limelightTextTheme;
  static const lindenHill = PartL.lindenHill;
  static const lindenHillTextTheme = PartL.lindenHillTextTheme;
  static const linefont = PartL.linefont;
  static const linefontTextTheme = PartL.linefontTextTheme;
  static const lisuBosa = PartL.lisuBosa;
  static const lisuBosaTextTheme = PartL.lisuBosaTextTheme;
  static const literata = PartL.literata;
  static const literataTextTheme = PartL.literataTextTheme;
  static const liuJianMaoCao = PartL.liuJianMaoCao;
  static const liuJianMaoCaoTextTheme = PartL.liuJianMaoCaoTextTheme;
  static const livvic = PartL.livvic;
  static const livvicTextTheme = PartL.livvicTextTheme;
  static const lobster = PartL.lobster;
  static const lobsterTextTheme = PartL.lobsterTextTheme;
  static const lobsterTwo = PartL.lobsterTwo;
  static const lobsterTwoTextTheme = PartL.lobsterTwoTextTheme;
  static const londrinaOutline = PartL.londrinaOutline;
  static const londrinaOutlineTextTheme = PartL.londrinaOutlineTextTheme;
  static const londrinaShadow = PartL.londrinaShadow;
  static const londrinaShadowTextTheme = PartL.londrinaShadowTextTheme;
  static const londrinaSketch = PartL.londrinaSketch;
  static const londrinaSketchTextTheme = PartL.londrinaSketchTextTheme;
  static const londrinaSolid = PartL.londrinaSolid;
  static const londrinaSolidTextTheme = PartL.londrinaSolidTextTheme;
  static const longCang = PartL.longCang;
  static const longCangTextTheme = PartL.longCangTextTheme;
  static const lora = PartL.lora;
  static const loraTextTheme = PartL.loraTextTheme;
  static const loveLight = PartL.loveLight;
  static const loveLightTextTheme = PartL.loveLightTextTheme;
  static const loveYaLikeASister = PartL.loveYaLikeASister;
  static const loveYaLikeASisterTextTheme = PartL.loveYaLikeASisterTextTheme;
  static const lovedByTheKing = PartL.lovedByTheKing;
  static const lovedByTheKingTextTheme = PartL.lovedByTheKingTextTheme;
  static const loversQuarrel = PartL.loversQuarrel;
  static const loversQuarrelTextTheme = PartL.loversQuarrelTextTheme;
  static const luckiestGuy = PartL.luckiestGuy;
  static const luckiestGuyTextTheme = PartL.luckiestGuyTextTheme;
  static const lugrasimo = PartL.lugrasimo;
  static const lugrasimoTextTheme = PartL.lugrasimoTextTheme;
  static const lumanosimo = PartL.lumanosimo;
  static const lumanosimoTextTheme = PartL.lumanosimoTextTheme;
  static const lunasima = PartL.lunasima;
  static const lunasimaTextTheme = PartL.lunasimaTextTheme;
  static const lusitana = PartL.lusitana;
  static const lusitanaTextTheme = PartL.lusitanaTextTheme;
  static const lustria = PartL.lustria;
  static const lustriaTextTheme = PartL.lustriaTextTheme;
  static const luxuriousRoman = PartL.luxuriousRoman;
  static const luxuriousRomanTextTheme = PartL.luxuriousRomanTextTheme;
  static const luxuriousScript = PartL.luxuriousScript;
  static const luxuriousScriptTextTheme = PartL.luxuriousScriptTextTheme;
  static const mPlus1 = PartM.mPlus1;
  static const mPlus1TextTheme = PartM.mPlus1TextTheme;
  static const mPlus1Code = PartM.mPlus1Code;
  static const mPlus1CodeTextTheme = PartM.mPlus1CodeTextTheme;
  static const mPlus1p = PartM.mPlus1p;
  static const mPlus1pTextTheme = PartM.mPlus1pTextTheme;
  static const mPlus2 = PartM.mPlus2;
  static const mPlus2TextTheme = PartM.mPlus2TextTheme;
  static const mPlusCodeLatin = PartM.mPlusCodeLatin;
  static const mPlusCodeLatinTextTheme = PartM.mPlusCodeLatinTextTheme;
  static const mPlusRounded1c = PartM.mPlusRounded1c;
  static const mPlusRounded1cTextTheme = PartM.mPlusRounded1cTextTheme;
  static const maShanZheng = PartM.maShanZheng;
  static const maShanZhengTextTheme = PartM.maShanZhengTextTheme;
  static const macondo = PartM.macondo;
  static const macondoTextTheme = PartM.macondoTextTheme;
  static const macondoSwashCaps = PartM.macondoSwashCaps;
  static const macondoSwashCapsTextTheme = PartM.macondoSwashCapsTextTheme;
  static const mada = PartM.mada;
  static const madaTextTheme = PartM.madaTextTheme;
  static const madimiOne = PartM.madimiOne;
  static const madimiOneTextTheme = PartM.madimiOneTextTheme;
  static const magra = PartM.magra;
  static const magraTextTheme = PartM.magraTextTheme;
  static const maidenOrange = PartM.maidenOrange;
  static const maidenOrangeTextTheme = PartM.maidenOrangeTextTheme;
  static const maitree = PartM.maitree;
  static const maitreeTextTheme = PartM.maitreeTextTheme;
  static const majorMonoDisplay = PartM.majorMonoDisplay;
  static const majorMonoDisplayTextTheme = PartM.majorMonoDisplayTextTheme;
  static const mako = PartM.mako;
  static const makoTextTheme = PartM.makoTextTheme;
  static const mali = PartM.mali;
  static const maliTextTheme = PartM.maliTextTheme;
  static const mallanna = PartM.mallanna;
  static const mallannaTextTheme = PartM.mallannaTextTheme;
  static const maname = PartM.maname;
  static const manameTextTheme = PartM.manameTextTheme;
  static const mandali = PartM.mandali;
  static const mandaliTextTheme = PartM.mandaliTextTheme;
  static const manjari = PartM.manjari;
  static const manjariTextTheme = PartM.manjariTextTheme;
  static const manrope = PartM.manrope;
  static const manropeTextTheme = PartM.manropeTextTheme;
  static const mansalva = PartM.mansalva;
  static const mansalvaTextTheme = PartM.mansalvaTextTheme;
  static const manuale = PartM.manuale;
  static const manualeTextTheme = PartM.manualeTextTheme;
  static const marcellus = PartM.marcellus;
  static const marcellusTextTheme = PartM.marcellusTextTheme;
  static const marcellusSc = PartM.marcellusSc;
  static const marcellusScTextTheme = PartM.marcellusScTextTheme;
  static const marckScript = PartM.marckScript;
  static const marckScriptTextTheme = PartM.marckScriptTextTheme;
  static const margarine = PartM.margarine;
  static const margarineTextTheme = PartM.margarineTextTheme;
  static const marhey = PartM.marhey;
  static const marheyTextTheme = PartM.marheyTextTheme;
  static const markaziText = PartM.markaziText;
  static const markaziTextTextTheme = PartM.markaziTextTextTheme;
  static const markoOne = PartM.markoOne;
  static const markoOneTextTheme = PartM.markoOneTextTheme;
  static const marmelad = PartM.marmelad;
  static const marmeladTextTheme = PartM.marmeladTextTheme;
  static const martel = PartM.martel;
  static const martelTextTheme = PartM.martelTextTheme;
  static const martelSans = PartM.martelSans;
  static const martelSansTextTheme = PartM.martelSansTextTheme;
  static const martianMono = PartM.martianMono;
  static const martianMonoTextTheme = PartM.martianMonoTextTheme;
  static const marvel = PartM.marvel;
  static const marvelTextTheme = PartM.marvelTextTheme;
  static const mate = PartM.mate;
  static const mateTextTheme = PartM.mateTextTheme;
  static const mateSc = PartM.mateSc;
  static const mateScTextTheme = PartM.mateScTextTheme;
  static const mavenPro = PartM.mavenPro;
  static const mavenProTextTheme = PartM.mavenProTextTheme;
  static const mcLaren = PartM.mcLaren;
  static const mcLarenTextTheme = PartM.mcLarenTextTheme;
  static const meaCulpa = PartM.meaCulpa;
  static const meaCulpaTextTheme = PartM.meaCulpaTextTheme;
  static const meddon = PartM.meddon;
  static const meddonTextTheme = PartM.meddonTextTheme;
  static const medievalSharp = PartM.medievalSharp;
  static const medievalSharpTextTheme = PartM.medievalSharpTextTheme;
  static const medulaOne = PartM.medulaOne;
  static const medulaOneTextTheme = PartM.medulaOneTextTheme;
  static const meeraInimai = PartM.meeraInimai;
  static const meeraInimaiTextTheme = PartM.meeraInimaiTextTheme;
  static const megrim = PartM.megrim;
  static const megrimTextTheme = PartM.megrimTextTheme;
  static const meieScript = PartM.meieScript;
  static const meieScriptTextTheme = PartM.meieScriptTextTheme;
  static const meowScript = PartM.meowScript;
  static const meowScriptTextTheme = PartM.meowScriptTextTheme;
  static const merienda = PartM.merienda;
  static const meriendaTextTheme = PartM.meriendaTextTheme;
  static const merriweather = PartM.merriweather;
  static const merriweatherTextTheme = PartM.merriweatherTextTheme;
  static const merriweatherSans = PartM.merriweatherSans;
  static const merriweatherSansTextTheme = PartM.merriweatherSansTextTheme;
  static const metal = PartM.metal;
  static const metalTextTheme = PartM.metalTextTheme;
  static const metalMania = PartM.metalMania;
  static const metalManiaTextTheme = PartM.metalManiaTextTheme;
  static const metamorphous = PartM.metamorphous;
  static const metamorphousTextTheme = PartM.metamorphousTextTheme;
  static const metrophobic = PartM.metrophobic;
  static const metrophobicTextTheme = PartM.metrophobicTextTheme;
  static const michroma = PartM.michroma;
  static const michromaTextTheme = PartM.michromaTextTheme;
  static const micro5 = PartM.micro5;
  static const micro5TextTheme = PartM.micro5TextTheme;
  static const micro5Charted = PartM.micro5Charted;
  static const micro5ChartedTextTheme = PartM.micro5ChartedTextTheme;
  static const milonga = PartM.milonga;
  static const milongaTextTheme = PartM.milongaTextTheme;
  static const miltonian = PartM.miltonian;
  static const miltonianTextTheme = PartM.miltonianTextTheme;
  static const miltonianTattoo = PartM.miltonianTattoo;
  static const miltonianTattooTextTheme = PartM.miltonianTattooTextTheme;
  static const mina = PartM.mina;
  static const minaTextTheme = PartM.minaTextTheme;
  static const mingzat = PartM.mingzat;
  static const mingzatTextTheme = PartM.mingzatTextTheme;
  static const miniver = PartM.miniver;
  static const miniverTextTheme = PartM.miniverTextTheme;
  static const miriamLibre = PartM.miriamLibre;
  static const miriamLibreTextTheme = PartM.miriamLibreTextTheme;
  static const mirza = PartM.mirza;
  static const mirzaTextTheme = PartM.mirzaTextTheme;
  static const missFajardose = PartM.missFajardose;
  static const missFajardoseTextTheme = PartM.missFajardoseTextTheme;
  static const mitr = PartM.mitr;
  static const mitrTextTheme = PartM.mitrTextTheme;
  static const mochiyPopOne = PartM.mochiyPopOne;
  static const mochiyPopOneTextTheme = PartM.mochiyPopOneTextTheme;
  static const mochiyPopPOne = PartM.mochiyPopPOne;
  static const mochiyPopPOneTextTheme = PartM.mochiyPopPOneTextTheme;
  static const modak = PartM.modak;
  static const modakTextTheme = PartM.modakTextTheme;
  static const modernAntiqua = PartM.modernAntiqua;
  static const modernAntiquaTextTheme = PartM.modernAntiquaTextTheme;
  static const mogra = PartM.mogra;
  static const mograTextTheme = PartM.mograTextTheme;
  static const mohave = PartM.mohave;
  static const mohaveTextTheme = PartM.mohaveTextTheme;
  static const moiraiOne = PartM.moiraiOne;
  static const moiraiOneTextTheme = PartM.moiraiOneTextTheme;
  static const molengo = PartM.molengo;
  static const molengoTextTheme = PartM.molengoTextTheme;
  static const molle = PartM.molle;
  static const molleTextTheme = PartM.molleTextTheme;
  static const monda = PartM.monda;
  static const mondaTextTheme = PartM.mondaTextTheme;
  static const monofett = PartM.monofett;
  static const monofettTextTheme = PartM.monofettTextTheme;
  static const monomaniacOne = PartM.monomaniacOne;
  static const monomaniacOneTextTheme = PartM.monomaniacOneTextTheme;
  static const monoton = PartM.monoton;
  static const monotonTextTheme = PartM.monotonTextTheme;
  static const monsieurLaDoulaise = PartM.monsieurLaDoulaise;
  static const monsieurLaDoulaiseTextTheme = PartM.monsieurLaDoulaiseTextTheme;
  static const montaga = PartM.montaga;
  static const montagaTextTheme = PartM.montagaTextTheme;
  static const montaguSlab = PartM.montaguSlab;
  static const montaguSlabTextTheme = PartM.montaguSlabTextTheme;
  static const monteCarlo = PartM.monteCarlo;
  static const monteCarloTextTheme = PartM.monteCarloTextTheme;
  static const montez = PartM.montez;
  static const montezTextTheme = PartM.montezTextTheme;
  static const montserrat = PartM.montserrat;
  static const montserratTextTheme = PartM.montserratTextTheme;
  static const montserratAlternates = PartM.montserratAlternates;
  static const montserratAlternatesTextTheme =
      PartM.montserratAlternatesTextTheme;
  static const montserratSubrayada = PartM.montserratSubrayada;
  static const montserratSubrayadaTextTheme =
      PartM.montserratSubrayadaTextTheme;
  static const mooLahLah = PartM.mooLahLah;
  static const mooLahLahTextTheme = PartM.mooLahLahTextTheme;
  static const mooli = PartM.mooli;
  static const mooliTextTheme = PartM.mooliTextTheme;
  static const moonDance = PartM.moonDance;
  static const moonDanceTextTheme = PartM.moonDanceTextTheme;
  static const moul = PartM.moul;
  static const moulTextTheme = PartM.moulTextTheme;
  static const moulpali = PartM.moulpali;
  static const moulpaliTextTheme = PartM.moulpaliTextTheme;
  static const mountainsOfChristmas = PartM.mountainsOfChristmas;
  static const mountainsOfChristmasTextTheme =
      PartM.mountainsOfChristmasTextTheme;
  static const mouseMemoirs = PartM.mouseMemoirs;
  static const mouseMemoirsTextTheme = PartM.mouseMemoirsTextTheme;
  static const mrBedfort = PartM.mrBedfort;
  static const mrBedfortTextTheme = PartM.mrBedfortTextTheme;
  static const mrDafoe = PartM.mrDafoe;
  static const mrDafoeTextTheme = PartM.mrDafoeTextTheme;
  static const mrDeHaviland = PartM.mrDeHaviland;
  static const mrDeHavilandTextTheme = PartM.mrDeHavilandTextTheme;
  static const mrsSaintDelafield = PartM.mrsSaintDelafield;
  static const mrsSaintDelafieldTextTheme = PartM.mrsSaintDelafieldTextTheme;
  static const mrsSheppards = PartM.mrsSheppards;
  static const mrsSheppardsTextTheme = PartM.mrsSheppardsTextTheme;
  static const msMadi = PartM.msMadi;
  static const msMadiTextTheme = PartM.msMadiTextTheme;
  static const mukta = PartM.mukta;
  static const muktaTextTheme = PartM.muktaTextTheme;
  static const muktaMahee = PartM.muktaMahee;
  static const muktaMaheeTextTheme = PartM.muktaMaheeTextTheme;
  static const muktaMalar = PartM.muktaMalar;
  static const muktaMalarTextTheme = PartM.muktaMalarTextTheme;
  static const muktaVaani = PartM.muktaVaani;
  static const muktaVaaniTextTheme = PartM.muktaVaaniTextTheme;
  static const mulish = PartM.mulish;
  static const mulishTextTheme = PartM.mulishTextTheme;
  static const murecho = PartM.murecho;
  static const murechoTextTheme = PartM.murechoTextTheme;
  static const museoModerno = PartM.museoModerno;
  static const museoModernoTextTheme = PartM.museoModernoTextTheme;
  static const mySoul = PartM.mySoul;
  static const mySoulTextTheme = PartM.mySoulTextTheme;
  static const mynerve = PartM.mynerve;
  static const mynerveTextTheme = PartM.mynerveTextTheme;
  static const mysteryQuest = PartM.mysteryQuest;
  static const mysteryQuestTextTheme = PartM.mysteryQuestTextTheme;
  static const ntr = PartN.ntr;
  static const ntrTextTheme = PartN.ntrTextTheme;
  static const nabla = PartN.nabla;
  static const nablaTextTheme = PartN.nablaTextTheme;
  static const namdhinggo = PartN.namdhinggo;
  static const namdhinggoTextTheme = PartN.namdhinggoTextTheme;
  static const nanumBrushScript = PartN.nanumBrushScript;
  static const nanumBrushScriptTextTheme = PartN.nanumBrushScriptTextTheme;
  static const nanumGothic = PartN.nanumGothic;
  static const nanumGothicTextTheme = PartN.nanumGothicTextTheme;
  static const nanumGothicCoding = PartN.nanumGothicCoding;
  static const nanumGothicCodingTextTheme = PartN.nanumGothicCodingTextTheme;
  static const nanumMyeongjo = PartN.nanumMyeongjo;
  static const nanumMyeongjoTextTheme = PartN.nanumMyeongjoTextTheme;
  static const nanumPenScript = PartN.nanumPenScript;
  static const nanumPenScriptTextTheme = PartN.nanumPenScriptTextTheme;
  static const narnoor = PartN.narnoor;
  static const narnoorTextTheme = PartN.narnoorTextTheme;
  static const neonderthaw = PartN.neonderthaw;
  static const neonderthawTextTheme = PartN.neonderthawTextTheme;
  static const nerkoOne = PartN.nerkoOne;
  static const nerkoOneTextTheme = PartN.nerkoOneTextTheme;
  static const neucha = PartN.neucha;
  static const neuchaTextTheme = PartN.neuchaTextTheme;
  static const neuton = PartN.neuton;
  static const neutonTextTheme = PartN.neutonTextTheme;
  static const newRocker = PartN.newRocker;
  static const newRockerTextTheme = PartN.newRockerTextTheme;
  static const newTegomin = PartN.newTegomin;
  static const newTegominTextTheme = PartN.newTegominTextTheme;
  static const newsCycle = PartN.newsCycle;
  static const newsCycleTextTheme = PartN.newsCycleTextTheme;
  static const newsreader = PartN.newsreader;
  static const newsreaderTextTheme = PartN.newsreaderTextTheme;
  static const niconne = PartN.niconne;
  static const niconneTextTheme = PartN.niconneTextTheme;
  static const niramit = PartN.niramit;
  static const niramitTextTheme = PartN.niramitTextTheme;
  static const nixieOne = PartN.nixieOne;
  static const nixieOneTextTheme = PartN.nixieOneTextTheme;
  static const nobile = PartN.nobile;
  static const nobileTextTheme = PartN.nobileTextTheme;
  static const nokora = PartN.nokora;
  static const nokoraTextTheme = PartN.nokoraTextTheme;
  static const norican = PartN.norican;
  static const noricanTextTheme = PartN.noricanTextTheme;
  static const nosifer = PartN.nosifer;
  static const nosiferTextTheme = PartN.nosiferTextTheme;
  static const notable = PartN.notable;
  static const notableTextTheme = PartN.notableTextTheme;
  static const nothingYouCouldDo = PartN.nothingYouCouldDo;
  static const nothingYouCouldDoTextTheme = PartN.nothingYouCouldDoTextTheme;
  static const noticiaText = PartN.noticiaText;
  static const noticiaTextTextTheme = PartN.noticiaTextTextTheme;
  static const notoColorEmoji = PartN.notoColorEmoji;
  static const notoColorEmojiTextTheme = PartN.notoColorEmojiTextTheme;
  static const notoEmoji = PartN.notoEmoji;
  static const notoEmojiTextTheme = PartN.notoEmojiTextTheme;
  static const notoKufiArabic = PartN.notoKufiArabic;
  static const notoKufiArabicTextTheme = PartN.notoKufiArabicTextTheme;
  static const notoMusic = PartN.notoMusic;
  static const notoMusicTextTheme = PartN.notoMusicTextTheme;
  static const notoNaskhArabic = PartN.notoNaskhArabic;
  static const notoNaskhArabicTextTheme = PartN.notoNaskhArabicTextTheme;
  static const notoNastaliqUrdu = PartN.notoNastaliqUrdu;
  static const notoNastaliqUrduTextTheme = PartN.notoNastaliqUrduTextTheme;
  static const notoRashiHebrew = PartN.notoRashiHebrew;
  static const notoRashiHebrewTextTheme = PartN.notoRashiHebrewTextTheme;
  static const notoSans = PartN.notoSans;
  static const notoSansTextTheme = PartN.notoSansTextTheme;
  static const notoSansAdlam = PartN.notoSansAdlam;
  static const notoSansAdlamTextTheme = PartN.notoSansAdlamTextTheme;
  static const notoSansAdlamUnjoined = PartN.notoSansAdlamUnjoined;
  static const notoSansAdlamUnjoinedTextTheme =
      PartN.notoSansAdlamUnjoinedTextTheme;
  static const notoSansAnatolianHieroglyphs =
      PartN.notoSansAnatolianHieroglyphs;
  static const notoSansAnatolianHieroglyphsTextTheme =
      PartN.notoSansAnatolianHieroglyphsTextTheme;
  static const notoSansArabic = PartN.notoSansArabic;
  static const notoSansArabicTextTheme = PartN.notoSansArabicTextTheme;
  static const notoSansArmenian = PartN.notoSansArmenian;
  static const notoSansArmenianTextTheme = PartN.notoSansArmenianTextTheme;
  static const notoSansAvestan = PartN.notoSansAvestan;
  static const notoSansAvestanTextTheme = PartN.notoSansAvestanTextTheme;
  static const notoSansBalinese = PartN.notoSansBalinese;
  static const notoSansBalineseTextTheme = PartN.notoSansBalineseTextTheme;
  static const notoSansBamum = PartN.notoSansBamum;
  static const notoSansBamumTextTheme = PartN.notoSansBamumTextTheme;
  static const notoSansBassaVah = PartN.notoSansBassaVah;
  static const notoSansBassaVahTextTheme = PartN.notoSansBassaVahTextTheme;
  static const notoSansBatak = PartN.notoSansBatak;
  static const notoSansBatakTextTheme = PartN.notoSansBatakTextTheme;
  static const notoSansBengali = PartN.notoSansBengali;
  static const notoSansBengaliTextTheme = PartN.notoSansBengaliTextTheme;
  static const notoSansBhaiksuki = PartN.notoSansBhaiksuki;
  static const notoSansBhaiksukiTextTheme = PartN.notoSansBhaiksukiTextTheme;
  static const notoSansBrahmi = PartN.notoSansBrahmi;
  static const notoSansBrahmiTextTheme = PartN.notoSansBrahmiTextTheme;
  static const notoSansBuginese = PartN.notoSansBuginese;
  static const notoSansBugineseTextTheme = PartN.notoSansBugineseTextTheme;
  static const notoSansBuhid = PartN.notoSansBuhid;
  static const notoSansBuhidTextTheme = PartN.notoSansBuhidTextTheme;
  static const notoSansCanadianAboriginal = PartN.notoSansCanadianAboriginal;
  static const notoSansCanadianAboriginalTextTheme =
      PartN.notoSansCanadianAboriginalTextTheme;
  static const notoSansCarian = PartN.notoSansCarian;
  static const notoSansCarianTextTheme = PartN.notoSansCarianTextTheme;
  static const notoSansCaucasianAlbanian = PartN.notoSansCaucasianAlbanian;
  static const notoSansCaucasianAlbanianTextTheme =
      PartN.notoSansCaucasianAlbanianTextTheme;
  static const notoSansChakma = PartN.notoSansChakma;
  static const notoSansChakmaTextTheme = PartN.notoSansChakmaTextTheme;
  static const notoSansCham = PartN.notoSansCham;
  static const notoSansChamTextTheme = PartN.notoSansChamTextTheme;
  static const notoSansCherokee = PartN.notoSansCherokee;
  static const notoSansCherokeeTextTheme = PartN.notoSansCherokeeTextTheme;
  static const notoSansChorasmian = PartN.notoSansChorasmian;
  static const notoSansChorasmianTextTheme = PartN.notoSansChorasmianTextTheme;
  static const notoSansCoptic = PartN.notoSansCoptic;
  static const notoSansCopticTextTheme = PartN.notoSansCopticTextTheme;
  static const notoSansCuneiform = PartN.notoSansCuneiform;
  static const notoSansCuneiformTextTheme = PartN.notoSansCuneiformTextTheme;
  static const notoSansCypriot = PartN.notoSansCypriot;
  static const notoSansCypriotTextTheme = PartN.notoSansCypriotTextTheme;
  static const notoSansCyproMinoan = PartN.notoSansCyproMinoan;
  static const notoSansCyproMinoanTextTheme =
      PartN.notoSansCyproMinoanTextTheme;
  static const notoSansDeseret = PartN.notoSansDeseret;
  static const notoSansDeseretTextTheme = PartN.notoSansDeseretTextTheme;
  static const notoSansDevanagari = PartN.notoSansDevanagari;
  static const notoSansDevanagariTextTheme = PartN.notoSansDevanagariTextTheme;
  static const notoSansDisplay = PartN.notoSansDisplay;
  static const notoSansDisplayTextTheme = PartN.notoSansDisplayTextTheme;
  static const notoSansDuployan = PartN.notoSansDuployan;
  static const notoSansDuployanTextTheme = PartN.notoSansDuployanTextTheme;
  static const notoSansEgyptianHieroglyphs = PartN.notoSansEgyptianHieroglyphs;
  static const notoSansEgyptianHieroglyphsTextTheme =
      PartN.notoSansEgyptianHieroglyphsTextTheme;
  static const notoSansElbasan = PartN.notoSansElbasan;
  static const notoSansElbasanTextTheme = PartN.notoSansElbasanTextTheme;
  static const notoSansElymaic = PartN.notoSansElymaic;
  static const notoSansElymaicTextTheme = PartN.notoSansElymaicTextTheme;
  static const notoSansEthiopic = PartN.notoSansEthiopic;
  static const notoSansEthiopicTextTheme = PartN.notoSansEthiopicTextTheme;
  static const notoSansGeorgian = PartN.notoSansGeorgian;
  static const notoSansGeorgianTextTheme = PartN.notoSansGeorgianTextTheme;
  static const notoSansGlagolitic = PartN.notoSansGlagolitic;
  static const notoSansGlagoliticTextTheme = PartN.notoSansGlagoliticTextTheme;
  static const notoSansGothic = PartN.notoSansGothic;
  static const notoSansGothicTextTheme = PartN.notoSansGothicTextTheme;
  static const notoSansGrantha = PartN.notoSansGrantha;
  static const notoSansGranthaTextTheme = PartN.notoSansGranthaTextTheme;
  static const notoSansGujarati = PartN.notoSansGujarati;
  static const notoSansGujaratiTextTheme = PartN.notoSansGujaratiTextTheme;
  static const notoSansGunjalaGondi = PartN.notoSansGunjalaGondi;
  static const notoSansGunjalaGondiTextTheme =
      PartN.notoSansGunjalaGondiTextTheme;
  static const notoSansGurmukhi = PartN.notoSansGurmukhi;
  static const notoSansGurmukhiTextTheme = PartN.notoSansGurmukhiTextTheme;
  static const notoSansHk = PartN.notoSansHk;
  static const notoSansHkTextTheme = PartN.notoSansHkTextTheme;
  static const notoSansHanifiRohingya = PartN.notoSansHanifiRohingya;
  static const notoSansHanifiRohingyaTextTheme =
      PartN.notoSansHanifiRohingyaTextTheme;
  static const notoSansHanunoo = PartN.notoSansHanunoo;
  static const notoSansHanunooTextTheme = PartN.notoSansHanunooTextTheme;
  static const notoSansHatran = PartN.notoSansHatran;
  static const notoSansHatranTextTheme = PartN.notoSansHatranTextTheme;
  static const notoSansHebrew = PartN.notoSansHebrew;
  static const notoSansHebrewTextTheme = PartN.notoSansHebrewTextTheme;
  static const notoSansImperialAramaic = PartN.notoSansImperialAramaic;
  static const notoSansImperialAramaicTextTheme =
      PartN.notoSansImperialAramaicTextTheme;
  static const notoSansIndicSiyaqNumbers = PartN.notoSansIndicSiyaqNumbers;
  static const notoSansIndicSiyaqNumbersTextTheme =
      PartN.notoSansIndicSiyaqNumbersTextTheme;
  static const notoSansInscriptionalPahlavi =
      PartN.notoSansInscriptionalPahlavi;
  static const notoSansInscriptionalPahlaviTextTheme =
      PartN.notoSansInscriptionalPahlaviTextTheme;
  static const notoSansInscriptionalParthian =
      PartN.notoSansInscriptionalParthian;
  static const notoSansInscriptionalParthianTextTheme =
      PartN.notoSansInscriptionalParthianTextTheme;
  static const notoSansJp = PartN.notoSansJp;
  static const notoSansJpTextTheme = PartN.notoSansJpTextTheme;
  static const notoSansJavanese = PartN.notoSansJavanese;
  static const notoSansJavaneseTextTheme = PartN.notoSansJavaneseTextTheme;
  static const notoSansKr = PartN.notoSansKr;
  static const notoSansKrTextTheme = PartN.notoSansKrTextTheme;
  static const notoSansKaithi = PartN.notoSansKaithi;
  static const notoSansKaithiTextTheme = PartN.notoSansKaithiTextTheme;
  static const notoSansKannada = PartN.notoSansKannada;
  static const notoSansKannadaTextTheme = PartN.notoSansKannadaTextTheme;
  static const notoSansKawi = PartN.notoSansKawi;
  static const notoSansKawiTextTheme = PartN.notoSansKawiTextTheme;
  static const notoSansKayahLi = PartN.notoSansKayahLi;
  static const notoSansKayahLiTextTheme = PartN.notoSansKayahLiTextTheme;
  static const notoSansKharoshthi = PartN.notoSansKharoshthi;
  static const notoSansKharoshthiTextTheme = PartN.notoSansKharoshthiTextTheme;
  static const notoSansKhmer = PartN.notoSansKhmer;
  static const notoSansKhmerTextTheme = PartN.notoSansKhmerTextTheme;
  static const notoSansKhojki = PartN.notoSansKhojki;
  static const notoSansKhojkiTextTheme = PartN.notoSansKhojkiTextTheme;
  static const notoSansKhudawadi = PartN.notoSansKhudawadi;
  static const notoSansKhudawadiTextTheme = PartN.notoSansKhudawadiTextTheme;
  static const notoSansLao = PartN.notoSansLao;
  static const notoSansLaoTextTheme = PartN.notoSansLaoTextTheme;
  static const notoSansLaoLooped = PartN.notoSansLaoLooped;
  static const notoSansLaoLoopedTextTheme = PartN.notoSansLaoLoopedTextTheme;
  static const notoSansLepcha = PartN.notoSansLepcha;
  static const notoSansLepchaTextTheme = PartN.notoSansLepchaTextTheme;
  static const notoSansLimbu = PartN.notoSansLimbu;
  static const notoSansLimbuTextTheme = PartN.notoSansLimbuTextTheme;
  static const notoSansLinearA = PartN.notoSansLinearA;
  static const notoSansLinearATextTheme = PartN.notoSansLinearATextTheme;
  static const notoSansLinearB = PartN.notoSansLinearB;
  static const notoSansLinearBTextTheme = PartN.notoSansLinearBTextTheme;
  static const notoSansLisu = PartN.notoSansLisu;
  static const notoSansLisuTextTheme = PartN.notoSansLisuTextTheme;
  static const notoSansLycian = PartN.notoSansLycian;
  static const notoSansLycianTextTheme = PartN.notoSansLycianTextTheme;
  static const notoSansLydian = PartN.notoSansLydian;
  static const notoSansLydianTextTheme = PartN.notoSansLydianTextTheme;
  static const notoSansMahajani = PartN.notoSansMahajani;
  static const notoSansMahajaniTextTheme = PartN.notoSansMahajaniTextTheme;
  static const notoSansMalayalam = PartN.notoSansMalayalam;
  static const notoSansMalayalamTextTheme = PartN.notoSansMalayalamTextTheme;
  static const notoSansMandaic = PartN.notoSansMandaic;
  static const notoSansMandaicTextTheme = PartN.notoSansMandaicTextTheme;
  static const notoSansManichaean = PartN.notoSansManichaean;
  static const notoSansManichaeanTextTheme = PartN.notoSansManichaeanTextTheme;
  static const notoSansMarchen = PartN.notoSansMarchen;
  static const notoSansMarchenTextTheme = PartN.notoSansMarchenTextTheme;
  static const notoSansMasaramGondi = PartN.notoSansMasaramGondi;
  static const notoSansMasaramGondiTextTheme =
      PartN.notoSansMasaramGondiTextTheme;
  static const notoSansMath = PartN.notoSansMath;
  static const notoSansMathTextTheme = PartN.notoSansMathTextTheme;
  static const notoSansMayanNumerals = PartN.notoSansMayanNumerals;
  static const notoSansMayanNumeralsTextTheme =
      PartN.notoSansMayanNumeralsTextTheme;
  static const notoSansMedefaidrin = PartN.notoSansMedefaidrin;
  static const notoSansMedefaidrinTextTheme =
      PartN.notoSansMedefaidrinTextTheme;
  static const notoSansMeeteiMayek = PartN.notoSansMeeteiMayek;
  static const notoSansMeeteiMayekTextTheme =
      PartN.notoSansMeeteiMayekTextTheme;
  static const notoSansMendeKikakui = PartN.notoSansMendeKikakui;
  static const notoSansMendeKikakuiTextTheme =
      PartN.notoSansMendeKikakuiTextTheme;
  static const notoSansMeroitic = PartN.notoSansMeroitic;
  static const notoSansMeroiticTextTheme = PartN.notoSansMeroiticTextTheme;
  static const notoSansMiao = PartN.notoSansMiao;
  static const notoSansMiaoTextTheme = PartN.notoSansMiaoTextTheme;
  static const notoSansModi = PartN.notoSansModi;
  static const notoSansModiTextTheme = PartN.notoSansModiTextTheme;
  static const notoSansMongolian = PartN.notoSansMongolian;
  static const notoSansMongolianTextTheme = PartN.notoSansMongolianTextTheme;
  static const notoSansMono = PartN.notoSansMono;
  static const notoSansMonoTextTheme = PartN.notoSansMonoTextTheme;
  static const notoSansMro = PartN.notoSansMro;
  static const notoSansMroTextTheme = PartN.notoSansMroTextTheme;
  static const notoSansMultani = PartN.notoSansMultani;
  static const notoSansMultaniTextTheme = PartN.notoSansMultaniTextTheme;
  static const notoSansMyanmar = PartN.notoSansMyanmar;
  static const notoSansMyanmarTextTheme = PartN.notoSansMyanmarTextTheme;
  static const notoSansNKo = PartN.notoSansNKo;
  static const notoSansNKoTextTheme = PartN.notoSansNKoTextTheme;
  static const notoSansNKoUnjoined = PartN.notoSansNKoUnjoined;
  static const notoSansNKoUnjoinedTextTheme =
      PartN.notoSansNKoUnjoinedTextTheme;
  static const notoSansNabataean = PartN.notoSansNabataean;
  static const notoSansNabataeanTextTheme = PartN.notoSansNabataeanTextTheme;
  static const notoSansNagMundari = PartN.notoSansNagMundari;
  static const notoSansNagMundariTextTheme = PartN.notoSansNagMundariTextTheme;
  static const notoSansNandinagari = PartN.notoSansNandinagari;
  static const notoSansNandinagariTextTheme =
      PartN.notoSansNandinagariTextTheme;
  static const notoSansNewTaiLue = PartN.notoSansNewTaiLue;
  static const notoSansNewTaiLueTextTheme = PartN.notoSansNewTaiLueTextTheme;
  static const notoSansNewa = PartN.notoSansNewa;
  static const notoSansNewaTextTheme = PartN.notoSansNewaTextTheme;
  static const notoSansNushu = PartN.notoSansNushu;
  static const notoSansNushuTextTheme = PartN.notoSansNushuTextTheme;
  static const notoSansOgham = PartN.notoSansOgham;
  static const notoSansOghamTextTheme = PartN.notoSansOghamTextTheme;
  static const notoSansOlChiki = PartN.notoSansOlChiki;
  static const notoSansOlChikiTextTheme = PartN.notoSansOlChikiTextTheme;
  static const notoSansOldHungarian = PartN.notoSansOldHungarian;
  static const notoSansOldHungarianTextTheme =
      PartN.notoSansOldHungarianTextTheme;
  static const notoSansOldItalic = PartN.notoSansOldItalic;
  static const notoSansOldItalicTextTheme = PartN.notoSansOldItalicTextTheme;
  static const notoSansOldNorthArabian = PartN.notoSansOldNorthArabian;
  static const notoSansOldNorthArabianTextTheme =
      PartN.notoSansOldNorthArabianTextTheme;
  static const notoSansOldPermic = PartN.notoSansOldPermic;
  static const notoSansOldPermicTextTheme = PartN.notoSansOldPermicTextTheme;
  static const notoSansOldPersian = PartN.notoSansOldPersian;
  static const notoSansOldPersianTextTheme = PartN.notoSansOldPersianTextTheme;
  static const notoSansOldSogdian = PartN.notoSansOldSogdian;
  static const notoSansOldSogdianTextTheme = PartN.notoSansOldSogdianTextTheme;
  static const notoSansOldSouthArabian = PartN.notoSansOldSouthArabian;
  static const notoSansOldSouthArabianTextTheme =
      PartN.notoSansOldSouthArabianTextTheme;
  static const notoSansOldTurkic = PartN.notoSansOldTurkic;
  static const notoSansOldTurkicTextTheme = PartN.notoSansOldTurkicTextTheme;
  static const notoSansOriya = PartN.notoSansOriya;
  static const notoSansOriyaTextTheme = PartN.notoSansOriyaTextTheme;
  static const notoSansOsage = PartN.notoSansOsage;
  static const notoSansOsageTextTheme = PartN.notoSansOsageTextTheme;
  static const notoSansOsmanya = PartN.notoSansOsmanya;
  static const notoSansOsmanyaTextTheme = PartN.notoSansOsmanyaTextTheme;
  static const notoSansPahawhHmong = PartN.notoSansPahawhHmong;
  static const notoSansPahawhHmongTextTheme =
      PartN.notoSansPahawhHmongTextTheme;
  static const notoSansPalmyrene = PartN.notoSansPalmyrene;
  static const notoSansPalmyreneTextTheme = PartN.notoSansPalmyreneTextTheme;
  static const notoSansPauCinHau = PartN.notoSansPauCinHau;
  static const notoSansPauCinHauTextTheme = PartN.notoSansPauCinHauTextTheme;
  static const notoSansPhagsPa = PartN.notoSansPhagsPa;
  static const notoSansPhagsPaTextTheme = PartN.notoSansPhagsPaTextTheme;
  static const notoSansPhoenician = PartN.notoSansPhoenician;
  static const notoSansPhoenicianTextTheme = PartN.notoSansPhoenicianTextTheme;
  static const notoSansPsalterPahlavi = PartN.notoSansPsalterPahlavi;
  static const notoSansPsalterPahlaviTextTheme =
      PartN.notoSansPsalterPahlaviTextTheme;
  static const notoSansRejang = PartN.notoSansRejang;
  static const notoSansRejangTextTheme = PartN.notoSansRejangTextTheme;
  static const notoSansRunic = PartN.notoSansRunic;
  static const notoSansRunicTextTheme = PartN.notoSansRunicTextTheme;
  static const notoSansSc = PartN.notoSansSc;
  static const notoSansScTextTheme = PartN.notoSansScTextTheme;
  static const notoSansSamaritan = PartN.notoSansSamaritan;
  static const notoSansSamaritanTextTheme = PartN.notoSansSamaritanTextTheme;
  static const notoSansSaurashtra = PartN.notoSansSaurashtra;
  static const notoSansSaurashtraTextTheme = PartN.notoSansSaurashtraTextTheme;
  static const notoSansSharada = PartN.notoSansSharada;
  static const notoSansSharadaTextTheme = PartN.notoSansSharadaTextTheme;
  static const notoSansShavian = PartN.notoSansShavian;
  static const notoSansShavianTextTheme = PartN.notoSansShavianTextTheme;
  static const notoSansSiddham = PartN.notoSansSiddham;
  static const notoSansSiddhamTextTheme = PartN.notoSansSiddhamTextTheme;
  static const notoSansSignWriting = PartN.notoSansSignWriting;
  static const notoSansSignWritingTextTheme =
      PartN.notoSansSignWritingTextTheme;
  static const notoSansSinhala = PartN.notoSansSinhala;
  static const notoSansSinhalaTextTheme = PartN.notoSansSinhalaTextTheme;
  static const notoSansSogdian = PartN.notoSansSogdian;
  static const notoSansSogdianTextTheme = PartN.notoSansSogdianTextTheme;
  static const notoSansSoraSompeng = PartN.notoSansSoraSompeng;
  static const notoSansSoraSompengTextTheme =
      PartN.notoSansSoraSompengTextTheme;
  static const notoSansSoyombo = PartN.notoSansSoyombo;
  static const notoSansSoyomboTextTheme = PartN.notoSansSoyomboTextTheme;
  static const notoSansSundanese = PartN.notoSansSundanese;
  static const notoSansSundaneseTextTheme = PartN.notoSansSundaneseTextTheme;
  static const notoSansSylotiNagri = PartN.notoSansSylotiNagri;
  static const notoSansSylotiNagriTextTheme =
      PartN.notoSansSylotiNagriTextTheme;
  static const notoSansSymbols = PartN.notoSansSymbols;
  static const notoSansSymbolsTextTheme = PartN.notoSansSymbolsTextTheme;
  static const notoSansSymbols2 = PartN.notoSansSymbols2;
  static const notoSansSymbols2TextTheme = PartN.notoSansSymbols2TextTheme;
  static const notoSansSyriac = PartN.notoSansSyriac;
  static const notoSansSyriacTextTheme = PartN.notoSansSyriacTextTheme;
  static const notoSansSyriacEastern = PartN.notoSansSyriacEastern;
  static const notoSansSyriacEasternTextTheme =
      PartN.notoSansSyriacEasternTextTheme;
  static const notoSansTc = PartN.notoSansTc;
  static const notoSansTcTextTheme = PartN.notoSansTcTextTheme;
  static const notoSansTagalog = PartN.notoSansTagalog;
  static const notoSansTagalogTextTheme = PartN.notoSansTagalogTextTheme;
  static const notoSansTagbanwa = PartN.notoSansTagbanwa;
  static const notoSansTagbanwaTextTheme = PartN.notoSansTagbanwaTextTheme;
  static const notoSansTaiLe = PartN.notoSansTaiLe;
  static const notoSansTaiLeTextTheme = PartN.notoSansTaiLeTextTheme;
  static const notoSansTaiTham = PartN.notoSansTaiTham;
  static const notoSansTaiThamTextTheme = PartN.notoSansTaiThamTextTheme;
  static const notoSansTaiViet = PartN.notoSansTaiViet;
  static const notoSansTaiVietTextTheme = PartN.notoSansTaiVietTextTheme;
  static const notoSansTakri = PartN.notoSansTakri;
  static const notoSansTakriTextTheme = PartN.notoSansTakriTextTheme;
  static const notoSansTamil = PartN.notoSansTamil;
  static const notoSansTamilTextTheme = PartN.notoSansTamilTextTheme;
  static const notoSansTamilSupplement = PartN.notoSansTamilSupplement;
  static const notoSansTamilSupplementTextTheme =
      PartN.notoSansTamilSupplementTextTheme;
  static const notoSansTangsa = PartN.notoSansTangsa;
  static const notoSansTangsaTextTheme = PartN.notoSansTangsaTextTheme;
  static const notoSansTelugu = PartN.notoSansTelugu;
  static const notoSansTeluguTextTheme = PartN.notoSansTeluguTextTheme;
  static const notoSansThaana = PartN.notoSansThaana;
  static const notoSansThaanaTextTheme = PartN.notoSansThaanaTextTheme;
  static const notoSansThai = PartN.notoSansThai;
  static const notoSansThaiTextTheme = PartN.notoSansThaiTextTheme;
  static const notoSansThaiLooped = PartN.notoSansThaiLooped;
  static const notoSansThaiLoopedTextTheme = PartN.notoSansThaiLoopedTextTheme;
  static const notoSansTifinagh = PartN.notoSansTifinagh;
  static const notoSansTifinaghTextTheme = PartN.notoSansTifinaghTextTheme;
  static const notoSansTirhuta = PartN.notoSansTirhuta;
  static const notoSansTirhutaTextTheme = PartN.notoSansTirhutaTextTheme;
  static const notoSansUgaritic = PartN.notoSansUgaritic;
  static const notoSansUgariticTextTheme = PartN.notoSansUgariticTextTheme;
  static const notoSansVai = PartN.notoSansVai;
  static const notoSansVaiTextTheme = PartN.notoSansVaiTextTheme;
  static const notoSansVithkuqi = PartN.notoSansVithkuqi;
  static const notoSansVithkuqiTextTheme = PartN.notoSansVithkuqiTextTheme;
  static const notoSansWancho = PartN.notoSansWancho;
  static const notoSansWanchoTextTheme = PartN.notoSansWanchoTextTheme;
  static const notoSansWarangCiti = PartN.notoSansWarangCiti;
  static const notoSansWarangCitiTextTheme = PartN.notoSansWarangCitiTextTheme;
  static const notoSansYi = PartN.notoSansYi;
  static const notoSansYiTextTheme = PartN.notoSansYiTextTheme;
  static const notoSansZanabazarSquare = PartN.notoSansZanabazarSquare;
  static const notoSansZanabazarSquareTextTheme =
      PartN.notoSansZanabazarSquareTextTheme;
  static const notoSerif = PartN.notoSerif;
  static const notoSerifTextTheme = PartN.notoSerifTextTheme;
  static const notoSerifAhom = PartN.notoSerifAhom;
  static const notoSerifAhomTextTheme = PartN.notoSerifAhomTextTheme;
  static const notoSerifArmenian = PartN.notoSerifArmenian;
  static const notoSerifArmenianTextTheme = PartN.notoSerifArmenianTextTheme;
  static const notoSerifBalinese = PartN.notoSerifBalinese;
  static const notoSerifBalineseTextTheme = PartN.notoSerifBalineseTextTheme;
  static const notoSerifBengali = PartN.notoSerifBengali;
  static const notoSerifBengaliTextTheme = PartN.notoSerifBengaliTextTheme;
  static const notoSerifDevanagari = PartN.notoSerifDevanagari;
  static const notoSerifDevanagariTextTheme =
      PartN.notoSerifDevanagariTextTheme;
  static const notoSerifDisplay = PartN.notoSerifDisplay;
  static const notoSerifDisplayTextTheme = PartN.notoSerifDisplayTextTheme;
  static const notoSerifDogra = PartN.notoSerifDogra;
  static const notoSerifDograTextTheme = PartN.notoSerifDograTextTheme;
  static const notoSerifEthiopic = PartN.notoSerifEthiopic;
  static const notoSerifEthiopicTextTheme = PartN.notoSerifEthiopicTextTheme;
  static const notoSerifGeorgian = PartN.notoSerifGeorgian;
  static const notoSerifGeorgianTextTheme = PartN.notoSerifGeorgianTextTheme;
  static const notoSerifGrantha = PartN.notoSerifGrantha;
  static const notoSerifGranthaTextTheme = PartN.notoSerifGranthaTextTheme;
  static const notoSerifGujarati = PartN.notoSerifGujarati;
  static const notoSerifGujaratiTextTheme = PartN.notoSerifGujaratiTextTheme;
  static const notoSerifGurmukhi = PartN.notoSerifGurmukhi;
  static const notoSerifGurmukhiTextTheme = PartN.notoSerifGurmukhiTextTheme;
  static const notoSerifHk = PartN.notoSerifHk;
  static const notoSerifHkTextTheme = PartN.notoSerifHkTextTheme;
  static const notoSerifHebrew = PartN.notoSerifHebrew;
  static const notoSerifHebrewTextTheme = PartN.notoSerifHebrewTextTheme;
  static const notoSerifJp = PartN.notoSerifJp;
  static const notoSerifJpTextTheme = PartN.notoSerifJpTextTheme;
  static const notoSerifKr = PartN.notoSerifKr;
  static const notoSerifKrTextTheme = PartN.notoSerifKrTextTheme;
  static const notoSerifKannada = PartN.notoSerifKannada;
  static const notoSerifKannadaTextTheme = PartN.notoSerifKannadaTextTheme;
  static const notoSerifKhitanSmallScript = PartN.notoSerifKhitanSmallScript;
  static const notoSerifKhitanSmallScriptTextTheme =
      PartN.notoSerifKhitanSmallScriptTextTheme;
  static const notoSerifKhmer = PartN.notoSerifKhmer;
  static const notoSerifKhmerTextTheme = PartN.notoSerifKhmerTextTheme;
  static const notoSerifKhojki = PartN.notoSerifKhojki;
  static const notoSerifKhojkiTextTheme = PartN.notoSerifKhojkiTextTheme;
  static const notoSerifLao = PartN.notoSerifLao;
  static const notoSerifLaoTextTheme = PartN.notoSerifLaoTextTheme;
  static const notoSerifMakasar = PartN.notoSerifMakasar;
  static const notoSerifMakasarTextTheme = PartN.notoSerifMakasarTextTheme;
  static const notoSerifMalayalam = PartN.notoSerifMalayalam;
  static const notoSerifMalayalamTextTheme = PartN.notoSerifMalayalamTextTheme;
  static const notoSerifMyanmar = PartN.notoSerifMyanmar;
  static const notoSerifMyanmarTextTheme = PartN.notoSerifMyanmarTextTheme;
  static const notoSerifNpHmong = PartN.notoSerifNpHmong;
  static const notoSerifNpHmongTextTheme = PartN.notoSerifNpHmongTextTheme;
  static const notoSerifOldUyghur = PartN.notoSerifOldUyghur;
  static const notoSerifOldUyghurTextTheme = PartN.notoSerifOldUyghurTextTheme;
  static const notoSerifOriya = PartN.notoSerifOriya;
  static const notoSerifOriyaTextTheme = PartN.notoSerifOriyaTextTheme;
  static const notoSerifOttomanSiyaq = PartN.notoSerifOttomanSiyaq;
  static const notoSerifOttomanSiyaqTextTheme =
      PartN.notoSerifOttomanSiyaqTextTheme;
  static const notoSerifSc = PartN.notoSerifSc;
  static const notoSerifScTextTheme = PartN.notoSerifScTextTheme;
  static const notoSerifSinhala = PartN.notoSerifSinhala;
  static const notoSerifSinhalaTextTheme = PartN.notoSerifSinhalaTextTheme;
  static const notoSerifTc = PartN.notoSerifTc;
  static const notoSerifTcTextTheme = PartN.notoSerifTcTextTheme;
  static const notoSerifTamil = PartN.notoSerifTamil;
  static const notoSerifTamilTextTheme = PartN.notoSerifTamilTextTheme;
  static const notoSerifTangut = PartN.notoSerifTangut;
  static const notoSerifTangutTextTheme = PartN.notoSerifTangutTextTheme;
  static const notoSerifTelugu = PartN.notoSerifTelugu;
  static const notoSerifTeluguTextTheme = PartN.notoSerifTeluguTextTheme;
  static const notoSerifThai = PartN.notoSerifThai;
  static const notoSerifThaiTextTheme = PartN.notoSerifThaiTextTheme;
  static const notoSerifTibetan = PartN.notoSerifTibetan;
  static const notoSerifTibetanTextTheme = PartN.notoSerifTibetanTextTheme;
  static const notoSerifToto = PartN.notoSerifToto;
  static const notoSerifTotoTextTheme = PartN.notoSerifTotoTextTheme;
  static const notoSerifVithkuqi = PartN.notoSerifVithkuqi;
  static const notoSerifVithkuqiTextTheme = PartN.notoSerifVithkuqiTextTheme;
  static const notoSerifYezidi = PartN.notoSerifYezidi;
  static const notoSerifYezidiTextTheme = PartN.notoSerifYezidiTextTheme;
  static const notoTraditionalNushu = PartN.notoTraditionalNushu;
  static const notoTraditionalNushuTextTheme =
      PartN.notoTraditionalNushuTextTheme;
  static const notoZnamennyMusicalNotation = PartN.notoZnamennyMusicalNotation;
  static const notoZnamennyMusicalNotationTextTheme =
      PartN.notoZnamennyMusicalNotationTextTheme;
  static const novaCut = PartN.novaCut;
  static const novaCutTextTheme = PartN.novaCutTextTheme;
  static const novaFlat = PartN.novaFlat;
  static const novaFlatTextTheme = PartN.novaFlatTextTheme;
  static const novaMono = PartN.novaMono;
  static const novaMonoTextTheme = PartN.novaMonoTextTheme;
  static const novaOval = PartN.novaOval;
  static const novaOvalTextTheme = PartN.novaOvalTextTheme;
  static const novaRound = PartN.novaRound;
  static const novaRoundTextTheme = PartN.novaRoundTextTheme;
  static const novaScript = PartN.novaScript;
  static const novaScriptTextTheme = PartN.novaScriptTextTheme;
  static const novaSlim = PartN.novaSlim;
  static const novaSlimTextTheme = PartN.novaSlimTextTheme;
  static const novaSquare = PartN.novaSquare;
  static const novaSquareTextTheme = PartN.novaSquareTextTheme;
  static const numans = PartN.numans;
  static const numansTextTheme = PartN.numansTextTheme;
  static const nunito = PartN.nunito;
  static const nunitoTextTheme = PartN.nunitoTextTheme;
  static const nunitoSans = PartN.nunitoSans;
  static const nunitoSansTextTheme = PartN.nunitoSansTextTheme;
  static const nuosuSil = PartN.nuosuSil;
  static const nuosuSilTextTheme = PartN.nuosuSilTextTheme;
  static const odibeeSans = PartO.odibeeSans;
  static const odibeeSansTextTheme = PartO.odibeeSansTextTheme;
  static const odorMeanChey = PartO.odorMeanChey;
  static const odorMeanCheyTextTheme = PartO.odorMeanCheyTextTheme;
  static const offside = PartO.offside;
  static const offsideTextTheme = PartO.offsideTextTheme;
  static const oi = PartO.oi;
  static const oiTextTheme = PartO.oiTextTheme;
  static const ojuju = PartO.ojuju;
  static const ojujuTextTheme = PartO.ojujuTextTheme;
  static const oldStandardTt = PartO.oldStandardTt;
  static const oldStandardTtTextTheme = PartO.oldStandardTtTextTheme;
  static const oldenburg = PartO.oldenburg;
  static const oldenburgTextTheme = PartO.oldenburgTextTheme;
  static const ole = PartO.ole;
  static const oleTextTheme = PartO.oleTextTheme;
  static const oleoScript = PartO.oleoScript;
  static const oleoScriptTextTheme = PartO.oleoScriptTextTheme;
  static const oleoScriptSwashCaps = PartO.oleoScriptSwashCaps;
  static const oleoScriptSwashCapsTextTheme =
      PartO.oleoScriptSwashCapsTextTheme;
  static const onest = PartO.onest;
  static const onestTextTheme = PartO.onestTextTheme;
  static const ooohBaby = PartO.ooohBaby;
  static const ooohBabyTextTheme = PartO.ooohBabyTextTheme;
  static const openSans = PartO.openSans;
  static const openSansTextTheme = PartO.openSansTextTheme;
  static const openSansCondensed = PartO.openSansCondensed;
  static const openSansCondensedTextTheme = PartO.openSansCondensedTextTheme;
  static const oranienbaum = PartO.oranienbaum;
  static const oranienbaumTextTheme = PartO.oranienbaumTextTheme;
  static const orbit = PartO.orbit;
  static const orbitTextTheme = PartO.orbitTextTheme;
  static const orbitron = PartO.orbitron;
  static const orbitronTextTheme = PartO.orbitronTextTheme;
  static const oregano = PartO.oregano;
  static const oreganoTextTheme = PartO.oreganoTextTheme;
  static const orelegaOne = PartO.orelegaOne;
  static const orelegaOneTextTheme = PartO.orelegaOneTextTheme;
  static const orienta = PartO.orienta;
  static const orientaTextTheme = PartO.orientaTextTheme;
  static const originalSurfer = PartO.originalSurfer;
  static const originalSurferTextTheme = PartO.originalSurferTextTheme;
  static const oswald = PartO.oswald;
  static const oswaldTextTheme = PartO.oswaldTextTheme;
  static const outfit = PartO.outfit;
  static const outfitTextTheme = PartO.outfitTextTheme;
  static const overTheRainbow = PartO.overTheRainbow;
  static const overTheRainbowTextTheme = PartO.overTheRainbowTextTheme;
  static const overlock = PartO.overlock;
  static const overlockTextTheme = PartO.overlockTextTheme;
  static const overlockSc = PartO.overlockSc;
  static const overlockScTextTheme = PartO.overlockScTextTheme;
  static const overpass = PartO.overpass;
  static const overpassTextTheme = PartO.overpassTextTheme;
  static const overpassMono = PartO.overpassMono;
  static const overpassMonoTextTheme = PartO.overpassMonoTextTheme;
  static const ovo = PartO.ovo;
  static const ovoTextTheme = PartO.ovoTextTheme;
  static const oxanium = PartO.oxanium;
  static const oxaniumTextTheme = PartO.oxaniumTextTheme;
  static const oxygen = PartO.oxygen;
  static const oxygenTextTheme = PartO.oxygenTextTheme;
  static const oxygenMono = PartO.oxygenMono;
  static const oxygenMonoTextTheme = PartO.oxygenMonoTextTheme;
  static const ptMono = PartP.ptMono;
  static const ptMonoTextTheme = PartP.ptMonoTextTheme;
  static const ptSans = PartP.ptSans;
  static const ptSansTextTheme = PartP.ptSansTextTheme;
  static const ptSansCaption = PartP.ptSansCaption;
  static const ptSansCaptionTextTheme = PartP.ptSansCaptionTextTheme;
  static const ptSansNarrow = PartP.ptSansNarrow;
  static const ptSansNarrowTextTheme = PartP.ptSansNarrowTextTheme;
  static const ptSerif = PartP.ptSerif;
  static const ptSerifTextTheme = PartP.ptSerifTextTheme;
  static const ptSerifCaption = PartP.ptSerifCaption;
  static const ptSerifCaptionTextTheme = PartP.ptSerifCaptionTextTheme;
  static const pacifico = PartP.pacifico;
  static const pacificoTextTheme = PartP.pacificoTextTheme;
  static const padauk = PartP.padauk;
  static const padaukTextTheme = PartP.padaukTextTheme;
  static const padyakkeExpandedOne = PartP.padyakkeExpandedOne;
  static const padyakkeExpandedOneTextTheme =
      PartP.padyakkeExpandedOneTextTheme;
  static const palanquin = PartP.palanquin;
  static const palanquinTextTheme = PartP.palanquinTextTheme;
  static const palanquinDark = PartP.palanquinDark;
  static const palanquinDarkTextTheme = PartP.palanquinDarkTextTheme;
  static const paletteMosaic = PartP.paletteMosaic;
  static const paletteMosaicTextTheme = PartP.paletteMosaicTextTheme;
  static const pangolin = PartP.pangolin;
  static const pangolinTextTheme = PartP.pangolinTextTheme;
  static const paprika = PartP.paprika;
  static const paprikaTextTheme = PartP.paprikaTextTheme;
  static const parisienne = PartP.parisienne;
  static const parisienneTextTheme = PartP.parisienneTextTheme;
  static const passeroOne = PartP.passeroOne;
  static const passeroOneTextTheme = PartP.passeroOneTextTheme;
  static const passionOne = PartP.passionOne;
  static const passionOneTextTheme = PartP.passionOneTextTheme;
  static const passionsConflict = PartP.passionsConflict;
  static const passionsConflictTextTheme = PartP.passionsConflictTextTheme;
  static const pathwayExtreme = PartP.pathwayExtreme;
  static const pathwayExtremeTextTheme = PartP.pathwayExtremeTextTheme;
  static const pathwayGothicOne = PartP.pathwayGothicOne;
  static const pathwayGothicOneTextTheme = PartP.pathwayGothicOneTextTheme;
  static const patrickHand = PartP.patrickHand;
  static const patrickHandTextTheme = PartP.patrickHandTextTheme;
  static const patrickHandSc = PartP.patrickHandSc;
  static const patrickHandScTextTheme = PartP.patrickHandScTextTheme;
  static const pattaya = PartP.pattaya;
  static const pattayaTextTheme = PartP.pattayaTextTheme;
  static const patuaOne = PartP.patuaOne;
  static const patuaOneTextTheme = PartP.patuaOneTextTheme;
  static const pavanam = PartP.pavanam;
  static const pavanamTextTheme = PartP.pavanamTextTheme;
  static const paytoneOne = PartP.paytoneOne;
  static const paytoneOneTextTheme = PartP.paytoneOneTextTheme;
  static const peddana = PartP.peddana;
  static const peddanaTextTheme = PartP.peddanaTextTheme;
  static const peralta = PartP.peralta;
  static const peraltaTextTheme = PartP.peraltaTextTheme;
  static const permanentMarker = PartP.permanentMarker;
  static const permanentMarkerTextTheme = PartP.permanentMarkerTextTheme;
  static const petemoss = PartP.petemoss;
  static const petemossTextTheme = PartP.petemossTextTheme;
  static const petitFormalScript = PartP.petitFormalScript;
  static const petitFormalScriptTextTheme = PartP.petitFormalScriptTextTheme;
  static const petrona = PartP.petrona;
  static const petronaTextTheme = PartP.petronaTextTheme;
  static const philosopher = PartP.philosopher;
  static const philosopherTextTheme = PartP.philosopherTextTheme;
  static const phudu = PartP.phudu;
  static const phuduTextTheme = PartP.phuduTextTheme;
  static const piazzolla = PartP.piazzolla;
  static const piazzollaTextTheme = PartP.piazzollaTextTheme;
  static const piedra = PartP.piedra;
  static const piedraTextTheme = PartP.piedraTextTheme;
  static const pinyonScript = PartP.pinyonScript;
  static const pinyonScriptTextTheme = PartP.pinyonScriptTextTheme;
  static const pirataOne = PartP.pirataOne;
  static const pirataOneTextTheme = PartP.pirataOneTextTheme;
  static const pixelifySans = PartP.pixelifySans;
  static const pixelifySansTextTheme = PartP.pixelifySansTextTheme;
  static const plaster = PartP.plaster;
  static const plasterTextTheme = PartP.plasterTextTheme;
  static const platypi = PartP.platypi;
  static const platypiTextTheme = PartP.platypiTextTheme;
  static const play = PartP.play;
  static const playTextTheme = PartP.playTextTheme;
  static const playball = PartP.playball;
  static const playballTextTheme = PartP.playballTextTheme;
  static const playfair = PartP.playfair;
  static const playfairTextTheme = PartP.playfairTextTheme;
  static const playfairDisplay = PartP.playfairDisplay;
  static const playfairDisplayTextTheme = PartP.playfairDisplayTextTheme;
  static const playfairDisplaySc = PartP.playfairDisplaySc;
  static const playfairDisplayScTextTheme = PartP.playfairDisplayScTextTheme;
  static const playpenSans = PartP.playpenSans;
  static const playpenSansTextTheme = PartP.playpenSansTextTheme;
  static const playwriteAr = PartP.playwriteAr;
  static const playwriteArTextTheme = PartP.playwriteArTextTheme;
  static const playwriteAt = PartP.playwriteAt;
  static const playwriteAtTextTheme = PartP.playwriteAtTextTheme;
  static const playwriteAuNsw = PartP.playwriteAuNsw;
  static const playwriteAuNswTextTheme = PartP.playwriteAuNswTextTheme;
  static const playwriteAuQld = PartP.playwriteAuQld;
  static const playwriteAuQldTextTheme = PartP.playwriteAuQldTextTheme;
  static const playwriteAuSa = PartP.playwriteAuSa;
  static const playwriteAuSaTextTheme = PartP.playwriteAuSaTextTheme;
  static const playwriteAuTas = PartP.playwriteAuTas;
  static const playwriteAuTasTextTheme = PartP.playwriteAuTasTextTheme;
  static const playwriteAuVic = PartP.playwriteAuVic;
  static const playwriteAuVicTextTheme = PartP.playwriteAuVicTextTheme;
  static const playwriteBeVlg = PartP.playwriteBeVlg;
  static const playwriteBeVlgTextTheme = PartP.playwriteBeVlgTextTheme;
  static const playwriteBeWal = PartP.playwriteBeWal;
  static const playwriteBeWalTextTheme = PartP.playwriteBeWalTextTheme;
  static const playwriteBr = PartP.playwriteBr;
  static const playwriteBrTextTheme = PartP.playwriteBrTextTheme;
  static const playwriteCa = PartP.playwriteCa;
  static const playwriteCaTextTheme = PartP.playwriteCaTextTheme;
  static const playwriteCl = PartP.playwriteCl;
  static const playwriteClTextTheme = PartP.playwriteClTextTheme;
  static const playwriteCo = PartP.playwriteCo;
  static const playwriteCoTextTheme = PartP.playwriteCoTextTheme;
  static const playwriteCu = PartP.playwriteCu;
  static const playwriteCuTextTheme = PartP.playwriteCuTextTheme;
  static const playwriteCz = PartP.playwriteCz;
  static const playwriteCzTextTheme = PartP.playwriteCzTextTheme;
  static const playwriteDeGrund = PartP.playwriteDeGrund;
  static const playwriteDeGrundTextTheme = PartP.playwriteDeGrundTextTheme;
  static const playwriteDeLa = PartP.playwriteDeLa;
  static const playwriteDeLaTextTheme = PartP.playwriteDeLaTextTheme;
  static const playwriteDeSas = PartP.playwriteDeSas;
  static const playwriteDeSasTextTheme = PartP.playwriteDeSasTextTheme;
  static const playwriteDeVa = PartP.playwriteDeVa;
  static const playwriteDeVaTextTheme = PartP.playwriteDeVaTextTheme;
  static const playwriteDkLoopet = PartP.playwriteDkLoopet;
  static const playwriteDkLoopetTextTheme = PartP.playwriteDkLoopetTextTheme;
  static const playwriteDkUloopet = PartP.playwriteDkUloopet;
  static const playwriteDkUloopetTextTheme = PartP.playwriteDkUloopetTextTheme;
  static const playwriteEs = PartP.playwriteEs;
  static const playwriteEsTextTheme = PartP.playwriteEsTextTheme;
  static const playwriteEsDeco = PartP.playwriteEsDeco;
  static const playwriteEsDecoTextTheme = PartP.playwriteEsDecoTextTheme;
  static const playwriteFrModerne = PartP.playwriteFrModerne;
  static const playwriteFrModerneTextTheme = PartP.playwriteFrModerneTextTheme;
  static const playwriteFrTrad = PartP.playwriteFrTrad;
  static const playwriteFrTradTextTheme = PartP.playwriteFrTradTextTheme;
  static const playwriteGbJ = PartP.playwriteGbJ;
  static const playwriteGbJTextTheme = PartP.playwriteGbJTextTheme;
  static const playwriteGbS = PartP.playwriteGbS;
  static const playwriteGbSTextTheme = PartP.playwriteGbSTextTheme;
  static const playwriteHr = PartP.playwriteHr;
  static const playwriteHrTextTheme = PartP.playwriteHrTextTheme;
  static const playwriteHrLijeva = PartP.playwriteHrLijeva;
  static const playwriteHrLijevaTextTheme = PartP.playwriteHrLijevaTextTheme;
  static const playwriteHu = PartP.playwriteHu;
  static const playwriteHuTextTheme = PartP.playwriteHuTextTheme;
  static const playwriteId = PartP.playwriteId;
  static const playwriteIdTextTheme = PartP.playwriteIdTextTheme;
  static const playwriteIe = PartP.playwriteIe;
  static const playwriteIeTextTheme = PartP.playwriteIeTextTheme;
  static const playwriteIn = PartP.playwriteIn;
  static const playwriteInTextTheme = PartP.playwriteInTextTheme;
  static const playwriteIs = PartP.playwriteIs;
  static const playwriteIsTextTheme = PartP.playwriteIsTextTheme;
  static const playwriteItModerna = PartP.playwriteItModerna;
  static const playwriteItModernaTextTheme = PartP.playwriteItModernaTextTheme;
  static const playwriteItTrad = PartP.playwriteItTrad;
  static const playwriteItTradTextTheme = PartP.playwriteItTradTextTheme;
  static const playwriteMx = PartP.playwriteMx;
  static const playwriteMxTextTheme = PartP.playwriteMxTextTheme;
  static const playwriteNgModern = PartP.playwriteNgModern;
  static const playwriteNgModernTextTheme = PartP.playwriteNgModernTextTheme;
  static const playwriteNl = PartP.playwriteNl;
  static const playwriteNlTextTheme = PartP.playwriteNlTextTheme;
  static const playwriteNo = PartP.playwriteNo;
  static const playwriteNoTextTheme = PartP.playwriteNoTextTheme;
  static const playwriteNz = PartP.playwriteNz;
  static const playwriteNzTextTheme = PartP.playwriteNzTextTheme;
  static const playwritePe = PartP.playwritePe;
  static const playwritePeTextTheme = PartP.playwritePeTextTheme;
  static const playwritePl = PartP.playwritePl;
  static const playwritePlTextTheme = PartP.playwritePlTextTheme;
  static const playwritePt = PartP.playwritePt;
  static const playwritePtTextTheme = PartP.playwritePtTextTheme;
  static const playwriteRo = PartP.playwriteRo;
  static const playwriteRoTextTheme = PartP.playwriteRoTextTheme;
  static const playwriteSk = PartP.playwriteSk;
  static const playwriteSkTextTheme = PartP.playwriteSkTextTheme;
  static const playwriteTz = PartP.playwriteTz;
  static const playwriteTzTextTheme = PartP.playwriteTzTextTheme;
  static const playwriteUsModern = PartP.playwriteUsModern;
  static const playwriteUsModernTextTheme = PartP.playwriteUsModernTextTheme;
  static const playwriteUsTrad = PartP.playwriteUsTrad;
  static const playwriteUsTradTextTheme = PartP.playwriteUsTradTextTheme;
  static const playwriteVn = PartP.playwriteVn;
  static const playwriteVnTextTheme = PartP.playwriteVnTextTheme;
  static const playwriteZa = PartP.playwriteZa;
  static const playwriteZaTextTheme = PartP.playwriteZaTextTheme;
  static const plusJakartaSans = PartP.plusJakartaSans;
  static const plusJakartaSansTextTheme = PartP.plusJakartaSansTextTheme;
  static const podkova = PartP.podkova;
  static const podkovaTextTheme = PartP.podkovaTextTheme;
  static const poetsenOne = PartP.poetsenOne;
  static const poetsenOneTextTheme = PartP.poetsenOneTextTheme;
  static const poiretOne = PartP.poiretOne;
  static const poiretOneTextTheme = PartP.poiretOneTextTheme;
  static const pollerOne = PartP.pollerOne;
  static const pollerOneTextTheme = PartP.pollerOneTextTheme;
  static const poltawskiNowy = PartP.poltawskiNowy;
  static const poltawskiNowyTextTheme = PartP.poltawskiNowyTextTheme;
  static const poly = PartP.poly;
  static const polyTextTheme = PartP.polyTextTheme;
  static const pompiere = PartP.pompiere;
  static const pompiereTextTheme = PartP.pompiereTextTheme;
  static const pontanoSans = PartP.pontanoSans;
  static const pontanoSansTextTheme = PartP.pontanoSansTextTheme;
  static const poorStory = PartP.poorStory;
  static const poorStoryTextTheme = PartP.poorStoryTextTheme;
  static const poppins = PartP.poppins;
  static const poppinsTextTheme = PartP.poppinsTextTheme;
  static const portLligatSans = PartP.portLligatSans;
  static const portLligatSansTextTheme = PartP.portLligatSansTextTheme;
  static const portLligatSlab = PartP.portLligatSlab;
  static const portLligatSlabTextTheme = PartP.portLligatSlabTextTheme;
  static const pottaOne = PartP.pottaOne;
  static const pottaOneTextTheme = PartP.pottaOneTextTheme;
  static const pragatiNarrow = PartP.pragatiNarrow;
  static const pragatiNarrowTextTheme = PartP.pragatiNarrowTextTheme;
  static const praise = PartP.praise;
  static const praiseTextTheme = PartP.praiseTextTheme;
  static const prata = PartP.prata;
  static const prataTextTheme = PartP.prataTextTheme;
  static const preahvihear = PartP.preahvihear;
  static const preahvihearTextTheme = PartP.preahvihearTextTheme;
  static const pressStart2p = PartP.pressStart2p;
  static const pressStart2pTextTheme = PartP.pressStart2pTextTheme;
  static const pridi = PartP.pridi;
  static const pridiTextTheme = PartP.pridiTextTheme;
  static const princessSofia = PartP.princessSofia;
  static const princessSofiaTextTheme = PartP.princessSofiaTextTheme;
  static const prociono = PartP.prociono;
  static const procionoTextTheme = PartP.procionoTextTheme;
  static const prompt = PartP.prompt;
  static const promptTextTheme = PartP.promptTextTheme;
  static const prostoOne = PartP.prostoOne;
  static const prostoOneTextTheme = PartP.prostoOneTextTheme;
  static const protestGuerrilla = PartP.protestGuerrilla;
  static const protestGuerrillaTextTheme = PartP.protestGuerrillaTextTheme;
  static const protestRevolution = PartP.protestRevolution;
  static const protestRevolutionTextTheme = PartP.protestRevolutionTextTheme;
  static const protestRiot = PartP.protestRiot;
  static const protestRiotTextTheme = PartP.protestRiotTextTheme;
  static const protestStrike = PartP.protestStrike;
  static const protestStrikeTextTheme = PartP.protestStrikeTextTheme;
  static const prozaLibre = PartP.prozaLibre;
  static const prozaLibreTextTheme = PartP.prozaLibreTextTheme;
  static const publicSans = PartP.publicSans;
  static const publicSansTextTheme = PartP.publicSansTextTheme;
  static const puppiesPlay = PartP.puppiesPlay;
  static const puppiesPlayTextTheme = PartP.puppiesPlayTextTheme;
  static const puritan = PartP.puritan;
  static const puritanTextTheme = PartP.puritanTextTheme;
  static const purplePurse = PartP.purplePurse;
  static const purplePurseTextTheme = PartP.purplePurseTextTheme;
  static const qahiri = PartQ.qahiri;
  static const qahiriTextTheme = PartQ.qahiriTextTheme;
  static const quando = PartQ.quando;
  static const quandoTextTheme = PartQ.quandoTextTheme;
  static const quantico = PartQ.quantico;
  static const quanticoTextTheme = PartQ.quanticoTextTheme;
  static const quattrocento = PartQ.quattrocento;
  static const quattrocentoTextTheme = PartQ.quattrocentoTextTheme;
  static const quattrocentoSans = PartQ.quattrocentoSans;
  static const quattrocentoSansTextTheme = PartQ.quattrocentoSansTextTheme;
  static const questrial = PartQ.questrial;
  static const questrialTextTheme = PartQ.questrialTextTheme;
  static const quicksand = PartQ.quicksand;
  static const quicksandTextTheme = PartQ.quicksandTextTheme;
  static const quintessential = PartQ.quintessential;
  static const quintessentialTextTheme = PartQ.quintessentialTextTheme;
  static const qwigley = PartQ.qwigley;
  static const qwigleyTextTheme = PartQ.qwigleyTextTheme;
  static const qwitcherGrypen = PartQ.qwitcherGrypen;
  static const qwitcherGrypenTextTheme = PartQ.qwitcherGrypenTextTheme;
  static const rem = PartR.rem;
  static const remTextTheme = PartR.remTextTheme;
  static const racingSansOne = PartR.racingSansOne;
  static const racingSansOneTextTheme = PartR.racingSansOneTextTheme;
  static const radioCanada = PartR.radioCanada;
  static const radioCanadaTextTheme = PartR.radioCanadaTextTheme;
  static const radioCanadaBig = PartR.radioCanadaBig;
  static const radioCanadaBigTextTheme = PartR.radioCanadaBigTextTheme;
  static const radley = PartR.radley;
  static const radleyTextTheme = PartR.radleyTextTheme;
  static const rajdhani = PartR.rajdhani;
  static const rajdhaniTextTheme = PartR.rajdhaniTextTheme;
  static const rakkas = PartR.rakkas;
  static const rakkasTextTheme = PartR.rakkasTextTheme;
  static const raleway = PartR.raleway;
  static const ralewayTextTheme = PartR.ralewayTextTheme;
  static const ralewayDots = PartR.ralewayDots;
  static const ralewayDotsTextTheme = PartR.ralewayDotsTextTheme;
  static const ramabhadra = PartR.ramabhadra;
  static const ramabhadraTextTheme = PartR.ramabhadraTextTheme;
  static const ramaraja = PartR.ramaraja;
  static const ramarajaTextTheme = PartR.ramarajaTextTheme;
  static const rambla = PartR.rambla;
  static const ramblaTextTheme = PartR.ramblaTextTheme;
  static const rammettoOne = PartR.rammettoOne;
  static const rammettoOneTextTheme = PartR.rammettoOneTextTheme;
  static const rampartOne = PartR.rampartOne;
  static const rampartOneTextTheme = PartR.rampartOneTextTheme;
  static const ranchers = PartR.ranchers;
  static const ranchersTextTheme = PartR.ranchersTextTheme;
  static const rancho = PartR.rancho;
  static const ranchoTextTheme = PartR.ranchoTextTheme;
  static const ranga = PartR.ranga;
  static const rangaTextTheme = PartR.rangaTextTheme;
  static const rasa = PartR.rasa;
  static const rasaTextTheme = PartR.rasaTextTheme;
  static const rationale = PartR.rationale;
  static const rationaleTextTheme = PartR.rationaleTextTheme;
  static const raviPrakash = PartR.raviPrakash;
  static const raviPrakashTextTheme = PartR.raviPrakashTextTheme;
  static const readexPro = PartR.readexPro;
  static const readexProTextTheme = PartR.readexProTextTheme;
  static const recursive = PartR.recursive;
  static const recursiveTextTheme = PartR.recursiveTextTheme;
  static const redHatDisplay = PartR.redHatDisplay;
  static const redHatDisplayTextTheme = PartR.redHatDisplayTextTheme;
  static const redHatMono = PartR.redHatMono;
  static const redHatMonoTextTheme = PartR.redHatMonoTextTheme;
  static const redHatText = PartR.redHatText;
  static const redHatTextTextTheme = PartR.redHatTextTextTheme;
  static const redRose = PartR.redRose;
  static const redRoseTextTheme = PartR.redRoseTextTheme;
  static const redacted = PartR.redacted;
  static const redactedTextTheme = PartR.redactedTextTheme;
  static const redactedScript = PartR.redactedScript;
  static const redactedScriptTextTheme = PartR.redactedScriptTextTheme;
  static const redditMono = PartR.redditMono;
  static const redditMonoTextTheme = PartR.redditMonoTextTheme;
  static const redditSans = PartR.redditSans;
  static const redditSansTextTheme = PartR.redditSansTextTheme;
  static const redditSansCondensed = PartR.redditSansCondensed;
  static const redditSansCondensedTextTheme =
      PartR.redditSansCondensedTextTheme;
  static const redressed = PartR.redressed;
  static const redressedTextTheme = PartR.redressedTextTheme;
  static const reemKufi = PartR.reemKufi;
  static const reemKufiTextTheme = PartR.reemKufiTextTheme;
  static const reemKufiFun = PartR.reemKufiFun;
  static const reemKufiFunTextTheme = PartR.reemKufiFunTextTheme;
  static const reemKufiInk = PartR.reemKufiInk;
  static const reemKufiInkTextTheme = PartR.reemKufiInkTextTheme;
  static const reenieBeanie = PartR.reenieBeanie;
  static const reenieBeanieTextTheme = PartR.reenieBeanieTextTheme;
  static const reggaeOne = PartR.reggaeOne;
  static const reggaeOneTextTheme = PartR.reggaeOneTextTheme;
  static const rethinkSans = PartR.rethinkSans;
  static const rethinkSansTextTheme = PartR.rethinkSansTextTheme;
  static const revalia = PartR.revalia;
  static const revaliaTextTheme = PartR.revaliaTextTheme;
  static const rhodiumLibre = PartR.rhodiumLibre;
  static const rhodiumLibreTextTheme = PartR.rhodiumLibreTextTheme;
  static const ribeye = PartR.ribeye;
  static const ribeyeTextTheme = PartR.ribeyeTextTheme;
  static const ribeyeMarrow = PartR.ribeyeMarrow;
  static const ribeyeMarrowTextTheme = PartR.ribeyeMarrowTextTheme;
  static const righteous = PartR.righteous;
  static const righteousTextTheme = PartR.righteousTextTheme;
  static const risque = PartR.risque;
  static const risqueTextTheme = PartR.risqueTextTheme;
  static const roadRage = PartR.roadRage;
  static const roadRageTextTheme = PartR.roadRageTextTheme;
  static const roboto = PartR.roboto;
  static const robotoTextTheme = PartR.robotoTextTheme;
  static const robotoCondensed = PartR.robotoCondensed;
  static const robotoCondensedTextTheme = PartR.robotoCondensedTextTheme;
  static const robotoFlex = PartR.robotoFlex;
  static const robotoFlexTextTheme = PartR.robotoFlexTextTheme;
  static const robotoMono = PartR.robotoMono;
  static const robotoMonoTextTheme = PartR.robotoMonoTextTheme;
  static const robotoSerif = PartR.robotoSerif;
  static const robotoSerifTextTheme = PartR.robotoSerifTextTheme;
  static const robotoSlab = PartR.robotoSlab;
  static const robotoSlabTextTheme = PartR.robotoSlabTextTheme;
  static const rochester = PartR.rochester;
  static const rochesterTextTheme = PartR.rochesterTextTheme;
  static const rock3d = PartR.rock3d;
  static const rock3dTextTheme = PartR.rock3dTextTheme;
  static const rockSalt = PartR.rockSalt;
  static const rockSaltTextTheme = PartR.rockSaltTextTheme;
  static const rocknRollOne = PartR.rocknRollOne;
  static const rocknRollOneTextTheme = PartR.rocknRollOneTextTheme;
  static const rokkitt = PartR.rokkitt;
  static const rokkittTextTheme = PartR.rokkittTextTheme;
  static const romanesco = PartR.romanesco;
  static const romanescoTextTheme = PartR.romanescoTextTheme;
  static const ropaSans = PartR.ropaSans;
  static const ropaSansTextTheme = PartR.ropaSansTextTheme;
  static const rosario = PartR.rosario;
  static const rosarioTextTheme = PartR.rosarioTextTheme;
  static const rosarivo = PartR.rosarivo;
  static const rosarivoTextTheme = PartR.rosarivoTextTheme;
  static const rougeScript = PartR.rougeScript;
  static const rougeScriptTextTheme = PartR.rougeScriptTextTheme;
  static const rowdies = PartR.rowdies;
  static const rowdiesTextTheme = PartR.rowdiesTextTheme;
  static const rozhaOne = PartR.rozhaOne;
  static const rozhaOneTextTheme = PartR.rozhaOneTextTheme;
  static const rubik = PartR.rubik;
  static const rubikTextTheme = PartR.rubikTextTheme;
  static const rubik80sFade = PartR.rubik80sFade;
  static const rubik80sFadeTextTheme = PartR.rubik80sFadeTextTheme;
  static const rubikBeastly = PartR.rubikBeastly;
  static const rubikBeastlyTextTheme = PartR.rubikBeastlyTextTheme;
  static const rubikBrokenFax = PartR.rubikBrokenFax;
  static const rubikBrokenFaxTextTheme = PartR.rubikBrokenFaxTextTheme;
  static const rubikBubbles = PartR.rubikBubbles;
  static const rubikBubblesTextTheme = PartR.rubikBubblesTextTheme;
  static const rubikBurned = PartR.rubikBurned;
  static const rubikBurnedTextTheme = PartR.rubikBurnedTextTheme;
  static const rubikDirt = PartR.rubikDirt;
  static const rubikDirtTextTheme = PartR.rubikDirtTextTheme;
  static const rubikDistressed = PartR.rubikDistressed;
  static const rubikDistressedTextTheme = PartR.rubikDistressedTextTheme;
  static const rubikDoodleShadow = PartR.rubikDoodleShadow;
  static const rubikDoodleShadowTextTheme = PartR.rubikDoodleShadowTextTheme;
  static const rubikDoodleTriangles = PartR.rubikDoodleTriangles;
  static const rubikDoodleTrianglesTextTheme =
      PartR.rubikDoodleTrianglesTextTheme;
  static const rubikGemstones = PartR.rubikGemstones;
  static const rubikGemstonesTextTheme = PartR.rubikGemstonesTextTheme;
  static const rubikGlitch = PartR.rubikGlitch;
  static const rubikGlitchTextTheme = PartR.rubikGlitchTextTheme;
  static const rubikGlitchPop = PartR.rubikGlitchPop;
  static const rubikGlitchPopTextTheme = PartR.rubikGlitchPopTextTheme;
  static const rubikIso = PartR.rubikIso;
  static const rubikIsoTextTheme = PartR.rubikIsoTextTheme;
  static const rubikLines = PartR.rubikLines;
  static const rubikLinesTextTheme = PartR.rubikLinesTextTheme;
  static const rubikMaps = PartR.rubikMaps;
  static const rubikMapsTextTheme = PartR.rubikMapsTextTheme;
  static const rubikMarkerHatch = PartR.rubikMarkerHatch;
  static const rubikMarkerHatchTextTheme = PartR.rubikMarkerHatchTextTheme;
  static const rubikMaze = PartR.rubikMaze;
  static const rubikMazeTextTheme = PartR.rubikMazeTextTheme;
  static const rubikMicrobe = PartR.rubikMicrobe;
  static const rubikMicrobeTextTheme = PartR.rubikMicrobeTextTheme;
  static const rubikMonoOne = PartR.rubikMonoOne;
  static const rubikMonoOneTextTheme = PartR.rubikMonoOneTextTheme;
  static const rubikMoonrocks = PartR.rubikMoonrocks;
  static const rubikMoonrocksTextTheme = PartR.rubikMoonrocksTextTheme;
  static const rubikPixels = PartR.rubikPixels;
  static const rubikPixelsTextTheme = PartR.rubikPixelsTextTheme;
  static const rubikPuddles = PartR.rubikPuddles;
  static const rubikPuddlesTextTheme = PartR.rubikPuddlesTextTheme;
  static const rubikScribble = PartR.rubikScribble;
  static const rubikScribbleTextTheme = PartR.rubikScribbleTextTheme;
  static const rubikSprayPaint = PartR.rubikSprayPaint;
  static const rubikSprayPaintTextTheme = PartR.rubikSprayPaintTextTheme;
  static const rubikStorm = PartR.rubikStorm;
  static const rubikStormTextTheme = PartR.rubikStormTextTheme;
  static const rubikVinyl = PartR.rubikVinyl;
  static const rubikVinylTextTheme = PartR.rubikVinylTextTheme;
  static const rubikWetPaint = PartR.rubikWetPaint;
  static const rubikWetPaintTextTheme = PartR.rubikWetPaintTextTheme;
  static const ruda = PartR.ruda;
  static const rudaTextTheme = PartR.rudaTextTheme;
  static const rufina = PartR.rufina;
  static const rufinaTextTheme = PartR.rufinaTextTheme;
  static const rugeBoogie = PartR.rugeBoogie;
  static const rugeBoogieTextTheme = PartR.rugeBoogieTextTheme;
  static const ruluko = PartR.ruluko;
  static const rulukoTextTheme = PartR.rulukoTextTheme;
  static const rumRaisin = PartR.rumRaisin;
  static const rumRaisinTextTheme = PartR.rumRaisinTextTheme;
  static const ruslanDisplay = PartR.ruslanDisplay;
  static const ruslanDisplayTextTheme = PartR.ruslanDisplayTextTheme;
  static const russoOne = PartR.russoOne;
  static const russoOneTextTheme = PartR.russoOneTextTheme;
  static const ruthie = PartR.ruthie;
  static const ruthieTextTheme = PartR.ruthieTextTheme;
  static const ruwudu = PartR.ruwudu;
  static const ruwuduTextTheme = PartR.ruwuduTextTheme;
  static const rye = PartR.rye;
  static const ryeTextTheme = PartR.ryeTextTheme;
  static const stixTwoText = PartS.stixTwoText;
  static const stixTwoTextTextTheme = PartS.stixTwoTextTextTheme;
  static const sacramento = PartS.sacramento;
  static const sacramentoTextTheme = PartS.sacramentoTextTheme;
  static const sahitya = PartS.sahitya;
  static const sahityaTextTheme = PartS.sahityaTextTheme;
  static const sail = PartS.sail;
  static const sailTextTheme = PartS.sailTextTheme;
  static const saira = PartS.saira;
  static const sairaTextTheme = PartS.sairaTextTheme;
  static const sairaCondensed = PartS.sairaCondensed;
  static const sairaCondensedTextTheme = PartS.sairaCondensedTextTheme;
  static const sairaExtraCondensed = PartS.sairaExtraCondensed;
  static const sairaExtraCondensedTextTheme =
      PartS.sairaExtraCondensedTextTheme;
  static const sairaSemiCondensed = PartS.sairaSemiCondensed;
  static const sairaSemiCondensedTextTheme = PartS.sairaSemiCondensedTextTheme;
  static const sairaStencilOne = PartS.sairaStencilOne;
  static const sairaStencilOneTextTheme = PartS.sairaStencilOneTextTheme;
  static const salsa = PartS.salsa;
  static const salsaTextTheme = PartS.salsaTextTheme;
  static const sanchez = PartS.sanchez;
  static const sanchezTextTheme = PartS.sanchezTextTheme;
  static const sancreek = PartS.sancreek;
  static const sancreekTextTheme = PartS.sancreekTextTheme;
  static const sansita = PartS.sansita;
  static const sansitaTextTheme = PartS.sansitaTextTheme;
  static const sansitaSwashed = PartS.sansitaSwashed;
  static const sansitaSwashedTextTheme = PartS.sansitaSwashedTextTheme;
  static const sarabun = PartS.sarabun;
  static const sarabunTextTheme = PartS.sarabunTextTheme;
  static const sarala = PartS.sarala;
  static const saralaTextTheme = PartS.saralaTextTheme;
  static const sarina = PartS.sarina;
  static const sarinaTextTheme = PartS.sarinaTextTheme;
  static const sarpanch = PartS.sarpanch;
  static const sarpanchTextTheme = PartS.sarpanchTextTheme;
  static const sassyFrass = PartS.sassyFrass;
  static const sassyFrassTextTheme = PartS.sassyFrassTextTheme;
  static const satisfy = PartS.satisfy;
  static const satisfyTextTheme = PartS.satisfyTextTheme;
  static const sawarabiGothic = PartS.sawarabiGothic;
  static const sawarabiGothicTextTheme = PartS.sawarabiGothicTextTheme;
  static const sawarabiMincho = PartS.sawarabiMincho;
  static const sawarabiMinchoTextTheme = PartS.sawarabiMinchoTextTheme;
  static const scada = PartS.scada;
  static const scadaTextTheme = PartS.scadaTextTheme;
  static const scheherazadeNew = PartS.scheherazadeNew;
  static const scheherazadeNewTextTheme = PartS.scheherazadeNewTextTheme;
  static const schibstedGrotesk = PartS.schibstedGrotesk;
  static const schibstedGroteskTextTheme = PartS.schibstedGroteskTextTheme;
  static const schoolbell = PartS.schoolbell;
  static const schoolbellTextTheme = PartS.schoolbellTextTheme;
  static const scopeOne = PartS.scopeOne;
  static const scopeOneTextTheme = PartS.scopeOneTextTheme;
  static const seaweedScript = PartS.seaweedScript;
  static const seaweedScriptTextTheme = PartS.seaweedScriptTextTheme;
  static const secularOne = PartS.secularOne;
  static const secularOneTextTheme = PartS.secularOneTextTheme;
  static const sedan = PartS.sedan;
  static const sedanTextTheme = PartS.sedanTextTheme;
  static const sedanSc = PartS.sedanSc;
  static const sedanScTextTheme = PartS.sedanScTextTheme;
  static const sedgwickAve = PartS.sedgwickAve;
  static const sedgwickAveTextTheme = PartS.sedgwickAveTextTheme;
  static const sedgwickAveDisplay = PartS.sedgwickAveDisplay;
  static const sedgwickAveDisplayTextTheme = PartS.sedgwickAveDisplayTextTheme;
  static const sen = PartS.sen;
  static const senTextTheme = PartS.senTextTheme;
  static const sendFlowers = PartS.sendFlowers;
  static const sendFlowersTextTheme = PartS.sendFlowersTextTheme;
  static const sevillana = PartS.sevillana;
  static const sevillanaTextTheme = PartS.sevillanaTextTheme;
  static const seymourOne = PartS.seymourOne;
  static const seymourOneTextTheme = PartS.seymourOneTextTheme;
  static const shadowsIntoLight = PartS.shadowsIntoLight;
  static const shadowsIntoLightTextTheme = PartS.shadowsIntoLightTextTheme;
  static const shadowsIntoLightTwo = PartS.shadowsIntoLightTwo;
  static const shadowsIntoLightTwoTextTheme =
      PartS.shadowsIntoLightTwoTextTheme;
  static const shalimar = PartS.shalimar;
  static const shalimarTextTheme = PartS.shalimarTextTheme;
  static const shantellSans = PartS.shantellSans;
  static const shantellSansTextTheme = PartS.shantellSansTextTheme;
  static const shanti = PartS.shanti;
  static const shantiTextTheme = PartS.shantiTextTheme;
  static const share = PartS.share;
  static const shareTextTheme = PartS.shareTextTheme;
  static const shareTech = PartS.shareTech;
  static const shareTechTextTheme = PartS.shareTechTextTheme;
  static const shareTechMono = PartS.shareTechMono;
  static const shareTechMonoTextTheme = PartS.shareTechMonoTextTheme;
  static const shipporiAntique = PartS.shipporiAntique;
  static const shipporiAntiqueTextTheme = PartS.shipporiAntiqueTextTheme;
  static const shipporiAntiqueB1 = PartS.shipporiAntiqueB1;
  static const shipporiAntiqueB1TextTheme = PartS.shipporiAntiqueB1TextTheme;
  static const shipporiMincho = PartS.shipporiMincho;
  static const shipporiMinchoTextTheme = PartS.shipporiMinchoTextTheme;
  static const shipporiMinchoB1 = PartS.shipporiMinchoB1;
  static const shipporiMinchoB1TextTheme = PartS.shipporiMinchoB1TextTheme;
  static const shizuru = PartS.shizuru;
  static const shizuruTextTheme = PartS.shizuruTextTheme;
  static const shojumaru = PartS.shojumaru;
  static const shojumaruTextTheme = PartS.shojumaruTextTheme;
  static const shortStack = PartS.shortStack;
  static const shortStackTextTheme = PartS.shortStackTextTheme;
  static const shrikhand = PartS.shrikhand;
  static const shrikhandTextTheme = PartS.shrikhandTextTheme;
  static const siemreap = PartS.siemreap;
  static const siemreapTextTheme = PartS.siemreapTextTheme;
  static const sigmar = PartS.sigmar;
  static const sigmarTextTheme = PartS.sigmarTextTheme;
  static const sigmarOne = PartS.sigmarOne;
  static const sigmarOneTextTheme = PartS.sigmarOneTextTheme;
  static const signika = PartS.signika;
  static const signikaTextTheme = PartS.signikaTextTheme;
  static const signikaNegative = PartS.signikaNegative;
  static const signikaNegativeTextTheme = PartS.signikaNegativeTextTheme;
  static const silkscreen = PartS.silkscreen;
  static const silkscreenTextTheme = PartS.silkscreenTextTheme;
  static const simonetta = PartS.simonetta;
  static const simonettaTextTheme = PartS.simonettaTextTheme;
  static const singleDay = PartS.singleDay;
  static const singleDayTextTheme = PartS.singleDayTextTheme;
  static const sintony = PartS.sintony;
  static const sintonyTextTheme = PartS.sintonyTextTheme;
  static const sirinStencil = PartS.sirinStencil;
  static const sirinStencilTextTheme = PartS.sirinStencilTextTheme;
  static const sixCaps = PartS.sixCaps;
  static const sixCapsTextTheme = PartS.sixCapsTextTheme;
  static const sixtyfour = PartS.sixtyfour;
  static const sixtyfourTextTheme = PartS.sixtyfourTextTheme;
  static const skranji = PartS.skranji;
  static const skranjiTextTheme = PartS.skranjiTextTheme;
  static const slabo13px = PartS.slabo13px;
  static const slabo13pxTextTheme = PartS.slabo13pxTextTheme;
  static const slabo27px = PartS.slabo27px;
  static const slabo27pxTextTheme = PartS.slabo27pxTextTheme;
  static const slackey = PartS.slackey;
  static const slackeyTextTheme = PartS.slackeyTextTheme;
  static const slacksideOne = PartS.slacksideOne;
  static const slacksideOneTextTheme = PartS.slacksideOneTextTheme;
  static const smokum = PartS.smokum;
  static const smokumTextTheme = PartS.smokumTextTheme;
  static const smooch = PartS.smooch;
  static const smoochTextTheme = PartS.smoochTextTheme;
  static const smoochSans = PartS.smoochSans;
  static const smoochSansTextTheme = PartS.smoochSansTextTheme;
  static const smythe = PartS.smythe;
  static const smytheTextTheme = PartS.smytheTextTheme;
  static const sniglet = PartS.sniglet;
  static const snigletTextTheme = PartS.snigletTextTheme;
  static const snippet = PartS.snippet;
  static const snippetTextTheme = PartS.snippetTextTheme;
  static const snowburstOne = PartS.snowburstOne;
  static const snowburstOneTextTheme = PartS.snowburstOneTextTheme;
  static const sofadiOne = PartS.sofadiOne;
  static const sofadiOneTextTheme = PartS.sofadiOneTextTheme;
  static const sofia = PartS.sofia;
  static const sofiaTextTheme = PartS.sofiaTextTheme;
  static const sofiaSans = PartS.sofiaSans;
  static const sofiaSansTextTheme = PartS.sofiaSansTextTheme;
  static const sofiaSansCondensed = PartS.sofiaSansCondensed;
  static const sofiaSansCondensedTextTheme = PartS.sofiaSansCondensedTextTheme;
  static const sofiaSansExtraCondensed = PartS.sofiaSansExtraCondensed;
  static const sofiaSansExtraCondensedTextTheme =
      PartS.sofiaSansExtraCondensedTextTheme;
  static const sofiaSansSemiCondensed = PartS.sofiaSansSemiCondensed;
  static const sofiaSansSemiCondensedTextTheme =
      PartS.sofiaSansSemiCondensedTextTheme;
  static const solitreo = PartS.solitreo;
  static const solitreoTextTheme = PartS.solitreoTextTheme;
  static const solway = PartS.solway;
  static const solwayTextTheme = PartS.solwayTextTheme;
  static const sometypeMono = PartS.sometypeMono;
  static const sometypeMonoTextTheme = PartS.sometypeMonoTextTheme;
  static const songMyung = PartS.songMyung;
  static const songMyungTextTheme = PartS.songMyungTextTheme;
  static const sono = PartS.sono;
  static const sonoTextTheme = PartS.sonoTextTheme;
  static const sonsieOne = PartS.sonsieOne;
  static const sonsieOneTextTheme = PartS.sonsieOneTextTheme;
  static const sora = PartS.sora;
  static const soraTextTheme = PartS.soraTextTheme;
  static const sortsMillGoudy = PartS.sortsMillGoudy;
  static const sortsMillGoudyTextTheme = PartS.sortsMillGoudyTextTheme;
  static const sourceCodePro = PartS.sourceCodePro;
  static const sourceCodeProTextTheme = PartS.sourceCodeProTextTheme;
  static const sourceSans3 = PartS.sourceSans3;
  static const sourceSans3TextTheme = PartS.sourceSans3TextTheme;
  static const sourceSerif4 = PartS.sourceSerif4;
  static const sourceSerif4TextTheme = PartS.sourceSerif4TextTheme;
  static const spaceGrotesk = PartS.spaceGrotesk;
  static const spaceGroteskTextTheme = PartS.spaceGroteskTextTheme;
  static const spaceMono = PartS.spaceMono;
  static const spaceMonoTextTheme = PartS.spaceMonoTextTheme;
  static const specialElite = PartS.specialElite;
  static const specialEliteTextTheme = PartS.specialEliteTextTheme;
  static const spectral = PartS.spectral;
  static const spectralTextTheme = PartS.spectralTextTheme;
  static const spectralSc = PartS.spectralSc;
  static const spectralScTextTheme = PartS.spectralScTextTheme;
  static const spicyRice = PartS.spicyRice;
  static const spicyRiceTextTheme = PartS.spicyRiceTextTheme;
  static const spinnaker = PartS.spinnaker;
  static const spinnakerTextTheme = PartS.spinnakerTextTheme;
  static const spirax = PartS.spirax;
  static const spiraxTextTheme = PartS.spiraxTextTheme;
  static const splash = PartS.splash;
  static const splashTextTheme = PartS.splashTextTheme;
  static const splineSans = PartS.splineSans;
  static const splineSansTextTheme = PartS.splineSansTextTheme;
  static const splineSansMono = PartS.splineSansMono;
  static const splineSansMonoTextTheme = PartS.splineSansMonoTextTheme;
  static const squadaOne = PartS.squadaOne;
  static const squadaOneTextTheme = PartS.squadaOneTextTheme;
  static const squarePeg = PartS.squarePeg;
  static const squarePegTextTheme = PartS.squarePegTextTheme;
  static const sreeKrushnadevaraya = PartS.sreeKrushnadevaraya;
  static const sreeKrushnadevarayaTextTheme =
      PartS.sreeKrushnadevarayaTextTheme;
  static const sriracha = PartS.sriracha;
  static const srirachaTextTheme = PartS.srirachaTextTheme;
  static const srisakdi = PartS.srisakdi;
  static const srisakdiTextTheme = PartS.srisakdiTextTheme;
  static const staatliches = PartS.staatliches;
  static const staatlichesTextTheme = PartS.staatlichesTextTheme;
  static const stalemate = PartS.stalemate;
  static const stalemateTextTheme = PartS.stalemateTextTheme;
  static const stalinistOne = PartS.stalinistOne;
  static const stalinistOneTextTheme = PartS.stalinistOneTextTheme;
  static const stardosStencil = PartS.stardosStencil;
  static const stardosStencilTextTheme = PartS.stardosStencilTextTheme;
  static const stick = PartS.stick;
  static const stickTextTheme = PartS.stickTextTheme;
  static const stickNoBills = PartS.stickNoBills;
  static const stickNoBillsTextTheme = PartS.stickNoBillsTextTheme;
  static const stintUltraCondensed = PartS.stintUltraCondensed;
  static const stintUltraCondensedTextTheme =
      PartS.stintUltraCondensedTextTheme;
  static const stintUltraExpanded = PartS.stintUltraExpanded;
  static const stintUltraExpandedTextTheme = PartS.stintUltraExpandedTextTheme;
  static const stoke = PartS.stoke;
  static const stokeTextTheme = PartS.stokeTextTheme;
  static const strait = PartS.strait;
  static const straitTextTheme = PartS.straitTextTheme;
  static const styleScript = PartS.styleScript;
  static const styleScriptTextTheme = PartS.styleScriptTextTheme;
  static const stylish = PartS.stylish;
  static const stylishTextTheme = PartS.stylishTextTheme;
  static const sueEllenFrancisco = PartS.sueEllenFrancisco;
  static const sueEllenFranciscoTextTheme = PartS.sueEllenFranciscoTextTheme;
  static const suezOne = PartS.suezOne;
  static const suezOneTextTheme = PartS.suezOneTextTheme;
  static const sulphurPoint = PartS.sulphurPoint;
  static const sulphurPointTextTheme = PartS.sulphurPointTextTheme;
  static const sumana = PartS.sumana;
  static const sumanaTextTheme = PartS.sumanaTextTheme;
  static const sunflower = PartS.sunflower;
  static const sunflowerTextTheme = PartS.sunflowerTextTheme;
  static const sunshiney = PartS.sunshiney;
  static const sunshineyTextTheme = PartS.sunshineyTextTheme;
  static const supermercadoOne = PartS.supermercadoOne;
  static const supermercadoOneTextTheme = PartS.supermercadoOneTextTheme;
  static const sura = PartS.sura;
  static const suraTextTheme = PartS.suraTextTheme;
  static const suranna = PartS.suranna;
  static const surannaTextTheme = PartS.surannaTextTheme;
  static const suravaram = PartS.suravaram;
  static const suravaramTextTheme = PartS.suravaramTextTheme;
  static const suwannaphum = PartS.suwannaphum;
  static const suwannaphumTextTheme = PartS.suwannaphumTextTheme;
  static const swankyAndMooMoo = PartS.swankyAndMooMoo;
  static const swankyAndMooMooTextTheme = PartS.swankyAndMooMooTextTheme;
  static const syncopate = PartS.syncopate;
  static const syncopateTextTheme = PartS.syncopateTextTheme;
  static const syne = PartS.syne;
  static const syneTextTheme = PartS.syneTextTheme;
  static const syneMono = PartS.syneMono;
  static const syneMonoTextTheme = PartS.syneMonoTextTheme;
  static const syneTactile = PartS.syneTactile;
  static const syneTactileTextTheme = PartS.syneTactileTextTheme;
  static const tacOne = PartT.tacOne;
  static const tacOneTextTheme = PartT.tacOneTextTheme;
  static const taiHeritagePro = PartT.taiHeritagePro;
  static const taiHeritageProTextTheme = PartT.taiHeritageProTextTheme;
  static const tajawal = PartT.tajawal;
  static const tajawalTextTheme = PartT.tajawalTextTheme;
  static const tangerine = PartT.tangerine;
  static const tangerineTextTheme = PartT.tangerineTextTheme;
  static const tapestry = PartT.tapestry;
  static const tapestryTextTheme = PartT.tapestryTextTheme;
  static const taprom = PartT.taprom;
  static const tapromTextTheme = PartT.tapromTextTheme;
  static const tauri = PartT.tauri;
  static const tauriTextTheme = PartT.tauriTextTheme;
  static const taviraj = PartT.taviraj;
  static const tavirajTextTheme = PartT.tavirajTextTheme;
  static const teachers = PartT.teachers;
  static const teachersTextTheme = PartT.teachersTextTheme;
  static const teko = PartT.teko;
  static const tekoTextTheme = PartT.tekoTextTheme;
  static const tektur = PartT.tektur;
  static const tekturTextTheme = PartT.tekturTextTheme;
  static const telex = PartT.telex;
  static const telexTextTheme = PartT.telexTextTheme;
  static const tenaliRamakrishna = PartT.tenaliRamakrishna;
  static const tenaliRamakrishnaTextTheme = PartT.tenaliRamakrishnaTextTheme;
  static const tenorSans = PartT.tenorSans;
  static const tenorSansTextTheme = PartT.tenorSansTextTheme;
  static const textMeOne = PartT.textMeOne;
  static const textMeOneTextTheme = PartT.textMeOneTextTheme;
  static const texturina = PartT.texturina;
  static const texturinaTextTheme = PartT.texturinaTextTheme;
  static const thasadith = PartT.thasadith;
  static const thasadithTextTheme = PartT.thasadithTextTheme;
  static const theGirlNextDoor = PartT.theGirlNextDoor;
  static const theGirlNextDoorTextTheme = PartT.theGirlNextDoorTextTheme;
  static const theNautigal = PartT.theNautigal;
  static const theNautigalTextTheme = PartT.theNautigalTextTheme;
  static const tienne = PartT.tienne;
  static const tienneTextTheme = PartT.tienneTextTheme;
  static const tillana = PartT.tillana;
  static const tillanaTextTheme = PartT.tillanaTextTheme;
  static const tiltNeon = PartT.tiltNeon;
  static const tiltNeonTextTheme = PartT.tiltNeonTextTheme;
  static const tiltPrism = PartT.tiltPrism;
  static const tiltPrismTextTheme = PartT.tiltPrismTextTheme;
  static const tiltWarp = PartT.tiltWarp;
  static const tiltWarpTextTheme = PartT.tiltWarpTextTheme;
  static const timmana = PartT.timmana;
  static const timmanaTextTheme = PartT.timmanaTextTheme;
  static const tinos = PartT.tinos;
  static const tinosTextTheme = PartT.tinosTextTheme;
  static const tiny5 = PartT.tiny5;
  static const tiny5TextTheme = PartT.tiny5TextTheme;
  static const tiroBangla = PartT.tiroBangla;
  static const tiroBanglaTextTheme = PartT.tiroBanglaTextTheme;
  static const tiroDevanagariHindi = PartT.tiroDevanagariHindi;
  static const tiroDevanagariHindiTextTheme =
      PartT.tiroDevanagariHindiTextTheme;
  static const tiroDevanagariMarathi = PartT.tiroDevanagariMarathi;
  static const tiroDevanagariMarathiTextTheme =
      PartT.tiroDevanagariMarathiTextTheme;
  static const tiroDevanagariSanskrit = PartT.tiroDevanagariSanskrit;
  static const tiroDevanagariSanskritTextTheme =
      PartT.tiroDevanagariSanskritTextTheme;
  static const tiroGurmukhi = PartT.tiroGurmukhi;
  static const tiroGurmukhiTextTheme = PartT.tiroGurmukhiTextTheme;
  static const tiroKannada = PartT.tiroKannada;
  static const tiroKannadaTextTheme = PartT.tiroKannadaTextTheme;
  static const tiroTamil = PartT.tiroTamil;
  static const tiroTamilTextTheme = PartT.tiroTamilTextTheme;
  static const tiroTelugu = PartT.tiroTelugu;
  static const tiroTeluguTextTheme = PartT.tiroTeluguTextTheme;
  static const titanOne = PartT.titanOne;
  static const titanOneTextTheme = PartT.titanOneTextTheme;
  static const titilliumWeb = PartT.titilliumWeb;
  static const titilliumWebTextTheme = PartT.titilliumWebTextTheme;
  static const tomorrow = PartT.tomorrow;
  static const tomorrowTextTheme = PartT.tomorrowTextTheme;
  static const tourney = PartT.tourney;
  static const tourneyTextTheme = PartT.tourneyTextTheme;
  static const tradeWinds = PartT.tradeWinds;
  static const tradeWindsTextTheme = PartT.tradeWindsTextTheme;
  static const trainOne = PartT.trainOne;
  static const trainOneTextTheme = PartT.trainOneTextTheme;
  static const trirong = PartT.trirong;
  static const trirongTextTheme = PartT.trirongTextTheme;
  static const trispace = PartT.trispace;
  static const trispaceTextTheme = PartT.trispaceTextTheme;
  static const trocchi = PartT.trocchi;
  static const trocchiTextTheme = PartT.trocchiTextTheme;
  static const trochut = PartT.trochut;
  static const trochutTextTheme = PartT.trochutTextTheme;
  static const truculenta = PartT.truculenta;
  static const truculentaTextTheme = PartT.truculentaTextTheme;
  static const trykker = PartT.trykker;
  static const trykkerTextTheme = PartT.trykkerTextTheme;
  static const tsukimiRounded = PartT.tsukimiRounded;
  static const tsukimiRoundedTextTheme = PartT.tsukimiRoundedTextTheme;
  static const tulpenOne = PartT.tulpenOne;
  static const tulpenOneTextTheme = PartT.tulpenOneTextTheme;
  static const turretRoad = PartT.turretRoad;
  static const turretRoadTextTheme = PartT.turretRoadTextTheme;
  static const twinkleStar = PartT.twinkleStar;
  static const twinkleStarTextTheme = PartT.twinkleStarTextTheme;
  static const ubuntu = PartU.ubuntu;
  static const ubuntuTextTheme = PartU.ubuntuTextTheme;
  static const ubuntuCondensed = PartU.ubuntuCondensed;
  static const ubuntuCondensedTextTheme = PartU.ubuntuCondensedTextTheme;
  static const ubuntuMono = PartU.ubuntuMono;
  static const ubuntuMonoTextTheme = PartU.ubuntuMonoTextTheme;
  static const ubuntuSans = PartU.ubuntuSans;
  static const ubuntuSansTextTheme = PartU.ubuntuSansTextTheme;
  static const ubuntuSansMono = PartU.ubuntuSansMono;
  static const ubuntuSansMonoTextTheme = PartU.ubuntuSansMonoTextTheme;
  static const uchen = PartU.uchen;
  static const uchenTextTheme = PartU.uchenTextTheme;
  static const ultra = PartU.ultra;
  static const ultraTextTheme = PartU.ultraTextTheme;
  static const unbounded = PartU.unbounded;
  static const unboundedTextTheme = PartU.unboundedTextTheme;
  static const uncialAntiqua = PartU.uncialAntiqua;
  static const uncialAntiquaTextTheme = PartU.uncialAntiquaTextTheme;
  static const underdog = PartU.underdog;
  static const underdogTextTheme = PartU.underdogTextTheme;
  static const unicaOne = PartU.unicaOne;
  static const unicaOneTextTheme = PartU.unicaOneTextTheme;
  static const unifrakturCook = PartU.unifrakturCook;
  static const unifrakturCookTextTheme = PartU.unifrakturCookTextTheme;
  static const unifrakturMaguntia = PartU.unifrakturMaguntia;
  static const unifrakturMaguntiaTextTheme = PartU.unifrakturMaguntiaTextTheme;
  static const unkempt = PartU.unkempt;
  static const unkemptTextTheme = PartU.unkemptTextTheme;
  static const unlock = PartU.unlock;
  static const unlockTextTheme = PartU.unlockTextTheme;
  static const unna = PartU.unna;
  static const unnaTextTheme = PartU.unnaTextTheme;
  static const updock = PartU.updock;
  static const updockTextTheme = PartU.updockTextTheme;
  static const urbanist = PartU.urbanist;
  static const urbanistTextTheme = PartU.urbanistTextTheme;
  static const vt323 = PartV.vt323;
  static const vt323TextTheme = PartV.vt323TextTheme;
  static const vampiroOne = PartV.vampiroOne;
  static const vampiroOneTextTheme = PartV.vampiroOneTextTheme;
  static const varela = PartV.varela;
  static const varelaTextTheme = PartV.varelaTextTheme;
  static const varelaRound = PartV.varelaRound;
  static const varelaRoundTextTheme = PartV.varelaRoundTextTheme;
  static const varta = PartV.varta;
  static const vartaTextTheme = PartV.vartaTextTheme;
  static const vastShadow = PartV.vastShadow;
  static const vastShadowTextTheme = PartV.vastShadowTextTheme;
  static const vazirmatn = PartV.vazirmatn;
  static const vazirmatnTextTheme = PartV.vazirmatnTextTheme;
  static const vesperLibre = PartV.vesperLibre;
  static const vesperLibreTextTheme = PartV.vesperLibreTextTheme;
  static const viaodaLibre = PartV.viaodaLibre;
  static const viaodaLibreTextTheme = PartV.viaodaLibreTextTheme;
  static const vibes = PartV.vibes;
  static const vibesTextTheme = PartV.vibesTextTheme;
  static const vibur = PartV.vibur;
  static const viburTextTheme = PartV.viburTextTheme;
  static const victorMono = PartV.victorMono;
  static const victorMonoTextTheme = PartV.victorMonoTextTheme;
  static const vidaloka = PartV.vidaloka;
  static const vidalokaTextTheme = PartV.vidalokaTextTheme;
  static const viga = PartV.viga;
  static const vigaTextTheme = PartV.vigaTextTheme;
  static const vinaSans = PartV.vinaSans;
  static const vinaSansTextTheme = PartV.vinaSansTextTheme;
  static const voces = PartV.voces;
  static const vocesTextTheme = PartV.vocesTextTheme;
  static const volkhov = PartV.volkhov;
  static const volkhovTextTheme = PartV.volkhovTextTheme;
  static const vollkorn = PartV.vollkorn;
  static const vollkornTextTheme = PartV.vollkornTextTheme;
  static const vollkornSc = PartV.vollkornSc;
  static const vollkornScTextTheme = PartV.vollkornScTextTheme;
  static const voltaire = PartV.voltaire;
  static const voltaireTextTheme = PartV.voltaireTextTheme;
  static const vujahdayScript = PartV.vujahdayScript;
  static const vujahdayScriptTextTheme = PartV.vujahdayScriptTextTheme;
  static const waitingForTheSunrise = PartW.waitingForTheSunrise;
  static const waitingForTheSunriseTextTheme =
      PartW.waitingForTheSunriseTextTheme;
  static const wallpoet = PartW.wallpoet;
  static const wallpoetTextTheme = PartW.wallpoetTextTheme;
  static const walterTurncoat = PartW.walterTurncoat;
  static const walterTurncoatTextTheme = PartW.walterTurncoatTextTheme;
  static const warnes = PartW.warnes;
  static const warnesTextTheme = PartW.warnesTextTheme;
  static const waterBrush = PartW.waterBrush;
  static const waterBrushTextTheme = PartW.waterBrushTextTheme;
  static const waterfall = PartW.waterfall;
  static const waterfallTextTheme = PartW.waterfallTextTheme;
  static const wavefont = PartW.wavefont;
  static const wavefontTextTheme = PartW.wavefontTextTheme;
  static const wellfleet = PartW.wellfleet;
  static const wellfleetTextTheme = PartW.wellfleetTextTheme;
  static const wendyOne = PartW.wendyOne;
  static const wendyOneTextTheme = PartW.wendyOneTextTheme;
  static const whisper = PartW.whisper;
  static const whisperTextTheme = PartW.whisperTextTheme;
  static const windSong = PartW.windSong;
  static const windSongTextTheme = PartW.windSongTextTheme;
  static const wireOne = PartW.wireOne;
  static const wireOneTextTheme = PartW.wireOneTextTheme;
  static const wittgenstein = PartW.wittgenstein;
  static const wittgensteinTextTheme = PartW.wittgensteinTextTheme;
  static const wixMadeforDisplay = PartW.wixMadeforDisplay;
  static const wixMadeforDisplayTextTheme = PartW.wixMadeforDisplayTextTheme;
  static const wixMadeforText = PartW.wixMadeforText;
  static const wixMadeforTextTextTheme = PartW.wixMadeforTextTextTheme;
  static const workSans = PartW.workSans;
  static const workSansTextTheme = PartW.workSansTextTheme;
  static const workbench = PartW.workbench;
  static const workbenchTextTheme = PartW.workbenchTextTheme;
  static const xanhMono = PartX.xanhMono;
  static const xanhMonoTextTheme = PartX.xanhMonoTextTheme;
  static const yaldevi = PartY.yaldevi;
  static const yaldeviTextTheme = PartY.yaldeviTextTheme;
  static const yanoneKaffeesatz = PartY.yanoneKaffeesatz;
  static const yanoneKaffeesatzTextTheme = PartY.yanoneKaffeesatzTextTheme;
  static const yantramanav = PartY.yantramanav;
  static const yantramanavTextTheme = PartY.yantramanavTextTheme;
  static const yarndings12 = PartY.yarndings12;
  static const yarndings12TextTheme = PartY.yarndings12TextTheme;
  static const yarndings12Charted = PartY.yarndings12Charted;
  static const yarndings12ChartedTextTheme = PartY.yarndings12ChartedTextTheme;
  static const yarndings20 = PartY.yarndings20;
  static const yarndings20TextTheme = PartY.yarndings20TextTheme;
  static const yarndings20Charted = PartY.yarndings20Charted;
  static const yarndings20ChartedTextTheme = PartY.yarndings20ChartedTextTheme;
  static const yatraOne = PartY.yatraOne;
  static const yatraOneTextTheme = PartY.yatraOneTextTheme;
  static const yellowtail = PartY.yellowtail;
  static const yellowtailTextTheme = PartY.yellowtailTextTheme;
  static const yeonSung = PartY.yeonSung;
  static const yeonSungTextTheme = PartY.yeonSungTextTheme;
  static const yesevaOne = PartY.yesevaOne;
  static const yesevaOneTextTheme = PartY.yesevaOneTextTheme;
  static const yesteryear = PartY.yesteryear;
  static const yesteryearTextTheme = PartY.yesteryearTextTheme;
  static const yomogi = PartY.yomogi;
  static const yomogiTextTheme = PartY.yomogiTextTheme;
  static const youngSerif = PartY.youngSerif;
  static const youngSerifTextTheme = PartY.youngSerifTextTheme;
  static const yrsa = PartY.yrsa;
  static const yrsaTextTheme = PartY.yrsaTextTheme;
  static const ysabeau = PartY.ysabeau;
  static const ysabeauTextTheme = PartY.ysabeauTextTheme;
  static const ysabeauInfant = PartY.ysabeauInfant;
  static const ysabeauInfantTextTheme = PartY.ysabeauInfantTextTheme;
  static const ysabeauOffice = PartY.ysabeauOffice;
  static const ysabeauOfficeTextTheme = PartY.ysabeauOfficeTextTheme;
  static const ysabeauSc = PartY.ysabeauSc;
  static const ysabeauScTextTheme = PartY.ysabeauScTextTheme;
  static const yujiBoku = PartY.yujiBoku;
  static const yujiBokuTextTheme = PartY.yujiBokuTextTheme;
  static const yujiHentaiganaAkari = PartY.yujiHentaiganaAkari;
  static const yujiHentaiganaAkariTextTheme =
      PartY.yujiHentaiganaAkariTextTheme;
  static const yujiHentaiganaAkebono = PartY.yujiHentaiganaAkebono;
  static const yujiHentaiganaAkebonoTextTheme =
      PartY.yujiHentaiganaAkebonoTextTheme;
  static const yujiMai = PartY.yujiMai;
  static const yujiMaiTextTheme = PartY.yujiMaiTextTheme;
  static const yujiSyuku = PartY.yujiSyuku;
  static const yujiSyukuTextTheme = PartY.yujiSyukuTextTheme;
  static const yuseiMagic = PartY.yuseiMagic;
  static const yuseiMagicTextTheme = PartY.yuseiMagicTextTheme;
  static const zcoolKuaiLe = PartZ.zcoolKuaiLe;
  static const zcoolKuaiLeTextTheme = PartZ.zcoolKuaiLeTextTheme;
  static const zcoolQingKeHuangYou = PartZ.zcoolQingKeHuangYou;
  static const zcoolQingKeHuangYouTextTheme =
      PartZ.zcoolQingKeHuangYouTextTheme;
  static const zcoolXiaoWei = PartZ.zcoolXiaoWei;
  static const zcoolXiaoWeiTextTheme = PartZ.zcoolXiaoWeiTextTheme;
  static const zain = PartZ.zain;
  static const zainTextTheme = PartZ.zainTextTheme;
  static const zenAntique = PartZ.zenAntique;
  static const zenAntiqueTextTheme = PartZ.zenAntiqueTextTheme;
  static const zenAntiqueSoft = PartZ.zenAntiqueSoft;
  static const zenAntiqueSoftTextTheme = PartZ.zenAntiqueSoftTextTheme;
  static const zenDots = PartZ.zenDots;
  static const zenDotsTextTheme = PartZ.zenDotsTextTheme;
  static const zenKakuGothicAntique = PartZ.zenKakuGothicAntique;
  static const zenKakuGothicAntiqueTextTheme =
      PartZ.zenKakuGothicAntiqueTextTheme;
  static const zenKakuGothicNew = PartZ.zenKakuGothicNew;
  static const zenKakuGothicNewTextTheme = PartZ.zenKakuGothicNewTextTheme;
  static const zenKurenaido = PartZ.zenKurenaido;
  static const zenKurenaidoTextTheme = PartZ.zenKurenaidoTextTheme;
  static const zenLoop = PartZ.zenLoop;
  static const zenLoopTextTheme = PartZ.zenLoopTextTheme;
  static const zenMaruGothic = PartZ.zenMaruGothic;
  static const zenMaruGothicTextTheme = PartZ.zenMaruGothicTextTheme;
  static const zenOldMincho = PartZ.zenOldMincho;
  static const zenOldMinchoTextTheme = PartZ.zenOldMinchoTextTheme;
  static const zenTokyoZoo = PartZ.zenTokyoZoo;
  static const zenTokyoZooTextTheme = PartZ.zenTokyoZooTextTheme;
  static const zeyada = PartZ.zeyada;
  static const zeyadaTextTheme = PartZ.zeyadaTextTheme;
  static const zhiMangXing = PartZ.zhiMangXing;
  static const zhiMangXingTextTheme = PartZ.zhiMangXingTextTheme;
  static const zillaSlab = PartZ.zillaSlab;
  static const zillaSlabTextTheme = PartZ.zillaSlabTextTheme;
  static const zillaSlabHighlight = PartZ.zillaSlabHighlight;
  static const zillaSlabHighlightTextTheme = PartZ.zillaSlabHighlightTextTheme;
}
