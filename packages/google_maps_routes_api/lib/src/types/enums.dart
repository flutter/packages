// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'polyline.dart';
import 'route.dart';
import 'route_leg.dart';
import 'routes_request.dart';

/// A set of values that specify the navigation action to take for the current
/// [RouteLegStep] (e.g., turn left, merge, straight, etc.).
enum Maneuver {
  /// Not used.
  MANEUVER_UNSPECIFIED,

  /// Turn slightly to the left.
  TURN_SLIGHT_LEFT,

  /// Turn sharply to the left.
  TURN_SHARP_LEFT,

  /// Make a left u-turn.
  UTURN_LEFT,

  /// Turn left.
  TURN_LEFT,

  /// Turn slightly to the right.
  TURN_SLIGHT_RIGHT,

  /// Turn sharply to the right.
  TURN_SHARP_RIGHT,

  /// Make a right u-turn.
  UTURN_RIGHT,

  /// Turn right.
  TURN_RIGHT,

  /// Go straight.
  STRAIGHT,

  /// Take the left ramp.
  RAMP_LEFT,

  /// Take the right ramp.
  RAMP_RIGHT,

  /// Merge into traffic.
  MERGE,

  /// Take the left fork.
  FORK_LEFT,

  /// Take the right fork.
  FORK_RIGHT,

  /// Take the ferry.
  FERRY,

  /// Take the train leading onto the ferry.
  FERRY_TRAIN,

  /// Turn left at the roundabout.
  ROUNDABOUT_LEFT,

  /// Turn right at the roundabout.
  ROUNDABOUT_RIGHT,
}

/// Labels for the [Route] that are useful to identify specific properties of
/// the route to compare against others.
enum RouteLabel {
  /// Default - not used.
  ROUTE_LABEL_UNSPECIFIED,

  /// The deafult "best" route returned for the route computation
  DEFAULT_ROUTE,

  /// An alternative to the default "best" route. Routes like this will be
  /// returned when [ComputeRoutesRequest.computeAlternativeRoutes] is specified.
  DEFAULT_ROUTE_ALTERNATE,

  /// Fuel efficient route. Routes labeled with this value are determined to be
  /// optimized for Eco parameters such as fuel consumption.
  FUEL_EFFICIENT,
}

/// A set of values used to specify the mode of travel.
enum RouteTravelMode {
  /// No travel mode specified. Defaults to [DRIVE].
  TRAVEL_MODE_UNSPECIFIED,

  /// Travel by passenger car.
  DRIVE,

  /// Travel by bicycle.
  BICYCLE,

  /// Travel by walking.
  WALK,

  /// Two-wheeled, motorized vehicle. For example, motorcycle. Note that this
  /// differs from the [BICYCLE] travel mode which covers human-powered mode.
  TWO_WHEELER,
}

/// A set of values that specify factors to take into consideration when
/// calculating the route.
enum RoutingPreference {
  /// No routing preference specified. Default to [TRAFFIC_UNAWARE].
  ROUTING_PREFERENCE_UNSPECIFIED,

  /// Computes routes without taking live traffic conditions into
  /// consideration. Suitable when traffic conditions don't matter or are not
  /// applicable. Using this value produces the lowest latency.
  TRAFFIC_UNAWARE,

  /// Calculates routes taking live traffic conditions into consideration.
  /// In contrast to [TRAFFIC_AWARE_OPTIMAL], some optimizations are applied to
  /// significantly reduce latency.
  TRAFFIC_AWARE,

  /// Calculates the routes taking live traffic conditions into consideration,
  /// without applying most performance optimizations. Using this value
  /// produces the highest latency.
  TRAFFIC_AWARE_OPTIMAL,
}

/// A set of values that specify the quality of the [Polyline].
enum PolylineQuality {
  /// No polyline quality preference specified. Defaults to [OVERVIEW].
  POLYLINE_QUALITY_UNSPECIFIED,

  /// Specifies a high-quality [Polyline] - which is composed using more
  /// points than [OVERVIEW], at the cost of increased response size.
  /// Use this value when you need more precision.
  HIGH_QUALITY,

  /// Specifies an overview [Polyline] - which is composed using a small
  /// number of points. Use this value when displaying an overview of the
  /// route. Using this option has a lower request latency compared to using
  /// the [HIGH_QUALITY] option
  OVERVIEW,
}

/// Specifies the preferred type of [Polyline] to be returned.
enum PolylineEncoding {
  /// No [Polyline] type preference specified. Defaults to [ENCODED_POLYLINE].
  POLYLINE_ENCODING_UNSPECIFIED,

  /// Specifies a [Polyline] encoded using the polyline encoding algorithm.
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  ENCODED_POLYLINE,

  /// Specifies a [Polyline] using the [GeoJsonLinestring] format.
  /// https://tools.ietf.org/html/rfc7946#section-3.1.4
  GEO_JSON_LINESTRING,
}

/// A set of values that specify the unit of measure used in the display.
enum Units {
  /// Units of measure not specified. Defaults to the unit of measure inferred
  /// from the request.
  UNITS_UNSPECIFIED,

