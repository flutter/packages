# Fancy pre-built Animations for Flutter

**This package is still under heavy development and may change frequently.**

This package contains pre-canned animations for commonly-desired effects. The animations can be customized with your content and dropped into your application to delight your users.

## Available Animations

Currently, the following animated effects are available in this library:

### Material's [Open Container Transitions](https://material.io/design/motion/choreography.html#transformation)

Tapping on a container (e.g. a card or a button) will expand the container to reveal more information.

#### Open Container with Fade Transition

The incoming element fades in over the outgoing element.

<p align="center">
    <img
        alt="Open Container Card Fade Transition Demo"
        src="example/demo_gifs/open_container_fade_card_demo.gif"
    >
    <p align="center">Card Example</p>
</p>

<p align="center">
    <img
        alt="Open Container Floating Action Button Fade Transition Demo"
        src="example/demo_gifs/open_container_fade_floating_action_button_demo.gif"
    >
    <p align="center">Floating Action Button Example</p>
</p>

#### Open Container with Fade Through Transition

The outgoing element first fades out. The incoming element starts to fade in
once the outgoing element has completely faded out.

<p align="center">
    <img
        alt="Open Container Card Fade Through Transition Demo"
        src="example/demo_gifs/open_container_fade_through_card_demo.gif"
    >
    <p align="center">Card Example</p>
</p>

<p align="center">
    <img
        alt="Open Container Floating Action Button Fade Through Transition Demo"
        src="example/demo_gifs/open_container_fade_through_floating_action_button_demo.gif"
    >
    <p align="center">Floating Action Button Example</p>
</p>

### Material's [Shared Axis Transitions](https://material.io/design/motion/choreography.html#transformation)

A transition animation between UI elements that have a spatial or navigational
relationship. There are three types of shared axis transitions:

#### Horizontal Shared Axis Transition (x-axis)

A new element slides and fades in horizontally while the previous element slides
and fades out.

<p align="center">
    <img
        alt="Shared Axis Horizontal Transition Demo"
        src="example/demo_gifs/shared_axis_horizontal_demo.gif"
    >
</p>

#### Vertical Shared Axis Transition (y-axis)

A new element slides and fades in vertically while the previous element slides
and fades out.

<p align="center">
    <img
        alt="Shared Axis Vertical Transition Demo"
        src="example/demo_gifs/shared_axis_vertical_demo.gif"
    >
</p>

#### Scaled Shared Axis Transition (z-axis)

A new element scales and fades in while the previous element scales and fades out

<p align="center">
    <img
        alt="Shared Axis Scaled Transition Demo"
        src="example/demo_gifs/shared_axis_scaled_demo.gif"
    >
</p>

### Material's [Fade Through Transition](https://material.io/design/motion/choreography.html#transformation)

A transition animation between UI elements that have do not have a strong
relationship to one another.

<p align="center">
    <img
        alt="Fade Through Transition Demo"
        src="example/demo_gifs/fade_through_demo.gif"
    >
    <p align="center">Fade Through Page Transition</p>
</p>

### Material's [Fade Transition](https://material.io/design/motion/choreography.html#transformation)

The fade pattern is used for UI elements that enter or exit from within
the screen bounds.

<p align="center">
    <img
        alt="Fade Modal Transition Demo"
        src="example/demo_gifs/fade_modal_demo.gif"
    >
    <p align="center">Modal Fade Transition</p>
</p>

<p align="center">
    <img
        alt="Fade Floating Action Button Transition Demo"
        src="example/demo_gifs/fade_floating_action_button_demo.gif"
    >
    <p align="center">Floating Action Button Fade Transition</p>
</p>
