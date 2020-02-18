# High quality pre-built Animations for Flutter

This package contains pre-canned animations for commonly-desired effects. The animations can be customized with your content and dropped into your application to delight your users.

To see examples of the following animations on a device or simulator:

```bash
cd example/
flutter run --release
```

## Material motion for Flutter

Material motion is a set of transition patterns that help users understand and navigate an app. Currently,
the following transition patterns are available in this library:

1.  [Container transform](#container-transform)
2.  [Shared axis](#shared-axis)
3.  [Fade through](#fade-through)
4.  [Fade](#fade)

### Container transform

The **container transform** pattern is designed for transitions between UI elements that include a container. This pattern creates a visible connection between two UI elements.

!["Container transform gallery - normal speed and slow motion"](example/demo_gifs/container_transform_lineup.gif)
_Examples of the container transform:_

1.  _A card into a details page_
2.  _A list item into a details page_
3.  _A FAB into a details page_
4.  _A search bar into expanded search_

### Shared axis

The **shared axis** pattern is used for transitions between UI elements that
have a spatial or navigational relationship. This pattern uses a shared
transformation on the x, y, or z axis to reinforce the relationship between
elements.

!["Shared axis gallery - normal speed and slow motion"](example/demo_gifs/shared_axis_lineup.gif)
_Examples of the shared axis pattern:_

1.  _An onboarding flow transitions along the x-axis_
2.  _A stepper transitions along the y-axis_
3.  _A parent-child navigation transitions along the z-axis_

### Fade through

The **fade through** pattern is used for transitions between UI elements that do
not have a strong relationship to each other.

!["Fade through gallery - normal speed and slow motion"](example/demo_gifs/fade_through_lineup.gif)
_Examples of the fade through pattern:_

1.  _Tapping destinations in a bottom navigation bar_
2.  _Tapping a refresh icon_
3.  _Tapping an account switcher_

### Fade

The **fade** pattern is used for UI elements that enter or exit within the
bounds of the screen, such as a dialog that fades in the center of the screen.

!["Fade gallery - normal speed and slow motion"](example/demo_gifs/fade_lineup.gif)
_Examples of the fade pattern:_

1.  _A dialog_
2.  _A menu_
3.  _A snackbar_
4.  _A FAB_