  /// Metric units of measure.
  METRIC,

  /// Imperial (English) units of measure.
  IMPERIAL,
}

/// A supported reference route on the [ComputeRoutesRequest].
enum ReferenceRoute {
  /// Not used. Requests containing this value fail.
  REFERENCE_ROUTE_UNSPECIFIED,

  /// Fuel efficient route. Routes labeled with this value are determined to be
  /// optimized for parameters such as fuel consumption.
  FUEL_EFFICIENT,
}

/// A set of values describing the vehicle's emission type. Applies only to the
/// [RouteTravelMode.DRIVE] travel mode.
enum VehicleEmissionType {
  /// No emission type specified. Default to [GASOLINE].
  VEHICLE_EMISSION_TYPE_UNSPECIFIED,

  /// Gasoline/petrol fueled vehicle.
  GASOLINE,

  /// Electricity powered vehicle.
  ELECTRIC,

  /// Hybrid fuel (such as gasoline + electric) vehicle.
  HYBRID,
}

/// List of toll passes around the world that we support.
enum TollPass {
  /// Not used. If this value is used, then the request fails.
  TOLL_PASS_UNSPECIFIED,

  /// One of many Sydney toll pass providers. https://www.myetoll.com.au
  AU_ETOLL_TAG,

  /// One of many Sydney toll pass providers. https://www.tollpay.com.au/
  AU_EWAY_TAG,

  /// Australia-wide toll pass. See additional details at https://www.linkt.com.au/.
  AU_LINKT,

  /// Argentina toll pass. See additional details at https://telepase.com.ar
  AR_TELEPASE,

  /// Brazil toll pass. See additional details at https://www.autoexpreso.com
  BR_AUTO_EXPRESO,

  /// Brazil toll pass. See additional details at https://conectcar.com.
  BR_CONECTCAR,

  ///	Brazil toll pass. See additional details at https://movemais.com.
  BR_MOVE_MAIS,

  /// Brazil toll pass. See additional details at https://pasorapido.gob.do/
  BR_PASSA_RAPIDO,

  /// Brazil toll pass. See additional details at https://www.semparar.com.br.
  BR_SEM_PARAR,

  /// Brazil toll pass. See additional details at https://taggy.com.br.
  BR_TAGGY,

  /// Brazil toll pass. See additional details at https://veloe.com.br/site/onde-usar.
  BR_VELOE,

  /// Canada to United States border crossing.
  CA_US_AKWASASNE_SEAWAY_CORPORATE_CARD,

  /// Canada to United States border crossing.
  CA_US_AKWASASNE_SEAWAY_TRANSIT_CARD,

  /// Ontario, Canada to Michigan, United States border crossing.
  CA_US_BLUE_WATER_EDGE_PASS,

  /// Ontario, Canada to Michigan, United States border crossing.
  CA_US_CONNEXION,

  /// Canada to United States border crossing.
  CA_US_NEXUS_CARD,

  ///	Indonesia. E-card provided by multiple banks used to pay for tolls.
  /// All e-cards via banks are charged the same so only one enum value is
  /// needed. E.g.
  /// Bank Mandiri https://www.bankmandiri.co.id/e-money
  /// BCA https://www.bca.co.id/flazz
  /// BNI https://www.bni.co.id/id-id/ebanking/tapcash
  ID_E_TOLL,

  /// India.
  IN_FASTAG,

  /// India, HP state plate exemption.
  IN_LOCAL_HP_PLATE_EXEMPT,

  /// Mexico toll pass. https://iave.capufe.gob.mx/#/
  MX_IAVE,

  /// Mexico https://www.pase.com.mx
  MX_PASE,

  /// Mexico https://operadoravial.com/quick-pass/
  MX_QUICKPASS,

  /// http://appsh.chihuahua.gob.mx/transparencia/?doc=/ingresos/TelepeajeFormato4.pdf
  MX_SISTEMA_TELEPEAJE_CHIHUAHUA,

  /// Mexico.
  MX_TAG_IAVE,

  /// Mexico toll pass company. One of many operating in Mexico City. See
  /// additional details at https://www.televia.com.mx.
  MX_TAG_TELEVIA,

  /// Mexico toll pass. See additional details at https://www.viapass.com.mx/viapass/web_home.aspx.
  MX_VIAPASS,

  /// AL, USA.
  US_AL_FREEDOM_PASS,

  /// AK, USA.
  US_AK_ANTON_ANDERSON_TUNNEL_BOOK_OF_10_TICKETS,

  /// AK, USA.
  US_CA_FASTRAK,

  /// Indicates driver has any FasTrak pass in addition to the DMV issued
  /// Clean Air Vehicle (CAV) sticker.
  /// https://www.bayareafastrak.org/en/guide/doINeedFlex.shtml
  US_CA_FASTRAK_CAV_STICKER,

  /// CO, USA.
  US_CO_EXPRESSTOLL,

  /// CO, USA.
  US_CO_GO_PASS,

  /// DE, USA.
  US_DE_EZPASSDE,

