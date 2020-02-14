# Fancy pre-built Animations for Flutter

**This package is still under heavy development and may change frequently.**

This package contains pre-canned animations for commonly-desired effects. The animations can be customized with your content and dropped into your application to delight your users.

## Available Animations

Currently, the following animated effects are available in this library:

### Material's [Open Container Transitions](https://material.io/design/motion/choreography.html#transformation)

Tapping on a container (e.g. a card or a button) will expand the container to reveal more information.

1) Fade Transition

- Card Example:

![](example/demo_gifs/open_container_fade_card_demo.gif)

- Floating Action Button Example:

![](example/demo_gifs/open_container_fade_floating_action_button_demo.gif)

2) Fade Through Transition

- Card Example:

![](example/demo_gifs/open_container_fade_through_card_demo.gif)

- Floating Action Button Example:

![](example/demo_gifs/open_container_fade_through_floating_action_button_demo.gif)

### Material's [Shared Axis Transitions](https://material.io/design/motion/choreography.html#transformation)

A transition animation between UI elements that have a spatial or navigational
relationship. There are three types of shared axis transitions:

1) Horizontal shared axis transition

A new element slides and fades in horizontally while the previous element slides
and fades out.

![](example/demo_gifs/shared_axis_horizontal_demo.gif)

2) Vertical shared axis transition

A new element slides and fades in vertically while the previous element slides
and fades out.

![](example/demo_gifs/shared_axis_vertical_demo.gif)

3) Scaled shared axis transition

A new element scales and fades in while the previous element scales and fades out

![](example/demo_gifs/shared_axis_scaled_demo.gif)

### Material's [Fade Through Transition](https://material.io/design/motion/choreography.html#transformation)

A transition animation between UI elements that have do not have a strong
relationship to one another.

![](example/demo_gifs/fade_through_demo.gif)

### Material's [Fade Transition](https://material.io/design/motion/choreography.html#transformation)

The fade pattern is used for UI elements that enter or exit from within
the screen bounds.

1) Modal Example:

![](example/demo_gifs/fade_modal_demo.gif)

2) Floating Action Button Example:

![](example/demo_gifs/fade_floating_action_button_demo.gif)