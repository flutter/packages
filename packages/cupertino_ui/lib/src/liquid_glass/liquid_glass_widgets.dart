/// Liquid Glass Implementation according to Apple's Guidelines
library;

// Renderer — explicit public surface only.
// LiquidGlass is intentionally excluded: use AdaptiveGlass or Glass* widgets
// instead. LiquidGlass is Impeller-only and silently renders nothing on Skia/web.
// LiquidStretch/RawLiquidStretch and GlassGlowLayer are internal utilities.
export 'src/renderer/liquid_glass_renderer.dart'
    show
        AnchorStretchSettings,
        GlassBodyMode,
        GlassLensModel,
        LiquidGlassSettings,
        PlatformViewGlassMode,
        LiquidGlassLayer,
        LiquidGlassBlendGroup,
        GlassGlow,
        debugPaintLiquidGlassGeometry;
export 'src/renderer/glass_backdrop_group.dart'; // GlassBackdropGroup
export 'src/engine/liquid_shape.dart'; // all shapes are public
export 'types/interaction_notification.dart'; // public for Smart Silence support
export 'types/glass_specular_sharpness.dart'; // GlassSpecularSharpness enum

// Setup and Configuration
export 'liquid_glass_setup.dart';

// Constants
export 'constants/glass_defaults.dart';
export 'constants/glass_shadow.dart';

// Theme
export 'theme/glass_theme.dart';
export 'theme/glass_interaction_settings.dart';
export 'theme/glass_theme_data.dart';
export 'theme/glass_theme_settings.dart';

// Types
export 'types/glass_quality.dart';
export 'types/glass_quality_change_reason.dart'; // GlassQualityChangeReason enum
export 'src/types/glass_interaction_behavior.dart'; // GlassInteractionBehavior enum

// Shared widgets
export 'widgets/shared/adaptive_glass.dart';
export 'widgets/shared/adaptive_liquid_glass_layer.dart';
export 'widgets/shared/animated_glass_indicator.dart'
    show AnimatedGlassIndicator; // baseIndicatorSettings for partial overrides
export 'widgets/shared/glass_accessibility_scope.dart'; // GlassAccessibilityScope + GlassAccessibilityData
export 'widgets/shared/glass_adaptive_scope.dart'; // GlassAdaptiveScope + GlassAdaptiveScopeData + GlassAdaptiveDiagnostic
export 'widgets/shared/glass_content_aware_scope.dart'; // GlassContentAwareScope + GlassContentAwareContent + GlassContentAwareBrightness
export 'widgets/shared/glass_page.dart' show GlassPage, GlassStatusBarStyle;
export 'widgets/shared/glass_motion_scope.dart';
export 'widgets/shared/glass_scroll_edge_effect.dart';
export 'widgets/shared/inherited_liquid_glass.dart';
export 'widgets/shared/lightweight_liquid_glass.dart';

// Utils — for advanced / custom widget authors
export 'utils/glass_morph_controller.dart'
    show
        GlassMorphController,
        MorphSpeed,
        MorphStyle,
        LiquidMorphState,
        MorphPhase;
export 'utils/glass_spring.dart';
export 'utils/glass_performance_monitor.dart'
    show GlassPerformanceMonitor; // PremiumGlassTracker is internal

// Widgets - Containers
export 'widgets/containers/glass_card.dart';
export 'widgets/containers/glass_container.dart';
export 'widgets/containers/glass_divider.dart';
export 'widgets/containers/glass_grouped_section.dart';
export 'widgets/containers/glass_list_tile.dart';
export 'widgets/containers/glass_stepper.dart';
// Widgets - Input
export 'widgets/input/glass_form_field.dart';
export 'widgets/input/glass_password_field.dart';
export 'widgets/input/glass_picker.dart';
export 'widgets/input/glass_search_bar.dart';
export 'widgets/input/glass_text_area.dart';
export 'widgets/input/glass_text_field.dart';
// Widgets - Interactive
export 'widgets/interactive/glass_badge.dart';
export 'widgets/interactive/glass_button.dart';
export 'widgets/interactive/glass_chip.dart';
export 'widgets/interactive/glass_icon_button.dart';
export 'widgets/interactive/glass_page_control.dart';
export 'widgets/interactive/glass_segmented_control.dart';
export 'widgets/interactive/liquid_glass_scope.dart'
    show LiquidGlassScope, GlassBackgroundSource;
export 'widgets/interactive/glass_slider.dart';
export 'widgets/interactive/glass_switch.dart';
export 'widgets/interactive/glass_pull_down_button.dart';
export 'widgets/interactive/glass_button_group.dart';
export 'types/glass_button_style.dart';
// Widgets - Feedback
export 'widgets/feedback/glass_progress_indicator.dart';
// Widgets - Overlays
export 'widgets/overlays/glass_action_sheet.dart';
export 'widgets/overlays/glass_dialog.dart';
export 'widgets/overlays/glass_menu.dart';
export 'widgets/overlays/glass_menu_item.dart';
export 'widgets/overlays/glass_sheet.dart';
export 'widgets/overlays/glass_modal_sheet.dart'
    show
        GlassModalSheet,
        GlassSheetState,
        GlassSheetMode,
        GlassSheetDetent, // the `detents` set on GlassModalSheet / .show()
        GlassSheetPlacement, // the `placement` on GlassModalSheet / .show()
        GlassFillTransition,
        GlassModalSheetController,
        GlassMorphTrigger, // wraps a trigger a sheet morphs out of
        GlassMorphAnchor, // the token GlassMorphTrigger hands its builder
        GlassModalSheetScaffold, // used directly for maps-style hit-through layouts
        GlassModalSheetStateProvider, // read sheet state from descendants
        SheetStateInfo, // value type from GlassModalSheetStateProvider.of()
        ScrollControllerProvider; // access scroll controller from sheet content
export 'widgets/overlays/glass_toast.dart';
export 'widgets/overlays/glass_popover.dart';
// Widgets - Effects
export 'widgets/effects/glass_materialize.dart';
export 'widgets/effects/progressive_blur.dart';
// Widgets - Surfaces
export 'widgets/surfaces/glass_app_bar.dart';
export 'widgets/surfaces/glass_bar_item.dart';
export 'widgets/surfaces/glass_navigation_shell.dart'
    show
        GlassNavigationShell,
        GlassNavigationShellState,
        GlassNavBarRegistration;
// Geometry a bar that is not a GlassAppBar aligns its in-route chrome to.
export 'widgets/surfaces/shared/glass_nav_pinned_host.dart'
    show GlassNavPinnedMetrics;
export 'widgets/surfaces/glass_pinned_bar_chrome.dart';
export 'widgets/surfaces/glass_large_title.dart';
export 'widgets/shared/glass_isolation_scope.dart';
export 'widgets/surfaces/glass_scaffold.dart';
export 'widgets/surfaces/shared/glass_search_bar_config.dart';
export 'widgets/surfaces/shared/tab_bar_searchable_controller.dart';
export 'widgets/surfaces/glass_tab_bar.dart';
export 'widgets/surfaces/glass_toolbar.dart';
export 'widgets/surfaces/glass_vertical_bar.dart';