  /// FL, USA.
  US_FL_BOB_SIKES_TOLL_BRIDGE_PASS,

  /// FL, USA.
  US_FL_DUNES_COMMUNITY_DEVELOPMENT_DISTRICT_EXPRESSCARD,

  /// FL, USA.
  US_FL_EPASS,

  /// FL, USA.
  US_FL_GIBA_TOLL_PASS,

  /// FL, USA.
  US_FL_LEEWAY,

  /// FL, USA.
  US_FL_SUNPASS,

  /// FL, USA.
  US_FL_SUNPASS_PRO,

  /// IL, USA.
  US_IL_EZPASSIL,

  /// IL, USA.
  US_IL_IPASS,

  /// IN, USA.
  US_IN_EZPASSIN,

  /// KS, USA.
  US_KS_BESTPASS_HORIZON,

  /// KS, USA.
  US_KS_KTAG,

  /// KS, USA.
  US_KS_NATIONALPASS,

  /// KS, USA.
  US_KS_PREPASS_ELITEPASS,

  /// KY, USA.
  US_KY_RIVERLINK,

  /// LA, USA.
  US_LA_GEAUXPASS,

  /// LA, USA.
  US_LA_TOLL_TAG,

  /// MA, USA.
  US_MA_EZPASSMA,

  /// MD, USA.
  US_MD_EZPASSMD,

  /// ME, USA.
  UZ_ME_EZPASSME,

  /// MI, USA.
  US_MI_AMBASSADOR_BRIDGE_PREMIER_COMMUTER_CARD,

  /// MI, USA.
  US_MI_GROSSE_ILE_TOLL_BRIDGE_PASS_TAG,

  /// MI, USA.
  US_MI_IQ_PROX_CARD,

  /// MI, USA.
  US_MI_MACKINAC_BRIDGE_MAC_PASS,

  /// MI, USA.
  US_MI_NEXPRESS_TOLL,

  /// MN, USA.
  US_MN_EZPASSMN,

  /// NC, USA.
  US_NC_EZPASSNC,

  /// NC, USA.
  US_NC_PEACH_PASS,

  /// NC, USA.
  US_NC_QUICK_PASS,

  /// NH, USA.
  US_NH_EZPASSNH,

  /// NJ, USA.
  US_NJ_DOWNBEACH_EXPRESS_PASS,

  /// NJ, USA.
  US_NJ_EZPASSNJ,

  /// NY, USA.
  US_NY_EXPRESSPASS,

  /// NY, USA.
  US_NY_EZPASSNY,

  /// OH, USA.
  US_OH_EZPASSOH,

  /// PA, USA.
  US_PA_EZPASSPA,

  /// RI, USA.
  US_RI_EZPASSRI,

  /// SC, USA.
  US_SC_PALPASS,

  /// TX, USA.
  US_TX_BANCPASS,

  /// TX, USA.
  US_TX_DEL_RIO_PASS,

  /// TX, USA.
  US_TX_EFAST_PASS,

  /// TX, USA.
  US_TX_EAGLE_PASS_EXPRESS_CARD,

  /// TX, USA.
  US_TX_EPTOLL,

  /// TX, USA.
  US_TX_EZ_CROSS,

  /// TX, USA.
  US_TX_EZTAG,

  /// TX, USA.
  US_TX_LAREDO_TRADE_TAG,

  /// TX, USA.
  US_TX_PLUSPASS,

  /// TX, USA.
  US_TX_TOLLTAG,

  /// TX, USA.
  US_TX_TXTAG,

  /// TX, USA.
  US_TX_XPRESS_CARD,

  /// UT, USA.
  US_UT_ADAMS_AVE_PARKWAY_EXPRESSCARD,

  /// VA, USA.
  US_VA_EZPASSVA,

  /// WA, USA.
  US_WA_BREEZEBY,

  /// WA, USA.
  US_WA_GOOD_TO_GO,

  /// WV, USA.
  US_WV_EZPASSWV,

  /// WV, USA.
  US_WV_MEMORIAL_BRIDGE_TICKETS,

  /// WV, USA.
  US_WV_NEWELL_TOLL_BRIDGE_TICKET,
}

/// The condition of the [Route] being returned.
enum RouteMatrixElementCondition {
  /// Only used when the [RouteMatrix.status] of the element is not OK.
  ROUTE_MATRIX_ELEMENT_CONDITION_UNSPECIFIED,

  /// A route was found, and the corresponding information was filled out for
  /// the element.
  ROUTE_EXISTS,

  /// No route could be found. Fields containing route information, such as
  /// [RouteMatrix.distanceMeters] or [RouteMatrix.duration], will not be
  /// filled out in the element.
  ROUTE_NOT_FOUND,
}

/// The classification of [Polyline] speed based on traffic data.
enum Speed {
  /// Default value. This value is unused.
  SPEED_UNSPECIFIED,

  /// Normal speed, no slowdown is detected.
  NORMAL,

  /// Slowdown detected, but no traffic jam formed.
  SLOW,

  /// Traffic jam detected.
  TRAFFIC_JAM,
}
