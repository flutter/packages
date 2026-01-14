// GENERATED CODE - DO NOT EDIT

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: specify_nonobvious_property_types, specify_nonobvious_local_variable_types

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'google_fonts_base.dart';
import 'google_fonts_parts/part_a.dart';
import 'google_fonts_parts/part_b.dart';
import 'google_fonts_parts/part_c.dart';
import 'google_fonts_parts/part_d.dart';
import 'google_fonts_parts/part_e.dart';
import 'google_fonts_parts/part_f.dart';
import 'google_fonts_parts/part_g.dart';
import 'google_fonts_parts/part_h.dart';
import 'google_fonts_parts/part_i.dart';
import 'google_fonts_parts/part_j.dart';
import 'google_fonts_parts/part_k.dart';
import 'google_fonts_parts/part_l.dart';
import 'google_fonts_parts/part_m.dart';
import 'google_fonts_parts/part_n.dart';
import 'google_fonts_parts/part_o.dart';
import 'google_fonts_parts/part_p.dart';
import 'google_fonts_parts/part_q.dart';
import 'google_fonts_parts/part_r.dart';
import 'google_fonts_parts/part_s.dart';
import 'google_fonts_parts/part_t.dart';
import 'google_fonts_parts/part_u.dart';
import 'google_fonts_parts/part_v.dart';
import 'google_fonts_parts/part_w.dart';
import 'google_fonts_parts/part_x.dart';
import 'google_fonts_parts/part_y.dart';
import 'google_fonts_parts/part_z.dart';

/// A collection of properties used to specify custom behavior of the
/// GoogleFonts library.
class Config {
  /// Whether or not the GoogleFonts library can make requests to
  /// [fonts.google.com](https://fonts.google.com/) to retrieve font files.
  bool allowRuntimeFetching = true;
}

/// Provides configuration, and static methods to obtain [TextStyle]s and [TextTheme]s.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=8Vzv2CdbEY0}
///
/// Obtain a map of available fonts with [asMap]. Retrieve a font by family name
/// with [getFont]. Retrieve a text theme by its font family name [getTextTheme].
///
/// Check out the [README](https://pub.dev/packages/google_fonts) for more info.
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
  static final Config config = Config();

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
    })
  >
  asMap() => const {
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
    'Afacad Flux': PartA.afacadFlux,
    'Agbalumo': PartA.agbalumo,
    'Agdasima': PartA.agdasima,
    'Agu Display': PartA.aguDisplay,
    'Aguafina Script': PartA.aguafinaScript,
    'Akatab': PartA.akatab,
    'Akaya Kanadaka': PartA.akayaKanadaka,
    'Akaya Telivigala': PartA.akayaTelivigala,
    'Akronim': PartA.akronim,
    'Akshar': PartA.akshar,
    'Aladin': PartA.aladin,
    'Alan Sans': PartA.alanSans,
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
    'Alumni Sans SC': PartA.alumniSansSc,
    'Amarante': PartA.amarante,
    'Amaranth': PartA.amaranth,
    'Amatic SC': PartA.amaticSc,
    'Amethysta': PartA.amethysta,
    'Amiko': PartA.amiko,
    'Amiri': PartA.amiri,
    'Amiri Quran': PartA.amiriQuran,
    'Amita': PartA.amita,
    'Anaheim': PartA.anaheim,
    'Ancizar Sans': PartA.ancizarSans,
    'Ancizar Serif': PartA.ancizarSerif,
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
    'Asar': PartA.asar,
    'Asimovian': PartA.asimovian,
    'Asset': PartA.asset,
    'Assistant': PartA.assistant,
    'Asta Sans': PartA.astaSans,
    'Astloch': PartA.astloch,
    'Asul': PartA.asul,
    'Athiti': PartA.athiti,
    'Atkinson Hyperlegible': PartA.atkinsonHyperlegible,
    'Atkinson Hyperlegible Mono': PartA.atkinsonHyperlegibleMono,
    'Atkinson Hyperlegible Next': PartA.atkinsonHyperlegibleNext,
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
    'Badeen Display': PartB.badeenDisplay,
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
    'Big Shoulders': PartB.bigShoulders,
    'Big Shoulders Inline': PartB.bigShouldersInline,
    'Big Shoulders Stencil': PartB.bigShouldersStencil,
    'Bigelow Rules': PartB.bigelowRules,
    'Bigshot One': PartB.bigshotOne,
    'Bilbo': PartB.bilbo,
    'Bilbo Swash Caps': PartB.bilboSwashCaps,
    'BioRhyme': PartB.bioRhyme,
    'Birthstone': PartB.birthstone,
    'Birthstone Bounce': PartB.birthstoneBounce,
    'Biryani': PartB.biryani,
    'Bitcount': PartB.bitcount,
    'Bitcount Grid Double': PartB.bitcountGridDouble,
    'Bitcount Grid Double Ink': PartB.bitcountGridDoubleInk,
    'Bitcount Grid Single': PartB.bitcountGridSingle,
    'Bitcount Grid Single Ink': PartB.bitcountGridSingleInk,
    'Bitcount Ink': PartB.bitcountInk,
    'Bitcount Prop Double': PartB.bitcountPropDouble,
    'Bitcount Prop Double Ink': PartB.bitcountPropDoubleInk,
    'Bitcount Prop Single': PartB.bitcountPropSingle,
    'Bitcount Prop Single Ink': PartB.bitcountPropSingleInk,
    'Bitcount Single': PartB.bitcountSingle,
    'Bitcount Single Ink': PartB.bitcountSingleInk,
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
    'Boldonse': PartB.boldonse,
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
    'Bungee Tint': PartB.bungeeTint,
    'Butcherman': PartB.butcherman,
    'Butterfly Kids': PartB.butterflyKids,
    'Bytesized': PartB.bytesized,
    'Cabin': PartC.cabin,
    'Cabin Sketch': PartC.cabinSketch,
    'Cactus Classical Serif': PartC.cactusClassicalSerif,
    'Caesar Dressing': PartC.caesarDressing,
    'Cagliostro': PartC.cagliostro,
    'Cairo': PartC.cairo,
    'Cairo Play': PartC.cairoPlay,
    'Cal Sans': PartC.calSans,
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
    'Cascadia Code': PartC.cascadiaCode,
    'Cascadia Mono': PartC.cascadiaMono,
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
    'Chiron GoRound TC': PartC.chironGoRoundTc,
    'Chiron Hei HK': PartC.chironHeiHk,
    'Chiron Sung HK': PartC.chironSungHk,
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
    'Comic Relief': PartC.comicRelief,
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
    'Coral Pixels': PartC.coralPixels,
    'Corben': PartC.corben,
    'Corinthia': PartC.corinthia,
    'Cormorant': PartC.cormorant,
    'Cormorant Garamond': PartC.cormorantGaramond,
    'Cormorant Infant': PartC.cormorantInfant,
    'Cormorant SC': PartC.cormorantSc,
    'Cormorant Unicase': PartC.cormorantUnicase,
    'Cormorant Upright': PartC.cormorantUpright,
    'Cossette Texte': PartC.cossetteTexte,
    'Cossette Titre': PartC.cossetteTitre,
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
    'Doto': PartD.doto,
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
    'Edu AU VIC WA NT Arrows': PartE.eduAuVicWaNtArrows,
    'Edu AU VIC WA NT Dots': PartE.eduAuVicWaNtDots,
    'Edu AU VIC WA NT Guides': PartE.eduAuVicWaNtGuides,
    'Edu AU VIC WA NT Hand': PartE.eduAuVicWaNtHand,
    'Edu AU VIC WA NT Pre': PartE.eduAuVicWaNtPre,
    'Edu NSW ACT Cursive': PartE.eduNswActCursive,
    'Edu NSW ACT Foundation': PartE.eduNswActFoundation,
    'Edu NSW ACT Hand Pre': PartE.eduNswActHandPre,
    'Edu QLD Beginner': PartE.eduQldBeginner,
    'Edu QLD Hand': PartE.eduQldHand,
    'Edu SA Beginner': PartE.eduSaBeginner,
    'Edu SA Hand': PartE.eduSaHand,
    'Edu TAS Beginner': PartE.eduTasBeginner,
    'Edu VIC WA NT Beginner': PartE.eduVicWaNtBeginner,
    'Edu VIC WA NT Hand': PartE.eduVicWaNtHand,
    'Edu VIC WA NT Hand Pre': PartE.eduVicWaNtHandPre,
    'El Messiri': PartE.elMessiri,
    'Electrolize': PartE.electrolize,
    'Elsie': PartE.elsie,
    'Elsie Swash Caps': PartE.elsieSwashCaps,
    'Emblema One': PartE.emblemaOne,
    'Emilys Candy': PartE.emilysCandy,
    'Encode Sans': PartE.encodeSans,
    'Encode Sans SC': PartE.encodeSansSc,
    'Engagement': PartE.engagement,
    'Englebert': PartE.englebert,
    'Enriqueta': PartE.enriqueta,
    'Ephesis': PartE.ephesis,
    'Epilogue': PartE.epilogue,
    'Epunda Sans': PartE.epundaSans,
    'Epunda Slab': PartE.epundaSlab,
    'Erica One': PartE.ericaOne,
    'Esteban': PartE.esteban,
    'Estonia': PartE.estonia,
    'Euphoria Script': PartE.euphoriaScript,
    'Ewert': PartE.ewert,
    'Exile': PartE.exile,
    'Exo': PartE.exo,
    'Exo 2': PartE.exo2,
    'Expletus Sans': PartE.expletusSans,
    'Explora': PartE.explora,
    'Faculty Glyphic': PartF.facultyGlyphic,
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
    'Funnel Display': PartF.funnelDisplay,
    'Funnel Sans': PartF.funnelSans,
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
    'Geist': PartG.geist,
    'Geist Mono': PartG.geistMono,
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
    'Gidole': PartG.gidole,
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
    'Google Sans Code': PartG.googleSansCode,
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
    'Hind Mysuru': PartH.hindMysuru,
    'Hind Siliguri': PartH.hindSiliguri,
    'Hind Vadodara': PartH.hindVadodara,
    'Holtwood One SC': PartH.holtwoodOneSc,
    'Homemade Apple': PartH.homemadeApple,
    'Homenaje': PartH.homenaje,
    'Honk': PartH.honk,
    'Host Grotesk': PartH.hostGrotesk,
    'Hubballi': PartH.hubballi,
    'Hubot Sans': PartH.hubotSans,
    'Huninn': PartH.huninn,
    'Hurricane': PartH.hurricane,
    'IBM Plex Mono': PartI.ibmPlexMono,
    'IBM Plex Sans': PartI.ibmPlexSans,
    'IBM Plex Sans Arabic': PartI.ibmPlexSansArabic,
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
    'Iansui': PartI.iansui,
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
    'Intel One Mono': PartI.intelOneMono,
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
    'Kanchenjunga': PartK.kanchenjunga,
    'Kanit': PartK.kanit,
    'Kantumruy Pro': PartK.kantumruyPro,
    'Kapakana': PartK.kapakana,
    'Karantina': PartK.karantina,
    'Karla': PartK.karla,
    'Karla Tamil Inclined': PartK.karlaTamilInclined,
    'Karla Tamil Upright': PartK.karlaTamilUpright,
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
    'LXGW Marker Gothic': PartL.lxgwMarkerGothic,
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
    'Libertinus Keyboard': PartL.libertinusKeyboard,
    'Libertinus Math': PartL.libertinusMath,
    'Libertinus Mono': PartL.libertinusMono,
    'Libertinus Sans': PartL.libertinusSans,
    'Libertinus Serif': PartL.libertinusSerif,
    'Libertinus Serif Display': PartL.libertinusSerifDisplay,
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
    'Liter': PartL.liter,
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
    'Manufacturing Consent': PartM.manufacturingConsent,
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
    'Matangi': PartM.matangi,
    'Mate': PartM.mate,
    'Mate SC': PartM.mateSc,
    'Matemasie': PartM.matemasie,
    'Maven Pro': PartM.mavenPro,
    'McLaren': PartM.mcLaren,
    'Mea Culpa': PartM.meaCulpa,
    'Meddon': PartM.meddon,
    'MedievalSharp': PartM.medievalSharp,
    'Medula One': PartM.medulaOne,
    'Meera Inimai': PartM.meeraInimai,
    'Megrim': PartM.megrim,
    'Meie Script': PartM.meieScript,
    'Menbere': PartM.menbere,
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
    'Moderustic': PartM.moderustic,
    'Mogra': PartM.mogra,
    'Mohave': PartM.mohave,
    'Moirai One': PartM.moiraiOne,
    'Molengo': PartM.molengo,
    'Molle': PartM.molle,
    'Mona Sans': PartM.monaSans,
    'Monda': PartM.monda,
    'Monofett': PartM.monofett,
    'Monomakh': PartM.monomakh,
    'Monomaniac One': PartM.monomaniacOne,
    'Monoton': PartM.monoton,
    'Monsieur La Doulaise': PartM.monsieurLaDoulaise,
    'Montaga': PartM.montaga,
    'Montagu Slab': PartM.montaguSlab,
    'MonteCarlo': PartM.monteCarlo,
    'Montez': PartM.montez,
    'Montserrat': PartM.montserrat,
    'Montserrat Alternates': PartM.montserratAlternates,
    'Montserrat Underline': PartM.montserratUnderline,
    'Moo Lah Lah': PartM.mooLahLah,
    'Mooli': PartM.mooli,
    'Moon Dance': PartM.moonDance,
    'Moul': PartM.moul,
    'Moulpali': PartM.moulpali,
    'Mountains of Christmas': PartM.mountainsOfChristmas,
    'Mouse Memoirs': PartM.mouseMemoirs,
    'Mozilla Headline': PartM.mozillaHeadline,
    'Mozilla Text': PartM.mozillaText,
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
    'Nata Sans': PartN.nataSans,
    'National Park': PartN.nationalPark,
    'Neonderthaw': PartN.neonderthaw,
    'Nerko One': PartN.nerkoOne,
    'Neucha': PartN.neucha,
    'Neuton': PartN.neuton,
    'New Amsterdam': PartN.newAmsterdam,
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
    'Noto Sans PhagsPa': PartN.notoSansPhagsPa,
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
    'Noto Sans Sunuwar': PartN.notoSansSunuwar,
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
    'Noto Serif Dives Akuru': PartN.notoSerifDivesAkuru,
    'Noto Serif Dogra': PartN.notoSerifDogra,
    'Noto Serif Ethiopic': PartN.notoSerifEthiopic,
    'Noto Serif Georgian': PartN.notoSerifGeorgian,
    'Noto Serif Grantha': PartN.notoSerifGrantha,
    'Noto Serif Gujarati': PartN.notoSerifGujarati,
    'Noto Serif Gurmukhi': PartN.notoSerifGurmukhi,
    'Noto Serif HK': PartN.notoSerifHk,
    'Noto Serif Hebrew': PartN.notoSerifHebrew,
    'Noto Serif Hentaigana': PartN.notoSerifHentaigana,
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
    'Noto Serif Todhri': PartN.notoSerifTodhri,
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
    'Parastoo': PartP.parastoo,
    'Parisienne': PartP.parisienne,
    'Parkinsans': PartP.parkinsans,
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
    'Phetsarath': PartP.phetsarath,
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
    'Playpen Sans Arabic': PartP.playpenSansArabic,
    'Playpen Sans Deva': PartP.playpenSansDeva,
    'Playpen Sans Hebrew': PartP.playpenSansHebrew,
    'Playpen Sans Thai': PartP.playpenSansThai,
    'Playwrite AR': PartP.playwriteAr,
    'Playwrite AR Guides': PartP.playwriteArGuides,
    'Playwrite AT': PartP.playwriteAt,
    'Playwrite AT Guides': PartP.playwriteAtGuides,
    'Playwrite AU NSW': PartP.playwriteAuNsw,
    'Playwrite AU NSW Guides': PartP.playwriteAuNswGuides,
    'Playwrite AU QLD': PartP.playwriteAuQld,
    'Playwrite AU QLD Guides': PartP.playwriteAuQldGuides,
    'Playwrite AU SA': PartP.playwriteAuSa,
    'Playwrite AU SA Guides': PartP.playwriteAuSaGuides,
    'Playwrite AU TAS': PartP.playwriteAuTas,
    'Playwrite AU TAS Guides': PartP.playwriteAuTasGuides,
    'Playwrite AU VIC': PartP.playwriteAuVic,
    'Playwrite AU VIC Guides': PartP.playwriteAuVicGuides,
    'Playwrite BE VLG': PartP.playwriteBeVlg,
    'Playwrite BE VLG Guides': PartP.playwriteBeVlgGuides,
    'Playwrite BE WAL': PartP.playwriteBeWal,
    'Playwrite BE WAL Guides': PartP.playwriteBeWalGuides,
    'Playwrite BR': PartP.playwriteBr,
    'Playwrite BR Guides': PartP.playwriteBrGuides,
    'Playwrite CA': PartP.playwriteCa,
    'Playwrite CA Guides': PartP.playwriteCaGuides,
    'Playwrite CL': PartP.playwriteCl,
    'Playwrite CL Guides': PartP.playwriteClGuides,
    'Playwrite CO': PartP.playwriteCo,
    'Playwrite CO Guides': PartP.playwriteCoGuides,
    'Playwrite CU': PartP.playwriteCu,
    'Playwrite CU Guides': PartP.playwriteCuGuides,
    'Playwrite CZ': PartP.playwriteCz,
    'Playwrite CZ Guides': PartP.playwriteCzGuides,
    'Playwrite DE Grund': PartP.playwriteDeGrund,
    'Playwrite DE Grund Guides': PartP.playwriteDeGrundGuides,
    'Playwrite DE LA': PartP.playwriteDeLa,
    'Playwrite DE LA Guides': PartP.playwriteDeLaGuides,
    'Playwrite DE SAS': PartP.playwriteDeSas,
    'Playwrite DE SAS Guides': PartP.playwriteDeSasGuides,
    'Playwrite DE VA': PartP.playwriteDeVa,
    'Playwrite DE VA Guides': PartP.playwriteDeVaGuides,
    'Playwrite DK Loopet': PartP.playwriteDkLoopet,
    'Playwrite DK Loopet Guides': PartP.playwriteDkLoopetGuides,
    'Playwrite DK Uloopet': PartP.playwriteDkUloopet,
    'Playwrite DK Uloopet Guides': PartP.playwriteDkUloopetGuides,
    'Playwrite ES': PartP.playwriteEs,
    'Playwrite ES Deco': PartP.playwriteEsDeco,
    'Playwrite ES Deco Guides': PartP.playwriteEsDecoGuides,
    'Playwrite ES Guides': PartP.playwriteEsGuides,
    'Playwrite FR Moderne': PartP.playwriteFrModerne,
    'Playwrite FR Moderne Guides': PartP.playwriteFrModerneGuides,
    'Playwrite FR Trad': PartP.playwriteFrTrad,
    'Playwrite FR Trad Guides': PartP.playwriteFrTradGuides,
    'Playwrite GB J': PartP.playwriteGbJ,
    'Playwrite GB J Guides': PartP.playwriteGbJGuides,
    'Playwrite GB S': PartP.playwriteGbS,
    'Playwrite GB S Guides': PartP.playwriteGbSGuides,
    'Playwrite HR': PartP.playwriteHr,
    'Playwrite HR Guides': PartP.playwriteHrGuides,
    'Playwrite HR Lijeva': PartP.playwriteHrLijeva,
    'Playwrite HR Lijeva Guides': PartP.playwriteHrLijevaGuides,
    'Playwrite HU': PartP.playwriteHu,
    'Playwrite HU Guides': PartP.playwriteHuGuides,
    'Playwrite ID': PartP.playwriteId,
    'Playwrite ID Guides': PartP.playwriteIdGuides,
    'Playwrite IE': PartP.playwriteIe,
    'Playwrite IE Guides': PartP.playwriteIeGuides,
    'Playwrite IN': PartP.playwriteIn,
    'Playwrite IN Guides': PartP.playwriteInGuides,
    'Playwrite IS': PartP.playwriteIs,
    'Playwrite IS Guides': PartP.playwriteIsGuides,
    'Playwrite IT Moderna': PartP.playwriteItModerna,
    'Playwrite IT Moderna Guides': PartP.playwriteItModernaGuides,
    'Playwrite IT Trad': PartP.playwriteItTrad,
    'Playwrite IT Trad Guides': PartP.playwriteItTradGuides,
    'Playwrite MX': PartP.playwriteMx,
    'Playwrite MX Guides': PartP.playwriteMxGuides,
    'Playwrite NG Modern': PartP.playwriteNgModern,
    'Playwrite NG Modern Guides': PartP.playwriteNgModernGuides,
    'Playwrite NL': PartP.playwriteNl,
    'Playwrite NL Guides': PartP.playwriteNlGuides,
    'Playwrite NO': PartP.playwriteNo,
    'Playwrite NO Guides': PartP.playwriteNoGuides,
    'Playwrite NZ': PartP.playwriteNz,
    'Playwrite NZ Guides': PartP.playwriteNzGuides,
    'Playwrite PE': PartP.playwritePe,
    'Playwrite PE Guides': PartP.playwritePeGuides,
    'Playwrite PL': PartP.playwritePl,
    'Playwrite PL Guides': PartP.playwritePlGuides,
    'Playwrite PT': PartP.playwritePt,
    'Playwrite PT Guides': PartP.playwritePtGuides,
    'Playwrite RO': PartP.playwriteRo,
    'Playwrite RO Guides': PartP.playwriteRoGuides,
    'Playwrite SK': PartP.playwriteSk,
    'Playwrite SK Guides': PartP.playwriteSkGuides,
    'Playwrite TZ': PartP.playwriteTz,
    'Playwrite TZ Guides': PartP.playwriteTzGuides,
    'Playwrite US Modern': PartP.playwriteUsModern,
    'Playwrite US Modern Guides': PartP.playwriteUsModernGuides,
    'Playwrite US Trad': PartP.playwriteUsTrad,
    'Playwrite US Trad Guides': PartP.playwriteUsTradGuides,
    'Playwrite VN': PartP.playwriteVn,
    'Playwrite VN Guides': PartP.playwriteVnGuides,
    'Playwrite ZA': PartP.playwriteZa,
    'Playwrite ZA Guides': PartP.playwriteZaGuides,
    'Plus Jakarta Sans': PartP.plusJakartaSans,
    'Pochaevsk': PartP.pochaevsk,
    'Podkova': PartP.podkova,
    'Poetsen One': PartP.poetsenOne,
    'Poiret One': PartP.poiretOne,
    'Poller One': PartP.pollerOne,
    'Poltawski Nowy': PartP.poltawskiNowy,
    'Poly': PartP.poly,
    'Pompiere': PartP.pompiere,
    'Ponnala': PartP.ponnala,
    'Ponomar': PartP.ponomar,
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
    'SUSE': PartS.suse,
    'SUSE Mono': PartS.suseMono,
    'Sacramento': PartS.sacramento,
    'Sahitya': PartS.sahitya,
    'Sail': PartS.sail,
    'Saira': PartS.saira,
    'Saira Stencil One': PartS.sairaStencilOne,
    'Salsa': PartS.salsa,
    'Sanchez': PartS.sanchez,
    'Sancreek': PartS.sancreek,
    'Sankofa Display': PartS.sankofaDisplay,
    'Sansation': PartS.sansation,
    'Sansita': PartS.sansita,
    'Sansita Swashed': PartS.sansitaSwashed,
    'Sarabun': PartS.sarabun,
    'Sarala': PartS.sarala,
    'Sarina': PartS.sarina,
    'Sarpanch': PartS.sarpanch,
    'Sassy Frass': PartS.sassyFrass,
    'Satisfy': PartS.satisfy,
    'Savate': PartS.savate,
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
    'Shafarik': PartS.shafarik,
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
    'Sirivennela': PartS.sirivennela,
    'Six Caps': PartS.sixCaps,
    'Sixtyfour': PartS.sixtyfour,
    'Sixtyfour Convergence': PartS.sixtyfourConvergence,
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
    'Sour Gummy': PartS.sourGummy,
    'Source Code Pro': PartS.sourceCodePro,
    'Source Sans 3': PartS.sourceSans3,
    'Source Serif 4': PartS.sourceSerif4,
    'Space Grotesk': PartS.spaceGrotesk,
    'Space Mono': PartS.spaceMono,
    'Special Elite': PartS.specialElite,
    'Special Gothic': PartS.specialGothic,
    'Special Gothic Condensed One': PartS.specialGothicCondensedOne,
    'Special Gothic Expanded One': PartS.specialGothicExpandedOne,
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
    'Story Script': PartS.storyScript,
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
    'TASA Explorer': PartT.tasaExplorer,
    'TASA Orbiter': PartT.tasaOrbiter,
    'Tac One': PartT.tacOne,
    'Tagesschrift': PartT.tagesschrift,
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
    'TikTok Sans': PartT.tikTokSans,
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
    'Tirra': PartT.tirra,
    'Titan One': PartT.titanOne,
    'Titillium Web': PartT.titilliumWeb,
    'Tomorrow': PartT.tomorrow,
    'Tourney': PartT.tourney,
    'Trade Winds': PartT.tradeWinds,
    'Train One': PartT.trainOne,
    'Triodion': PartT.triodion,
    'Trirong': PartT.trirong,
    'Trispace': PartT.trispace,
    'Trocchi': PartT.trocchi,
    'Trochut': PartT.trochut,
    'Truculenta': PartT.truculenta,
    'Trykker': PartT.trykker,
    'Tsukimi Rounded': PartT.tsukimiRounded,
    'Tuffy': PartT.tuffy,
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
    'UoqMunThenKhung': PartU.uoqMunThenKhung,
    'Updock': PartU.updock,
    'Urbanist': PartU.urbanist,
    'VT323': PartV.vt323,
    'Vampiro One': PartV.vampiroOne,
    'Varela': PartV.varela,
    'Varela Round': PartV.varelaRound,
    'Varta': PartV.varta,
    'Vast Shadow': PartV.vastShadow,
    'Vazirmatn': PartV.vazirmatn,
    'Vend Sans': PartV.vendSans,
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
    'WDXL Lubrifont JP N': PartW.wdxlLubrifontJpN,
    'WDXL Lubrifont SC': PartW.wdxlLubrifontSc,
    'WDXL Lubrifont TC': PartW.wdxlLubrifontTc,
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
    'Winky Rough': PartW.winkyRough,
    'Winky Sans': PartW.winkySans,
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
    'Zalando Sans': PartZ.zalandoSans,
    'Zalando Sans Expanded': PartZ.zalandoSansExpanded,
    'Zalando Sans SemiExpanded': PartZ.zalandoSansSemiExpanded,
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
  static Map<String, TextTheme Function([TextTheme?])>
  _asMapOfTextThemes() => const {
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
    'Afacad Flux': PartA.afacadFluxTextTheme,
    'Agbalumo': PartA.agbalumoTextTheme,
    'Agdasima': PartA.agdasimaTextTheme,
    'Agu Display': PartA.aguDisplayTextTheme,
    'Aguafina Script': PartA.aguafinaScriptTextTheme,
    'Akatab': PartA.akatabTextTheme,
    'Akaya Kanadaka': PartA.akayaKanadakaTextTheme,
    'Akaya Telivigala': PartA.akayaTelivigalaTextTheme,
    'Akronim': PartA.akronimTextTheme,
    'Akshar': PartA.aksharTextTheme,
    'Aladin': PartA.aladinTextTheme,
    'Alan Sans': PartA.alanSansTextTheme,
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
    'Alumni Sans SC': PartA.alumniSansScTextTheme,
    'Amarante': PartA.amaranteTextTheme,
    'Amaranth': PartA.amaranthTextTheme,
    'Amatic SC': PartA.amaticScTextTheme,
    'Amethysta': PartA.amethystaTextTheme,
    'Amiko': PartA.amikoTextTheme,
    'Amiri': PartA.amiriTextTheme,
    'Amiri Quran': PartA.amiriQuranTextTheme,
    'Amita': PartA.amitaTextTheme,
    'Anaheim': PartA.anaheimTextTheme,
    'Ancizar Sans': PartA.ancizarSansTextTheme,
    'Ancizar Serif': PartA.ancizarSerifTextTheme,
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
    'Asar': PartA.asarTextTheme,
    'Asimovian': PartA.asimovianTextTheme,
    'Asset': PartA.assetTextTheme,
    'Assistant': PartA.assistantTextTheme,
    'Asta Sans': PartA.astaSansTextTheme,
    'Astloch': PartA.astlochTextTheme,
    'Asul': PartA.asulTextTheme,
    'Athiti': PartA.athitiTextTheme,
    'Atkinson Hyperlegible': PartA.atkinsonHyperlegibleTextTheme,
    'Atkinson Hyperlegible Mono': PartA.atkinsonHyperlegibleMonoTextTheme,
    'Atkinson Hyperlegible Next': PartA.atkinsonHyperlegibleNextTextTheme,
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
    'Badeen Display': PartB.badeenDisplayTextTheme,
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
    'Big Shoulders': PartB.bigShouldersTextTheme,
    'Big Shoulders Inline': PartB.bigShouldersInlineTextTheme,
    'Big Shoulders Stencil': PartB.bigShouldersStencilTextTheme,
    'Bigelow Rules': PartB.bigelowRulesTextTheme,
    'Bigshot One': PartB.bigshotOneTextTheme,
    'Bilbo': PartB.bilboTextTheme,
    'Bilbo Swash Caps': PartB.bilboSwashCapsTextTheme,
    'BioRhyme': PartB.bioRhymeTextTheme,
    'Birthstone': PartB.birthstoneTextTheme,
    'Birthstone Bounce': PartB.birthstoneBounceTextTheme,
    'Biryani': PartB.biryaniTextTheme,
    'Bitcount': PartB.bitcountTextTheme,
    'Bitcount Grid Double': PartB.bitcountGridDoubleTextTheme,
    'Bitcount Grid Double Ink': PartB.bitcountGridDoubleInkTextTheme,
    'Bitcount Grid Single': PartB.bitcountGridSingleTextTheme,
    'Bitcount Grid Single Ink': PartB.bitcountGridSingleInkTextTheme,
    'Bitcount Ink': PartB.bitcountInkTextTheme,
    'Bitcount Prop Double': PartB.bitcountPropDoubleTextTheme,
    'Bitcount Prop Double Ink': PartB.bitcountPropDoubleInkTextTheme,
    'Bitcount Prop Single': PartB.bitcountPropSingleTextTheme,
    'Bitcount Prop Single Ink': PartB.bitcountPropSingleInkTextTheme,
    'Bitcount Single': PartB.bitcountSingleTextTheme,
    'Bitcount Single Ink': PartB.bitcountSingleInkTextTheme,
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
    'Boldonse': PartB.boldonseTextTheme,
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
    'Bungee Tint': PartB.bungeeTintTextTheme,
    'Butcherman': PartB.butchermanTextTheme,
    'Butterfly Kids': PartB.butterflyKidsTextTheme,
    'Bytesized': PartB.bytesizedTextTheme,
    'Cabin': PartC.cabinTextTheme,
    'Cabin Sketch': PartC.cabinSketchTextTheme,
    'Cactus Classical Serif': PartC.cactusClassicalSerifTextTheme,
    'Caesar Dressing': PartC.caesarDressingTextTheme,
    'Cagliostro': PartC.cagliostroTextTheme,
    'Cairo': PartC.cairoTextTheme,
    'Cairo Play': PartC.cairoPlayTextTheme,
    'Cal Sans': PartC.calSansTextTheme,
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
    'Cascadia Code': PartC.cascadiaCodeTextTheme,
    'Cascadia Mono': PartC.cascadiaMonoTextTheme,
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
    'Chiron GoRound TC': PartC.chironGoRoundTcTextTheme,
    'Chiron Hei HK': PartC.chironHeiHkTextTheme,
    'Chiron Sung HK': PartC.chironSungHkTextTheme,
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
    'Comic Relief': PartC.comicReliefTextTheme,
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
    'Coral Pixels': PartC.coralPixelsTextTheme,
    'Corben': PartC.corbenTextTheme,
    'Corinthia': PartC.corinthiaTextTheme,
    'Cormorant': PartC.cormorantTextTheme,
    'Cormorant Garamond': PartC.cormorantGaramondTextTheme,
    'Cormorant Infant': PartC.cormorantInfantTextTheme,
    'Cormorant SC': PartC.cormorantScTextTheme,
    'Cormorant Unicase': PartC.cormorantUnicaseTextTheme,
    'Cormorant Upright': PartC.cormorantUprightTextTheme,
    'Cossette Texte': PartC.cossetteTexteTextTheme,
    'Cossette Titre': PartC.cossetteTitreTextTheme,
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
    'Doto': PartD.dotoTextTheme,
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
    'Edu AU VIC WA NT Arrows': PartE.eduAuVicWaNtArrowsTextTheme,
    'Edu AU VIC WA NT Dots': PartE.eduAuVicWaNtDotsTextTheme,
    'Edu AU VIC WA NT Guides': PartE.eduAuVicWaNtGuidesTextTheme,
    'Edu AU VIC WA NT Hand': PartE.eduAuVicWaNtHandTextTheme,
    'Edu AU VIC WA NT Pre': PartE.eduAuVicWaNtPreTextTheme,
    'Edu NSW ACT Cursive': PartE.eduNswActCursiveTextTheme,
    'Edu NSW ACT Foundation': PartE.eduNswActFoundationTextTheme,
    'Edu NSW ACT Hand Pre': PartE.eduNswActHandPreTextTheme,
    'Edu QLD Beginner': PartE.eduQldBeginnerTextTheme,
    'Edu QLD Hand': PartE.eduQldHandTextTheme,
    'Edu SA Beginner': PartE.eduSaBeginnerTextTheme,
    'Edu SA Hand': PartE.eduSaHandTextTheme,
    'Edu TAS Beginner': PartE.eduTasBeginnerTextTheme,
    'Edu VIC WA NT Beginner': PartE.eduVicWaNtBeginnerTextTheme,
    'Edu VIC WA NT Hand': PartE.eduVicWaNtHandTextTheme,
    'Edu VIC WA NT Hand Pre': PartE.eduVicWaNtHandPreTextTheme,
    'El Messiri': PartE.elMessiriTextTheme,
    'Electrolize': PartE.electrolizeTextTheme,
    'Elsie': PartE.elsieTextTheme,
    'Elsie Swash Caps': PartE.elsieSwashCapsTextTheme,
    'Emblema One': PartE.emblemaOneTextTheme,
    'Emilys Candy': PartE.emilysCandyTextTheme,
    'Encode Sans': PartE.encodeSansTextTheme,
    'Encode Sans SC': PartE.encodeSansScTextTheme,
    'Engagement': PartE.engagementTextTheme,
    'Englebert': PartE.englebertTextTheme,
    'Enriqueta': PartE.enriquetaTextTheme,
    'Ephesis': PartE.ephesisTextTheme,
    'Epilogue': PartE.epilogueTextTheme,
    'Epunda Sans': PartE.epundaSansTextTheme,
    'Epunda Slab': PartE.epundaSlabTextTheme,
    'Erica One': PartE.ericaOneTextTheme,
    'Esteban': PartE.estebanTextTheme,
    'Estonia': PartE.estoniaTextTheme,
    'Euphoria Script': PartE.euphoriaScriptTextTheme,
    'Ewert': PartE.ewertTextTheme,
    'Exile': PartE.exileTextTheme,
    'Exo': PartE.exoTextTheme,
    'Exo 2': PartE.exo2TextTheme,
    'Expletus Sans': PartE.expletusSansTextTheme,
    'Explora': PartE.exploraTextTheme,
    'Faculty Glyphic': PartF.facultyGlyphicTextTheme,
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
    'Funnel Display': PartF.funnelDisplayTextTheme,
    'Funnel Sans': PartF.funnelSansTextTheme,
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
    'Geist': PartG.geistTextTheme,
    'Geist Mono': PartG.geistMonoTextTheme,
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
    'Gidole': PartG.gidoleTextTheme,
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
    'Google Sans Code': PartG.googleSansCodeTextTheme,
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
    'Hind Mysuru': PartH.hindMysuruTextTheme,
    'Hind Siliguri': PartH.hindSiliguriTextTheme,
    'Hind Vadodara': PartH.hindVadodaraTextTheme,
    'Holtwood One SC': PartH.holtwoodOneScTextTheme,
    'Homemade Apple': PartH.homemadeAppleTextTheme,
    'Homenaje': PartH.homenajeTextTheme,
    'Honk': PartH.honkTextTheme,
    'Host Grotesk': PartH.hostGroteskTextTheme,
    'Hubballi': PartH.hubballiTextTheme,
    'Hubot Sans': PartH.hubotSansTextTheme,
    'Huninn': PartH.huninnTextTheme,
    'Hurricane': PartH.hurricaneTextTheme,
    'IBM Plex Mono': PartI.ibmPlexMonoTextTheme,
    'IBM Plex Sans': PartI.ibmPlexSansTextTheme,
    'IBM Plex Sans Arabic': PartI.ibmPlexSansArabicTextTheme,
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
    'Iansui': PartI.iansuiTextTheme,
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
    'Intel One Mono': PartI.intelOneMonoTextTheme,
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
    'Jacquarda Bastarda 9 Charted': PartJ.jacquardaBastarda9ChartedTextTheme,
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
    'Kanchenjunga': PartK.kanchenjungaTextTheme,
    'Kanit': PartK.kanitTextTheme,
    'Kantumruy Pro': PartK.kantumruyProTextTheme,
    'Kapakana': PartK.kapakanaTextTheme,
    'Karantina': PartK.karantinaTextTheme,
    'Karla': PartK.karlaTextTheme,
    'Karla Tamil Inclined': PartK.karlaTamilInclinedTextTheme,
    'Karla Tamil Upright': PartK.karlaTamilUprightTextTheme,
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
    'LXGW Marker Gothic': PartL.lxgwMarkerGothicTextTheme,
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
    'Libertinus Keyboard': PartL.libertinusKeyboardTextTheme,
    'Libertinus Math': PartL.libertinusMathTextTheme,
    'Libertinus Mono': PartL.libertinusMonoTextTheme,
    'Libertinus Sans': PartL.libertinusSansTextTheme,
    'Libertinus Serif': PartL.libertinusSerifTextTheme,
    'Libertinus Serif Display': PartL.libertinusSerifDisplayTextTheme,
    'Libre Barcode 128': PartL.libreBarcode128TextTheme,
    'Libre Barcode 128 Text': PartL.libreBarcode128TextTextTheme,
    'Libre Barcode 39': PartL.libreBarcode39TextTheme,
    'Libre Barcode 39 Extended': PartL.libreBarcode39ExtendedTextTheme,
    'Libre Barcode 39 Extended Text': PartL.libreBarcode39ExtendedTextTextTheme,
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
    'Liter': PartL.literTextTheme,
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
    'Manufacturing Consent': PartM.manufacturingConsentTextTheme,
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
    'Matangi': PartM.matangiTextTheme,
    'Mate': PartM.mateTextTheme,
    'Mate SC': PartM.mateScTextTheme,
    'Matemasie': PartM.matemasieTextTheme,
    'Maven Pro': PartM.mavenProTextTheme,
    'McLaren': PartM.mcLarenTextTheme,
    'Mea Culpa': PartM.meaCulpaTextTheme,
    'Meddon': PartM.meddonTextTheme,
    'MedievalSharp': PartM.medievalSharpTextTheme,
    'Medula One': PartM.medulaOneTextTheme,
    'Meera Inimai': PartM.meeraInimaiTextTheme,
    'Megrim': PartM.megrimTextTheme,
    'Meie Script': PartM.meieScriptTextTheme,
    'Menbere': PartM.menbereTextTheme,
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
    'Moderustic': PartM.moderusticTextTheme,
    'Mogra': PartM.mograTextTheme,
    'Mohave': PartM.mohaveTextTheme,
    'Moirai One': PartM.moiraiOneTextTheme,
    'Molengo': PartM.molengoTextTheme,
    'Molle': PartM.molleTextTheme,
    'Mona Sans': PartM.monaSansTextTheme,
    'Monda': PartM.mondaTextTheme,
    'Monofett': PartM.monofettTextTheme,
    'Monomakh': PartM.monomakhTextTheme,
    'Monomaniac One': PartM.monomaniacOneTextTheme,
    'Monoton': PartM.monotonTextTheme,
    'Monsieur La Doulaise': PartM.monsieurLaDoulaiseTextTheme,
    'Montaga': PartM.montagaTextTheme,
    'Montagu Slab': PartM.montaguSlabTextTheme,
    'MonteCarlo': PartM.monteCarloTextTheme,
    'Montez': PartM.montezTextTheme,
    'Montserrat': PartM.montserratTextTheme,
    'Montserrat Alternates': PartM.montserratAlternatesTextTheme,
    'Montserrat Underline': PartM.montserratUnderlineTextTheme,
    'Moo Lah Lah': PartM.mooLahLahTextTheme,
    'Mooli': PartM.mooliTextTheme,
    'Moon Dance': PartM.moonDanceTextTheme,
    'Moul': PartM.moulTextTheme,
    'Moulpali': PartM.moulpaliTextTheme,
    'Mountains of Christmas': PartM.mountainsOfChristmasTextTheme,
    'Mouse Memoirs': PartM.mouseMemoirsTextTheme,
    'Mozilla Headline': PartM.mozillaHeadlineTextTheme,
    'Mozilla Text': PartM.mozillaTextTextTheme,
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
    'Nata Sans': PartN.nataSansTextTheme,
    'National Park': PartN.nationalParkTextTheme,
    'Neonderthaw': PartN.neonderthawTextTheme,
    'Nerko One': PartN.nerkoOneTextTheme,
    'Neucha': PartN.neuchaTextTheme,
    'Neuton': PartN.neutonTextTheme,
    'New Amsterdam': PartN.newAmsterdamTextTheme,
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
    'Noto Sans Canadian Aboriginal': PartN.notoSansCanadianAboriginalTextTheme,
    'Noto Sans Carian': PartN.notoSansCarianTextTheme,
    'Noto Sans Caucasian Albanian': PartN.notoSansCaucasianAlbanianTextTheme,
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
    'Noto Sans Indic Siyaq Numbers': PartN.notoSansIndicSiyaqNumbersTextTheme,
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
    'Noto Sans PhagsPa': PartN.notoSansPhagsPaTextTheme,
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
    'Noto Sans Sunuwar': PartN.notoSansSunuwarTextTheme,
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
    'Noto Serif Dives Akuru': PartN.notoSerifDivesAkuruTextTheme,
    'Noto Serif Dogra': PartN.notoSerifDograTextTheme,
    'Noto Serif Ethiopic': PartN.notoSerifEthiopicTextTheme,
    'Noto Serif Georgian': PartN.notoSerifGeorgianTextTheme,
    'Noto Serif Grantha': PartN.notoSerifGranthaTextTheme,
    'Noto Serif Gujarati': PartN.notoSerifGujaratiTextTheme,
    'Noto Serif Gurmukhi': PartN.notoSerifGurmukhiTextTheme,
    'Noto Serif HK': PartN.notoSerifHkTextTheme,
    'Noto Serif Hebrew': PartN.notoSerifHebrewTextTheme,
    'Noto Serif Hentaigana': PartN.notoSerifHentaiganaTextTheme,
    'Noto Serif JP': PartN.notoSerifJpTextTheme,
    'Noto Serif KR': PartN.notoSerifKrTextTheme,
    'Noto Serif Kannada': PartN.notoSerifKannadaTextTheme,
    'Noto Serif Khitan Small Script': PartN.notoSerifKhitanSmallScriptTextTheme,
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
    'Noto Serif Todhri': PartN.notoSerifTodhriTextTheme,
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
    'Parastoo': PartP.parastooTextTheme,
    'Parisienne': PartP.parisienneTextTheme,
    'Parkinsans': PartP.parkinsansTextTheme,
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
    'Phetsarath': PartP.phetsarathTextTheme,
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
    'Playpen Sans Arabic': PartP.playpenSansArabicTextTheme,
    'Playpen Sans Deva': PartP.playpenSansDevaTextTheme,
    'Playpen Sans Hebrew': PartP.playpenSansHebrewTextTheme,
    'Playpen Sans Thai': PartP.playpenSansThaiTextTheme,
    'Playwrite AR': PartP.playwriteArTextTheme,
    'Playwrite AR Guides': PartP.playwriteArGuidesTextTheme,
    'Playwrite AT': PartP.playwriteAtTextTheme,
    'Playwrite AT Guides': PartP.playwriteAtGuidesTextTheme,
    'Playwrite AU NSW': PartP.playwriteAuNswTextTheme,
    'Playwrite AU NSW Guides': PartP.playwriteAuNswGuidesTextTheme,
    'Playwrite AU QLD': PartP.playwriteAuQldTextTheme,
    'Playwrite AU QLD Guides': PartP.playwriteAuQldGuidesTextTheme,
    'Playwrite AU SA': PartP.playwriteAuSaTextTheme,
    'Playwrite AU SA Guides': PartP.playwriteAuSaGuidesTextTheme,
    'Playwrite AU TAS': PartP.playwriteAuTasTextTheme,
    'Playwrite AU TAS Guides': PartP.playwriteAuTasGuidesTextTheme,
    'Playwrite AU VIC': PartP.playwriteAuVicTextTheme,
    'Playwrite AU VIC Guides': PartP.playwriteAuVicGuidesTextTheme,
    'Playwrite BE VLG': PartP.playwriteBeVlgTextTheme,
    'Playwrite BE VLG Guides': PartP.playwriteBeVlgGuidesTextTheme,
    'Playwrite BE WAL': PartP.playwriteBeWalTextTheme,
    'Playwrite BE WAL Guides': PartP.playwriteBeWalGuidesTextTheme,
    'Playwrite BR': PartP.playwriteBrTextTheme,
    'Playwrite BR Guides': PartP.playwriteBrGuidesTextTheme,
    'Playwrite CA': PartP.playwriteCaTextTheme,
    'Playwrite CA Guides': PartP.playwriteCaGuidesTextTheme,
    'Playwrite CL': PartP.playwriteClTextTheme,
    'Playwrite CL Guides': PartP.playwriteClGuidesTextTheme,
    'Playwrite CO': PartP.playwriteCoTextTheme,
    'Playwrite CO Guides': PartP.playwriteCoGuidesTextTheme,
    'Playwrite CU': PartP.playwriteCuTextTheme,
    'Playwrite CU Guides': PartP.playwriteCuGuidesTextTheme,
    'Playwrite CZ': PartP.playwriteCzTextTheme,
    'Playwrite CZ Guides': PartP.playwriteCzGuidesTextTheme,
    'Playwrite DE Grund': PartP.playwriteDeGrundTextTheme,
    'Playwrite DE Grund Guides': PartP.playwriteDeGrundGuidesTextTheme,
    'Playwrite DE LA': PartP.playwriteDeLaTextTheme,
    'Playwrite DE LA Guides': PartP.playwriteDeLaGuidesTextTheme,
    'Playwrite DE SAS': PartP.playwriteDeSasTextTheme,
    'Playwrite DE SAS Guides': PartP.playwriteDeSasGuidesTextTheme,
    'Playwrite DE VA': PartP.playwriteDeVaTextTheme,
    'Playwrite DE VA Guides': PartP.playwriteDeVaGuidesTextTheme,
    'Playwrite DK Loopet': PartP.playwriteDkLoopetTextTheme,
    'Playwrite DK Loopet Guides': PartP.playwriteDkLoopetGuidesTextTheme,
    'Playwrite DK Uloopet': PartP.playwriteDkUloopetTextTheme,
    'Playwrite DK Uloopet Guides': PartP.playwriteDkUloopetGuidesTextTheme,
    'Playwrite ES': PartP.playwriteEsTextTheme,
    'Playwrite ES Deco': PartP.playwriteEsDecoTextTheme,
    'Playwrite ES Deco Guides': PartP.playwriteEsDecoGuidesTextTheme,
    'Playwrite ES Guides': PartP.playwriteEsGuidesTextTheme,
    'Playwrite FR Moderne': PartP.playwriteFrModerneTextTheme,
    'Playwrite FR Moderne Guides': PartP.playwriteFrModerneGuidesTextTheme,
    'Playwrite FR Trad': PartP.playwriteFrTradTextTheme,
    'Playwrite FR Trad Guides': PartP.playwriteFrTradGuidesTextTheme,
    'Playwrite GB J': PartP.playwriteGbJTextTheme,
    'Playwrite GB J Guides': PartP.playwriteGbJGuidesTextTheme,
    'Playwrite GB S': PartP.playwriteGbSTextTheme,
    'Playwrite GB S Guides': PartP.playwriteGbSGuidesTextTheme,
    'Playwrite HR': PartP.playwriteHrTextTheme,
    'Playwrite HR Guides': PartP.playwriteHrGuidesTextTheme,
    'Playwrite HR Lijeva': PartP.playwriteHrLijevaTextTheme,
    'Playwrite HR Lijeva Guides': PartP.playwriteHrLijevaGuidesTextTheme,
    'Playwrite HU': PartP.playwriteHuTextTheme,
    'Playwrite HU Guides': PartP.playwriteHuGuidesTextTheme,
    'Playwrite ID': PartP.playwriteIdTextTheme,
    'Playwrite ID Guides': PartP.playwriteIdGuidesTextTheme,
    'Playwrite IE': PartP.playwriteIeTextTheme,
    'Playwrite IE Guides': PartP.playwriteIeGuidesTextTheme,
    'Playwrite IN': PartP.playwriteInTextTheme,
    'Playwrite IN Guides': PartP.playwriteInGuidesTextTheme,
    'Playwrite IS': PartP.playwriteIsTextTheme,
    'Playwrite IS Guides': PartP.playwriteIsGuidesTextTheme,
    'Playwrite IT Moderna': PartP.playwriteItModernaTextTheme,
    'Playwrite IT Moderna Guides': PartP.playwriteItModernaGuidesTextTheme,
    'Playwrite IT Trad': PartP.playwriteItTradTextTheme,
    'Playwrite IT Trad Guides': PartP.playwriteItTradGuidesTextTheme,
    'Playwrite MX': PartP.playwriteMxTextTheme,
    'Playwrite MX Guides': PartP.playwriteMxGuidesTextTheme,
    'Playwrite NG Modern': PartP.playwriteNgModernTextTheme,
    'Playwrite NG Modern Guides': PartP.playwriteNgModernGuidesTextTheme,
    'Playwrite NL': PartP.playwriteNlTextTheme,
    'Playwrite NL Guides': PartP.playwriteNlGuidesTextTheme,
    'Playwrite NO': PartP.playwriteNoTextTheme,
    'Playwrite NO Guides': PartP.playwriteNoGuidesTextTheme,
    'Playwrite NZ': PartP.playwriteNzTextTheme,
    'Playwrite NZ Guides': PartP.playwriteNzGuidesTextTheme,
    'Playwrite PE': PartP.playwritePeTextTheme,
    'Playwrite PE Guides': PartP.playwritePeGuidesTextTheme,
    'Playwrite PL': PartP.playwritePlTextTheme,
    'Playwrite PL Guides': PartP.playwritePlGuidesTextTheme,
    'Playwrite PT': PartP.playwritePtTextTheme,
    'Playwrite PT Guides': PartP.playwritePtGuidesTextTheme,
    'Playwrite RO': PartP.playwriteRoTextTheme,
    'Playwrite RO Guides': PartP.playwriteRoGuidesTextTheme,
    'Playwrite SK': PartP.playwriteSkTextTheme,
    'Playwrite SK Guides': PartP.playwriteSkGuidesTextTheme,
    'Playwrite TZ': PartP.playwriteTzTextTheme,
    'Playwrite TZ Guides': PartP.playwriteTzGuidesTextTheme,
    'Playwrite US Modern': PartP.playwriteUsModernTextTheme,
    'Playwrite US Modern Guides': PartP.playwriteUsModernGuidesTextTheme,
    'Playwrite US Trad': PartP.playwriteUsTradTextTheme,
    'Playwrite US Trad Guides': PartP.playwriteUsTradGuidesTextTheme,
    'Playwrite VN': PartP.playwriteVnTextTheme,
    'Playwrite VN Guides': PartP.playwriteVnGuidesTextTheme,
    'Playwrite ZA': PartP.playwriteZaTextTheme,
    'Playwrite ZA Guides': PartP.playwriteZaGuidesTextTheme,
    'Plus Jakarta Sans': PartP.plusJakartaSansTextTheme,
    'Pochaevsk': PartP.pochaevskTextTheme,
    'Podkova': PartP.podkovaTextTheme,
    'Poetsen One': PartP.poetsenOneTextTheme,
    'Poiret One': PartP.poiretOneTextTheme,
    'Poller One': PartP.pollerOneTextTheme,
    'Poltawski Nowy': PartP.poltawskiNowyTextTheme,
    'Poly': PartP.polyTextTheme,
    'Pompiere': PartP.pompiereTextTheme,
    'Ponnala': PartP.ponnalaTextTheme,
    'Ponomar': PartP.ponomarTextTheme,
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
    'SUSE': PartS.suseTextTheme,
    'SUSE Mono': PartS.suseMonoTextTheme,
    'Sacramento': PartS.sacramentoTextTheme,
    'Sahitya': PartS.sahityaTextTheme,
    'Sail': PartS.sailTextTheme,
    'Saira': PartS.sairaTextTheme,
    'Saira Stencil One': PartS.sairaStencilOneTextTheme,
    'Salsa': PartS.salsaTextTheme,
    'Sanchez': PartS.sanchezTextTheme,
    'Sancreek': PartS.sancreekTextTheme,
    'Sankofa Display': PartS.sankofaDisplayTextTheme,
    'Sansation': PartS.sansationTextTheme,
    'Sansita': PartS.sansitaTextTheme,
    'Sansita Swashed': PartS.sansitaSwashedTextTheme,
    'Sarabun': PartS.sarabunTextTheme,
    'Sarala': PartS.saralaTextTheme,
    'Sarina': PartS.sarinaTextTheme,
    'Sarpanch': PartS.sarpanchTextTheme,
    'Sassy Frass': PartS.sassyFrassTextTheme,
    'Satisfy': PartS.satisfyTextTheme,
    'Savate': PartS.savateTextTheme,
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
    'Shafarik': PartS.shafarikTextTheme,
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
    'Sirivennela': PartS.sirivennelaTextTheme,
    'Six Caps': PartS.sixCapsTextTheme,
    'Sixtyfour': PartS.sixtyfourTextTheme,
    'Sixtyfour Convergence': PartS.sixtyfourConvergenceTextTheme,
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
    'Sour Gummy': PartS.sourGummyTextTheme,
    'Source Code Pro': PartS.sourceCodeProTextTheme,
    'Source Sans 3': PartS.sourceSans3TextTheme,
    'Source Serif 4': PartS.sourceSerif4TextTheme,
    'Space Grotesk': PartS.spaceGroteskTextTheme,
    'Space Mono': PartS.spaceMonoTextTheme,
    'Special Elite': PartS.specialEliteTextTheme,
    'Special Gothic': PartS.specialGothicTextTheme,
    'Special Gothic Condensed One': PartS.specialGothicCondensedOneTextTheme,
    'Special Gothic Expanded One': PartS.specialGothicExpandedOneTextTheme,
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
    'Story Script': PartS.storyScriptTextTheme,
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
    'TASA Explorer': PartT.tasaExplorerTextTheme,
    'TASA Orbiter': PartT.tasaOrbiterTextTheme,
    'Tac One': PartT.tacOneTextTheme,
    'Tagesschrift': PartT.tagesschriftTextTheme,
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
    'TikTok Sans': PartT.tikTokSansTextTheme,
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
    'Tirra': PartT.tirraTextTheme,
    'Titan One': PartT.titanOneTextTheme,
    'Titillium Web': PartT.titilliumWebTextTheme,
    'Tomorrow': PartT.tomorrowTextTheme,
    'Tourney': PartT.tourneyTextTheme,
    'Trade Winds': PartT.tradeWindsTextTheme,
    'Train One': PartT.trainOneTextTheme,
    'Triodion': PartT.triodionTextTheme,
    'Trirong': PartT.trirongTextTheme,
    'Trispace': PartT.trispaceTextTheme,
    'Trocchi': PartT.trocchiTextTheme,
    'Trochut': PartT.trochutTextTheme,
    'Truculenta': PartT.truculentaTextTheme,
    'Trykker': PartT.trykkerTextTheme,
    'Tsukimi Rounded': PartT.tsukimiRoundedTextTheme,
    'Tuffy': PartT.tuffyTextTheme,
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
    'UoqMunThenKhung': PartU.uoqMunThenKhungTextTheme,
    'Updock': PartU.updockTextTheme,
    'Urbanist': PartU.urbanistTextTheme,
    'VT323': PartV.vt323TextTheme,
    'Vampiro One': PartV.vampiroOneTextTheme,
    'Varela': PartV.varelaTextTheme,
    'Varela Round': PartV.varelaRoundTextTheme,
    'Varta': PartV.vartaTextTheme,
    'Vast Shadow': PartV.vastShadowTextTheme,
    'Vazirmatn': PartV.vazirmatnTextTheme,
    'Vend Sans': PartV.vendSansTextTheme,
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
    'WDXL Lubrifont JP N': PartW.wdxlLubrifontJpNTextTheme,
    'WDXL Lubrifont SC': PartW.wdxlLubrifontScTextTheme,
    'WDXL Lubrifont TC': PartW.wdxlLubrifontTcTextTheme,
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
    'Winky Rough': PartW.winkyRoughTextTheme,
    'Winky Sans': PartW.winkySansTextTheme,
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
    'Zalando Sans': PartZ.zalandoSansTextTheme,
    'Zalando Sans Expanded': PartZ.zalandoSansExpandedTextTheme,
    'Zalando Sans SemiExpanded': PartZ.zalandoSansSemiExpandedTextTheme,
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

  /// See [PartA.aBeeZee].
  static const aBeeZee = PartA.aBeeZee;

  /// See [PartA.aBeeZeeTextTheme].
  static const aBeeZeeTextTheme = PartA.aBeeZeeTextTheme;

  /// See [PartA.aDLaMDisplay].
  static const aDLaMDisplay = PartA.aDLaMDisplay;

  /// See [PartA.aDLaMDisplayTextTheme].
  static const aDLaMDisplayTextTheme = PartA.aDLaMDisplayTextTheme;

  /// See [PartA.arOneSans].
  static const arOneSans = PartA.arOneSans;

  /// See [PartA.arOneSansTextTheme].
  static const arOneSansTextTheme = PartA.arOneSansTextTheme;

  /// See [PartA.abel].
  static const abel = PartA.abel;

  /// See [PartA.abelTextTheme].
  static const abelTextTheme = PartA.abelTextTheme;

  /// See [PartA.abhayaLibre].
  static const abhayaLibre = PartA.abhayaLibre;

  /// See [PartA.abhayaLibreTextTheme].
  static const abhayaLibreTextTheme = PartA.abhayaLibreTextTheme;

  /// See [PartA.aboreto].
  static const aboreto = PartA.aboreto;

  /// See [PartA.aboretoTextTheme].
  static const aboretoTextTheme = PartA.aboretoTextTheme;

  /// See [PartA.abrilFatface].
  static const abrilFatface = PartA.abrilFatface;

  /// See [PartA.abrilFatfaceTextTheme].
  static const abrilFatfaceTextTheme = PartA.abrilFatfaceTextTheme;

  /// See [PartA.abyssinicaSil].
  static const abyssinicaSil = PartA.abyssinicaSil;

  /// See [PartA.abyssinicaSilTextTheme].
  static const abyssinicaSilTextTheme = PartA.abyssinicaSilTextTheme;

  /// See [PartA.aclonica].
  static const aclonica = PartA.aclonica;

  /// See [PartA.aclonicaTextTheme].
  static const aclonicaTextTheme = PartA.aclonicaTextTheme;

  /// See [PartA.acme].
  static const acme = PartA.acme;

  /// See [PartA.acmeTextTheme].
  static const acmeTextTheme = PartA.acmeTextTheme;

  /// See [PartA.actor].
  static const actor = PartA.actor;

  /// See [PartA.actorTextTheme].
  static const actorTextTheme = PartA.actorTextTheme;

  /// See [PartA.adamina].
  static const adamina = PartA.adamina;

  /// See [PartA.adaminaTextTheme].
  static const adaminaTextTheme = PartA.adaminaTextTheme;

  /// See [PartA.adventPro].
  static const adventPro = PartA.adventPro;

  /// See [PartA.adventProTextTheme].
  static const adventProTextTheme = PartA.adventProTextTheme;

  /// See [PartA.afacad].
  static const afacad = PartA.afacad;

  /// See [PartA.afacadTextTheme].
  static const afacadTextTheme = PartA.afacadTextTheme;

  /// See [PartA.afacadFlux].
  static const afacadFlux = PartA.afacadFlux;

  /// See [PartA.afacadFluxTextTheme].
  static const afacadFluxTextTheme = PartA.afacadFluxTextTheme;

  /// See [PartA.agbalumo].
  static const agbalumo = PartA.agbalumo;

  /// See [PartA.agbalumoTextTheme].
  static const agbalumoTextTheme = PartA.agbalumoTextTheme;

  /// See [PartA.agdasima].
  static const agdasima = PartA.agdasima;

  /// See [PartA.agdasimaTextTheme].
  static const agdasimaTextTheme = PartA.agdasimaTextTheme;

  /// See [PartA.aguDisplay].
  static const aguDisplay = PartA.aguDisplay;

  /// See [PartA.aguDisplayTextTheme].
  static const aguDisplayTextTheme = PartA.aguDisplayTextTheme;

  /// See [PartA.aguafinaScript].
  static const aguafinaScript = PartA.aguafinaScript;

  /// See [PartA.aguafinaScriptTextTheme].
  static const aguafinaScriptTextTheme = PartA.aguafinaScriptTextTheme;

  /// See [PartA.akatab].
  static const akatab = PartA.akatab;

  /// See [PartA.akatabTextTheme].
  static const akatabTextTheme = PartA.akatabTextTheme;

  /// See [PartA.akayaKanadaka].
  static const akayaKanadaka = PartA.akayaKanadaka;

  /// See [PartA.akayaKanadakaTextTheme].
  static const akayaKanadakaTextTheme = PartA.akayaKanadakaTextTheme;

  /// See [PartA.akayaTelivigala].
  static const akayaTelivigala = PartA.akayaTelivigala;

  /// See [PartA.akayaTelivigalaTextTheme].
  static const akayaTelivigalaTextTheme = PartA.akayaTelivigalaTextTheme;

  /// See [PartA.akronim].
  static const akronim = PartA.akronim;

  /// See [PartA.akronimTextTheme].
  static const akronimTextTheme = PartA.akronimTextTheme;

  /// See [PartA.akshar].
  static const akshar = PartA.akshar;

  /// See [PartA.aksharTextTheme].
  static const aksharTextTheme = PartA.aksharTextTheme;

  /// See [PartA.aladin].
  static const aladin = PartA.aladin;

  /// See [PartA.aladinTextTheme].
  static const aladinTextTheme = PartA.aladinTextTheme;

  /// See [PartA.alanSans].
  static const alanSans = PartA.alanSans;

  /// See [PartA.alanSansTextTheme].
  static const alanSansTextTheme = PartA.alanSansTextTheme;

  /// See [PartA.alata].
  static const alata = PartA.alata;

  /// See [PartA.alataTextTheme].
  static const alataTextTheme = PartA.alataTextTheme;

  /// See [PartA.alatsi].
  static const alatsi = PartA.alatsi;

  /// See [PartA.alatsiTextTheme].
  static const alatsiTextTheme = PartA.alatsiTextTheme;

  /// See [PartA.albertSans].
  static const albertSans = PartA.albertSans;

  /// See [PartA.albertSansTextTheme].
  static const albertSansTextTheme = PartA.albertSansTextTheme;

  /// See [PartA.aldrich].
  static const aldrich = PartA.aldrich;

  /// See [PartA.aldrichTextTheme].
  static const aldrichTextTheme = PartA.aldrichTextTheme;

  /// See [PartA.alef].
  static const alef = PartA.alef;

  /// See [PartA.alefTextTheme].
  static const alefTextTheme = PartA.alefTextTheme;

  /// See [PartA.alegreya].
  static const alegreya = PartA.alegreya;

  /// See [PartA.alegreyaTextTheme].
  static const alegreyaTextTheme = PartA.alegreyaTextTheme;

  /// See [PartA.alegreyaSc].
  static const alegreyaSc = PartA.alegreyaSc;

  /// See [PartA.alegreyaScTextTheme].
  static const alegreyaScTextTheme = PartA.alegreyaScTextTheme;

  /// See [PartA.alegreyaSans].
  static const alegreyaSans = PartA.alegreyaSans;

  /// See [PartA.alegreyaSansTextTheme].
  static const alegreyaSansTextTheme = PartA.alegreyaSansTextTheme;

  /// See [PartA.alegreyaSansSc].
  static const alegreyaSansSc = PartA.alegreyaSansSc;

  /// See [PartA.alegreyaSansScTextTheme].
  static const alegreyaSansScTextTheme = PartA.alegreyaSansScTextTheme;

  /// See [PartA.aleo].
  static const aleo = PartA.aleo;

  /// See [PartA.aleoTextTheme].
  static const aleoTextTheme = PartA.aleoTextTheme;

  /// See [PartA.alexBrush].
  static const alexBrush = PartA.alexBrush;

  /// See [PartA.alexBrushTextTheme].
  static const alexBrushTextTheme = PartA.alexBrushTextTheme;

  /// See [PartA.alexandria].
  static const alexandria = PartA.alexandria;

  /// See [PartA.alexandriaTextTheme].
  static const alexandriaTextTheme = PartA.alexandriaTextTheme;

  /// See [PartA.alfaSlabOne].
  static const alfaSlabOne = PartA.alfaSlabOne;

  /// See [PartA.alfaSlabOneTextTheme].
  static const alfaSlabOneTextTheme = PartA.alfaSlabOneTextTheme;

  /// See [PartA.alice].
  static const alice = PartA.alice;

  /// See [PartA.aliceTextTheme].
  static const aliceTextTheme = PartA.aliceTextTheme;

  /// See [PartA.alike].
  static const alike = PartA.alike;

  /// See [PartA.alikeTextTheme].
  static const alikeTextTheme = PartA.alikeTextTheme;

  /// See [PartA.alikeAngular].
  static const alikeAngular = PartA.alikeAngular;

  /// See [PartA.alikeAngularTextTheme].
  static const alikeAngularTextTheme = PartA.alikeAngularTextTheme;

  /// See [PartA.alkalami].
  static const alkalami = PartA.alkalami;

  /// See [PartA.alkalamiTextTheme].
  static const alkalamiTextTheme = PartA.alkalamiTextTheme;

  /// See [PartA.alkatra].
  static const alkatra = PartA.alkatra;

  /// See [PartA.alkatraTextTheme].
  static const alkatraTextTheme = PartA.alkatraTextTheme;

  /// See [PartA.allan].
  static const allan = PartA.allan;

  /// See [PartA.allanTextTheme].
  static const allanTextTheme = PartA.allanTextTheme;

  /// See [PartA.allerta].
  static const allerta = PartA.allerta;

  /// See [PartA.allertaTextTheme].
  static const allertaTextTheme = PartA.allertaTextTheme;

  /// See [PartA.allertaStencil].
  static const allertaStencil = PartA.allertaStencil;

  /// See [PartA.allertaStencilTextTheme].
  static const allertaStencilTextTheme = PartA.allertaStencilTextTheme;

  /// See [PartA.allison].
  static const allison = PartA.allison;

  /// See [PartA.allisonTextTheme].
  static const allisonTextTheme = PartA.allisonTextTheme;

  /// See [PartA.allura].
  static const allura = PartA.allura;

  /// See [PartA.alluraTextTheme].
  static const alluraTextTheme = PartA.alluraTextTheme;

  /// See [PartA.almarai].
  static const almarai = PartA.almarai;

  /// See [PartA.almaraiTextTheme].
  static const almaraiTextTheme = PartA.almaraiTextTheme;

  /// See [PartA.almendra].
  static const almendra = PartA.almendra;

  /// See [PartA.almendraTextTheme].
  static const almendraTextTheme = PartA.almendraTextTheme;

  /// See [PartA.almendraDisplay].
  static const almendraDisplay = PartA.almendraDisplay;

  /// See [PartA.almendraDisplayTextTheme].
  static const almendraDisplayTextTheme = PartA.almendraDisplayTextTheme;

  /// See [PartA.almendraSc].
  static const almendraSc = PartA.almendraSc;

  /// See [PartA.almendraScTextTheme].
  static const almendraScTextTheme = PartA.almendraScTextTheme;

  /// See [PartA.alumniSans].
  static const alumniSans = PartA.alumniSans;

  /// See [PartA.alumniSansTextTheme].
  static const alumniSansTextTheme = PartA.alumniSansTextTheme;

  /// See [PartA.alumniSansCollegiateOne].
  static const alumniSansCollegiateOne = PartA.alumniSansCollegiateOne;

  /// See [PartA.alumniSansCollegiateOneTextTheme].
  static const alumniSansCollegiateOneTextTheme =
      PartA.alumniSansCollegiateOneTextTheme;

  /// See [PartA.alumniSansInlineOne].
  static const alumniSansInlineOne = PartA.alumniSansInlineOne;

  /// See [PartA.alumniSansInlineOneTextTheme].
  static const alumniSansInlineOneTextTheme =
      PartA.alumniSansInlineOneTextTheme;

  /// See [PartA.alumniSansPinstripe].
  static const alumniSansPinstripe = PartA.alumniSansPinstripe;

  /// See [PartA.alumniSansPinstripeTextTheme].
  static const alumniSansPinstripeTextTheme =
      PartA.alumniSansPinstripeTextTheme;

  /// See [PartA.alumniSansSc].
  static const alumniSansSc = PartA.alumniSansSc;

  /// See [PartA.alumniSansScTextTheme].
  static const alumniSansScTextTheme = PartA.alumniSansScTextTheme;

  /// See [PartA.amarante].
  static const amarante = PartA.amarante;

  /// See [PartA.amaranteTextTheme].
  static const amaranteTextTheme = PartA.amaranteTextTheme;

  /// See [PartA.amaranth].
  static const amaranth = PartA.amaranth;

  /// See [PartA.amaranthTextTheme].
  static const amaranthTextTheme = PartA.amaranthTextTheme;

  /// See [PartA.amaticSc].
  static const amaticSc = PartA.amaticSc;

  /// See [PartA.amaticScTextTheme].
  static const amaticScTextTheme = PartA.amaticScTextTheme;

  /// See [PartA.amethysta].
  static const amethysta = PartA.amethysta;

  /// See [PartA.amethystaTextTheme].
  static const amethystaTextTheme = PartA.amethystaTextTheme;

  /// See [PartA.amiko].
  static const amiko = PartA.amiko;

  /// See [PartA.amikoTextTheme].
  static const amikoTextTheme = PartA.amikoTextTheme;

  /// See [PartA.amiri].
  static const amiri = PartA.amiri;

  /// See [PartA.amiriTextTheme].
  static const amiriTextTheme = PartA.amiriTextTheme;

  /// See [PartA.amiriQuran].
  static const amiriQuran = PartA.amiriQuran;

  /// See [PartA.amiriQuranTextTheme].
  static const amiriQuranTextTheme = PartA.amiriQuranTextTheme;

  /// See [PartA.amita].
  static const amita = PartA.amita;

  /// See [PartA.amitaTextTheme].
  static const amitaTextTheme = PartA.amitaTextTheme;

  /// See [PartA.anaheim].
  static const anaheim = PartA.anaheim;

  /// See [PartA.anaheimTextTheme].
  static const anaheimTextTheme = PartA.anaheimTextTheme;

  /// See [PartA.ancizarSans].
  static const ancizarSans = PartA.ancizarSans;

  /// See [PartA.ancizarSansTextTheme].
  static const ancizarSansTextTheme = PartA.ancizarSansTextTheme;

  /// See [PartA.ancizarSerif].
  static const ancizarSerif = PartA.ancizarSerif;

  /// See [PartA.ancizarSerifTextTheme].
  static const ancizarSerifTextTheme = PartA.ancizarSerifTextTheme;

  /// See [PartA.andadaPro].
  static const andadaPro = PartA.andadaPro;

  /// See [PartA.andadaProTextTheme].
  static const andadaProTextTheme = PartA.andadaProTextTheme;

  /// See [PartA.andika].
  static const andika = PartA.andika;

  /// See [PartA.andikaTextTheme].
  static const andikaTextTheme = PartA.andikaTextTheme;

  /// See [PartA.anekBangla].
  static const anekBangla = PartA.anekBangla;

  /// See [PartA.anekBanglaTextTheme].
  static const anekBanglaTextTheme = PartA.anekBanglaTextTheme;

  /// See [PartA.anekDevanagari].
  static const anekDevanagari = PartA.anekDevanagari;

  /// See [PartA.anekDevanagariTextTheme].
  static const anekDevanagariTextTheme = PartA.anekDevanagariTextTheme;

  /// See [PartA.anekGujarati].
  static const anekGujarati = PartA.anekGujarati;

  /// See [PartA.anekGujaratiTextTheme].
  static const anekGujaratiTextTheme = PartA.anekGujaratiTextTheme;

  /// See [PartA.anekGurmukhi].
  static const anekGurmukhi = PartA.anekGurmukhi;

  /// See [PartA.anekGurmukhiTextTheme].
  static const anekGurmukhiTextTheme = PartA.anekGurmukhiTextTheme;

  /// See [PartA.anekKannada].
  static const anekKannada = PartA.anekKannada;

  /// See [PartA.anekKannadaTextTheme].
  static const anekKannadaTextTheme = PartA.anekKannadaTextTheme;

  /// See [PartA.anekLatin].
  static const anekLatin = PartA.anekLatin;

  /// See [PartA.anekLatinTextTheme].
  static const anekLatinTextTheme = PartA.anekLatinTextTheme;

  /// See [PartA.anekMalayalam].
  static const anekMalayalam = PartA.anekMalayalam;

  /// See [PartA.anekMalayalamTextTheme].
  static const anekMalayalamTextTheme = PartA.anekMalayalamTextTheme;

  /// See [PartA.anekOdia].
  static const anekOdia = PartA.anekOdia;

  /// See [PartA.anekOdiaTextTheme].
  static const anekOdiaTextTheme = PartA.anekOdiaTextTheme;

  /// See [PartA.anekTamil].
  static const anekTamil = PartA.anekTamil;

  /// See [PartA.anekTamilTextTheme].
  static const anekTamilTextTheme = PartA.anekTamilTextTheme;

  /// See [PartA.anekTelugu].
  static const anekTelugu = PartA.anekTelugu;

  /// See [PartA.anekTeluguTextTheme].
  static const anekTeluguTextTheme = PartA.anekTeluguTextTheme;

  /// See [PartA.angkor].
  static const angkor = PartA.angkor;

  /// See [PartA.angkorTextTheme].
  static const angkorTextTheme = PartA.angkorTextTheme;

  /// See [PartA.annapurnaSil].
  static const annapurnaSil = PartA.annapurnaSil;

  /// See [PartA.annapurnaSilTextTheme].
  static const annapurnaSilTextTheme = PartA.annapurnaSilTextTheme;

  /// See [PartA.annieUseYourTelescope].
  static const annieUseYourTelescope = PartA.annieUseYourTelescope;

  /// See [PartA.annieUseYourTelescopeTextTheme].
  static const annieUseYourTelescopeTextTheme =
      PartA.annieUseYourTelescopeTextTheme;

  /// See [PartA.anonymousPro].
  static const anonymousPro = PartA.anonymousPro;

  /// See [PartA.anonymousProTextTheme].
  static const anonymousProTextTheme = PartA.anonymousProTextTheme;

  /// See [PartA.anta].
  static const anta = PartA.anta;

  /// See [PartA.antaTextTheme].
  static const antaTextTheme = PartA.antaTextTheme;

  /// See [PartA.antic].
  static const antic = PartA.antic;

  /// See [PartA.anticTextTheme].
  static const anticTextTheme = PartA.anticTextTheme;

  /// See [PartA.anticDidone].
  static const anticDidone = PartA.anticDidone;

  /// See [PartA.anticDidoneTextTheme].
  static const anticDidoneTextTheme = PartA.anticDidoneTextTheme;

  /// See [PartA.anticSlab].
  static const anticSlab = PartA.anticSlab;

  /// See [PartA.anticSlabTextTheme].
  static const anticSlabTextTheme = PartA.anticSlabTextTheme;

  /// See [PartA.anton].
  static const anton = PartA.anton;

  /// See [PartA.antonTextTheme].
  static const antonTextTheme = PartA.antonTextTheme;

  /// See [PartA.antonSc].
  static const antonSc = PartA.antonSc;

  /// See [PartA.antonScTextTheme].
  static const antonScTextTheme = PartA.antonScTextTheme;

  /// See [PartA.antonio].
  static const antonio = PartA.antonio;

  /// See [PartA.antonioTextTheme].
  static const antonioTextTheme = PartA.antonioTextTheme;

  /// See [PartA.anuphan].
  static const anuphan = PartA.anuphan;

  /// See [PartA.anuphanTextTheme].
  static const anuphanTextTheme = PartA.anuphanTextTheme;

  /// See [PartA.anybody].
  static const anybody = PartA.anybody;

  /// See [PartA.anybodyTextTheme].
  static const anybodyTextTheme = PartA.anybodyTextTheme;

  /// See [PartA.aoboshiOne].
  static const aoboshiOne = PartA.aoboshiOne;

  /// See [PartA.aoboshiOneTextTheme].
  static const aoboshiOneTextTheme = PartA.aoboshiOneTextTheme;

  /// See [PartA.arapey].
  static const arapey = PartA.arapey;

  /// See [PartA.arapeyTextTheme].
  static const arapeyTextTheme = PartA.arapeyTextTheme;

  /// See [PartA.arbutus].
  static const arbutus = PartA.arbutus;

  /// See [PartA.arbutusTextTheme].
  static const arbutusTextTheme = PartA.arbutusTextTheme;

  /// See [PartA.arbutusSlab].
  static const arbutusSlab = PartA.arbutusSlab;

  /// See [PartA.arbutusSlabTextTheme].
  static const arbutusSlabTextTheme = PartA.arbutusSlabTextTheme;

  /// See [PartA.architectsDaughter].
  static const architectsDaughter = PartA.architectsDaughter;

  /// See [PartA.architectsDaughterTextTheme].
  static const architectsDaughterTextTheme = PartA.architectsDaughterTextTheme;

  /// See [PartA.archivo].
  static const archivo = PartA.archivo;

  /// See [PartA.archivoTextTheme].
  static const archivoTextTheme = PartA.archivoTextTheme;

  /// See [PartA.archivoBlack].
  static const archivoBlack = PartA.archivoBlack;

  /// See [PartA.archivoBlackTextTheme].
  static const archivoBlackTextTheme = PartA.archivoBlackTextTheme;

  /// See [PartA.archivoNarrow].
  static const archivoNarrow = PartA.archivoNarrow;

  /// See [PartA.archivoNarrowTextTheme].
  static const archivoNarrowTextTheme = PartA.archivoNarrowTextTheme;

  /// See [PartA.areYouSerious].
  static const areYouSerious = PartA.areYouSerious;

  /// See [PartA.areYouSeriousTextTheme].
  static const areYouSeriousTextTheme = PartA.areYouSeriousTextTheme;

  /// See [PartA.arefRuqaa].
  static const arefRuqaa = PartA.arefRuqaa;

  /// See [PartA.arefRuqaaTextTheme].
  static const arefRuqaaTextTheme = PartA.arefRuqaaTextTheme;

  /// See [PartA.arefRuqaaInk].
  static const arefRuqaaInk = PartA.arefRuqaaInk;

  /// See [PartA.arefRuqaaInkTextTheme].
  static const arefRuqaaInkTextTheme = PartA.arefRuqaaInkTextTheme;

  /// See [PartA.arima].
  static const arima = PartA.arima;

  /// See [PartA.arimaTextTheme].
  static const arimaTextTheme = PartA.arimaTextTheme;

  /// See [PartA.arimo].
  static const arimo = PartA.arimo;

  /// See [PartA.arimoTextTheme].
  static const arimoTextTheme = PartA.arimoTextTheme;

  /// See [PartA.arizonia].
  static const arizonia = PartA.arizonia;

  /// See [PartA.arizoniaTextTheme].
  static const arizoniaTextTheme = PartA.arizoniaTextTheme;

  /// See [PartA.armata].
  static const armata = PartA.armata;

  /// See [PartA.armataTextTheme].
  static const armataTextTheme = PartA.armataTextTheme;

  /// See [PartA.arsenal].
  static const arsenal = PartA.arsenal;

  /// See [PartA.arsenalTextTheme].
  static const arsenalTextTheme = PartA.arsenalTextTheme;

  /// See [PartA.arsenalSc].
  static const arsenalSc = PartA.arsenalSc;

  /// See [PartA.arsenalScTextTheme].
  static const arsenalScTextTheme = PartA.arsenalScTextTheme;

  /// See [PartA.artifika].
  static const artifika = PartA.artifika;

  /// See [PartA.artifikaTextTheme].
  static const artifikaTextTheme = PartA.artifikaTextTheme;

  /// See [PartA.arvo].
  static const arvo = PartA.arvo;

  /// See [PartA.arvoTextTheme].
  static const arvoTextTheme = PartA.arvoTextTheme;

  /// See [PartA.arya].
  static const arya = PartA.arya;

  /// See [PartA.aryaTextTheme].
  static const aryaTextTheme = PartA.aryaTextTheme;

  /// See [PartA.asap].
  static const asap = PartA.asap;

  /// See [PartA.asapTextTheme].
  static const asapTextTheme = PartA.asapTextTheme;

  /// See [PartA.asar].
  static const asar = PartA.asar;

  /// See [PartA.asarTextTheme].
  static const asarTextTheme = PartA.asarTextTheme;

  /// See [PartA.asimovian].
  static const asimovian = PartA.asimovian;

  /// See [PartA.asimovianTextTheme].
  static const asimovianTextTheme = PartA.asimovianTextTheme;

  /// See [PartA.asset].
  static const asset = PartA.asset;

  /// See [PartA.assetTextTheme].
  static const assetTextTheme = PartA.assetTextTheme;

  /// See [PartA.assistant].
  static const assistant = PartA.assistant;

  /// See [PartA.assistantTextTheme].
  static const assistantTextTheme = PartA.assistantTextTheme;

  /// See [PartA.astaSans].
  static const astaSans = PartA.astaSans;

  /// See [PartA.astaSansTextTheme].
  static const astaSansTextTheme = PartA.astaSansTextTheme;

  /// See [PartA.astloch].
  static const astloch = PartA.astloch;

  /// See [PartA.astlochTextTheme].
  static const astlochTextTheme = PartA.astlochTextTheme;

  /// See [PartA.asul].
  static const asul = PartA.asul;

  /// See [PartA.asulTextTheme].
  static const asulTextTheme = PartA.asulTextTheme;

  /// See [PartA.athiti].
  static const athiti = PartA.athiti;

  /// See [PartA.athitiTextTheme].
  static const athitiTextTheme = PartA.athitiTextTheme;

  /// See [PartA.atkinsonHyperlegible].
  static const atkinsonHyperlegible = PartA.atkinsonHyperlegible;

  /// See [PartA.atkinsonHyperlegibleTextTheme].
  static const atkinsonHyperlegibleTextTheme =
      PartA.atkinsonHyperlegibleTextTheme;

  /// See [PartA.atkinsonHyperlegibleMono].
  static const atkinsonHyperlegibleMono = PartA.atkinsonHyperlegibleMono;

  /// See [PartA.atkinsonHyperlegibleMonoTextTheme].
  static const atkinsonHyperlegibleMonoTextTheme =
      PartA.atkinsonHyperlegibleMonoTextTheme;

  /// See [PartA.atkinsonHyperlegibleNext].
  static const atkinsonHyperlegibleNext = PartA.atkinsonHyperlegibleNext;

  /// See [PartA.atkinsonHyperlegibleNextTextTheme].
  static const atkinsonHyperlegibleNextTextTheme =
      PartA.atkinsonHyperlegibleNextTextTheme;

  /// See [PartA.atma].
  static const atma = PartA.atma;

  /// See [PartA.atmaTextTheme].
  static const atmaTextTheme = PartA.atmaTextTheme;

  /// See [PartA.atomicAge].
  static const atomicAge = PartA.atomicAge;

  /// See [PartA.atomicAgeTextTheme].
  static const atomicAgeTextTheme = PartA.atomicAgeTextTheme;

  /// See [PartA.aubrey].
  static const aubrey = PartA.aubrey;

  /// See [PartA.aubreyTextTheme].
  static const aubreyTextTheme = PartA.aubreyTextTheme;

  /// See [PartA.audiowide].
  static const audiowide = PartA.audiowide;

  /// See [PartA.audiowideTextTheme].
  static const audiowideTextTheme = PartA.audiowideTextTheme;

  /// See [PartA.autourOne].
  static const autourOne = PartA.autourOne;

  /// See [PartA.autourOneTextTheme].
  static const autourOneTextTheme = PartA.autourOneTextTheme;

  /// See [PartA.average].
  static const average = PartA.average;

  /// See [PartA.averageTextTheme].
  static const averageTextTheme = PartA.averageTextTheme;

  /// See [PartA.averageSans].
  static const averageSans = PartA.averageSans;

  /// See [PartA.averageSansTextTheme].
  static const averageSansTextTheme = PartA.averageSansTextTheme;

  /// See [PartA.averiaGruesaLibre].
  static const averiaGruesaLibre = PartA.averiaGruesaLibre;

  /// See [PartA.averiaGruesaLibreTextTheme].
  static const averiaGruesaLibreTextTheme = PartA.averiaGruesaLibreTextTheme;

  /// See [PartA.averiaLibre].
  static const averiaLibre = PartA.averiaLibre;

  /// See [PartA.averiaLibreTextTheme].
  static const averiaLibreTextTheme = PartA.averiaLibreTextTheme;

  /// See [PartA.averiaSansLibre].
  static const averiaSansLibre = PartA.averiaSansLibre;

  /// See [PartA.averiaSansLibreTextTheme].
  static const averiaSansLibreTextTheme = PartA.averiaSansLibreTextTheme;

  /// See [PartA.averiaSerifLibre].
  static const averiaSerifLibre = PartA.averiaSerifLibre;

  /// See [PartA.averiaSerifLibreTextTheme].
  static const averiaSerifLibreTextTheme = PartA.averiaSerifLibreTextTheme;

  /// See [PartA.azeretMono].
  static const azeretMono = PartA.azeretMono;

  /// See [PartA.azeretMonoTextTheme].
  static const azeretMonoTextTheme = PartA.azeretMonoTextTheme;

  /// See [PartB.b612].
  static const b612 = PartB.b612;

  /// See [PartB.b612TextTheme].
  static const b612TextTheme = PartB.b612TextTheme;

  /// See [PartB.b612Mono].
  static const b612Mono = PartB.b612Mono;

  /// See [PartB.b612MonoTextTheme].
  static const b612MonoTextTheme = PartB.b612MonoTextTheme;

  /// See [PartB.bizUDGothic].
  static const bizUDGothic = PartB.bizUDGothic;

  /// See [PartB.bizUDGothicTextTheme].
  static const bizUDGothicTextTheme = PartB.bizUDGothicTextTheme;

  /// See [PartB.bizUDMincho].
  static const bizUDMincho = PartB.bizUDMincho;

  /// See [PartB.bizUDMinchoTextTheme].
  static const bizUDMinchoTextTheme = PartB.bizUDMinchoTextTheme;

  /// See [PartB.bizUDPGothic].
  static const bizUDPGothic = PartB.bizUDPGothic;

  /// See [PartB.bizUDPGothicTextTheme].
  static const bizUDPGothicTextTheme = PartB.bizUDPGothicTextTheme;

  /// See [PartB.bizUDPMincho].
  static const bizUDPMincho = PartB.bizUDPMincho;

  /// See [PartB.bizUDPMinchoTextTheme].
  static const bizUDPMinchoTextTheme = PartB.bizUDPMinchoTextTheme;

  /// See [PartB.babylonica].
  static const babylonica = PartB.babylonica;

  /// See [PartB.babylonicaTextTheme].
  static const babylonicaTextTheme = PartB.babylonicaTextTheme;

  /// See [PartB.bacasimeAntique].
  static const bacasimeAntique = PartB.bacasimeAntique;

  /// See [PartB.bacasimeAntiqueTextTheme].
  static const bacasimeAntiqueTextTheme = PartB.bacasimeAntiqueTextTheme;

  /// See [PartB.badScript].
  static const badScript = PartB.badScript;

  /// See [PartB.badScriptTextTheme].
  static const badScriptTextTheme = PartB.badScriptTextTheme;

  /// See [PartB.badeenDisplay].
  static const badeenDisplay = PartB.badeenDisplay;

  /// See [PartB.badeenDisplayTextTheme].
  static const badeenDisplayTextTheme = PartB.badeenDisplayTextTheme;

  /// See [PartB.bagelFatOne].
  static const bagelFatOne = PartB.bagelFatOne;

  /// See [PartB.bagelFatOneTextTheme].
  static const bagelFatOneTextTheme = PartB.bagelFatOneTextTheme;

  /// See [PartB.bahiana].
  static const bahiana = PartB.bahiana;

  /// See [PartB.bahianaTextTheme].
  static const bahianaTextTheme = PartB.bahianaTextTheme;

  /// See [PartB.bahianita].
  static const bahianita = PartB.bahianita;

  /// See [PartB.bahianitaTextTheme].
  static const bahianitaTextTheme = PartB.bahianitaTextTheme;

  /// See [PartB.baiJamjuree].
  static const baiJamjuree = PartB.baiJamjuree;

  /// See [PartB.baiJamjureeTextTheme].
  static const baiJamjureeTextTheme = PartB.baiJamjureeTextTheme;

  /// See [PartB.bakbakOne].
  static const bakbakOne = PartB.bakbakOne;

  /// See [PartB.bakbakOneTextTheme].
  static const bakbakOneTextTheme = PartB.bakbakOneTextTheme;

  /// See [PartB.ballet].
  static const ballet = PartB.ballet;

  /// See [PartB.balletTextTheme].
  static const balletTextTheme = PartB.balletTextTheme;

  /// See [PartB.baloo2].
  static const baloo2 = PartB.baloo2;

  /// See [PartB.baloo2TextTheme].
  static const baloo2TextTheme = PartB.baloo2TextTheme;

  /// See [PartB.balooBhai2].
  static const balooBhai2 = PartB.balooBhai2;

  /// See [PartB.balooBhai2TextTheme].
  static const balooBhai2TextTheme = PartB.balooBhai2TextTheme;

  /// See [PartB.balooBhaijaan2].
  static const balooBhaijaan2 = PartB.balooBhaijaan2;

  /// See [PartB.balooBhaijaan2TextTheme].
  static const balooBhaijaan2TextTheme = PartB.balooBhaijaan2TextTheme;

  /// See [PartB.balooBhaina2].
  static const balooBhaina2 = PartB.balooBhaina2;

  /// See [PartB.balooBhaina2TextTheme].
  static const balooBhaina2TextTheme = PartB.balooBhaina2TextTheme;

  /// See [PartB.balooChettan2].
  static const balooChettan2 = PartB.balooChettan2;

  /// See [PartB.balooChettan2TextTheme].
  static const balooChettan2TextTheme = PartB.balooChettan2TextTheme;

  /// See [PartB.balooDa2].
  static const balooDa2 = PartB.balooDa2;

  /// See [PartB.balooDa2TextTheme].
  static const balooDa2TextTheme = PartB.balooDa2TextTheme;

  /// See [PartB.balooPaaji2].
  static const balooPaaji2 = PartB.balooPaaji2;

  /// See [PartB.balooPaaji2TextTheme].
  static const balooPaaji2TextTheme = PartB.balooPaaji2TextTheme;

  /// See [PartB.balooTamma2].
  static const balooTamma2 = PartB.balooTamma2;

  /// See [PartB.balooTamma2TextTheme].
  static const balooTamma2TextTheme = PartB.balooTamma2TextTheme;

  /// See [PartB.balooTammudu2].
  static const balooTammudu2 = PartB.balooTammudu2;

  /// See [PartB.balooTammudu2TextTheme].
  static const balooTammudu2TextTheme = PartB.balooTammudu2TextTheme;

  /// See [PartB.balooThambi2].
  static const balooThambi2 = PartB.balooThambi2;

  /// See [PartB.balooThambi2TextTheme].
  static const balooThambi2TextTheme = PartB.balooThambi2TextTheme;

  /// See [PartB.balsamiqSans].
  static const balsamiqSans = PartB.balsamiqSans;

  /// See [PartB.balsamiqSansTextTheme].
  static const balsamiqSansTextTheme = PartB.balsamiqSansTextTheme;

  /// See [PartB.balthazar].
  static const balthazar = PartB.balthazar;

  /// See [PartB.balthazarTextTheme].
  static const balthazarTextTheme = PartB.balthazarTextTheme;

  /// See [PartB.bangers].
  static const bangers = PartB.bangers;

  /// See [PartB.bangersTextTheme].
  static const bangersTextTheme = PartB.bangersTextTheme;

  /// See [PartB.barlow].
  static const barlow = PartB.barlow;

  /// See [PartB.barlowTextTheme].
  static const barlowTextTheme = PartB.barlowTextTheme;

  /// See [PartB.barlowCondensed].
  static const barlowCondensed = PartB.barlowCondensed;

  /// See [PartB.barlowCondensedTextTheme].
  static const barlowCondensedTextTheme = PartB.barlowCondensedTextTheme;

  /// See [PartB.barlowSemiCondensed].
  static const barlowSemiCondensed = PartB.barlowSemiCondensed;

  /// See [PartB.barlowSemiCondensedTextTheme].
  static const barlowSemiCondensedTextTheme =
      PartB.barlowSemiCondensedTextTheme;

  /// See [PartB.barriecito].
  static const barriecito = PartB.barriecito;

  /// See [PartB.barriecitoTextTheme].
  static const barriecitoTextTheme = PartB.barriecitoTextTheme;

  /// See [PartB.barrio].
  static const barrio = PartB.barrio;

  /// See [PartB.barrioTextTheme].
  static const barrioTextTheme = PartB.barrioTextTheme;

  /// See [PartB.basic].
  static const basic = PartB.basic;

  /// See [PartB.basicTextTheme].
  static const basicTextTheme = PartB.basicTextTheme;

  /// See [PartB.baskervville].
  static const baskervville = PartB.baskervville;

  /// See [PartB.baskervvilleTextTheme].
  static const baskervvilleTextTheme = PartB.baskervvilleTextTheme;

  /// See [PartB.baskervvilleSc].
  static const baskervvilleSc = PartB.baskervvilleSc;

  /// See [PartB.baskervvilleScTextTheme].
  static const baskervvilleScTextTheme = PartB.baskervvilleScTextTheme;

  /// See [PartB.battambang].
  static const battambang = PartB.battambang;

  /// See [PartB.battambangTextTheme].
  static const battambangTextTheme = PartB.battambangTextTheme;

  /// See [PartB.baumans].
  static const baumans = PartB.baumans;

  /// See [PartB.baumansTextTheme].
  static const baumansTextTheme = PartB.baumansTextTheme;

  /// See [PartB.bayon].
  static const bayon = PartB.bayon;

  /// See [PartB.bayonTextTheme].
  static const bayonTextTheme = PartB.bayonTextTheme;

  /// See [PartB.beVietnamPro].
  static const beVietnamPro = PartB.beVietnamPro;

  /// See [PartB.beVietnamProTextTheme].
  static const beVietnamProTextTheme = PartB.beVietnamProTextTheme;

  /// See [PartB.beauRivage].
  static const beauRivage = PartB.beauRivage;

  /// See [PartB.beauRivageTextTheme].
  static const beauRivageTextTheme = PartB.beauRivageTextTheme;

  /// See [PartB.bebasNeue].
  static const bebasNeue = PartB.bebasNeue;

  /// See [PartB.bebasNeueTextTheme].
  static const bebasNeueTextTheme = PartB.bebasNeueTextTheme;

  /// See [PartB.beiruti].
  static const beiruti = PartB.beiruti;

  /// See [PartB.beirutiTextTheme].
  static const beirutiTextTheme = PartB.beirutiTextTheme;

  /// See [PartB.belanosima].
  static const belanosima = PartB.belanosima;

  /// See [PartB.belanosimaTextTheme].
  static const belanosimaTextTheme = PartB.belanosimaTextTheme;

  /// See [PartB.belgrano].
  static const belgrano = PartB.belgrano;

  /// See [PartB.belgranoTextTheme].
  static const belgranoTextTheme = PartB.belgranoTextTheme;

  /// See [PartB.bellefair].
  static const bellefair = PartB.bellefair;

  /// See [PartB.bellefairTextTheme].
  static const bellefairTextTheme = PartB.bellefairTextTheme;

  /// See [PartB.belleza].
  static const belleza = PartB.belleza;

  /// See [PartB.bellezaTextTheme].
  static const bellezaTextTheme = PartB.bellezaTextTheme;

  /// See [PartB.bellota].
  static const bellota = PartB.bellota;

  /// See [PartB.bellotaTextTheme].
  static const bellotaTextTheme = PartB.bellotaTextTheme;

  /// See [PartB.bellotaText].
  static const bellotaText = PartB.bellotaText;

  /// See [PartB.bellotaTextTextTheme].
  static const bellotaTextTextTheme = PartB.bellotaTextTextTheme;

  /// See [PartB.benchNine].
  static const benchNine = PartB.benchNine;

  /// See [PartB.benchNineTextTheme].
  static const benchNineTextTheme = PartB.benchNineTextTheme;

  /// See [PartB.benne].
  static const benne = PartB.benne;

  /// See [PartB.benneTextTheme].
  static const benneTextTheme = PartB.benneTextTheme;

  /// See [PartB.bentham].
  static const bentham = PartB.bentham;

  /// See [PartB.benthamTextTheme].
  static const benthamTextTheme = PartB.benthamTextTheme;

  /// See [PartB.berkshireSwash].
  static const berkshireSwash = PartB.berkshireSwash;

  /// See [PartB.berkshireSwashTextTheme].
  static const berkshireSwashTextTheme = PartB.berkshireSwashTextTheme;

  /// See [PartB.besley].
  static const besley = PartB.besley;

  /// See [PartB.besleyTextTheme].
  static const besleyTextTheme = PartB.besleyTextTheme;

  /// See [PartB.bethEllen].
  static const bethEllen = PartB.bethEllen;

  /// See [PartB.bethEllenTextTheme].
  static const bethEllenTextTheme = PartB.bethEllenTextTheme;

  /// See [PartB.bevan].
  static const bevan = PartB.bevan;

  /// See [PartB.bevanTextTheme].
  static const bevanTextTheme = PartB.bevanTextTheme;

  /// See [PartB.bhuTukaExpandedOne].
  static const bhuTukaExpandedOne = PartB.bhuTukaExpandedOne;

  /// See [PartB.bhuTukaExpandedOneTextTheme].
  static const bhuTukaExpandedOneTextTheme = PartB.bhuTukaExpandedOneTextTheme;

  /// See [PartB.bigShoulders].
  static const bigShoulders = PartB.bigShoulders;

  /// See [PartB.bigShouldersTextTheme].
  static const bigShouldersTextTheme = PartB.bigShouldersTextTheme;

  /// See [PartB.bigShouldersInline].
  static const bigShouldersInline = PartB.bigShouldersInline;

  /// See [PartB.bigShouldersInlineTextTheme].
  static const bigShouldersInlineTextTheme = PartB.bigShouldersInlineTextTheme;

  /// See [PartB.bigShouldersStencil].
  static const bigShouldersStencil = PartB.bigShouldersStencil;

  /// See [PartB.bigShouldersStencilTextTheme].
  static const bigShouldersStencilTextTheme =
      PartB.bigShouldersStencilTextTheme;

  /// See [PartB.bigelowRules].
  static const bigelowRules = PartB.bigelowRules;

  /// See [PartB.bigelowRulesTextTheme].
  static const bigelowRulesTextTheme = PartB.bigelowRulesTextTheme;

  /// See [PartB.bigshotOne].
  static const bigshotOne = PartB.bigshotOne;

  /// See [PartB.bigshotOneTextTheme].
  static const bigshotOneTextTheme = PartB.bigshotOneTextTheme;

  /// See [PartB.bilbo].
  static const bilbo = PartB.bilbo;

  /// See [PartB.bilboTextTheme].
  static const bilboTextTheme = PartB.bilboTextTheme;

  /// See [PartB.bilboSwashCaps].
  static const bilboSwashCaps = PartB.bilboSwashCaps;

  /// See [PartB.bilboSwashCapsTextTheme].
  static const bilboSwashCapsTextTheme = PartB.bilboSwashCapsTextTheme;

  /// See [PartB.bioRhyme].
  static const bioRhyme = PartB.bioRhyme;

  /// See [PartB.bioRhymeTextTheme].
  static const bioRhymeTextTheme = PartB.bioRhymeTextTheme;

  /// See [PartB.birthstone].
  static const birthstone = PartB.birthstone;

  /// See [PartB.birthstoneTextTheme].
  static const birthstoneTextTheme = PartB.birthstoneTextTheme;

  /// See [PartB.birthstoneBounce].
  static const birthstoneBounce = PartB.birthstoneBounce;

  /// See [PartB.birthstoneBounceTextTheme].
  static const birthstoneBounceTextTheme = PartB.birthstoneBounceTextTheme;

  /// See [PartB.biryani].
  static const biryani = PartB.biryani;

  /// See [PartB.biryaniTextTheme].
  static const biryaniTextTheme = PartB.biryaniTextTheme;

  /// See [PartB.bitcount].
  static const bitcount = PartB.bitcount;

  /// See [PartB.bitcountTextTheme].
  static const bitcountTextTheme = PartB.bitcountTextTheme;

  /// See [PartB.bitcountGridDouble].
  static const bitcountGridDouble = PartB.bitcountGridDouble;

  /// See [PartB.bitcountGridDoubleTextTheme].
  static const bitcountGridDoubleTextTheme = PartB.bitcountGridDoubleTextTheme;

  /// See [PartB.bitcountGridDoubleInk].
  static const bitcountGridDoubleInk = PartB.bitcountGridDoubleInk;

  /// See [PartB.bitcountGridDoubleInkTextTheme].
  static const bitcountGridDoubleInkTextTheme =
      PartB.bitcountGridDoubleInkTextTheme;

  /// See [PartB.bitcountGridSingle].
  static const bitcountGridSingle = PartB.bitcountGridSingle;

  /// See [PartB.bitcountGridSingleTextTheme].
  static const bitcountGridSingleTextTheme = PartB.bitcountGridSingleTextTheme;

  /// See [PartB.bitcountGridSingleInk].
  static const bitcountGridSingleInk = PartB.bitcountGridSingleInk;

  /// See [PartB.bitcountGridSingleInkTextTheme].
  static const bitcountGridSingleInkTextTheme =
      PartB.bitcountGridSingleInkTextTheme;

  /// See [PartB.bitcountInk].
  static const bitcountInk = PartB.bitcountInk;

  /// See [PartB.bitcountInkTextTheme].
  static const bitcountInkTextTheme = PartB.bitcountInkTextTheme;

  /// See [PartB.bitcountPropDouble].
  static const bitcountPropDouble = PartB.bitcountPropDouble;

  /// See [PartB.bitcountPropDoubleTextTheme].
  static const bitcountPropDoubleTextTheme = PartB.bitcountPropDoubleTextTheme;

  /// See [PartB.bitcountPropDoubleInk].
  static const bitcountPropDoubleInk = PartB.bitcountPropDoubleInk;

  /// See [PartB.bitcountPropDoubleInkTextTheme].
  static const bitcountPropDoubleInkTextTheme =
      PartB.bitcountPropDoubleInkTextTheme;

  /// See [PartB.bitcountPropSingle].
  static const bitcountPropSingle = PartB.bitcountPropSingle;

  /// See [PartB.bitcountPropSingleTextTheme].
  static const bitcountPropSingleTextTheme = PartB.bitcountPropSingleTextTheme;

  /// See [PartB.bitcountPropSingleInk].
  static const bitcountPropSingleInk = PartB.bitcountPropSingleInk;

  /// See [PartB.bitcountPropSingleInkTextTheme].
  static const bitcountPropSingleInkTextTheme =
      PartB.bitcountPropSingleInkTextTheme;

  /// See [PartB.bitcountSingle].
  static const bitcountSingle = PartB.bitcountSingle;

  /// See [PartB.bitcountSingleTextTheme].
  static const bitcountSingleTextTheme = PartB.bitcountSingleTextTheme;

  /// See [PartB.bitcountSingleInk].
  static const bitcountSingleInk = PartB.bitcountSingleInk;

  /// See [PartB.bitcountSingleInkTextTheme].
  static const bitcountSingleInkTextTheme = PartB.bitcountSingleInkTextTheme;

  /// See [PartB.bitter].
  static const bitter = PartB.bitter;

  /// See [PartB.bitterTextTheme].
  static const bitterTextTheme = PartB.bitterTextTheme;

  /// See [PartB.blackAndWhitePicture].
  static const blackAndWhitePicture = PartB.blackAndWhitePicture;

  /// See [PartB.blackAndWhitePictureTextTheme].
  static const blackAndWhitePictureTextTheme =
      PartB.blackAndWhitePictureTextTheme;

  /// See [PartB.blackHanSans].
  static const blackHanSans = PartB.blackHanSans;

  /// See [PartB.blackHanSansTextTheme].
  static const blackHanSansTextTheme = PartB.blackHanSansTextTheme;

  /// See [PartB.blackOpsOne].
  static const blackOpsOne = PartB.blackOpsOne;

  /// See [PartB.blackOpsOneTextTheme].
  static const blackOpsOneTextTheme = PartB.blackOpsOneTextTheme;

  /// See [PartB.blaka].
  static const blaka = PartB.blaka;

  /// See [PartB.blakaTextTheme].
  static const blakaTextTheme = PartB.blakaTextTheme;

  /// See [PartB.blakaHollow].
  static const blakaHollow = PartB.blakaHollow;

  /// See [PartB.blakaHollowTextTheme].
  static const blakaHollowTextTheme = PartB.blakaHollowTextTheme;

  /// See [PartB.blakaInk].
  static const blakaInk = PartB.blakaInk;

  /// See [PartB.blakaInkTextTheme].
  static const blakaInkTextTheme = PartB.blakaInkTextTheme;

  /// See [PartB.blinker].
  static const blinker = PartB.blinker;

  /// See [PartB.blinkerTextTheme].
  static const blinkerTextTheme = PartB.blinkerTextTheme;

  /// See [PartB.bodoniModa].
  static const bodoniModa = PartB.bodoniModa;

  /// See [PartB.bodoniModaTextTheme].
  static const bodoniModaTextTheme = PartB.bodoniModaTextTheme;

  /// See [PartB.bodoniModaSc].
  static const bodoniModaSc = PartB.bodoniModaSc;

  /// See [PartB.bodoniModaScTextTheme].
  static const bodoniModaScTextTheme = PartB.bodoniModaScTextTheme;

  /// See [PartB.bokor].
  static const bokor = PartB.bokor;

  /// See [PartB.bokorTextTheme].
  static const bokorTextTheme = PartB.bokorTextTheme;

  /// See [PartB.boldonse].
  static const boldonse = PartB.boldonse;

  /// See [PartB.boldonseTextTheme].
  static const boldonseTextTheme = PartB.boldonseTextTheme;

  /// See [PartB.bonaNova].
  static const bonaNova = PartB.bonaNova;

  /// See [PartB.bonaNovaTextTheme].
  static const bonaNovaTextTheme = PartB.bonaNovaTextTheme;

  /// See [PartB.bonaNovaSc].
  static const bonaNovaSc = PartB.bonaNovaSc;

  /// See [PartB.bonaNovaScTextTheme].
  static const bonaNovaScTextTheme = PartB.bonaNovaScTextTheme;

  /// See [PartB.bonbon].
  static const bonbon = PartB.bonbon;

  /// See [PartB.bonbonTextTheme].
  static const bonbonTextTheme = PartB.bonbonTextTheme;

  /// See [PartB.bonheurRoyale].
  static const bonheurRoyale = PartB.bonheurRoyale;

  /// See [PartB.bonheurRoyaleTextTheme].
  static const bonheurRoyaleTextTheme = PartB.bonheurRoyaleTextTheme;

  /// See [PartB.boogaloo].
  static const boogaloo = PartB.boogaloo;

  /// See [PartB.boogalooTextTheme].
  static const boogalooTextTheme = PartB.boogalooTextTheme;

  /// See [PartB.borel].
  static const borel = PartB.borel;

  /// See [PartB.borelTextTheme].
  static const borelTextTheme = PartB.borelTextTheme;

  /// See [PartB.bowlbyOne].
  static const bowlbyOne = PartB.bowlbyOne;

  /// See [PartB.bowlbyOneTextTheme].
  static const bowlbyOneTextTheme = PartB.bowlbyOneTextTheme;

  /// See [PartB.bowlbyOneSc].
  static const bowlbyOneSc = PartB.bowlbyOneSc;

  /// See [PartB.bowlbyOneScTextTheme].
  static const bowlbyOneScTextTheme = PartB.bowlbyOneScTextTheme;

  /// See [PartB.braahOne].
  static const braahOne = PartB.braahOne;

  /// See [PartB.braahOneTextTheme].
  static const braahOneTextTheme = PartB.braahOneTextTheme;

  /// See [PartB.brawler].
  static const brawler = PartB.brawler;

  /// See [PartB.brawlerTextTheme].
  static const brawlerTextTheme = PartB.brawlerTextTheme;

  /// See [PartB.breeSerif].
  static const breeSerif = PartB.breeSerif;

  /// See [PartB.breeSerifTextTheme].
  static const breeSerifTextTheme = PartB.breeSerifTextTheme;

  /// See [PartB.bricolageGrotesque].
  static const bricolageGrotesque = PartB.bricolageGrotesque;

  /// See [PartB.bricolageGrotesqueTextTheme].
  static const bricolageGrotesqueTextTheme = PartB.bricolageGrotesqueTextTheme;

  /// See [PartB.brunoAce].
  static const brunoAce = PartB.brunoAce;

  /// See [PartB.brunoAceTextTheme].
  static const brunoAceTextTheme = PartB.brunoAceTextTheme;

  /// See [PartB.brunoAceSc].
  static const brunoAceSc = PartB.brunoAceSc;

  /// See [PartB.brunoAceScTextTheme].
  static const brunoAceScTextTheme = PartB.brunoAceScTextTheme;

  /// See [PartB.brygada1918].
  static const brygada1918 = PartB.brygada1918;

  /// See [PartB.brygada1918TextTheme].
  static const brygada1918TextTheme = PartB.brygada1918TextTheme;

  /// See [PartB.bubblegumSans].
  static const bubblegumSans = PartB.bubblegumSans;

  /// See [PartB.bubblegumSansTextTheme].
  static const bubblegumSansTextTheme = PartB.bubblegumSansTextTheme;

  /// See [PartB.bubblerOne].
  static const bubblerOne = PartB.bubblerOne;

  /// See [PartB.bubblerOneTextTheme].
  static const bubblerOneTextTheme = PartB.bubblerOneTextTheme;

  /// See [PartB.buda].
  static const buda = PartB.buda;

  /// See [PartB.budaTextTheme].
  static const budaTextTheme = PartB.budaTextTheme;

  /// See [PartB.buenard].
  static const buenard = PartB.buenard;

  /// See [PartB.buenardTextTheme].
  static const buenardTextTheme = PartB.buenardTextTheme;

  /// See [PartB.bungee].
  static const bungee = PartB.bungee;

  /// See [PartB.bungeeTextTheme].
  static const bungeeTextTheme = PartB.bungeeTextTheme;

  /// See [PartB.bungeeHairline].
  static const bungeeHairline = PartB.bungeeHairline;

  /// See [PartB.bungeeHairlineTextTheme].
  static const bungeeHairlineTextTheme = PartB.bungeeHairlineTextTheme;

  /// See [PartB.bungeeInline].
  static const bungeeInline = PartB.bungeeInline;

  /// See [PartB.bungeeInlineTextTheme].
  static const bungeeInlineTextTheme = PartB.bungeeInlineTextTheme;

  /// See [PartB.bungeeOutline].
  static const bungeeOutline = PartB.bungeeOutline;

  /// See [PartB.bungeeOutlineTextTheme].
  static const bungeeOutlineTextTheme = PartB.bungeeOutlineTextTheme;

  /// See [PartB.bungeeShade].
  static const bungeeShade = PartB.bungeeShade;

  /// See [PartB.bungeeShadeTextTheme].
  static const bungeeShadeTextTheme = PartB.bungeeShadeTextTheme;

  /// See [PartB.bungeeSpice].
  static const bungeeSpice = PartB.bungeeSpice;

  /// See [PartB.bungeeSpiceTextTheme].
  static const bungeeSpiceTextTheme = PartB.bungeeSpiceTextTheme;

  /// See [PartB.bungeeTint].
  static const bungeeTint = PartB.bungeeTint;

  /// See [PartB.bungeeTintTextTheme].
  static const bungeeTintTextTheme = PartB.bungeeTintTextTheme;

  /// See [PartB.butcherman].
  static const butcherman = PartB.butcherman;

  /// See [PartB.butchermanTextTheme].
  static const butchermanTextTheme = PartB.butchermanTextTheme;

  /// See [PartB.butterflyKids].
  static const butterflyKids = PartB.butterflyKids;

  /// See [PartB.butterflyKidsTextTheme].
  static const butterflyKidsTextTheme = PartB.butterflyKidsTextTheme;

  /// See [PartB.bytesized].
  static const bytesized = PartB.bytesized;

  /// See [PartB.bytesizedTextTheme].
  static const bytesizedTextTheme = PartB.bytesizedTextTheme;

  /// See [PartC.cabin].
  static const cabin = PartC.cabin;

  /// See [PartC.cabinTextTheme].
  static const cabinTextTheme = PartC.cabinTextTheme;

  /// See [PartC.cabinSketch].
  static const cabinSketch = PartC.cabinSketch;

  /// See [PartC.cabinSketchTextTheme].
  static const cabinSketchTextTheme = PartC.cabinSketchTextTheme;

  /// See [PartC.cactusClassicalSerif].
  static const cactusClassicalSerif = PartC.cactusClassicalSerif;

  /// See [PartC.cactusClassicalSerifTextTheme].
  static const cactusClassicalSerifTextTheme =
      PartC.cactusClassicalSerifTextTheme;

  /// See [PartC.caesarDressing].
  static const caesarDressing = PartC.caesarDressing;

  /// See [PartC.caesarDressingTextTheme].
  static const caesarDressingTextTheme = PartC.caesarDressingTextTheme;

  /// See [PartC.cagliostro].
  static const cagliostro = PartC.cagliostro;

  /// See [PartC.cagliostroTextTheme].
  static const cagliostroTextTheme = PartC.cagliostroTextTheme;

  /// See [PartC.cairo].
  static const cairo = PartC.cairo;

  /// See [PartC.cairoTextTheme].
  static const cairoTextTheme = PartC.cairoTextTheme;

  /// See [PartC.cairoPlay].
  static const cairoPlay = PartC.cairoPlay;

  /// See [PartC.cairoPlayTextTheme].
  static const cairoPlayTextTheme = PartC.cairoPlayTextTheme;

  /// See [PartC.calSans].
  static const calSans = PartC.calSans;

  /// See [PartC.calSansTextTheme].
  static const calSansTextTheme = PartC.calSansTextTheme;

  /// See [PartC.caladea].
  static const caladea = PartC.caladea;

  /// See [PartC.caladeaTextTheme].
  static const caladeaTextTheme = PartC.caladeaTextTheme;

  /// See [PartC.calistoga].
  static const calistoga = PartC.calistoga;

  /// See [PartC.calistogaTextTheme].
  static const calistogaTextTheme = PartC.calistogaTextTheme;

  /// See [PartC.calligraffitti].
  static const calligraffitti = PartC.calligraffitti;

  /// See [PartC.calligraffittiTextTheme].
  static const calligraffittiTextTheme = PartC.calligraffittiTextTheme;

  /// See [PartC.cambay].
  static const cambay = PartC.cambay;

  /// See [PartC.cambayTextTheme].
  static const cambayTextTheme = PartC.cambayTextTheme;

  /// See [PartC.cambo].
  static const cambo = PartC.cambo;

  /// See [PartC.camboTextTheme].
  static const camboTextTheme = PartC.camboTextTheme;

  /// See [PartC.candal].
  static const candal = PartC.candal;

  /// See [PartC.candalTextTheme].
  static const candalTextTheme = PartC.candalTextTheme;

  /// See [PartC.cantarell].
  static const cantarell = PartC.cantarell;

  /// See [PartC.cantarellTextTheme].
  static const cantarellTextTheme = PartC.cantarellTextTheme;

  /// See [PartC.cantataOne].
  static const cantataOne = PartC.cantataOne;

  /// See [PartC.cantataOneTextTheme].
  static const cantataOneTextTheme = PartC.cantataOneTextTheme;

  /// See [PartC.cantoraOne].
  static const cantoraOne = PartC.cantoraOne;

  /// See [PartC.cantoraOneTextTheme].
  static const cantoraOneTextTheme = PartC.cantoraOneTextTheme;

  /// See [PartC.caprasimo].
  static const caprasimo = PartC.caprasimo;

  /// See [PartC.caprasimoTextTheme].
  static const caprasimoTextTheme = PartC.caprasimoTextTheme;

  /// See [PartC.capriola].
  static const capriola = PartC.capriola;

  /// See [PartC.capriolaTextTheme].
  static const capriolaTextTheme = PartC.capriolaTextTheme;

  /// See [PartC.caramel].
  static const caramel = PartC.caramel;

  /// See [PartC.caramelTextTheme].
  static const caramelTextTheme = PartC.caramelTextTheme;

  /// See [PartC.carattere].
  static const carattere = PartC.carattere;

  /// See [PartC.carattereTextTheme].
  static const carattereTextTheme = PartC.carattereTextTheme;

  /// See [PartC.cardo].
  static const cardo = PartC.cardo;

  /// See [PartC.cardoTextTheme].
  static const cardoTextTheme = PartC.cardoTextTheme;

  /// See [PartC.carlito].
  static const carlito = PartC.carlito;

  /// See [PartC.carlitoTextTheme].
  static const carlitoTextTheme = PartC.carlitoTextTheme;

  /// See [PartC.carme].
  static const carme = PartC.carme;

  /// See [PartC.carmeTextTheme].
  static const carmeTextTheme = PartC.carmeTextTheme;

  /// See [PartC.carroisGothic].
  static const carroisGothic = PartC.carroisGothic;

  /// See [PartC.carroisGothicTextTheme].
  static const carroisGothicTextTheme = PartC.carroisGothicTextTheme;

  /// See [PartC.carroisGothicSc].
  static const carroisGothicSc = PartC.carroisGothicSc;

  /// See [PartC.carroisGothicScTextTheme].
  static const carroisGothicScTextTheme = PartC.carroisGothicScTextTheme;

  /// See [PartC.carterOne].
  static const carterOne = PartC.carterOne;

  /// See [PartC.carterOneTextTheme].
  static const carterOneTextTheme = PartC.carterOneTextTheme;

  /// See [PartC.cascadiaCode].
  static const cascadiaCode = PartC.cascadiaCode;

  /// See [PartC.cascadiaCodeTextTheme].
  static const cascadiaCodeTextTheme = PartC.cascadiaCodeTextTheme;

  /// See [PartC.cascadiaMono].
  static const cascadiaMono = PartC.cascadiaMono;

  /// See [PartC.cascadiaMonoTextTheme].
  static const cascadiaMonoTextTheme = PartC.cascadiaMonoTextTheme;

  /// See [PartC.castoro].
  static const castoro = PartC.castoro;

  /// See [PartC.castoroTextTheme].
  static const castoroTextTheme = PartC.castoroTextTheme;

  /// See [PartC.castoroTitling].
  static const castoroTitling = PartC.castoroTitling;

  /// See [PartC.castoroTitlingTextTheme].
  static const castoroTitlingTextTheme = PartC.castoroTitlingTextTheme;

  /// See [PartC.catamaran].
  static const catamaran = PartC.catamaran;

  /// See [PartC.catamaranTextTheme].
  static const catamaranTextTheme = PartC.catamaranTextTheme;

  /// See [PartC.caudex].
  static const caudex = PartC.caudex;

  /// See [PartC.caudexTextTheme].
  static const caudexTextTheme = PartC.caudexTextTheme;

  /// See [PartC.caveat].
  static const caveat = PartC.caveat;

  /// See [PartC.caveatTextTheme].
  static const caveatTextTheme = PartC.caveatTextTheme;

  /// See [PartC.caveatBrush].
  static const caveatBrush = PartC.caveatBrush;

  /// See [PartC.caveatBrushTextTheme].
  static const caveatBrushTextTheme = PartC.caveatBrushTextTheme;

  /// See [PartC.cedarvilleCursive].
  static const cedarvilleCursive = PartC.cedarvilleCursive;

  /// See [PartC.cedarvilleCursiveTextTheme].
  static const cedarvilleCursiveTextTheme = PartC.cedarvilleCursiveTextTheme;

  /// See [PartC.cevicheOne].
  static const cevicheOne = PartC.cevicheOne;

  /// See [PartC.cevicheOneTextTheme].
  static const cevicheOneTextTheme = PartC.cevicheOneTextTheme;

  /// See [PartC.chakraPetch].
  static const chakraPetch = PartC.chakraPetch;

  /// See [PartC.chakraPetchTextTheme].
  static const chakraPetchTextTheme = PartC.chakraPetchTextTheme;

  /// See [PartC.changa].
  static const changa = PartC.changa;

  /// See [PartC.changaTextTheme].
  static const changaTextTheme = PartC.changaTextTheme;

  /// See [PartC.changaOne].
  static const changaOne = PartC.changaOne;

  /// See [PartC.changaOneTextTheme].
  static const changaOneTextTheme = PartC.changaOneTextTheme;

  /// See [PartC.chango].
  static const chango = PartC.chango;

  /// See [PartC.changoTextTheme].
  static const changoTextTheme = PartC.changoTextTheme;

  /// See [PartC.charisSil].
  static const charisSil = PartC.charisSil;

  /// See [PartC.charisSilTextTheme].
  static const charisSilTextTheme = PartC.charisSilTextTheme;

  /// See [PartC.charm].
  static const charm = PartC.charm;

  /// See [PartC.charmTextTheme].
  static const charmTextTheme = PartC.charmTextTheme;

  /// See [PartC.charmonman].
  static const charmonman = PartC.charmonman;

  /// See [PartC.charmonmanTextTheme].
  static const charmonmanTextTheme = PartC.charmonmanTextTheme;

  /// See [PartC.chathura].
  static const chathura = PartC.chathura;

  /// See [PartC.chathuraTextTheme].
  static const chathuraTextTheme = PartC.chathuraTextTheme;

  /// See [PartC.chauPhilomeneOne].
  static const chauPhilomeneOne = PartC.chauPhilomeneOne;

  /// See [PartC.chauPhilomeneOneTextTheme].
  static const chauPhilomeneOneTextTheme = PartC.chauPhilomeneOneTextTheme;

  /// See [PartC.chelaOne].
  static const chelaOne = PartC.chelaOne;

  /// See [PartC.chelaOneTextTheme].
  static const chelaOneTextTheme = PartC.chelaOneTextTheme;

  /// See [PartC.chelseaMarket].
  static const chelseaMarket = PartC.chelseaMarket;

  /// See [PartC.chelseaMarketTextTheme].
  static const chelseaMarketTextTheme = PartC.chelseaMarketTextTheme;

  /// See [PartC.chenla].
  static const chenla = PartC.chenla;

  /// See [PartC.chenlaTextTheme].
  static const chenlaTextTheme = PartC.chenlaTextTheme;

  /// See [PartC.cherish].
  static const cherish = PartC.cherish;

  /// See [PartC.cherishTextTheme].
  static const cherishTextTheme = PartC.cherishTextTheme;

  /// See [PartC.cherryBombOne].
  static const cherryBombOne = PartC.cherryBombOne;

  /// See [PartC.cherryBombOneTextTheme].
  static const cherryBombOneTextTheme = PartC.cherryBombOneTextTheme;

  /// See [PartC.cherryCreamSoda].
  static const cherryCreamSoda = PartC.cherryCreamSoda;

  /// See [PartC.cherryCreamSodaTextTheme].
  static const cherryCreamSodaTextTheme = PartC.cherryCreamSodaTextTheme;

  /// See [PartC.cherrySwash].
  static const cherrySwash = PartC.cherrySwash;

  /// See [PartC.cherrySwashTextTheme].
  static const cherrySwashTextTheme = PartC.cherrySwashTextTheme;

  /// See [PartC.chewy].
  static const chewy = PartC.chewy;

  /// See [PartC.chewyTextTheme].
  static const chewyTextTheme = PartC.chewyTextTheme;

  /// See [PartC.chicle].
  static const chicle = PartC.chicle;

  /// See [PartC.chicleTextTheme].
  static const chicleTextTheme = PartC.chicleTextTheme;

  /// See [PartC.chilanka].
  static const chilanka = PartC.chilanka;

  /// See [PartC.chilankaTextTheme].
  static const chilankaTextTheme = PartC.chilankaTextTheme;

  /// See [PartC.chironGoRoundTc].
  static const chironGoRoundTc = PartC.chironGoRoundTc;

  /// See [PartC.chironGoRoundTcTextTheme].
  static const chironGoRoundTcTextTheme = PartC.chironGoRoundTcTextTheme;

  /// See [PartC.chironHeiHk].
  static const chironHeiHk = PartC.chironHeiHk;

  /// See [PartC.chironHeiHkTextTheme].
  static const chironHeiHkTextTheme = PartC.chironHeiHkTextTheme;

  /// See [PartC.chironSungHk].
  static const chironSungHk = PartC.chironSungHk;

  /// See [PartC.chironSungHkTextTheme].
  static const chironSungHkTextTheme = PartC.chironSungHkTextTheme;

  /// See [PartC.chivo].
  static const chivo = PartC.chivo;

  /// See [PartC.chivoTextTheme].
  static const chivoTextTheme = PartC.chivoTextTheme;

  /// See [PartC.chivoMono].
  static const chivoMono = PartC.chivoMono;

  /// See [PartC.chivoMonoTextTheme].
  static const chivoMonoTextTheme = PartC.chivoMonoTextTheme;

  /// See [PartC.chocolateClassicalSans].
  static const chocolateClassicalSans = PartC.chocolateClassicalSans;

  /// See [PartC.chocolateClassicalSansTextTheme].
  static const chocolateClassicalSansTextTheme =
      PartC.chocolateClassicalSansTextTheme;

  /// See [PartC.chokokutai].
  static const chokokutai = PartC.chokokutai;

  /// See [PartC.chokokutaiTextTheme].
  static const chokokutaiTextTheme = PartC.chokokutaiTextTheme;

  /// See [PartC.chonburi].
  static const chonburi = PartC.chonburi;

  /// See [PartC.chonburiTextTheme].
  static const chonburiTextTheme = PartC.chonburiTextTheme;

  /// See [PartC.cinzel].
  static const cinzel = PartC.cinzel;

  /// See [PartC.cinzelTextTheme].
  static const cinzelTextTheme = PartC.cinzelTextTheme;

  /// See [PartC.cinzelDecorative].
  static const cinzelDecorative = PartC.cinzelDecorative;

  /// See [PartC.cinzelDecorativeTextTheme].
  static const cinzelDecorativeTextTheme = PartC.cinzelDecorativeTextTheme;

  /// See [PartC.clickerScript].
  static const clickerScript = PartC.clickerScript;

  /// See [PartC.clickerScriptTextTheme].
  static const clickerScriptTextTheme = PartC.clickerScriptTextTheme;

  /// See [PartC.climateCrisis].
  static const climateCrisis = PartC.climateCrisis;

  /// See [PartC.climateCrisisTextTheme].
  static const climateCrisisTextTheme = PartC.climateCrisisTextTheme;

  /// See [PartC.coda].
  static const coda = PartC.coda;

  /// See [PartC.codaTextTheme].
  static const codaTextTheme = PartC.codaTextTheme;

  /// See [PartC.codystar].
  static const codystar = PartC.codystar;

  /// See [PartC.codystarTextTheme].
  static const codystarTextTheme = PartC.codystarTextTheme;

  /// See [PartC.coiny].
  static const coiny = PartC.coiny;

  /// See [PartC.coinyTextTheme].
  static const coinyTextTheme = PartC.coinyTextTheme;

  /// See [PartC.combo].
  static const combo = PartC.combo;

  /// See [PartC.comboTextTheme].
  static const comboTextTheme = PartC.comboTextTheme;

  /// See [PartC.comfortaa].
  static const comfortaa = PartC.comfortaa;

  /// See [PartC.comfortaaTextTheme].
  static const comfortaaTextTheme = PartC.comfortaaTextTheme;

  /// See [PartC.comforter].
  static const comforter = PartC.comforter;

  /// See [PartC.comforterTextTheme].
  static const comforterTextTheme = PartC.comforterTextTheme;

  /// See [PartC.comforterBrush].
  static const comforterBrush = PartC.comforterBrush;

  /// See [PartC.comforterBrushTextTheme].
  static const comforterBrushTextTheme = PartC.comforterBrushTextTheme;

  /// See [PartC.comicNeue].
  static const comicNeue = PartC.comicNeue;

  /// See [PartC.comicNeueTextTheme].
  static const comicNeueTextTheme = PartC.comicNeueTextTheme;

  /// See [PartC.comicRelief].
  static const comicRelief = PartC.comicRelief;

  /// See [PartC.comicReliefTextTheme].
  static const comicReliefTextTheme = PartC.comicReliefTextTheme;

  /// See [PartC.comingSoon].
  static const comingSoon = PartC.comingSoon;

  /// See [PartC.comingSoonTextTheme].
  static const comingSoonTextTheme = PartC.comingSoonTextTheme;

  /// See [PartC.comme].
  static const comme = PartC.comme;

  /// See [PartC.commeTextTheme].
  static const commeTextTheme = PartC.commeTextTheme;

  /// See [PartC.commissioner].
  static const commissioner = PartC.commissioner;

  /// See [PartC.commissionerTextTheme].
  static const commissionerTextTheme = PartC.commissionerTextTheme;

  /// See [PartC.concertOne].
  static const concertOne = PartC.concertOne;

  /// See [PartC.concertOneTextTheme].
  static const concertOneTextTheme = PartC.concertOneTextTheme;

  /// See [PartC.condiment].
  static const condiment = PartC.condiment;

  /// See [PartC.condimentTextTheme].
  static const condimentTextTheme = PartC.condimentTextTheme;

  /// See [PartC.content].
  static const content = PartC.content;

  /// See [PartC.contentTextTheme].
  static const contentTextTheme = PartC.contentTextTheme;

  /// See [PartC.contrailOne].
  static const contrailOne = PartC.contrailOne;

  /// See [PartC.contrailOneTextTheme].
  static const contrailOneTextTheme = PartC.contrailOneTextTheme;

  /// See [PartC.convergence].
  static const convergence = PartC.convergence;

  /// See [PartC.convergenceTextTheme].
  static const convergenceTextTheme = PartC.convergenceTextTheme;

  /// See [PartC.cookie].
  static const cookie = PartC.cookie;

  /// See [PartC.cookieTextTheme].
  static const cookieTextTheme = PartC.cookieTextTheme;

  /// See [PartC.copse].
  static const copse = PartC.copse;

  /// See [PartC.copseTextTheme].
  static const copseTextTheme = PartC.copseTextTheme;

  /// See [PartC.coralPixels].
  static const coralPixels = PartC.coralPixels;

  /// See [PartC.coralPixelsTextTheme].
  static const coralPixelsTextTheme = PartC.coralPixelsTextTheme;

  /// See [PartC.corben].
  static const corben = PartC.corben;

  /// See [PartC.corbenTextTheme].
  static const corbenTextTheme = PartC.corbenTextTheme;

  /// See [PartC.corinthia].
  static const corinthia = PartC.corinthia;

  /// See [PartC.corinthiaTextTheme].
  static const corinthiaTextTheme = PartC.corinthiaTextTheme;

  /// See [PartC.cormorant].
  static const cormorant = PartC.cormorant;

  /// See [PartC.cormorantTextTheme].
  static const cormorantTextTheme = PartC.cormorantTextTheme;

  /// See [PartC.cormorantGaramond].
  static const cormorantGaramond = PartC.cormorantGaramond;

  /// See [PartC.cormorantGaramondTextTheme].
  static const cormorantGaramondTextTheme = PartC.cormorantGaramondTextTheme;

  /// See [PartC.cormorantInfant].
  static const cormorantInfant = PartC.cormorantInfant;

  /// See [PartC.cormorantInfantTextTheme].
  static const cormorantInfantTextTheme = PartC.cormorantInfantTextTheme;

  /// See [PartC.cormorantSc].
  static const cormorantSc = PartC.cormorantSc;

  /// See [PartC.cormorantScTextTheme].
  static const cormorantScTextTheme = PartC.cormorantScTextTheme;

  /// See [PartC.cormorantUnicase].
  static const cormorantUnicase = PartC.cormorantUnicase;

  /// See [PartC.cormorantUnicaseTextTheme].
  static const cormorantUnicaseTextTheme = PartC.cormorantUnicaseTextTheme;

  /// See [PartC.cormorantUpright].
  static const cormorantUpright = PartC.cormorantUpright;

  /// See [PartC.cormorantUprightTextTheme].
  static const cormorantUprightTextTheme = PartC.cormorantUprightTextTheme;

  /// See [PartC.cossetteTexte].
  static const cossetteTexte = PartC.cossetteTexte;

  /// See [PartC.cossetteTexteTextTheme].
  static const cossetteTexteTextTheme = PartC.cossetteTexteTextTheme;

  /// See [PartC.cossetteTitre].
  static const cossetteTitre = PartC.cossetteTitre;

  /// See [PartC.cossetteTitreTextTheme].
  static const cossetteTitreTextTheme = PartC.cossetteTitreTextTheme;

  /// See [PartC.courgette].
  static const courgette = PartC.courgette;

  /// See [PartC.courgetteTextTheme].
  static const courgetteTextTheme = PartC.courgetteTextTheme;

  /// See [PartC.courierPrime].
  static const courierPrime = PartC.courierPrime;

  /// See [PartC.courierPrimeTextTheme].
  static const courierPrimeTextTheme = PartC.courierPrimeTextTheme;

  /// See [PartC.cousine].
  static const cousine = PartC.cousine;

  /// See [PartC.cousineTextTheme].
  static const cousineTextTheme = PartC.cousineTextTheme;

  /// See [PartC.coustard].
  static const coustard = PartC.coustard;

  /// See [PartC.coustardTextTheme].
  static const coustardTextTheme = PartC.coustardTextTheme;

  /// See [PartC.coveredByYourGrace].
  static const coveredByYourGrace = PartC.coveredByYourGrace;

  /// See [PartC.coveredByYourGraceTextTheme].
  static const coveredByYourGraceTextTheme = PartC.coveredByYourGraceTextTheme;

  /// See [PartC.craftyGirls].
  static const craftyGirls = PartC.craftyGirls;

  /// See [PartC.craftyGirlsTextTheme].
  static const craftyGirlsTextTheme = PartC.craftyGirlsTextTheme;

  /// See [PartC.creepster].
  static const creepster = PartC.creepster;

  /// See [PartC.creepsterTextTheme].
  static const creepsterTextTheme = PartC.creepsterTextTheme;

  /// See [PartC.creteRound].
  static const creteRound = PartC.creteRound;

  /// See [PartC.creteRoundTextTheme].
  static const creteRoundTextTheme = PartC.creteRoundTextTheme;

  /// See [PartC.crimsonPro].
  static const crimsonPro = PartC.crimsonPro;

  /// See [PartC.crimsonProTextTheme].
  static const crimsonProTextTheme = PartC.crimsonProTextTheme;

  /// See [PartC.crimsonText].
  static const crimsonText = PartC.crimsonText;

  /// See [PartC.crimsonTextTextTheme].
  static const crimsonTextTextTheme = PartC.crimsonTextTextTheme;

  /// See [PartC.croissantOne].
  static const croissantOne = PartC.croissantOne;

  /// See [PartC.croissantOneTextTheme].
  static const croissantOneTextTheme = PartC.croissantOneTextTheme;

  /// See [PartC.crushed].
  static const crushed = PartC.crushed;

  /// See [PartC.crushedTextTheme].
  static const crushedTextTheme = PartC.crushedTextTheme;

  /// See [PartC.cuprum].
  static const cuprum = PartC.cuprum;

  /// See [PartC.cuprumTextTheme].
  static const cuprumTextTheme = PartC.cuprumTextTheme;

  /// See [PartC.cuteFont].
  static const cuteFont = PartC.cuteFont;

  /// See [PartC.cuteFontTextTheme].
  static const cuteFontTextTheme = PartC.cuteFontTextTheme;

  /// See [PartC.cutive].
  static const cutive = PartC.cutive;

  /// See [PartC.cutiveTextTheme].
  static const cutiveTextTheme = PartC.cutiveTextTheme;

  /// See [PartC.cutiveMono].
  static const cutiveMono = PartC.cutiveMono;

  /// See [PartC.cutiveMonoTextTheme].
  static const cutiveMonoTextTheme = PartC.cutiveMonoTextTheme;

  /// See [PartD.dmMono].
  static const dmMono = PartD.dmMono;

  /// See [PartD.dmMonoTextTheme].
  static const dmMonoTextTheme = PartD.dmMonoTextTheme;

  /// See [PartD.dmSans].
  static const dmSans = PartD.dmSans;

  /// See [PartD.dmSansTextTheme].
  static const dmSansTextTheme = PartD.dmSansTextTheme;

  /// See [PartD.dmSerifDisplay].
  static const dmSerifDisplay = PartD.dmSerifDisplay;

  /// See [PartD.dmSerifDisplayTextTheme].
  static const dmSerifDisplayTextTheme = PartD.dmSerifDisplayTextTheme;

  /// See [PartD.dmSerifText].
  static const dmSerifText = PartD.dmSerifText;

  /// See [PartD.dmSerifTextTextTheme].
  static const dmSerifTextTextTheme = PartD.dmSerifTextTextTheme;

  /// See [PartD.daiBannaSil].
  static const daiBannaSil = PartD.daiBannaSil;

  /// See [PartD.daiBannaSilTextTheme].
  static const daiBannaSilTextTheme = PartD.daiBannaSilTextTheme;

  /// See [PartD.damion].
  static const damion = PartD.damion;

  /// See [PartD.damionTextTheme].
  static const damionTextTheme = PartD.damionTextTheme;

  /// See [PartD.dancingScript].
  static const dancingScript = PartD.dancingScript;

  /// See [PartD.dancingScriptTextTheme].
  static const dancingScriptTextTheme = PartD.dancingScriptTextTheme;

  /// See [PartD.danfo].
  static const danfo = PartD.danfo;

  /// See [PartD.danfoTextTheme].
  static const danfoTextTheme = PartD.danfoTextTheme;

  /// See [PartD.dangrek].
  static const dangrek = PartD.dangrek;

  /// See [PartD.dangrekTextTheme].
  static const dangrekTextTheme = PartD.dangrekTextTheme;

  /// See [PartD.darkerGrotesque].
  static const darkerGrotesque = PartD.darkerGrotesque;

  /// See [PartD.darkerGrotesqueTextTheme].
  static const darkerGrotesqueTextTheme = PartD.darkerGrotesqueTextTheme;

  /// See [PartD.darumadropOne].
  static const darumadropOne = PartD.darumadropOne;

  /// See [PartD.darumadropOneTextTheme].
  static const darumadropOneTextTheme = PartD.darumadropOneTextTheme;

  /// See [PartD.davidLibre].
  static const davidLibre = PartD.davidLibre;

  /// See [PartD.davidLibreTextTheme].
  static const davidLibreTextTheme = PartD.davidLibreTextTheme;

  /// See [PartD.dawningOfANewDay].
  static const dawningOfANewDay = PartD.dawningOfANewDay;

  /// See [PartD.dawningOfANewDayTextTheme].
  static const dawningOfANewDayTextTheme = PartD.dawningOfANewDayTextTheme;

  /// See [PartD.daysOne].
  static const daysOne = PartD.daysOne;

  /// See [PartD.daysOneTextTheme].
  static const daysOneTextTheme = PartD.daysOneTextTheme;

  /// See [PartD.dekko].
  static const dekko = PartD.dekko;

  /// See [PartD.dekkoTextTheme].
  static const dekkoTextTheme = PartD.dekkoTextTheme;

  /// See [PartD.delaGothicOne].
  static const delaGothicOne = PartD.delaGothicOne;

  /// See [PartD.delaGothicOneTextTheme].
  static const delaGothicOneTextTheme = PartD.delaGothicOneTextTheme;

  /// See [PartD.deliciousHandrawn].
  static const deliciousHandrawn = PartD.deliciousHandrawn;

  /// See [PartD.deliciousHandrawnTextTheme].
  static const deliciousHandrawnTextTheme = PartD.deliciousHandrawnTextTheme;

  /// See [PartD.delius].
  static const delius = PartD.delius;

  /// See [PartD.deliusTextTheme].
  static const deliusTextTheme = PartD.deliusTextTheme;

  /// See [PartD.deliusSwashCaps].
  static const deliusSwashCaps = PartD.deliusSwashCaps;

  /// See [PartD.deliusSwashCapsTextTheme].
  static const deliusSwashCapsTextTheme = PartD.deliusSwashCapsTextTheme;

  /// See [PartD.deliusUnicase].
  static const deliusUnicase = PartD.deliusUnicase;

  /// See [PartD.deliusUnicaseTextTheme].
  static const deliusUnicaseTextTheme = PartD.deliusUnicaseTextTheme;

  /// See [PartD.dellaRespira].
  static const dellaRespira = PartD.dellaRespira;

  /// See [PartD.dellaRespiraTextTheme].
  static const dellaRespiraTextTheme = PartD.dellaRespiraTextTheme;

  /// See [PartD.denkOne].
  static const denkOne = PartD.denkOne;

  /// See [PartD.denkOneTextTheme].
  static const denkOneTextTheme = PartD.denkOneTextTheme;

  /// See [PartD.devonshire].
  static const devonshire = PartD.devonshire;

  /// See [PartD.devonshireTextTheme].
  static const devonshireTextTheme = PartD.devonshireTextTheme;

  /// See [PartD.dhurjati].
  static const dhurjati = PartD.dhurjati;

  /// See [PartD.dhurjatiTextTheme].
  static const dhurjatiTextTheme = PartD.dhurjatiTextTheme;

  /// See [PartD.didactGothic].
  static const didactGothic = PartD.didactGothic;

  /// See [PartD.didactGothicTextTheme].
  static const didactGothicTextTheme = PartD.didactGothicTextTheme;

  /// See [PartD.diphylleia].
  static const diphylleia = PartD.diphylleia;

  /// See [PartD.diphylleiaTextTheme].
  static const diphylleiaTextTheme = PartD.diphylleiaTextTheme;

  /// See [PartD.diplomata].
  static const diplomata = PartD.diplomata;

  /// See [PartD.diplomataTextTheme].
  static const diplomataTextTheme = PartD.diplomataTextTheme;

  /// See [PartD.diplomataSc].
  static const diplomataSc = PartD.diplomataSc;

  /// See [PartD.diplomataScTextTheme].
  static const diplomataScTextTheme = PartD.diplomataScTextTheme;

  /// See [PartD.doHyeon].
  static const doHyeon = PartD.doHyeon;

  /// See [PartD.doHyeonTextTheme].
  static const doHyeonTextTheme = PartD.doHyeonTextTheme;

  /// See [PartD.dokdo].
  static const dokdo = PartD.dokdo;

  /// See [PartD.dokdoTextTheme].
  static const dokdoTextTheme = PartD.dokdoTextTheme;

  /// See [PartD.domine].
  static const domine = PartD.domine;

  /// See [PartD.domineTextTheme].
  static const domineTextTheme = PartD.domineTextTheme;

  /// See [PartD.donegalOne].
  static const donegalOne = PartD.donegalOne;

  /// See [PartD.donegalOneTextTheme].
  static const donegalOneTextTheme = PartD.donegalOneTextTheme;

  /// See [PartD.dongle].
  static const dongle = PartD.dongle;

  /// See [PartD.dongleTextTheme].
  static const dongleTextTheme = PartD.dongleTextTheme;

  /// See [PartD.doppioOne].
  static const doppioOne = PartD.doppioOne;

  /// See [PartD.doppioOneTextTheme].
  static const doppioOneTextTheme = PartD.doppioOneTextTheme;

  /// See [PartD.dorsa].
  static const dorsa = PartD.dorsa;

  /// See [PartD.dorsaTextTheme].
  static const dorsaTextTheme = PartD.dorsaTextTheme;

  /// See [PartD.dosis].
  static const dosis = PartD.dosis;

  /// See [PartD.dosisTextTheme].
  static const dosisTextTheme = PartD.dosisTextTheme;

  /// See [PartD.dotGothic16].
  static const dotGothic16 = PartD.dotGothic16;

  /// See [PartD.dotGothic16TextTheme].
  static const dotGothic16TextTheme = PartD.dotGothic16TextTheme;

  /// See [PartD.doto].
  static const doto = PartD.doto;

  /// See [PartD.dotoTextTheme].
  static const dotoTextTheme = PartD.dotoTextTheme;

  /// See [PartD.drSugiyama].
  static const drSugiyama = PartD.drSugiyama;

  /// See [PartD.drSugiyamaTextTheme].
  static const drSugiyamaTextTheme = PartD.drSugiyamaTextTheme;

  /// See [PartD.duruSans].
  static const duruSans = PartD.duruSans;

  /// See [PartD.duruSansTextTheme].
  static const duruSansTextTheme = PartD.duruSansTextTheme;

  /// See [PartD.dynaPuff].
  static const dynaPuff = PartD.dynaPuff;

  /// See [PartD.dynaPuffTextTheme].
  static const dynaPuffTextTheme = PartD.dynaPuffTextTheme;

  /// See [PartD.dynalight].
  static const dynalight = PartD.dynalight;

  /// See [PartD.dynalightTextTheme].
  static const dynalightTextTheme = PartD.dynalightTextTheme;

  /// See [PartE.ebGaramond].
  static const ebGaramond = PartE.ebGaramond;

  /// See [PartE.ebGaramondTextTheme].
  static const ebGaramondTextTheme = PartE.ebGaramondTextTheme;

  /// See [PartE.eagleLake].
  static const eagleLake = PartE.eagleLake;

  /// See [PartE.eagleLakeTextTheme].
  static const eagleLakeTextTheme = PartE.eagleLakeTextTheme;

  /// See [PartE.eastSeaDokdo].
  static const eastSeaDokdo = PartE.eastSeaDokdo;

  /// See [PartE.eastSeaDokdoTextTheme].
  static const eastSeaDokdoTextTheme = PartE.eastSeaDokdoTextTheme;

  /// See [PartE.eater].
  static const eater = PartE.eater;

  /// See [PartE.eaterTextTheme].
  static const eaterTextTheme = PartE.eaterTextTheme;

  /// See [PartE.economica].
  static const economica = PartE.economica;

  /// See [PartE.economicaTextTheme].
  static const economicaTextTheme = PartE.economicaTextTheme;

  /// See [PartE.eczar].
  static const eczar = PartE.eczar;

  /// See [PartE.eczarTextTheme].
  static const eczarTextTheme = PartE.eczarTextTheme;

  /// See [PartE.eduAuVicWaNtArrows].
  static const eduAuVicWaNtArrows = PartE.eduAuVicWaNtArrows;

  /// See [PartE.eduAuVicWaNtArrowsTextTheme].
  static const eduAuVicWaNtArrowsTextTheme = PartE.eduAuVicWaNtArrowsTextTheme;

  /// See [PartE.eduAuVicWaNtDots].
  static const eduAuVicWaNtDots = PartE.eduAuVicWaNtDots;

  /// See [PartE.eduAuVicWaNtDotsTextTheme].
  static const eduAuVicWaNtDotsTextTheme = PartE.eduAuVicWaNtDotsTextTheme;

  /// See [PartE.eduAuVicWaNtGuides].
  static const eduAuVicWaNtGuides = PartE.eduAuVicWaNtGuides;

  /// See [PartE.eduAuVicWaNtGuidesTextTheme].
  static const eduAuVicWaNtGuidesTextTheme = PartE.eduAuVicWaNtGuidesTextTheme;

  /// See [PartE.eduAuVicWaNtHand].
  static const eduAuVicWaNtHand = PartE.eduAuVicWaNtHand;

  /// See [PartE.eduAuVicWaNtHandTextTheme].
  static const eduAuVicWaNtHandTextTheme = PartE.eduAuVicWaNtHandTextTheme;

  /// See [PartE.eduAuVicWaNtPre].
  static const eduAuVicWaNtPre = PartE.eduAuVicWaNtPre;

  /// See [PartE.eduAuVicWaNtPreTextTheme].
  static const eduAuVicWaNtPreTextTheme = PartE.eduAuVicWaNtPreTextTheme;

  /// See [PartE.eduNswActCursive].
  static const eduNswActCursive = PartE.eduNswActCursive;

  /// See [PartE.eduNswActCursiveTextTheme].
  static const eduNswActCursiveTextTheme = PartE.eduNswActCursiveTextTheme;

  /// See [PartE.eduNswActFoundation].
  static const eduNswActFoundation = PartE.eduNswActFoundation;

  /// See [PartE.eduNswActFoundationTextTheme].
  static const eduNswActFoundationTextTheme =
      PartE.eduNswActFoundationTextTheme;

  /// See [PartE.eduNswActHandPre].
  static const eduNswActHandPre = PartE.eduNswActHandPre;

  /// See [PartE.eduNswActHandPreTextTheme].
  static const eduNswActHandPreTextTheme = PartE.eduNswActHandPreTextTheme;

  /// See [PartE.eduQldBeginner].
  static const eduQldBeginner = PartE.eduQldBeginner;

  /// See [PartE.eduQldBeginnerTextTheme].
  static const eduQldBeginnerTextTheme = PartE.eduQldBeginnerTextTheme;

  /// See [PartE.eduQldHand].
  static const eduQldHand = PartE.eduQldHand;

  /// See [PartE.eduQldHandTextTheme].
  static const eduQldHandTextTheme = PartE.eduQldHandTextTheme;

  /// See [PartE.eduSaBeginner].
  static const eduSaBeginner = PartE.eduSaBeginner;

  /// See [PartE.eduSaBeginnerTextTheme].
  static const eduSaBeginnerTextTheme = PartE.eduSaBeginnerTextTheme;

  /// See [PartE.eduSaHand].
  static const eduSaHand = PartE.eduSaHand;

  /// See [PartE.eduSaHandTextTheme].
  static const eduSaHandTextTheme = PartE.eduSaHandTextTheme;

  /// See [PartE.eduTasBeginner].
  static const eduTasBeginner = PartE.eduTasBeginner;

  /// See [PartE.eduTasBeginnerTextTheme].
  static const eduTasBeginnerTextTheme = PartE.eduTasBeginnerTextTheme;

  /// See [PartE.eduVicWaNtBeginner].
  static const eduVicWaNtBeginner = PartE.eduVicWaNtBeginner;

  /// See [PartE.eduVicWaNtBeginnerTextTheme].
  static const eduVicWaNtBeginnerTextTheme = PartE.eduVicWaNtBeginnerTextTheme;

  /// See [PartE.eduVicWaNtHand].
  static const eduVicWaNtHand = PartE.eduVicWaNtHand;

  /// See [PartE.eduVicWaNtHandTextTheme].
  static const eduVicWaNtHandTextTheme = PartE.eduVicWaNtHandTextTheme;

  /// See [PartE.eduVicWaNtHandPre].
  static const eduVicWaNtHandPre = PartE.eduVicWaNtHandPre;

  /// See [PartE.eduVicWaNtHandPreTextTheme].
  static const eduVicWaNtHandPreTextTheme = PartE.eduVicWaNtHandPreTextTheme;

  /// See [PartE.elMessiri].
  static const elMessiri = PartE.elMessiri;

  /// See [PartE.elMessiriTextTheme].
  static const elMessiriTextTheme = PartE.elMessiriTextTheme;

  /// See [PartE.electrolize].
  static const electrolize = PartE.electrolize;

  /// See [PartE.electrolizeTextTheme].
  static const electrolizeTextTheme = PartE.electrolizeTextTheme;

  /// See [PartE.elsie].
  static const elsie = PartE.elsie;

  /// See [PartE.elsieTextTheme].
  static const elsieTextTheme = PartE.elsieTextTheme;

  /// See [PartE.elsieSwashCaps].
  static const elsieSwashCaps = PartE.elsieSwashCaps;

  /// See [PartE.elsieSwashCapsTextTheme].
  static const elsieSwashCapsTextTheme = PartE.elsieSwashCapsTextTheme;

  /// See [PartE.emblemaOne].
  static const emblemaOne = PartE.emblemaOne;

  /// See [PartE.emblemaOneTextTheme].
  static const emblemaOneTextTheme = PartE.emblemaOneTextTheme;

  /// See [PartE.emilysCandy].
  static const emilysCandy = PartE.emilysCandy;

  /// See [PartE.emilysCandyTextTheme].
  static const emilysCandyTextTheme = PartE.emilysCandyTextTheme;

  /// See [PartE.encodeSans].
  static const encodeSans = PartE.encodeSans;

  /// See [PartE.encodeSansTextTheme].
  static const encodeSansTextTheme = PartE.encodeSansTextTheme;

  /// See [PartE.encodeSansSc].
  static const encodeSansSc = PartE.encodeSansSc;

  /// See [PartE.encodeSansScTextTheme].
  static const encodeSansScTextTheme = PartE.encodeSansScTextTheme;

  /// See [PartE.engagement].
  static const engagement = PartE.engagement;

  /// See [PartE.engagementTextTheme].
  static const engagementTextTheme = PartE.engagementTextTheme;

  /// See [PartE.englebert].
  static const englebert = PartE.englebert;

  /// See [PartE.englebertTextTheme].
  static const englebertTextTheme = PartE.englebertTextTheme;

  /// See [PartE.enriqueta].
  static const enriqueta = PartE.enriqueta;

  /// See [PartE.enriquetaTextTheme].
  static const enriquetaTextTheme = PartE.enriquetaTextTheme;

  /// See [PartE.ephesis].
  static const ephesis = PartE.ephesis;

  /// See [PartE.ephesisTextTheme].
  static const ephesisTextTheme = PartE.ephesisTextTheme;

  /// See [PartE.epilogue].
  static const epilogue = PartE.epilogue;

  /// See [PartE.epilogueTextTheme].
  static const epilogueTextTheme = PartE.epilogueTextTheme;

  /// See [PartE.epundaSans].
  static const epundaSans = PartE.epundaSans;

  /// See [PartE.epundaSansTextTheme].
  static const epundaSansTextTheme = PartE.epundaSansTextTheme;

  /// See [PartE.epundaSlab].
  static const epundaSlab = PartE.epundaSlab;

  /// See [PartE.epundaSlabTextTheme].
  static const epundaSlabTextTheme = PartE.epundaSlabTextTheme;

  /// See [PartE.ericaOne].
  static const ericaOne = PartE.ericaOne;

  /// See [PartE.ericaOneTextTheme].
  static const ericaOneTextTheme = PartE.ericaOneTextTheme;

  /// See [PartE.esteban].
  static const esteban = PartE.esteban;

  /// See [PartE.estebanTextTheme].
  static const estebanTextTheme = PartE.estebanTextTheme;

  /// See [PartE.estonia].
  static const estonia = PartE.estonia;

  /// See [PartE.estoniaTextTheme].
  static const estoniaTextTheme = PartE.estoniaTextTheme;

  /// See [PartE.euphoriaScript].
  static const euphoriaScript = PartE.euphoriaScript;

  /// See [PartE.euphoriaScriptTextTheme].
  static const euphoriaScriptTextTheme = PartE.euphoriaScriptTextTheme;

  /// See [PartE.ewert].
  static const ewert = PartE.ewert;

  /// See [PartE.ewertTextTheme].
  static const ewertTextTheme = PartE.ewertTextTheme;

  /// See [PartE.exile].
  static const exile = PartE.exile;

  /// See [PartE.exileTextTheme].
  static const exileTextTheme = PartE.exileTextTheme;

  /// See [PartE.exo].
  static const exo = PartE.exo;

  /// See [PartE.exoTextTheme].
  static const exoTextTheme = PartE.exoTextTheme;

  /// See [PartE.exo2].
  static const exo2 = PartE.exo2;

  /// See [PartE.exo2TextTheme].
  static const exo2TextTheme = PartE.exo2TextTheme;

  /// See [PartE.expletusSans].
  static const expletusSans = PartE.expletusSans;

  /// See [PartE.expletusSansTextTheme].
  static const expletusSansTextTheme = PartE.expletusSansTextTheme;

  /// See [PartE.explora].
  static const explora = PartE.explora;

  /// See [PartE.exploraTextTheme].
  static const exploraTextTheme = PartE.exploraTextTheme;

  /// See [PartF.facultyGlyphic].
  static const facultyGlyphic = PartF.facultyGlyphic;

  /// See [PartF.facultyGlyphicTextTheme].
  static const facultyGlyphicTextTheme = PartF.facultyGlyphicTextTheme;

  /// See [PartF.fahkwang].
  static const fahkwang = PartF.fahkwang;

  /// See [PartF.fahkwangTextTheme].
  static const fahkwangTextTheme = PartF.fahkwangTextTheme;

  /// See [PartF.familjenGrotesk].
  static const familjenGrotesk = PartF.familjenGrotesk;

  /// See [PartF.familjenGroteskTextTheme].
  static const familjenGroteskTextTheme = PartF.familjenGroteskTextTheme;

  /// See [PartF.fanwoodText].
  static const fanwoodText = PartF.fanwoodText;

  /// See [PartF.fanwoodTextTextTheme].
  static const fanwoodTextTextTheme = PartF.fanwoodTextTextTheme;

  /// See [PartF.farro].
  static const farro = PartF.farro;

  /// See [PartF.farroTextTheme].
  static const farroTextTheme = PartF.farroTextTheme;

  /// See [PartF.farsan].
  static const farsan = PartF.farsan;

  /// See [PartF.farsanTextTheme].
  static const farsanTextTheme = PartF.farsanTextTheme;

  /// See [PartF.fascinate].
  static const fascinate = PartF.fascinate;

  /// See [PartF.fascinateTextTheme].
  static const fascinateTextTheme = PartF.fascinateTextTheme;

  /// See [PartF.fascinateInline].
  static const fascinateInline = PartF.fascinateInline;

  /// See [PartF.fascinateInlineTextTheme].
  static const fascinateInlineTextTheme = PartF.fascinateInlineTextTheme;

  /// See [PartF.fasterOne].
  static const fasterOne = PartF.fasterOne;

  /// See [PartF.fasterOneTextTheme].
  static const fasterOneTextTheme = PartF.fasterOneTextTheme;

  /// See [PartF.fasthand].
  static const fasthand = PartF.fasthand;

  /// See [PartF.fasthandTextTheme].
  static const fasthandTextTheme = PartF.fasthandTextTheme;

  /// See [PartF.faunaOne].
  static const faunaOne = PartF.faunaOne;

  /// See [PartF.faunaOneTextTheme].
  static const faunaOneTextTheme = PartF.faunaOneTextTheme;

  /// See [PartF.faustina].
  static const faustina = PartF.faustina;

  /// See [PartF.faustinaTextTheme].
  static const faustinaTextTheme = PartF.faustinaTextTheme;

  /// See [PartF.federant].
  static const federant = PartF.federant;

  /// See [PartF.federantTextTheme].
  static const federantTextTheme = PartF.federantTextTheme;

  /// See [PartF.federo].
  static const federo = PartF.federo;

  /// See [PartF.federoTextTheme].
  static const federoTextTheme = PartF.federoTextTheme;

  /// See [PartF.felipa].
  static const felipa = PartF.felipa;

  /// See [PartF.felipaTextTheme].
  static const felipaTextTheme = PartF.felipaTextTheme;

  /// See [PartF.fenix].
  static const fenix = PartF.fenix;

  /// See [PartF.fenixTextTheme].
  static const fenixTextTheme = PartF.fenixTextTheme;

  /// See [PartF.festive].
  static const festive = PartF.festive;

  /// See [PartF.festiveTextTheme].
  static const festiveTextTheme = PartF.festiveTextTheme;

  /// See [PartF.figtree].
  static const figtree = PartF.figtree;

  /// See [PartF.figtreeTextTheme].
  static const figtreeTextTheme = PartF.figtreeTextTheme;

  /// See [PartF.fingerPaint].
  static const fingerPaint = PartF.fingerPaint;

  /// See [PartF.fingerPaintTextTheme].
  static const fingerPaintTextTheme = PartF.fingerPaintTextTheme;

  /// See [PartF.finlandica].
  static const finlandica = PartF.finlandica;

  /// See [PartF.finlandicaTextTheme].
  static const finlandicaTextTheme = PartF.finlandicaTextTheme;

  /// See [PartF.firaCode].
  static const firaCode = PartF.firaCode;

  /// See [PartF.firaCodeTextTheme].
  static const firaCodeTextTheme = PartF.firaCodeTextTheme;

  /// See [PartF.firaMono].
  static const firaMono = PartF.firaMono;

  /// See [PartF.firaMonoTextTheme].
  static const firaMonoTextTheme = PartF.firaMonoTextTheme;

  /// See [PartF.firaSans].
  static const firaSans = PartF.firaSans;

  /// See [PartF.firaSansTextTheme].
  static const firaSansTextTheme = PartF.firaSansTextTheme;

  /// See [PartF.firaSansCondensed].
  static const firaSansCondensed = PartF.firaSansCondensed;

  /// See [PartF.firaSansCondensedTextTheme].
  static const firaSansCondensedTextTheme = PartF.firaSansCondensedTextTheme;

  /// See [PartF.firaSansExtraCondensed].
  static const firaSansExtraCondensed = PartF.firaSansExtraCondensed;

  /// See [PartF.firaSansExtraCondensedTextTheme].
  static const firaSansExtraCondensedTextTheme =
      PartF.firaSansExtraCondensedTextTheme;

  /// See [PartF.fjallaOne].
  static const fjallaOne = PartF.fjallaOne;

  /// See [PartF.fjallaOneTextTheme].
  static const fjallaOneTextTheme = PartF.fjallaOneTextTheme;

  /// See [PartF.fjordOne].
  static const fjordOne = PartF.fjordOne;

  /// See [PartF.fjordOneTextTheme].
  static const fjordOneTextTheme = PartF.fjordOneTextTheme;

  /// See [PartF.flamenco].
  static const flamenco = PartF.flamenco;

  /// See [PartF.flamencoTextTheme].
  static const flamencoTextTheme = PartF.flamencoTextTheme;

  /// See [PartF.flavors].
  static const flavors = PartF.flavors;

  /// See [PartF.flavorsTextTheme].
  static const flavorsTextTheme = PartF.flavorsTextTheme;

  /// See [PartF.fleurDeLeah].
  static const fleurDeLeah = PartF.fleurDeLeah;

  /// See [PartF.fleurDeLeahTextTheme].
  static const fleurDeLeahTextTheme = PartF.fleurDeLeahTextTheme;

  /// See [PartF.flowBlock].
  static const flowBlock = PartF.flowBlock;

  /// See [PartF.flowBlockTextTheme].
  static const flowBlockTextTheme = PartF.flowBlockTextTheme;

  /// See [PartF.flowCircular].
  static const flowCircular = PartF.flowCircular;

  /// See [PartF.flowCircularTextTheme].
  static const flowCircularTextTheme = PartF.flowCircularTextTheme;

  /// See [PartF.flowRounded].
  static const flowRounded = PartF.flowRounded;

  /// See [PartF.flowRoundedTextTheme].
  static const flowRoundedTextTheme = PartF.flowRoundedTextTheme;

  /// See [PartF.foldit].
  static const foldit = PartF.foldit;

  /// See [PartF.folditTextTheme].
  static const folditTextTheme = PartF.folditTextTheme;

  /// See [PartF.fondamento].
  static const fondamento = PartF.fondamento;

  /// See [PartF.fondamentoTextTheme].
  static const fondamentoTextTheme = PartF.fondamentoTextTheme;

  /// See [PartF.fontdinerSwanky].
  static const fontdinerSwanky = PartF.fontdinerSwanky;

  /// See [PartF.fontdinerSwankyTextTheme].
  static const fontdinerSwankyTextTheme = PartF.fontdinerSwankyTextTheme;

  /// See [PartF.forum].
  static const forum = PartF.forum;

  /// See [PartF.forumTextTheme].
  static const forumTextTheme = PartF.forumTextTheme;

  /// See [PartF.fragmentMono].
  static const fragmentMono = PartF.fragmentMono;

  /// See [PartF.fragmentMonoTextTheme].
  static const fragmentMonoTextTheme = PartF.fragmentMonoTextTheme;

  /// See [PartF.francoisOne].
  static const francoisOne = PartF.francoisOne;

  /// See [PartF.francoisOneTextTheme].
  static const francoisOneTextTheme = PartF.francoisOneTextTheme;

  /// See [PartF.frankRuhlLibre].
  static const frankRuhlLibre = PartF.frankRuhlLibre;

  /// See [PartF.frankRuhlLibreTextTheme].
  static const frankRuhlLibreTextTheme = PartF.frankRuhlLibreTextTheme;

  /// See [PartF.fraunces].
  static const fraunces = PartF.fraunces;

  /// See [PartF.frauncesTextTheme].
  static const frauncesTextTheme = PartF.frauncesTextTheme;

  /// See [PartF.freckleFace].
  static const freckleFace = PartF.freckleFace;

  /// See [PartF.freckleFaceTextTheme].
  static const freckleFaceTextTheme = PartF.freckleFaceTextTheme;

  /// See [PartF.frederickaTheGreat].
  static const frederickaTheGreat = PartF.frederickaTheGreat;

  /// See [PartF.frederickaTheGreatTextTheme].
  static const frederickaTheGreatTextTheme = PartF.frederickaTheGreatTextTheme;

  /// See [PartF.fredoka].
  static const fredoka = PartF.fredoka;

  /// See [PartF.fredokaTextTheme].
  static const fredokaTextTheme = PartF.fredokaTextTheme;

  /// See [PartF.freehand].
  static const freehand = PartF.freehand;

  /// See [PartF.freehandTextTheme].
  static const freehandTextTheme = PartF.freehandTextTheme;

  /// See [PartF.freeman].
  static const freeman = PartF.freeman;

  /// See [PartF.freemanTextTheme].
  static const freemanTextTheme = PartF.freemanTextTheme;

  /// See [PartF.fresca].
  static const fresca = PartF.fresca;

  /// See [PartF.frescaTextTheme].
  static const frescaTextTheme = PartF.frescaTextTheme;

  /// See [PartF.frijole].
  static const frijole = PartF.frijole;

  /// See [PartF.frijoleTextTheme].
  static const frijoleTextTheme = PartF.frijoleTextTheme;

  /// See [PartF.fruktur].
  static const fruktur = PartF.fruktur;

  /// See [PartF.frukturTextTheme].
  static const frukturTextTheme = PartF.frukturTextTheme;

  /// See [PartF.fugazOne].
  static const fugazOne = PartF.fugazOne;

  /// See [PartF.fugazOneTextTheme].
  static const fugazOneTextTheme = PartF.fugazOneTextTheme;

  /// See [PartF.fuggles].
  static const fuggles = PartF.fuggles;

  /// See [PartF.fugglesTextTheme].
  static const fugglesTextTheme = PartF.fugglesTextTheme;

  /// See [PartF.funnelDisplay].
  static const funnelDisplay = PartF.funnelDisplay;

  /// See [PartF.funnelDisplayTextTheme].
  static const funnelDisplayTextTheme = PartF.funnelDisplayTextTheme;

  /// See [PartF.funnelSans].
  static const funnelSans = PartF.funnelSans;

  /// See [PartF.funnelSansTextTheme].
  static const funnelSansTextTheme = PartF.funnelSansTextTheme;

  /// See [PartF.fustat].
  static const fustat = PartF.fustat;

  /// See [PartF.fustatTextTheme].
  static const fustatTextTheme = PartF.fustatTextTheme;

  /// See [PartF.fuzzyBubbles].
  static const fuzzyBubbles = PartF.fuzzyBubbles;

  /// See [PartF.fuzzyBubblesTextTheme].
  static const fuzzyBubblesTextTheme = PartF.fuzzyBubblesTextTheme;

  /// See [PartG.gfsDidot].
  static const gfsDidot = PartG.gfsDidot;

  /// See [PartG.gfsDidotTextTheme].
  static const gfsDidotTextTheme = PartG.gfsDidotTextTheme;

  /// See [PartG.gfsNeohellenic].
  static const gfsNeohellenic = PartG.gfsNeohellenic;

  /// See [PartG.gfsNeohellenicTextTheme].
  static const gfsNeohellenicTextTheme = PartG.gfsNeohellenicTextTheme;

  /// See [PartG.gaMaamli].
  static const gaMaamli = PartG.gaMaamli;

  /// See [PartG.gaMaamliTextTheme].
  static const gaMaamliTextTheme = PartG.gaMaamliTextTheme;

  /// See [PartG.gabarito].
  static const gabarito = PartG.gabarito;

  /// See [PartG.gabaritoTextTheme].
  static const gabaritoTextTheme = PartG.gabaritoTextTheme;

  /// See [PartG.gabriela].
  static const gabriela = PartG.gabriela;

  /// See [PartG.gabrielaTextTheme].
  static const gabrielaTextTheme = PartG.gabrielaTextTheme;

  /// See [PartG.gaegu].
  static const gaegu = PartG.gaegu;

  /// See [PartG.gaeguTextTheme].
  static const gaeguTextTheme = PartG.gaeguTextTheme;

  /// See [PartG.gafata].
  static const gafata = PartG.gafata;

  /// See [PartG.gafataTextTheme].
  static const gafataTextTheme = PartG.gafataTextTheme;

  /// See [PartG.gajrajOne].
  static const gajrajOne = PartG.gajrajOne;

  /// See [PartG.gajrajOneTextTheme].
  static const gajrajOneTextTheme = PartG.gajrajOneTextTheme;

  /// See [PartG.galada].
  static const galada = PartG.galada;

  /// See [PartG.galadaTextTheme].
  static const galadaTextTheme = PartG.galadaTextTheme;

  /// See [PartG.galdeano].
  static const galdeano = PartG.galdeano;

  /// See [PartG.galdeanoTextTheme].
  static const galdeanoTextTheme = PartG.galdeanoTextTheme;

  /// See [PartG.galindo].
  static const galindo = PartG.galindo;

  /// See [PartG.galindoTextTheme].
  static const galindoTextTheme = PartG.galindoTextTheme;

  /// See [PartG.gamjaFlower].
  static const gamjaFlower = PartG.gamjaFlower;

  /// See [PartG.gamjaFlowerTextTheme].
  static const gamjaFlowerTextTheme = PartG.gamjaFlowerTextTheme;

  /// See [PartG.gantari].
  static const gantari = PartG.gantari;

  /// See [PartG.gantariTextTheme].
  static const gantariTextTheme = PartG.gantariTextTheme;

  /// See [PartG.gasoekOne].
  static const gasoekOne = PartG.gasoekOne;

  /// See [PartG.gasoekOneTextTheme].
  static const gasoekOneTextTheme = PartG.gasoekOneTextTheme;

  /// See [PartG.gayathri].
  static const gayathri = PartG.gayathri;

  /// See [PartG.gayathriTextTheme].
  static const gayathriTextTheme = PartG.gayathriTextTheme;

  /// See [PartG.geist].
  static const geist = PartG.geist;

  /// See [PartG.geistTextTheme].
  static const geistTextTheme = PartG.geistTextTheme;

  /// See [PartG.geistMono].
  static const geistMono = PartG.geistMono;

  /// See [PartG.geistMonoTextTheme].
  static const geistMonoTextTheme = PartG.geistMonoTextTheme;

  /// See [PartG.gelasio].
  static const gelasio = PartG.gelasio;

  /// See [PartG.gelasioTextTheme].
  static const gelasioTextTheme = PartG.gelasioTextTheme;

  /// See [PartG.gemunuLibre].
  static const gemunuLibre = PartG.gemunuLibre;

  /// See [PartG.gemunuLibreTextTheme].
  static const gemunuLibreTextTheme = PartG.gemunuLibreTextTheme;

  /// See [PartG.genos].
  static const genos = PartG.genos;

  /// See [PartG.genosTextTheme].
  static const genosTextTheme = PartG.genosTextTheme;

  /// See [PartG.gentiumBookPlus].
  static const gentiumBookPlus = PartG.gentiumBookPlus;

  /// See [PartG.gentiumBookPlusTextTheme].
  static const gentiumBookPlusTextTheme = PartG.gentiumBookPlusTextTheme;

  /// See [PartG.gentiumPlus].
  static const gentiumPlus = PartG.gentiumPlus;

  /// See [PartG.gentiumPlusTextTheme].
  static const gentiumPlusTextTheme = PartG.gentiumPlusTextTheme;

  /// See [PartG.geo].
  static const geo = PartG.geo;

  /// See [PartG.geoTextTheme].
  static const geoTextTheme = PartG.geoTextTheme;

  /// See [PartG.geologica].
  static const geologica = PartG.geologica;

  /// See [PartG.geologicaTextTheme].
  static const geologicaTextTheme = PartG.geologicaTextTheme;

  /// See [PartG.georama].
  static const georama = PartG.georama;

  /// See [PartG.georamaTextTheme].
  static const georamaTextTheme = PartG.georamaTextTheme;

  /// See [PartG.geostar].
  static const geostar = PartG.geostar;

  /// See [PartG.geostarTextTheme].
  static const geostarTextTheme = PartG.geostarTextTheme;

  /// See [PartG.geostarFill].
  static const geostarFill = PartG.geostarFill;

  /// See [PartG.geostarFillTextTheme].
  static const geostarFillTextTheme = PartG.geostarFillTextTheme;

  /// See [PartG.germaniaOne].
  static const germaniaOne = PartG.germaniaOne;

  /// See [PartG.germaniaOneTextTheme].
  static const germaniaOneTextTheme = PartG.germaniaOneTextTheme;

  /// See [PartG.gideonRoman].
  static const gideonRoman = PartG.gideonRoman;

  /// See [PartG.gideonRomanTextTheme].
  static const gideonRomanTextTheme = PartG.gideonRomanTextTheme;

  /// See [PartG.gidole].
  static const gidole = PartG.gidole;

  /// See [PartG.gidoleTextTheme].
  static const gidoleTextTheme = PartG.gidoleTextTheme;

  /// See [PartG.gidugu].
  static const gidugu = PartG.gidugu;

  /// See [PartG.giduguTextTheme].
  static const giduguTextTheme = PartG.giduguTextTheme;

  /// See [PartG.gildaDisplay].
  static const gildaDisplay = PartG.gildaDisplay;

  /// See [PartG.gildaDisplayTextTheme].
  static const gildaDisplayTextTheme = PartG.gildaDisplayTextTheme;

  /// See [PartG.girassol].
  static const girassol = PartG.girassol;

  /// See [PartG.girassolTextTheme].
  static const girassolTextTheme = PartG.girassolTextTheme;

  /// See [PartG.giveYouGlory].
  static const giveYouGlory = PartG.giveYouGlory;

  /// See [PartG.giveYouGloryTextTheme].
  static const giveYouGloryTextTheme = PartG.giveYouGloryTextTheme;

  /// See [PartG.glassAntiqua].
  static const glassAntiqua = PartG.glassAntiqua;

  /// See [PartG.glassAntiquaTextTheme].
  static const glassAntiquaTextTheme = PartG.glassAntiquaTextTheme;

  /// See [PartG.glegoo].
  static const glegoo = PartG.glegoo;

  /// See [PartG.glegooTextTheme].
  static const glegooTextTheme = PartG.glegooTextTheme;

  /// See [PartG.gloock].
  static const gloock = PartG.gloock;

  /// See [PartG.gloockTextTheme].
  static const gloockTextTheme = PartG.gloockTextTheme;

  /// See [PartG.gloriaHallelujah].
  static const gloriaHallelujah = PartG.gloriaHallelujah;

  /// See [PartG.gloriaHallelujahTextTheme].
  static const gloriaHallelujahTextTheme = PartG.gloriaHallelujahTextTheme;

  /// See [PartG.glory].
  static const glory = PartG.glory;

  /// See [PartG.gloryTextTheme].
  static const gloryTextTheme = PartG.gloryTextTheme;

  /// See [PartG.gluten].
  static const gluten = PartG.gluten;

  /// See [PartG.glutenTextTheme].
  static const glutenTextTheme = PartG.glutenTextTheme;

  /// See [PartG.goblinOne].
  static const goblinOne = PartG.goblinOne;

  /// See [PartG.goblinOneTextTheme].
  static const goblinOneTextTheme = PartG.goblinOneTextTheme;

  /// See [PartG.gochiHand].
  static const gochiHand = PartG.gochiHand;

  /// See [PartG.gochiHandTextTheme].
  static const gochiHandTextTheme = PartG.gochiHandTextTheme;

  /// See [PartG.goldman].
  static const goldman = PartG.goldman;

  /// See [PartG.goldmanTextTheme].
  static const goldmanTextTheme = PartG.goldmanTextTheme;

  /// See [PartG.golosText].
  static const golosText = PartG.golosText;

  /// See [PartG.golosTextTextTheme].
  static const golosTextTextTheme = PartG.golosTextTextTheme;

  /// See [PartG.googleSansCode].
  static const googleSansCode = PartG.googleSansCode;

  /// See [PartG.googleSansCodeTextTheme].
  static const googleSansCodeTextTheme = PartG.googleSansCodeTextTheme;

  /// See [PartG.gorditas].
  static const gorditas = PartG.gorditas;

  /// See [PartG.gorditasTextTheme].
  static const gorditasTextTheme = PartG.gorditasTextTheme;

  /// See [PartG.gothicA1].
  static const gothicA1 = PartG.gothicA1;

  /// See [PartG.gothicA1TextTheme].
  static const gothicA1TextTheme = PartG.gothicA1TextTheme;

  /// See [PartG.gotu].
  static const gotu = PartG.gotu;

  /// See [PartG.gotuTextTheme].
  static const gotuTextTheme = PartG.gotuTextTheme;

  /// See [PartG.goudyBookletter1911].
  static const goudyBookletter1911 = PartG.goudyBookletter1911;

  /// See [PartG.goudyBookletter1911TextTheme].
  static const goudyBookletter1911TextTheme =
      PartG.goudyBookletter1911TextTheme;

  /// See [PartG.gowunBatang].
  static const gowunBatang = PartG.gowunBatang;

  /// See [PartG.gowunBatangTextTheme].
  static const gowunBatangTextTheme = PartG.gowunBatangTextTheme;

  /// See [PartG.gowunDodum].
  static const gowunDodum = PartG.gowunDodum;

  /// See [PartG.gowunDodumTextTheme].
  static const gowunDodumTextTheme = PartG.gowunDodumTextTheme;

  /// See [PartG.graduate].
  static const graduate = PartG.graduate;

  /// See [PartG.graduateTextTheme].
  static const graduateTextTheme = PartG.graduateTextTheme;

  /// See [PartG.grandHotel].
  static const grandHotel = PartG.grandHotel;

  /// See [PartG.grandHotelTextTheme].
  static const grandHotelTextTheme = PartG.grandHotelTextTheme;

  /// See [PartG.grandifloraOne].
  static const grandifloraOne = PartG.grandifloraOne;

  /// See [PartG.grandifloraOneTextTheme].
  static const grandifloraOneTextTheme = PartG.grandifloraOneTextTheme;

  /// See [PartG.grandstander].
  static const grandstander = PartG.grandstander;

  /// See [PartG.grandstanderTextTheme].
  static const grandstanderTextTheme = PartG.grandstanderTextTheme;

  /// See [PartG.grapeNuts].
  static const grapeNuts = PartG.grapeNuts;

  /// See [PartG.grapeNutsTextTheme].
  static const grapeNutsTextTheme = PartG.grapeNutsTextTheme;

  /// See [PartG.gravitasOne].
  static const gravitasOne = PartG.gravitasOne;

  /// See [PartG.gravitasOneTextTheme].
  static const gravitasOneTextTheme = PartG.gravitasOneTextTheme;

  /// See [PartG.greatVibes].
  static const greatVibes = PartG.greatVibes;

  /// See [PartG.greatVibesTextTheme].
  static const greatVibesTextTheme = PartG.greatVibesTextTheme;

  /// See [PartG.grechenFuemen].
  static const grechenFuemen = PartG.grechenFuemen;

  /// See [PartG.grechenFuemenTextTheme].
  static const grechenFuemenTextTheme = PartG.grechenFuemenTextTheme;

  /// See [PartG.grenze].
  static const grenze = PartG.grenze;

  /// See [PartG.grenzeTextTheme].
  static const grenzeTextTheme = PartG.grenzeTextTheme;

  /// See [PartG.grenzeGotisch].
  static const grenzeGotisch = PartG.grenzeGotisch;

  /// See [PartG.grenzeGotischTextTheme].
  static const grenzeGotischTextTheme = PartG.grenzeGotischTextTheme;

  /// See [PartG.greyQo].
  static const greyQo = PartG.greyQo;

  /// See [PartG.greyQoTextTheme].
  static const greyQoTextTheme = PartG.greyQoTextTheme;

  /// See [PartG.griffy].
  static const griffy = PartG.griffy;

  /// See [PartG.griffyTextTheme].
  static const griffyTextTheme = PartG.griffyTextTheme;

  /// See [PartG.gruppo].
  static const gruppo = PartG.gruppo;

  /// See [PartG.gruppoTextTheme].
  static const gruppoTextTheme = PartG.gruppoTextTheme;

  /// See [PartG.gudea].
  static const gudea = PartG.gudea;

  /// See [PartG.gudeaTextTheme].
  static const gudeaTextTheme = PartG.gudeaTextTheme;

  /// See [PartG.gugi].
  static const gugi = PartG.gugi;

  /// See [PartG.gugiTextTheme].
  static const gugiTextTheme = PartG.gugiTextTheme;

  /// See [PartG.gulzar].
  static const gulzar = PartG.gulzar;

  /// See [PartG.gulzarTextTheme].
  static const gulzarTextTheme = PartG.gulzarTextTheme;

  /// See [PartG.gupter].
  static const gupter = PartG.gupter;

  /// See [PartG.gupterTextTheme].
  static const gupterTextTheme = PartG.gupterTextTheme;

  /// See [PartG.gurajada].
  static const gurajada = PartG.gurajada;

  /// See [PartG.gurajadaTextTheme].
  static const gurajadaTextTheme = PartG.gurajadaTextTheme;

  /// See [PartG.gwendolyn].
  static const gwendolyn = PartG.gwendolyn;

  /// See [PartG.gwendolynTextTheme].
  static const gwendolynTextTheme = PartG.gwendolynTextTheme;

  /// See [PartH.habibi].
  static const habibi = PartH.habibi;

  /// See [PartH.habibiTextTheme].
  static const habibiTextTheme = PartH.habibiTextTheme;

  /// See [PartH.hachiMaruPop].
  static const hachiMaruPop = PartH.hachiMaruPop;

  /// See [PartH.hachiMaruPopTextTheme].
  static const hachiMaruPopTextTheme = PartH.hachiMaruPopTextTheme;

  /// See [PartH.hahmlet].
  static const hahmlet = PartH.hahmlet;

  /// See [PartH.hahmletTextTheme].
  static const hahmletTextTheme = PartH.hahmletTextTheme;

  /// See [PartH.halant].
  static const halant = PartH.halant;

  /// See [PartH.halantTextTheme].
  static const halantTextTheme = PartH.halantTextTheme;

  /// See [PartH.hammersmithOne].
  static const hammersmithOne = PartH.hammersmithOne;

  /// See [PartH.hammersmithOneTextTheme].
  static const hammersmithOneTextTheme = PartH.hammersmithOneTextTheme;

  /// See [PartH.hanalei].
  static const hanalei = PartH.hanalei;

  /// See [PartH.hanaleiTextTheme].
  static const hanaleiTextTheme = PartH.hanaleiTextTheme;

  /// See [PartH.hanaleiFill].
  static const hanaleiFill = PartH.hanaleiFill;

  /// See [PartH.hanaleiFillTextTheme].
  static const hanaleiFillTextTheme = PartH.hanaleiFillTextTheme;

  /// See [PartH.handjet].
  static const handjet = PartH.handjet;

  /// See [PartH.handjetTextTheme].
  static const handjetTextTheme = PartH.handjetTextTheme;

  /// See [PartH.handlee].
  static const handlee = PartH.handlee;

  /// See [PartH.handleeTextTheme].
  static const handleeTextTheme = PartH.handleeTextTheme;

  /// See [PartH.hankenGrotesk].
  static const hankenGrotesk = PartH.hankenGrotesk;

  /// See [PartH.hankenGroteskTextTheme].
  static const hankenGroteskTextTheme = PartH.hankenGroteskTextTheme;

  /// See [PartH.hanuman].
  static const hanuman = PartH.hanuman;

  /// See [PartH.hanumanTextTheme].
  static const hanumanTextTheme = PartH.hanumanTextTheme;

  /// See [PartH.happyMonkey].
  static const happyMonkey = PartH.happyMonkey;

  /// See [PartH.happyMonkeyTextTheme].
  static const happyMonkeyTextTheme = PartH.happyMonkeyTextTheme;

  /// See [PartH.harmattan].
  static const harmattan = PartH.harmattan;

  /// See [PartH.harmattanTextTheme].
  static const harmattanTextTheme = PartH.harmattanTextTheme;

  /// See [PartH.headlandOne].
  static const headlandOne = PartH.headlandOne;

  /// See [PartH.headlandOneTextTheme].
  static const headlandOneTextTheme = PartH.headlandOneTextTheme;

  /// See [PartH.hedvigLettersSans].
  static const hedvigLettersSans = PartH.hedvigLettersSans;

  /// See [PartH.hedvigLettersSansTextTheme].
  static const hedvigLettersSansTextTheme = PartH.hedvigLettersSansTextTheme;

  /// See [PartH.hedvigLettersSerif].
  static const hedvigLettersSerif = PartH.hedvigLettersSerif;

  /// See [PartH.hedvigLettersSerifTextTheme].
  static const hedvigLettersSerifTextTheme = PartH.hedvigLettersSerifTextTheme;

  /// See [PartH.heebo].
  static const heebo = PartH.heebo;

  /// See [PartH.heeboTextTheme].
  static const heeboTextTheme = PartH.heeboTextTheme;

  /// See [PartH.hennyPenny].
  static const hennyPenny = PartH.hennyPenny;

  /// See [PartH.hennyPennyTextTheme].
  static const hennyPennyTextTheme = PartH.hennyPennyTextTheme;

  /// See [PartH.heptaSlab].
  static const heptaSlab = PartH.heptaSlab;

  /// See [PartH.heptaSlabTextTheme].
  static const heptaSlabTextTheme = PartH.heptaSlabTextTheme;

  /// See [PartH.herrVonMuellerhoff].
  static const herrVonMuellerhoff = PartH.herrVonMuellerhoff;

  /// See [PartH.herrVonMuellerhoffTextTheme].
  static const herrVonMuellerhoffTextTheme = PartH.herrVonMuellerhoffTextTheme;

  /// See [PartH.hiMelody].
  static const hiMelody = PartH.hiMelody;

  /// See [PartH.hiMelodyTextTheme].
  static const hiMelodyTextTheme = PartH.hiMelodyTextTheme;

  /// See [PartH.hinaMincho].
  static const hinaMincho = PartH.hinaMincho;

  /// See [PartH.hinaMinchoTextTheme].
  static const hinaMinchoTextTheme = PartH.hinaMinchoTextTheme;

  /// See [PartH.hind].
  static const hind = PartH.hind;

  /// See [PartH.hindTextTheme].
  static const hindTextTheme = PartH.hindTextTheme;

  /// See [PartH.hindGuntur].
  static const hindGuntur = PartH.hindGuntur;

  /// See [PartH.hindGunturTextTheme].
  static const hindGunturTextTheme = PartH.hindGunturTextTheme;

  /// See [PartH.hindMadurai].
  static const hindMadurai = PartH.hindMadurai;

  /// See [PartH.hindMaduraiTextTheme].
  static const hindMaduraiTextTheme = PartH.hindMaduraiTextTheme;

  /// See [PartH.hindMysuru].
  static const hindMysuru = PartH.hindMysuru;

  /// See [PartH.hindMysuruTextTheme].
  static const hindMysuruTextTheme = PartH.hindMysuruTextTheme;

  /// See [PartH.hindSiliguri].
  static const hindSiliguri = PartH.hindSiliguri;

  /// See [PartH.hindSiliguriTextTheme].
  static const hindSiliguriTextTheme = PartH.hindSiliguriTextTheme;

  /// See [PartH.hindVadodara].
  static const hindVadodara = PartH.hindVadodara;

  /// See [PartH.hindVadodaraTextTheme].
  static const hindVadodaraTextTheme = PartH.hindVadodaraTextTheme;

  /// See [PartH.holtwoodOneSc].
  static const holtwoodOneSc = PartH.holtwoodOneSc;

  /// See [PartH.holtwoodOneScTextTheme].
  static const holtwoodOneScTextTheme = PartH.holtwoodOneScTextTheme;

  /// See [PartH.homemadeApple].
  static const homemadeApple = PartH.homemadeApple;

  /// See [PartH.homemadeAppleTextTheme].
  static const homemadeAppleTextTheme = PartH.homemadeAppleTextTheme;

  /// See [PartH.homenaje].
  static const homenaje = PartH.homenaje;

  /// See [PartH.homenajeTextTheme].
  static const homenajeTextTheme = PartH.homenajeTextTheme;

  /// See [PartH.honk].
  static const honk = PartH.honk;

  /// See [PartH.honkTextTheme].
  static const honkTextTheme = PartH.honkTextTheme;

  /// See [PartH.hostGrotesk].
  static const hostGrotesk = PartH.hostGrotesk;

  /// See [PartH.hostGroteskTextTheme].
  static const hostGroteskTextTheme = PartH.hostGroteskTextTheme;

  /// See [PartH.hubballi].
  static const hubballi = PartH.hubballi;

  /// See [PartH.hubballiTextTheme].
  static const hubballiTextTheme = PartH.hubballiTextTheme;

  /// See [PartH.hubotSans].
  static const hubotSans = PartH.hubotSans;

  /// See [PartH.hubotSansTextTheme].
  static const hubotSansTextTheme = PartH.hubotSansTextTheme;

  /// See [PartH.huninn].
  static const huninn = PartH.huninn;

  /// See [PartH.huninnTextTheme].
  static const huninnTextTheme = PartH.huninnTextTheme;

  /// See [PartH.hurricane].
  static const hurricane = PartH.hurricane;

  /// See [PartH.hurricaneTextTheme].
  static const hurricaneTextTheme = PartH.hurricaneTextTheme;

  /// See [PartI.ibmPlexMono].
  static const ibmPlexMono = PartI.ibmPlexMono;

  /// See [PartI.ibmPlexMonoTextTheme].
  static const ibmPlexMonoTextTheme = PartI.ibmPlexMonoTextTheme;

  /// See [PartI.ibmPlexSans].
  static const ibmPlexSans = PartI.ibmPlexSans;

  /// See [PartI.ibmPlexSansTextTheme].
  static const ibmPlexSansTextTheme = PartI.ibmPlexSansTextTheme;

  /// See [PartI.ibmPlexSansArabic].
  static const ibmPlexSansArabic = PartI.ibmPlexSansArabic;

  /// See [PartI.ibmPlexSansArabicTextTheme].
  static const ibmPlexSansArabicTextTheme = PartI.ibmPlexSansArabicTextTheme;

  /// See [PartI.ibmPlexSansDevanagari].
  static const ibmPlexSansDevanagari = PartI.ibmPlexSansDevanagari;

  /// See [PartI.ibmPlexSansDevanagariTextTheme].
  static const ibmPlexSansDevanagariTextTheme =
      PartI.ibmPlexSansDevanagariTextTheme;

  /// See [PartI.ibmPlexSansHebrew].
  static const ibmPlexSansHebrew = PartI.ibmPlexSansHebrew;

  /// See [PartI.ibmPlexSansHebrewTextTheme].
  static const ibmPlexSansHebrewTextTheme = PartI.ibmPlexSansHebrewTextTheme;

  /// See [PartI.ibmPlexSansJp].
  static const ibmPlexSansJp = PartI.ibmPlexSansJp;

  /// See [PartI.ibmPlexSansJpTextTheme].
  static const ibmPlexSansJpTextTheme = PartI.ibmPlexSansJpTextTheme;

  /// See [PartI.ibmPlexSansKr].
  static const ibmPlexSansKr = PartI.ibmPlexSansKr;

  /// See [PartI.ibmPlexSansKrTextTheme].
  static const ibmPlexSansKrTextTheme = PartI.ibmPlexSansKrTextTheme;

  /// See [PartI.ibmPlexSansThai].
  static const ibmPlexSansThai = PartI.ibmPlexSansThai;

  /// See [PartI.ibmPlexSansThaiTextTheme].
  static const ibmPlexSansThaiTextTheme = PartI.ibmPlexSansThaiTextTheme;

  /// See [PartI.ibmPlexSansThaiLooped].
  static const ibmPlexSansThaiLooped = PartI.ibmPlexSansThaiLooped;

  /// See [PartI.ibmPlexSansThaiLoopedTextTheme].
  static const ibmPlexSansThaiLoopedTextTheme =
      PartI.ibmPlexSansThaiLoopedTextTheme;

  /// See [PartI.ibmPlexSerif].
  static const ibmPlexSerif = PartI.ibmPlexSerif;

  /// See [PartI.ibmPlexSerifTextTheme].
  static const ibmPlexSerifTextTheme = PartI.ibmPlexSerifTextTheme;

  /// See [PartI.imFellDwPica].
  static const imFellDwPica = PartI.imFellDwPica;

  /// See [PartI.imFellDwPicaTextTheme].
  static const imFellDwPicaTextTheme = PartI.imFellDwPicaTextTheme;

  /// See [PartI.imFellDwPicaSc].
  static const imFellDwPicaSc = PartI.imFellDwPicaSc;

  /// See [PartI.imFellDwPicaScTextTheme].
  static const imFellDwPicaScTextTheme = PartI.imFellDwPicaScTextTheme;

  /// See [PartI.imFellDoublePica].
  static const imFellDoublePica = PartI.imFellDoublePica;

  /// See [PartI.imFellDoublePicaTextTheme].
  static const imFellDoublePicaTextTheme = PartI.imFellDoublePicaTextTheme;

  /// See [PartI.imFellDoublePicaSc].
  static const imFellDoublePicaSc = PartI.imFellDoublePicaSc;

  /// See [PartI.imFellDoublePicaScTextTheme].
  static const imFellDoublePicaScTextTheme = PartI.imFellDoublePicaScTextTheme;

  /// See [PartI.imFellEnglish].
  static const imFellEnglish = PartI.imFellEnglish;

  /// See [PartI.imFellEnglishTextTheme].
  static const imFellEnglishTextTheme = PartI.imFellEnglishTextTheme;

  /// See [PartI.imFellEnglishSc].
  static const imFellEnglishSc = PartI.imFellEnglishSc;

  /// See [PartI.imFellEnglishScTextTheme].
  static const imFellEnglishScTextTheme = PartI.imFellEnglishScTextTheme;

  /// See [PartI.imFellFrenchCanon].
  static const imFellFrenchCanon = PartI.imFellFrenchCanon;

  /// See [PartI.imFellFrenchCanonTextTheme].
  static const imFellFrenchCanonTextTheme = PartI.imFellFrenchCanonTextTheme;

  /// See [PartI.imFellFrenchCanonSc].
  static const imFellFrenchCanonSc = PartI.imFellFrenchCanonSc;

  /// See [PartI.imFellFrenchCanonScTextTheme].
  static const imFellFrenchCanonScTextTheme =
      PartI.imFellFrenchCanonScTextTheme;

  /// See [PartI.imFellGreatPrimer].
  static const imFellGreatPrimer = PartI.imFellGreatPrimer;

  /// See [PartI.imFellGreatPrimerTextTheme].
  static const imFellGreatPrimerTextTheme = PartI.imFellGreatPrimerTextTheme;

  /// See [PartI.imFellGreatPrimerSc].
  static const imFellGreatPrimerSc = PartI.imFellGreatPrimerSc;

  /// See [PartI.imFellGreatPrimerScTextTheme].
  static const imFellGreatPrimerScTextTheme =
      PartI.imFellGreatPrimerScTextTheme;

  /// See [PartI.iansui].
  static const iansui = PartI.iansui;

  /// See [PartI.iansuiTextTheme].
  static const iansuiTextTheme = PartI.iansuiTextTheme;

  /// See [PartI.ibarraRealNova].
  static const ibarraRealNova = PartI.ibarraRealNova;

  /// See [PartI.ibarraRealNovaTextTheme].
  static const ibarraRealNovaTextTheme = PartI.ibarraRealNovaTextTheme;

  /// See [PartI.iceberg].
  static const iceberg = PartI.iceberg;

  /// See [PartI.icebergTextTheme].
  static const icebergTextTheme = PartI.icebergTextTheme;

  /// See [PartI.iceland].
  static const iceland = PartI.iceland;

  /// See [PartI.icelandTextTheme].
  static const icelandTextTheme = PartI.icelandTextTheme;

  /// See [PartI.imbue].
  static const imbue = PartI.imbue;

  /// See [PartI.imbueTextTheme].
  static const imbueTextTheme = PartI.imbueTextTheme;

  /// See [PartI.imperialScript].
  static const imperialScript = PartI.imperialScript;

  /// See [PartI.imperialScriptTextTheme].
  static const imperialScriptTextTheme = PartI.imperialScriptTextTheme;

  /// See [PartI.imprima].
  static const imprima = PartI.imprima;

  /// See [PartI.imprimaTextTheme].
  static const imprimaTextTheme = PartI.imprimaTextTheme;

  /// See [PartI.inclusiveSans].
  static const inclusiveSans = PartI.inclusiveSans;

  /// See [PartI.inclusiveSansTextTheme].
  static const inclusiveSansTextTheme = PartI.inclusiveSansTextTheme;

  /// See [PartI.inconsolata].
  static const inconsolata = PartI.inconsolata;

  /// See [PartI.inconsolataTextTheme].
  static const inconsolataTextTheme = PartI.inconsolataTextTheme;

  /// See [PartI.inder].
  static const inder = PartI.inder;

  /// See [PartI.inderTextTheme].
  static const inderTextTheme = PartI.inderTextTheme;

  /// See [PartI.indieFlower].
  static const indieFlower = PartI.indieFlower;

  /// See [PartI.indieFlowerTextTheme].
  static const indieFlowerTextTheme = PartI.indieFlowerTextTheme;

  /// See [PartI.ingridDarling].
  static const ingridDarling = PartI.ingridDarling;

  /// See [PartI.ingridDarlingTextTheme].
  static const ingridDarlingTextTheme = PartI.ingridDarlingTextTheme;

  /// See [PartI.inika].
  static const inika = PartI.inika;

  /// See [PartI.inikaTextTheme].
  static const inikaTextTheme = PartI.inikaTextTheme;

  /// See [PartI.inknutAntiqua].
  static const inknutAntiqua = PartI.inknutAntiqua;

  /// See [PartI.inknutAntiquaTextTheme].
  static const inknutAntiquaTextTheme = PartI.inknutAntiquaTextTheme;

  /// See [PartI.inriaSans].
  static const inriaSans = PartI.inriaSans;

  /// See [PartI.inriaSansTextTheme].
  static const inriaSansTextTheme = PartI.inriaSansTextTheme;

  /// See [PartI.inriaSerif].
  static const inriaSerif = PartI.inriaSerif;

  /// See [PartI.inriaSerifTextTheme].
  static const inriaSerifTextTheme = PartI.inriaSerifTextTheme;

  /// See [PartI.inspiration].
  static const inspiration = PartI.inspiration;

  /// See [PartI.inspirationTextTheme].
  static const inspirationTextTheme = PartI.inspirationTextTheme;

  /// See [PartI.instrumentSans].
  static const instrumentSans = PartI.instrumentSans;

  /// See [PartI.instrumentSansTextTheme].
  static const instrumentSansTextTheme = PartI.instrumentSansTextTheme;

  /// See [PartI.instrumentSerif].
  static const instrumentSerif = PartI.instrumentSerif;

  /// See [PartI.instrumentSerifTextTheme].
  static const instrumentSerifTextTheme = PartI.instrumentSerifTextTheme;

  /// See [PartI.intelOneMono].
  static const intelOneMono = PartI.intelOneMono;

  /// See [PartI.intelOneMonoTextTheme].
  static const intelOneMonoTextTheme = PartI.intelOneMonoTextTheme;

  /// See [PartI.inter].
  static const inter = PartI.inter;

  /// See [PartI.interTextTheme].
  static const interTextTheme = PartI.interTextTheme;

  /// See [PartI.interTight].
  static const interTight = PartI.interTight;

  /// See [PartI.interTightTextTheme].
  static const interTightTextTheme = PartI.interTightTextTheme;

  /// See [PartI.irishGrover].
  static const irishGrover = PartI.irishGrover;

  /// See [PartI.irishGroverTextTheme].
  static const irishGroverTextTheme = PartI.irishGroverTextTheme;

  /// See [PartI.islandMoments].
  static const islandMoments = PartI.islandMoments;

  /// See [PartI.islandMomentsTextTheme].
  static const islandMomentsTextTheme = PartI.islandMomentsTextTheme;

  /// See [PartI.istokWeb].
  static const istokWeb = PartI.istokWeb;

  /// See [PartI.istokWebTextTheme].
  static const istokWebTextTheme = PartI.istokWebTextTheme;

  /// See [PartI.italiana].
  static const italiana = PartI.italiana;

  /// See [PartI.italianaTextTheme].
  static const italianaTextTheme = PartI.italianaTextTheme;

  /// See [PartI.italianno].
  static const italianno = PartI.italianno;

  /// See [PartI.italiannoTextTheme].
  static const italiannoTextTheme = PartI.italiannoTextTheme;

  /// See [PartI.itim].
  static const itim = PartI.itim;

  /// See [PartI.itimTextTheme].
  static const itimTextTheme = PartI.itimTextTheme;

  /// See [PartJ.jacquard12].
  static const jacquard12 = PartJ.jacquard12;

  /// See [PartJ.jacquard12TextTheme].
  static const jacquard12TextTheme = PartJ.jacquard12TextTheme;

  /// See [PartJ.jacquard12Charted].
  static const jacquard12Charted = PartJ.jacquard12Charted;

  /// See [PartJ.jacquard12ChartedTextTheme].
  static const jacquard12ChartedTextTheme = PartJ.jacquard12ChartedTextTheme;

  /// See [PartJ.jacquard24].
  static const jacquard24 = PartJ.jacquard24;

  /// See [PartJ.jacquard24TextTheme].
  static const jacquard24TextTheme = PartJ.jacquard24TextTheme;

  /// See [PartJ.jacquard24Charted].
  static const jacquard24Charted = PartJ.jacquard24Charted;

  /// See [PartJ.jacquard24ChartedTextTheme].
  static const jacquard24ChartedTextTheme = PartJ.jacquard24ChartedTextTheme;

  /// See [PartJ.jacquardaBastarda9].
  static const jacquardaBastarda9 = PartJ.jacquardaBastarda9;

  /// See [PartJ.jacquardaBastarda9TextTheme].
  static const jacquardaBastarda9TextTheme = PartJ.jacquardaBastarda9TextTheme;

  /// See [PartJ.jacquardaBastarda9Charted].
  static const jacquardaBastarda9Charted = PartJ.jacquardaBastarda9Charted;

  /// See [PartJ.jacquardaBastarda9ChartedTextTheme].
  static const jacquardaBastarda9ChartedTextTheme =
      PartJ.jacquardaBastarda9ChartedTextTheme;

  /// See [PartJ.jacquesFrancois].
  static const jacquesFrancois = PartJ.jacquesFrancois;

  /// See [PartJ.jacquesFrancoisTextTheme].
  static const jacquesFrancoisTextTheme = PartJ.jacquesFrancoisTextTheme;

  /// See [PartJ.jacquesFrancoisShadow].
  static const jacquesFrancoisShadow = PartJ.jacquesFrancoisShadow;

  /// See [PartJ.jacquesFrancoisShadowTextTheme].
  static const jacquesFrancoisShadowTextTheme =
      PartJ.jacquesFrancoisShadowTextTheme;

  /// See [PartJ.jaini].
  static const jaini = PartJ.jaini;

  /// See [PartJ.jainiTextTheme].
  static const jainiTextTheme = PartJ.jainiTextTheme;

  /// See [PartJ.jainiPurva].
  static const jainiPurva = PartJ.jainiPurva;

  /// See [PartJ.jainiPurvaTextTheme].
  static const jainiPurvaTextTheme = PartJ.jainiPurvaTextTheme;

  /// See [PartJ.jaldi].
  static const jaldi = PartJ.jaldi;

  /// See [PartJ.jaldiTextTheme].
  static const jaldiTextTheme = PartJ.jaldiTextTheme;

  /// See [PartJ.jaro].
  static const jaro = PartJ.jaro;

  /// See [PartJ.jaroTextTheme].
  static const jaroTextTheme = PartJ.jaroTextTheme;

  /// See [PartJ.jersey10].
  static const jersey10 = PartJ.jersey10;

  /// See [PartJ.jersey10TextTheme].
  static const jersey10TextTheme = PartJ.jersey10TextTheme;

  /// See [PartJ.jersey10Charted].
  static const jersey10Charted = PartJ.jersey10Charted;

  /// See [PartJ.jersey10ChartedTextTheme].
  static const jersey10ChartedTextTheme = PartJ.jersey10ChartedTextTheme;

  /// See [PartJ.jersey15].
  static const jersey15 = PartJ.jersey15;

  /// See [PartJ.jersey15TextTheme].
  static const jersey15TextTheme = PartJ.jersey15TextTheme;

  /// See [PartJ.jersey15Charted].
  static const jersey15Charted = PartJ.jersey15Charted;

  /// See [PartJ.jersey15ChartedTextTheme].
  static const jersey15ChartedTextTheme = PartJ.jersey15ChartedTextTheme;

  /// See [PartJ.jersey20].
  static const jersey20 = PartJ.jersey20;

  /// See [PartJ.jersey20TextTheme].
  static const jersey20TextTheme = PartJ.jersey20TextTheme;

  /// See [PartJ.jersey20Charted].
  static const jersey20Charted = PartJ.jersey20Charted;

  /// See [PartJ.jersey20ChartedTextTheme].
  static const jersey20ChartedTextTheme = PartJ.jersey20ChartedTextTheme;

  /// See [PartJ.jersey25].
  static const jersey25 = PartJ.jersey25;

  /// See [PartJ.jersey25TextTheme].
  static const jersey25TextTheme = PartJ.jersey25TextTheme;

  /// See [PartJ.jersey25Charted].
  static const jersey25Charted = PartJ.jersey25Charted;

  /// See [PartJ.jersey25ChartedTextTheme].
  static const jersey25ChartedTextTheme = PartJ.jersey25ChartedTextTheme;

  /// See [PartJ.jetBrainsMono].
  static const jetBrainsMono = PartJ.jetBrainsMono;

  /// See [PartJ.jetBrainsMonoTextTheme].
  static const jetBrainsMonoTextTheme = PartJ.jetBrainsMonoTextTheme;

  /// See [PartJ.jimNightshade].
  static const jimNightshade = PartJ.jimNightshade;

  /// See [PartJ.jimNightshadeTextTheme].
  static const jimNightshadeTextTheme = PartJ.jimNightshadeTextTheme;

  /// See [PartJ.joan].
  static const joan = PartJ.joan;

  /// See [PartJ.joanTextTheme].
  static const joanTextTheme = PartJ.joanTextTheme;

  /// See [PartJ.jockeyOne].
  static const jockeyOne = PartJ.jockeyOne;

  /// See [PartJ.jockeyOneTextTheme].
  static const jockeyOneTextTheme = PartJ.jockeyOneTextTheme;

  /// See [PartJ.jollyLodger].
  static const jollyLodger = PartJ.jollyLodger;

  /// See [PartJ.jollyLodgerTextTheme].
  static const jollyLodgerTextTheme = PartJ.jollyLodgerTextTheme;

  /// See [PartJ.jomhuria].
  static const jomhuria = PartJ.jomhuria;

  /// See [PartJ.jomhuriaTextTheme].
  static const jomhuriaTextTheme = PartJ.jomhuriaTextTheme;

  /// See [PartJ.jomolhari].
  static const jomolhari = PartJ.jomolhari;

  /// See [PartJ.jomolhariTextTheme].
  static const jomolhariTextTheme = PartJ.jomolhariTextTheme;

  /// See [PartJ.josefinSans].
  static const josefinSans = PartJ.josefinSans;

  /// See [PartJ.josefinSansTextTheme].
  static const josefinSansTextTheme = PartJ.josefinSansTextTheme;

  /// See [PartJ.josefinSlab].
  static const josefinSlab = PartJ.josefinSlab;

  /// See [PartJ.josefinSlabTextTheme].
  static const josefinSlabTextTheme = PartJ.josefinSlabTextTheme;

  /// See [PartJ.jost].
  static const jost = PartJ.jost;

  /// See [PartJ.jostTextTheme].
  static const jostTextTheme = PartJ.jostTextTheme;

  /// See [PartJ.jotiOne].
  static const jotiOne = PartJ.jotiOne;

  /// See [PartJ.jotiOneTextTheme].
  static const jotiOneTextTheme = PartJ.jotiOneTextTheme;

  /// See [PartJ.jua].
  static const jua = PartJ.jua;

  /// See [PartJ.juaTextTheme].
  static const juaTextTheme = PartJ.juaTextTheme;

  /// See [PartJ.judson].
  static const judson = PartJ.judson;

  /// See [PartJ.judsonTextTheme].
  static const judsonTextTheme = PartJ.judsonTextTheme;

  /// See [PartJ.julee].
  static const julee = PartJ.julee;

  /// See [PartJ.juleeTextTheme].
  static const juleeTextTheme = PartJ.juleeTextTheme;

  /// See [PartJ.juliusSansOne].
  static const juliusSansOne = PartJ.juliusSansOne;

  /// See [PartJ.juliusSansOneTextTheme].
  static const juliusSansOneTextTheme = PartJ.juliusSansOneTextTheme;

  /// See [PartJ.junge].
  static const junge = PartJ.junge;

  /// See [PartJ.jungeTextTheme].
  static const jungeTextTheme = PartJ.jungeTextTheme;

  /// See [PartJ.jura].
  static const jura = PartJ.jura;

  /// See [PartJ.juraTextTheme].
  static const juraTextTheme = PartJ.juraTextTheme;

  /// See [PartJ.justAnotherHand].
  static const justAnotherHand = PartJ.justAnotherHand;

  /// See [PartJ.justAnotherHandTextTheme].
  static const justAnotherHandTextTheme = PartJ.justAnotherHandTextTheme;

  /// See [PartJ.justMeAgainDownHere].
  static const justMeAgainDownHere = PartJ.justMeAgainDownHere;

  /// See [PartJ.justMeAgainDownHereTextTheme].
  static const justMeAgainDownHereTextTheme =
      PartJ.justMeAgainDownHereTextTheme;

  /// See [PartK.k2d].
  static const k2d = PartK.k2d;

  /// See [PartK.k2dTextTheme].
  static const k2dTextTheme = PartK.k2dTextTheme;

  /// See [PartK.kablammo].
  static const kablammo = PartK.kablammo;

  /// See [PartK.kablammoTextTheme].
  static const kablammoTextTheme = PartK.kablammoTextTheme;

  /// See [PartK.kadwa].
  static const kadwa = PartK.kadwa;

  /// See [PartK.kadwaTextTheme].
  static const kadwaTextTheme = PartK.kadwaTextTheme;

  /// See [PartK.kaiseiDecol].
  static const kaiseiDecol = PartK.kaiseiDecol;

  /// See [PartK.kaiseiDecolTextTheme].
  static const kaiseiDecolTextTheme = PartK.kaiseiDecolTextTheme;

  /// See [PartK.kaiseiHarunoUmi].
  static const kaiseiHarunoUmi = PartK.kaiseiHarunoUmi;

  /// See [PartK.kaiseiHarunoUmiTextTheme].
  static const kaiseiHarunoUmiTextTheme = PartK.kaiseiHarunoUmiTextTheme;

  /// See [PartK.kaiseiOpti].
  static const kaiseiOpti = PartK.kaiseiOpti;

  /// See [PartK.kaiseiOptiTextTheme].
  static const kaiseiOptiTextTheme = PartK.kaiseiOptiTextTheme;

  /// See [PartK.kaiseiTokumin].
  static const kaiseiTokumin = PartK.kaiseiTokumin;

  /// See [PartK.kaiseiTokuminTextTheme].
  static const kaiseiTokuminTextTheme = PartK.kaiseiTokuminTextTheme;

  /// See [PartK.kalam].
  static const kalam = PartK.kalam;

  /// See [PartK.kalamTextTheme].
  static const kalamTextTheme = PartK.kalamTextTheme;

  /// See [PartK.kalnia].
  static const kalnia = PartK.kalnia;

  /// See [PartK.kalniaTextTheme].
  static const kalniaTextTheme = PartK.kalniaTextTheme;

  /// See [PartK.kalniaGlaze].
  static const kalniaGlaze = PartK.kalniaGlaze;

  /// See [PartK.kalniaGlazeTextTheme].
  static const kalniaGlazeTextTheme = PartK.kalniaGlazeTextTheme;

  /// See [PartK.kameron].
  static const kameron = PartK.kameron;

  /// See [PartK.kameronTextTheme].
  static const kameronTextTheme = PartK.kameronTextTheme;

  /// See [PartK.kanchenjunga].
  static const kanchenjunga = PartK.kanchenjunga;

  /// See [PartK.kanchenjungaTextTheme].
  static const kanchenjungaTextTheme = PartK.kanchenjungaTextTheme;

  /// See [PartK.kanit].
  static const kanit = PartK.kanit;

  /// See [PartK.kanitTextTheme].
  static const kanitTextTheme = PartK.kanitTextTheme;

  /// See [PartK.kantumruyPro].
  static const kantumruyPro = PartK.kantumruyPro;

  /// See [PartK.kantumruyProTextTheme].
  static const kantumruyProTextTheme = PartK.kantumruyProTextTheme;

  /// See [PartK.kapakana].
  static const kapakana = PartK.kapakana;

  /// See [PartK.kapakanaTextTheme].
  static const kapakanaTextTheme = PartK.kapakanaTextTheme;

  /// See [PartK.karantina].
  static const karantina = PartK.karantina;

  /// See [PartK.karantinaTextTheme].
  static const karantinaTextTheme = PartK.karantinaTextTheme;

  /// See [PartK.karla].
  static const karla = PartK.karla;

  /// See [PartK.karlaTextTheme].
  static const karlaTextTheme = PartK.karlaTextTheme;

  /// See [PartK.karlaTamilInclined].
  static const karlaTamilInclined = PartK.karlaTamilInclined;

  /// See [PartK.karlaTamilInclinedTextTheme].
  static const karlaTamilInclinedTextTheme = PartK.karlaTamilInclinedTextTheme;

  /// See [PartK.karlaTamilUpright].
  static const karlaTamilUpright = PartK.karlaTamilUpright;

  /// See [PartK.karlaTamilUprightTextTheme].
  static const karlaTamilUprightTextTheme = PartK.karlaTamilUprightTextTheme;

  /// See [PartK.karma].
  static const karma = PartK.karma;

  /// See [PartK.karmaTextTheme].
  static const karmaTextTheme = PartK.karmaTextTheme;

  /// See [PartK.katibeh].
  static const katibeh = PartK.katibeh;

  /// See [PartK.katibehTextTheme].
  static const katibehTextTheme = PartK.katibehTextTheme;

  /// See [PartK.kaushanScript].
  static const kaushanScript = PartK.kaushanScript;

  /// See [PartK.kaushanScriptTextTheme].
  static const kaushanScriptTextTheme = PartK.kaushanScriptTextTheme;

  /// See [PartK.kavivanar].
  static const kavivanar = PartK.kavivanar;

  /// See [PartK.kavivanarTextTheme].
  static const kavivanarTextTheme = PartK.kavivanarTextTheme;

  /// See [PartK.kavoon].
  static const kavoon = PartK.kavoon;

  /// See [PartK.kavoonTextTheme].
  static const kavoonTextTheme = PartK.kavoonTextTheme;

  /// See [PartK.kayPhoDu].
  static const kayPhoDu = PartK.kayPhoDu;

  /// See [PartK.kayPhoDuTextTheme].
  static const kayPhoDuTextTheme = PartK.kayPhoDuTextTheme;

  /// See [PartK.kdamThmorPro].
  static const kdamThmorPro = PartK.kdamThmorPro;

  /// See [PartK.kdamThmorProTextTheme].
  static const kdamThmorProTextTheme = PartK.kdamThmorProTextTheme;

  /// See [PartK.keaniaOne].
  static const keaniaOne = PartK.keaniaOne;

  /// See [PartK.keaniaOneTextTheme].
  static const keaniaOneTextTheme = PartK.keaniaOneTextTheme;

  /// See [PartK.kellySlab].
  static const kellySlab = PartK.kellySlab;

  /// See [PartK.kellySlabTextTheme].
  static const kellySlabTextTheme = PartK.kellySlabTextTheme;

  /// See [PartK.kenia].
  static const kenia = PartK.kenia;

  /// See [PartK.keniaTextTheme].
  static const keniaTextTheme = PartK.keniaTextTheme;

  /// See [PartK.khand].
  static const khand = PartK.khand;

  /// See [PartK.khandTextTheme].
  static const khandTextTheme = PartK.khandTextTheme;

  /// See [PartK.khmer].
  static const khmer = PartK.khmer;

  /// See [PartK.khmerTextTheme].
  static const khmerTextTheme = PartK.khmerTextTheme;

  /// See [PartK.khula].
  static const khula = PartK.khula;

  /// See [PartK.khulaTextTheme].
  static const khulaTextTheme = PartK.khulaTextTheme;

  /// See [PartK.kings].
  static const kings = PartK.kings;

  /// See [PartK.kingsTextTheme].
  static const kingsTextTheme = PartK.kingsTextTheme;

  /// See [PartK.kirangHaerang].
  static const kirangHaerang = PartK.kirangHaerang;

  /// See [PartK.kirangHaerangTextTheme].
  static const kirangHaerangTextTheme = PartK.kirangHaerangTextTheme;

  /// See [PartK.kiteOne].
  static const kiteOne = PartK.kiteOne;

  /// See [PartK.kiteOneTextTheme].
  static const kiteOneTextTheme = PartK.kiteOneTextTheme;

  /// See [PartK.kiwiMaru].
  static const kiwiMaru = PartK.kiwiMaru;

  /// See [PartK.kiwiMaruTextTheme].
  static const kiwiMaruTextTheme = PartK.kiwiMaruTextTheme;

  /// See [PartK.kleeOne].
  static const kleeOne = PartK.kleeOne;

  /// See [PartK.kleeOneTextTheme].
  static const kleeOneTextTheme = PartK.kleeOneTextTheme;

  /// See [PartK.knewave].
  static const knewave = PartK.knewave;

  /// See [PartK.knewaveTextTheme].
  static const knewaveTextTheme = PartK.knewaveTextTheme;

  /// See [PartK.koHo].
  static const koHo = PartK.koHo;

  /// See [PartK.koHoTextTheme].
  static const koHoTextTheme = PartK.koHoTextTheme;

  /// See [PartK.kodchasan].
  static const kodchasan = PartK.kodchasan;

  /// See [PartK.kodchasanTextTheme].
  static const kodchasanTextTheme = PartK.kodchasanTextTheme;

  /// See [PartK.kodeMono].
  static const kodeMono = PartK.kodeMono;

  /// See [PartK.kodeMonoTextTheme].
  static const kodeMonoTextTheme = PartK.kodeMonoTextTheme;

  /// See [PartK.kohSantepheap].
  static const kohSantepheap = PartK.kohSantepheap;

  /// See [PartK.kohSantepheapTextTheme].
  static const kohSantepheapTextTheme = PartK.kohSantepheapTextTheme;

  /// See [PartK.kolkerBrush].
  static const kolkerBrush = PartK.kolkerBrush;

  /// See [PartK.kolkerBrushTextTheme].
  static const kolkerBrushTextTheme = PartK.kolkerBrushTextTheme;

  /// See [PartK.konkhmerSleokchher].
  static const konkhmerSleokchher = PartK.konkhmerSleokchher;

  /// See [PartK.konkhmerSleokchherTextTheme].
  static const konkhmerSleokchherTextTheme = PartK.konkhmerSleokchherTextTheme;

  /// See [PartK.kosugi].
  static const kosugi = PartK.kosugi;

  /// See [PartK.kosugiTextTheme].
  static const kosugiTextTheme = PartK.kosugiTextTheme;

  /// See [PartK.kosugiMaru].
  static const kosugiMaru = PartK.kosugiMaru;

  /// See [PartK.kosugiMaruTextTheme].
  static const kosugiMaruTextTheme = PartK.kosugiMaruTextTheme;

  /// See [PartK.kottaOne].
  static const kottaOne = PartK.kottaOne;

  /// See [PartK.kottaOneTextTheme].
  static const kottaOneTextTheme = PartK.kottaOneTextTheme;

  /// See [PartK.koulen].
  static const koulen = PartK.koulen;

  /// See [PartK.koulenTextTheme].
  static const koulenTextTheme = PartK.koulenTextTheme;

  /// See [PartK.kranky].
  static const kranky = PartK.kranky;

  /// See [PartK.krankyTextTheme].
  static const krankyTextTheme = PartK.krankyTextTheme;

  /// See [PartK.kreon].
  static const kreon = PartK.kreon;

  /// See [PartK.kreonTextTheme].
  static const kreonTextTheme = PartK.kreonTextTheme;

  /// See [PartK.kristi].
  static const kristi = PartK.kristi;

  /// See [PartK.kristiTextTheme].
  static const kristiTextTheme = PartK.kristiTextTheme;

  /// See [PartK.kronaOne].
  static const kronaOne = PartK.kronaOne;

  /// See [PartK.kronaOneTextTheme].
  static const kronaOneTextTheme = PartK.kronaOneTextTheme;

  /// See [PartK.krub].
  static const krub = PartK.krub;

  /// See [PartK.krubTextTheme].
  static const krubTextTheme = PartK.krubTextTheme;

  /// See [PartK.kufam].
  static const kufam = PartK.kufam;

  /// See [PartK.kufamTextTheme].
  static const kufamTextTheme = PartK.kufamTextTheme;

  /// See [PartK.kulimPark].
  static const kulimPark = PartK.kulimPark;

  /// See [PartK.kulimParkTextTheme].
  static const kulimParkTextTheme = PartK.kulimParkTextTheme;

  /// See [PartK.kumarOne].
  static const kumarOne = PartK.kumarOne;

  /// See [PartK.kumarOneTextTheme].
  static const kumarOneTextTheme = PartK.kumarOneTextTheme;

  /// See [PartK.kumarOneOutline].
  static const kumarOneOutline = PartK.kumarOneOutline;

  /// See [PartK.kumarOneOutlineTextTheme].
  static const kumarOneOutlineTextTheme = PartK.kumarOneOutlineTextTheme;

  /// See [PartK.kumbhSans].
  static const kumbhSans = PartK.kumbhSans;

  /// See [PartK.kumbhSansTextTheme].
  static const kumbhSansTextTheme = PartK.kumbhSansTextTheme;

  /// See [PartK.kurale].
  static const kurale = PartK.kurale;

  /// See [PartK.kuraleTextTheme].
  static const kuraleTextTheme = PartK.kuraleTextTheme;

  /// See [PartL.lxgwMarkerGothic].
  static const lxgwMarkerGothic = PartL.lxgwMarkerGothic;

  /// See [PartL.lxgwMarkerGothicTextTheme].
  static const lxgwMarkerGothicTextTheme = PartL.lxgwMarkerGothicTextTheme;

  /// See [PartL.lxgwWenKaiMonoTc].
  static const lxgwWenKaiMonoTc = PartL.lxgwWenKaiMonoTc;

  /// See [PartL.lxgwWenKaiMonoTcTextTheme].
  static const lxgwWenKaiMonoTcTextTheme = PartL.lxgwWenKaiMonoTcTextTheme;

  /// See [PartL.lxgwWenKaiTc].
  static const lxgwWenKaiTc = PartL.lxgwWenKaiTc;

  /// See [PartL.lxgwWenKaiTcTextTheme].
  static const lxgwWenKaiTcTextTheme = PartL.lxgwWenKaiTcTextTheme;

  /// See [PartL.laBelleAurore].
  static const laBelleAurore = PartL.laBelleAurore;

  /// See [PartL.laBelleAuroreTextTheme].
  static const laBelleAuroreTextTheme = PartL.laBelleAuroreTextTheme;

  /// See [PartL.labrada].
  static const labrada = PartL.labrada;

  /// See [PartL.labradaTextTheme].
  static const labradaTextTheme = PartL.labradaTextTheme;

  /// See [PartL.lacquer].
  static const lacquer = PartL.lacquer;

  /// See [PartL.lacquerTextTheme].
  static const lacquerTextTheme = PartL.lacquerTextTheme;

  /// See [PartL.laila].
  static const laila = PartL.laila;

  /// See [PartL.lailaTextTheme].
  static const lailaTextTheme = PartL.lailaTextTheme;

  /// See [PartL.lakkiReddy].
  static const lakkiReddy = PartL.lakkiReddy;

  /// See [PartL.lakkiReddyTextTheme].
  static const lakkiReddyTextTheme = PartL.lakkiReddyTextTheme;

  /// See [PartL.lalezar].
  static const lalezar = PartL.lalezar;

  /// See [PartL.lalezarTextTheme].
  static const lalezarTextTheme = PartL.lalezarTextTheme;

  /// See [PartL.lancelot].
  static const lancelot = PartL.lancelot;

  /// See [PartL.lancelotTextTheme].
  static const lancelotTextTheme = PartL.lancelotTextTheme;

  /// See [PartL.langar].
  static const langar = PartL.langar;

  /// See [PartL.langarTextTheme].
  static const langarTextTheme = PartL.langarTextTheme;

  /// See [PartL.lateef].
  static const lateef = PartL.lateef;

  /// See [PartL.lateefTextTheme].
  static const lateefTextTheme = PartL.lateefTextTheme;

  /// See [PartL.lato].
  static const lato = PartL.lato;

  /// See [PartL.latoTextTheme].
  static const latoTextTheme = PartL.latoTextTheme;

  /// See [PartL.lavishlyYours].
  static const lavishlyYours = PartL.lavishlyYours;

  /// See [PartL.lavishlyYoursTextTheme].
  static const lavishlyYoursTextTheme = PartL.lavishlyYoursTextTheme;

  /// See [PartL.leagueGothic].
  static const leagueGothic = PartL.leagueGothic;

  /// See [PartL.leagueGothicTextTheme].
  static const leagueGothicTextTheme = PartL.leagueGothicTextTheme;

  /// See [PartL.leagueScript].
  static const leagueScript = PartL.leagueScript;

  /// See [PartL.leagueScriptTextTheme].
  static const leagueScriptTextTheme = PartL.leagueScriptTextTheme;

  /// See [PartL.leagueSpartan].
  static const leagueSpartan = PartL.leagueSpartan;

  /// See [PartL.leagueSpartanTextTheme].
  static const leagueSpartanTextTheme = PartL.leagueSpartanTextTheme;

  /// See [PartL.leckerliOne].
  static const leckerliOne = PartL.leckerliOne;

  /// See [PartL.leckerliOneTextTheme].
  static const leckerliOneTextTheme = PartL.leckerliOneTextTheme;

  /// See [PartL.ledger].
  static const ledger = PartL.ledger;

  /// See [PartL.ledgerTextTheme].
  static const ledgerTextTheme = PartL.ledgerTextTheme;

  /// See [PartL.lekton].
  static const lekton = PartL.lekton;

  /// See [PartL.lektonTextTheme].
  static const lektonTextTheme = PartL.lektonTextTheme;

  /// See [PartL.lemon].
  static const lemon = PartL.lemon;

  /// See [PartL.lemonTextTheme].
  static const lemonTextTheme = PartL.lemonTextTheme;

  /// See [PartL.lemonada].
  static const lemonada = PartL.lemonada;

  /// See [PartL.lemonadaTextTheme].
  static const lemonadaTextTheme = PartL.lemonadaTextTheme;

  /// See [PartL.lexend].
  static const lexend = PartL.lexend;

  /// See [PartL.lexendTextTheme].
  static const lexendTextTheme = PartL.lexendTextTheme;

  /// See [PartL.lexendDeca].
  static const lexendDeca = PartL.lexendDeca;

  /// See [PartL.lexendDecaTextTheme].
  static const lexendDecaTextTheme = PartL.lexendDecaTextTheme;

  /// See [PartL.lexendExa].
  static const lexendExa = PartL.lexendExa;

  /// See [PartL.lexendExaTextTheme].
  static const lexendExaTextTheme = PartL.lexendExaTextTheme;

  /// See [PartL.lexendGiga].
  static const lexendGiga = PartL.lexendGiga;

  /// See [PartL.lexendGigaTextTheme].
  static const lexendGigaTextTheme = PartL.lexendGigaTextTheme;

  /// See [PartL.lexendMega].
  static const lexendMega = PartL.lexendMega;

  /// See [PartL.lexendMegaTextTheme].
  static const lexendMegaTextTheme = PartL.lexendMegaTextTheme;

  /// See [PartL.lexendPeta].
  static const lexendPeta = PartL.lexendPeta;

  /// See [PartL.lexendPetaTextTheme].
  static const lexendPetaTextTheme = PartL.lexendPetaTextTheme;

  /// See [PartL.lexendTera].
  static const lexendTera = PartL.lexendTera;

  /// See [PartL.lexendTeraTextTheme].
  static const lexendTeraTextTheme = PartL.lexendTeraTextTheme;

  /// See [PartL.lexendZetta].
  static const lexendZetta = PartL.lexendZetta;

  /// See [PartL.lexendZettaTextTheme].
  static const lexendZettaTextTheme = PartL.lexendZettaTextTheme;

  /// See [PartL.libertinusKeyboard].
  static const libertinusKeyboard = PartL.libertinusKeyboard;

  /// See [PartL.libertinusKeyboardTextTheme].
  static const libertinusKeyboardTextTheme = PartL.libertinusKeyboardTextTheme;

  /// See [PartL.libertinusMath].
  static const libertinusMath = PartL.libertinusMath;

  /// See [PartL.libertinusMathTextTheme].
  static const libertinusMathTextTheme = PartL.libertinusMathTextTheme;

  /// See [PartL.libertinusMono].
  static const libertinusMono = PartL.libertinusMono;

  /// See [PartL.libertinusMonoTextTheme].
  static const libertinusMonoTextTheme = PartL.libertinusMonoTextTheme;

  /// See [PartL.libertinusSans].
  static const libertinusSans = PartL.libertinusSans;

  /// See [PartL.libertinusSansTextTheme].
  static const libertinusSansTextTheme = PartL.libertinusSansTextTheme;

  /// See [PartL.libertinusSerif].
  static const libertinusSerif = PartL.libertinusSerif;

  /// See [PartL.libertinusSerifTextTheme].
  static const libertinusSerifTextTheme = PartL.libertinusSerifTextTheme;

  /// See [PartL.libertinusSerifDisplay].
  static const libertinusSerifDisplay = PartL.libertinusSerifDisplay;

  /// See [PartL.libertinusSerifDisplayTextTheme].
  static const libertinusSerifDisplayTextTheme =
      PartL.libertinusSerifDisplayTextTheme;

  /// See [PartL.libreBarcode128].
  static const libreBarcode128 = PartL.libreBarcode128;

  /// See [PartL.libreBarcode128TextTheme].
  static const libreBarcode128TextTheme = PartL.libreBarcode128TextTheme;

  /// See [PartL.libreBarcode128Text].
  static const libreBarcode128Text = PartL.libreBarcode128Text;

  /// See [PartL.libreBarcode128TextTextTheme].
  static const libreBarcode128TextTextTheme =
      PartL.libreBarcode128TextTextTheme;

  /// See [PartL.libreBarcode39].
  static const libreBarcode39 = PartL.libreBarcode39;

  /// See [PartL.libreBarcode39TextTheme].
  static const libreBarcode39TextTheme = PartL.libreBarcode39TextTheme;

  /// See [PartL.libreBarcode39Extended].
  static const libreBarcode39Extended = PartL.libreBarcode39Extended;

  /// See [PartL.libreBarcode39ExtendedTextTheme].
  static const libreBarcode39ExtendedTextTheme =
      PartL.libreBarcode39ExtendedTextTheme;

  /// See [PartL.libreBarcode39ExtendedText].
  static const libreBarcode39ExtendedText = PartL.libreBarcode39ExtendedText;

  /// See [PartL.libreBarcode39ExtendedTextTextTheme].
  static const libreBarcode39ExtendedTextTextTheme =
      PartL.libreBarcode39ExtendedTextTextTheme;

  /// See [PartL.libreBarcode39Text].
  static const libreBarcode39Text = PartL.libreBarcode39Text;

  /// See [PartL.libreBarcode39TextTextTheme].
  static const libreBarcode39TextTextTheme = PartL.libreBarcode39TextTextTheme;

  /// See [PartL.libreBarcodeEan13Text].
  static const libreBarcodeEan13Text = PartL.libreBarcodeEan13Text;

  /// See [PartL.libreBarcodeEan13TextTextTheme].
  static const libreBarcodeEan13TextTextTheme =
      PartL.libreBarcodeEan13TextTextTheme;

  /// See [PartL.libreBaskerville].
  static const libreBaskerville = PartL.libreBaskerville;

  /// See [PartL.libreBaskervilleTextTheme].
  static const libreBaskervilleTextTheme = PartL.libreBaskervilleTextTheme;

  /// See [PartL.libreBodoni].
  static const libreBodoni = PartL.libreBodoni;

  /// See [PartL.libreBodoniTextTheme].
  static const libreBodoniTextTheme = PartL.libreBodoniTextTheme;

  /// See [PartL.libreCaslonDisplay].
  static const libreCaslonDisplay = PartL.libreCaslonDisplay;

  /// See [PartL.libreCaslonDisplayTextTheme].
  static const libreCaslonDisplayTextTheme = PartL.libreCaslonDisplayTextTheme;

  /// See [PartL.libreCaslonText].
  static const libreCaslonText = PartL.libreCaslonText;

  /// See [PartL.libreCaslonTextTextTheme].
  static const libreCaslonTextTextTheme = PartL.libreCaslonTextTextTheme;

  /// See [PartL.libreFranklin].
  static const libreFranklin = PartL.libreFranklin;

  /// See [PartL.libreFranklinTextTheme].
  static const libreFranklinTextTheme = PartL.libreFranklinTextTheme;

  /// See [PartL.licorice].
  static const licorice = PartL.licorice;

  /// See [PartL.licoriceTextTheme].
  static const licoriceTextTheme = PartL.licoriceTextTheme;

  /// See [PartL.lifeSavers].
  static const lifeSavers = PartL.lifeSavers;

  /// See [PartL.lifeSaversTextTheme].
  static const lifeSaversTextTheme = PartL.lifeSaversTextTheme;

  /// See [PartL.lilitaOne].
  static const lilitaOne = PartL.lilitaOne;

  /// See [PartL.lilitaOneTextTheme].
  static const lilitaOneTextTheme = PartL.lilitaOneTextTheme;

  /// See [PartL.lilyScriptOne].
  static const lilyScriptOne = PartL.lilyScriptOne;

  /// See [PartL.lilyScriptOneTextTheme].
  static const lilyScriptOneTextTheme = PartL.lilyScriptOneTextTheme;

  /// See [PartL.limelight].
  static const limelight = PartL.limelight;

  /// See [PartL.limelightTextTheme].
  static const limelightTextTheme = PartL.limelightTextTheme;

  /// See [PartL.lindenHill].
  static const lindenHill = PartL.lindenHill;

  /// See [PartL.lindenHillTextTheme].
  static const lindenHillTextTheme = PartL.lindenHillTextTheme;

  /// See [PartL.linefont].
  static const linefont = PartL.linefont;

  /// See [PartL.linefontTextTheme].
  static const linefontTextTheme = PartL.linefontTextTheme;

  /// See [PartL.lisuBosa].
  static const lisuBosa = PartL.lisuBosa;

  /// See [PartL.lisuBosaTextTheme].
  static const lisuBosaTextTheme = PartL.lisuBosaTextTheme;

  /// See [PartL.liter].
  static const liter = PartL.liter;

  /// See [PartL.literTextTheme].
  static const literTextTheme = PartL.literTextTheme;

  /// See [PartL.literata].
  static const literata = PartL.literata;

  /// See [PartL.literataTextTheme].
  static const literataTextTheme = PartL.literataTextTheme;

  /// See [PartL.liuJianMaoCao].
  static const liuJianMaoCao = PartL.liuJianMaoCao;

  /// See [PartL.liuJianMaoCaoTextTheme].
  static const liuJianMaoCaoTextTheme = PartL.liuJianMaoCaoTextTheme;

  /// See [PartL.livvic].
  static const livvic = PartL.livvic;

  /// See [PartL.livvicTextTheme].
  static const livvicTextTheme = PartL.livvicTextTheme;

  /// See [PartL.lobster].
  static const lobster = PartL.lobster;

  /// See [PartL.lobsterTextTheme].
  static const lobsterTextTheme = PartL.lobsterTextTheme;

  /// See [PartL.lobsterTwo].
  static const lobsterTwo = PartL.lobsterTwo;

  /// See [PartL.lobsterTwoTextTheme].
  static const lobsterTwoTextTheme = PartL.lobsterTwoTextTheme;

  /// See [PartL.londrinaOutline].
  static const londrinaOutline = PartL.londrinaOutline;

  /// See [PartL.londrinaOutlineTextTheme].
  static const londrinaOutlineTextTheme = PartL.londrinaOutlineTextTheme;

  /// See [PartL.londrinaShadow].
  static const londrinaShadow = PartL.londrinaShadow;

  /// See [PartL.londrinaShadowTextTheme].
  static const londrinaShadowTextTheme = PartL.londrinaShadowTextTheme;

  /// See [PartL.londrinaSketch].
  static const londrinaSketch = PartL.londrinaSketch;

  /// See [PartL.londrinaSketchTextTheme].
  static const londrinaSketchTextTheme = PartL.londrinaSketchTextTheme;

  /// See [PartL.londrinaSolid].
  static const londrinaSolid = PartL.londrinaSolid;

  /// See [PartL.londrinaSolidTextTheme].
  static const londrinaSolidTextTheme = PartL.londrinaSolidTextTheme;

  /// See [PartL.longCang].
  static const longCang = PartL.longCang;

  /// See [PartL.longCangTextTheme].
  static const longCangTextTheme = PartL.longCangTextTheme;

  /// See [PartL.lora].
  static const lora = PartL.lora;

  /// See [PartL.loraTextTheme].
  static const loraTextTheme = PartL.loraTextTheme;

  /// See [PartL.loveLight].
  static const loveLight = PartL.loveLight;

  /// See [PartL.loveLightTextTheme].
  static const loveLightTextTheme = PartL.loveLightTextTheme;

  /// See [PartL.loveYaLikeASister].
  static const loveYaLikeASister = PartL.loveYaLikeASister;

  /// See [PartL.loveYaLikeASisterTextTheme].
  static const loveYaLikeASisterTextTheme = PartL.loveYaLikeASisterTextTheme;

  /// See [PartL.lovedByTheKing].
  static const lovedByTheKing = PartL.lovedByTheKing;

  /// See [PartL.lovedByTheKingTextTheme].
  static const lovedByTheKingTextTheme = PartL.lovedByTheKingTextTheme;

  /// See [PartL.loversQuarrel].
  static const loversQuarrel = PartL.loversQuarrel;

  /// See [PartL.loversQuarrelTextTheme].
  static const loversQuarrelTextTheme = PartL.loversQuarrelTextTheme;

  /// See [PartL.luckiestGuy].
  static const luckiestGuy = PartL.luckiestGuy;

  /// See [PartL.luckiestGuyTextTheme].
  static const luckiestGuyTextTheme = PartL.luckiestGuyTextTheme;

  /// See [PartL.lugrasimo].
  static const lugrasimo = PartL.lugrasimo;

  /// See [PartL.lugrasimoTextTheme].
  static const lugrasimoTextTheme = PartL.lugrasimoTextTheme;

  /// See [PartL.lumanosimo].
  static const lumanosimo = PartL.lumanosimo;

  /// See [PartL.lumanosimoTextTheme].
  static const lumanosimoTextTheme = PartL.lumanosimoTextTheme;

  /// See [PartL.lunasima].
  static const lunasima = PartL.lunasima;

  /// See [PartL.lunasimaTextTheme].
  static const lunasimaTextTheme = PartL.lunasimaTextTheme;

  /// See [PartL.lusitana].
  static const lusitana = PartL.lusitana;

  /// See [PartL.lusitanaTextTheme].
  static const lusitanaTextTheme = PartL.lusitanaTextTheme;

  /// See [PartL.lustria].
  static const lustria = PartL.lustria;

  /// See [PartL.lustriaTextTheme].
  static const lustriaTextTheme = PartL.lustriaTextTheme;

  /// See [PartL.luxuriousRoman].
  static const luxuriousRoman = PartL.luxuriousRoman;

  /// See [PartL.luxuriousRomanTextTheme].
  static const luxuriousRomanTextTheme = PartL.luxuriousRomanTextTheme;

  /// See [PartL.luxuriousScript].
  static const luxuriousScript = PartL.luxuriousScript;

  /// See [PartL.luxuriousScriptTextTheme].
  static const luxuriousScriptTextTheme = PartL.luxuriousScriptTextTheme;

  /// See [PartM.mPlus1].
  static const mPlus1 = PartM.mPlus1;

  /// See [PartM.mPlus1TextTheme].
  static const mPlus1TextTheme = PartM.mPlus1TextTheme;

  /// See [PartM.mPlus1Code].
  static const mPlus1Code = PartM.mPlus1Code;

  /// See [PartM.mPlus1CodeTextTheme].
  static const mPlus1CodeTextTheme = PartM.mPlus1CodeTextTheme;

  /// See [PartM.mPlus1p].
  static const mPlus1p = PartM.mPlus1p;

  /// See [PartM.mPlus1pTextTheme].
  static const mPlus1pTextTheme = PartM.mPlus1pTextTheme;

  /// See [PartM.mPlus2].
  static const mPlus2 = PartM.mPlus2;

  /// See [PartM.mPlus2TextTheme].
  static const mPlus2TextTheme = PartM.mPlus2TextTheme;

  /// See [PartM.mPlusCodeLatin].
  static const mPlusCodeLatin = PartM.mPlusCodeLatin;

  /// See [PartM.mPlusCodeLatinTextTheme].
  static const mPlusCodeLatinTextTheme = PartM.mPlusCodeLatinTextTheme;

  /// See [PartM.mPlusRounded1c].
  static const mPlusRounded1c = PartM.mPlusRounded1c;

  /// See [PartM.mPlusRounded1cTextTheme].
  static const mPlusRounded1cTextTheme = PartM.mPlusRounded1cTextTheme;

  /// See [PartM.maShanZheng].
  static const maShanZheng = PartM.maShanZheng;

  /// See [PartM.maShanZhengTextTheme].
  static const maShanZhengTextTheme = PartM.maShanZhengTextTheme;

  /// See [PartM.macondo].
  static const macondo = PartM.macondo;

  /// See [PartM.macondoTextTheme].
  static const macondoTextTheme = PartM.macondoTextTheme;

  /// See [PartM.macondoSwashCaps].
  static const macondoSwashCaps = PartM.macondoSwashCaps;

  /// See [PartM.macondoSwashCapsTextTheme].
  static const macondoSwashCapsTextTheme = PartM.macondoSwashCapsTextTheme;

  /// See [PartM.mada].
  static const mada = PartM.mada;

  /// See [PartM.madaTextTheme].
  static const madaTextTheme = PartM.madaTextTheme;

  /// See [PartM.madimiOne].
  static const madimiOne = PartM.madimiOne;

  /// See [PartM.madimiOneTextTheme].
  static const madimiOneTextTheme = PartM.madimiOneTextTheme;

  /// See [PartM.magra].
  static const magra = PartM.magra;

  /// See [PartM.magraTextTheme].
  static const magraTextTheme = PartM.magraTextTheme;

  /// See [PartM.maidenOrange].
  static const maidenOrange = PartM.maidenOrange;

  /// See [PartM.maidenOrangeTextTheme].
  static const maidenOrangeTextTheme = PartM.maidenOrangeTextTheme;

  /// See [PartM.maitree].
  static const maitree = PartM.maitree;

  /// See [PartM.maitreeTextTheme].
  static const maitreeTextTheme = PartM.maitreeTextTheme;

  /// See [PartM.majorMonoDisplay].
  static const majorMonoDisplay = PartM.majorMonoDisplay;

  /// See [PartM.majorMonoDisplayTextTheme].
  static const majorMonoDisplayTextTheme = PartM.majorMonoDisplayTextTheme;

  /// See [PartM.mako].
  static const mako = PartM.mako;

  /// See [PartM.makoTextTheme].
  static const makoTextTheme = PartM.makoTextTheme;

  /// See [PartM.mali].
  static const mali = PartM.mali;

  /// See [PartM.maliTextTheme].
  static const maliTextTheme = PartM.maliTextTheme;

  /// See [PartM.mallanna].
  static const mallanna = PartM.mallanna;

  /// See [PartM.mallannaTextTheme].
  static const mallannaTextTheme = PartM.mallannaTextTheme;

  /// See [PartM.maname].
  static const maname = PartM.maname;

  /// See [PartM.manameTextTheme].
  static const manameTextTheme = PartM.manameTextTheme;

  /// See [PartM.mandali].
  static const mandali = PartM.mandali;

  /// See [PartM.mandaliTextTheme].
  static const mandaliTextTheme = PartM.mandaliTextTheme;

  /// See [PartM.manjari].
  static const manjari = PartM.manjari;

  /// See [PartM.manjariTextTheme].
  static const manjariTextTheme = PartM.manjariTextTheme;

  /// See [PartM.manrope].
  static const manrope = PartM.manrope;

  /// See [PartM.manropeTextTheme].
  static const manropeTextTheme = PartM.manropeTextTheme;

  /// See [PartM.mansalva].
  static const mansalva = PartM.mansalva;

  /// See [PartM.mansalvaTextTheme].
  static const mansalvaTextTheme = PartM.mansalvaTextTheme;

  /// See [PartM.manuale].
  static const manuale = PartM.manuale;

  /// See [PartM.manualeTextTheme].
  static const manualeTextTheme = PartM.manualeTextTheme;

  /// See [PartM.manufacturingConsent].
  static const manufacturingConsent = PartM.manufacturingConsent;

  /// See [PartM.manufacturingConsentTextTheme].
  static const manufacturingConsentTextTheme =
      PartM.manufacturingConsentTextTheme;

  /// See [PartM.marcellus].
  static const marcellus = PartM.marcellus;

  /// See [PartM.marcellusTextTheme].
  static const marcellusTextTheme = PartM.marcellusTextTheme;

  /// See [PartM.marcellusSc].
  static const marcellusSc = PartM.marcellusSc;

  /// See [PartM.marcellusScTextTheme].
  static const marcellusScTextTheme = PartM.marcellusScTextTheme;

  /// See [PartM.marckScript].
  static const marckScript = PartM.marckScript;

  /// See [PartM.marckScriptTextTheme].
  static const marckScriptTextTheme = PartM.marckScriptTextTheme;

  /// See [PartM.margarine].
  static const margarine = PartM.margarine;

  /// See [PartM.margarineTextTheme].
  static const margarineTextTheme = PartM.margarineTextTheme;

  /// See [PartM.marhey].
  static const marhey = PartM.marhey;

  /// See [PartM.marheyTextTheme].
  static const marheyTextTheme = PartM.marheyTextTheme;

  /// See [PartM.markaziText].
  static const markaziText = PartM.markaziText;

  /// See [PartM.markaziTextTextTheme].
  static const markaziTextTextTheme = PartM.markaziTextTextTheme;

  /// See [PartM.markoOne].
  static const markoOne = PartM.markoOne;

  /// See [PartM.markoOneTextTheme].
  static const markoOneTextTheme = PartM.markoOneTextTheme;

  /// See [PartM.marmelad].
  static const marmelad = PartM.marmelad;

  /// See [PartM.marmeladTextTheme].
  static const marmeladTextTheme = PartM.marmeladTextTheme;

  /// See [PartM.martel].
  static const martel = PartM.martel;

  /// See [PartM.martelTextTheme].
  static const martelTextTheme = PartM.martelTextTheme;

  /// See [PartM.martelSans].
  static const martelSans = PartM.martelSans;

  /// See [PartM.martelSansTextTheme].
  static const martelSansTextTheme = PartM.martelSansTextTheme;

  /// See [PartM.martianMono].
  static const martianMono = PartM.martianMono;

  /// See [PartM.martianMonoTextTheme].
  static const martianMonoTextTheme = PartM.martianMonoTextTheme;

  /// See [PartM.marvel].
  static const marvel = PartM.marvel;

  /// See [PartM.marvelTextTheme].
  static const marvelTextTheme = PartM.marvelTextTheme;

  /// See [PartM.matangi].
  static const matangi = PartM.matangi;

  /// See [PartM.matangiTextTheme].
  static const matangiTextTheme = PartM.matangiTextTheme;

  /// See [PartM.mate].
  static const mate = PartM.mate;

  /// See [PartM.mateTextTheme].
  static const mateTextTheme = PartM.mateTextTheme;

  /// See [PartM.mateSc].
  static const mateSc = PartM.mateSc;

  /// See [PartM.mateScTextTheme].
  static const mateScTextTheme = PartM.mateScTextTheme;

  /// See [PartM.matemasie].
  static const matemasie = PartM.matemasie;

  /// See [PartM.matemasieTextTheme].
  static const matemasieTextTheme = PartM.matemasieTextTheme;

  /// See [PartM.mavenPro].
  static const mavenPro = PartM.mavenPro;

  /// See [PartM.mavenProTextTheme].
  static const mavenProTextTheme = PartM.mavenProTextTheme;

  /// See [PartM.mcLaren].
  static const mcLaren = PartM.mcLaren;

  /// See [PartM.mcLarenTextTheme].
  static const mcLarenTextTheme = PartM.mcLarenTextTheme;

  /// See [PartM.meaCulpa].
  static const meaCulpa = PartM.meaCulpa;

  /// See [PartM.meaCulpaTextTheme].
  static const meaCulpaTextTheme = PartM.meaCulpaTextTheme;

  /// See [PartM.meddon].
  static const meddon = PartM.meddon;

  /// See [PartM.meddonTextTheme].
  static const meddonTextTheme = PartM.meddonTextTheme;

  /// See [PartM.medievalSharp].
  static const medievalSharp = PartM.medievalSharp;

  /// See [PartM.medievalSharpTextTheme].
  static const medievalSharpTextTheme = PartM.medievalSharpTextTheme;

  /// See [PartM.medulaOne].
  static const medulaOne = PartM.medulaOne;

  /// See [PartM.medulaOneTextTheme].
  static const medulaOneTextTheme = PartM.medulaOneTextTheme;

  /// See [PartM.meeraInimai].
  static const meeraInimai = PartM.meeraInimai;

  /// See [PartM.meeraInimaiTextTheme].
  static const meeraInimaiTextTheme = PartM.meeraInimaiTextTheme;

  /// See [PartM.megrim].
  static const megrim = PartM.megrim;

  /// See [PartM.megrimTextTheme].
  static const megrimTextTheme = PartM.megrimTextTheme;

  /// See [PartM.meieScript].
  static const meieScript = PartM.meieScript;

  /// See [PartM.meieScriptTextTheme].
  static const meieScriptTextTheme = PartM.meieScriptTextTheme;

  /// See [PartM.menbere].
  static const menbere = PartM.menbere;

  /// See [PartM.menbereTextTheme].
  static const menbereTextTheme = PartM.menbereTextTheme;

  /// See [PartM.meowScript].
  static const meowScript = PartM.meowScript;

  /// See [PartM.meowScriptTextTheme].
  static const meowScriptTextTheme = PartM.meowScriptTextTheme;

  /// See [PartM.merienda].
  static const merienda = PartM.merienda;

  /// See [PartM.meriendaTextTheme].
  static const meriendaTextTheme = PartM.meriendaTextTheme;

  /// See [PartM.merriweather].
  static const merriweather = PartM.merriweather;

  /// See [PartM.merriweatherTextTheme].
  static const merriweatherTextTheme = PartM.merriweatherTextTheme;

  /// See [PartM.merriweatherSans].
  static const merriweatherSans = PartM.merriweatherSans;

  /// See [PartM.merriweatherSansTextTheme].
  static const merriweatherSansTextTheme = PartM.merriweatherSansTextTheme;

  /// See [PartM.metal].
  static const metal = PartM.metal;

  /// See [PartM.metalTextTheme].
  static const metalTextTheme = PartM.metalTextTheme;

  /// See [PartM.metalMania].
  static const metalMania = PartM.metalMania;

  /// See [PartM.metalManiaTextTheme].
  static const metalManiaTextTheme = PartM.metalManiaTextTheme;

  /// See [PartM.metamorphous].
  static const metamorphous = PartM.metamorphous;

  /// See [PartM.metamorphousTextTheme].
  static const metamorphousTextTheme = PartM.metamorphousTextTheme;

  /// See [PartM.metrophobic].
  static const metrophobic = PartM.metrophobic;

  /// See [PartM.metrophobicTextTheme].
  static const metrophobicTextTheme = PartM.metrophobicTextTheme;

  /// See [PartM.michroma].
  static const michroma = PartM.michroma;

  /// See [PartM.michromaTextTheme].
  static const michromaTextTheme = PartM.michromaTextTheme;

  /// See [PartM.micro5].
  static const micro5 = PartM.micro5;

  /// See [PartM.micro5TextTheme].
  static const micro5TextTheme = PartM.micro5TextTheme;

  /// See [PartM.micro5Charted].
  static const micro5Charted = PartM.micro5Charted;

  /// See [PartM.micro5ChartedTextTheme].
  static const micro5ChartedTextTheme = PartM.micro5ChartedTextTheme;

  /// See [PartM.milonga].
  static const milonga = PartM.milonga;

  /// See [PartM.milongaTextTheme].
  static const milongaTextTheme = PartM.milongaTextTheme;

  /// See [PartM.miltonian].
  static const miltonian = PartM.miltonian;

  /// See [PartM.miltonianTextTheme].
  static const miltonianTextTheme = PartM.miltonianTextTheme;

  /// See [PartM.miltonianTattoo].
  static const miltonianTattoo = PartM.miltonianTattoo;

  /// See [PartM.miltonianTattooTextTheme].
  static const miltonianTattooTextTheme = PartM.miltonianTattooTextTheme;

  /// See [PartM.mina].
  static const mina = PartM.mina;

  /// See [PartM.minaTextTheme].
  static const minaTextTheme = PartM.minaTextTheme;

  /// See [PartM.mingzat].
  static const mingzat = PartM.mingzat;

  /// See [PartM.mingzatTextTheme].
  static const mingzatTextTheme = PartM.mingzatTextTheme;

  /// See [PartM.miniver].
  static const miniver = PartM.miniver;

  /// See [PartM.miniverTextTheme].
  static const miniverTextTheme = PartM.miniverTextTheme;

  /// See [PartM.miriamLibre].
  static const miriamLibre = PartM.miriamLibre;

  /// See [PartM.miriamLibreTextTheme].
  static const miriamLibreTextTheme = PartM.miriamLibreTextTheme;

  /// See [PartM.mirza].
  static const mirza = PartM.mirza;

  /// See [PartM.mirzaTextTheme].
  static const mirzaTextTheme = PartM.mirzaTextTheme;

  /// See [PartM.missFajardose].
  static const missFajardose = PartM.missFajardose;

  /// See [PartM.missFajardoseTextTheme].
  static const missFajardoseTextTheme = PartM.missFajardoseTextTheme;

  /// See [PartM.mitr].
  static const mitr = PartM.mitr;

  /// See [PartM.mitrTextTheme].
  static const mitrTextTheme = PartM.mitrTextTheme;

  /// See [PartM.mochiyPopOne].
  static const mochiyPopOne = PartM.mochiyPopOne;

  /// See [PartM.mochiyPopOneTextTheme].
  static const mochiyPopOneTextTheme = PartM.mochiyPopOneTextTheme;

  /// See [PartM.mochiyPopPOne].
  static const mochiyPopPOne = PartM.mochiyPopPOne;

  /// See [PartM.mochiyPopPOneTextTheme].
  static const mochiyPopPOneTextTheme = PartM.mochiyPopPOneTextTheme;

  /// See [PartM.modak].
  static const modak = PartM.modak;

  /// See [PartM.modakTextTheme].
  static const modakTextTheme = PartM.modakTextTheme;

  /// See [PartM.modernAntiqua].
  static const modernAntiqua = PartM.modernAntiqua;

  /// See [PartM.modernAntiquaTextTheme].
  static const modernAntiquaTextTheme = PartM.modernAntiquaTextTheme;

  /// See [PartM.moderustic].
  static const moderustic = PartM.moderustic;

  /// See [PartM.moderusticTextTheme].
  static const moderusticTextTheme = PartM.moderusticTextTheme;

  /// See [PartM.mogra].
  static const mogra = PartM.mogra;

  /// See [PartM.mograTextTheme].
  static const mograTextTheme = PartM.mograTextTheme;

  /// See [PartM.mohave].
  static const mohave = PartM.mohave;

  /// See [PartM.mohaveTextTheme].
  static const mohaveTextTheme = PartM.mohaveTextTheme;

  /// See [PartM.moiraiOne].
  static const moiraiOne = PartM.moiraiOne;

  /// See [PartM.moiraiOneTextTheme].
  static const moiraiOneTextTheme = PartM.moiraiOneTextTheme;

  /// See [PartM.molengo].
  static const molengo = PartM.molengo;

  /// See [PartM.molengoTextTheme].
  static const molengoTextTheme = PartM.molengoTextTheme;

  /// See [PartM.molle].
  static const molle = PartM.molle;

  /// See [PartM.molleTextTheme].
  static const molleTextTheme = PartM.molleTextTheme;

  /// See [PartM.monaSans].
  static const monaSans = PartM.monaSans;

  /// See [PartM.monaSansTextTheme].
  static const monaSansTextTheme = PartM.monaSansTextTheme;

  /// See [PartM.monda].
  static const monda = PartM.monda;

  /// See [PartM.mondaTextTheme].
  static const mondaTextTheme = PartM.mondaTextTheme;

  /// See [PartM.monofett].
  static const monofett = PartM.monofett;

  /// See [PartM.monofettTextTheme].
  static const monofettTextTheme = PartM.monofettTextTheme;

  /// See [PartM.monomakh].
  static const monomakh = PartM.monomakh;

  /// See [PartM.monomakhTextTheme].
  static const monomakhTextTheme = PartM.monomakhTextTheme;

  /// See [PartM.monomaniacOne].
  static const monomaniacOne = PartM.monomaniacOne;

  /// See [PartM.monomaniacOneTextTheme].
  static const monomaniacOneTextTheme = PartM.monomaniacOneTextTheme;

  /// See [PartM.monoton].
  static const monoton = PartM.monoton;

  /// See [PartM.monotonTextTheme].
  static const monotonTextTheme = PartM.monotonTextTheme;

  /// See [PartM.monsieurLaDoulaise].
  static const monsieurLaDoulaise = PartM.monsieurLaDoulaise;

  /// See [PartM.monsieurLaDoulaiseTextTheme].
  static const monsieurLaDoulaiseTextTheme = PartM.monsieurLaDoulaiseTextTheme;

  /// See [PartM.montaga].
  static const montaga = PartM.montaga;

  /// See [PartM.montagaTextTheme].
  static const montagaTextTheme = PartM.montagaTextTheme;

  /// See [PartM.montaguSlab].
  static const montaguSlab = PartM.montaguSlab;

  /// See [PartM.montaguSlabTextTheme].
  static const montaguSlabTextTheme = PartM.montaguSlabTextTheme;

  /// See [PartM.monteCarlo].
  static const monteCarlo = PartM.monteCarlo;

  /// See [PartM.monteCarloTextTheme].
  static const monteCarloTextTheme = PartM.monteCarloTextTheme;

  /// See [PartM.montez].
  static const montez = PartM.montez;

  /// See [PartM.montezTextTheme].
  static const montezTextTheme = PartM.montezTextTheme;

  /// See [PartM.montserrat].
  static const montserrat = PartM.montserrat;

  /// See [PartM.montserratTextTheme].
  static const montserratTextTheme = PartM.montserratTextTheme;

  /// See [PartM.montserratAlternates].
  static const montserratAlternates = PartM.montserratAlternates;

  /// See [PartM.montserratAlternatesTextTheme].
  static const montserratAlternatesTextTheme =
      PartM.montserratAlternatesTextTheme;

  /// See [PartM.montserratUnderline].
  static const montserratUnderline = PartM.montserratUnderline;

  /// See [PartM.montserratUnderlineTextTheme].
  static const montserratUnderlineTextTheme =
      PartM.montserratUnderlineTextTheme;

  /// See [PartM.mooLahLah].
  static const mooLahLah = PartM.mooLahLah;

  /// See [PartM.mooLahLahTextTheme].
  static const mooLahLahTextTheme = PartM.mooLahLahTextTheme;

  /// See [PartM.mooli].
  static const mooli = PartM.mooli;

  /// See [PartM.mooliTextTheme].
  static const mooliTextTheme = PartM.mooliTextTheme;

  /// See [PartM.moonDance].
  static const moonDance = PartM.moonDance;

  /// See [PartM.moonDanceTextTheme].
  static const moonDanceTextTheme = PartM.moonDanceTextTheme;

  /// See [PartM.moul].
  static const moul = PartM.moul;

  /// See [PartM.moulTextTheme].
  static const moulTextTheme = PartM.moulTextTheme;

  /// See [PartM.moulpali].
  static const moulpali = PartM.moulpali;

  /// See [PartM.moulpaliTextTheme].
  static const moulpaliTextTheme = PartM.moulpaliTextTheme;

  /// See [PartM.mountainsOfChristmas].
  static const mountainsOfChristmas = PartM.mountainsOfChristmas;

  /// See [PartM.mountainsOfChristmasTextTheme].
  static const mountainsOfChristmasTextTheme =
      PartM.mountainsOfChristmasTextTheme;

  /// See [PartM.mouseMemoirs].
  static const mouseMemoirs = PartM.mouseMemoirs;

  /// See [PartM.mouseMemoirsTextTheme].
  static const mouseMemoirsTextTheme = PartM.mouseMemoirsTextTheme;

  /// See [PartM.mozillaHeadline].
  static const mozillaHeadline = PartM.mozillaHeadline;

  /// See [PartM.mozillaHeadlineTextTheme].
  static const mozillaHeadlineTextTheme = PartM.mozillaHeadlineTextTheme;

  /// See [PartM.mozillaText].
  static const mozillaText = PartM.mozillaText;

  /// See [PartM.mozillaTextTextTheme].
  static const mozillaTextTextTheme = PartM.mozillaTextTextTheme;

  /// See [PartM.mrBedfort].
  static const mrBedfort = PartM.mrBedfort;

  /// See [PartM.mrBedfortTextTheme].
  static const mrBedfortTextTheme = PartM.mrBedfortTextTheme;

  /// See [PartM.mrDafoe].
  static const mrDafoe = PartM.mrDafoe;

  /// See [PartM.mrDafoeTextTheme].
  static const mrDafoeTextTheme = PartM.mrDafoeTextTheme;

  /// See [PartM.mrDeHaviland].
  static const mrDeHaviland = PartM.mrDeHaviland;

  /// See [PartM.mrDeHavilandTextTheme].
  static const mrDeHavilandTextTheme = PartM.mrDeHavilandTextTheme;

  /// See [PartM.mrsSaintDelafield].
  static const mrsSaintDelafield = PartM.mrsSaintDelafield;

  /// See [PartM.mrsSaintDelafieldTextTheme].
  static const mrsSaintDelafieldTextTheme = PartM.mrsSaintDelafieldTextTheme;

  /// See [PartM.mrsSheppards].
  static const mrsSheppards = PartM.mrsSheppards;

  /// See [PartM.mrsSheppardsTextTheme].
  static const mrsSheppardsTextTheme = PartM.mrsSheppardsTextTheme;

  /// See [PartM.msMadi].
  static const msMadi = PartM.msMadi;

  /// See [PartM.msMadiTextTheme].
  static const msMadiTextTheme = PartM.msMadiTextTheme;

  /// See [PartM.mukta].
  static const mukta = PartM.mukta;

  /// See [PartM.muktaTextTheme].
  static const muktaTextTheme = PartM.muktaTextTheme;

  /// See [PartM.muktaMahee].
  static const muktaMahee = PartM.muktaMahee;

  /// See [PartM.muktaMaheeTextTheme].
  static const muktaMaheeTextTheme = PartM.muktaMaheeTextTheme;

  /// See [PartM.muktaMalar].
  static const muktaMalar = PartM.muktaMalar;

  /// See [PartM.muktaMalarTextTheme].
  static const muktaMalarTextTheme = PartM.muktaMalarTextTheme;

  /// See [PartM.muktaVaani].
  static const muktaVaani = PartM.muktaVaani;

  /// See [PartM.muktaVaaniTextTheme].
  static const muktaVaaniTextTheme = PartM.muktaVaaniTextTheme;

  /// See [PartM.mulish].
  static const mulish = PartM.mulish;

  /// See [PartM.mulishTextTheme].
  static const mulishTextTheme = PartM.mulishTextTheme;

  /// See [PartM.murecho].
  static const murecho = PartM.murecho;

  /// See [PartM.murechoTextTheme].
  static const murechoTextTheme = PartM.murechoTextTheme;

  /// See [PartM.museoModerno].
  static const museoModerno = PartM.museoModerno;

  /// See [PartM.museoModernoTextTheme].
  static const museoModernoTextTheme = PartM.museoModernoTextTheme;

  /// See [PartM.mySoul].
  static const mySoul = PartM.mySoul;

  /// See [PartM.mySoulTextTheme].
  static const mySoulTextTheme = PartM.mySoulTextTheme;

  /// See [PartM.mynerve].
  static const mynerve = PartM.mynerve;

  /// See [PartM.mynerveTextTheme].
  static const mynerveTextTheme = PartM.mynerveTextTheme;

  /// See [PartM.mysteryQuest].
  static const mysteryQuest = PartM.mysteryQuest;

  /// See [PartM.mysteryQuestTextTheme].
  static const mysteryQuestTextTheme = PartM.mysteryQuestTextTheme;

  /// See [PartN.ntr].
  static const ntr = PartN.ntr;

  /// See [PartN.ntrTextTheme].
  static const ntrTextTheme = PartN.ntrTextTheme;

  /// See [PartN.nabla].
  static const nabla = PartN.nabla;

  /// See [PartN.nablaTextTheme].
  static const nablaTextTheme = PartN.nablaTextTheme;

  /// See [PartN.namdhinggo].
  static const namdhinggo = PartN.namdhinggo;

  /// See [PartN.namdhinggoTextTheme].
  static const namdhinggoTextTheme = PartN.namdhinggoTextTheme;

  /// See [PartN.nanumBrushScript].
  static const nanumBrushScript = PartN.nanumBrushScript;

  /// See [PartN.nanumBrushScriptTextTheme].
  static const nanumBrushScriptTextTheme = PartN.nanumBrushScriptTextTheme;

  /// See [PartN.nanumGothic].
  static const nanumGothic = PartN.nanumGothic;

  /// See [PartN.nanumGothicTextTheme].
  static const nanumGothicTextTheme = PartN.nanumGothicTextTheme;

  /// See [PartN.nanumGothicCoding].
  static const nanumGothicCoding = PartN.nanumGothicCoding;

  /// See [PartN.nanumGothicCodingTextTheme].
  static const nanumGothicCodingTextTheme = PartN.nanumGothicCodingTextTheme;

  /// See [PartN.nanumMyeongjo].
  static const nanumMyeongjo = PartN.nanumMyeongjo;

  /// See [PartN.nanumMyeongjoTextTheme].
  static const nanumMyeongjoTextTheme = PartN.nanumMyeongjoTextTheme;

  /// See [PartN.nanumPenScript].
  static const nanumPenScript = PartN.nanumPenScript;

  /// See [PartN.nanumPenScriptTextTheme].
  static const nanumPenScriptTextTheme = PartN.nanumPenScriptTextTheme;

  /// See [PartN.narnoor].
  static const narnoor = PartN.narnoor;

  /// See [PartN.narnoorTextTheme].
  static const narnoorTextTheme = PartN.narnoorTextTheme;

  /// See [PartN.nataSans].
  static const nataSans = PartN.nataSans;

  /// See [PartN.nataSansTextTheme].
  static const nataSansTextTheme = PartN.nataSansTextTheme;

  /// See [PartN.nationalPark].
  static const nationalPark = PartN.nationalPark;

  /// See [PartN.nationalParkTextTheme].
  static const nationalParkTextTheme = PartN.nationalParkTextTheme;

  /// See [PartN.neonderthaw].
  static const neonderthaw = PartN.neonderthaw;

  /// See [PartN.neonderthawTextTheme].
  static const neonderthawTextTheme = PartN.neonderthawTextTheme;

  /// See [PartN.nerkoOne].
  static const nerkoOne = PartN.nerkoOne;

  /// See [PartN.nerkoOneTextTheme].
  static const nerkoOneTextTheme = PartN.nerkoOneTextTheme;

  /// See [PartN.neucha].
  static const neucha = PartN.neucha;

  /// See [PartN.neuchaTextTheme].
  static const neuchaTextTheme = PartN.neuchaTextTheme;

  /// See [PartN.neuton].
  static const neuton = PartN.neuton;

  /// See [PartN.neutonTextTheme].
  static const neutonTextTheme = PartN.neutonTextTheme;

  /// See [PartN.newAmsterdam].
  static const newAmsterdam = PartN.newAmsterdam;

  /// See [PartN.newAmsterdamTextTheme].
  static const newAmsterdamTextTheme = PartN.newAmsterdamTextTheme;

  /// See [PartN.newRocker].
  static const newRocker = PartN.newRocker;

  /// See [PartN.newRockerTextTheme].
  static const newRockerTextTheme = PartN.newRockerTextTheme;

  /// See [PartN.newTegomin].
  static const newTegomin = PartN.newTegomin;

  /// See [PartN.newTegominTextTheme].
  static const newTegominTextTheme = PartN.newTegominTextTheme;

  /// See [PartN.newsCycle].
  static const newsCycle = PartN.newsCycle;

  /// See [PartN.newsCycleTextTheme].
  static const newsCycleTextTheme = PartN.newsCycleTextTheme;

  /// See [PartN.newsreader].
  static const newsreader = PartN.newsreader;

  /// See [PartN.newsreaderTextTheme].
  static const newsreaderTextTheme = PartN.newsreaderTextTheme;

  /// See [PartN.niconne].
  static const niconne = PartN.niconne;

  /// See [PartN.niconneTextTheme].
  static const niconneTextTheme = PartN.niconneTextTheme;

  /// See [PartN.niramit].
  static const niramit = PartN.niramit;

  /// See [PartN.niramitTextTheme].
  static const niramitTextTheme = PartN.niramitTextTheme;

  /// See [PartN.nixieOne].
  static const nixieOne = PartN.nixieOne;

  /// See [PartN.nixieOneTextTheme].
  static const nixieOneTextTheme = PartN.nixieOneTextTheme;

  /// See [PartN.nobile].
  static const nobile = PartN.nobile;

  /// See [PartN.nobileTextTheme].
  static const nobileTextTheme = PartN.nobileTextTheme;

  /// See [PartN.nokora].
  static const nokora = PartN.nokora;

  /// See [PartN.nokoraTextTheme].
  static const nokoraTextTheme = PartN.nokoraTextTheme;

  /// See [PartN.norican].
  static const norican = PartN.norican;

  /// See [PartN.noricanTextTheme].
  static const noricanTextTheme = PartN.noricanTextTheme;

  /// See [PartN.nosifer].
  static const nosifer = PartN.nosifer;

  /// See [PartN.nosiferTextTheme].
  static const nosiferTextTheme = PartN.nosiferTextTheme;

  /// See [PartN.notable].
  static const notable = PartN.notable;

  /// See [PartN.notableTextTheme].
  static const notableTextTheme = PartN.notableTextTheme;

  /// See [PartN.nothingYouCouldDo].
  static const nothingYouCouldDo = PartN.nothingYouCouldDo;

  /// See [PartN.nothingYouCouldDoTextTheme].
  static const nothingYouCouldDoTextTheme = PartN.nothingYouCouldDoTextTheme;

  /// See [PartN.noticiaText].
  static const noticiaText = PartN.noticiaText;

  /// See [PartN.noticiaTextTextTheme].
  static const noticiaTextTextTheme = PartN.noticiaTextTextTheme;

  /// See [PartN.notoColorEmoji].
  static const notoColorEmoji = PartN.notoColorEmoji;

  /// See [PartN.notoColorEmojiTextTheme].
  static const notoColorEmojiTextTheme = PartN.notoColorEmojiTextTheme;

  /// See [PartN.notoEmoji].
  static const notoEmoji = PartN.notoEmoji;

  /// See [PartN.notoEmojiTextTheme].
  static const notoEmojiTextTheme = PartN.notoEmojiTextTheme;

  /// See [PartN.notoKufiArabic].
  static const notoKufiArabic = PartN.notoKufiArabic;

  /// See [PartN.notoKufiArabicTextTheme].
  static const notoKufiArabicTextTheme = PartN.notoKufiArabicTextTheme;

  /// See [PartN.notoMusic].
  static const notoMusic = PartN.notoMusic;

  /// See [PartN.notoMusicTextTheme].
  static const notoMusicTextTheme = PartN.notoMusicTextTheme;

  /// See [PartN.notoNaskhArabic].
  static const notoNaskhArabic = PartN.notoNaskhArabic;

  /// See [PartN.notoNaskhArabicTextTheme].
  static const notoNaskhArabicTextTheme = PartN.notoNaskhArabicTextTheme;

  /// See [PartN.notoNastaliqUrdu].
  static const notoNastaliqUrdu = PartN.notoNastaliqUrdu;

  /// See [PartN.notoNastaliqUrduTextTheme].
  static const notoNastaliqUrduTextTheme = PartN.notoNastaliqUrduTextTheme;

  /// See [PartN.notoRashiHebrew].
  static const notoRashiHebrew = PartN.notoRashiHebrew;

  /// See [PartN.notoRashiHebrewTextTheme].
  static const notoRashiHebrewTextTheme = PartN.notoRashiHebrewTextTheme;

  /// See [PartN.notoSans].
  static const notoSans = PartN.notoSans;

  /// See [PartN.notoSansTextTheme].
  static const notoSansTextTheme = PartN.notoSansTextTheme;

  /// See [PartN.notoSansAdlam].
  static const notoSansAdlam = PartN.notoSansAdlam;

  /// See [PartN.notoSansAdlamTextTheme].
  static const notoSansAdlamTextTheme = PartN.notoSansAdlamTextTheme;

  /// See [PartN.notoSansAdlamUnjoined].
  static const notoSansAdlamUnjoined = PartN.notoSansAdlamUnjoined;

  /// See [PartN.notoSansAdlamUnjoinedTextTheme].
  static const notoSansAdlamUnjoinedTextTheme =
      PartN.notoSansAdlamUnjoinedTextTheme;

  /// See [PartN.notoSansAnatolianHieroglyphs].
  static const notoSansAnatolianHieroglyphs =
      PartN.notoSansAnatolianHieroglyphs;

  /// See [PartN.notoSansAnatolianHieroglyphsTextTheme].
  static const notoSansAnatolianHieroglyphsTextTheme =
      PartN.notoSansAnatolianHieroglyphsTextTheme;

  /// See [PartN.notoSansArabic].
  static const notoSansArabic = PartN.notoSansArabic;

  /// See [PartN.notoSansArabicTextTheme].
  static const notoSansArabicTextTheme = PartN.notoSansArabicTextTheme;

  /// See [PartN.notoSansArmenian].
  static const notoSansArmenian = PartN.notoSansArmenian;

  /// See [PartN.notoSansArmenianTextTheme].
  static const notoSansArmenianTextTheme = PartN.notoSansArmenianTextTheme;

  /// See [PartN.notoSansAvestan].
  static const notoSansAvestan = PartN.notoSansAvestan;

  /// See [PartN.notoSansAvestanTextTheme].
  static const notoSansAvestanTextTheme = PartN.notoSansAvestanTextTheme;

  /// See [PartN.notoSansBalinese].
  static const notoSansBalinese = PartN.notoSansBalinese;

  /// See [PartN.notoSansBalineseTextTheme].
  static const notoSansBalineseTextTheme = PartN.notoSansBalineseTextTheme;

  /// See [PartN.notoSansBamum].
  static const notoSansBamum = PartN.notoSansBamum;

  /// See [PartN.notoSansBamumTextTheme].
  static const notoSansBamumTextTheme = PartN.notoSansBamumTextTheme;

  /// See [PartN.notoSansBassaVah].
  static const notoSansBassaVah = PartN.notoSansBassaVah;

  /// See [PartN.notoSansBassaVahTextTheme].
  static const notoSansBassaVahTextTheme = PartN.notoSansBassaVahTextTheme;

  /// See [PartN.notoSansBatak].
  static const notoSansBatak = PartN.notoSansBatak;

  /// See [PartN.notoSansBatakTextTheme].
  static const notoSansBatakTextTheme = PartN.notoSansBatakTextTheme;

  /// See [PartN.notoSansBengali].
  static const notoSansBengali = PartN.notoSansBengali;

  /// See [PartN.notoSansBengaliTextTheme].
  static const notoSansBengaliTextTheme = PartN.notoSansBengaliTextTheme;

  /// See [PartN.notoSansBhaiksuki].
  static const notoSansBhaiksuki = PartN.notoSansBhaiksuki;

  /// See [PartN.notoSansBhaiksukiTextTheme].
  static const notoSansBhaiksukiTextTheme = PartN.notoSansBhaiksukiTextTheme;

  /// See [PartN.notoSansBrahmi].
  static const notoSansBrahmi = PartN.notoSansBrahmi;

  /// See [PartN.notoSansBrahmiTextTheme].
  static const notoSansBrahmiTextTheme = PartN.notoSansBrahmiTextTheme;

  /// See [PartN.notoSansBuginese].
  static const notoSansBuginese = PartN.notoSansBuginese;

  /// See [PartN.notoSansBugineseTextTheme].
  static const notoSansBugineseTextTheme = PartN.notoSansBugineseTextTheme;

  /// See [PartN.notoSansBuhid].
  static const notoSansBuhid = PartN.notoSansBuhid;

  /// See [PartN.notoSansBuhidTextTheme].
  static const notoSansBuhidTextTheme = PartN.notoSansBuhidTextTheme;

  /// See [PartN.notoSansCanadianAboriginal].
  static const notoSansCanadianAboriginal = PartN.notoSansCanadianAboriginal;

  /// See [PartN.notoSansCanadianAboriginalTextTheme].
  static const notoSansCanadianAboriginalTextTheme =
      PartN.notoSansCanadianAboriginalTextTheme;

  /// See [PartN.notoSansCarian].
  static const notoSansCarian = PartN.notoSansCarian;

  /// See [PartN.notoSansCarianTextTheme].
  static const notoSansCarianTextTheme = PartN.notoSansCarianTextTheme;

  /// See [PartN.notoSansCaucasianAlbanian].
  static const notoSansCaucasianAlbanian = PartN.notoSansCaucasianAlbanian;

  /// See [PartN.notoSansCaucasianAlbanianTextTheme].
  static const notoSansCaucasianAlbanianTextTheme =
      PartN.notoSansCaucasianAlbanianTextTheme;

  /// See [PartN.notoSansChakma].
  static const notoSansChakma = PartN.notoSansChakma;

  /// See [PartN.notoSansChakmaTextTheme].
  static const notoSansChakmaTextTheme = PartN.notoSansChakmaTextTheme;

  /// See [PartN.notoSansCham].
  static const notoSansCham = PartN.notoSansCham;

  /// See [PartN.notoSansChamTextTheme].
  static const notoSansChamTextTheme = PartN.notoSansChamTextTheme;

  /// See [PartN.notoSansCherokee].
  static const notoSansCherokee = PartN.notoSansCherokee;

  /// See [PartN.notoSansCherokeeTextTheme].
  static const notoSansCherokeeTextTheme = PartN.notoSansCherokeeTextTheme;

  /// See [PartN.notoSansChorasmian].
  static const notoSansChorasmian = PartN.notoSansChorasmian;

  /// See [PartN.notoSansChorasmianTextTheme].
  static const notoSansChorasmianTextTheme = PartN.notoSansChorasmianTextTheme;

  /// See [PartN.notoSansCoptic].
  static const notoSansCoptic = PartN.notoSansCoptic;

  /// See [PartN.notoSansCopticTextTheme].
  static const notoSansCopticTextTheme = PartN.notoSansCopticTextTheme;

  /// See [PartN.notoSansCuneiform].
  static const notoSansCuneiform = PartN.notoSansCuneiform;

  /// See [PartN.notoSansCuneiformTextTheme].
  static const notoSansCuneiformTextTheme = PartN.notoSansCuneiformTextTheme;

  /// See [PartN.notoSansCypriot].
  static const notoSansCypriot = PartN.notoSansCypriot;

  /// See [PartN.notoSansCypriotTextTheme].
  static const notoSansCypriotTextTheme = PartN.notoSansCypriotTextTheme;

  /// See [PartN.notoSansCyproMinoan].
  static const notoSansCyproMinoan = PartN.notoSansCyproMinoan;

  /// See [PartN.notoSansCyproMinoanTextTheme].
  static const notoSansCyproMinoanTextTheme =
      PartN.notoSansCyproMinoanTextTheme;

  /// See [PartN.notoSansDeseret].
  static const notoSansDeseret = PartN.notoSansDeseret;

  /// See [PartN.notoSansDeseretTextTheme].
  static const notoSansDeseretTextTheme = PartN.notoSansDeseretTextTheme;

  /// See [PartN.notoSansDevanagari].
  static const notoSansDevanagari = PartN.notoSansDevanagari;

  /// See [PartN.notoSansDevanagariTextTheme].
  static const notoSansDevanagariTextTheme = PartN.notoSansDevanagariTextTheme;

  /// See [PartN.notoSansDisplay].
  static const notoSansDisplay = PartN.notoSansDisplay;

  /// See [PartN.notoSansDisplayTextTheme].
  static const notoSansDisplayTextTheme = PartN.notoSansDisplayTextTheme;

  /// See [PartN.notoSansDuployan].
  static const notoSansDuployan = PartN.notoSansDuployan;

  /// See [PartN.notoSansDuployanTextTheme].
  static const notoSansDuployanTextTheme = PartN.notoSansDuployanTextTheme;

  /// See [PartN.notoSansEgyptianHieroglyphs].
  static const notoSansEgyptianHieroglyphs = PartN.notoSansEgyptianHieroglyphs;

  /// See [PartN.notoSansEgyptianHieroglyphsTextTheme].
  static const notoSansEgyptianHieroglyphsTextTheme =
      PartN.notoSansEgyptianHieroglyphsTextTheme;

  /// See [PartN.notoSansElbasan].
  static const notoSansElbasan = PartN.notoSansElbasan;

  /// See [PartN.notoSansElbasanTextTheme].
  static const notoSansElbasanTextTheme = PartN.notoSansElbasanTextTheme;

  /// See [PartN.notoSansElymaic].
  static const notoSansElymaic = PartN.notoSansElymaic;

  /// See [PartN.notoSansElymaicTextTheme].
  static const notoSansElymaicTextTheme = PartN.notoSansElymaicTextTheme;

  /// See [PartN.notoSansEthiopic].
  static const notoSansEthiopic = PartN.notoSansEthiopic;

  /// See [PartN.notoSansEthiopicTextTheme].
  static const notoSansEthiopicTextTheme = PartN.notoSansEthiopicTextTheme;

  /// See [PartN.notoSansGeorgian].
  static const notoSansGeorgian = PartN.notoSansGeorgian;

  /// See [PartN.notoSansGeorgianTextTheme].
  static const notoSansGeorgianTextTheme = PartN.notoSansGeorgianTextTheme;

  /// See [PartN.notoSansGlagolitic].
  static const notoSansGlagolitic = PartN.notoSansGlagolitic;

  /// See [PartN.notoSansGlagoliticTextTheme].
  static const notoSansGlagoliticTextTheme = PartN.notoSansGlagoliticTextTheme;

  /// See [PartN.notoSansGothic].
  static const notoSansGothic = PartN.notoSansGothic;

  /// See [PartN.notoSansGothicTextTheme].
  static const notoSansGothicTextTheme = PartN.notoSansGothicTextTheme;

  /// See [PartN.notoSansGrantha].
  static const notoSansGrantha = PartN.notoSansGrantha;

  /// See [PartN.notoSansGranthaTextTheme].
  static const notoSansGranthaTextTheme = PartN.notoSansGranthaTextTheme;

  /// See [PartN.notoSansGujarati].
  static const notoSansGujarati = PartN.notoSansGujarati;

  /// See [PartN.notoSansGujaratiTextTheme].
  static const notoSansGujaratiTextTheme = PartN.notoSansGujaratiTextTheme;

  /// See [PartN.notoSansGunjalaGondi].
  static const notoSansGunjalaGondi = PartN.notoSansGunjalaGondi;

  /// See [PartN.notoSansGunjalaGondiTextTheme].
  static const notoSansGunjalaGondiTextTheme =
      PartN.notoSansGunjalaGondiTextTheme;

  /// See [PartN.notoSansGurmukhi].
  static const notoSansGurmukhi = PartN.notoSansGurmukhi;

  /// See [PartN.notoSansGurmukhiTextTheme].
  static const notoSansGurmukhiTextTheme = PartN.notoSansGurmukhiTextTheme;

  /// See [PartN.notoSansHk].
  static const notoSansHk = PartN.notoSansHk;

  /// See [PartN.notoSansHkTextTheme].
  static const notoSansHkTextTheme = PartN.notoSansHkTextTheme;

  /// See [PartN.notoSansHanifiRohingya].
  static const notoSansHanifiRohingya = PartN.notoSansHanifiRohingya;

  /// See [PartN.notoSansHanifiRohingyaTextTheme].
  static const notoSansHanifiRohingyaTextTheme =
      PartN.notoSansHanifiRohingyaTextTheme;

  /// See [PartN.notoSansHanunoo].
  static const notoSansHanunoo = PartN.notoSansHanunoo;

  /// See [PartN.notoSansHanunooTextTheme].
  static const notoSansHanunooTextTheme = PartN.notoSansHanunooTextTheme;

  /// See [PartN.notoSansHatran].
  static const notoSansHatran = PartN.notoSansHatran;

  /// See [PartN.notoSansHatranTextTheme].
  static const notoSansHatranTextTheme = PartN.notoSansHatranTextTheme;

  /// See [PartN.notoSansHebrew].
  static const notoSansHebrew = PartN.notoSansHebrew;

  /// See [PartN.notoSansHebrewTextTheme].
  static const notoSansHebrewTextTheme = PartN.notoSansHebrewTextTheme;

  /// See [PartN.notoSansImperialAramaic].
  static const notoSansImperialAramaic = PartN.notoSansImperialAramaic;

  /// See [PartN.notoSansImperialAramaicTextTheme].
  static const notoSansImperialAramaicTextTheme =
      PartN.notoSansImperialAramaicTextTheme;

  /// See [PartN.notoSansIndicSiyaqNumbers].
  static const notoSansIndicSiyaqNumbers = PartN.notoSansIndicSiyaqNumbers;

  /// See [PartN.notoSansIndicSiyaqNumbersTextTheme].
  static const notoSansIndicSiyaqNumbersTextTheme =
      PartN.notoSansIndicSiyaqNumbersTextTheme;

  /// See [PartN.notoSansInscriptionalPahlavi].
  static const notoSansInscriptionalPahlavi =
      PartN.notoSansInscriptionalPahlavi;

  /// See [PartN.notoSansInscriptionalPahlaviTextTheme].
  static const notoSansInscriptionalPahlaviTextTheme =
      PartN.notoSansInscriptionalPahlaviTextTheme;

  /// See [PartN.notoSansInscriptionalParthian].
  static const notoSansInscriptionalParthian =
      PartN.notoSansInscriptionalParthian;

  /// See [PartN.notoSansInscriptionalParthianTextTheme].
  static const notoSansInscriptionalParthianTextTheme =
      PartN.notoSansInscriptionalParthianTextTheme;

  /// See [PartN.notoSansJp].
  static const notoSansJp = PartN.notoSansJp;

  /// See [PartN.notoSansJpTextTheme].
  static const notoSansJpTextTheme = PartN.notoSansJpTextTheme;

  /// See [PartN.notoSansJavanese].
  static const notoSansJavanese = PartN.notoSansJavanese;

  /// See [PartN.notoSansJavaneseTextTheme].
  static const notoSansJavaneseTextTheme = PartN.notoSansJavaneseTextTheme;

  /// See [PartN.notoSansKr].
  static const notoSansKr = PartN.notoSansKr;

  /// See [PartN.notoSansKrTextTheme].
  static const notoSansKrTextTheme = PartN.notoSansKrTextTheme;

  /// See [PartN.notoSansKaithi].
  static const notoSansKaithi = PartN.notoSansKaithi;

  /// See [PartN.notoSansKaithiTextTheme].
  static const notoSansKaithiTextTheme = PartN.notoSansKaithiTextTheme;

  /// See [PartN.notoSansKannada].
  static const notoSansKannada = PartN.notoSansKannada;

  /// See [PartN.notoSansKannadaTextTheme].
  static const notoSansKannadaTextTheme = PartN.notoSansKannadaTextTheme;

  /// See [PartN.notoSansKawi].
  static const notoSansKawi = PartN.notoSansKawi;

  /// See [PartN.notoSansKawiTextTheme].
  static const notoSansKawiTextTheme = PartN.notoSansKawiTextTheme;

  /// See [PartN.notoSansKayahLi].
  static const notoSansKayahLi = PartN.notoSansKayahLi;

  /// See [PartN.notoSansKayahLiTextTheme].
  static const notoSansKayahLiTextTheme = PartN.notoSansKayahLiTextTheme;

  /// See [PartN.notoSansKharoshthi].
  static const notoSansKharoshthi = PartN.notoSansKharoshthi;

  /// See [PartN.notoSansKharoshthiTextTheme].
  static const notoSansKharoshthiTextTheme = PartN.notoSansKharoshthiTextTheme;

  /// See [PartN.notoSansKhmer].
  static const notoSansKhmer = PartN.notoSansKhmer;

  /// See [PartN.notoSansKhmerTextTheme].
  static const notoSansKhmerTextTheme = PartN.notoSansKhmerTextTheme;

  /// See [PartN.notoSansKhojki].
  static const notoSansKhojki = PartN.notoSansKhojki;

  /// See [PartN.notoSansKhojkiTextTheme].
  static const notoSansKhojkiTextTheme = PartN.notoSansKhojkiTextTheme;

  /// See [PartN.notoSansKhudawadi].
  static const notoSansKhudawadi = PartN.notoSansKhudawadi;

  /// See [PartN.notoSansKhudawadiTextTheme].
  static const notoSansKhudawadiTextTheme = PartN.notoSansKhudawadiTextTheme;

  /// See [PartN.notoSansLao].
  static const notoSansLao = PartN.notoSansLao;

  /// See [PartN.notoSansLaoTextTheme].
  static const notoSansLaoTextTheme = PartN.notoSansLaoTextTheme;

  /// See [PartN.notoSansLaoLooped].
  static const notoSansLaoLooped = PartN.notoSansLaoLooped;

  /// See [PartN.notoSansLaoLoopedTextTheme].
  static const notoSansLaoLoopedTextTheme = PartN.notoSansLaoLoopedTextTheme;

  /// See [PartN.notoSansLepcha].
  static const notoSansLepcha = PartN.notoSansLepcha;

  /// See [PartN.notoSansLepchaTextTheme].
  static const notoSansLepchaTextTheme = PartN.notoSansLepchaTextTheme;

  /// See [PartN.notoSansLimbu].
  static const notoSansLimbu = PartN.notoSansLimbu;

  /// See [PartN.notoSansLimbuTextTheme].
  static const notoSansLimbuTextTheme = PartN.notoSansLimbuTextTheme;

  /// See [PartN.notoSansLinearA].
  static const notoSansLinearA = PartN.notoSansLinearA;

  /// See [PartN.notoSansLinearATextTheme].
  static const notoSansLinearATextTheme = PartN.notoSansLinearATextTheme;

  /// See [PartN.notoSansLinearB].
  static const notoSansLinearB = PartN.notoSansLinearB;

  /// See [PartN.notoSansLinearBTextTheme].
  static const notoSansLinearBTextTheme = PartN.notoSansLinearBTextTheme;

  /// See [PartN.notoSansLisu].
  static const notoSansLisu = PartN.notoSansLisu;

  /// See [PartN.notoSansLisuTextTheme].
  static const notoSansLisuTextTheme = PartN.notoSansLisuTextTheme;

  /// See [PartN.notoSansLycian].
  static const notoSansLycian = PartN.notoSansLycian;

  /// See [PartN.notoSansLycianTextTheme].
  static const notoSansLycianTextTheme = PartN.notoSansLycianTextTheme;

  /// See [PartN.notoSansLydian].
  static const notoSansLydian = PartN.notoSansLydian;

  /// See [PartN.notoSansLydianTextTheme].
  static const notoSansLydianTextTheme = PartN.notoSansLydianTextTheme;

  /// See [PartN.notoSansMahajani].
  static const notoSansMahajani = PartN.notoSansMahajani;

  /// See [PartN.notoSansMahajaniTextTheme].
  static const notoSansMahajaniTextTheme = PartN.notoSansMahajaniTextTheme;

  /// See [PartN.notoSansMalayalam].
  static const notoSansMalayalam = PartN.notoSansMalayalam;

  /// See [PartN.notoSansMalayalamTextTheme].
  static const notoSansMalayalamTextTheme = PartN.notoSansMalayalamTextTheme;

  /// See [PartN.notoSansMandaic].
  static const notoSansMandaic = PartN.notoSansMandaic;

  /// See [PartN.notoSansMandaicTextTheme].
  static const notoSansMandaicTextTheme = PartN.notoSansMandaicTextTheme;

  /// See [PartN.notoSansManichaean].
  static const notoSansManichaean = PartN.notoSansManichaean;

  /// See [PartN.notoSansManichaeanTextTheme].
  static const notoSansManichaeanTextTheme = PartN.notoSansManichaeanTextTheme;

  /// See [PartN.notoSansMarchen].
  static const notoSansMarchen = PartN.notoSansMarchen;

  /// See [PartN.notoSansMarchenTextTheme].
  static const notoSansMarchenTextTheme = PartN.notoSansMarchenTextTheme;

  /// See [PartN.notoSansMasaramGondi].
  static const notoSansMasaramGondi = PartN.notoSansMasaramGondi;

  /// See [PartN.notoSansMasaramGondiTextTheme].
  static const notoSansMasaramGondiTextTheme =
      PartN.notoSansMasaramGondiTextTheme;

  /// See [PartN.notoSansMath].
  static const notoSansMath = PartN.notoSansMath;

  /// See [PartN.notoSansMathTextTheme].
  static const notoSansMathTextTheme = PartN.notoSansMathTextTheme;

  /// See [PartN.notoSansMayanNumerals].
  static const notoSansMayanNumerals = PartN.notoSansMayanNumerals;

  /// See [PartN.notoSansMayanNumeralsTextTheme].
  static const notoSansMayanNumeralsTextTheme =
      PartN.notoSansMayanNumeralsTextTheme;

  /// See [PartN.notoSansMedefaidrin].
  static const notoSansMedefaidrin = PartN.notoSansMedefaidrin;

  /// See [PartN.notoSansMedefaidrinTextTheme].
  static const notoSansMedefaidrinTextTheme =
      PartN.notoSansMedefaidrinTextTheme;

  /// See [PartN.notoSansMeeteiMayek].
  static const notoSansMeeteiMayek = PartN.notoSansMeeteiMayek;

  /// See [PartN.notoSansMeeteiMayekTextTheme].
  static const notoSansMeeteiMayekTextTheme =
      PartN.notoSansMeeteiMayekTextTheme;

  /// See [PartN.notoSansMendeKikakui].
  static const notoSansMendeKikakui = PartN.notoSansMendeKikakui;

  /// See [PartN.notoSansMendeKikakuiTextTheme].
  static const notoSansMendeKikakuiTextTheme =
      PartN.notoSansMendeKikakuiTextTheme;

  /// See [PartN.notoSansMeroitic].
  static const notoSansMeroitic = PartN.notoSansMeroitic;

  /// See [PartN.notoSansMeroiticTextTheme].
  static const notoSansMeroiticTextTheme = PartN.notoSansMeroiticTextTheme;

  /// See [PartN.notoSansMiao].
  static const notoSansMiao = PartN.notoSansMiao;

  /// See [PartN.notoSansMiaoTextTheme].
  static const notoSansMiaoTextTheme = PartN.notoSansMiaoTextTheme;

  /// See [PartN.notoSansModi].
  static const notoSansModi = PartN.notoSansModi;

  /// See [PartN.notoSansModiTextTheme].
  static const notoSansModiTextTheme = PartN.notoSansModiTextTheme;

  /// See [PartN.notoSansMongolian].
  static const notoSansMongolian = PartN.notoSansMongolian;

  /// See [PartN.notoSansMongolianTextTheme].
  static const notoSansMongolianTextTheme = PartN.notoSansMongolianTextTheme;

  /// See [PartN.notoSansMono].
  static const notoSansMono = PartN.notoSansMono;

  /// See [PartN.notoSansMonoTextTheme].
  static const notoSansMonoTextTheme = PartN.notoSansMonoTextTheme;

  /// See [PartN.notoSansMro].
  static const notoSansMro = PartN.notoSansMro;

  /// See [PartN.notoSansMroTextTheme].
  static const notoSansMroTextTheme = PartN.notoSansMroTextTheme;

  /// See [PartN.notoSansMultani].
  static const notoSansMultani = PartN.notoSansMultani;

  /// See [PartN.notoSansMultaniTextTheme].
  static const notoSansMultaniTextTheme = PartN.notoSansMultaniTextTheme;

  /// See [PartN.notoSansMyanmar].
  static const notoSansMyanmar = PartN.notoSansMyanmar;

  /// See [PartN.notoSansMyanmarTextTheme].
  static const notoSansMyanmarTextTheme = PartN.notoSansMyanmarTextTheme;

  /// See [PartN.notoSansNKo].
  static const notoSansNKo = PartN.notoSansNKo;

  /// See [PartN.notoSansNKoTextTheme].
  static const notoSansNKoTextTheme = PartN.notoSansNKoTextTheme;

  /// See [PartN.notoSansNKoUnjoined].
  static const notoSansNKoUnjoined = PartN.notoSansNKoUnjoined;

  /// See [PartN.notoSansNKoUnjoinedTextTheme].
  static const notoSansNKoUnjoinedTextTheme =
      PartN.notoSansNKoUnjoinedTextTheme;

  /// See [PartN.notoSansNabataean].
  static const notoSansNabataean = PartN.notoSansNabataean;

  /// See [PartN.notoSansNabataeanTextTheme].
  static const notoSansNabataeanTextTheme = PartN.notoSansNabataeanTextTheme;

  /// See [PartN.notoSansNagMundari].
  static const notoSansNagMundari = PartN.notoSansNagMundari;

  /// See [PartN.notoSansNagMundariTextTheme].
  static const notoSansNagMundariTextTheme = PartN.notoSansNagMundariTextTheme;

  /// See [PartN.notoSansNandinagari].
  static const notoSansNandinagari = PartN.notoSansNandinagari;

  /// See [PartN.notoSansNandinagariTextTheme].
  static const notoSansNandinagariTextTheme =
      PartN.notoSansNandinagariTextTheme;

  /// See [PartN.notoSansNewTaiLue].
  static const notoSansNewTaiLue = PartN.notoSansNewTaiLue;

  /// See [PartN.notoSansNewTaiLueTextTheme].
  static const notoSansNewTaiLueTextTheme = PartN.notoSansNewTaiLueTextTheme;

  /// See [PartN.notoSansNewa].
  static const notoSansNewa = PartN.notoSansNewa;

  /// See [PartN.notoSansNewaTextTheme].
  static const notoSansNewaTextTheme = PartN.notoSansNewaTextTheme;

  /// See [PartN.notoSansNushu].
  static const notoSansNushu = PartN.notoSansNushu;

  /// See [PartN.notoSansNushuTextTheme].
  static const notoSansNushuTextTheme = PartN.notoSansNushuTextTheme;

  /// See [PartN.notoSansOgham].
  static const notoSansOgham = PartN.notoSansOgham;

  /// See [PartN.notoSansOghamTextTheme].
  static const notoSansOghamTextTheme = PartN.notoSansOghamTextTheme;

  /// See [PartN.notoSansOlChiki].
  static const notoSansOlChiki = PartN.notoSansOlChiki;

  /// See [PartN.notoSansOlChikiTextTheme].
  static const notoSansOlChikiTextTheme = PartN.notoSansOlChikiTextTheme;

  /// See [PartN.notoSansOldHungarian].
  static const notoSansOldHungarian = PartN.notoSansOldHungarian;

  /// See [PartN.notoSansOldHungarianTextTheme].
  static const notoSansOldHungarianTextTheme =
      PartN.notoSansOldHungarianTextTheme;

  /// See [PartN.notoSansOldItalic].
  static const notoSansOldItalic = PartN.notoSansOldItalic;

  /// See [PartN.notoSansOldItalicTextTheme].
  static const notoSansOldItalicTextTheme = PartN.notoSansOldItalicTextTheme;

  /// See [PartN.notoSansOldNorthArabian].
  static const notoSansOldNorthArabian = PartN.notoSansOldNorthArabian;

  /// See [PartN.notoSansOldNorthArabianTextTheme].
  static const notoSansOldNorthArabianTextTheme =
      PartN.notoSansOldNorthArabianTextTheme;

  /// See [PartN.notoSansOldPermic].
  static const notoSansOldPermic = PartN.notoSansOldPermic;

  /// See [PartN.notoSansOldPermicTextTheme].
  static const notoSansOldPermicTextTheme = PartN.notoSansOldPermicTextTheme;

  /// See [PartN.notoSansOldPersian].
  static const notoSansOldPersian = PartN.notoSansOldPersian;

  /// See [PartN.notoSansOldPersianTextTheme].
  static const notoSansOldPersianTextTheme = PartN.notoSansOldPersianTextTheme;

  /// See [PartN.notoSansOldSogdian].
  static const notoSansOldSogdian = PartN.notoSansOldSogdian;

  /// See [PartN.notoSansOldSogdianTextTheme].
  static const notoSansOldSogdianTextTheme = PartN.notoSansOldSogdianTextTheme;

  /// See [PartN.notoSansOldSouthArabian].
  static const notoSansOldSouthArabian = PartN.notoSansOldSouthArabian;

  /// See [PartN.notoSansOldSouthArabianTextTheme].
  static const notoSansOldSouthArabianTextTheme =
      PartN.notoSansOldSouthArabianTextTheme;

  /// See [PartN.notoSansOldTurkic].
  static const notoSansOldTurkic = PartN.notoSansOldTurkic;

  /// See [PartN.notoSansOldTurkicTextTheme].
  static const notoSansOldTurkicTextTheme = PartN.notoSansOldTurkicTextTheme;

  /// See [PartN.notoSansOriya].
  static const notoSansOriya = PartN.notoSansOriya;

  /// See [PartN.notoSansOriyaTextTheme].
  static const notoSansOriyaTextTheme = PartN.notoSansOriyaTextTheme;

  /// See [PartN.notoSansOsage].
  static const notoSansOsage = PartN.notoSansOsage;

  /// See [PartN.notoSansOsageTextTheme].
  static const notoSansOsageTextTheme = PartN.notoSansOsageTextTheme;

  /// See [PartN.notoSansOsmanya].
  static const notoSansOsmanya = PartN.notoSansOsmanya;

  /// See [PartN.notoSansOsmanyaTextTheme].
  static const notoSansOsmanyaTextTheme = PartN.notoSansOsmanyaTextTheme;

  /// See [PartN.notoSansPahawhHmong].
  static const notoSansPahawhHmong = PartN.notoSansPahawhHmong;

  /// See [PartN.notoSansPahawhHmongTextTheme].
  static const notoSansPahawhHmongTextTheme =
      PartN.notoSansPahawhHmongTextTheme;

  /// See [PartN.notoSansPalmyrene].
  static const notoSansPalmyrene = PartN.notoSansPalmyrene;

  /// See [PartN.notoSansPalmyreneTextTheme].
  static const notoSansPalmyreneTextTheme = PartN.notoSansPalmyreneTextTheme;

  /// See [PartN.notoSansPauCinHau].
  static const notoSansPauCinHau = PartN.notoSansPauCinHau;

  /// See [PartN.notoSansPauCinHauTextTheme].
  static const notoSansPauCinHauTextTheme = PartN.notoSansPauCinHauTextTheme;

  /// See [PartN.notoSansPhagsPa].
  static const notoSansPhagsPa = PartN.notoSansPhagsPa;

  /// See [PartN.notoSansPhagsPaTextTheme].
  static const notoSansPhagsPaTextTheme = PartN.notoSansPhagsPaTextTheme;

  /// See [PartN.notoSansPhoenician].
  static const notoSansPhoenician = PartN.notoSansPhoenician;

  /// See [PartN.notoSansPhoenicianTextTheme].
  static const notoSansPhoenicianTextTheme = PartN.notoSansPhoenicianTextTheme;

  /// See [PartN.notoSansPsalterPahlavi].
  static const notoSansPsalterPahlavi = PartN.notoSansPsalterPahlavi;

  /// See [PartN.notoSansPsalterPahlaviTextTheme].
  static const notoSansPsalterPahlaviTextTheme =
      PartN.notoSansPsalterPahlaviTextTheme;

  /// See [PartN.notoSansRejang].
  static const notoSansRejang = PartN.notoSansRejang;

  /// See [PartN.notoSansRejangTextTheme].
  static const notoSansRejangTextTheme = PartN.notoSansRejangTextTheme;

  /// See [PartN.notoSansRunic].
  static const notoSansRunic = PartN.notoSansRunic;

  /// See [PartN.notoSansRunicTextTheme].
  static const notoSansRunicTextTheme = PartN.notoSansRunicTextTheme;

  /// See [PartN.notoSansSc].
  static const notoSansSc = PartN.notoSansSc;

  /// See [PartN.notoSansScTextTheme].
  static const notoSansScTextTheme = PartN.notoSansScTextTheme;

  /// See [PartN.notoSansSamaritan].
  static const notoSansSamaritan = PartN.notoSansSamaritan;

  /// See [PartN.notoSansSamaritanTextTheme].
  static const notoSansSamaritanTextTheme = PartN.notoSansSamaritanTextTheme;

  /// See [PartN.notoSansSaurashtra].
  static const notoSansSaurashtra = PartN.notoSansSaurashtra;

  /// See [PartN.notoSansSaurashtraTextTheme].
  static const notoSansSaurashtraTextTheme = PartN.notoSansSaurashtraTextTheme;

  /// See [PartN.notoSansSharada].
  static const notoSansSharada = PartN.notoSansSharada;

  /// See [PartN.notoSansSharadaTextTheme].
  static const notoSansSharadaTextTheme = PartN.notoSansSharadaTextTheme;

  /// See [PartN.notoSansShavian].
  static const notoSansShavian = PartN.notoSansShavian;

  /// See [PartN.notoSansShavianTextTheme].
  static const notoSansShavianTextTheme = PartN.notoSansShavianTextTheme;

  /// See [PartN.notoSansSiddham].
  static const notoSansSiddham = PartN.notoSansSiddham;

  /// See [PartN.notoSansSiddhamTextTheme].
  static const notoSansSiddhamTextTheme = PartN.notoSansSiddhamTextTheme;

  /// See [PartN.notoSansSignWriting].
  static const notoSansSignWriting = PartN.notoSansSignWriting;

  /// See [PartN.notoSansSignWritingTextTheme].
  static const notoSansSignWritingTextTheme =
      PartN.notoSansSignWritingTextTheme;

  /// See [PartN.notoSansSinhala].
  static const notoSansSinhala = PartN.notoSansSinhala;

  /// See [PartN.notoSansSinhalaTextTheme].
  static const notoSansSinhalaTextTheme = PartN.notoSansSinhalaTextTheme;

  /// See [PartN.notoSansSogdian].
  static const notoSansSogdian = PartN.notoSansSogdian;

  /// See [PartN.notoSansSogdianTextTheme].
  static const notoSansSogdianTextTheme = PartN.notoSansSogdianTextTheme;

  /// See [PartN.notoSansSoraSompeng].
  static const notoSansSoraSompeng = PartN.notoSansSoraSompeng;

  /// See [PartN.notoSansSoraSompengTextTheme].
  static const notoSansSoraSompengTextTheme =
      PartN.notoSansSoraSompengTextTheme;

  /// See [PartN.notoSansSoyombo].
  static const notoSansSoyombo = PartN.notoSansSoyombo;

  /// See [PartN.notoSansSoyomboTextTheme].
  static const notoSansSoyomboTextTheme = PartN.notoSansSoyomboTextTheme;

  /// See [PartN.notoSansSundanese].
  static const notoSansSundanese = PartN.notoSansSundanese;

  /// See [PartN.notoSansSundaneseTextTheme].
  static const notoSansSundaneseTextTheme = PartN.notoSansSundaneseTextTheme;

  /// See [PartN.notoSansSunuwar].
  static const notoSansSunuwar = PartN.notoSansSunuwar;

  /// See [PartN.notoSansSunuwarTextTheme].
  static const notoSansSunuwarTextTheme = PartN.notoSansSunuwarTextTheme;

  /// See [PartN.notoSansSylotiNagri].
  static const notoSansSylotiNagri = PartN.notoSansSylotiNagri;

  /// See [PartN.notoSansSylotiNagriTextTheme].
  static const notoSansSylotiNagriTextTheme =
      PartN.notoSansSylotiNagriTextTheme;

  /// See [PartN.notoSansSymbols].
  static const notoSansSymbols = PartN.notoSansSymbols;

  /// See [PartN.notoSansSymbolsTextTheme].
  static const notoSansSymbolsTextTheme = PartN.notoSansSymbolsTextTheme;

  /// See [PartN.notoSansSymbols2].
  static const notoSansSymbols2 = PartN.notoSansSymbols2;

  /// See [PartN.notoSansSymbols2TextTheme].
  static const notoSansSymbols2TextTheme = PartN.notoSansSymbols2TextTheme;

  /// See [PartN.notoSansSyriac].
  static const notoSansSyriac = PartN.notoSansSyriac;

  /// See [PartN.notoSansSyriacTextTheme].
  static const notoSansSyriacTextTheme = PartN.notoSansSyriacTextTheme;

  /// See [PartN.notoSansSyriacEastern].
  static const notoSansSyriacEastern = PartN.notoSansSyriacEastern;

  /// See [PartN.notoSansSyriacEasternTextTheme].
  static const notoSansSyriacEasternTextTheme =
      PartN.notoSansSyriacEasternTextTheme;

  /// See [PartN.notoSansTc].
  static const notoSansTc = PartN.notoSansTc;

  /// See [PartN.notoSansTcTextTheme].
  static const notoSansTcTextTheme = PartN.notoSansTcTextTheme;

  /// See [PartN.notoSansTagalog].
  static const notoSansTagalog = PartN.notoSansTagalog;

  /// See [PartN.notoSansTagalogTextTheme].
  static const notoSansTagalogTextTheme = PartN.notoSansTagalogTextTheme;

  /// See [PartN.notoSansTagbanwa].
  static const notoSansTagbanwa = PartN.notoSansTagbanwa;

  /// See [PartN.notoSansTagbanwaTextTheme].
  static const notoSansTagbanwaTextTheme = PartN.notoSansTagbanwaTextTheme;

  /// See [PartN.notoSansTaiLe].
  static const notoSansTaiLe = PartN.notoSansTaiLe;

  /// See [PartN.notoSansTaiLeTextTheme].
  static const notoSansTaiLeTextTheme = PartN.notoSansTaiLeTextTheme;

  /// See [PartN.notoSansTaiTham].
  static const notoSansTaiTham = PartN.notoSansTaiTham;

  /// See [PartN.notoSansTaiThamTextTheme].
  static const notoSansTaiThamTextTheme = PartN.notoSansTaiThamTextTheme;

  /// See [PartN.notoSansTaiViet].
  static const notoSansTaiViet = PartN.notoSansTaiViet;

  /// See [PartN.notoSansTaiVietTextTheme].
  static const notoSansTaiVietTextTheme = PartN.notoSansTaiVietTextTheme;

  /// See [PartN.notoSansTakri].
  static const notoSansTakri = PartN.notoSansTakri;

  /// See [PartN.notoSansTakriTextTheme].
  static const notoSansTakriTextTheme = PartN.notoSansTakriTextTheme;

  /// See [PartN.notoSansTamil].
  static const notoSansTamil = PartN.notoSansTamil;

  /// See [PartN.notoSansTamilTextTheme].
  static const notoSansTamilTextTheme = PartN.notoSansTamilTextTheme;

  /// See [PartN.notoSansTamilSupplement].
  static const notoSansTamilSupplement = PartN.notoSansTamilSupplement;

  /// See [PartN.notoSansTamilSupplementTextTheme].
  static const notoSansTamilSupplementTextTheme =
      PartN.notoSansTamilSupplementTextTheme;

  /// See [PartN.notoSansTangsa].
  static const notoSansTangsa = PartN.notoSansTangsa;

  /// See [PartN.notoSansTangsaTextTheme].
  static const notoSansTangsaTextTheme = PartN.notoSansTangsaTextTheme;

  /// See [PartN.notoSansTelugu].
  static const notoSansTelugu = PartN.notoSansTelugu;

  /// See [PartN.notoSansTeluguTextTheme].
  static const notoSansTeluguTextTheme = PartN.notoSansTeluguTextTheme;

  /// See [PartN.notoSansThaana].
  static const notoSansThaana = PartN.notoSansThaana;

  /// See [PartN.notoSansThaanaTextTheme].
  static const notoSansThaanaTextTheme = PartN.notoSansThaanaTextTheme;

  /// See [PartN.notoSansThai].
  static const notoSansThai = PartN.notoSansThai;

  /// See [PartN.notoSansThaiTextTheme].
  static const notoSansThaiTextTheme = PartN.notoSansThaiTextTheme;

  /// See [PartN.notoSansThaiLooped].
  static const notoSansThaiLooped = PartN.notoSansThaiLooped;

  /// See [PartN.notoSansThaiLoopedTextTheme].
  static const notoSansThaiLoopedTextTheme = PartN.notoSansThaiLoopedTextTheme;

  /// See [PartN.notoSansTifinagh].
  static const notoSansTifinagh = PartN.notoSansTifinagh;

  /// See [PartN.notoSansTifinaghTextTheme].
  static const notoSansTifinaghTextTheme = PartN.notoSansTifinaghTextTheme;

  /// See [PartN.notoSansTirhuta].
  static const notoSansTirhuta = PartN.notoSansTirhuta;

  /// See [PartN.notoSansTirhutaTextTheme].
  static const notoSansTirhutaTextTheme = PartN.notoSansTirhutaTextTheme;

  /// See [PartN.notoSansUgaritic].
  static const notoSansUgaritic = PartN.notoSansUgaritic;

  /// See [PartN.notoSansUgariticTextTheme].
  static const notoSansUgariticTextTheme = PartN.notoSansUgariticTextTheme;

  /// See [PartN.notoSansVai].
  static const notoSansVai = PartN.notoSansVai;

  /// See [PartN.notoSansVaiTextTheme].
  static const notoSansVaiTextTheme = PartN.notoSansVaiTextTheme;

  /// See [PartN.notoSansVithkuqi].
  static const notoSansVithkuqi = PartN.notoSansVithkuqi;

  /// See [PartN.notoSansVithkuqiTextTheme].
  static const notoSansVithkuqiTextTheme = PartN.notoSansVithkuqiTextTheme;

  /// See [PartN.notoSansWancho].
  static const notoSansWancho = PartN.notoSansWancho;

  /// See [PartN.notoSansWanchoTextTheme].
  static const notoSansWanchoTextTheme = PartN.notoSansWanchoTextTheme;

  /// See [PartN.notoSansWarangCiti].
  static const notoSansWarangCiti = PartN.notoSansWarangCiti;

  /// See [PartN.notoSansWarangCitiTextTheme].
  static const notoSansWarangCitiTextTheme = PartN.notoSansWarangCitiTextTheme;

  /// See [PartN.notoSansYi].
  static const notoSansYi = PartN.notoSansYi;

  /// See [PartN.notoSansYiTextTheme].
  static const notoSansYiTextTheme = PartN.notoSansYiTextTheme;

  /// See [PartN.notoSansZanabazarSquare].
  static const notoSansZanabazarSquare = PartN.notoSansZanabazarSquare;

  /// See [PartN.notoSansZanabazarSquareTextTheme].
  static const notoSansZanabazarSquareTextTheme =
      PartN.notoSansZanabazarSquareTextTheme;

  /// See [PartN.notoSerif].
  static const notoSerif = PartN.notoSerif;

  /// See [PartN.notoSerifTextTheme].
  static const notoSerifTextTheme = PartN.notoSerifTextTheme;

  /// See [PartN.notoSerifAhom].
  static const notoSerifAhom = PartN.notoSerifAhom;

  /// See [PartN.notoSerifAhomTextTheme].
  static const notoSerifAhomTextTheme = PartN.notoSerifAhomTextTheme;

  /// See [PartN.notoSerifArmenian].
  static const notoSerifArmenian = PartN.notoSerifArmenian;

  /// See [PartN.notoSerifArmenianTextTheme].
  static const notoSerifArmenianTextTheme = PartN.notoSerifArmenianTextTheme;

  /// See [PartN.notoSerifBalinese].
  static const notoSerifBalinese = PartN.notoSerifBalinese;

  /// See [PartN.notoSerifBalineseTextTheme].
  static const notoSerifBalineseTextTheme = PartN.notoSerifBalineseTextTheme;

  /// See [PartN.notoSerifBengali].
  static const notoSerifBengali = PartN.notoSerifBengali;

  /// See [PartN.notoSerifBengaliTextTheme].
  static const notoSerifBengaliTextTheme = PartN.notoSerifBengaliTextTheme;

  /// See [PartN.notoSerifDevanagari].
  static const notoSerifDevanagari = PartN.notoSerifDevanagari;

  /// See [PartN.notoSerifDevanagariTextTheme].
  static const notoSerifDevanagariTextTheme =
      PartN.notoSerifDevanagariTextTheme;

  /// See [PartN.notoSerifDisplay].
  static const notoSerifDisplay = PartN.notoSerifDisplay;

  /// See [PartN.notoSerifDisplayTextTheme].
  static const notoSerifDisplayTextTheme = PartN.notoSerifDisplayTextTheme;

  /// See [PartN.notoSerifDivesAkuru].
  static const notoSerifDivesAkuru = PartN.notoSerifDivesAkuru;

  /// See [PartN.notoSerifDivesAkuruTextTheme].
  static const notoSerifDivesAkuruTextTheme =
      PartN.notoSerifDivesAkuruTextTheme;

  /// See [PartN.notoSerifDogra].
  static const notoSerifDogra = PartN.notoSerifDogra;

  /// See [PartN.notoSerifDograTextTheme].
  static const notoSerifDograTextTheme = PartN.notoSerifDograTextTheme;

  /// See [PartN.notoSerifEthiopic].
  static const notoSerifEthiopic = PartN.notoSerifEthiopic;

  /// See [PartN.notoSerifEthiopicTextTheme].
  static const notoSerifEthiopicTextTheme = PartN.notoSerifEthiopicTextTheme;

  /// See [PartN.notoSerifGeorgian].
  static const notoSerifGeorgian = PartN.notoSerifGeorgian;

  /// See [PartN.notoSerifGeorgianTextTheme].
  static const notoSerifGeorgianTextTheme = PartN.notoSerifGeorgianTextTheme;

  /// See [PartN.notoSerifGrantha].
  static const notoSerifGrantha = PartN.notoSerifGrantha;

  /// See [PartN.notoSerifGranthaTextTheme].
  static const notoSerifGranthaTextTheme = PartN.notoSerifGranthaTextTheme;

  /// See [PartN.notoSerifGujarati].
  static const notoSerifGujarati = PartN.notoSerifGujarati;

  /// See [PartN.notoSerifGujaratiTextTheme].
  static const notoSerifGujaratiTextTheme = PartN.notoSerifGujaratiTextTheme;

  /// See [PartN.notoSerifGurmukhi].
  static const notoSerifGurmukhi = PartN.notoSerifGurmukhi;

  /// See [PartN.notoSerifGurmukhiTextTheme].
  static const notoSerifGurmukhiTextTheme = PartN.notoSerifGurmukhiTextTheme;

  /// See [PartN.notoSerifHk].
  static const notoSerifHk = PartN.notoSerifHk;

  /// See [PartN.notoSerifHkTextTheme].
  static const notoSerifHkTextTheme = PartN.notoSerifHkTextTheme;

  /// See [PartN.notoSerifHebrew].
  static const notoSerifHebrew = PartN.notoSerifHebrew;

  /// See [PartN.notoSerifHebrewTextTheme].
  static const notoSerifHebrewTextTheme = PartN.notoSerifHebrewTextTheme;

  /// See [PartN.notoSerifHentaigana].
  static const notoSerifHentaigana = PartN.notoSerifHentaigana;

  /// See [PartN.notoSerifHentaiganaTextTheme].
  static const notoSerifHentaiganaTextTheme =
      PartN.notoSerifHentaiganaTextTheme;

  /// See [PartN.notoSerifJp].
  static const notoSerifJp = PartN.notoSerifJp;

  /// See [PartN.notoSerifJpTextTheme].
  static const notoSerifJpTextTheme = PartN.notoSerifJpTextTheme;

  /// See [PartN.notoSerifKr].
  static const notoSerifKr = PartN.notoSerifKr;

  /// See [PartN.notoSerifKrTextTheme].
  static const notoSerifKrTextTheme = PartN.notoSerifKrTextTheme;

  /// See [PartN.notoSerifKannada].
  static const notoSerifKannada = PartN.notoSerifKannada;

  /// See [PartN.notoSerifKannadaTextTheme].
  static const notoSerifKannadaTextTheme = PartN.notoSerifKannadaTextTheme;

  /// See [PartN.notoSerifKhitanSmallScript].
  static const notoSerifKhitanSmallScript = PartN.notoSerifKhitanSmallScript;

  /// See [PartN.notoSerifKhitanSmallScriptTextTheme].
  static const notoSerifKhitanSmallScriptTextTheme =
      PartN.notoSerifKhitanSmallScriptTextTheme;

  /// See [PartN.notoSerifKhmer].
  static const notoSerifKhmer = PartN.notoSerifKhmer;

  /// See [PartN.notoSerifKhmerTextTheme].
  static const notoSerifKhmerTextTheme = PartN.notoSerifKhmerTextTheme;

  /// See [PartN.notoSerifKhojki].
  static const notoSerifKhojki = PartN.notoSerifKhojki;

  /// See [PartN.notoSerifKhojkiTextTheme].
  static const notoSerifKhojkiTextTheme = PartN.notoSerifKhojkiTextTheme;

  /// See [PartN.notoSerifLao].
  static const notoSerifLao = PartN.notoSerifLao;

  /// See [PartN.notoSerifLaoTextTheme].
  static const notoSerifLaoTextTheme = PartN.notoSerifLaoTextTheme;

  /// See [PartN.notoSerifMakasar].
  static const notoSerifMakasar = PartN.notoSerifMakasar;

  /// See [PartN.notoSerifMakasarTextTheme].
  static const notoSerifMakasarTextTheme = PartN.notoSerifMakasarTextTheme;

  /// See [PartN.notoSerifMalayalam].
  static const notoSerifMalayalam = PartN.notoSerifMalayalam;

  /// See [PartN.notoSerifMalayalamTextTheme].
  static const notoSerifMalayalamTextTheme = PartN.notoSerifMalayalamTextTheme;

  /// See [PartN.notoSerifMyanmar].
  static const notoSerifMyanmar = PartN.notoSerifMyanmar;

  /// See [PartN.notoSerifMyanmarTextTheme].
  static const notoSerifMyanmarTextTheme = PartN.notoSerifMyanmarTextTheme;

  /// See [PartN.notoSerifNpHmong].
  static const notoSerifNpHmong = PartN.notoSerifNpHmong;

  /// See [PartN.notoSerifNpHmongTextTheme].
  static const notoSerifNpHmongTextTheme = PartN.notoSerifNpHmongTextTheme;

  /// See [PartN.notoSerifOldUyghur].
  static const notoSerifOldUyghur = PartN.notoSerifOldUyghur;

  /// See [PartN.notoSerifOldUyghurTextTheme].
  static const notoSerifOldUyghurTextTheme = PartN.notoSerifOldUyghurTextTheme;

  /// See [PartN.notoSerifOriya].
  static const notoSerifOriya = PartN.notoSerifOriya;

  /// See [PartN.notoSerifOriyaTextTheme].
  static const notoSerifOriyaTextTheme = PartN.notoSerifOriyaTextTheme;

  /// See [PartN.notoSerifOttomanSiyaq].
  static const notoSerifOttomanSiyaq = PartN.notoSerifOttomanSiyaq;

  /// See [PartN.notoSerifOttomanSiyaqTextTheme].
  static const notoSerifOttomanSiyaqTextTheme =
      PartN.notoSerifOttomanSiyaqTextTheme;

  /// See [PartN.notoSerifSc].
  static const notoSerifSc = PartN.notoSerifSc;

  /// See [PartN.notoSerifScTextTheme].
  static const notoSerifScTextTheme = PartN.notoSerifScTextTheme;

  /// See [PartN.notoSerifSinhala].
  static const notoSerifSinhala = PartN.notoSerifSinhala;

  /// See [PartN.notoSerifSinhalaTextTheme].
  static const notoSerifSinhalaTextTheme = PartN.notoSerifSinhalaTextTheme;

  /// See [PartN.notoSerifTc].
  static const notoSerifTc = PartN.notoSerifTc;

  /// See [PartN.notoSerifTcTextTheme].
  static const notoSerifTcTextTheme = PartN.notoSerifTcTextTheme;

  /// See [PartN.notoSerifTamil].
  static const notoSerifTamil = PartN.notoSerifTamil;

  /// See [PartN.notoSerifTamilTextTheme].
  static const notoSerifTamilTextTheme = PartN.notoSerifTamilTextTheme;

  /// See [PartN.notoSerifTangut].
  static const notoSerifTangut = PartN.notoSerifTangut;

  /// See [PartN.notoSerifTangutTextTheme].
  static const notoSerifTangutTextTheme = PartN.notoSerifTangutTextTheme;

  /// See [PartN.notoSerifTelugu].
  static const notoSerifTelugu = PartN.notoSerifTelugu;

  /// See [PartN.notoSerifTeluguTextTheme].
  static const notoSerifTeluguTextTheme = PartN.notoSerifTeluguTextTheme;

  /// See [PartN.notoSerifThai].
  static const notoSerifThai = PartN.notoSerifThai;

  /// See [PartN.notoSerifThaiTextTheme].
  static const notoSerifThaiTextTheme = PartN.notoSerifThaiTextTheme;

  /// See [PartN.notoSerifTibetan].
  static const notoSerifTibetan = PartN.notoSerifTibetan;

  /// See [PartN.notoSerifTibetanTextTheme].
  static const notoSerifTibetanTextTheme = PartN.notoSerifTibetanTextTheme;

  /// See [PartN.notoSerifTodhri].
  static const notoSerifTodhri = PartN.notoSerifTodhri;

  /// See [PartN.notoSerifTodhriTextTheme].
  static const notoSerifTodhriTextTheme = PartN.notoSerifTodhriTextTheme;

  /// See [PartN.notoSerifToto].
  static const notoSerifToto = PartN.notoSerifToto;

  /// See [PartN.notoSerifTotoTextTheme].
  static const notoSerifTotoTextTheme = PartN.notoSerifTotoTextTheme;

  /// See [PartN.notoSerifVithkuqi].
  static const notoSerifVithkuqi = PartN.notoSerifVithkuqi;

  /// See [PartN.notoSerifVithkuqiTextTheme].
  static const notoSerifVithkuqiTextTheme = PartN.notoSerifVithkuqiTextTheme;

  /// See [PartN.notoSerifYezidi].
  static const notoSerifYezidi = PartN.notoSerifYezidi;

  /// See [PartN.notoSerifYezidiTextTheme].
  static const notoSerifYezidiTextTheme = PartN.notoSerifYezidiTextTheme;

  /// See [PartN.notoTraditionalNushu].
  static const notoTraditionalNushu = PartN.notoTraditionalNushu;

  /// See [PartN.notoTraditionalNushuTextTheme].
  static const notoTraditionalNushuTextTheme =
      PartN.notoTraditionalNushuTextTheme;

  /// See [PartN.notoZnamennyMusicalNotation].
  static const notoZnamennyMusicalNotation = PartN.notoZnamennyMusicalNotation;

  /// See [PartN.notoZnamennyMusicalNotationTextTheme].
  static const notoZnamennyMusicalNotationTextTheme =
      PartN.notoZnamennyMusicalNotationTextTheme;

  /// See [PartN.novaCut].
  static const novaCut = PartN.novaCut;

  /// See [PartN.novaCutTextTheme].
  static const novaCutTextTheme = PartN.novaCutTextTheme;

  /// See [PartN.novaFlat].
  static const novaFlat = PartN.novaFlat;

  /// See [PartN.novaFlatTextTheme].
  static const novaFlatTextTheme = PartN.novaFlatTextTheme;

  /// See [PartN.novaMono].
  static const novaMono = PartN.novaMono;

  /// See [PartN.novaMonoTextTheme].
  static const novaMonoTextTheme = PartN.novaMonoTextTheme;

  /// See [PartN.novaOval].
  static const novaOval = PartN.novaOval;

  /// See [PartN.novaOvalTextTheme].
  static const novaOvalTextTheme = PartN.novaOvalTextTheme;

  /// See [PartN.novaRound].
  static const novaRound = PartN.novaRound;

  /// See [PartN.novaRoundTextTheme].
  static const novaRoundTextTheme = PartN.novaRoundTextTheme;

  /// See [PartN.novaScript].
  static const novaScript = PartN.novaScript;

  /// See [PartN.novaScriptTextTheme].
  static const novaScriptTextTheme = PartN.novaScriptTextTheme;

  /// See [PartN.novaSlim].
  static const novaSlim = PartN.novaSlim;

  /// See [PartN.novaSlimTextTheme].
  static const novaSlimTextTheme = PartN.novaSlimTextTheme;

  /// See [PartN.novaSquare].
  static const novaSquare = PartN.novaSquare;

  /// See [PartN.novaSquareTextTheme].
  static const novaSquareTextTheme = PartN.novaSquareTextTheme;

  /// See [PartN.numans].
  static const numans = PartN.numans;

  /// See [PartN.numansTextTheme].
  static const numansTextTheme = PartN.numansTextTheme;

  /// See [PartN.nunito].
  static const nunito = PartN.nunito;

  /// See [PartN.nunitoTextTheme].
  static const nunitoTextTheme = PartN.nunitoTextTheme;

  /// See [PartN.nunitoSans].
  static const nunitoSans = PartN.nunitoSans;

  /// See [PartN.nunitoSansTextTheme].
  static const nunitoSansTextTheme = PartN.nunitoSansTextTheme;

  /// See [PartN.nuosuSil].
  static const nuosuSil = PartN.nuosuSil;

  /// See [PartN.nuosuSilTextTheme].
  static const nuosuSilTextTheme = PartN.nuosuSilTextTheme;

  /// See [PartO.odibeeSans].
  static const odibeeSans = PartO.odibeeSans;

  /// See [PartO.odibeeSansTextTheme].
  static const odibeeSansTextTheme = PartO.odibeeSansTextTheme;

  /// See [PartO.odorMeanChey].
  static const odorMeanChey = PartO.odorMeanChey;

  /// See [PartO.odorMeanCheyTextTheme].
  static const odorMeanCheyTextTheme = PartO.odorMeanCheyTextTheme;

  /// See [PartO.offside].
  static const offside = PartO.offside;

  /// See [PartO.offsideTextTheme].
  static const offsideTextTheme = PartO.offsideTextTheme;

  /// See [PartO.oi].
  static const oi = PartO.oi;

  /// See [PartO.oiTextTheme].
  static const oiTextTheme = PartO.oiTextTheme;

  /// See [PartO.ojuju].
  static const ojuju = PartO.ojuju;

  /// See [PartO.ojujuTextTheme].
  static const ojujuTextTheme = PartO.ojujuTextTheme;

  /// See [PartO.oldStandardTt].
  static const oldStandardTt = PartO.oldStandardTt;

  /// See [PartO.oldStandardTtTextTheme].
  static const oldStandardTtTextTheme = PartO.oldStandardTtTextTheme;

  /// See [PartO.oldenburg].
  static const oldenburg = PartO.oldenburg;

  /// See [PartO.oldenburgTextTheme].
  static const oldenburgTextTheme = PartO.oldenburgTextTheme;

  /// See [PartO.ole].
  static const ole = PartO.ole;

  /// See [PartO.oleTextTheme].
  static const oleTextTheme = PartO.oleTextTheme;

  /// See [PartO.oleoScript].
  static const oleoScript = PartO.oleoScript;

  /// See [PartO.oleoScriptTextTheme].
  static const oleoScriptTextTheme = PartO.oleoScriptTextTheme;

  /// See [PartO.oleoScriptSwashCaps].
  static const oleoScriptSwashCaps = PartO.oleoScriptSwashCaps;

  /// See [PartO.oleoScriptSwashCapsTextTheme].
  static const oleoScriptSwashCapsTextTheme =
      PartO.oleoScriptSwashCapsTextTheme;

  /// See [PartO.onest].
  static const onest = PartO.onest;

  /// See [PartO.onestTextTheme].
  static const onestTextTheme = PartO.onestTextTheme;

  /// See [PartO.ooohBaby].
  static const ooohBaby = PartO.ooohBaby;

  /// See [PartO.ooohBabyTextTheme].
  static const ooohBabyTextTheme = PartO.ooohBabyTextTheme;

  /// See [PartO.openSans].
  static const openSans = PartO.openSans;

  /// See [PartO.openSansTextTheme].
  static const openSansTextTheme = PartO.openSansTextTheme;

  /// See [PartO.oranienbaum].
  static const oranienbaum = PartO.oranienbaum;

  /// See [PartO.oranienbaumTextTheme].
  static const oranienbaumTextTheme = PartO.oranienbaumTextTheme;

  /// See [PartO.orbit].
  static const orbit = PartO.orbit;

  /// See [PartO.orbitTextTheme].
  static const orbitTextTheme = PartO.orbitTextTheme;

  /// See [PartO.orbitron].
  static const orbitron = PartO.orbitron;

  /// See [PartO.orbitronTextTheme].
  static const orbitronTextTheme = PartO.orbitronTextTheme;

  /// See [PartO.oregano].
  static const oregano = PartO.oregano;

  /// See [PartO.oreganoTextTheme].
  static const oreganoTextTheme = PartO.oreganoTextTheme;

  /// See [PartO.orelegaOne].
  static const orelegaOne = PartO.orelegaOne;

  /// See [PartO.orelegaOneTextTheme].
  static const orelegaOneTextTheme = PartO.orelegaOneTextTheme;

  /// See [PartO.orienta].
  static const orienta = PartO.orienta;

  /// See [PartO.orientaTextTheme].
  static const orientaTextTheme = PartO.orientaTextTheme;

  /// See [PartO.originalSurfer].
  static const originalSurfer = PartO.originalSurfer;

  /// See [PartO.originalSurferTextTheme].
  static const originalSurferTextTheme = PartO.originalSurferTextTheme;

  /// See [PartO.oswald].
  static const oswald = PartO.oswald;

  /// See [PartO.oswaldTextTheme].
  static const oswaldTextTheme = PartO.oswaldTextTheme;

  /// See [PartO.outfit].
  static const outfit = PartO.outfit;

  /// See [PartO.outfitTextTheme].
  static const outfitTextTheme = PartO.outfitTextTheme;

  /// See [PartO.overTheRainbow].
  static const overTheRainbow = PartO.overTheRainbow;

  /// See [PartO.overTheRainbowTextTheme].
  static const overTheRainbowTextTheme = PartO.overTheRainbowTextTheme;

  /// See [PartO.overlock].
  static const overlock = PartO.overlock;

  /// See [PartO.overlockTextTheme].
  static const overlockTextTheme = PartO.overlockTextTheme;

  /// See [PartO.overlockSc].
  static const overlockSc = PartO.overlockSc;

  /// See [PartO.overlockScTextTheme].
  static const overlockScTextTheme = PartO.overlockScTextTheme;

  /// See [PartO.overpass].
  static const overpass = PartO.overpass;

  /// See [PartO.overpassTextTheme].
  static const overpassTextTheme = PartO.overpassTextTheme;

  /// See [PartO.overpassMono].
  static const overpassMono = PartO.overpassMono;

  /// See [PartO.overpassMonoTextTheme].
  static const overpassMonoTextTheme = PartO.overpassMonoTextTheme;

  /// See [PartO.ovo].
  static const ovo = PartO.ovo;

  /// See [PartO.ovoTextTheme].
  static const ovoTextTheme = PartO.ovoTextTheme;

  /// See [PartO.oxanium].
  static const oxanium = PartO.oxanium;

  /// See [PartO.oxaniumTextTheme].
  static const oxaniumTextTheme = PartO.oxaniumTextTheme;

  /// See [PartO.oxygen].
  static const oxygen = PartO.oxygen;

  /// See [PartO.oxygenTextTheme].
  static const oxygenTextTheme = PartO.oxygenTextTheme;

  /// See [PartO.oxygenMono].
  static const oxygenMono = PartO.oxygenMono;

  /// See [PartO.oxygenMonoTextTheme].
  static const oxygenMonoTextTheme = PartO.oxygenMonoTextTheme;

  /// See [PartP.ptMono].
  static const ptMono = PartP.ptMono;

  /// See [PartP.ptMonoTextTheme].
  static const ptMonoTextTheme = PartP.ptMonoTextTheme;

  /// See [PartP.ptSans].
  static const ptSans = PartP.ptSans;

  /// See [PartP.ptSansTextTheme].
  static const ptSansTextTheme = PartP.ptSansTextTheme;

  /// See [PartP.ptSansCaption].
  static const ptSansCaption = PartP.ptSansCaption;

  /// See [PartP.ptSansCaptionTextTheme].
  static const ptSansCaptionTextTheme = PartP.ptSansCaptionTextTheme;

  /// See [PartP.ptSansNarrow].
  static const ptSansNarrow = PartP.ptSansNarrow;

  /// See [PartP.ptSansNarrowTextTheme].
  static const ptSansNarrowTextTheme = PartP.ptSansNarrowTextTheme;

  /// See [PartP.ptSerif].
  static const ptSerif = PartP.ptSerif;

  /// See [PartP.ptSerifTextTheme].
  static const ptSerifTextTheme = PartP.ptSerifTextTheme;

  /// See [PartP.ptSerifCaption].
  static const ptSerifCaption = PartP.ptSerifCaption;

  /// See [PartP.ptSerifCaptionTextTheme].
  static const ptSerifCaptionTextTheme = PartP.ptSerifCaptionTextTheme;

  /// See [PartP.pacifico].
  static const pacifico = PartP.pacifico;

  /// See [PartP.pacificoTextTheme].
  static const pacificoTextTheme = PartP.pacificoTextTheme;

  /// See [PartP.padauk].
  static const padauk = PartP.padauk;

  /// See [PartP.padaukTextTheme].
  static const padaukTextTheme = PartP.padaukTextTheme;

  /// See [PartP.padyakkeExpandedOne].
  static const padyakkeExpandedOne = PartP.padyakkeExpandedOne;

  /// See [PartP.padyakkeExpandedOneTextTheme].
  static const padyakkeExpandedOneTextTheme =
      PartP.padyakkeExpandedOneTextTheme;

  /// See [PartP.palanquin].
  static const palanquin = PartP.palanquin;

  /// See [PartP.palanquinTextTheme].
  static const palanquinTextTheme = PartP.palanquinTextTheme;

  /// See [PartP.palanquinDark].
  static const palanquinDark = PartP.palanquinDark;

  /// See [PartP.palanquinDarkTextTheme].
  static const palanquinDarkTextTheme = PartP.palanquinDarkTextTheme;

  /// See [PartP.paletteMosaic].
  static const paletteMosaic = PartP.paletteMosaic;

  /// See [PartP.paletteMosaicTextTheme].
  static const paletteMosaicTextTheme = PartP.paletteMosaicTextTheme;

  /// See [PartP.pangolin].
  static const pangolin = PartP.pangolin;

  /// See [PartP.pangolinTextTheme].
  static const pangolinTextTheme = PartP.pangolinTextTheme;

  /// See [PartP.paprika].
  static const paprika = PartP.paprika;

  /// See [PartP.paprikaTextTheme].
  static const paprikaTextTheme = PartP.paprikaTextTheme;

  /// See [PartP.parastoo].
  static const parastoo = PartP.parastoo;

  /// See [PartP.parastooTextTheme].
  static const parastooTextTheme = PartP.parastooTextTheme;

  /// See [PartP.parisienne].
  static const parisienne = PartP.parisienne;

  /// See [PartP.parisienneTextTheme].
  static const parisienneTextTheme = PartP.parisienneTextTheme;

  /// See [PartP.parkinsans].
  static const parkinsans = PartP.parkinsans;

  /// See [PartP.parkinsansTextTheme].
  static const parkinsansTextTheme = PartP.parkinsansTextTheme;

  /// See [PartP.passeroOne].
  static const passeroOne = PartP.passeroOne;

  /// See [PartP.passeroOneTextTheme].
  static const passeroOneTextTheme = PartP.passeroOneTextTheme;

  /// See [PartP.passionOne].
  static const passionOne = PartP.passionOne;

  /// See [PartP.passionOneTextTheme].
  static const passionOneTextTheme = PartP.passionOneTextTheme;

  /// See [PartP.passionsConflict].
  static const passionsConflict = PartP.passionsConflict;

  /// See [PartP.passionsConflictTextTheme].
  static const passionsConflictTextTheme = PartP.passionsConflictTextTheme;

  /// See [PartP.pathwayExtreme].
  static const pathwayExtreme = PartP.pathwayExtreme;

  /// See [PartP.pathwayExtremeTextTheme].
  static const pathwayExtremeTextTheme = PartP.pathwayExtremeTextTheme;

  /// See [PartP.pathwayGothicOne].
  static const pathwayGothicOne = PartP.pathwayGothicOne;

  /// See [PartP.pathwayGothicOneTextTheme].
  static const pathwayGothicOneTextTheme = PartP.pathwayGothicOneTextTheme;

  /// See [PartP.patrickHand].
  static const patrickHand = PartP.patrickHand;

  /// See [PartP.patrickHandTextTheme].
  static const patrickHandTextTheme = PartP.patrickHandTextTheme;

  /// See [PartP.patrickHandSc].
  static const patrickHandSc = PartP.patrickHandSc;

  /// See [PartP.patrickHandScTextTheme].
  static const patrickHandScTextTheme = PartP.patrickHandScTextTheme;

  /// See [PartP.pattaya].
  static const pattaya = PartP.pattaya;

  /// See [PartP.pattayaTextTheme].
  static const pattayaTextTheme = PartP.pattayaTextTheme;

  /// See [PartP.patuaOne].
  static const patuaOne = PartP.patuaOne;

  /// See [PartP.patuaOneTextTheme].
  static const patuaOneTextTheme = PartP.patuaOneTextTheme;

  /// See [PartP.pavanam].
  static const pavanam = PartP.pavanam;

  /// See [PartP.pavanamTextTheme].
  static const pavanamTextTheme = PartP.pavanamTextTheme;

  /// See [PartP.paytoneOne].
  static const paytoneOne = PartP.paytoneOne;

  /// See [PartP.paytoneOneTextTheme].
  static const paytoneOneTextTheme = PartP.paytoneOneTextTheme;

  /// See [PartP.peddana].
  static const peddana = PartP.peddana;

  /// See [PartP.peddanaTextTheme].
  static const peddanaTextTheme = PartP.peddanaTextTheme;

  /// See [PartP.peralta].
  static const peralta = PartP.peralta;

  /// See [PartP.peraltaTextTheme].
  static const peraltaTextTheme = PartP.peraltaTextTheme;

  /// See [PartP.permanentMarker].
  static const permanentMarker = PartP.permanentMarker;

  /// See [PartP.permanentMarkerTextTheme].
  static const permanentMarkerTextTheme = PartP.permanentMarkerTextTheme;

  /// See [PartP.petemoss].
  static const petemoss = PartP.petemoss;

  /// See [PartP.petemossTextTheme].
  static const petemossTextTheme = PartP.petemossTextTheme;

  /// See [PartP.petitFormalScript].
  static const petitFormalScript = PartP.petitFormalScript;

  /// See [PartP.petitFormalScriptTextTheme].
  static const petitFormalScriptTextTheme = PartP.petitFormalScriptTextTheme;

  /// See [PartP.petrona].
  static const petrona = PartP.petrona;

  /// See [PartP.petronaTextTheme].
  static const petronaTextTheme = PartP.petronaTextTheme;

  /// See [PartP.phetsarath].
  static const phetsarath = PartP.phetsarath;

  /// See [PartP.phetsarathTextTheme].
  static const phetsarathTextTheme = PartP.phetsarathTextTheme;

  /// See [PartP.philosopher].
  static const philosopher = PartP.philosopher;

  /// See [PartP.philosopherTextTheme].
  static const philosopherTextTheme = PartP.philosopherTextTheme;

  /// See [PartP.phudu].
  static const phudu = PartP.phudu;

  /// See [PartP.phuduTextTheme].
  static const phuduTextTheme = PartP.phuduTextTheme;

  /// See [PartP.piazzolla].
  static const piazzolla = PartP.piazzolla;

  /// See [PartP.piazzollaTextTheme].
  static const piazzollaTextTheme = PartP.piazzollaTextTheme;

  /// See [PartP.piedra].
  static const piedra = PartP.piedra;

  /// See [PartP.piedraTextTheme].
  static const piedraTextTheme = PartP.piedraTextTheme;

  /// See [PartP.pinyonScript].
  static const pinyonScript = PartP.pinyonScript;

  /// See [PartP.pinyonScriptTextTheme].
  static const pinyonScriptTextTheme = PartP.pinyonScriptTextTheme;

  /// See [PartP.pirataOne].
  static const pirataOne = PartP.pirataOne;

  /// See [PartP.pirataOneTextTheme].
  static const pirataOneTextTheme = PartP.pirataOneTextTheme;

  /// See [PartP.pixelifySans].
  static const pixelifySans = PartP.pixelifySans;

  /// See [PartP.pixelifySansTextTheme].
  static const pixelifySansTextTheme = PartP.pixelifySansTextTheme;

  /// See [PartP.plaster].
  static const plaster = PartP.plaster;

  /// See [PartP.plasterTextTheme].
  static const plasterTextTheme = PartP.plasterTextTheme;

  /// See [PartP.platypi].
  static const platypi = PartP.platypi;

  /// See [PartP.platypiTextTheme].
  static const platypiTextTheme = PartP.platypiTextTheme;

  /// See [PartP.play].
  static const play = PartP.play;

  /// See [PartP.playTextTheme].
  static const playTextTheme = PartP.playTextTheme;

  /// See [PartP.playball].
  static const playball = PartP.playball;

  /// See [PartP.playballTextTheme].
  static const playballTextTheme = PartP.playballTextTheme;

  /// See [PartP.playfair].
  static const playfair = PartP.playfair;

  /// See [PartP.playfairTextTheme].
  static const playfairTextTheme = PartP.playfairTextTheme;

  /// See [PartP.playfairDisplay].
  static const playfairDisplay = PartP.playfairDisplay;

  /// See [PartP.playfairDisplayTextTheme].
  static const playfairDisplayTextTheme = PartP.playfairDisplayTextTheme;

  /// See [PartP.playfairDisplaySc].
  static const playfairDisplaySc = PartP.playfairDisplaySc;

  /// See [PartP.playfairDisplayScTextTheme].
  static const playfairDisplayScTextTheme = PartP.playfairDisplayScTextTheme;

  /// See [PartP.playpenSans].
  static const playpenSans = PartP.playpenSans;

  /// See [PartP.playpenSansTextTheme].
  static const playpenSansTextTheme = PartP.playpenSansTextTheme;

  /// See [PartP.playpenSansArabic].
  static const playpenSansArabic = PartP.playpenSansArabic;

  /// See [PartP.playpenSansArabicTextTheme].
  static const playpenSansArabicTextTheme = PartP.playpenSansArabicTextTheme;

  /// See [PartP.playpenSansDeva].
  static const playpenSansDeva = PartP.playpenSansDeva;

  /// See [PartP.playpenSansDevaTextTheme].
  static const playpenSansDevaTextTheme = PartP.playpenSansDevaTextTheme;

  /// See [PartP.playpenSansHebrew].
  static const playpenSansHebrew = PartP.playpenSansHebrew;

  /// See [PartP.playpenSansHebrewTextTheme].
  static const playpenSansHebrewTextTheme = PartP.playpenSansHebrewTextTheme;

  /// See [PartP.playpenSansThai].
  static const playpenSansThai = PartP.playpenSansThai;

  /// See [PartP.playpenSansThaiTextTheme].
  static const playpenSansThaiTextTheme = PartP.playpenSansThaiTextTheme;

  /// See [PartP.playwriteAr].
  static const playwriteAr = PartP.playwriteAr;

  /// See [PartP.playwriteArTextTheme].
  static const playwriteArTextTheme = PartP.playwriteArTextTheme;

  /// See [PartP.playwriteArGuides].
  static const playwriteArGuides = PartP.playwriteArGuides;

  /// See [PartP.playwriteArGuidesTextTheme].
  static const playwriteArGuidesTextTheme = PartP.playwriteArGuidesTextTheme;

  /// See [PartP.playwriteAt].
  static const playwriteAt = PartP.playwriteAt;

  /// See [PartP.playwriteAtTextTheme].
  static const playwriteAtTextTheme = PartP.playwriteAtTextTheme;

  /// See [PartP.playwriteAtGuides].
  static const playwriteAtGuides = PartP.playwriteAtGuides;

  /// See [PartP.playwriteAtGuidesTextTheme].
  static const playwriteAtGuidesTextTheme = PartP.playwriteAtGuidesTextTheme;

  /// See [PartP.playwriteAuNsw].
  static const playwriteAuNsw = PartP.playwriteAuNsw;

  /// See [PartP.playwriteAuNswTextTheme].
  static const playwriteAuNswTextTheme = PartP.playwriteAuNswTextTheme;

  /// See [PartP.playwriteAuNswGuides].
  static const playwriteAuNswGuides = PartP.playwriteAuNswGuides;

  /// See [PartP.playwriteAuNswGuidesTextTheme].
  static const playwriteAuNswGuidesTextTheme =
      PartP.playwriteAuNswGuidesTextTheme;

  /// See [PartP.playwriteAuQld].
  static const playwriteAuQld = PartP.playwriteAuQld;

  /// See [PartP.playwriteAuQldTextTheme].
  static const playwriteAuQldTextTheme = PartP.playwriteAuQldTextTheme;

  /// See [PartP.playwriteAuQldGuides].
  static const playwriteAuQldGuides = PartP.playwriteAuQldGuides;

  /// See [PartP.playwriteAuQldGuidesTextTheme].
  static const playwriteAuQldGuidesTextTheme =
      PartP.playwriteAuQldGuidesTextTheme;

  /// See [PartP.playwriteAuSa].
  static const playwriteAuSa = PartP.playwriteAuSa;

  /// See [PartP.playwriteAuSaTextTheme].
  static const playwriteAuSaTextTheme = PartP.playwriteAuSaTextTheme;

  /// See [PartP.playwriteAuSaGuides].
  static const playwriteAuSaGuides = PartP.playwriteAuSaGuides;

  /// See [PartP.playwriteAuSaGuidesTextTheme].
  static const playwriteAuSaGuidesTextTheme =
      PartP.playwriteAuSaGuidesTextTheme;

  /// See [PartP.playwriteAuTas].
  static const playwriteAuTas = PartP.playwriteAuTas;

  /// See [PartP.playwriteAuTasTextTheme].
  static const playwriteAuTasTextTheme = PartP.playwriteAuTasTextTheme;

  /// See [PartP.playwriteAuTasGuides].
  static const playwriteAuTasGuides = PartP.playwriteAuTasGuides;

  /// See [PartP.playwriteAuTasGuidesTextTheme].
  static const playwriteAuTasGuidesTextTheme =
      PartP.playwriteAuTasGuidesTextTheme;

  /// See [PartP.playwriteAuVic].
  static const playwriteAuVic = PartP.playwriteAuVic;

  /// See [PartP.playwriteAuVicTextTheme].
  static const playwriteAuVicTextTheme = PartP.playwriteAuVicTextTheme;

  /// See [PartP.playwriteAuVicGuides].
  static const playwriteAuVicGuides = PartP.playwriteAuVicGuides;

  /// See [PartP.playwriteAuVicGuidesTextTheme].
  static const playwriteAuVicGuidesTextTheme =
      PartP.playwriteAuVicGuidesTextTheme;

  /// See [PartP.playwriteBeVlg].
  static const playwriteBeVlg = PartP.playwriteBeVlg;

  /// See [PartP.playwriteBeVlgTextTheme].
  static const playwriteBeVlgTextTheme = PartP.playwriteBeVlgTextTheme;

  /// See [PartP.playwriteBeVlgGuides].
  static const playwriteBeVlgGuides = PartP.playwriteBeVlgGuides;

  /// See [PartP.playwriteBeVlgGuidesTextTheme].
  static const playwriteBeVlgGuidesTextTheme =
      PartP.playwriteBeVlgGuidesTextTheme;

  /// See [PartP.playwriteBeWal].
  static const playwriteBeWal = PartP.playwriteBeWal;

  /// See [PartP.playwriteBeWalTextTheme].
  static const playwriteBeWalTextTheme = PartP.playwriteBeWalTextTheme;

  /// See [PartP.playwriteBeWalGuides].
  static const playwriteBeWalGuides = PartP.playwriteBeWalGuides;

  /// See [PartP.playwriteBeWalGuidesTextTheme].
  static const playwriteBeWalGuidesTextTheme =
      PartP.playwriteBeWalGuidesTextTheme;

  /// See [PartP.playwriteBr].
  static const playwriteBr = PartP.playwriteBr;

  /// See [PartP.playwriteBrTextTheme].
  static const playwriteBrTextTheme = PartP.playwriteBrTextTheme;

  /// See [PartP.playwriteBrGuides].
  static const playwriteBrGuides = PartP.playwriteBrGuides;

  /// See [PartP.playwriteBrGuidesTextTheme].
  static const playwriteBrGuidesTextTheme = PartP.playwriteBrGuidesTextTheme;

  /// See [PartP.playwriteCa].
  static const playwriteCa = PartP.playwriteCa;

  /// See [PartP.playwriteCaTextTheme].
  static const playwriteCaTextTheme = PartP.playwriteCaTextTheme;

  /// See [PartP.playwriteCaGuides].
  static const playwriteCaGuides = PartP.playwriteCaGuides;

  /// See [PartP.playwriteCaGuidesTextTheme].
  static const playwriteCaGuidesTextTheme = PartP.playwriteCaGuidesTextTheme;

  /// See [PartP.playwriteCl].
  static const playwriteCl = PartP.playwriteCl;

  /// See [PartP.playwriteClTextTheme].
  static const playwriteClTextTheme = PartP.playwriteClTextTheme;

  /// See [PartP.playwriteClGuides].
  static const playwriteClGuides = PartP.playwriteClGuides;

  /// See [PartP.playwriteClGuidesTextTheme].
  static const playwriteClGuidesTextTheme = PartP.playwriteClGuidesTextTheme;

  /// See [PartP.playwriteCo].
  static const playwriteCo = PartP.playwriteCo;

  /// See [PartP.playwriteCoTextTheme].
  static const playwriteCoTextTheme = PartP.playwriteCoTextTheme;

  /// See [PartP.playwriteCoGuides].
  static const playwriteCoGuides = PartP.playwriteCoGuides;

  /// See [PartP.playwriteCoGuidesTextTheme].
  static const playwriteCoGuidesTextTheme = PartP.playwriteCoGuidesTextTheme;

  /// See [PartP.playwriteCu].
  static const playwriteCu = PartP.playwriteCu;

  /// See [PartP.playwriteCuTextTheme].
  static const playwriteCuTextTheme = PartP.playwriteCuTextTheme;

  /// See [PartP.playwriteCuGuides].
  static const playwriteCuGuides = PartP.playwriteCuGuides;

  /// See [PartP.playwriteCuGuidesTextTheme].
  static const playwriteCuGuidesTextTheme = PartP.playwriteCuGuidesTextTheme;

  /// See [PartP.playwriteCz].
  static const playwriteCz = PartP.playwriteCz;

  /// See [PartP.playwriteCzTextTheme].
  static const playwriteCzTextTheme = PartP.playwriteCzTextTheme;

  /// See [PartP.playwriteCzGuides].
  static const playwriteCzGuides = PartP.playwriteCzGuides;

  /// See [PartP.playwriteCzGuidesTextTheme].
  static const playwriteCzGuidesTextTheme = PartP.playwriteCzGuidesTextTheme;

  /// See [PartP.playwriteDeGrund].
  static const playwriteDeGrund = PartP.playwriteDeGrund;

  /// See [PartP.playwriteDeGrundTextTheme].
  static const playwriteDeGrundTextTheme = PartP.playwriteDeGrundTextTheme;

  /// See [PartP.playwriteDeGrundGuides].
  static const playwriteDeGrundGuides = PartP.playwriteDeGrundGuides;

  /// See [PartP.playwriteDeGrundGuidesTextTheme].
  static const playwriteDeGrundGuidesTextTheme =
      PartP.playwriteDeGrundGuidesTextTheme;

  /// See [PartP.playwriteDeLa].
  static const playwriteDeLa = PartP.playwriteDeLa;

  /// See [PartP.playwriteDeLaTextTheme].
  static const playwriteDeLaTextTheme = PartP.playwriteDeLaTextTheme;

  /// See [PartP.playwriteDeLaGuides].
  static const playwriteDeLaGuides = PartP.playwriteDeLaGuides;

  /// See [PartP.playwriteDeLaGuidesTextTheme].
  static const playwriteDeLaGuidesTextTheme =
      PartP.playwriteDeLaGuidesTextTheme;

  /// See [PartP.playwriteDeSas].
  static const playwriteDeSas = PartP.playwriteDeSas;

  /// See [PartP.playwriteDeSasTextTheme].
  static const playwriteDeSasTextTheme = PartP.playwriteDeSasTextTheme;

  /// See [PartP.playwriteDeSasGuides].
  static const playwriteDeSasGuides = PartP.playwriteDeSasGuides;

  /// See [PartP.playwriteDeSasGuidesTextTheme].
  static const playwriteDeSasGuidesTextTheme =
      PartP.playwriteDeSasGuidesTextTheme;

  /// See [PartP.playwriteDeVa].
  static const playwriteDeVa = PartP.playwriteDeVa;

  /// See [PartP.playwriteDeVaTextTheme].
  static const playwriteDeVaTextTheme = PartP.playwriteDeVaTextTheme;

  /// See [PartP.playwriteDeVaGuides].
  static const playwriteDeVaGuides = PartP.playwriteDeVaGuides;

  /// See [PartP.playwriteDeVaGuidesTextTheme].
  static const playwriteDeVaGuidesTextTheme =
      PartP.playwriteDeVaGuidesTextTheme;

  /// See [PartP.playwriteDkLoopet].
  static const playwriteDkLoopet = PartP.playwriteDkLoopet;

  /// See [PartP.playwriteDkLoopetTextTheme].
  static const playwriteDkLoopetTextTheme = PartP.playwriteDkLoopetTextTheme;

  /// See [PartP.playwriteDkLoopetGuides].
  static const playwriteDkLoopetGuides = PartP.playwriteDkLoopetGuides;

  /// See [PartP.playwriteDkLoopetGuidesTextTheme].
  static const playwriteDkLoopetGuidesTextTheme =
      PartP.playwriteDkLoopetGuidesTextTheme;

  /// See [PartP.playwriteDkUloopet].
  static const playwriteDkUloopet = PartP.playwriteDkUloopet;

  /// See [PartP.playwriteDkUloopetTextTheme].
  static const playwriteDkUloopetTextTheme = PartP.playwriteDkUloopetTextTheme;

  /// See [PartP.playwriteDkUloopetGuides].
  static const playwriteDkUloopetGuides = PartP.playwriteDkUloopetGuides;

  /// See [PartP.playwriteDkUloopetGuidesTextTheme].
  static const playwriteDkUloopetGuidesTextTheme =
      PartP.playwriteDkUloopetGuidesTextTheme;

  /// See [PartP.playwriteEs].
  static const playwriteEs = PartP.playwriteEs;

  /// See [PartP.playwriteEsTextTheme].
  static const playwriteEsTextTheme = PartP.playwriteEsTextTheme;

  /// See [PartP.playwriteEsDeco].
  static const playwriteEsDeco = PartP.playwriteEsDeco;

  /// See [PartP.playwriteEsDecoTextTheme].
  static const playwriteEsDecoTextTheme = PartP.playwriteEsDecoTextTheme;

  /// See [PartP.playwriteEsDecoGuides].
  static const playwriteEsDecoGuides = PartP.playwriteEsDecoGuides;

  /// See [PartP.playwriteEsDecoGuidesTextTheme].
  static const playwriteEsDecoGuidesTextTheme =
      PartP.playwriteEsDecoGuidesTextTheme;

  /// See [PartP.playwriteEsGuides].
  static const playwriteEsGuides = PartP.playwriteEsGuides;

  /// See [PartP.playwriteEsGuidesTextTheme].
  static const playwriteEsGuidesTextTheme = PartP.playwriteEsGuidesTextTheme;

  /// See [PartP.playwriteFrModerne].
  static const playwriteFrModerne = PartP.playwriteFrModerne;

  /// See [PartP.playwriteFrModerneTextTheme].
  static const playwriteFrModerneTextTheme = PartP.playwriteFrModerneTextTheme;

  /// See [PartP.playwriteFrModerneGuides].
  static const playwriteFrModerneGuides = PartP.playwriteFrModerneGuides;

  /// See [PartP.playwriteFrModerneGuidesTextTheme].
  static const playwriteFrModerneGuidesTextTheme =
      PartP.playwriteFrModerneGuidesTextTheme;

  /// See [PartP.playwriteFrTrad].
  static const playwriteFrTrad = PartP.playwriteFrTrad;

  /// See [PartP.playwriteFrTradTextTheme].
  static const playwriteFrTradTextTheme = PartP.playwriteFrTradTextTheme;

  /// See [PartP.playwriteFrTradGuides].
  static const playwriteFrTradGuides = PartP.playwriteFrTradGuides;

  /// See [PartP.playwriteFrTradGuidesTextTheme].
  static const playwriteFrTradGuidesTextTheme =
      PartP.playwriteFrTradGuidesTextTheme;

  /// See [PartP.playwriteGbJ].
  static const playwriteGbJ = PartP.playwriteGbJ;

  /// See [PartP.playwriteGbJTextTheme].
  static const playwriteGbJTextTheme = PartP.playwriteGbJTextTheme;

  /// See [PartP.playwriteGbJGuides].
  static const playwriteGbJGuides = PartP.playwriteGbJGuides;

  /// See [PartP.playwriteGbJGuidesTextTheme].
  static const playwriteGbJGuidesTextTheme = PartP.playwriteGbJGuidesTextTheme;

  /// See [PartP.playwriteGbS].
  static const playwriteGbS = PartP.playwriteGbS;

  /// See [PartP.playwriteGbSTextTheme].
  static const playwriteGbSTextTheme = PartP.playwriteGbSTextTheme;

  /// See [PartP.playwriteGbSGuides].
  static const playwriteGbSGuides = PartP.playwriteGbSGuides;

  /// See [PartP.playwriteGbSGuidesTextTheme].
  static const playwriteGbSGuidesTextTheme = PartP.playwriteGbSGuidesTextTheme;

  /// See [PartP.playwriteHr].
  static const playwriteHr = PartP.playwriteHr;

  /// See [PartP.playwriteHrTextTheme].
  static const playwriteHrTextTheme = PartP.playwriteHrTextTheme;

  /// See [PartP.playwriteHrGuides].
  static const playwriteHrGuides = PartP.playwriteHrGuides;

  /// See [PartP.playwriteHrGuidesTextTheme].
  static const playwriteHrGuidesTextTheme = PartP.playwriteHrGuidesTextTheme;

  /// See [PartP.playwriteHrLijeva].
  static const playwriteHrLijeva = PartP.playwriteHrLijeva;

  /// See [PartP.playwriteHrLijevaTextTheme].
  static const playwriteHrLijevaTextTheme = PartP.playwriteHrLijevaTextTheme;

  /// See [PartP.playwriteHrLijevaGuides].
  static const playwriteHrLijevaGuides = PartP.playwriteHrLijevaGuides;

  /// See [PartP.playwriteHrLijevaGuidesTextTheme].
  static const playwriteHrLijevaGuidesTextTheme =
      PartP.playwriteHrLijevaGuidesTextTheme;

  /// See [PartP.playwriteHu].
  static const playwriteHu = PartP.playwriteHu;

  /// See [PartP.playwriteHuTextTheme].
  static const playwriteHuTextTheme = PartP.playwriteHuTextTheme;

  /// See [PartP.playwriteHuGuides].
  static const playwriteHuGuides = PartP.playwriteHuGuides;

  /// See [PartP.playwriteHuGuidesTextTheme].
  static const playwriteHuGuidesTextTheme = PartP.playwriteHuGuidesTextTheme;

  /// See [PartP.playwriteId].
  static const playwriteId = PartP.playwriteId;

  /// See [PartP.playwriteIdTextTheme].
  static const playwriteIdTextTheme = PartP.playwriteIdTextTheme;

  /// See [PartP.playwriteIdGuides].
  static const playwriteIdGuides = PartP.playwriteIdGuides;

  /// See [PartP.playwriteIdGuidesTextTheme].
  static const playwriteIdGuidesTextTheme = PartP.playwriteIdGuidesTextTheme;

  /// See [PartP.playwriteIe].
  static const playwriteIe = PartP.playwriteIe;

  /// See [PartP.playwriteIeTextTheme].
  static const playwriteIeTextTheme = PartP.playwriteIeTextTheme;

  /// See [PartP.playwriteIeGuides].
  static const playwriteIeGuides = PartP.playwriteIeGuides;

  /// See [PartP.playwriteIeGuidesTextTheme].
  static const playwriteIeGuidesTextTheme = PartP.playwriteIeGuidesTextTheme;

  /// See [PartP.playwriteIn].
  static const playwriteIn = PartP.playwriteIn;

  /// See [PartP.playwriteInTextTheme].
  static const playwriteInTextTheme = PartP.playwriteInTextTheme;

  /// See [PartP.playwriteInGuides].
  static const playwriteInGuides = PartP.playwriteInGuides;

  /// See [PartP.playwriteInGuidesTextTheme].
  static const playwriteInGuidesTextTheme = PartP.playwriteInGuidesTextTheme;

  /// See [PartP.playwriteIs].
  static const playwriteIs = PartP.playwriteIs;

  /// See [PartP.playwriteIsTextTheme].
  static const playwriteIsTextTheme = PartP.playwriteIsTextTheme;

  /// See [PartP.playwriteIsGuides].
  static const playwriteIsGuides = PartP.playwriteIsGuides;

  /// See [PartP.playwriteIsGuidesTextTheme].
  static const playwriteIsGuidesTextTheme = PartP.playwriteIsGuidesTextTheme;

  /// See [PartP.playwriteItModerna].
  static const playwriteItModerna = PartP.playwriteItModerna;

  /// See [PartP.playwriteItModernaTextTheme].
  static const playwriteItModernaTextTheme = PartP.playwriteItModernaTextTheme;

  /// See [PartP.playwriteItModernaGuides].
  static const playwriteItModernaGuides = PartP.playwriteItModernaGuides;

  /// See [PartP.playwriteItModernaGuidesTextTheme].
  static const playwriteItModernaGuidesTextTheme =
      PartP.playwriteItModernaGuidesTextTheme;

  /// See [PartP.playwriteItTrad].
  static const playwriteItTrad = PartP.playwriteItTrad;

  /// See [PartP.playwriteItTradTextTheme].
  static const playwriteItTradTextTheme = PartP.playwriteItTradTextTheme;

  /// See [PartP.playwriteItTradGuides].
  static const playwriteItTradGuides = PartP.playwriteItTradGuides;

  /// See [PartP.playwriteItTradGuidesTextTheme].
  static const playwriteItTradGuidesTextTheme =
      PartP.playwriteItTradGuidesTextTheme;

  /// See [PartP.playwriteMx].
  static const playwriteMx = PartP.playwriteMx;

  /// See [PartP.playwriteMxTextTheme].
  static const playwriteMxTextTheme = PartP.playwriteMxTextTheme;

  /// See [PartP.playwriteMxGuides].
  static const playwriteMxGuides = PartP.playwriteMxGuides;

  /// See [PartP.playwriteMxGuidesTextTheme].
  static const playwriteMxGuidesTextTheme = PartP.playwriteMxGuidesTextTheme;

  /// See [PartP.playwriteNgModern].
  static const playwriteNgModern = PartP.playwriteNgModern;

  /// See [PartP.playwriteNgModernTextTheme].
  static const playwriteNgModernTextTheme = PartP.playwriteNgModernTextTheme;

  /// See [PartP.playwriteNgModernGuides].
  static const playwriteNgModernGuides = PartP.playwriteNgModernGuides;

  /// See [PartP.playwriteNgModernGuidesTextTheme].
  static const playwriteNgModernGuidesTextTheme =
      PartP.playwriteNgModernGuidesTextTheme;

  /// See [PartP.playwriteNl].
  static const playwriteNl = PartP.playwriteNl;

  /// See [PartP.playwriteNlTextTheme].
  static const playwriteNlTextTheme = PartP.playwriteNlTextTheme;

  /// See [PartP.playwriteNlGuides].
  static const playwriteNlGuides = PartP.playwriteNlGuides;

  /// See [PartP.playwriteNlGuidesTextTheme].
  static const playwriteNlGuidesTextTheme = PartP.playwriteNlGuidesTextTheme;

  /// See [PartP.playwriteNo].
  static const playwriteNo = PartP.playwriteNo;

  /// See [PartP.playwriteNoTextTheme].
  static const playwriteNoTextTheme = PartP.playwriteNoTextTheme;

  /// See [PartP.playwriteNoGuides].
  static const playwriteNoGuides = PartP.playwriteNoGuides;

  /// See [PartP.playwriteNoGuidesTextTheme].
  static const playwriteNoGuidesTextTheme = PartP.playwriteNoGuidesTextTheme;

  /// See [PartP.playwriteNz].
  static const playwriteNz = PartP.playwriteNz;

  /// See [PartP.playwriteNzTextTheme].
  static const playwriteNzTextTheme = PartP.playwriteNzTextTheme;

  /// See [PartP.playwriteNzGuides].
  static const playwriteNzGuides = PartP.playwriteNzGuides;

  /// See [PartP.playwriteNzGuidesTextTheme].
  static const playwriteNzGuidesTextTheme = PartP.playwriteNzGuidesTextTheme;

  /// See [PartP.playwritePe].
  static const playwritePe = PartP.playwritePe;

  /// See [PartP.playwritePeTextTheme].
  static const playwritePeTextTheme = PartP.playwritePeTextTheme;

  /// See [PartP.playwritePeGuides].
  static const playwritePeGuides = PartP.playwritePeGuides;

  /// See [PartP.playwritePeGuidesTextTheme].
  static const playwritePeGuidesTextTheme = PartP.playwritePeGuidesTextTheme;

  /// See [PartP.playwritePl].
  static const playwritePl = PartP.playwritePl;

  /// See [PartP.playwritePlTextTheme].
  static const playwritePlTextTheme = PartP.playwritePlTextTheme;

  /// See [PartP.playwritePlGuides].
  static const playwritePlGuides = PartP.playwritePlGuides;

  /// See [PartP.playwritePlGuidesTextTheme].
  static const playwritePlGuidesTextTheme = PartP.playwritePlGuidesTextTheme;

  /// See [PartP.playwritePt].
  static const playwritePt = PartP.playwritePt;

  /// See [PartP.playwritePtTextTheme].
  static const playwritePtTextTheme = PartP.playwritePtTextTheme;

  /// See [PartP.playwritePtGuides].
  static const playwritePtGuides = PartP.playwritePtGuides;

  /// See [PartP.playwritePtGuidesTextTheme].
  static const playwritePtGuidesTextTheme = PartP.playwritePtGuidesTextTheme;

  /// See [PartP.playwriteRo].
  static const playwriteRo = PartP.playwriteRo;

  /// See [PartP.playwriteRoTextTheme].
  static const playwriteRoTextTheme = PartP.playwriteRoTextTheme;

  /// See [PartP.playwriteRoGuides].
  static const playwriteRoGuides = PartP.playwriteRoGuides;

  /// See [PartP.playwriteRoGuidesTextTheme].
  static const playwriteRoGuidesTextTheme = PartP.playwriteRoGuidesTextTheme;

  /// See [PartP.playwriteSk].
  static const playwriteSk = PartP.playwriteSk;

  /// See [PartP.playwriteSkTextTheme].
  static const playwriteSkTextTheme = PartP.playwriteSkTextTheme;

  /// See [PartP.playwriteSkGuides].
  static const playwriteSkGuides = PartP.playwriteSkGuides;

  /// See [PartP.playwriteSkGuidesTextTheme].
  static const playwriteSkGuidesTextTheme = PartP.playwriteSkGuidesTextTheme;

  /// See [PartP.playwriteTz].
  static const playwriteTz = PartP.playwriteTz;

  /// See [PartP.playwriteTzTextTheme].
  static const playwriteTzTextTheme = PartP.playwriteTzTextTheme;

  /// See [PartP.playwriteTzGuides].
  static const playwriteTzGuides = PartP.playwriteTzGuides;

  /// See [PartP.playwriteTzGuidesTextTheme].
  static const playwriteTzGuidesTextTheme = PartP.playwriteTzGuidesTextTheme;

  /// See [PartP.playwriteUsModern].
  static const playwriteUsModern = PartP.playwriteUsModern;

  /// See [PartP.playwriteUsModernTextTheme].
  static const playwriteUsModernTextTheme = PartP.playwriteUsModernTextTheme;

  /// See [PartP.playwriteUsModernGuides].
  static const playwriteUsModernGuides = PartP.playwriteUsModernGuides;

  /// See [PartP.playwriteUsModernGuidesTextTheme].
  static const playwriteUsModernGuidesTextTheme =
      PartP.playwriteUsModernGuidesTextTheme;

  /// See [PartP.playwriteUsTrad].
  static const playwriteUsTrad = PartP.playwriteUsTrad;

  /// See [PartP.playwriteUsTradTextTheme].
  static const playwriteUsTradTextTheme = PartP.playwriteUsTradTextTheme;

  /// See [PartP.playwriteUsTradGuides].
  static const playwriteUsTradGuides = PartP.playwriteUsTradGuides;

  /// See [PartP.playwriteUsTradGuidesTextTheme].
  static const playwriteUsTradGuidesTextTheme =
      PartP.playwriteUsTradGuidesTextTheme;

  /// See [PartP.playwriteVn].
  static const playwriteVn = PartP.playwriteVn;

  /// See [PartP.playwriteVnTextTheme].
  static const playwriteVnTextTheme = PartP.playwriteVnTextTheme;

  /// See [PartP.playwriteVnGuides].
  static const playwriteVnGuides = PartP.playwriteVnGuides;

  /// See [PartP.playwriteVnGuidesTextTheme].
  static const playwriteVnGuidesTextTheme = PartP.playwriteVnGuidesTextTheme;

  /// See [PartP.playwriteZa].
  static const playwriteZa = PartP.playwriteZa;

  /// See [PartP.playwriteZaTextTheme].
  static const playwriteZaTextTheme = PartP.playwriteZaTextTheme;

  /// See [PartP.playwriteZaGuides].
  static const playwriteZaGuides = PartP.playwriteZaGuides;

  /// See [PartP.playwriteZaGuidesTextTheme].
  static const playwriteZaGuidesTextTheme = PartP.playwriteZaGuidesTextTheme;

  /// See [PartP.plusJakartaSans].
  static const plusJakartaSans = PartP.plusJakartaSans;

  /// See [PartP.plusJakartaSansTextTheme].
  static const plusJakartaSansTextTheme = PartP.plusJakartaSansTextTheme;

  /// See [PartP.pochaevsk].
  static const pochaevsk = PartP.pochaevsk;

  /// See [PartP.pochaevskTextTheme].
  static const pochaevskTextTheme = PartP.pochaevskTextTheme;

  /// See [PartP.podkova].
  static const podkova = PartP.podkova;

  /// See [PartP.podkovaTextTheme].
  static const podkovaTextTheme = PartP.podkovaTextTheme;

  /// See [PartP.poetsenOne].
  static const poetsenOne = PartP.poetsenOne;

  /// See [PartP.poetsenOneTextTheme].
  static const poetsenOneTextTheme = PartP.poetsenOneTextTheme;

  /// See [PartP.poiretOne].
  static const poiretOne = PartP.poiretOne;

  /// See [PartP.poiretOneTextTheme].
  static const poiretOneTextTheme = PartP.poiretOneTextTheme;

  /// See [PartP.pollerOne].
  static const pollerOne = PartP.pollerOne;

  /// See [PartP.pollerOneTextTheme].
  static const pollerOneTextTheme = PartP.pollerOneTextTheme;

  /// See [PartP.poltawskiNowy].
  static const poltawskiNowy = PartP.poltawskiNowy;

  /// See [PartP.poltawskiNowyTextTheme].
  static const poltawskiNowyTextTheme = PartP.poltawskiNowyTextTheme;

  /// See [PartP.poly].
  static const poly = PartP.poly;

  /// See [PartP.polyTextTheme].
  static const polyTextTheme = PartP.polyTextTheme;

  /// See [PartP.pompiere].
  static const pompiere = PartP.pompiere;

  /// See [PartP.pompiereTextTheme].
  static const pompiereTextTheme = PartP.pompiereTextTheme;

  /// See [PartP.ponnala].
  static const ponnala = PartP.ponnala;

  /// See [PartP.ponnalaTextTheme].
  static const ponnalaTextTheme = PartP.ponnalaTextTheme;

  /// See [PartP.ponomar].
  static const ponomar = PartP.ponomar;

  /// See [PartP.ponomarTextTheme].
  static const ponomarTextTheme = PartP.ponomarTextTheme;

  /// See [PartP.pontanoSans].
  static const pontanoSans = PartP.pontanoSans;

  /// See [PartP.pontanoSansTextTheme].
  static const pontanoSansTextTheme = PartP.pontanoSansTextTheme;

  /// See [PartP.poorStory].
  static const poorStory = PartP.poorStory;

  /// See [PartP.poorStoryTextTheme].
  static const poorStoryTextTheme = PartP.poorStoryTextTheme;

  /// See [PartP.poppins].
  static const poppins = PartP.poppins;

  /// See [PartP.poppinsTextTheme].
  static const poppinsTextTheme = PartP.poppinsTextTheme;

  /// See [PartP.portLligatSans].
  static const portLligatSans = PartP.portLligatSans;

  /// See [PartP.portLligatSansTextTheme].
  static const portLligatSansTextTheme = PartP.portLligatSansTextTheme;

  /// See [PartP.portLligatSlab].
  static const portLligatSlab = PartP.portLligatSlab;

  /// See [PartP.portLligatSlabTextTheme].
  static const portLligatSlabTextTheme = PartP.portLligatSlabTextTheme;

  /// See [PartP.pottaOne].
  static const pottaOne = PartP.pottaOne;

  /// See [PartP.pottaOneTextTheme].
  static const pottaOneTextTheme = PartP.pottaOneTextTheme;

  /// See [PartP.pragatiNarrow].
  static const pragatiNarrow = PartP.pragatiNarrow;

  /// See [PartP.pragatiNarrowTextTheme].
  static const pragatiNarrowTextTheme = PartP.pragatiNarrowTextTheme;

  /// See [PartP.praise].
  static const praise = PartP.praise;

  /// See [PartP.praiseTextTheme].
  static const praiseTextTheme = PartP.praiseTextTheme;

  /// See [PartP.prata].
  static const prata = PartP.prata;

  /// See [PartP.prataTextTheme].
  static const prataTextTheme = PartP.prataTextTheme;

  /// See [PartP.preahvihear].
  static const preahvihear = PartP.preahvihear;

  /// See [PartP.preahvihearTextTheme].
  static const preahvihearTextTheme = PartP.preahvihearTextTheme;

  /// See [PartP.pressStart2p].
  static const pressStart2p = PartP.pressStart2p;

  /// See [PartP.pressStart2pTextTheme].
  static const pressStart2pTextTheme = PartP.pressStart2pTextTheme;

  /// See [PartP.pridi].
  static const pridi = PartP.pridi;

  /// See [PartP.pridiTextTheme].
  static const pridiTextTheme = PartP.pridiTextTheme;

  /// See [PartP.princessSofia].
  static const princessSofia = PartP.princessSofia;

  /// See [PartP.princessSofiaTextTheme].
  static const princessSofiaTextTheme = PartP.princessSofiaTextTheme;

  /// See [PartP.prociono].
  static const prociono = PartP.prociono;

  /// See [PartP.procionoTextTheme].
  static const procionoTextTheme = PartP.procionoTextTheme;

  /// See [PartP.prompt].
  static const prompt = PartP.prompt;

  /// See [PartP.promptTextTheme].
  static const promptTextTheme = PartP.promptTextTheme;

  /// See [PartP.prostoOne].
  static const prostoOne = PartP.prostoOne;

  /// See [PartP.prostoOneTextTheme].
  static const prostoOneTextTheme = PartP.prostoOneTextTheme;

  /// See [PartP.protestGuerrilla].
  static const protestGuerrilla = PartP.protestGuerrilla;

  /// See [PartP.protestGuerrillaTextTheme].
  static const protestGuerrillaTextTheme = PartP.protestGuerrillaTextTheme;

  /// See [PartP.protestRevolution].
  static const protestRevolution = PartP.protestRevolution;

  /// See [PartP.protestRevolutionTextTheme].
  static const protestRevolutionTextTheme = PartP.protestRevolutionTextTheme;

  /// See [PartP.protestRiot].
  static const protestRiot = PartP.protestRiot;

  /// See [PartP.protestRiotTextTheme].
  static const protestRiotTextTheme = PartP.protestRiotTextTheme;

  /// See [PartP.protestStrike].
  static const protestStrike = PartP.protestStrike;

  /// See [PartP.protestStrikeTextTheme].
  static const protestStrikeTextTheme = PartP.protestStrikeTextTheme;

  /// See [PartP.prozaLibre].
  static const prozaLibre = PartP.prozaLibre;

  /// See [PartP.prozaLibreTextTheme].
  static const prozaLibreTextTheme = PartP.prozaLibreTextTheme;

  /// See [PartP.publicSans].
  static const publicSans = PartP.publicSans;

  /// See [PartP.publicSansTextTheme].
  static const publicSansTextTheme = PartP.publicSansTextTheme;

  /// See [PartP.puppiesPlay].
  static const puppiesPlay = PartP.puppiesPlay;

  /// See [PartP.puppiesPlayTextTheme].
  static const puppiesPlayTextTheme = PartP.puppiesPlayTextTheme;

  /// See [PartP.puritan].
  static const puritan = PartP.puritan;

  /// See [PartP.puritanTextTheme].
  static const puritanTextTheme = PartP.puritanTextTheme;

  /// See [PartP.purplePurse].
  static const purplePurse = PartP.purplePurse;

  /// See [PartP.purplePurseTextTheme].
  static const purplePurseTextTheme = PartP.purplePurseTextTheme;

  /// See [PartQ.qahiri].
  static const qahiri = PartQ.qahiri;

  /// See [PartQ.qahiriTextTheme].
  static const qahiriTextTheme = PartQ.qahiriTextTheme;

  /// See [PartQ.quando].
  static const quando = PartQ.quando;

  /// See [PartQ.quandoTextTheme].
  static const quandoTextTheme = PartQ.quandoTextTheme;

  /// See [PartQ.quantico].
  static const quantico = PartQ.quantico;

  /// See [PartQ.quanticoTextTheme].
  static const quanticoTextTheme = PartQ.quanticoTextTheme;

  /// See [PartQ.quattrocento].
  static const quattrocento = PartQ.quattrocento;

  /// See [PartQ.quattrocentoTextTheme].
  static const quattrocentoTextTheme = PartQ.quattrocentoTextTheme;

  /// See [PartQ.quattrocentoSans].
  static const quattrocentoSans = PartQ.quattrocentoSans;

  /// See [PartQ.quattrocentoSansTextTheme].
  static const quattrocentoSansTextTheme = PartQ.quattrocentoSansTextTheme;

  /// See [PartQ.questrial].
  static const questrial = PartQ.questrial;

  /// See [PartQ.questrialTextTheme].
  static const questrialTextTheme = PartQ.questrialTextTheme;

  /// See [PartQ.quicksand].
  static const quicksand = PartQ.quicksand;

  /// See [PartQ.quicksandTextTheme].
  static const quicksandTextTheme = PartQ.quicksandTextTheme;

  /// See [PartQ.quintessential].
  static const quintessential = PartQ.quintessential;

  /// See [PartQ.quintessentialTextTheme].
  static const quintessentialTextTheme = PartQ.quintessentialTextTheme;

  /// See [PartQ.qwigley].
  static const qwigley = PartQ.qwigley;

  /// See [PartQ.qwigleyTextTheme].
  static const qwigleyTextTheme = PartQ.qwigleyTextTheme;

  /// See [PartQ.qwitcherGrypen].
  static const qwitcherGrypen = PartQ.qwitcherGrypen;

  /// See [PartQ.qwitcherGrypenTextTheme].
  static const qwitcherGrypenTextTheme = PartQ.qwitcherGrypenTextTheme;

  /// See [PartR.rem].
  static const rem = PartR.rem;

  /// See [PartR.remTextTheme].
  static const remTextTheme = PartR.remTextTheme;

  /// See [PartR.racingSansOne].
  static const racingSansOne = PartR.racingSansOne;

  /// See [PartR.racingSansOneTextTheme].
  static const racingSansOneTextTheme = PartR.racingSansOneTextTheme;

  /// See [PartR.radioCanada].
  static const radioCanada = PartR.radioCanada;

  /// See [PartR.radioCanadaTextTheme].
  static const radioCanadaTextTheme = PartR.radioCanadaTextTheme;

  /// See [PartR.radioCanadaBig].
  static const radioCanadaBig = PartR.radioCanadaBig;

  /// See [PartR.radioCanadaBigTextTheme].
  static const radioCanadaBigTextTheme = PartR.radioCanadaBigTextTheme;

  /// See [PartR.radley].
  static const radley = PartR.radley;

  /// See [PartR.radleyTextTheme].
  static const radleyTextTheme = PartR.radleyTextTheme;

  /// See [PartR.rajdhani].
  static const rajdhani = PartR.rajdhani;

  /// See [PartR.rajdhaniTextTheme].
  static const rajdhaniTextTheme = PartR.rajdhaniTextTheme;

  /// See [PartR.rakkas].
  static const rakkas = PartR.rakkas;

  /// See [PartR.rakkasTextTheme].
  static const rakkasTextTheme = PartR.rakkasTextTheme;

  /// See [PartR.raleway].
  static const raleway = PartR.raleway;

  /// See [PartR.ralewayTextTheme].
  static const ralewayTextTheme = PartR.ralewayTextTheme;

  /// See [PartR.ralewayDots].
  static const ralewayDots = PartR.ralewayDots;

  /// See [PartR.ralewayDotsTextTheme].
  static const ralewayDotsTextTheme = PartR.ralewayDotsTextTheme;

  /// See [PartR.ramabhadra].
  static const ramabhadra = PartR.ramabhadra;

  /// See [PartR.ramabhadraTextTheme].
  static const ramabhadraTextTheme = PartR.ramabhadraTextTheme;

  /// See [PartR.ramaraja].
  static const ramaraja = PartR.ramaraja;

  /// See [PartR.ramarajaTextTheme].
  static const ramarajaTextTheme = PartR.ramarajaTextTheme;

  /// See [PartR.rambla].
  static const rambla = PartR.rambla;

  /// See [PartR.ramblaTextTheme].
  static const ramblaTextTheme = PartR.ramblaTextTheme;

  /// See [PartR.rammettoOne].
  static const rammettoOne = PartR.rammettoOne;

  /// See [PartR.rammettoOneTextTheme].
  static const rammettoOneTextTheme = PartR.rammettoOneTextTheme;

  /// See [PartR.rampartOne].
  static const rampartOne = PartR.rampartOne;

  /// See [PartR.rampartOneTextTheme].
  static const rampartOneTextTheme = PartR.rampartOneTextTheme;

  /// See [PartR.ranchers].
  static const ranchers = PartR.ranchers;

  /// See [PartR.ranchersTextTheme].
  static const ranchersTextTheme = PartR.ranchersTextTheme;

  /// See [PartR.rancho].
  static const rancho = PartR.rancho;

  /// See [PartR.ranchoTextTheme].
  static const ranchoTextTheme = PartR.ranchoTextTheme;

  /// See [PartR.ranga].
  static const ranga = PartR.ranga;

  /// See [PartR.rangaTextTheme].
  static const rangaTextTheme = PartR.rangaTextTheme;

  /// See [PartR.rasa].
  static const rasa = PartR.rasa;

  /// See [PartR.rasaTextTheme].
  static const rasaTextTheme = PartR.rasaTextTheme;

  /// See [PartR.rationale].
  static const rationale = PartR.rationale;

  /// See [PartR.rationaleTextTheme].
  static const rationaleTextTheme = PartR.rationaleTextTheme;

  /// See [PartR.raviPrakash].
  static const raviPrakash = PartR.raviPrakash;

  /// See [PartR.raviPrakashTextTheme].
  static const raviPrakashTextTheme = PartR.raviPrakashTextTheme;

  /// See [PartR.readexPro].
  static const readexPro = PartR.readexPro;

  /// See [PartR.readexProTextTheme].
  static const readexProTextTheme = PartR.readexProTextTheme;

  /// See [PartR.recursive].
  static const recursive = PartR.recursive;

  /// See [PartR.recursiveTextTheme].
  static const recursiveTextTheme = PartR.recursiveTextTheme;

  /// See [PartR.redHatDisplay].
  static const redHatDisplay = PartR.redHatDisplay;

  /// See [PartR.redHatDisplayTextTheme].
  static const redHatDisplayTextTheme = PartR.redHatDisplayTextTheme;

  /// See [PartR.redHatMono].
  static const redHatMono = PartR.redHatMono;

  /// See [PartR.redHatMonoTextTheme].
  static const redHatMonoTextTheme = PartR.redHatMonoTextTheme;

  /// See [PartR.redHatText].
  static const redHatText = PartR.redHatText;

  /// See [PartR.redHatTextTextTheme].
  static const redHatTextTextTheme = PartR.redHatTextTextTheme;

  /// See [PartR.redRose].
  static const redRose = PartR.redRose;

  /// See [PartR.redRoseTextTheme].
  static const redRoseTextTheme = PartR.redRoseTextTheme;

  /// See [PartR.redacted].
  static const redacted = PartR.redacted;

  /// See [PartR.redactedTextTheme].
  static const redactedTextTheme = PartR.redactedTextTheme;

  /// See [PartR.redactedScript].
  static const redactedScript = PartR.redactedScript;

  /// See [PartR.redactedScriptTextTheme].
  static const redactedScriptTextTheme = PartR.redactedScriptTextTheme;

  /// See [PartR.redditMono].
  static const redditMono = PartR.redditMono;

  /// See [PartR.redditMonoTextTheme].
  static const redditMonoTextTheme = PartR.redditMonoTextTheme;

  /// See [PartR.redditSans].
  static const redditSans = PartR.redditSans;

  /// See [PartR.redditSansTextTheme].
  static const redditSansTextTheme = PartR.redditSansTextTheme;

  /// See [PartR.redditSansCondensed].
  static const redditSansCondensed = PartR.redditSansCondensed;

  /// See [PartR.redditSansCondensedTextTheme].
  static const redditSansCondensedTextTheme =
      PartR.redditSansCondensedTextTheme;

  /// See [PartR.redressed].
  static const redressed = PartR.redressed;

  /// See [PartR.redressedTextTheme].
  static const redressedTextTheme = PartR.redressedTextTheme;

  /// See [PartR.reemKufi].
  static const reemKufi = PartR.reemKufi;

  /// See [PartR.reemKufiTextTheme].
  static const reemKufiTextTheme = PartR.reemKufiTextTheme;

  /// See [PartR.reemKufiFun].
  static const reemKufiFun = PartR.reemKufiFun;

  /// See [PartR.reemKufiFunTextTheme].
  static const reemKufiFunTextTheme = PartR.reemKufiFunTextTheme;

  /// See [PartR.reemKufiInk].
  static const reemKufiInk = PartR.reemKufiInk;

  /// See [PartR.reemKufiInkTextTheme].
  static const reemKufiInkTextTheme = PartR.reemKufiInkTextTheme;

  /// See [PartR.reenieBeanie].
  static const reenieBeanie = PartR.reenieBeanie;

  /// See [PartR.reenieBeanieTextTheme].
  static const reenieBeanieTextTheme = PartR.reenieBeanieTextTheme;

  /// See [PartR.reggaeOne].
  static const reggaeOne = PartR.reggaeOne;

  /// See [PartR.reggaeOneTextTheme].
  static const reggaeOneTextTheme = PartR.reggaeOneTextTheme;

  /// See [PartR.rethinkSans].
  static const rethinkSans = PartR.rethinkSans;

  /// See [PartR.rethinkSansTextTheme].
  static const rethinkSansTextTheme = PartR.rethinkSansTextTheme;

  /// See [PartR.revalia].
  static const revalia = PartR.revalia;

  /// See [PartR.revaliaTextTheme].
  static const revaliaTextTheme = PartR.revaliaTextTheme;

  /// See [PartR.rhodiumLibre].
  static const rhodiumLibre = PartR.rhodiumLibre;

  /// See [PartR.rhodiumLibreTextTheme].
  static const rhodiumLibreTextTheme = PartR.rhodiumLibreTextTheme;

  /// See [PartR.ribeye].
  static const ribeye = PartR.ribeye;

  /// See [PartR.ribeyeTextTheme].
  static const ribeyeTextTheme = PartR.ribeyeTextTheme;

  /// See [PartR.ribeyeMarrow].
  static const ribeyeMarrow = PartR.ribeyeMarrow;

  /// See [PartR.ribeyeMarrowTextTheme].
  static const ribeyeMarrowTextTheme = PartR.ribeyeMarrowTextTheme;

  /// See [PartR.righteous].
  static const righteous = PartR.righteous;

  /// See [PartR.righteousTextTheme].
  static const righteousTextTheme = PartR.righteousTextTheme;

  /// See [PartR.risque].
  static const risque = PartR.risque;

  /// See [PartR.risqueTextTheme].
  static const risqueTextTheme = PartR.risqueTextTheme;

  /// See [PartR.roadRage].
  static const roadRage = PartR.roadRage;

  /// See [PartR.roadRageTextTheme].
  static const roadRageTextTheme = PartR.roadRageTextTheme;

  /// See [PartR.roboto].
  static const roboto = PartR.roboto;

  /// See [PartR.robotoTextTheme].
  static const robotoTextTheme = PartR.robotoTextTheme;

  /// See [PartR.robotoFlex].
  static const robotoFlex = PartR.robotoFlex;

  /// See [PartR.robotoFlexTextTheme].
  static const robotoFlexTextTheme = PartR.robotoFlexTextTheme;

  /// See [PartR.robotoMono].
  static const robotoMono = PartR.robotoMono;

  /// See [PartR.robotoMonoTextTheme].
  static const robotoMonoTextTheme = PartR.robotoMonoTextTheme;

  /// See [PartR.robotoSerif].
  static const robotoSerif = PartR.robotoSerif;

  /// See [PartR.robotoSerifTextTheme].
  static const robotoSerifTextTheme = PartR.robotoSerifTextTheme;

  /// See [PartR.robotoSlab].
  static const robotoSlab = PartR.robotoSlab;

  /// See [PartR.robotoSlabTextTheme].
  static const robotoSlabTextTheme = PartR.robotoSlabTextTheme;

  /// See [PartR.rochester].
  static const rochester = PartR.rochester;

  /// See [PartR.rochesterTextTheme].
  static const rochesterTextTheme = PartR.rochesterTextTheme;

  /// See [PartR.rock3d].
  static const rock3d = PartR.rock3d;

  /// See [PartR.rock3dTextTheme].
  static const rock3dTextTheme = PartR.rock3dTextTheme;

  /// See [PartR.rockSalt].
  static const rockSalt = PartR.rockSalt;

  /// See [PartR.rockSaltTextTheme].
  static const rockSaltTextTheme = PartR.rockSaltTextTheme;

  /// See [PartR.rocknRollOne].
  static const rocknRollOne = PartR.rocknRollOne;

  /// See [PartR.rocknRollOneTextTheme].
  static const rocknRollOneTextTheme = PartR.rocknRollOneTextTheme;

  /// See [PartR.rokkitt].
  static const rokkitt = PartR.rokkitt;

  /// See [PartR.rokkittTextTheme].
  static const rokkittTextTheme = PartR.rokkittTextTheme;

  /// See [PartR.romanesco].
  static const romanesco = PartR.romanesco;

  /// See [PartR.romanescoTextTheme].
  static const romanescoTextTheme = PartR.romanescoTextTheme;

  /// See [PartR.ropaSans].
  static const ropaSans = PartR.ropaSans;

  /// See [PartR.ropaSansTextTheme].
  static const ropaSansTextTheme = PartR.ropaSansTextTheme;

  /// See [PartR.rosario].
  static const rosario = PartR.rosario;

  /// See [PartR.rosarioTextTheme].
  static const rosarioTextTheme = PartR.rosarioTextTheme;

  /// See [PartR.rosarivo].
  static const rosarivo = PartR.rosarivo;

  /// See [PartR.rosarivoTextTheme].
  static const rosarivoTextTheme = PartR.rosarivoTextTheme;

  /// See [PartR.rougeScript].
  static const rougeScript = PartR.rougeScript;

  /// See [PartR.rougeScriptTextTheme].
  static const rougeScriptTextTheme = PartR.rougeScriptTextTheme;

  /// See [PartR.rowdies].
  static const rowdies = PartR.rowdies;

  /// See [PartR.rowdiesTextTheme].
  static const rowdiesTextTheme = PartR.rowdiesTextTheme;

  /// See [PartR.rozhaOne].
  static const rozhaOne = PartR.rozhaOne;

  /// See [PartR.rozhaOneTextTheme].
  static const rozhaOneTextTheme = PartR.rozhaOneTextTheme;

  /// See [PartR.rubik].
  static const rubik = PartR.rubik;

  /// See [PartR.rubikTextTheme].
  static const rubikTextTheme = PartR.rubikTextTheme;

  /// See [PartR.rubik80sFade].
  static const rubik80sFade = PartR.rubik80sFade;

  /// See [PartR.rubik80sFadeTextTheme].
  static const rubik80sFadeTextTheme = PartR.rubik80sFadeTextTheme;

  /// See [PartR.rubikBeastly].
  static const rubikBeastly = PartR.rubikBeastly;

  /// See [PartR.rubikBeastlyTextTheme].
  static const rubikBeastlyTextTheme = PartR.rubikBeastlyTextTheme;

  /// See [PartR.rubikBrokenFax].
  static const rubikBrokenFax = PartR.rubikBrokenFax;

  /// See [PartR.rubikBrokenFaxTextTheme].
  static const rubikBrokenFaxTextTheme = PartR.rubikBrokenFaxTextTheme;

  /// See [PartR.rubikBubbles].
  static const rubikBubbles = PartR.rubikBubbles;

  /// See [PartR.rubikBubblesTextTheme].
  static const rubikBubblesTextTheme = PartR.rubikBubblesTextTheme;

  /// See [PartR.rubikBurned].
  static const rubikBurned = PartR.rubikBurned;

  /// See [PartR.rubikBurnedTextTheme].
  static const rubikBurnedTextTheme = PartR.rubikBurnedTextTheme;

  /// See [PartR.rubikDirt].
  static const rubikDirt = PartR.rubikDirt;

  /// See [PartR.rubikDirtTextTheme].
  static const rubikDirtTextTheme = PartR.rubikDirtTextTheme;

  /// See [PartR.rubikDistressed].
  static const rubikDistressed = PartR.rubikDistressed;

  /// See [PartR.rubikDistressedTextTheme].
  static const rubikDistressedTextTheme = PartR.rubikDistressedTextTheme;

  /// See [PartR.rubikDoodleShadow].
  static const rubikDoodleShadow = PartR.rubikDoodleShadow;

  /// See [PartR.rubikDoodleShadowTextTheme].
  static const rubikDoodleShadowTextTheme = PartR.rubikDoodleShadowTextTheme;

  /// See [PartR.rubikDoodleTriangles].
  static const rubikDoodleTriangles = PartR.rubikDoodleTriangles;

  /// See [PartR.rubikDoodleTrianglesTextTheme].
  static const rubikDoodleTrianglesTextTheme =
      PartR.rubikDoodleTrianglesTextTheme;

  /// See [PartR.rubikGemstones].
  static const rubikGemstones = PartR.rubikGemstones;

  /// See [PartR.rubikGemstonesTextTheme].
  static const rubikGemstonesTextTheme = PartR.rubikGemstonesTextTheme;

  /// See [PartR.rubikGlitch].
  static const rubikGlitch = PartR.rubikGlitch;

  /// See [PartR.rubikGlitchTextTheme].
  static const rubikGlitchTextTheme = PartR.rubikGlitchTextTheme;

  /// See [PartR.rubikGlitchPop].
  static const rubikGlitchPop = PartR.rubikGlitchPop;

  /// See [PartR.rubikGlitchPopTextTheme].
  static const rubikGlitchPopTextTheme = PartR.rubikGlitchPopTextTheme;

  /// See [PartR.rubikIso].
  static const rubikIso = PartR.rubikIso;

  /// See [PartR.rubikIsoTextTheme].
  static const rubikIsoTextTheme = PartR.rubikIsoTextTheme;

  /// See [PartR.rubikLines].
  static const rubikLines = PartR.rubikLines;

  /// See [PartR.rubikLinesTextTheme].
  static const rubikLinesTextTheme = PartR.rubikLinesTextTheme;

  /// See [PartR.rubikMaps].
  static const rubikMaps = PartR.rubikMaps;

  /// See [PartR.rubikMapsTextTheme].
  static const rubikMapsTextTheme = PartR.rubikMapsTextTheme;

  /// See [PartR.rubikMarkerHatch].
  static const rubikMarkerHatch = PartR.rubikMarkerHatch;

  /// See [PartR.rubikMarkerHatchTextTheme].
  static const rubikMarkerHatchTextTheme = PartR.rubikMarkerHatchTextTheme;

  /// See [PartR.rubikMaze].
  static const rubikMaze = PartR.rubikMaze;

  /// See [PartR.rubikMazeTextTheme].
  static const rubikMazeTextTheme = PartR.rubikMazeTextTheme;

  /// See [PartR.rubikMicrobe].
  static const rubikMicrobe = PartR.rubikMicrobe;

  /// See [PartR.rubikMicrobeTextTheme].
  static const rubikMicrobeTextTheme = PartR.rubikMicrobeTextTheme;

  /// See [PartR.rubikMonoOne].
  static const rubikMonoOne = PartR.rubikMonoOne;

  /// See [PartR.rubikMonoOneTextTheme].
  static const rubikMonoOneTextTheme = PartR.rubikMonoOneTextTheme;

  /// See [PartR.rubikMoonrocks].
  static const rubikMoonrocks = PartR.rubikMoonrocks;

  /// See [PartR.rubikMoonrocksTextTheme].
  static const rubikMoonrocksTextTheme = PartR.rubikMoonrocksTextTheme;

  /// See [PartR.rubikPixels].
  static const rubikPixels = PartR.rubikPixels;

  /// See [PartR.rubikPixelsTextTheme].
  static const rubikPixelsTextTheme = PartR.rubikPixelsTextTheme;

  /// See [PartR.rubikPuddles].
  static const rubikPuddles = PartR.rubikPuddles;

  /// See [PartR.rubikPuddlesTextTheme].
  static const rubikPuddlesTextTheme = PartR.rubikPuddlesTextTheme;

  /// See [PartR.rubikScribble].
  static const rubikScribble = PartR.rubikScribble;

  /// See [PartR.rubikScribbleTextTheme].
  static const rubikScribbleTextTheme = PartR.rubikScribbleTextTheme;

  /// See [PartR.rubikSprayPaint].
  static const rubikSprayPaint = PartR.rubikSprayPaint;

  /// See [PartR.rubikSprayPaintTextTheme].
  static const rubikSprayPaintTextTheme = PartR.rubikSprayPaintTextTheme;

  /// See [PartR.rubikStorm].
  static const rubikStorm = PartR.rubikStorm;

  /// See [PartR.rubikStormTextTheme].
  static const rubikStormTextTheme = PartR.rubikStormTextTheme;

  /// See [PartR.rubikVinyl].
  static const rubikVinyl = PartR.rubikVinyl;

  /// See [PartR.rubikVinylTextTheme].
  static const rubikVinylTextTheme = PartR.rubikVinylTextTheme;

  /// See [PartR.rubikWetPaint].
  static const rubikWetPaint = PartR.rubikWetPaint;

  /// See [PartR.rubikWetPaintTextTheme].
  static const rubikWetPaintTextTheme = PartR.rubikWetPaintTextTheme;

  /// See [PartR.ruda].
  static const ruda = PartR.ruda;

  /// See [PartR.rudaTextTheme].
  static const rudaTextTheme = PartR.rudaTextTheme;

  /// See [PartR.rufina].
  static const rufina = PartR.rufina;

  /// See [PartR.rufinaTextTheme].
  static const rufinaTextTheme = PartR.rufinaTextTheme;

  /// See [PartR.rugeBoogie].
  static const rugeBoogie = PartR.rugeBoogie;

  /// See [PartR.rugeBoogieTextTheme].
  static const rugeBoogieTextTheme = PartR.rugeBoogieTextTheme;

  /// See [PartR.ruluko].
  static const ruluko = PartR.ruluko;

  /// See [PartR.rulukoTextTheme].
  static const rulukoTextTheme = PartR.rulukoTextTheme;

  /// See [PartR.rumRaisin].
  static const rumRaisin = PartR.rumRaisin;

  /// See [PartR.rumRaisinTextTheme].
  static const rumRaisinTextTheme = PartR.rumRaisinTextTheme;

  /// See [PartR.ruslanDisplay].
  static const ruslanDisplay = PartR.ruslanDisplay;

  /// See [PartR.ruslanDisplayTextTheme].
  static const ruslanDisplayTextTheme = PartR.ruslanDisplayTextTheme;

  /// See [PartR.russoOne].
  static const russoOne = PartR.russoOne;

  /// See [PartR.russoOneTextTheme].
  static const russoOneTextTheme = PartR.russoOneTextTheme;

  /// See [PartR.ruthie].
  static const ruthie = PartR.ruthie;

  /// See [PartR.ruthieTextTheme].
  static const ruthieTextTheme = PartR.ruthieTextTheme;

  /// See [PartR.ruwudu].
  static const ruwudu = PartR.ruwudu;

  /// See [PartR.ruwuduTextTheme].
  static const ruwuduTextTheme = PartR.ruwuduTextTheme;

  /// See [PartR.rye].
  static const rye = PartR.rye;

  /// See [PartR.ryeTextTheme].
  static const ryeTextTheme = PartR.ryeTextTheme;

  /// See [PartS.stixTwoText].
  static const stixTwoText = PartS.stixTwoText;

  /// See [PartS.stixTwoTextTextTheme].
  static const stixTwoTextTextTheme = PartS.stixTwoTextTextTheme;

  /// See [PartS.suse].
  static const suse = PartS.suse;

  /// See [PartS.suseTextTheme].
  static const suseTextTheme = PartS.suseTextTheme;

  /// See [PartS.suseMono].
  static const suseMono = PartS.suseMono;

  /// See [PartS.suseMonoTextTheme].
  static const suseMonoTextTheme = PartS.suseMonoTextTheme;

  /// See [PartS.sacramento].
  static const sacramento = PartS.sacramento;

  /// See [PartS.sacramentoTextTheme].
  static const sacramentoTextTheme = PartS.sacramentoTextTheme;

  /// See [PartS.sahitya].
  static const sahitya = PartS.sahitya;

  /// See [PartS.sahityaTextTheme].
  static const sahityaTextTheme = PartS.sahityaTextTheme;

  /// See [PartS.sail].
  static const sail = PartS.sail;

  /// See [PartS.sailTextTheme].
  static const sailTextTheme = PartS.sailTextTheme;

  /// See [PartS.saira].
  static const saira = PartS.saira;

  /// See [PartS.sairaTextTheme].
  static const sairaTextTheme = PartS.sairaTextTheme;

  /// See [PartS.sairaStencilOne].
  static const sairaStencilOne = PartS.sairaStencilOne;

  /// See [PartS.sairaStencilOneTextTheme].
  static const sairaStencilOneTextTheme = PartS.sairaStencilOneTextTheme;

  /// See [PartS.salsa].
  static const salsa = PartS.salsa;

  /// See [PartS.salsaTextTheme].
  static const salsaTextTheme = PartS.salsaTextTheme;

  /// See [PartS.sanchez].
  static const sanchez = PartS.sanchez;

  /// See [PartS.sanchezTextTheme].
  static const sanchezTextTheme = PartS.sanchezTextTheme;

  /// See [PartS.sancreek].
  static const sancreek = PartS.sancreek;

  /// See [PartS.sancreekTextTheme].
  static const sancreekTextTheme = PartS.sancreekTextTheme;

  /// See [PartS.sankofaDisplay].
  static const sankofaDisplay = PartS.sankofaDisplay;

  /// See [PartS.sankofaDisplayTextTheme].
  static const sankofaDisplayTextTheme = PartS.sankofaDisplayTextTheme;

  /// See [PartS.sansation].
  static const sansation = PartS.sansation;

  /// See [PartS.sansationTextTheme].
  static const sansationTextTheme = PartS.sansationTextTheme;

  /// See [PartS.sansita].
  static const sansita = PartS.sansita;

  /// See [PartS.sansitaTextTheme].
  static const sansitaTextTheme = PartS.sansitaTextTheme;

  /// See [PartS.sansitaSwashed].
  static const sansitaSwashed = PartS.sansitaSwashed;

  /// See [PartS.sansitaSwashedTextTheme].
  static const sansitaSwashedTextTheme = PartS.sansitaSwashedTextTheme;

  /// See [PartS.sarabun].
  static const sarabun = PartS.sarabun;

  /// See [PartS.sarabunTextTheme].
  static const sarabunTextTheme = PartS.sarabunTextTheme;

  /// See [PartS.sarala].
  static const sarala = PartS.sarala;

  /// See [PartS.saralaTextTheme].
  static const saralaTextTheme = PartS.saralaTextTheme;

  /// See [PartS.sarina].
  static const sarina = PartS.sarina;

  /// See [PartS.sarinaTextTheme].
  static const sarinaTextTheme = PartS.sarinaTextTheme;

  /// See [PartS.sarpanch].
  static const sarpanch = PartS.sarpanch;

  /// See [PartS.sarpanchTextTheme].
  static const sarpanchTextTheme = PartS.sarpanchTextTheme;

  /// See [PartS.sassyFrass].
  static const sassyFrass = PartS.sassyFrass;

  /// See [PartS.sassyFrassTextTheme].
  static const sassyFrassTextTheme = PartS.sassyFrassTextTheme;

  /// See [PartS.satisfy].
  static const satisfy = PartS.satisfy;

  /// See [PartS.satisfyTextTheme].
  static const satisfyTextTheme = PartS.satisfyTextTheme;

  /// See [PartS.savate].
  static const savate = PartS.savate;

  /// See [PartS.savateTextTheme].
  static const savateTextTheme = PartS.savateTextTheme;

  /// See [PartS.sawarabiGothic].
  static const sawarabiGothic = PartS.sawarabiGothic;

  /// See [PartS.sawarabiGothicTextTheme].
  static const sawarabiGothicTextTheme = PartS.sawarabiGothicTextTheme;

  /// See [PartS.sawarabiMincho].
  static const sawarabiMincho = PartS.sawarabiMincho;

  /// See [PartS.sawarabiMinchoTextTheme].
  static const sawarabiMinchoTextTheme = PartS.sawarabiMinchoTextTheme;

  /// See [PartS.scada].
  static const scada = PartS.scada;

  /// See [PartS.scadaTextTheme].
  static const scadaTextTheme = PartS.scadaTextTheme;

  /// See [PartS.scheherazadeNew].
  static const scheherazadeNew = PartS.scheherazadeNew;

  /// See [PartS.scheherazadeNewTextTheme].
  static const scheherazadeNewTextTheme = PartS.scheherazadeNewTextTheme;

  /// See [PartS.schibstedGrotesk].
  static const schibstedGrotesk = PartS.schibstedGrotesk;

  /// See [PartS.schibstedGroteskTextTheme].
  static const schibstedGroteskTextTheme = PartS.schibstedGroteskTextTheme;

  /// See [PartS.schoolbell].
  static const schoolbell = PartS.schoolbell;

  /// See [PartS.schoolbellTextTheme].
  static const schoolbellTextTheme = PartS.schoolbellTextTheme;

  /// See [PartS.scopeOne].
  static const scopeOne = PartS.scopeOne;

  /// See [PartS.scopeOneTextTheme].
  static const scopeOneTextTheme = PartS.scopeOneTextTheme;

  /// See [PartS.seaweedScript].
  static const seaweedScript = PartS.seaweedScript;

  /// See [PartS.seaweedScriptTextTheme].
  static const seaweedScriptTextTheme = PartS.seaweedScriptTextTheme;

  /// See [PartS.secularOne].
  static const secularOne = PartS.secularOne;

  /// See [PartS.secularOneTextTheme].
  static const secularOneTextTheme = PartS.secularOneTextTheme;

  /// See [PartS.sedan].
  static const sedan = PartS.sedan;

  /// See [PartS.sedanTextTheme].
  static const sedanTextTheme = PartS.sedanTextTheme;

  /// See [PartS.sedanSc].
  static const sedanSc = PartS.sedanSc;

  /// See [PartS.sedanScTextTheme].
  static const sedanScTextTheme = PartS.sedanScTextTheme;

  /// See [PartS.sedgwickAve].
  static const sedgwickAve = PartS.sedgwickAve;

  /// See [PartS.sedgwickAveTextTheme].
  static const sedgwickAveTextTheme = PartS.sedgwickAveTextTheme;

  /// See [PartS.sedgwickAveDisplay].
  static const sedgwickAveDisplay = PartS.sedgwickAveDisplay;

  /// See [PartS.sedgwickAveDisplayTextTheme].
  static const sedgwickAveDisplayTextTheme = PartS.sedgwickAveDisplayTextTheme;

  /// See [PartS.sen].
  static const sen = PartS.sen;

  /// See [PartS.senTextTheme].
  static const senTextTheme = PartS.senTextTheme;

  /// See [PartS.sendFlowers].
  static const sendFlowers = PartS.sendFlowers;

  /// See [PartS.sendFlowersTextTheme].
  static const sendFlowersTextTheme = PartS.sendFlowersTextTheme;

  /// See [PartS.sevillana].
  static const sevillana = PartS.sevillana;

  /// See [PartS.sevillanaTextTheme].
  static const sevillanaTextTheme = PartS.sevillanaTextTheme;

  /// See [PartS.seymourOne].
  static const seymourOne = PartS.seymourOne;

  /// See [PartS.seymourOneTextTheme].
  static const seymourOneTextTheme = PartS.seymourOneTextTheme;

  /// See [PartS.shadowsIntoLight].
  static const shadowsIntoLight = PartS.shadowsIntoLight;

  /// See [PartS.shadowsIntoLightTextTheme].
  static const shadowsIntoLightTextTheme = PartS.shadowsIntoLightTextTheme;

  /// See [PartS.shadowsIntoLightTwo].
  static const shadowsIntoLightTwo = PartS.shadowsIntoLightTwo;

  /// See [PartS.shadowsIntoLightTwoTextTheme].
  static const shadowsIntoLightTwoTextTheme =
      PartS.shadowsIntoLightTwoTextTheme;

  /// See [PartS.shafarik].
  static const shafarik = PartS.shafarik;

  /// See [PartS.shafarikTextTheme].
  static const shafarikTextTheme = PartS.shafarikTextTheme;

  /// See [PartS.shalimar].
  static const shalimar = PartS.shalimar;

  /// See [PartS.shalimarTextTheme].
  static const shalimarTextTheme = PartS.shalimarTextTheme;

  /// See [PartS.shantellSans].
  static const shantellSans = PartS.shantellSans;

  /// See [PartS.shantellSansTextTheme].
  static const shantellSansTextTheme = PartS.shantellSansTextTheme;

  /// See [PartS.shanti].
  static const shanti = PartS.shanti;

  /// See [PartS.shantiTextTheme].
  static const shantiTextTheme = PartS.shantiTextTheme;

  /// See [PartS.share].
  static const share = PartS.share;

  /// See [PartS.shareTextTheme].
  static const shareTextTheme = PartS.shareTextTheme;

  /// See [PartS.shareTech].
  static const shareTech = PartS.shareTech;

  /// See [PartS.shareTechTextTheme].
  static const shareTechTextTheme = PartS.shareTechTextTheme;

  /// See [PartS.shareTechMono].
  static const shareTechMono = PartS.shareTechMono;

  /// See [PartS.shareTechMonoTextTheme].
  static const shareTechMonoTextTheme = PartS.shareTechMonoTextTheme;

  /// See [PartS.shipporiAntique].
  static const shipporiAntique = PartS.shipporiAntique;

  /// See [PartS.shipporiAntiqueTextTheme].
  static const shipporiAntiqueTextTheme = PartS.shipporiAntiqueTextTheme;

  /// See [PartS.shipporiAntiqueB1].
  static const shipporiAntiqueB1 = PartS.shipporiAntiqueB1;

  /// See [PartS.shipporiAntiqueB1TextTheme].
  static const shipporiAntiqueB1TextTheme = PartS.shipporiAntiqueB1TextTheme;

  /// See [PartS.shipporiMincho].
  static const shipporiMincho = PartS.shipporiMincho;

  /// See [PartS.shipporiMinchoTextTheme].
  static const shipporiMinchoTextTheme = PartS.shipporiMinchoTextTheme;

  /// See [PartS.shipporiMinchoB1].
  static const shipporiMinchoB1 = PartS.shipporiMinchoB1;

  /// See [PartS.shipporiMinchoB1TextTheme].
  static const shipporiMinchoB1TextTheme = PartS.shipporiMinchoB1TextTheme;

  /// See [PartS.shizuru].
  static const shizuru = PartS.shizuru;

  /// See [PartS.shizuruTextTheme].
  static const shizuruTextTheme = PartS.shizuruTextTheme;

  /// See [PartS.shojumaru].
  static const shojumaru = PartS.shojumaru;

  /// See [PartS.shojumaruTextTheme].
  static const shojumaruTextTheme = PartS.shojumaruTextTheme;

  /// See [PartS.shortStack].
  static const shortStack = PartS.shortStack;

  /// See [PartS.shortStackTextTheme].
  static const shortStackTextTheme = PartS.shortStackTextTheme;

  /// See [PartS.shrikhand].
  static const shrikhand = PartS.shrikhand;

  /// See [PartS.shrikhandTextTheme].
  static const shrikhandTextTheme = PartS.shrikhandTextTheme;

  /// See [PartS.siemreap].
  static const siemreap = PartS.siemreap;

  /// See [PartS.siemreapTextTheme].
  static const siemreapTextTheme = PartS.siemreapTextTheme;

  /// See [PartS.sigmar].
  static const sigmar = PartS.sigmar;

  /// See [PartS.sigmarTextTheme].
  static const sigmarTextTheme = PartS.sigmarTextTheme;

  /// See [PartS.sigmarOne].
  static const sigmarOne = PartS.sigmarOne;

  /// See [PartS.sigmarOneTextTheme].
  static const sigmarOneTextTheme = PartS.sigmarOneTextTheme;

  /// See [PartS.signika].
  static const signika = PartS.signika;

  /// See [PartS.signikaTextTheme].
  static const signikaTextTheme = PartS.signikaTextTheme;

  /// See [PartS.signikaNegative].
  static const signikaNegative = PartS.signikaNegative;

  /// See [PartS.signikaNegativeTextTheme].
  static const signikaNegativeTextTheme = PartS.signikaNegativeTextTheme;

  /// See [PartS.silkscreen].
  static const silkscreen = PartS.silkscreen;

  /// See [PartS.silkscreenTextTheme].
  static const silkscreenTextTheme = PartS.silkscreenTextTheme;

  /// See [PartS.simonetta].
  static const simonetta = PartS.simonetta;

  /// See [PartS.simonettaTextTheme].
  static const simonettaTextTheme = PartS.simonettaTextTheme;

  /// See [PartS.singleDay].
  static const singleDay = PartS.singleDay;

  /// See [PartS.singleDayTextTheme].
  static const singleDayTextTheme = PartS.singleDayTextTheme;

  /// See [PartS.sintony].
  static const sintony = PartS.sintony;

  /// See [PartS.sintonyTextTheme].
  static const sintonyTextTheme = PartS.sintonyTextTheme;

  /// See [PartS.sirinStencil].
  static const sirinStencil = PartS.sirinStencil;

  /// See [PartS.sirinStencilTextTheme].
  static const sirinStencilTextTheme = PartS.sirinStencilTextTheme;

  /// See [PartS.sirivennela].
  static const sirivennela = PartS.sirivennela;

  /// See [PartS.sirivennelaTextTheme].
  static const sirivennelaTextTheme = PartS.sirivennelaTextTheme;

  /// See [PartS.sixCaps].
  static const sixCaps = PartS.sixCaps;

  /// See [PartS.sixCapsTextTheme].
  static const sixCapsTextTheme = PartS.sixCapsTextTheme;

  /// See [PartS.sixtyfour].
  static const sixtyfour = PartS.sixtyfour;

  /// See [PartS.sixtyfourTextTheme].
  static const sixtyfourTextTheme = PartS.sixtyfourTextTheme;

  /// See [PartS.sixtyfourConvergence].
  static const sixtyfourConvergence = PartS.sixtyfourConvergence;

  /// See [PartS.sixtyfourConvergenceTextTheme].
  static const sixtyfourConvergenceTextTheme =
      PartS.sixtyfourConvergenceTextTheme;

  /// See [PartS.skranji].
  static const skranji = PartS.skranji;

  /// See [PartS.skranjiTextTheme].
  static const skranjiTextTheme = PartS.skranjiTextTheme;

  /// See [PartS.slabo13px].
  static const slabo13px = PartS.slabo13px;

  /// See [PartS.slabo13pxTextTheme].
  static const slabo13pxTextTheme = PartS.slabo13pxTextTheme;

  /// See [PartS.slabo27px].
  static const slabo27px = PartS.slabo27px;

  /// See [PartS.slabo27pxTextTheme].
  static const slabo27pxTextTheme = PartS.slabo27pxTextTheme;

  /// See [PartS.slackey].
  static const slackey = PartS.slackey;

  /// See [PartS.slackeyTextTheme].
  static const slackeyTextTheme = PartS.slackeyTextTheme;

  /// See [PartS.slacksideOne].
  static const slacksideOne = PartS.slacksideOne;

  /// See [PartS.slacksideOneTextTheme].
  static const slacksideOneTextTheme = PartS.slacksideOneTextTheme;

  /// See [PartS.smokum].
  static const smokum = PartS.smokum;

  /// See [PartS.smokumTextTheme].
  static const smokumTextTheme = PartS.smokumTextTheme;

  /// See [PartS.smooch].
  static const smooch = PartS.smooch;

  /// See [PartS.smoochTextTheme].
  static const smoochTextTheme = PartS.smoochTextTheme;

  /// See [PartS.smoochSans].
  static const smoochSans = PartS.smoochSans;

  /// See [PartS.smoochSansTextTheme].
  static const smoochSansTextTheme = PartS.smoochSansTextTheme;

  /// See [PartS.smythe].
  static const smythe = PartS.smythe;

  /// See [PartS.smytheTextTheme].
  static const smytheTextTheme = PartS.smytheTextTheme;

  /// See [PartS.sniglet].
  static const sniglet = PartS.sniglet;

  /// See [PartS.snigletTextTheme].
  static const snigletTextTheme = PartS.snigletTextTheme;

  /// See [PartS.snippet].
  static const snippet = PartS.snippet;

  /// See [PartS.snippetTextTheme].
  static const snippetTextTheme = PartS.snippetTextTheme;

  /// See [PartS.snowburstOne].
  static const snowburstOne = PartS.snowburstOne;

  /// See [PartS.snowburstOneTextTheme].
  static const snowburstOneTextTheme = PartS.snowburstOneTextTheme;

  /// See [PartS.sofadiOne].
  static const sofadiOne = PartS.sofadiOne;

  /// See [PartS.sofadiOneTextTheme].
  static const sofadiOneTextTheme = PartS.sofadiOneTextTheme;

  /// See [PartS.sofia].
  static const sofia = PartS.sofia;

  /// See [PartS.sofiaTextTheme].
  static const sofiaTextTheme = PartS.sofiaTextTheme;

  /// See [PartS.sofiaSans].
  static const sofiaSans = PartS.sofiaSans;

  /// See [PartS.sofiaSansTextTheme].
  static const sofiaSansTextTheme = PartS.sofiaSansTextTheme;

  /// See [PartS.sofiaSansCondensed].
  static const sofiaSansCondensed = PartS.sofiaSansCondensed;

  /// See [PartS.sofiaSansCondensedTextTheme].
  static const sofiaSansCondensedTextTheme = PartS.sofiaSansCondensedTextTheme;

  /// See [PartS.sofiaSansExtraCondensed].
  static const sofiaSansExtraCondensed = PartS.sofiaSansExtraCondensed;

  /// See [PartS.sofiaSansExtraCondensedTextTheme].
  static const sofiaSansExtraCondensedTextTheme =
      PartS.sofiaSansExtraCondensedTextTheme;

  /// See [PartS.sofiaSansSemiCondensed].
  static const sofiaSansSemiCondensed = PartS.sofiaSansSemiCondensed;

  /// See [PartS.sofiaSansSemiCondensedTextTheme].
  static const sofiaSansSemiCondensedTextTheme =
      PartS.sofiaSansSemiCondensedTextTheme;

  /// See [PartS.solitreo].
  static const solitreo = PartS.solitreo;

  /// See [PartS.solitreoTextTheme].
  static const solitreoTextTheme = PartS.solitreoTextTheme;

  /// See [PartS.solway].
  static const solway = PartS.solway;

  /// See [PartS.solwayTextTheme].
  static const solwayTextTheme = PartS.solwayTextTheme;

  /// See [PartS.sometypeMono].
  static const sometypeMono = PartS.sometypeMono;

  /// See [PartS.sometypeMonoTextTheme].
  static const sometypeMonoTextTheme = PartS.sometypeMonoTextTheme;

  /// See [PartS.songMyung].
  static const songMyung = PartS.songMyung;

  /// See [PartS.songMyungTextTheme].
  static const songMyungTextTheme = PartS.songMyungTextTheme;

  /// See [PartS.sono].
  static const sono = PartS.sono;

  /// See [PartS.sonoTextTheme].
  static const sonoTextTheme = PartS.sonoTextTheme;

  /// See [PartS.sonsieOne].
  static const sonsieOne = PartS.sonsieOne;

  /// See [PartS.sonsieOneTextTheme].
  static const sonsieOneTextTheme = PartS.sonsieOneTextTheme;

  /// See [PartS.sora].
  static const sora = PartS.sora;

  /// See [PartS.soraTextTheme].
  static const soraTextTheme = PartS.soraTextTheme;

  /// See [PartS.sortsMillGoudy].
  static const sortsMillGoudy = PartS.sortsMillGoudy;

  /// See [PartS.sortsMillGoudyTextTheme].
  static const sortsMillGoudyTextTheme = PartS.sortsMillGoudyTextTheme;

  /// See [PartS.sourGummy].
  static const sourGummy = PartS.sourGummy;

  /// See [PartS.sourGummyTextTheme].
  static const sourGummyTextTheme = PartS.sourGummyTextTheme;

  /// See [PartS.sourceCodePro].
  static const sourceCodePro = PartS.sourceCodePro;

  /// See [PartS.sourceCodeProTextTheme].
  static const sourceCodeProTextTheme = PartS.sourceCodeProTextTheme;

  /// See [PartS.sourceSans3].
  static const sourceSans3 = PartS.sourceSans3;

  /// See [PartS.sourceSans3TextTheme].
  static const sourceSans3TextTheme = PartS.sourceSans3TextTheme;

  /// See [PartS.sourceSerif4].
  static const sourceSerif4 = PartS.sourceSerif4;

  /// See [PartS.sourceSerif4TextTheme].
  static const sourceSerif4TextTheme = PartS.sourceSerif4TextTheme;

  /// See [PartS.spaceGrotesk].
  static const spaceGrotesk = PartS.spaceGrotesk;

  /// See [PartS.spaceGroteskTextTheme].
  static const spaceGroteskTextTheme = PartS.spaceGroteskTextTheme;

  /// See [PartS.spaceMono].
  static const spaceMono = PartS.spaceMono;

  /// See [PartS.spaceMonoTextTheme].
  static const spaceMonoTextTheme = PartS.spaceMonoTextTheme;

  /// See [PartS.specialElite].
  static const specialElite = PartS.specialElite;

  /// See [PartS.specialEliteTextTheme].
  static const specialEliteTextTheme = PartS.specialEliteTextTheme;

  /// See [PartS.specialGothic].
  static const specialGothic = PartS.specialGothic;

  /// See [PartS.specialGothicTextTheme].
  static const specialGothicTextTheme = PartS.specialGothicTextTheme;

  /// See [PartS.specialGothicCondensedOne].
  static const specialGothicCondensedOne = PartS.specialGothicCondensedOne;

  /// See [PartS.specialGothicCondensedOneTextTheme].
  static const specialGothicCondensedOneTextTheme =
      PartS.specialGothicCondensedOneTextTheme;

  /// See [PartS.specialGothicExpandedOne].
  static const specialGothicExpandedOne = PartS.specialGothicExpandedOne;

  /// See [PartS.specialGothicExpandedOneTextTheme].
  static const specialGothicExpandedOneTextTheme =
      PartS.specialGothicExpandedOneTextTheme;

  /// See [PartS.spectral].
  static const spectral = PartS.spectral;

  /// See [PartS.spectralTextTheme].
  static const spectralTextTheme = PartS.spectralTextTheme;

  /// See [PartS.spectralSc].
  static const spectralSc = PartS.spectralSc;

  /// See [PartS.spectralScTextTheme].
  static const spectralScTextTheme = PartS.spectralScTextTheme;

  /// See [PartS.spicyRice].
  static const spicyRice = PartS.spicyRice;

  /// See [PartS.spicyRiceTextTheme].
  static const spicyRiceTextTheme = PartS.spicyRiceTextTheme;

  /// See [PartS.spinnaker].
  static const spinnaker = PartS.spinnaker;

  /// See [PartS.spinnakerTextTheme].
  static const spinnakerTextTheme = PartS.spinnakerTextTheme;

  /// See [PartS.spirax].
  static const spirax = PartS.spirax;

  /// See [PartS.spiraxTextTheme].
  static const spiraxTextTheme = PartS.spiraxTextTheme;

  /// See [PartS.splash].
  static const splash = PartS.splash;

  /// See [PartS.splashTextTheme].
  static const splashTextTheme = PartS.splashTextTheme;

  /// See [PartS.splineSans].
  static const splineSans = PartS.splineSans;

  /// See [PartS.splineSansTextTheme].
  static const splineSansTextTheme = PartS.splineSansTextTheme;

  /// See [PartS.splineSansMono].
  static const splineSansMono = PartS.splineSansMono;

  /// See [PartS.splineSansMonoTextTheme].
  static const splineSansMonoTextTheme = PartS.splineSansMonoTextTheme;

  /// See [PartS.squadaOne].
  static const squadaOne = PartS.squadaOne;

  /// See [PartS.squadaOneTextTheme].
  static const squadaOneTextTheme = PartS.squadaOneTextTheme;

  /// See [PartS.squarePeg].
  static const squarePeg = PartS.squarePeg;

  /// See [PartS.squarePegTextTheme].
  static const squarePegTextTheme = PartS.squarePegTextTheme;

  /// See [PartS.sreeKrushnadevaraya].
  static const sreeKrushnadevaraya = PartS.sreeKrushnadevaraya;

  /// See [PartS.sreeKrushnadevarayaTextTheme].
  static const sreeKrushnadevarayaTextTheme =
      PartS.sreeKrushnadevarayaTextTheme;

  /// See [PartS.sriracha].
  static const sriracha = PartS.sriracha;

  /// See [PartS.srirachaTextTheme].
  static const srirachaTextTheme = PartS.srirachaTextTheme;

  /// See [PartS.srisakdi].
  static const srisakdi = PartS.srisakdi;

  /// See [PartS.srisakdiTextTheme].
  static const srisakdiTextTheme = PartS.srisakdiTextTheme;

  /// See [PartS.staatliches].
  static const staatliches = PartS.staatliches;

  /// See [PartS.staatlichesTextTheme].
  static const staatlichesTextTheme = PartS.staatlichesTextTheme;

  /// See [PartS.stalemate].
  static const stalemate = PartS.stalemate;

  /// See [PartS.stalemateTextTheme].
  static const stalemateTextTheme = PartS.stalemateTextTheme;

  /// See [PartS.stalinistOne].
  static const stalinistOne = PartS.stalinistOne;

  /// See [PartS.stalinistOneTextTheme].
  static const stalinistOneTextTheme = PartS.stalinistOneTextTheme;

  /// See [PartS.stardosStencil].
  static const stardosStencil = PartS.stardosStencil;

  /// See [PartS.stardosStencilTextTheme].
  static const stardosStencilTextTheme = PartS.stardosStencilTextTheme;

  /// See [PartS.stick].
  static const stick = PartS.stick;

  /// See [PartS.stickTextTheme].
  static const stickTextTheme = PartS.stickTextTheme;

  /// See [PartS.stickNoBills].
  static const stickNoBills = PartS.stickNoBills;

  /// See [PartS.stickNoBillsTextTheme].
  static const stickNoBillsTextTheme = PartS.stickNoBillsTextTheme;

  /// See [PartS.stintUltraCondensed].
  static const stintUltraCondensed = PartS.stintUltraCondensed;

  /// See [PartS.stintUltraCondensedTextTheme].
  static const stintUltraCondensedTextTheme =
      PartS.stintUltraCondensedTextTheme;

  /// See [PartS.stintUltraExpanded].
  static const stintUltraExpanded = PartS.stintUltraExpanded;

  /// See [PartS.stintUltraExpandedTextTheme].
  static const stintUltraExpandedTextTheme = PartS.stintUltraExpandedTextTheme;

  /// See [PartS.stoke].
  static const stoke = PartS.stoke;

  /// See [PartS.stokeTextTheme].
  static const stokeTextTheme = PartS.stokeTextTheme;

  /// See [PartS.storyScript].
  static const storyScript = PartS.storyScript;

  /// See [PartS.storyScriptTextTheme].
  static const storyScriptTextTheme = PartS.storyScriptTextTheme;

  /// See [PartS.strait].
  static const strait = PartS.strait;

  /// See [PartS.straitTextTheme].
  static const straitTextTheme = PartS.straitTextTheme;

  /// See [PartS.styleScript].
  static const styleScript = PartS.styleScript;

  /// See [PartS.styleScriptTextTheme].
  static const styleScriptTextTheme = PartS.styleScriptTextTheme;

  /// See [PartS.stylish].
  static const stylish = PartS.stylish;

  /// See [PartS.stylishTextTheme].
  static const stylishTextTheme = PartS.stylishTextTheme;

  /// See [PartS.sueEllenFrancisco].
  static const sueEllenFrancisco = PartS.sueEllenFrancisco;

  /// See [PartS.sueEllenFranciscoTextTheme].
  static const sueEllenFranciscoTextTheme = PartS.sueEllenFranciscoTextTheme;

  /// See [PartS.suezOne].
  static const suezOne = PartS.suezOne;

  /// See [PartS.suezOneTextTheme].
  static const suezOneTextTheme = PartS.suezOneTextTheme;

  /// See [PartS.sulphurPoint].
  static const sulphurPoint = PartS.sulphurPoint;

  /// See [PartS.sulphurPointTextTheme].
  static const sulphurPointTextTheme = PartS.sulphurPointTextTheme;

  /// See [PartS.sumana].
  static const sumana = PartS.sumana;

  /// See [PartS.sumanaTextTheme].
  static const sumanaTextTheme = PartS.sumanaTextTheme;

  /// See [PartS.sunflower].
  static const sunflower = PartS.sunflower;

  /// See [PartS.sunflowerTextTheme].
  static const sunflowerTextTheme = PartS.sunflowerTextTheme;

  /// See [PartS.sunshiney].
  static const sunshiney = PartS.sunshiney;

  /// See [PartS.sunshineyTextTheme].
  static const sunshineyTextTheme = PartS.sunshineyTextTheme;

  /// See [PartS.supermercadoOne].
  static const supermercadoOne = PartS.supermercadoOne;

  /// See [PartS.supermercadoOneTextTheme].
  static const supermercadoOneTextTheme = PartS.supermercadoOneTextTheme;

  /// See [PartS.sura].
  static const sura = PartS.sura;

  /// See [PartS.suraTextTheme].
  static const suraTextTheme = PartS.suraTextTheme;

  /// See [PartS.suranna].
  static const suranna = PartS.suranna;

  /// See [PartS.surannaTextTheme].
  static const surannaTextTheme = PartS.surannaTextTheme;

  /// See [PartS.suravaram].
  static const suravaram = PartS.suravaram;

  /// See [PartS.suravaramTextTheme].
  static const suravaramTextTheme = PartS.suravaramTextTheme;

  /// See [PartS.suwannaphum].
  static const suwannaphum = PartS.suwannaphum;

  /// See [PartS.suwannaphumTextTheme].
  static const suwannaphumTextTheme = PartS.suwannaphumTextTheme;

  /// See [PartS.swankyAndMooMoo].
  static const swankyAndMooMoo = PartS.swankyAndMooMoo;

  /// See [PartS.swankyAndMooMooTextTheme].
  static const swankyAndMooMooTextTheme = PartS.swankyAndMooMooTextTheme;

  /// See [PartS.syncopate].
  static const syncopate = PartS.syncopate;

  /// See [PartS.syncopateTextTheme].
  static const syncopateTextTheme = PartS.syncopateTextTheme;

  /// See [PartS.syne].
  static const syne = PartS.syne;

  /// See [PartS.syneTextTheme].
  static const syneTextTheme = PartS.syneTextTheme;

  /// See [PartS.syneMono].
  static const syneMono = PartS.syneMono;

  /// See [PartS.syneMonoTextTheme].
  static const syneMonoTextTheme = PartS.syneMonoTextTheme;

  /// See [PartS.syneTactile].
  static const syneTactile = PartS.syneTactile;

  /// See [PartS.syneTactileTextTheme].
  static const syneTactileTextTheme = PartS.syneTactileTextTheme;

  /// See [PartT.tasaExplorer].
  static const tasaExplorer = PartT.tasaExplorer;

  /// See [PartT.tasaExplorerTextTheme].
  static const tasaExplorerTextTheme = PartT.tasaExplorerTextTheme;

  /// See [PartT.tasaOrbiter].
  static const tasaOrbiter = PartT.tasaOrbiter;

  /// See [PartT.tasaOrbiterTextTheme].
  static const tasaOrbiterTextTheme = PartT.tasaOrbiterTextTheme;

  /// See [PartT.tacOne].
  static const tacOne = PartT.tacOne;

  /// See [PartT.tacOneTextTheme].
  static const tacOneTextTheme = PartT.tacOneTextTheme;

  /// See [PartT.tagesschrift].
  static const tagesschrift = PartT.tagesschrift;

  /// See [PartT.tagesschriftTextTheme].
  static const tagesschriftTextTheme = PartT.tagesschriftTextTheme;

  /// See [PartT.taiHeritagePro].
  static const taiHeritagePro = PartT.taiHeritagePro;

  /// See [PartT.taiHeritageProTextTheme].
  static const taiHeritageProTextTheme = PartT.taiHeritageProTextTheme;

  /// See [PartT.tajawal].
  static const tajawal = PartT.tajawal;

  /// See [PartT.tajawalTextTheme].
  static const tajawalTextTheme = PartT.tajawalTextTheme;

  /// See [PartT.tangerine].
  static const tangerine = PartT.tangerine;

  /// See [PartT.tangerineTextTheme].
  static const tangerineTextTheme = PartT.tangerineTextTheme;

  /// See [PartT.tapestry].
  static const tapestry = PartT.tapestry;

  /// See [PartT.tapestryTextTheme].
  static const tapestryTextTheme = PartT.tapestryTextTheme;

  /// See [PartT.taprom].
  static const taprom = PartT.taprom;

  /// See [PartT.tapromTextTheme].
  static const tapromTextTheme = PartT.tapromTextTheme;

  /// See [PartT.tauri].
  static const tauri = PartT.tauri;

  /// See [PartT.tauriTextTheme].
  static const tauriTextTheme = PartT.tauriTextTheme;

  /// See [PartT.taviraj].
  static const taviraj = PartT.taviraj;

  /// See [PartT.tavirajTextTheme].
  static const tavirajTextTheme = PartT.tavirajTextTheme;

  /// See [PartT.teachers].
  static const teachers = PartT.teachers;

  /// See [PartT.teachersTextTheme].
  static const teachersTextTheme = PartT.teachersTextTheme;

  /// See [PartT.teko].
  static const teko = PartT.teko;

  /// See [PartT.tekoTextTheme].
  static const tekoTextTheme = PartT.tekoTextTheme;

  /// See [PartT.tektur].
  static const tektur = PartT.tektur;

  /// See [PartT.tekturTextTheme].
  static const tekturTextTheme = PartT.tekturTextTheme;

  /// See [PartT.telex].
  static const telex = PartT.telex;

  /// See [PartT.telexTextTheme].
  static const telexTextTheme = PartT.telexTextTheme;

  /// See [PartT.tenaliRamakrishna].
  static const tenaliRamakrishna = PartT.tenaliRamakrishna;

  /// See [PartT.tenaliRamakrishnaTextTheme].
  static const tenaliRamakrishnaTextTheme = PartT.tenaliRamakrishnaTextTheme;

  /// See [PartT.tenorSans].
  static const tenorSans = PartT.tenorSans;

  /// See [PartT.tenorSansTextTheme].
  static const tenorSansTextTheme = PartT.tenorSansTextTheme;

  /// See [PartT.textMeOne].
  static const textMeOne = PartT.textMeOne;

  /// See [PartT.textMeOneTextTheme].
  static const textMeOneTextTheme = PartT.textMeOneTextTheme;

  /// See [PartT.texturina].
  static const texturina = PartT.texturina;

  /// See [PartT.texturinaTextTheme].
  static const texturinaTextTheme = PartT.texturinaTextTheme;

  /// See [PartT.thasadith].
  static const thasadith = PartT.thasadith;

  /// See [PartT.thasadithTextTheme].
  static const thasadithTextTheme = PartT.thasadithTextTheme;

  /// See [PartT.theGirlNextDoor].
  static const theGirlNextDoor = PartT.theGirlNextDoor;

  /// See [PartT.theGirlNextDoorTextTheme].
  static const theGirlNextDoorTextTheme = PartT.theGirlNextDoorTextTheme;

  /// See [PartT.theNautigal].
  static const theNautigal = PartT.theNautigal;

  /// See [PartT.theNautigalTextTheme].
  static const theNautigalTextTheme = PartT.theNautigalTextTheme;

  /// See [PartT.tienne].
  static const tienne = PartT.tienne;

  /// See [PartT.tienneTextTheme].
  static const tienneTextTheme = PartT.tienneTextTheme;

  /// See [PartT.tikTokSans].
  static const tikTokSans = PartT.tikTokSans;

  /// See [PartT.tikTokSansTextTheme].
  static const tikTokSansTextTheme = PartT.tikTokSansTextTheme;

  /// See [PartT.tillana].
  static const tillana = PartT.tillana;

  /// See [PartT.tillanaTextTheme].
  static const tillanaTextTheme = PartT.tillanaTextTheme;

  /// See [PartT.tiltNeon].
  static const tiltNeon = PartT.tiltNeon;

  /// See [PartT.tiltNeonTextTheme].
  static const tiltNeonTextTheme = PartT.tiltNeonTextTheme;

  /// See [PartT.tiltPrism].
  static const tiltPrism = PartT.tiltPrism;

  /// See [PartT.tiltPrismTextTheme].
  static const tiltPrismTextTheme = PartT.tiltPrismTextTheme;

  /// See [PartT.tiltWarp].
  static const tiltWarp = PartT.tiltWarp;

  /// See [PartT.tiltWarpTextTheme].
  static const tiltWarpTextTheme = PartT.tiltWarpTextTheme;

  /// See [PartT.timmana].
  static const timmana = PartT.timmana;

  /// See [PartT.timmanaTextTheme].
  static const timmanaTextTheme = PartT.timmanaTextTheme;

  /// See [PartT.tinos].
  static const tinos = PartT.tinos;

  /// See [PartT.tinosTextTheme].
  static const tinosTextTheme = PartT.tinosTextTheme;

  /// See [PartT.tiny5].
  static const tiny5 = PartT.tiny5;

  /// See [PartT.tiny5TextTheme].
  static const tiny5TextTheme = PartT.tiny5TextTheme;

  /// See [PartT.tiroBangla].
  static const tiroBangla = PartT.tiroBangla;

  /// See [PartT.tiroBanglaTextTheme].
  static const tiroBanglaTextTheme = PartT.tiroBanglaTextTheme;

  /// See [PartT.tiroDevanagariHindi].
  static const tiroDevanagariHindi = PartT.tiroDevanagariHindi;

  /// See [PartT.tiroDevanagariHindiTextTheme].
  static const tiroDevanagariHindiTextTheme =
      PartT.tiroDevanagariHindiTextTheme;

  /// See [PartT.tiroDevanagariMarathi].
  static const tiroDevanagariMarathi = PartT.tiroDevanagariMarathi;

  /// See [PartT.tiroDevanagariMarathiTextTheme].
  static const tiroDevanagariMarathiTextTheme =
      PartT.tiroDevanagariMarathiTextTheme;

  /// See [PartT.tiroDevanagariSanskrit].
  static const tiroDevanagariSanskrit = PartT.tiroDevanagariSanskrit;

  /// See [PartT.tiroDevanagariSanskritTextTheme].
  static const tiroDevanagariSanskritTextTheme =
      PartT.tiroDevanagariSanskritTextTheme;

  /// See [PartT.tiroGurmukhi].
  static const tiroGurmukhi = PartT.tiroGurmukhi;

  /// See [PartT.tiroGurmukhiTextTheme].
  static const tiroGurmukhiTextTheme = PartT.tiroGurmukhiTextTheme;

  /// See [PartT.tiroKannada].
  static const tiroKannada = PartT.tiroKannada;

  /// See [PartT.tiroKannadaTextTheme].
  static const tiroKannadaTextTheme = PartT.tiroKannadaTextTheme;

  /// See [PartT.tiroTamil].
  static const tiroTamil = PartT.tiroTamil;

  /// See [PartT.tiroTamilTextTheme].
  static const tiroTamilTextTheme = PartT.tiroTamilTextTheme;

  /// See [PartT.tiroTelugu].
  static const tiroTelugu = PartT.tiroTelugu;

  /// See [PartT.tiroTeluguTextTheme].
  static const tiroTeluguTextTheme = PartT.tiroTeluguTextTheme;

  /// See [PartT.tirra].
  static const tirra = PartT.tirra;

  /// See [PartT.tirraTextTheme].
  static const tirraTextTheme = PartT.tirraTextTheme;

  /// See [PartT.titanOne].
  static const titanOne = PartT.titanOne;

  /// See [PartT.titanOneTextTheme].
  static const titanOneTextTheme = PartT.titanOneTextTheme;

  /// See [PartT.titilliumWeb].
  static const titilliumWeb = PartT.titilliumWeb;

  /// See [PartT.titilliumWebTextTheme].
  static const titilliumWebTextTheme = PartT.titilliumWebTextTheme;

  /// See [PartT.tomorrow].
  static const tomorrow = PartT.tomorrow;

  /// See [PartT.tomorrowTextTheme].
  static const tomorrowTextTheme = PartT.tomorrowTextTheme;

  /// See [PartT.tourney].
  static const tourney = PartT.tourney;

  /// See [PartT.tourneyTextTheme].
  static const tourneyTextTheme = PartT.tourneyTextTheme;

  /// See [PartT.tradeWinds].
  static const tradeWinds = PartT.tradeWinds;

  /// See [PartT.tradeWindsTextTheme].
  static const tradeWindsTextTheme = PartT.tradeWindsTextTheme;

  /// See [PartT.trainOne].
  static const trainOne = PartT.trainOne;

  /// See [PartT.trainOneTextTheme].
  static const trainOneTextTheme = PartT.trainOneTextTheme;

  /// See [PartT.triodion].
  static const triodion = PartT.triodion;

  /// See [PartT.triodionTextTheme].
  static const triodionTextTheme = PartT.triodionTextTheme;

  /// See [PartT.trirong].
  static const trirong = PartT.trirong;

  /// See [PartT.trirongTextTheme].
  static const trirongTextTheme = PartT.trirongTextTheme;

  /// See [PartT.trispace].
  static const trispace = PartT.trispace;

  /// See [PartT.trispaceTextTheme].
  static const trispaceTextTheme = PartT.trispaceTextTheme;

  /// See [PartT.trocchi].
  static const trocchi = PartT.trocchi;

  /// See [PartT.trocchiTextTheme].
  static const trocchiTextTheme = PartT.trocchiTextTheme;

  /// See [PartT.trochut].
  static const trochut = PartT.trochut;

  /// See [PartT.trochutTextTheme].
  static const trochutTextTheme = PartT.trochutTextTheme;

  /// See [PartT.truculenta].
  static const truculenta = PartT.truculenta;

  /// See [PartT.truculentaTextTheme].
  static const truculentaTextTheme = PartT.truculentaTextTheme;

  /// See [PartT.trykker].
  static const trykker = PartT.trykker;

  /// See [PartT.trykkerTextTheme].
  static const trykkerTextTheme = PartT.trykkerTextTheme;

  /// See [PartT.tsukimiRounded].
  static const tsukimiRounded = PartT.tsukimiRounded;

  /// See [PartT.tsukimiRoundedTextTheme].
  static const tsukimiRoundedTextTheme = PartT.tsukimiRoundedTextTheme;

  /// See [PartT.tuffy].
  static const tuffy = PartT.tuffy;

  /// See [PartT.tuffyTextTheme].
  static const tuffyTextTheme = PartT.tuffyTextTheme;

  /// See [PartT.tulpenOne].
  static const tulpenOne = PartT.tulpenOne;

  /// See [PartT.tulpenOneTextTheme].
  static const tulpenOneTextTheme = PartT.tulpenOneTextTheme;

  /// See [PartT.turretRoad].
  static const turretRoad = PartT.turretRoad;

  /// See [PartT.turretRoadTextTheme].
  static const turretRoadTextTheme = PartT.turretRoadTextTheme;

  /// See [PartT.twinkleStar].
  static const twinkleStar = PartT.twinkleStar;

  /// See [PartT.twinkleStarTextTheme].
  static const twinkleStarTextTheme = PartT.twinkleStarTextTheme;

  /// See [PartU.ubuntu].
  static const ubuntu = PartU.ubuntu;

  /// See [PartU.ubuntuTextTheme].
  static const ubuntuTextTheme = PartU.ubuntuTextTheme;

  /// See [PartU.ubuntuCondensed].
  static const ubuntuCondensed = PartU.ubuntuCondensed;

  /// See [PartU.ubuntuCondensedTextTheme].
  static const ubuntuCondensedTextTheme = PartU.ubuntuCondensedTextTheme;

  /// See [PartU.ubuntuMono].
  static const ubuntuMono = PartU.ubuntuMono;

  /// See [PartU.ubuntuMonoTextTheme].
  static const ubuntuMonoTextTheme = PartU.ubuntuMonoTextTheme;

  /// See [PartU.ubuntuSans].
  static const ubuntuSans = PartU.ubuntuSans;

  /// See [PartU.ubuntuSansTextTheme].
  static const ubuntuSansTextTheme = PartU.ubuntuSansTextTheme;

  /// See [PartU.ubuntuSansMono].
  static const ubuntuSansMono = PartU.ubuntuSansMono;

  /// See [PartU.ubuntuSansMonoTextTheme].
  static const ubuntuSansMonoTextTheme = PartU.ubuntuSansMonoTextTheme;

  /// See [PartU.uchen].
  static const uchen = PartU.uchen;

  /// See [PartU.uchenTextTheme].
  static const uchenTextTheme = PartU.uchenTextTheme;

  /// See [PartU.ultra].
  static const ultra = PartU.ultra;

  /// See [PartU.ultraTextTheme].
  static const ultraTextTheme = PartU.ultraTextTheme;

  /// See [PartU.unbounded].
  static const unbounded = PartU.unbounded;

  /// See [PartU.unboundedTextTheme].
  static const unboundedTextTheme = PartU.unboundedTextTheme;

  /// See [PartU.uncialAntiqua].
  static const uncialAntiqua = PartU.uncialAntiqua;

  /// See [PartU.uncialAntiquaTextTheme].
  static const uncialAntiquaTextTheme = PartU.uncialAntiquaTextTheme;

  /// See [PartU.underdog].
  static const underdog = PartU.underdog;

  /// See [PartU.underdogTextTheme].
  static const underdogTextTheme = PartU.underdogTextTheme;

  /// See [PartU.unicaOne].
  static const unicaOne = PartU.unicaOne;

  /// See [PartU.unicaOneTextTheme].
  static const unicaOneTextTheme = PartU.unicaOneTextTheme;

  /// See [PartU.unifrakturCook].
  static const unifrakturCook = PartU.unifrakturCook;

  /// See [PartU.unifrakturCookTextTheme].
  static const unifrakturCookTextTheme = PartU.unifrakturCookTextTheme;

  /// See [PartU.unifrakturMaguntia].
  static const unifrakturMaguntia = PartU.unifrakturMaguntia;

  /// See [PartU.unifrakturMaguntiaTextTheme].
  static const unifrakturMaguntiaTextTheme = PartU.unifrakturMaguntiaTextTheme;

  /// See [PartU.unkempt].
  static const unkempt = PartU.unkempt;

  /// See [PartU.unkemptTextTheme].
  static const unkemptTextTheme = PartU.unkemptTextTheme;

  /// See [PartU.unlock].
  static const unlock = PartU.unlock;

  /// See [PartU.unlockTextTheme].
  static const unlockTextTheme = PartU.unlockTextTheme;

  /// See [PartU.unna].
  static const unna = PartU.unna;

  /// See [PartU.unnaTextTheme].
  static const unnaTextTheme = PartU.unnaTextTheme;

  /// See [PartU.uoqMunThenKhung].
  static const uoqMunThenKhung = PartU.uoqMunThenKhung;

  /// See [PartU.uoqMunThenKhungTextTheme].
  static const uoqMunThenKhungTextTheme = PartU.uoqMunThenKhungTextTheme;

  /// See [PartU.updock].
  static const updock = PartU.updock;

  /// See [PartU.updockTextTheme].
  static const updockTextTheme = PartU.updockTextTheme;

  /// See [PartU.urbanist].
  static const urbanist = PartU.urbanist;

  /// See [PartU.urbanistTextTheme].
  static const urbanistTextTheme = PartU.urbanistTextTheme;

  /// See [PartV.vt323].
  static const vt323 = PartV.vt323;

  /// See [PartV.vt323TextTheme].
  static const vt323TextTheme = PartV.vt323TextTheme;

  /// See [PartV.vampiroOne].
  static const vampiroOne = PartV.vampiroOne;

  /// See [PartV.vampiroOneTextTheme].
  static const vampiroOneTextTheme = PartV.vampiroOneTextTheme;

  /// See [PartV.varela].
  static const varela = PartV.varela;

  /// See [PartV.varelaTextTheme].
  static const varelaTextTheme = PartV.varelaTextTheme;

  /// See [PartV.varelaRound].
  static const varelaRound = PartV.varelaRound;

  /// See [PartV.varelaRoundTextTheme].
  static const varelaRoundTextTheme = PartV.varelaRoundTextTheme;

  /// See [PartV.varta].
  static const varta = PartV.varta;

  /// See [PartV.vartaTextTheme].
  static const vartaTextTheme = PartV.vartaTextTheme;

  /// See [PartV.vastShadow].
  static const vastShadow = PartV.vastShadow;

  /// See [PartV.vastShadowTextTheme].
  static const vastShadowTextTheme = PartV.vastShadowTextTheme;

  /// See [PartV.vazirmatn].
  static const vazirmatn = PartV.vazirmatn;

  /// See [PartV.vazirmatnTextTheme].
  static const vazirmatnTextTheme = PartV.vazirmatnTextTheme;

  /// See [PartV.vendSans].
  static const vendSans = PartV.vendSans;

  /// See [PartV.vendSansTextTheme].
  static const vendSansTextTheme = PartV.vendSansTextTheme;

  /// See [PartV.vesperLibre].
  static const vesperLibre = PartV.vesperLibre;

  /// See [PartV.vesperLibreTextTheme].
  static const vesperLibreTextTheme = PartV.vesperLibreTextTheme;

  /// See [PartV.viaodaLibre].
  static const viaodaLibre = PartV.viaodaLibre;

  /// See [PartV.viaodaLibreTextTheme].
  static const viaodaLibreTextTheme = PartV.viaodaLibreTextTheme;

  /// See [PartV.vibes].
  static const vibes = PartV.vibes;

  /// See [PartV.vibesTextTheme].
  static const vibesTextTheme = PartV.vibesTextTheme;

  /// See [PartV.vibur].
  static const vibur = PartV.vibur;

  /// See [PartV.viburTextTheme].
  static const viburTextTheme = PartV.viburTextTheme;

  /// See [PartV.victorMono].
  static const victorMono = PartV.victorMono;

  /// See [PartV.victorMonoTextTheme].
  static const victorMonoTextTheme = PartV.victorMonoTextTheme;

  /// See [PartV.vidaloka].
  static const vidaloka = PartV.vidaloka;

  /// See [PartV.vidalokaTextTheme].
  static const vidalokaTextTheme = PartV.vidalokaTextTheme;

  /// See [PartV.viga].
  static const viga = PartV.viga;

  /// See [PartV.vigaTextTheme].
  static const vigaTextTheme = PartV.vigaTextTheme;

  /// See [PartV.vinaSans].
  static const vinaSans = PartV.vinaSans;

  /// See [PartV.vinaSansTextTheme].
  static const vinaSansTextTheme = PartV.vinaSansTextTheme;

  /// See [PartV.voces].
  static const voces = PartV.voces;

  /// See [PartV.vocesTextTheme].
  static const vocesTextTheme = PartV.vocesTextTheme;

  /// See [PartV.volkhov].
  static const volkhov = PartV.volkhov;

  /// See [PartV.volkhovTextTheme].
  static const volkhovTextTheme = PartV.volkhovTextTheme;

  /// See [PartV.vollkorn].
  static const vollkorn = PartV.vollkorn;

  /// See [PartV.vollkornTextTheme].
  static const vollkornTextTheme = PartV.vollkornTextTheme;

  /// See [PartV.vollkornSc].
  static const vollkornSc = PartV.vollkornSc;

  /// See [PartV.vollkornScTextTheme].
  static const vollkornScTextTheme = PartV.vollkornScTextTheme;

  /// See [PartV.voltaire].
  static const voltaire = PartV.voltaire;

  /// See [PartV.voltaireTextTheme].
  static const voltaireTextTheme = PartV.voltaireTextTheme;

  /// See [PartV.vujahdayScript].
  static const vujahdayScript = PartV.vujahdayScript;

  /// See [PartV.vujahdayScriptTextTheme].
  static const vujahdayScriptTextTheme = PartV.vujahdayScriptTextTheme;

  /// See [PartW.wdxlLubrifontJpN].
  static const wdxlLubrifontJpN = PartW.wdxlLubrifontJpN;

  /// See [PartW.wdxlLubrifontJpNTextTheme].
  static const wdxlLubrifontJpNTextTheme = PartW.wdxlLubrifontJpNTextTheme;

  /// See [PartW.wdxlLubrifontSc].
  static const wdxlLubrifontSc = PartW.wdxlLubrifontSc;

  /// See [PartW.wdxlLubrifontScTextTheme].
  static const wdxlLubrifontScTextTheme = PartW.wdxlLubrifontScTextTheme;

  /// See [PartW.wdxlLubrifontTc].
  static const wdxlLubrifontTc = PartW.wdxlLubrifontTc;

  /// See [PartW.wdxlLubrifontTcTextTheme].
  static const wdxlLubrifontTcTextTheme = PartW.wdxlLubrifontTcTextTheme;

  /// See [PartW.waitingForTheSunrise].
  static const waitingForTheSunrise = PartW.waitingForTheSunrise;

  /// See [PartW.waitingForTheSunriseTextTheme].
  static const waitingForTheSunriseTextTheme =
      PartW.waitingForTheSunriseTextTheme;

  /// See [PartW.wallpoet].
  static const wallpoet = PartW.wallpoet;

  /// See [PartW.wallpoetTextTheme].
  static const wallpoetTextTheme = PartW.wallpoetTextTheme;

  /// See [PartW.walterTurncoat].
  static const walterTurncoat = PartW.walterTurncoat;

  /// See [PartW.walterTurncoatTextTheme].
  static const walterTurncoatTextTheme = PartW.walterTurncoatTextTheme;

  /// See [PartW.warnes].
  static const warnes = PartW.warnes;

  /// See [PartW.warnesTextTheme].
  static const warnesTextTheme = PartW.warnesTextTheme;

  /// See [PartW.waterBrush].
  static const waterBrush = PartW.waterBrush;

  /// See [PartW.waterBrushTextTheme].
  static const waterBrushTextTheme = PartW.waterBrushTextTheme;

  /// See [PartW.waterfall].
  static const waterfall = PartW.waterfall;

  /// See [PartW.waterfallTextTheme].
  static const waterfallTextTheme = PartW.waterfallTextTheme;

  /// See [PartW.wavefont].
  static const wavefont = PartW.wavefont;

  /// See [PartW.wavefontTextTheme].
  static const wavefontTextTheme = PartW.wavefontTextTheme;

  /// See [PartW.wellfleet].
  static const wellfleet = PartW.wellfleet;

  /// See [PartW.wellfleetTextTheme].
  static const wellfleetTextTheme = PartW.wellfleetTextTheme;

  /// See [PartW.wendyOne].
  static const wendyOne = PartW.wendyOne;

  /// See [PartW.wendyOneTextTheme].
  static const wendyOneTextTheme = PartW.wendyOneTextTheme;

  /// See [PartW.whisper].
  static const whisper = PartW.whisper;

  /// See [PartW.whisperTextTheme].
  static const whisperTextTheme = PartW.whisperTextTheme;

  /// See [PartW.windSong].
  static const windSong = PartW.windSong;

  /// See [PartW.windSongTextTheme].
  static const windSongTextTheme = PartW.windSongTextTheme;

  /// See [PartW.winkyRough].
  static const winkyRough = PartW.winkyRough;

  /// See [PartW.winkyRoughTextTheme].
  static const winkyRoughTextTheme = PartW.winkyRoughTextTheme;

  /// See [PartW.winkySans].
  static const winkySans = PartW.winkySans;

  /// See [PartW.winkySansTextTheme].
  static const winkySansTextTheme = PartW.winkySansTextTheme;

  /// See [PartW.wireOne].
  static const wireOne = PartW.wireOne;

  /// See [PartW.wireOneTextTheme].
  static const wireOneTextTheme = PartW.wireOneTextTheme;

  /// See [PartW.wittgenstein].
  static const wittgenstein = PartW.wittgenstein;

  /// See [PartW.wittgensteinTextTheme].
  static const wittgensteinTextTheme = PartW.wittgensteinTextTheme;

  /// See [PartW.wixMadeforDisplay].
  static const wixMadeforDisplay = PartW.wixMadeforDisplay;

  /// See [PartW.wixMadeforDisplayTextTheme].
  static const wixMadeforDisplayTextTheme = PartW.wixMadeforDisplayTextTheme;

  /// See [PartW.wixMadeforText].
  static const wixMadeforText = PartW.wixMadeforText;

  /// See [PartW.wixMadeforTextTextTheme].
  static const wixMadeforTextTextTheme = PartW.wixMadeforTextTextTheme;

  /// See [PartW.workSans].
  static const workSans = PartW.workSans;

  /// See [PartW.workSansTextTheme].
  static const workSansTextTheme = PartW.workSansTextTheme;

  /// See [PartW.workbench].
  static const workbench = PartW.workbench;

  /// See [PartW.workbenchTextTheme].
  static const workbenchTextTheme = PartW.workbenchTextTheme;

  /// See [PartX.xanhMono].
  static const xanhMono = PartX.xanhMono;

  /// See [PartX.xanhMonoTextTheme].
  static const xanhMonoTextTheme = PartX.xanhMonoTextTheme;

  /// See [PartY.yaldevi].
  static const yaldevi = PartY.yaldevi;

  /// See [PartY.yaldeviTextTheme].
  static const yaldeviTextTheme = PartY.yaldeviTextTheme;

  /// See [PartY.yanoneKaffeesatz].
  static const yanoneKaffeesatz = PartY.yanoneKaffeesatz;

  /// See [PartY.yanoneKaffeesatzTextTheme].
  static const yanoneKaffeesatzTextTheme = PartY.yanoneKaffeesatzTextTheme;

  /// See [PartY.yantramanav].
  static const yantramanav = PartY.yantramanav;

  /// See [PartY.yantramanavTextTheme].
  static const yantramanavTextTheme = PartY.yantramanavTextTheme;

  /// See [PartY.yarndings12].
  static const yarndings12 = PartY.yarndings12;

  /// See [PartY.yarndings12TextTheme].
  static const yarndings12TextTheme = PartY.yarndings12TextTheme;

  /// See [PartY.yarndings12Charted].
  static const yarndings12Charted = PartY.yarndings12Charted;

  /// See [PartY.yarndings12ChartedTextTheme].
  static const yarndings12ChartedTextTheme = PartY.yarndings12ChartedTextTheme;

  /// See [PartY.yarndings20].
  static const yarndings20 = PartY.yarndings20;

  /// See [PartY.yarndings20TextTheme].
  static const yarndings20TextTheme = PartY.yarndings20TextTheme;

  /// See [PartY.yarndings20Charted].
  static const yarndings20Charted = PartY.yarndings20Charted;

  /// See [PartY.yarndings20ChartedTextTheme].
  static const yarndings20ChartedTextTheme = PartY.yarndings20ChartedTextTheme;

  /// See [PartY.yatraOne].
  static const yatraOne = PartY.yatraOne;

  /// See [PartY.yatraOneTextTheme].
  static const yatraOneTextTheme = PartY.yatraOneTextTheme;

  /// See [PartY.yellowtail].
  static const yellowtail = PartY.yellowtail;

  /// See [PartY.yellowtailTextTheme].
  static const yellowtailTextTheme = PartY.yellowtailTextTheme;

  /// See [PartY.yeonSung].
  static const yeonSung = PartY.yeonSung;

  /// See [PartY.yeonSungTextTheme].
  static const yeonSungTextTheme = PartY.yeonSungTextTheme;

  /// See [PartY.yesevaOne].
  static const yesevaOne = PartY.yesevaOne;

  /// See [PartY.yesevaOneTextTheme].
  static const yesevaOneTextTheme = PartY.yesevaOneTextTheme;

  /// See [PartY.yesteryear].
  static const yesteryear = PartY.yesteryear;

  /// See [PartY.yesteryearTextTheme].
  static const yesteryearTextTheme = PartY.yesteryearTextTheme;

  /// See [PartY.yomogi].
  static const yomogi = PartY.yomogi;

  /// See [PartY.yomogiTextTheme].
  static const yomogiTextTheme = PartY.yomogiTextTheme;

  /// See [PartY.youngSerif].
  static const youngSerif = PartY.youngSerif;

  /// See [PartY.youngSerifTextTheme].
  static const youngSerifTextTheme = PartY.youngSerifTextTheme;

  /// See [PartY.yrsa].
  static const yrsa = PartY.yrsa;

  /// See [PartY.yrsaTextTheme].
  static const yrsaTextTheme = PartY.yrsaTextTheme;

  /// See [PartY.ysabeau].
  static const ysabeau = PartY.ysabeau;

  /// See [PartY.ysabeauTextTheme].
  static const ysabeauTextTheme = PartY.ysabeauTextTheme;

  /// See [PartY.ysabeauInfant].
  static const ysabeauInfant = PartY.ysabeauInfant;

  /// See [PartY.ysabeauInfantTextTheme].
  static const ysabeauInfantTextTheme = PartY.ysabeauInfantTextTheme;

  /// See [PartY.ysabeauOffice].
  static const ysabeauOffice = PartY.ysabeauOffice;

  /// See [PartY.ysabeauOfficeTextTheme].
  static const ysabeauOfficeTextTheme = PartY.ysabeauOfficeTextTheme;

  /// See [PartY.ysabeauSc].
  static const ysabeauSc = PartY.ysabeauSc;

  /// See [PartY.ysabeauScTextTheme].
  static const ysabeauScTextTheme = PartY.ysabeauScTextTheme;

  /// See [PartY.yujiBoku].
  static const yujiBoku = PartY.yujiBoku;

  /// See [PartY.yujiBokuTextTheme].
  static const yujiBokuTextTheme = PartY.yujiBokuTextTheme;

  /// See [PartY.yujiHentaiganaAkari].
  static const yujiHentaiganaAkari = PartY.yujiHentaiganaAkari;

  /// See [PartY.yujiHentaiganaAkariTextTheme].
  static const yujiHentaiganaAkariTextTheme =
      PartY.yujiHentaiganaAkariTextTheme;

  /// See [PartY.yujiHentaiganaAkebono].
  static const yujiHentaiganaAkebono = PartY.yujiHentaiganaAkebono;

  /// See [PartY.yujiHentaiganaAkebonoTextTheme].
  static const yujiHentaiganaAkebonoTextTheme =
      PartY.yujiHentaiganaAkebonoTextTheme;

  /// See [PartY.yujiMai].
  static const yujiMai = PartY.yujiMai;

  /// See [PartY.yujiMaiTextTheme].
  static const yujiMaiTextTheme = PartY.yujiMaiTextTheme;

  /// See [PartY.yujiSyuku].
  static const yujiSyuku = PartY.yujiSyuku;

  /// See [PartY.yujiSyukuTextTheme].
  static const yujiSyukuTextTheme = PartY.yujiSyukuTextTheme;

  /// See [PartY.yuseiMagic].
  static const yuseiMagic = PartY.yuseiMagic;

  /// See [PartY.yuseiMagicTextTheme].
  static const yuseiMagicTextTheme = PartY.yuseiMagicTextTheme;

  /// See [PartZ.zcoolKuaiLe].
  static const zcoolKuaiLe = PartZ.zcoolKuaiLe;

  /// See [PartZ.zcoolKuaiLeTextTheme].
  static const zcoolKuaiLeTextTheme = PartZ.zcoolKuaiLeTextTheme;

  /// See [PartZ.zcoolQingKeHuangYou].
  static const zcoolQingKeHuangYou = PartZ.zcoolQingKeHuangYou;

  /// See [PartZ.zcoolQingKeHuangYouTextTheme].
  static const zcoolQingKeHuangYouTextTheme =
      PartZ.zcoolQingKeHuangYouTextTheme;

  /// See [PartZ.zcoolXiaoWei].
  static const zcoolXiaoWei = PartZ.zcoolXiaoWei;

  /// See [PartZ.zcoolXiaoWeiTextTheme].
  static const zcoolXiaoWeiTextTheme = PartZ.zcoolXiaoWeiTextTheme;

  /// See [PartZ.zain].
  static const zain = PartZ.zain;

  /// See [PartZ.zainTextTheme].
  static const zainTextTheme = PartZ.zainTextTheme;

  /// See [PartZ.zalandoSans].
  static const zalandoSans = PartZ.zalandoSans;

  /// See [PartZ.zalandoSansTextTheme].
  static const zalandoSansTextTheme = PartZ.zalandoSansTextTheme;

  /// See [PartZ.zalandoSansExpanded].
  static const zalandoSansExpanded = PartZ.zalandoSansExpanded;

  /// See [PartZ.zalandoSansExpandedTextTheme].
  static const zalandoSansExpandedTextTheme =
      PartZ.zalandoSansExpandedTextTheme;

  /// See [PartZ.zalandoSansSemiExpanded].
  static const zalandoSansSemiExpanded = PartZ.zalandoSansSemiExpanded;

  /// See [PartZ.zalandoSansSemiExpandedTextTheme].
  static const zalandoSansSemiExpandedTextTheme =
      PartZ.zalandoSansSemiExpandedTextTheme;

  /// See [PartZ.zenAntique].
  static const zenAntique = PartZ.zenAntique;

  /// See [PartZ.zenAntiqueTextTheme].
  static const zenAntiqueTextTheme = PartZ.zenAntiqueTextTheme;

  /// See [PartZ.zenAntiqueSoft].
  static const zenAntiqueSoft = PartZ.zenAntiqueSoft;

  /// See [PartZ.zenAntiqueSoftTextTheme].
  static const zenAntiqueSoftTextTheme = PartZ.zenAntiqueSoftTextTheme;

  /// See [PartZ.zenDots].
  static const zenDots = PartZ.zenDots;

  /// See [PartZ.zenDotsTextTheme].
  static const zenDotsTextTheme = PartZ.zenDotsTextTheme;

  /// See [PartZ.zenKakuGothicAntique].
  static const zenKakuGothicAntique = PartZ.zenKakuGothicAntique;

  /// See [PartZ.zenKakuGothicAntiqueTextTheme].
  static const zenKakuGothicAntiqueTextTheme =
      PartZ.zenKakuGothicAntiqueTextTheme;

  /// See [PartZ.zenKakuGothicNew].
  static const zenKakuGothicNew = PartZ.zenKakuGothicNew;

  /// See [PartZ.zenKakuGothicNewTextTheme].
  static const zenKakuGothicNewTextTheme = PartZ.zenKakuGothicNewTextTheme;

  /// See [PartZ.zenKurenaido].
  static const zenKurenaido = PartZ.zenKurenaido;

  /// See [PartZ.zenKurenaidoTextTheme].
  static const zenKurenaidoTextTheme = PartZ.zenKurenaidoTextTheme;

  /// See [PartZ.zenLoop].
  static const zenLoop = PartZ.zenLoop;

  /// See [PartZ.zenLoopTextTheme].
  static const zenLoopTextTheme = PartZ.zenLoopTextTheme;

  /// See [PartZ.zenMaruGothic].
  static const zenMaruGothic = PartZ.zenMaruGothic;

  /// See [PartZ.zenMaruGothicTextTheme].
  static const zenMaruGothicTextTheme = PartZ.zenMaruGothicTextTheme;

  /// See [PartZ.zenOldMincho].
  static const zenOldMincho = PartZ.zenOldMincho;

  /// See [PartZ.zenOldMinchoTextTheme].
  static const zenOldMinchoTextTheme = PartZ.zenOldMinchoTextTheme;

  /// See [PartZ.zenTokyoZoo].
  static const zenTokyoZoo = PartZ.zenTokyoZoo;

  /// See [PartZ.zenTokyoZooTextTheme].
  static const zenTokyoZooTextTheme = PartZ.zenTokyoZooTextTheme;

  /// See [PartZ.zeyada].
  static const zeyada = PartZ.zeyada;

  /// See [PartZ.zeyadaTextTheme].
  static const zeyadaTextTheme = PartZ.zeyadaTextTheme;

  /// See [PartZ.zhiMangXing].
  static const zhiMangXing = PartZ.zhiMangXing;

  /// See [PartZ.zhiMangXingTextTheme].
  static const zhiMangXingTextTheme = PartZ.zhiMangXingTextTheme;

  /// See [PartZ.zillaSlab].
  static const zillaSlab = PartZ.zillaSlab;

  /// See [PartZ.zillaSlabTextTheme].
  static const zillaSlabTextTheme = PartZ.zillaSlabTextTheme;

  /// See [PartZ.zillaSlabHighlight].
  static const zillaSlabHighlight = PartZ.zillaSlabHighlight;

  /// See [PartZ.zillaSlabHighlightTextTheme].
  static const zillaSlabHighlightTextTheme = PartZ.zillaSlabHighlightTextTheme;
}
